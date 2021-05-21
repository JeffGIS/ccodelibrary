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
    InStartInputSOLAR2,
    InStopInputSOLAR2,
    InStartCalibrateSOLAR2,
    InCalibrateStep1SOLAR2,
    InCalibrateStep2SOLAR2,
    InCalibrateStep3SOLAR2,
    InCalibrateStep4SOLAR2,
    InCalibrateStep5SOLAR2,
    InCalibrateStep6SOLAR2,
    InGetSlopeDataSOLAR2,
};

@class SOLAR2Input;

@protocol SOLAR2InputDelegate <NSObject>

- (void)SOLAR2InputDidConnect:(SOLAR2Input *)controller;
- (void)SOLAR2CompletedCalibrationStep:(SOLAR2CalibrateSteps)step
                                status:(NSString *)status;

@end

@interface SOLAR2Input : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, weak) id <SOLAR2InputDelegate> delegate;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property float sleepTime;
@property NSString * tranRate;
@property NSString * filter;
@property int nValues;
@property double roll, pitch;
@property NSMutableArray * rollValues;
@property NSMutableArray * pitchValues;
@property BOOL wantScan;
@property BOOL wantSetNotify;
@property BOOL wantDisconnect;
@property BOOL waitingToConnect;
@property SOLAR2CalibrateSteps calibrationStep;
@property NSString * ioStatus;
@property BOOL firstValueSinceStartInput;
@property BOOL inCalibrate;
@property CBCharacteristic *dataCharacteristic;
@property CBCharacteristic *calibrationCharacteristic;

- (int) getResults:(double *)angles;
- (void) restart;
- (void) cancel;
- (BOOL) startInput:(BOOL)inCalibrate;
- (void) stopInput;
- (void) startCalibration;
- (void) calibrateStep:(int)step;
- (void) startDataCollection;

@end

NS_ASSUME_NONNULL_END
