//
//  SOLAR2Input.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/11/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SOLAR2CalibrateSteps)
{
    InStartCalibrateSOLAR2,
    InLeftCalibrateSOLAR2,
    InRightCalibrateSOLAR2,
    InEndCalibrationSOLAR2,
    InSaveCalibrationSOLAR2,
};

@class SOLAR2Input;

@protocol SOLAR2InputDelegate <NSObject>

- (void)SOLAR2InputDidConnect:(SOLAR2Input *)controller;
- (void)SOLAR2CompletedCalibrationStep:(SOLAR2CalibrateSteps)step;

@end

@interface SOLAR2Input : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, weak) id <SOLAR2InputDelegate> delegate;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property int nValues;
@property double roll, pitch;
@property NSMutableArray * rollValues;
@property NSMutableArray * pitchValues;
@property BOOL wantScan;
@property BOOL wantSetNotify;
@property BOOL wantDisconnect;
@property BOOL waitingToConnect;
@property SOLAR2CalibrateSteps calibrationStep;
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
