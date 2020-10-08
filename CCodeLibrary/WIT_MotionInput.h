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

typedef NS_ENUM(NSInteger, WITMotionCalibrateSteps)
{
    InStartCalibrate,
    InLeftCalibrate,
    InRightCalibrate,
    InEndCalibration,
    InSaveCalibration,
};

@class WIT_MotionInput;

@protocol WIT_MotionInputDelegate <NSObject>

- (void)WIT_MotionInputDidConnect:(WIT_MotionInput *)controller;
- (void)WIT_MotionCompletedCalibrationStep:(WITMotionCalibrateSteps)step;

@end

@interface WIT_MotionInput : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, weak) id <WIT_MotionInputDelegate> delegate;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property int nValues;
@property double roll, pitch, yaw;
@property NSMutableArray * rollValues;
@property NSMutableArray * pitchValues;
@property NSMutableArray * yawValues;
@property BOOL wantScan;
@property BOOL wantSetNotify;
@property BOOL wantDisconnect;
@property BOOL waitingToConnect;
@property WITMotionCalibrateSteps calibrationStep;
@property BOOL firstValueSinceStartInput;
@property CBCharacteristic *dataCharacteristic;
@property CBCharacteristic *calibrationCharacteristic;

- (int) getResults:(double *)angles;
- (void) restart;
- (void) cancel;
- (BOOL) startInput;
- (void) stopInput;
- (void) startCalibration;
- (void) leftCalibrate;
- (void) rightCalibrate;
- (void) endCalibration;
- (void) saveCalibration;

@end

NS_ASSUME_NONNULL_END
