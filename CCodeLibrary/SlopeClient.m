//
//  SlopeClient.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/30/19.
//  Copyright © 2019 GSSi. All rights reserved.
//
#import "CRAPI.h"
#import "SlopeClient.h"

@implementation SlopeClient
- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (self.centralManager)
            [self cleanup];
        self.centralManager = [CRAPI.sharedInstance getCentralManager:self];
        if (CRAPI.sharedInstance.NVCRIS_Peripheral)
        {
            [self.centralManager connectPeripheral:CRAPI.sharedInstance.NVCRIS_Peripheral options:nil];
        }
        else
            self.wantScan = TRUE;
        self.data = NSMutableData.new;

    }
    return self;
}
- (void)dealloc
{
    NSLog(@"slopeClient dealloc");
}
- (void) setDelegate:(id<SlopeClientDelegate>)delegate
{
    _delegate = delegate;
    if (_haveData && delegate)
        [_delegate SlopeClient:self returnedData:_slopeData];

}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog (@"Central State:%li",(long)central.state);
    if (central.state != CBCentralManagerStatePoweredOn) {
        showAlert(@"Bluetooth not on");
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
    
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    if (!_wantScan)
        return;
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
    
    NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    //    if (RSSI.integerValue < -60) {
    //        return;
    //    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // Ok, it's in range - have we already seen it?
    //if ([peripheral.name isEqualToString:@"WT901BLE"])
    if (CRAPI.sharedInstance.NVCRIS_Peripheral != peripheral)
    {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        
        CRAPI.sharedInstance.NVCRIS_Peripheral = peripheral;
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    else if (CRAPI.sharedInstance.NVCRIS_Peripheral.state == CBPeripheralStateDisconnected)
    {
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    //_textview.text = [NSString stringWithFormat:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]];
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        //_textview.text = [NSString stringWithFormat:@"Error discovering services: %@", [error localizedDescription]];
        [self cleanup];
        return;
    }
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //_textview.text = [NSString stringWithFormat:@"Error discovering characteristics: %@", [error localizedDescription]];
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
         if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            _slopeDataCharacteristic = characteristic;
            [CRAPI.sharedInstance.NVCRIS_Peripheral setNotifyValue:YES forCharacteristic:_slopeDataCharacteristic];
            
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //_textview.text = [NSString stringWithFormat:@"Error discovering characteristics: %@", [error localizedDescription]];
        return;
    }
    
    long lbytes = characteristic.value.length;
    
    NSLog (@"%li bytes for %@",lbytes,characteristic.UUID.UUIDString);
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        /*
         // Cancel our subscription to the characteristic
         [peripheral setNotifyValue:NO forCharacteristic:characteristic];
         
         // and disconnect from the peripehral
         [self.centralManager cancelPeripheralConnection:peripheral];
         */
        
        NSString * command = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        NSArray<NSString *> * array  = [command componentsSeparatedByString:@";"];
        _slopeData.frontSlopePct = array[0].doubleValue;
        _slopeData.sideSlopePct = array[1].doubleValue;
        _slopeData.maxSlopePct = array[2].doubleValue;
        _slopeData.heading = array[3].doubleValue;
        if (_delegate)
            [_delegate SlopeClient:self returnedData:_slopeData];
        _data = NSMutableData.new;
        _haveData = YES;
        return;
    }
    
    // Otherwise, just add the data on to what we already have
    [_data appendData:characteristic.value];
    

}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting=%i", characteristic,_wantDisconnect);
        if (_wantDisconnect)
            [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    //CRAPI.sharedInstance.NVCRIS_Peripheral = ni;
    
    // We're disconnected, so start scanning again
    [self scan];
}

- (void) cancel{
    _wantScan = FALSE;
    [self cleanup];
}
/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (CRAPI.sharedInstance.NVCRIS_Peripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (CRAPI.sharedInstance.NVCRIS_Peripheral.services != nil) {
        for (CBService *service in CRAPI.sharedInstance.NVCRIS_Peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            _wantDisconnect = YES;
                            [CRAPI.sharedInstance.NVCRIS_Peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:CRAPI.sharedInstance.NVCRIS_Peripheral];
}


@end
