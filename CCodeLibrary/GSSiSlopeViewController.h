//  GSSiSlopeViewController.h
//  CCodeLibrary

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
                didReturnAccelX:(CGFloat)accelX
                         accelY:(CGFloat)accelY
                         accelZ:(CGFloat)accelZ
                          gravX:(CGFloat)gravX
                          gravY:(CGFloat)gravY
                          gravZ:(CGFloat)gravZ
                            yaw:(CGFloat)yaw
                          pitch:(CGFloat)pitch
                           roll:(CGFloat)roll
                         slopes:(CGFloat *)slopes
                        heading:(CGFloat)heading;

- (BOOL)shouldUseCalibration:(GSSiSlopeViewController *)controller;

@end

@interface GSSiSlopeViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;
@property (nonatomic) NSString *which;
@property (nonatomic) NSInteger mode;

@end