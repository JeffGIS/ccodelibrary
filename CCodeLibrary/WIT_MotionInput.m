//
//  WIT_MotionInput.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/11/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import "WIT_MotionInput.h"
#import "CRAPI.h"
#import "SharedDefaults.h"

#include "JY901.h"
WITRECORD WitRecord;
CJY901 JY901data;

#define WIT_MOTION_UUID1 @"0000FFE4-0000-1000-8000-00805F9A34FB"
#define WIT_MOTION_UUID2 @"0000FFE9-0000-1000-8000-00805F9A34FB"
#define WIT_MOTION_SERVICE_UUID @"0000FFE5-0000-1000-8000-00805F9A34FB"

static unsigned char calibrationBytes[5];

@implementation WIT_MotionInput

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (self.centralManager)
            [self cleanup];
        self.centralManager = [CRAPI.sharedInstance getCentralManager:self];
        if (CRAPI.sharedInstance.WITMotionPeripheral)
            [self.centralManager connectPeripheral:CRAPI.sharedInstance.WITMotionPeripheral options:nil];
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
    NSLog(@"WIT_Motioninput dealloc");
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
        angles[2] = _yaw/_nValues;
    }
    NSLog (@"%@",_pitchValues.debugDescription);
    angles[0] = -[self computeAngle:_rollValues];
    angles[1] = -[self computeAngle:_pitchValues];
    angles[2] = [self computeAngle:_yawValues];

    return rtn;
}
 - (void) restart
{
    self.nValues = 0;
    self.pitch = 0;
    self.roll = 0;
    self.yaw = 0;
    self.rollValues = NSMutableArray.new;
    self.pitchValues = NSMutableArray.new;
    self.yawValues = NSMutableArray.new;
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
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:WIT_MOTION_SERVICE_UUID]]
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
        if (CRAPI.sharedInstance.WITMotionPeripheral != peripheral)
        {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            
            CRAPI.sharedInstance.WITMotionPeripheral = peripheral;
            // And connect
            NSLog(@"Connecting to peripheral %@", peripheral);
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
        else if (CRAPI.sharedInstance.WITMotionPeripheral.state == CBPeripheralStateDisconnected)
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
    [peripheral discoverServices:@[[CBUUID UUIDWithString:WIT_MOTION_SERVICE_UUID]]];
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
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WIT_MOTION_UUID1]]) {
            
            // If it is, subscribe to it
            _dataCharacteristic = characteristic;
            if (_wantSetNotify)
                [CRAPI.sharedInstance.WITMotionPeripheral setNotifyValue:YES forCharacteristic:_dataCharacteristic];

         }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WIT_MOTION_UUID2]]) {
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
    
    //NSLog (@"%li bytes for %@",lbytes,characteristic.UUID.UUIDString);
    CopySerialData(characteristic.value.bytes,lbytes);
    //NSLog (@"Roll:%.2f  Pitch:%.2f  Yaw:%.2f",WITRecord.RollAngle,WITRecord.PitchAngle,WITRecord.YawAngle);
    NSLog (@"Roll:%4f  Pitch:%4f  Yaw:%4f",WitRecord.RollAngle,WitRecord.PitchAngle,WitRecord.YawAngle);
    _nValues++;
    _roll += WitRecord.RollAngle;
    _pitch += WitRecord.PitchAngle;
    _yaw += WitRecord.YawAngle;
    NSNumber * rAngle = [NSNumber numberWithDouble:WitRecord.RollAngle];
    [_rollValues addObject:rAngle];
    NSNumber * pAngle = [NSNumber numberWithDouble:WitRecord.PitchAngle];
    [_pitchValues addObject:pAngle];
    NSNumber * yAngle = [NSNumber numberWithDouble:WitRecord.YawAngle];
    [_yawValues addObject:yAngle];
    if (_firstValueSinceStartInput)
    {
        if (_delegate)
            [_delegate WIT_MotionInputDidConnect:self];
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
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:WIT_MOTION_UUID1]]) {
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
    //CRAPI.sharedInstance.WITMotionPeripheral = ni;
    
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
    if (CRAPI.sharedInstance.WITMotionPeripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (CRAPI.sharedInstance.WITMotionPeripheral.services != nil) {
        for (CBService *service in CRAPI.sharedInstance.WITMotionPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WIT_MOTION_UUID1]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            _wantDisconnect = NO;
                            [CRAPI.sharedInstance.WITMotionPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:CRAPI.sharedInstance.WITMotionPeripheral];
}

- (BOOL) startInput
{
    if (_waitingToConnect)
        return FALSE;
    _wantSetNotify = NO;
    _firstValueSinceStartInput = YES;
    [self restart];
    if (!CRAPI.sharedInstance.WITMotionPeripheral || CRAPI.sharedInstance.WITMotionPeripheral.state == CBPeripheralStateDisconnected)
    {
        _wantScan = YES;
        _wantSetNotify = YES;
        [self scan];
    }
    else if (_dataCharacteristic)
        [CRAPI.sharedInstance.WITMotionPeripheral setNotifyValue:YES forCharacteristic:_dataCharacteristic];
    else
        _wantSetNotify = YES;
    return TRUE;
}
- (void) stopInput
{
    _wantDisconnect = NO;
    if (CRAPI.sharedInstance.WITMotionPeripheral&& _dataCharacteristic)
        [CRAPI.sharedInstance.WITMotionPeripheral setNotifyValue:NO forCharacteristic:_dataCharacteristic];
}
- (void) startCalibration
{
    [SharedDefaults.defaults saveString:@"" forKey:@"LastCalString"];
    _wantScan = YES;
    _wantSetNotify = NO;
    _wantDisconnect = NO;
    _calibrationStep = InStartCalibrate;
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    [CRAPI.sharedInstance.WITMotionPeripheral setNotifyValue:NO forCharacteristic:_dataCharacteristic];
    calibrationBytes[0] = 0xFF;
    calibrationBytes[1] = 0xAA;
    calibrationBytes[2] = 0x01;
    calibrationBytes[3] = 0x01;
    calibrationBytes[4] = 0x00;
    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];

    [self writeCalibrationData:data];
 }
- (void) writeCalibrationData:(NSData*)data
{
    NSLog (@"Writing data:%@",data);
    [CRAPI.sharedInstance.WITMotionPeripheral writeValue:data forCharacteristic:_calibrationCharacteristic type:CBCharacteristicWriteWithResponse];

}
-(void) sleep:(double)secs
{
    [NSThread sleepForTimeInterval:secs];
    return;
}
- (void) leftCalibrate
{
    calibrationBytes[0] = 0xFF;
    calibrationBytes[1] = 0xAA;
    calibrationBytes[2] = 0x01;
    calibrationBytes[3] = 0x05;
    calibrationBytes[4] = 0x00;

    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];
    
    if (_calibrationCharacteristic)
    {
        _calibrationStep = InLeftCalibrate;
        [self writeCalibrationData:data];
        [self sleep:2];
    }
    

}
- (void) rightCalibrate
{
    calibrationBytes[0] = 0xFF;
    calibrationBytes[1] = 0xAA;
    calibrationBytes[2] = 0x01;
    calibrationBytes[3] = 0x06;
    calibrationBytes[4] = 0x00;
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
    calibrationBytes[0] = 0xFF;
    calibrationBytes[1] = 0xAA;
    calibrationBytes[2] = 0x01;
    calibrationBytes[3] = 0x00;
    calibrationBytes[4] = 0x00;
    NSLog (@"Calibration end");
    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];
    [self writeCalibrationData:data];

    [self sleep:2];
    
}
- (void)saveCalibration
{
    calibrationBytes[0] = 0xFF;
    calibrationBytes[1] = 0xAA;
    calibrationBytes[2] = 0x00;
    calibrationBytes[3] = 0x00;
    calibrationBytes[4] = 0x00;

    _calibrationStep = InSaveCalibration;
    NSLog (@"Calibration data saved");
    NSData * data = [NSData dataWithBytes:calibrationBytes length:5];
    [self writeCalibrationData:data];
    [self sleep:2];
    
}
- (void)notifyStepCompleted
{
    [_delegate WIT_MotionCompletedCalibrationStep:_calibrationStep];
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

short Witshort (unsigned char *in)
{
    short out;
    out = ((short)in[0]<<8)|in[1];
    return out;
}
void  CopySerialData(const void * ucData,unsigned short usLength)
{
    static unsigned char chrTempUnsigned[2000];
    static unsigned char chrTempSigned[2000];
    static unsigned char ucRxCnt = 0;
    static unsigned short usRxLength = 0;
    int haveData = 0;
    int num = 1;
    
    /*if (*(char *)&num == 1)
     {
     printf("Little-Endian\n");
     }
     else
     {
     printf("Big-Endian\n");
     }*/
    
    memset (&WitRecord,0,sizeof(WitRecord));
    //if (usLength != 20)
    //    return;
    memcpy(chrTempUnsigned,ucData,usLength);
    memcpy(chrTempSigned,ucData,usLength);
    usRxLength += usLength;
    {
        if (chrTempUnsigned[0] != 0x55)
        {
            return;
        }
        switch(chrTempUnsigned[1])
        {
            case 0x50:
                memcpy(&JY901data.stcTime,&chrTempUnsigned[2],8);
                break;
            case 0x51:
                memcpy(&JY901data.stcAcc,&chrTempUnsigned[2],8);
                break;
            case 0x52:
                memcpy(&JY901data.stcGyro,&chrTempUnsigned[2],8);
                break;
            case 0x53:
                memcpy(&JY901data.stcAngle,&chrTempUnsigned[2],8);
                break;
            case 0x71:
                memcpy(&JY901data.stcMag,&chrTempUnsigned[2],8);
                break;
            case 0x55:
                memcpy(&JY901data.stcDStatus,&chrTempUnsigned[2],8);
                break;
            case 0x56:
                memcpy(&JY901data.stcPress,&chrTempUnsigned[2],8);
                break;
            case 0x57:
                memcpy(&JY901data.stcLonLat,&chrTempUnsigned[2],8);
                break;
            case 0x58:
                memcpy(&JY901data.stcGPSV,&chrTempUnsigned[2],8);
                break;
            case 0x61:
                
                memcpy(&WitRecord.accvals,&chrTempUnsigned[2],6);
                memcpy(&WitRecord.accelerationx,&chrTempUnsigned[2],2);
                memcpy(&WitRecord.accelerationy,&chrTempUnsigned[4],2);
                memcpy(&WitRecord.accelerationz,&chrTempUnsigned[6],2);
                memcpy(&WitRecord.angvelocityx,&chrTempUnsigned[8],2);
                memcpy(&WitRecord.angvelocityy,&chrTempUnsigned[10],2);
                memcpy(&WitRecord.angvelocityz,&chrTempUnsigned[12],2);
                memcpy(&WitRecord.roll,&chrTempUnsigned[14],2);
                memcpy(&WitRecord.pitch,&chrTempUnsigned[16],2);
                memcpy(&WitRecord.yaw,&chrTempUnsigned[18],2);
                
                /*  WITRecord.accelerationx = witshort(&chrTempUnsigned[2]);
                 WITRecord.accelerationy = witshort(&chrTempUnsigned[4]);
                 WITRecord.accelerationz = witshort(&chrTempUnsigned[6]);
                 WITRecord.angvelocityx = witshort (&chrTempUnsigned[8]);
                 WITRecord.angvelocityy = witshort (&chrTempUnsigned[10]);
                 WITRecord.angvelocityz = witshort (&chrTempUnsigned[12]);
                 WITRecord.roll = witshort (&chrTempUnsigned[14]);
                 WITRecord.pitch = witshort (&chrTempUnsigned[16]);
                 WITRecord.yaw = witshort (&chrTempUnsigned[18]);
                 */
                /*                axL X-axis acceleration low 8bit
                 axH X-axis acceleration high 8bit
                 ayL X-axis acceleration low 8bit
                 ayH X-axis acceleration high 8bit
                 azL X-axis acceleration low 8bit
                 azH X-axis acceleration high 8bit
                 wxL X-axis angular velocity low 8bit
                 wxH X-axis angular velocity high 8bit
                 wyL Y-axis angular velocity low 8bit
                 wyH Y-axis angular velocity high 8bit
                 wzL Z-axis angular velocity low 8bit
                 wzH Z-axis angular velocity high 8bit
                 RollL X-axis angle low 8bit
                 RollH X-axis angle high 8bit
                 PitchL Y-axis angle low 8bit
                 PitchH Y-axis angle high 8bit
                 YawL Z-axis angle low 8bit
                 YawH Z-axis angle high 8bit
                 Roll angle(x-axis)Roll=((RollH<<8)|RollL)/32768*180(°)
                 Pitching angle(y-axis)Pitch=((PitchH<<8)|PitchL)/32768*180(°)
                 Yaw angle(z-axis)Yaw=((YawH<<8)|YawL)/32768*180(°)
                 */
                WitRecord.RollAngle = WitRecord.roll/32768.0 * 180.0;
                WitRecord.PitchAngle = WitRecord.pitch/32768.0 * 180.0;
                WitRecord.YawAngle = WitRecord.yaw/32768.0 * 180.0;
                break;
        }
        return;
    }
}


@end
