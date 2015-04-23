//  NVHeadingViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class NVHeadingViewController;

@protocol NVHeadingViewControllerDelegate <NSObject>

@end

@interface NVHeadingViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id <NVHeadingViewControllerDelegate> delegate;
@property (nonatomic) CLLocationManager *locationManager;

+ (NVHeadingViewController *)showHeadingViewController:(id)delegate;

@end