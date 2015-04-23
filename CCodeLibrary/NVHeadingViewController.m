//  NVHeadingViewController.m
//  CCodeLibrary

#import "NVHeadingViewController.h"
#import "UserDefaults.h"

@interface NVHeadingViewController ()

@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) UILabel *headingLabel;
@property (nonatomic) UIButton *returnButton;

@end

@implementation NVHeadingViewController

+ (NVHeadingViewController *)showHeadingViewController:(id)delegate
{
    NVHeadingViewController *headingVC = [[NVHeadingViewController alloc] init];
    headingVC.delegate = delegate;
    
    if ([delegate isKindOfClass:UIViewController.class])
    {
        [delegate presentViewController:headingVC
                               animated:YES
                             completion:nil];
    }
    
    return headingVC;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UserDefaults.defaults.appleBlue;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupArrowView];
    [self setupHeadingLabel];
    [self setupReturnButton];
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationFaceUp;
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    else if (status == kCLAuthorizationStatusAuthorized ||
             status == kCLAuthorizationStatusAuthorizedAlways ||
             status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        if (CLLocationManager.headingAvailable)
            [_locationManager startUpdatingHeading];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupArrowView
{
    _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:
                                                     [NSBundle.mainBundle pathForResource:@"coolArrow"
                                                                                   ofType:@"png"]]];
    
    _arrowView.frame = CGRectMake(0.0, 0.0, _arrowView.image.size.width, (_arrowView.image.size.height * 1.5));
    _arrowView.center = self.view.center;
    
    [self.view addSubview:_arrowView];
}

- (void)setupHeadingLabel
{
    _headingLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width * 0.1), 80.0,
                                                              (self.view.frame.size.width * 0.8), 60.0)];
    
    _headingLabel.backgroundColor = UIColor.clearColor;
    _headingLabel.textColor = UIColor.whiteColor;
    _headingLabel.textAlignment = NSTextAlignmentCenter;
    _headingLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [self.view addSubview:_headingLabel];
}

- (void)setupReturnButton
{

}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    _headingLabel.text = [NSString stringWithFormat:@"Current Heading: %li\u00B0", (long)newHeading.trueHeading];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusRestricted &&
        status != kCLAuthorizationStatusDenied)
    {
        if (CLLocationManager.headingAvailable)
            [_locationManager startUpdatingHeading];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    
}

@end