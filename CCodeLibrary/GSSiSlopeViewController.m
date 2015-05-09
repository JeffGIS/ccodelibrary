//  SlopeViewController.m
//  CCodeLibrary

#import "GSSiSlopeViewController.h"
#import "CRAPI.h"
#import "MathUtil.h"
#import "NVProgressView.h"

#define SC_START 0
#define SC_CANCEL 1
#define COUNT 60

@interface GSSiSlopeViewController ()

@property (nonatomic) UIButton *unableButton, *startCancelButton;
@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UILabel *frontSlopeLabel, *sideSlopeLabel, *maxSlopeLabel, *promptLabel;
@property BOOL startCancelState, unable;
@property (nonatomic) CGFloat steadyDiff;
@property (nonatomic) CGFloat xRange, yRange, zRange;
@property (nonatomic) CGFloat maxX, minX, maxY, minY, maxZ, minZ;
@property (nonatomic) CGFloat gSumX, gSumY, gSumZ, aSumX, aSumY, aSumZ, yawSum, pitchSum, rollSum;
@property (nonatomic) CGFloat gx, gy, gz, ax, ay, az, yaw, pitch, roll;
@property (nonatomic) NSInteger counter, headingCounter;
@property (nonatomic) CGFloat sumHeading, avgHeading, frontSlope, sideSlope, maxSlope;
@property (nonatomic) UILabel *headingLabel;
@property (nonatomic) CGFloat target, forceFlip;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CMMotionManager *motionManager;

@end

@implementation GSSiSlopeViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = CRAPI.sharedInstance.defaultColors.backgroundColor;
    _steadyDiff = 0.015;
    _maxX = _maxY = _maxZ = -10.0;
    _minX = _minY = _minZ = 10.0;
    _gSumX = _gSumY = _gSumZ = 0.0;
    _aSumX = _aSumY = _aSumZ = 0.0;
    _yawSum = _pitchSum = _rollSum = 0.0;
    _frontSlope = _sideSlope = _maxSlope = 0.0;
    _sumHeading = _avgHeading = 0.0;
    _counter = _headingCounter = 0;
    _startCancelState = SC_START;
    _unable = YES;
    
    [self setupUnableButton];
    [self setupStartCancelButton];
    [self setupArrowView];
    [self setupLabels];
    [self setupProgressView];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationUnknown;
    
    _motionManager = [[CMMotionManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupUnableButton
{
    _unableButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 904.0, 400.0, 100.0)];
    
    [_unableButton addTarget:self
                      action:@selector(goBack:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_unableButton];
    
    [_unableButton setTitleColor:UserDefaults.defaults.appleBlue
                        forState:UIControlStateHighlighted];
    
    [self setupButton:_unableButton
                title:@"Unable"];
}

- (void)setupStartCancelButton
{
    _startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 564.0, 400.0, 100.0)];
    
    [_startCancelButton addTarget:self
                           action:@selector(startCancel:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_startCancelButton];
    
    [_startCancelButton setTitleColor:UserDefaults.defaults.appleBlue
                             forState:UIControlStateHighlighted];
    
    [self setupButton:_startCancelButton
                title:@"Start"];
}

- (void)setupLabels
{
    _headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 614.0, 568.0, 60.0)];
    _frontSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 684.0, 568.0, 60.0)];
    _sideSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 754.0, 568.0, 60.0)];
    _maxSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 824.0, 568.0, 60.0)];
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 340.0, 728.0, 194.0)];
    
    [self.view addSubview:_headingLabel];
    [self.view addSubview:_frontSlopeLabel];
    [self.view addSubview:_sideSlopeLabel];
    [self.view addSubview:_maxSlopeLabel];
    [self.view addSubview:_promptLabel];
    
    [self setupLabel:_headingLabel];
    [self setupLabel:_frontSlopeLabel];
    [self setupLabel:_sideSlopeLabel];
    [self setupLabel:_maxSlopeLabel];
    [self setupLabel:_promptLabel];
    
    _promptLabel.text = @"Place the iPad with the arrow pointing toward the downslope and tap 'Start' to begin measurement.";
}

- (void)setupArrowView
{
    _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(260.0, 20.0, 248.0, 320.0)];
    
    _arrowView.image = [UIImage imageWithContentsOfFile:
                        [NSBundle.mainBundle pathForResource:@"coolArrow"
                                                      ofType:@"png"]];
    
    [self.view addSubview:_arrowView];
}

- (void)setupProgressView
{
    _progressView = [[NVProgressView alloc] initWithCenter:CGPointMake(384.0, 786.0)
                                                     width:688.0
                                                trackColor:UIColor.blackColor
                                             progressColor:UIColor.whiteColor];
    
    _progressView.progress = 0.0;
    [self.view addSubview:_progressView];
    _progressView.hidden = YES;
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:CRAPI.sharedInstance.defaultColors.titleColor
                 forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:84.0];
    button.layer.cornerRadius = 10.0;
    
    [self updateButtonAppearance:button];
}

- (void)updateButtonAppearance:(UIButton *)button
{
    if (button.enabled)
        button.backgroundColor = CRAPI.sharedInstance.defaultColors.enabledColor;
    
    else
        button.backgroundColor = CRAPI.sharedInstance.defaultColors.disabledColor;
}

- (void)setupLabel:(UILabel *)label
{
    if (CRAPI.sharedInstance.currentModule == DETAIL_MODULE)
    {
        if ([UserDefaults.defaults pickAdjustedTextColorForColor1:CRAPI.sharedInstance.defaultColors.backgroundColor
                                                           color2:CRAPI.sharedInstance.defaultColors.disabledColor])
        {
            label.textColor = [UserDefaults.defaults lightColorForColor:CRAPI.sharedInstance.defaultColors.disabledColor];
        }
        
        else
            label.textColor = [UserDefaults.defaults darkColorForColor:CRAPI.sharedInstance.defaultColors.disabledColor];
    }
    
    else
        label.textColor = CRAPI.sharedInstance.defaultColors.textColor;
    
    label.font = [UIFont boldSystemFontOfSize:44.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.adjustsFontSizeToFitWidth = YES;
}

- (void)goBack:(UIButton *)button
{
    [_motionManager stopDeviceMotionUpdates];
    [_motionManager stopAccelerometerUpdates];
    
    CGFloat slopes[2], heading;
    
    slopes[0] = _frontSlope;
    slopes[1] = _sideSlope;
    heading = _avgHeading;
    
    if (_unable)
        slopes[0] = slopes[1] = heading = -9999.0;
    
    if (_delegate)
    {
        [_delegate gssiSlopeViewController:self
                           didReturnAccelX:_ax
                                    accelY:_ay
                                    accelZ:_az
                                     gravX:_gx
                                     gravY:_gy
                                     gravZ:_gz
                                       yaw:_yaw
                                     pitch:_pitch
                                      roll:_roll
                                    slopes:slopes
                                   heading:heading];
    }
}

- (void)startCancel:(UIButton *)button
{
    if (_startCancelState == SC_START)
    {
        [self startMotionManager];
        _startCancelState = SC_CANCEL;
        _unableButton.enabled = NO;
        _progressView.hidden = NO;
        
        [_startCancelButton setTitle:@"Cancel"
                            forState:UIControlStateNormal];
    }
    
    else if (_startCancelState == SC_CANCEL)
    {
        [_motionManager stopDeviceMotionUpdates];
        _startCancelState = SC_START;
        _unableButton.enabled = YES;
        _progressView.hidden = YES;
        
        [_startCancelButton setTitle:@"Start"
                            forState:UIControlStateNormal];
    }
    
    [self updateButtonAppearance:_unableButton];
}

- (void)startMotionManager
{
    _motionManager.deviceMotionUpdateInterval = 0.05;
    _motionManager.accelerometerUpdateInterval = 0.05;
    
    if (CLLocationManager.headingAvailable)
        [_locationManager startUpdatingHeading];
    
    if ([_motionManager isAccelerometerAvailable])
        [_motionManager startAccelerometerUpdates];
    
    if ([_motionManager isDeviceMotionAvailable])
    {
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                            toQueue:NSOperationQueue.currentQueue
                                                        withHandler:^(CMDeviceMotion *deviceMotion, NSError *error){
                                                            [self computeSlopeFromDeviceMotion:deviceMotion];
                                                            
                                                            if(error)
                                                                NSLog(@"DeviceMotionError:%@", error.localizedDescription);
                                                        }];
    }
}

- (void)computeSlopeFromDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    _promptLabel.text = @"Slope measurement in progress.\nPlease keep iPad stable.";
    
    if (_counter == COUNT)
    {
        [_motionManager stopDeviceMotionUpdates];
        [_motionManager stopAccelerometerUpdates];
        [_locationManager stopUpdatingHeading];
        
        _gx = (_gSumX / COUNT);
        _gy = (_gSumY / COUNT);
        _gz = (_gSumZ / COUNT);
        
        _ax = (_aSumX / COUNT);
        _ay = (_aSumY / COUNT);
        _az = (_aSumZ / COUNT);
        
        _yaw = (_yawSum / COUNT);
        _pitch = (_pitchSum / COUNT);
        _roll = (_rollSum / COUNT);
        
        _frontSlope = (100.0 * sin(-atan2(_ay, sqrt(pow(_ax, 2) + pow(_az, 2)))));
        _sideSlope = (100.0 * sin(atan2(_ax, sqrt(pow(_ay, 2) + pow(_az, 2)))));
        _maxSlope = ComputeMaxSlope(_frontSlope, _sideSlope);
        _avgHeading = (_sumHeading / _headingCounter);
        
        [self slopeMeasurementComplete];
    }
    
    else if (_counter < COUNT)
    {
        CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;
        
        _maxX = max(_maxX, acceleration.x);
        _minX = min(_minX, acceleration.x);
        _maxY = max(_maxY, acceleration.y);
        _minY = min(_minY, acceleration.y);
        _maxZ = max(_maxZ, acceleration.z);
        _minZ = min(_minZ, acceleration.z);
        _xRange = (_maxX - _minX);
        _yRange = (_maxY - _minY);
        _zRange = (_maxZ - _minZ);
        
        if (_yRange > _steadyDiff || _xRange > _steadyDiff || _zRange > _steadyDiff)
        {
            _maxX = _maxY = _maxZ = -10.0;
            _minX = _minY = _minZ = 10.0;
            _gSumX = _gSumY = _gSumZ = 0.0;
            _aSumX = _aSumY = _aSumZ = 0.0;
            _yawSum = _pitchSum = _rollSum = 0.0;
            _counter = 0;
        }
        
        _counter++;
        
        _aSumX += _motionManager.accelerometerData.acceleration.x;
        _aSumY += _motionManager.accelerometerData.acceleration.y;
        _aSumZ += _motionManager.accelerometerData.acceleration.z;
        
        _gSumX += deviceMotion.gravity.x;
        _gSumY += deviceMotion.gravity.y;
        _gSumZ += deviceMotion.gravity.z;
        
        _yawSum += deviceMotion.attitude.yaw;
        _pitchSum += deviceMotion.attitude.pitch;
        _rollSum += deviceMotion.attitude.roll;
        
        _progressView.progress = (_counter / (CGFloat)COUNT);
    }
}

- (void)slopeMeasurementComplete
{
    _headingLabel.text = [NSString stringWithFormat:@"Heading = %.02f\u00B0", _avgHeading];
    _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.02f%%", _frontSlope];
    _sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.02f%%", _sideSlope];
    _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.02f%%", _maxSlope];
    
    _promptLabel.text = @"Press 'Done' to continue inventory.";
    
    [_unableButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    
    _unable = NO;
    
    _startCancelButton.hidden = YES;
    _unableButton.enabled = YES;
    [self updateButtonAppearance:_unableButton];
    
    _progressView.hidden = YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    _sumHeading += newHeading.trueHeading;
    _headingCounter++;
}

@end