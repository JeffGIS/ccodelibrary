//
//  WIT_MotionInput.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/11/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


NS_ASSUME_NONNULL_BEGIN

@interface WIT_MotionInput : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property int nValues;
@property double roll, pitch, yaw;
@property BOOL wantScan;
@property BOOL wantSetNotify;
@property CBCharacteristic *dataCharacteristic;
@property CBCharacteristic *calibrationCharacteristic;

- (int) getResults:(double *)angles;
- (void) restart;
- (void) cancel;
- (void) startInput;
- (void) stopInput;
- (void) startCalibration;
- (void) leftCalibrate;
- (void) rightCalibrate;
@end

NS_ASSUME_NONNULL_END
