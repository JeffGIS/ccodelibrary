//  NVVideoHeadingViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class NVVideoHeadingViewController;

@protocol NVVideoHeadingViewControllerDelegate <NSObject>

- (void)videoHeadingViewController:(NVVideoHeadingViewController *)videoHeadingViewController
                  didReturnHeading:(CGFloat)heading;

- (void)videoHeadingViewControllerDidCancel:(NVVideoHeadingViewController *)videoHeadingViewController;

@end

@interface NVVideoHeadingViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id <NVVideoHeadingViewControllerDelegate> delegate;
@property (nonatomic) CLLocationManager *locationManager;

+ (NVVideoHeadingViewController *)showVideoHeadingViewControllerWithDelegate:(id)delegate
                                                             stabilityFactor:(CGFloat)stabilityFactor
                                                                 numReadings:(NSInteger)nRead;

@end