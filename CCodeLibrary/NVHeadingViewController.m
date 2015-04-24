//  NVHeadingViewController.m
//  CCodeLibrary

#import "NVHeadingViewController.h"
#import "UserDefaults.h"

typedef NS_ENUM(NSInteger, NVHeadingStatus)
{
    NVHeadingStatusDefault,
    NVHeadingStatusReady,
    NVHeadingStatusCheckingStability,
    NVHeadingStatusGettingHeading,
    NVHeadingStatusComplete,
};

@interface NVHeadingViewController ()

@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) UILabel *headingLabel, *progressInfoLabel;
@property (nonatomic) UIButton *returnButton, *startCancelButton;
@property (nonatomic) UIProgressView *progressView;
@property NVHeadingStatus status;
@property BOOL firstTime;
@property (nonatomic) NSDate *startTime;
@property (nonatomic) CGFloat minHeading, maxHeading, sumHeading, avgHeading;
@property (nonatomic) NSInteger counter;
@property (nonatomic) CGFloat stabilityFactor;

@end

@implementation NVHeadingViewController

+ (NVHeadingViewController *)showHeadingViewControllerWithDelegate:(id)delegate
                                                   stabilityFactor:(CGFloat)stabilityFactor
{
    NVHeadingViewController *headingVC = [[NVHeadingViewController alloc] init];
    headingVC.delegate = delegate;
    headingVC.stabilityFactor = stabilityFactor;
    
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
    
    _firstTime = YES;
    _counter = 0;
    _minHeading = _maxHeading = _sumHeading = _avgHeading = 0.0;
    
    [self setupArrowView];
    [self setupHeadingLabel];
    
    _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, 160.0, 60.0)];
    
    [self setupButton:_returnButton
               target:self
             selector:@selector(returnButtonTapped:)
                title:@"< Return"
             fontSize:32.0];
    
    _startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0, 904.0, 328.0, 80.0)];
    
    [self setupButton:_startCancelButton
               target:self
             selector:@selector(startCancelButtonTapped:)
                title:@"Start"
             fontSize:44.0];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(0.0, 0.0, 640.0, 0.0);
    
    _progressView.center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _arrowView.frame.size.height) +
                                         _startCancelButton.frame.origin.y) / 2.0));
    
    _progressView.progress = 0.0;
    _progressView.trackTintColor = UIColor.blackColor;
    _progressView.progressTintColor = UIColor.whiteColor;
    _progressView.hidden = YES;
    [self.view addSubview:_progressView];
    
    [self setupProgressInfoLabel];
    
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
    
    _status = NVHeadingStatusReady;
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
    
    _arrowView.frame = CGRectMake(0.0, 0.0, _arrowView.image.size.width,
                                  (_arrowView.image.size.height * 1.5));
    
    _arrowView.center = CGPointMake(384.0, 512.0);
    
    [self.view addSubview:_arrowView];
}

- (void)setupHeadingLabel
{
    _headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 408.0, 120.0)];
    
    _headingLabel.center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _returnButton.frame.size.height) +
                                               _returnButton.frame.origin.y) / 2.0));
    
    _headingLabel.backgroundColor = UIColor.clearColor;
    _headingLabel.textColor = UIColor.whiteColor;
    _headingLabel.textAlignment = NSTextAlignmentCenter;
    _headingLabel.font = [UIFont boldSystemFontOfSize:52.0];
    _headingLabel.adjustsFontSizeToFitWidth = YES;
    _headingLabel.numberOfLines = 2;
    
    [self.view addSubview:_headingLabel];
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
           fontSize:(CGFloat)fontSize
{
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button setTitleColor:UIColor.grayColor
                 forState:UIControlStateDisabled];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)setupProgressInfoLabel
{
    _progressInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, 40.0)];
    
    _progressInfoLabel.center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _arrowView.frame.size.height) +
                                                     _progressView.frame.origin.y) / 2.0));
    
    _progressInfoLabel.backgroundColor = UIColor.clearColor;
    _progressInfoLabel.textColor = UIColor.whiteColor;
    _progressInfoLabel.textAlignment = NSTextAlignmentCenter;
    _progressInfoLabel.font = [UIFont boldSystemFontOfSize:30.0];
    _progressInfoLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.view addSubview:_progressInfoLabel];
}

- (void)returnButtonTapped:(UIButton *)button
{
    if (_status == NVHeadingStatusComplete)
    {
        if (_delegate)
        {
            NSDecimal dIn = [NSNumber numberWithDouble:_avgHeading].decimalValue;
            NSDecimal dOut;
            NSDecimalRound(&dOut, &dIn, 0, NSRoundPlain);
            
            NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithDecimal:dOut];
            NSInteger resultInteger = result.integerValue;
            
            [_delegate headingViewController:self
                            didReturnHeading:resultInteger];
        }
    }
    
    else
    {
        if (_delegate)
            [_delegate headingViewControllerDidCancel:self];
    }
}

- (void)startCancelButtonTapped:(UIButton *)button
{
    switch (_status)
    {
        case NVHeadingStatusComplete:
            if (CLLocationManager.headingAvailable)
                [_locationManager startUpdatingHeading];
            
        case NVHeadingStatusReady:
            _progressInfoLabel.text = @"Checking Stability";
            _returnButton.enabled = NO;
            
            [_startCancelButton setTitle:@"Cancel"
                                forState:UIControlStateNormal];
            
            _status = NVHeadingStatusCheckingStability;
            break;
            
        case NVHeadingStatusCheckingStability:
        case NVHeadingStatusGettingHeading:
            _progressInfoLabel.text = @"";
            _returnButton.enabled = YES;
            
            [_startCancelButton setTitle:@"Start"
                                forState:UIControlStateNormal];
            
            _status = NVHeadingStatusReady;
            break;
            
        default:
            break;
    }
    
    _firstTime = YES;
    _progressView.hidden = YES;
    _progressView.progress = 0.0;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    _headingLabel.text = [NSString stringWithFormat:@"Current Heading:\n%.0f\u00B0",
                          newHeading.trueHeading];
    
    switch (_status)
    {
        case NVHeadingStatusCheckingStability:
            if (_firstTime)
            {
                _minHeading = _maxHeading = newHeading.trueHeading;
                _startTime = NSDate.date;
                _firstTime = NO;
            }
            
            else
            {
                _minHeading = min(_minHeading, newHeading.trueHeading);
                _maxHeading = max(_maxHeading, newHeading.trueHeading);
            }
            
            if ([NSDate.date timeIntervalSinceDate:_startTime] >= 1.0)
            {
                if (abs((_maxHeading - _minHeading) < _stabilityFactor))
                {
                    _status = NVHeadingStatusGettingHeading;
                    _progressView.hidden = NO;
                    _progressView.progress = 0.0;
                    _progressInfoLabel.text = @"Collecting Heading Measurement";
                    _minHeading = _maxHeading = _sumHeading = _avgHeading = 0.0;
                    _counter = 0;
                }
                
                _startTime = NSDate.date;
                _firstTime = YES;
            }
            
            break;
        
        case NVHeadingStatusGettingHeading:
            if (_firstTime)
            {
                _minHeading = _maxHeading = newHeading.trueHeading;
                _firstTime = NO;
            }
            
            else
            {
                _minHeading = min(_minHeading, newHeading.trueHeading);
                _maxHeading = max(_maxHeading, newHeading.trueHeading);
            }
            
            _progressView.progress = ([NSDate.date timeIntervalSinceDate:_startTime] / 1.0);
            _sumHeading += newHeading.trueHeading;
            _counter++;
            
            if ([NSDate.date timeIntervalSinceDate:_startTime] >= 1.0)
            {
                if (abs((_maxHeading - _minHeading) < _stabilityFactor))
                {
                    _status = NVHeadingStatusComplete;
                    _returnButton.enabled = YES;
                    _progressView.progress = 1.0;
                    _progressInfoLabel.text = @"Heading Measurement Complete";
                    _avgHeading = (_sumHeading / _counter);
                    
                    _headingLabel.text = [NSString stringWithFormat:@"Average Heading:\n%.0f\u00B0",
                                          _avgHeading];
                    
                    [_startCancelButton setTitle:@"Start"
                                        forState:UIControlStateNormal];
                    
                    [_locationManager stopUpdatingHeading];
                }
                
                else
                {
                    _progressInfoLabel.text = @"Checking Stability";
                    _progressView.hidden = YES;
                    _progressView.progress = 0.0;
                    _status = NVHeadingStatusCheckingStability;
                    _startTime = NSDate.date;
                }
                
                _firstTime = YES;
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