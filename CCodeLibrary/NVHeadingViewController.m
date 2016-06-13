//  NVHeadingViewController.m
//  CCodeLibrary

#import "NVHeadingViewController.h"
#import "UserDefaults.h"
#import "NVProgressView.h"
#import "Colors.h"

typedef NS_ENUM(NSInteger, NVHeadingStatus)
{
    NVHeadingStatusDefault,
    NVHeadingStatusReady,
    NVHeadingStatusGettingHeading,
    NVHeadingStatusComplete,
};

@interface NVHeadingViewController ()

@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) UILabel *headingLabel, *progressInfoLabel;
@property (nonatomic) UIButton *returnButton, *startCancelButton;
@property (nonatomic) NVProgressView *progressView;
@property NVHeadingStatus status;
@property (nonatomic) NSDate *startTime;
@property CGFloat referenceHeading, minHeading, maxHeading, sumHeading, avgHeading;
@property NSInteger counter, numDesiredReadings;
@property (nonatomic) CGFloat stabilityFactor;
@property (nonatomic) Colors *colors;

@end

@implementation NVHeadingViewController

+ (NVHeadingViewController *)showHeadingViewControllerWithDelegate:(id)delegate
                                                   stabilityFactor:(CGFloat)stabilityFactor
                                                       numReadings:(NSInteger)nRead
{
    NVHeadingViewController *headingVC = [[NVHeadingViewController alloc] init];
    headingVC.delegate = delegate;
    headingVC.stabilityFactor = stabilityFactor;
    headingVC.numDesiredReadings = nRead;
    
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
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _colors = UserDefaults.defaults.defaultColors;
    self.view.backgroundColor = _colors.backgroundColor;
    _promptText = @"Tap on 'Start' when ready to begin measurement";
    _autoReturn = NO;
    _counter = 0;
    
    [self setupArrowView];
    [self setupHeadingLabel];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.frame = CGRectMake(20.0, 20.0, 160.0, 60.0);
    
    [self setupButton:_returnButton
               target:self
             selector:@selector(returnButtonTapped:)
                title:@"< Return"
             fontSize:32.0];
    
    _startCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startCancelButton.frame = CGRectMake(220.0, 904.0, 328.0, 80.0);
    
    [self setupButton:_startCancelButton
               target:self
             selector:@selector(startCancelButtonTapped:)
                title:@"Start"
             fontSize:44.0];
    
    CGPoint center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _arrowView.frame.size.height) +
                                          _startCancelButton.frame.origin.y) / 2.0));
    
    _progressView = [[NVProgressView alloc] initWithCenter:center
                                                     width:688.0
                                                trackColor:UIColor.blackColor
                                             progressColor:UIColor.whiteColor];
    
    _progressView.progress = 0.0;
    [self.view addSubview:_progressView];
    [self setupProgressInfoLabel];
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationFaceUp;
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    else if (status == kCLAuthorizationStatusAuthorizedAlways ||
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
    _progressInfoLabel.text = _promptText;
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
                                  (_arrowView.image.size.height * 1.3));
    
    _arrowView.center = CGPointMake(384.0, 460.0);
    
    [self.view addSubview:_arrowView];
}

- (void)setupHeadingLabel
{
    _headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 408.0, 120.0)];
    
    _headingLabel.center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _returnButton.frame.size.height) +
                                               _returnButton.frame.origin.y) / 2.0));
    
    _headingLabel.backgroundColor = UIColor.clearColor;
    _headingLabel.textColor = _colors.textColor;
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
    button.backgroundColor = _colors.enabledColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:_colors.titleColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:_colors.highlightedColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)updateButtonAppearance:(UIButton *)button
{
    if (button.enabled)
        button.backgroundColor = _colors.enabledColor;
    
    else
        button.backgroundColor = _colors.disabledColor;
}

- (void)setupProgressInfoLabel
{
    _progressInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, 80.0)];
    
    _progressInfoLabel.center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _arrowView.frame.size.height) +
                                                     _progressView.frame.origin.y) / 2.0));
    
    _progressInfoLabel.backgroundColor = UIColor.clearColor;
    _progressInfoLabel.textColor = _colors.textColor;
    _progressInfoLabel.textAlignment = NSTextAlignmentCenter;
    _progressInfoLabel.font = [UIFont boldSystemFontOfSize:30.0];
    _progressInfoLabel.adjustsFontSizeToFitWidth = YES;
    _progressInfoLabel.numberOfLines = 2;
    
    [self.view addSubview:_progressInfoLabel];
}

- (void)returnButtonTapped:(UIButton *)button
{
    if (_status == NVHeadingStatusComplete)
    {
        if (_delegate)
        {
           [_delegate headingViewController:self
                            didReturnHeading:_avgHeading];
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
            _progressInfoLabel.text = @"Taking Measurement";
            _returnButton.enabled = NO;
            [self updateButtonAppearance:_returnButton];
            
            [_startCancelButton setTitle:@"Cancel"
                                forState:UIControlStateNormal];
            
            _status = NVHeadingStatusGettingHeading;
            _counter = 0;
            break;
            
        case NVHeadingStatusGettingHeading:
            _progressInfoLabel.text = @"";
            _returnButton.enabled = YES;
            [self updateButtonAppearance:_returnButton];
            
            [_startCancelButton setTitle:@"Start"
                                forState:UIControlStateNormal];
            
            _status = NVHeadingStatusReady;
            break;
            
        default:
            break;
    }
    
    _progressView.hidden = NO;
    _progressView.progress = 0.0;
}

- (CGFloat)correctedHeading:(CGFloat)heading
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
    _headingLabel.text = [NSString stringWithFormat:@"Current Heading:\n%.0f\u00B0",
                          newHeading.trueHeading];
    
    switch (_status)
    {
        case NVHeadingStatusGettingHeading:
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
            _progressView.progress = ((CGFloat)_counter / _numDesiredReadings);
            
            if (abs((_maxHeading - _minHeading) < _stabilityFactor))
            {
                if (_counter >= _numDesiredReadings)
                {
                    _status = NVHeadingStatusComplete;
                    _returnButton.enabled = YES;
                    [self updateButtonAppearance:_returnButton];
                    _progressView.progress = 1.0;
                    _progressInfoLabel.text = @"Heading Measurement Complete";
                    _avgHeading = (_sumHeading / _counter);
                    
                    if (_avgHeading > 360.0)
                        _avgHeading -= 360.0;
                    
                    else if (_avgHeading < 0)
                        _avgHeading += 360.0;
                    
                    _headingLabel.text = [NSString stringWithFormat:@"Average Heading:\n%.1f\u00B0",
                                          _avgHeading];
                    
                    [_startCancelButton setTitle:@"Start"
                                        forState:UIControlStateNormal];
                    
                    [_locationManager stopUpdatingHeading];
                    
                    if (_autoReturn && _delegate)
                    {
                        [_delegate headingViewController:self
                                        didReturnHeading:_avgHeading];
                    }
                }
            }
            
            else
            {
                _counter = 0;
                _progressView.progress = 0.0;
            }
        }
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
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

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end