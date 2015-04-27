//  GSSiSlopeViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@class GSSiSlopeViewController;

@protocol GSSiSlopeViewControllerDelegate <NSObject>

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
               didMeasureSlopes:(float *)slopes
                        heading:(float)heading;

- (BOOL)shouldUseCalibration:(GSSiSlopeViewController *)controller;

@end

@interface GSSiSlopeViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id <GSSiSlopeViewControllerDelegate> delegate;
@property (nonatomic) UIButton *unableButton;
@property (nonatomic) UIButton *startCancelButton;
@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) UILabel *frontSlopeLabel;
@property (nonatomic) UILabel *sideSlopeLabel;
@property (nonatomic) UILabel *maxSlopeLabel;
@property (nonatomic) UILabel *promptLabel;
@property (nonatomic) BOOL startCancelState;
@property (nonatomic) BOOL hasRun;
@property (nonatomic) CGFloat xRange;
@property (nonatomic) CGFloat yRange;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat sumX;
@property (nonatomic) CGFloat sumY;
@property (nonatomic) CGFloat sumZ;
@property (nonatomic) CGFloat x1;
@property (nonatomic) CGFloat y1;
@property (nonatomic) CGFloat z;
@property (nonatomic) CGFloat x2;
@property (nonatomic) CGFloat y2;
@property (nonatomic) CGFloat frontSlope;
@property (nonatomic) CGFloat sideSlope;
@property (nonatomic) CGFloat maxSlope;
@property (nonatomic) int counter;
@property (nonatomic) int calibrationOption;
@property (nonatomic) int headingCounter;
@property (nonatomic) CGFloat sumHeading;
@property (nonatomic) CGFloat avgHeading;
@property (nonatomic) UILabel *headingLabel;
@property (nonatomic) CGFloat target;
@property (nonatomic) CGFloat forceFlip;
@property (nonatomic) BOOL unable;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CMMotionManager *motionManager;

- (id)initWithTarget:(CGFloat)target
           forceFlip:(CGFloat)forceFlip;

@end