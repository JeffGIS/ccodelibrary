//  NVVideoHeadingViewController.m
//  CCodeLibrary

#import "NVVideoHeadingViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "UserDefaults.h"

typedef NS_ENUM(NSInteger, NVVideoHeadingStatus)
{
    NVVideoHeadingStatusDefault,
    NVVideoHeadingStatusReady,
    NVVideoHeadingStatusGettingHeading,
    NVVideoHeadingStatusComplete,
};

@interface NVVideoHeadingViewController ()

@property (nonatomic) UIButton *returnButton, *startCancelButton;
@property NVVideoHeadingStatus status;
@property (nonatomic) NSDate *startTime;
@property CGFloat referenceHeading, minHeading, maxHeading, sumHeading, avgHeading;
@property NSInteger counter, numDesiredReadings;
@property (nonatomic) CGFloat stabilityFactor;
@property (nonatomic) AVCaptureSession *videoSession;

@end

@implementation NVVideoHeadingViewController

+ (NVVideoHeadingViewController *)showVideoHeadingViewControllerWithDelegate:(id)delegate
                                                             stabilityFactor:(CGFloat)stabilityFactor
                                                                 numReadings:(NSInteger)nRead
{
    NVVideoHeadingViewController *videoHeadingVC = [[NVVideoHeadingViewController alloc] init];
    videoHeadingVC.delegate = delegate;
    videoHeadingVC.stabilityFactor = stabilityFactor;
    videoHeadingVC.numDesiredReadings = nRead;
    videoHeadingVC.videoSession = [[AVCaptureSession alloc] init];
    
    if ([delegate isKindOfClass:UIViewController.class])
    {
        [delegate presentViewController:videoHeadingVC
                               animated:YES
                             completion:nil];
    }
    
    return videoHeadingVC;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.blackColor;
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:&error];
    
    if (videoInput)
        [_videoSession addInput:videoInput];
    
    else
        NSLog(@"Video Input ERROR:%@", error.localizedDescription);
    
    AVCaptureVideoPreviewLayer *videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:_videoSession];
    videoLayer.frame = view.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [view.layer addSublayer:videoLayer];
    self.view = view;
    
    [_videoSession startRunning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _counter = 0;
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        if (CLLocationManager.headingAvailable)
            [_locationManager startUpdatingHeading];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end