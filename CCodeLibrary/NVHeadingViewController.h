//  NVHeadingViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class NVHeadingViewController;

@protocol NVHeadingViewControllerDelegate <NSObject>

- (void)headingViewController:(NVHeadingViewController *)headingViewController
             didReturnHeading:(NSInteger)heading;

- (void)headingViewControllerDidCancel:(NVHeadingViewController *)headingViewController;

@end

@interface NVHeadingViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id <NVHeadingViewControllerDelegate> delegate;
@property (nonatomic) CLLocationManager *locationManager;

+ (NVHeadingViewController *)showHeadingViewControllerWithDelegate:(id)delegate
                                                   stabilityFactor:(CGFloat)stabilityFactor numReadings:(NSInteger)nRead;

@end