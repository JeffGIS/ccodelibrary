//  GSSiSlopeViewController.h
//  CCodeLibrary

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef struct NVSlopeData {
    CGFloat accelX;
    CGFloat accelY;
    CGFloat accelZ;
    CGFloat gravX;
    CGFloat gravY;
    CGFloat gravZ;
    CGFloat yaw;
    CGFloat pitch;
    CGFloat roll;
} NVSlopeData;

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData
                         slopes:(CGFloat *)slopes
                        heading:(CGFloat)heading;

- (BOOL)shouldUseCalibration:(GSSiSlopeViewController *)controller;

@end

@interface GSSiSlopeViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;

+ (GSSiSlopeViewController *)slopeControllerWithCalibrationTarget:(CGFloat)calibrationTarget
                                                       flipRadius:(CGFloat)flipRadius
                                                         delegate:(id)delegate;

@property (nonatomic) CGFloat calibrationTarget, flipRadius;

@end