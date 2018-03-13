//  GSSiSlopeViewController.h
//  CCodeLibrary

@import UIKit;
#import "NVSliderController.h"

#define SDWK_ERROR_VAL 0.25

typedef NS_ENUM(NSInteger, NVManualStatus)
{
    NVManualStatusDevice,
    NVManualStatusManual,
    NVManualStatusCancelled,
};

typedef struct NVSlopeData {
    double accelX;
    double accelY;
    double accelZ;
    double frontSlopeDegrees;
    double sideSlopeDegrees;
    double frontSlopePct;
    double sideSlopePct;
    double manualFrontSlopeDegrees;
    double manualSideSlopeDegrees;
    double manualFrontSlopePct;
    double manualSideSlopePct;
    double maxSlopePct;
    double maxSlopeDegrees;
    double heading;
    NVManualStatus frontManualStatus;
    NVManualStatus sideManualStatus;
} NVSlopeData;

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData;

- (void)gssiSlopeViewControllerDidCancelForSystemCalibration:(GSSiSlopeViewController *)controller;

@optional
- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData
                       location:(CLLocationCoordinate2D)location;

@end

@interface GSSiSlopeViewController : UIViewController <NVSliderControllerDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;
@property BOOL displayDegrees;
@property BOOL useCalibration, fromCalibration;
@property BOOL useHeadingCalibration, hideDoesNotExistButton;
@property (nonatomic) double steadyFactor;
@property (nonatomic) double countFactor;
@property (nonatomic) double criticalValue;
@property (nonatomic) double criticalSideValue;
@property (nonatomic, copy) NSString *promptText;
@property (nonatomic) double errorValue;

+ (GSSiSlopeViewController *)slopeControllerWithCriticalValue:(double)criticalVal
                                            criticalSideValue:(double)criticalSideVal
                                                   errorValue:(double)errVal
                                               useCalibration:(BOOL)useCalibration
                                        useHeadingCalibration:(BOOL)useHeadingCalibration
                                                 steadyFactor:(double)steadyFac
                                                  countFactor:(double)countFac
                                               displayDegrees:(BOOL)displayDegrees
                                                     delegate:(id)delegate;

@end
