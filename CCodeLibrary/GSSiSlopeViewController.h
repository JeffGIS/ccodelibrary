//  GSSiSlopeViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVSliderController.h"

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
    CGFloat frontSlope;
    CGFloat sideSlope;
    CGFloat heading;
} NVSlopeData;

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData;

- (BOOL)shouldUseCalibration:(GSSiSlopeViewController *)controller;

@end

@interface GSSiSlopeViewController : UIViewController <NVSliderControllerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;

+ (GSSiSlopeViewController *)slopeControllerWithCalibrationTarget:(CGFloat)calibrationTarget
                                                       flipRadius:(CGFloat)flipRadius
                                                         delegate:(id)delegate;

@property (nonatomic) CGFloat calibrationTarget, flipRadius, steadyDiff;
@property (nonatomic) NSString *which;
@property (nonatomic) NSInteger mode;

@end