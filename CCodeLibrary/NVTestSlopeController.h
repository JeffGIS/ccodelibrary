//  NVTestSlopeController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVSliderController.h"
#import "NVLargeAlertView.h"

typedef struct NVSlopeTestData {
    CGFloat accelX;
    CGFloat accelY;
    CGFloat accelZ;
    CGFloat gravX;
    CGFloat gravY;
    CGFloat gravZ;
    CGFloat yaw;
    CGFloat pitch;
    CGFloat roll;
    CGFloat rm11;
    CGFloat rm12;
    CGFloat rm13;
    CGFloat rm21;
    CGFloat rm22;
    CGFloat rm23;
    CGFloat rm31;
    CGFloat rm32;
    CGFloat rm33;
    CGFloat quatX;
    CGFloat quatY;
    CGFloat quatZ;
    CGFloat quatW;
    CGFloat deviceSlopeDegrees;
    CGFloat deviceSlopePct;
    CGFloat manualSlope;
    CGFloat magneticHeading;
    CGFloat trueHeading;
    CGFloat manualHeading;
    CGFloat batteryLevel;
    UIDeviceOrientation orientation;
} NVSlopeTestData;

@class NVTestSlopeController;

@protocol NVTestSlopeControllerDelegate <NSObject>

- (BOOL)shouldUseCalibration:(NVTestSlopeController *)controller;

- (void)testSlopeViewController:(NVTestSlopeController *)controller
         didReturnSlopeTestData:(NVSlopeTestData)data;

@end

@interface NVTestSlopeController : UIViewController <NVSliderControllerDelegate,NVLargeAlertViewDelegate>

@property (nonatomic, weak) id <NVTestSlopeControllerDelegate> delegate;

+ (NVTestSlopeController *)slopeControllerWithDelegate:(id)delegate;

@end