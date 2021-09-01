//  GSSiSlopeViewController.h
//  CCodeLibrary

@import UIKit;
#import "NVSliderController.h"
#import "WIT_MotionInput.h"
#import "SOLAR-2Input.h"
#import "SlopeClient.h"

#define SDWK_ERROR_VAL 0.25


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

@interface GSSiSlopeViewController : UIViewController <NVSliderControllerDelegate,CLLocationManagerDelegate,WIT_MotionInputDelegate,SOLAR2InputDelegate,SlopeClientDelegate>

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
@property (nonatomic) double errorValueSide;
@property BOOL wantLocation;
@property BOOL wantWitMotion;
@property BOOL wantSOLAR2;
@property BOOL wantZeroButton;
@property WITMotionCalibrateSteps WITMotionCalibrationStep;
@property SOLAR2CalibrateSteps SOLAR2CalibrationStep;
@property NSTimer * timer;

+ (GSSiSlopeViewController *)slopeControllerWithCriticalValue:(double)criticalVal
                                            criticalSideValue:(double)criticalSideVal
                                                   errorValue:(double)errVal
                                               useCalibration:(BOOL)useCalibration
                                        useHeadingCalibration:(BOOL)useHeadingCalibration
                                                 steadyFactor:(double)steadyFac
                                                  countFactor:(double)countFac
                                               displayDegrees:(BOOL)displayDegrees
                                                     delegate:(id)delegate;
- (void)startStopAutoLoop:(UIButton *)button;
@end
