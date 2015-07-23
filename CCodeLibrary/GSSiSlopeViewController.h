//  GSSiSlopeViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVSliderController.h"
#import <CoreLocation/CoreLocation.h>

typedef struct NVSlopeData {
    CGFloat accelX[2];
    CGFloat accelY[2];
    CGFloat accelZ[2];
    CGFloat gravX[2];
    CGFloat gravY[2];
    CGFloat gravZ[2];
    CGFloat yaw[2];
    CGFloat pitch[2];
    CGFloat roll[2];
    CGFloat frontSlopeDegrees;
    CGFloat sideSlopeDegrees;
    CGFloat frontSlopePct;
    CGFloat sideSlopePct;
    CGFloat maxSlopePct;
    CGFloat maxSlopeDegrees;
    CGFloat maxSlopeDeflection;
    CGFloat heading;
} NVSlopeData;

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData;

@end

@interface GSSiSlopeViewController : UIViewController <NVSliderControllerDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *which;
@property NSInteger mode;
@property BOOL displayDegrees;
@property BOOL useCalibration;
@property BOOL useHeadingCalibration;
@property CGFloat steadyFactor;
@property CGFloat countFactor;
@property CGFloat criticalValue;
@property CGFloat criticalSideValue;
@property NSString *promptText;
@property CGFloat errorValue;
@property BOOL selfTest;

+ (GSSiSlopeViewController *)slopeControllerWithCriticalValue:(CGFloat)criticalVal
                                            criticalSideValue:(CGFloat)criticalSideVal
                                                   errorValue:(CGFloat)errVal
                                               useCalibration:(BOOL)useCalibration
                                                     selfTest:(BOOL)selfTest
                                                 steadyFactor:(CGFloat)steadyFac
                                                  countFactor:(CGFloat)countFac
                                               displayDegrees:(BOOL)displayDegrees
                                                     delegate:(id)delegate;

- (void)removeManualMeasurementButton;
- (void)removeCalDateLabel;

@end