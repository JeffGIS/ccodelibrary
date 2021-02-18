//
//  SOLAR2Input.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/11/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import "SOLAR-2Input.h"
#import "CRAPI.h"
#import "SharedDefaults.h"

#include "JY901.h"

//#define SOLAR2_UUID1 @"0000FFE4-0000-1000-8000-00805F9A34FB"
//#define SOLAR2_UUID2 @"0000FFE9-0000-1000-8000-00805F9A34FB"
//#define SOLAR2_SERVICE_UUID @"0000FFE5-0000-1000-8000-00805F9A34FB"
#define SOLAR2_UUID1 @"00031201-0000-1000-8000-00805F9B0130"
#define SOLAR2_UUID2 @"00031202-0000-1000-8000-00805F9B0130"
//#define SOLAR2_SERVICE_UUID @"0000180A-0000-1000-8000-00805F9B34FB"
#define SOLAR2_SERVICE_UUID @"0003ABCD-0000-1000-8000-00805F9B0131"

static unsigned char calibrationBytes[8];

@implementation SOLAR2Input

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (self.centralManager)
            [self cleanup];
        self.centralManager = [CRAPI.sharedInstance getCentralManager:self];
        if (CRAPI.sharedInstance.SOLAR2Peripheral)
            [self.centralManager connectPeripheral:CRAPI.sharedInstance.SOLAR2Peripheral options:nil];
        else
            self.wantScan = TRUE;
        [self restart];
        self.wantSetNotify = NO;
        self.wantDisconnect = NO;
        calibrationBytes[0] = 0xFF;
        calibrationBytes[1] = 0xAA;
        calibrationBytes[2] = 0x01;
        calibrationBytes[3] = 0x01;
        calibrationBytes[4] = 0x00;
    }
  return self;
}
- (void)dealloc
{
    _centralManager.delegate = nil;
    NSLog(@"SOLAR2input dealloc");
}
- (double) averageValue:(NSArray*)values
{
    double tot = 0;
    if (values.count)
    {
        for (NSNumber * num in values)
        {
            tot += num.doubleValue;
        }
        tot /= values.count;
    }
    return tot;
}
- (NSArray *) removeOutliers:(NSArray*)values
{
    NSMutableArray * newValues=NSMutableArray.new;
    NSMutableArray <NSNumber*>* diffArray = NSMutableArray.new;
    double aveValue = [self averageValue:values];
    for (NSNumber *num in values)
    {
        double diff = fabs (num.doubleValue - aveValue);
        NSNumber *dif = [NSNumber numberWithDouble:diff];
        [diffArray addObject:dif];
    }
    [diffArray sortUsingSelector:@selector(compare:)];
    int maxDiffIndex = min (max (0,values.count * 0.8),values.count-1);
    double maxdiff = diffArray[maxDiffIndex].doubleValue;
    for (NSNumber * num in values)
    {
        if (fabs(num.doubleValue - aveValue) <= maxdiff)
        {
            [newValues addObject:num];
        }
    }
    return newValues;
}
- (double) computeAngle:(NSArray*)values
{
    double rtn = [self averageValue:values];
    if (values.count>5)
    {
        NSArray *newValues= [self removeOutliers:values];
        rtn = [self averageValue:newValues];
    }
    return rtn;
}
- (int) getResults:(double *)angles
{
    int rtn = _nValues;

    if (_nValues > 0)
    {
        angles[0] = _roll/_nValues;
        angles[1] = _pitch/_nValues;
    }
    NSLog (@"%@",_pitchValues.debugDescription);
    angles[0] = -[self computeAngle:_rollValues];
    angles[1] = -[self computeAngle:_pitchValues];

    return rtn;
}
 - (void) restart
{
    self.nValues = 0;
    self.pitch = 0;
    self.roll = 0;
    self.rollValues = NSMutableArray.new;
    self.pitchValues = NSMutableArray.new;
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
    _waitingToConnect = YES;
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SOLAR2_SERVICE_UUID]]
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
        if (CRAPI.sharedInstance.SOLAR2Peripheral != peripheral)
        {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            
            CRAPI.sharedInstance.SOLAR2Peripheral = peripheral;
            // And connect
            NSLog(@"Connecting to peripheral %@", peripheral);
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
        else if (CRAPI.sharedInstance.SOLAR2Peripheral.state == CBPeripheralStateDisconnected)
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
    _waitingToConnect = NO;
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SOLAR2_SERVICE_UUID]]];
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
        NSString * str = characteristic.UUID.UUIDString;
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SOLAR2_UUID1]]) {
            
            // If it is, subscribe to it
            _dataCharacteristic = characteristic;
            if (_wantSetNotify)
                [CRAPI.sharedInstance.SOLAR2Peripheral setNotifyValue:YES forCharacteristic:_dataCharacteristic];

         }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SOLAR2_UUID2]]) {
            _calibrationCharacteristic = characteristic;
            
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

    NSString * data = [NSString stringWithUTF8String:[characteristic.value bytes]];

    //NSLog (@"%li bytes for %@",lbytes,characteristic.UUID.UUIDString);
    //CopySerialData(characteristic.value.bytes,lbytes);
    //NSLog (@"Roll:%.2f  Pitch:%.2f  Yaw:%.2f",WITRecord.RollAngle,WITRecord.PitchAngle,WITRecord.YawAngle);
    //NSLog (@"Roll:%4f  Pitch:%4f  Yaw:%4f",WitRecord.RollAngle,WitRecord.PitchAngle,WitRecord.YawAngle);
    NSArray <NSString*>*strings = [data componentsSeparatedByString:@","];
    if (strings.count ==2)
    {
        _nValues++;
        _roll += strings[0].doubleValue;
        _pitch += strings[1].doubleValue;
    //_yaw += WitRecord.YawAngle;
        NSNumber * rAngle = [NSNumber numberWithDouble:strings[0].doubleValue];
        [_rollValues addObject:rAngle];
        NSNumber * pAngle = [NSNumber numberWithDouble:strings[1].doubleValue];
        [_pitchValues addObject:pAngle];
    }
    //NSNumber * yAngle = [NSNumber numberWithDouble:WitRecord.YawAngle];
    //[_yawValues addObject:yAngle];
    if (_firstValueSinceStartInput)
    {
        if (_delegate)
            [_delegate SOLAR2InputDidConnect:self];
    }
    _firstValueSinceStartInput = NO;
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:SOLAR2_UUID1]]) {
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
    //CRAPI.sharedInstance.SOLAR2Peripheral = ni;
    
    // We're disconnected, so start scanning again
    [self scan];
}

- (void) cancel{
    //_wantScan = FALSE;
    [self cleanup];
}
/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (CRAPI.sharedInstance.SOLAR2Peripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (CRAPI.sharedInstance.SOLAR2Peripheral.services != nil) {
        for (CBService *service in CRAPI.sharedInstance.SOLAR2Peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SOLAR2_UUID1]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            _wantDisconnect = NO;
                            [CRAPI.sharedInstance.SOLAR2Peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:CRAPI.sharedInstance.SOLAR2Peripheral];
}

- (BOOL) startInput
{
    if (_waitingToConnect)
        return FALSE;
    _wantSetNotify = NO;
    _firstValueSinceStartInput = YES;
    [self restart];
    if (!CRAPI.sharedInstance.SOLAR2Peripheral || CRAPI.sharedInstance.SOLAR2Peripheral.state == CBPeripheralStateDisconnected)
    {
        _wantScan = YES;
        _wantSetNotify = YES;
        [self scan];
    }
    else if (_dataCharacteristic)
        [CRAPI.sharedInstance.SOLAR2Peripheral setNotifyValue:YES forCharacteristic:_dataCharacteristic];
    else
        _wantSetNotify = YES;
    return TRUE;
}
- (void) stopInput
{
    _wantDisconnect = NO;
    if (CRAPI.sharedInstance.SOLAR2Peripheral&& _dataCharacteristic)
        [CRAPI.sharedInstance.SOLAR2Peripheral setNotifyValue:NO forCharacteristic:_dataCharacteristic];
}
- (void) startCalibration
{
    [SharedDefaults.defaults saveString:@"" forKey:@"LastCalString"];
    _wantScan = YES;
    _wantSetNotify = NO;
    _wantDisconnect = NO;
    _calibrationStep = InStartCalibrateSOLAR2;
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    [CRAPI.sharedInstance.SOLAR2Peripheral setNotifyValue:NO forCharacteristic:_dataCharacteristic];
    strcpy (calibrationBytes,"setzcur");
    NSData * data = [NSData dataWithBytes:calibrationBytes length:7];

    [self writeCalibrationData:data];
 }
- (void) writeCalibrationData:(NSData*)data
{
    NSLog (@"Writing data:%@",data);
    [CRAPI.sharedInstance.SOLAR2Peripheral writeValue:data forCharacteristic:_calibrationCharacteristic type:CBCharacteristicWriteWithResponse];

}
-(void) sleep:(double)secs
{
    [NSThread sleepForTimeInterval:secs];
    return;
}
- (void) leftCalibrate
{
    strcpy (calibrationBytes,"setzcur");
    NSData * data = [NSData dataWithBytes:calibrationBytes length:7];
    
    if (_calibrationCharacteristic)
    {
        _calibrationStep = InLeftCalibrate;
        [self writeCalibrationData:data];
        [self sleep:2];
    }
    

}
- (void) rightCalibrate
{
    calibrationBytes[3] = 0x06;
    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];
    

    if (_calibrationCharacteristic)
    {
        _calibrationStep = InRightCalibrate;
        [self writeCalibrationData:data];
        [self sleep:2];
    }


}
- (void)endCalibration
{
    _calibrationStep = InEndCalibration;
    calibrationBytes[2] = 0x01;
    calibrationBytes[3] = 0x00;
    NSLog (@"Calibration end");
    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];
    [self writeCalibrationData:data];

    [self sleep:2];
    
}
- (void)saveCalibration
{
    calibrationBytes[0] = 0xFF;
    calibrationBytes[1] = 0xAA;
    calibrationBytes[2] = 0x01;
    calibrationBytes[3] = 0x01;
    calibrationBytes[4] = 0x00;

    _calibrationStep = InSaveCalibration;
    calibrationBytes[2] = 0x00;
    calibrationBytes[3] = 0x00;
    NSLog (@"Calibration data saved");
    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];
    [self writeCalibrationData:data];
    [self sleep:2];
    
}
- (void)notifyStepCompleted
{
    [_delegate SOLAR2CompletedCalibrationStep:_calibrationStep];
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
        NSLog(@"Error on write: %@\r\nchar: %@", [error localizedDescription],characteristic);
    else
    {
        NSLog (@"Calibration data written for step %li",(long)_calibrationStep);
        [self performSelectorOnMainThread:@selector(notifyStepCompleted)
                               withObject:nil
                            waitUntilDone:NO];

        
        switch (_calibrationStep)
        {
            case InSaveCalibration:
                break;
            case InStartCalibrate:
                break;
            case InLeftCalibrate:
                break;
            case InRightCalibrate:
                break;
            case InEndCalibration:
                break;
        }
    }
}



@end
