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
@property (nonatomic) UIImageView *targetImage;
@property (nonatomic) UIImage *blackTarget, *orangeTarget;

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
    
    _videoSession = [[AVCaptureSession alloc] init];
    
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
    
    _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0,
                                                               self.view.frame.size.height)];
    
    [self setupButton:_returnButton
               target:self
             selector:@selector(returnButtonTapped:)
                title:@"R\nE\nT\nU\nR\nN"];
    
    _startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0),
                                                                    0.0, 60.0, self.view.frame.size.height)];
    
    [self setupButton:_startCancelButton
               target:self
             selector:@selector(startCancelButtonTapped:)
                title:@"S\nT\nA\nR\nT"];
    
    _blackTarget = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"blackCrosshairs"
                                                                                  ofType:@"png"]];
    
    _orangeTarget = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"blackOrangeCrosshairs"
                                                                                   ofType:@"png"]];
    
    _targetImage = [[UIImageView alloc] initWithImage:_blackTarget];
    
    _targetImage.frame = CGRectMake(0.0, 0.0, _targetImage.image.size.width,
                                    _targetImage.image.size.height);
    
    _targetImage.center = CGPointMake((self.view.frame.size.width / 2.0),
                                      (self.view.frame.size.height / 2.0));
    
    [self.view addSubview:_targetImage];
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationPortrait;
    
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
    
    _status = NVVideoHeadingStatusReady;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.titleLabel.font = [UIFont boldSystemFontOfSize:56.0];
    button.backgroundColor = UIColor.blackColor;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateHighlighted];
    
    [button setTitleColor:UIColor.grayColor
                 forState:UIControlStateDisabled];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)returnButtonTapped:(UIButton *)button
{
    if (_status == NVVideoHeadingStatusComplete)
    {
        if (_delegate)
        {
            NSDecimal dIn = [NSNumber numberWithDouble:_avgHeading].decimalValue;
            NSDecimal dOut;
            NSDecimalRound(&dOut, &dIn, 0, NSRoundPlain);
            
            NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithDecimal:dOut];
            NSInteger resultInteger = result.integerValue;
            
            [_delegate videoHeadingViewController:self
                                 didReturnHeading:resultInteger];
        }
    }
    
    else
    {
        if (_delegate)
            [_delegate videoHeadingViewControllerDidCancel:self];
    }
    
    [_videoSession stopRunning];
}

- (void)startCancelButtonTapped:(UIButton *)button
{
    switch (_status)
    {
        case NVVideoHeadingStatusComplete:
            if (CLLocationManager.headingAvailable)
                [_locationManager startUpdatingHeading];
            
        case NVVideoHeadingStatusReady:
            _returnButton.enabled = NO;
            
            [_startCancelButton setTitle:@"C\nA\nN\nC\nE\nL"
                                forState:UIControlStateNormal];
            
            _targetImage.image = _orangeTarget;
            _status = NVVideoHeadingStatusGettingHeading;
            _counter = 0;
            break;
            
        case NVVideoHeadingStatusGettingHeading:
            _returnButton.enabled = YES;
            
            [_startCancelButton setTitle:@"S\nT\nA\nR\nT"
                                forState:UIControlStateNormal];
            
            _targetImage.image = _blackTarget;
            _status = NVVideoHeadingStatusReady;
            break;
            
        default:
            break;
    }
}

-(CGFloat)correctedHeading:(CGFloat)heading
{
    CGFloat corrected = heading;
    
    if (_referenceHeading - heading < -180)
        corrected = heading - 360.0;
    
    else if (_referenceHeading - heading > 180)
        corrected = heading + 360.0;
    
    return corrected;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    switch (_status)
    {
        case NVVideoHeadingStatusGettingHeading:
        {
            CGFloat heading;
            
            if (!_counter)
            {
                _sumHeading = heading = _referenceHeading = _minHeading =
                _maxHeading = newHeading.trueHeading;
            }
            
            else
            {
                heading = [self correctedHeading:newHeading.trueHeading];
                _minHeading = min(_minHeading, heading);
                _maxHeading = max(_maxHeading, heading);
                _sumHeading += heading;
            }
            
            _counter++;
            
            if (abs((_maxHeading - _minHeading) < _stabilityFactor))
            {
                if (_counter >= _numDesiredReadings)
                {
                    _status = NVVideoHeadingStatusComplete;
                    _targetImage.image = _blackTarget;
                    _returnButton.enabled = YES;
                    _avgHeading = (_sumHeading / _counter);
                    
                    if (_avgHeading > 360.0)
                        _avgHeading -= 360.0;
                    
                    else if (_avgHeading < 0)
                        _avgHeading += 360.0;
                    
                    [_startCancelButton setTitle:@"S\nT\nA\nR\nT"
                                        forState:UIControlStateNormal];
                    
                    [_locationManager stopUpdatingHeading];
                }
            }
            
            else
                _counter = 0;
        }
            
        default:
            break;
    }
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