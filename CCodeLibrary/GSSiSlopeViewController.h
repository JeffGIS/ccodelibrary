//  GSSiSlopeViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVSliderController.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, NVManualStatus)
{
    NVManualStatusDevice,
    NVManualStatusManual,
    NVManualStatusCancelled,
};

typedef struct NVSlopeData {
    CGFloat accelX[2];
    CGFloat accelY[2];
    CGFloat accelZ[2];
    CGFloat frontSlopeDegrees;
    CGFloat sideSlopeDegrees;
    CGFloat frontSlopePct;
    CGFloat sideSlopePct;
    CGFloat manualFrontSlopeDegrees;
    CGFloat manualSideSlopeDegrees;
    CGFloat manualFrontSlopePct;
    CGFloat manualSideSlopePct;
    CGFloat maxSlopePct;
    CGFloat maxSlopeDegrees;
    CGFloat maxSlopeDeflection;
    CGFloat heading;
    NVManualStatus frontManualStatus;
    NVManualStatus sideManualStatus;
} NVSlopeData;

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData;

@end

@interface GSSiSlopeViewController : UIViewController <NVSliderControllerDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;
@property BOOL displayDegrees;
@property BOOL useCalibration;
@property BOOL useHeadingCalibration;
@property (nonatomic) CGFloat steadyFactor;
@property (nonatomic) CGFloat countFactor;
@property (nonatomic) CGFloat criticalValue;
@property (nonatomic) CGFloat criticalSideValue;
@property (nonatomic, copy) NSString *promptText;
@property (nonatomic) CGFloat errorValue;

+ (GSSiSlopeViewController *)slopeControllerWithCriticalValue:(CGFloat)criticalVal
                                            criticalSideValue:(CGFloat)criticalSideVal
                                                   errorValue:(CGFloat)errVal
                                               useCalibration:(BOOL)useCalibration
                                                 steadyFactor:(CGFloat)steadyFac
                                                  countFactor:(CGFloat)countFac
                                               displayDegrees:(BOOL)displayDegrees
                                                     delegate:(id)delegate;

- (void)removeManualMeasurementButton;
- (void)removeCalDateLabel;

@end