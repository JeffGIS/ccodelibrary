//  SlopeViewController.m
//  CCodeLibrary

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "GSSiSlopeViewController.h"
#import "CRAPI.h"
#import "MathUtil.h"
#import "NVProgressView.h"

typedef NS_ENUM(NSInteger, SCStatus)
{
    SCStatusStart,
    SCStatusCancel,
};

#define COUNT 60

@interface GSSiSlopeViewController ()

@property (nonatomic) UIButton *unableButton, *startCancelButton, *manualButton;
@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UILabel *frontSlopeLabel, *sideSlopeLabel, *maxSlopeLabel, *promptLabel;
@property (nonatomic) CGFloat calibrationTarget, flipRadius, steadyDiff;
@property (nonatomic) CGFloat xRange, yRange, zRange;
@property (nonatomic) CGFloat maxX, minX, maxY, minY, maxZ, minZ;
@property (nonatomic) CGFloat gSumX, gSumY, gSumZ, aSumX, aSumY, aSumZ, yawSum, pitchSum, rollSum;
@property (nonatomic) NVSlopeData data;
@property (nonatomic) NSInteger counter;
@property (nonatomic) CGFloat sumHeading;
@property (nonatomic) UILabel *headingLabel;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CMMotionManager *motionManager;
@property SCStatus status;
@property BOOL unable, hasRun;

@end

@implementation GSSiSlopeViewController

+ (GSSiSlopeViewController *)slopeControllerWithCalibrationTarget:(CGFloat)calibrationTarget
                                                       flipRadius:(CGFloat)flipRadius
                                                         delegate:(id)delegate
{
    GSSiSlopeViewController *slopeController = [[GSSiSlopeViewController alloc] init];
    slopeController.calibrationTarget = calibrationTarget;
    slopeController.flipRadius = flipRadius;
    slopeController.delegate = delegate;
    
    return slopeController;
}

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
    _status = SCStatusStart;
    _unable = YES;
    
    [self setupUnableButton];
    [self setupStartCancelButton];
    [self setupArrowView];
    [self setupLabels];
    [self setupProgressView];
    [self setupManualButton];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationFaceDown;
    
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
    
    [self setupButton:_unableButton
                title:@"Unable"];
}

- (void)setupStartCancelButton
{
    _startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 564.0, 400.0, 100.0)];
    
    [_startCancelButton addTarget:self
                           action:@selector(startCancel:)
                 forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)setupManualButton
{
    _manualButton = [[UIButton alloc] initWithFrame:CGRectMake(104.0, (((_promptLabel.center.y * 2.0) + _headingLabel.center.y) / 3.0),
                                                               560.0, 80.0)];
    
    [_manualButton addTarget:self
                      action:@selector(manual:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _manualButton.hidden = YES;
    
    [self setupButton:_manualButton
                title:@"Manual Measurement"];
    
    _manualButton.titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    _manualButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:CRAPI.sharedInstance.defaultColors.titleColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateHighlighted];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:84.0];
    button.layer.cornerRadius = 10.0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self updateButtonAppearance:button];
    [self.view addSubview:button];
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
    
    [self.view addSubview:label];
}

- (void)goBack:(UIButton *)button
{
    [self stopMotionManager];
    
    if (_unable)
        _data.frontSlopePct = _data.sideSlopePct = _data.frontSlopeDegrees = _data.sideSlopeDegrees = _data.heading = -9999.0;
    
    if (_delegate)
    {
        [_delegate gssiSlopeViewController:self
                        didReturnSlopeData:_data];
    }
}

- (void)startCancel:(UIButton *)button
{
    if (_status == SCStatusStart)
    {
        [self startMotionManager];
        
        _status = SCStatusCancel;
        _unableButton.enabled = NO;
        _progressView.hidden = NO;
        
        [_startCancelButton setTitle:@"Cancel"
                            forState:UIControlStateNormal];
    }
    
    else if (_status == SCStatusCancel)
    {
        [self stopMotionManager];
        
        _status = SCStatusStart;
        _unableButton.enabled = YES;
        _progressView.hidden = YES;
        
        [_startCancelButton setTitle:@"Start"
                            forState:UIControlStateNormal];
    }
    
    [self updateButtonAppearance:_unableButton];
}

- (void)manual:(UIButton *)button
{
    NVSliderController *slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                                      width:728.0
                                                                 startValue:_data.frontSlopePct
                                                                   minValue:(_data.frontSlopePct - 2.0)
                                                                   maxValue:(_data.frontSlopePct + 2.0)
                                                                   delegate:self
                                                              configuration:NVSliderConfigurationManualSlope];
    
    [slider showSliderControllerInView:self.view
                              animated:YES
                               overlay:YES];
}

- (void)startMotionManager
{
    _motionManager.deviceMotionUpdateInterval = 0.05;
    _motionManager.accelerometerUpdateInterval = 0.05;
    
    if (CLLocationManager.headingAvailable && !_hasRun)
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
    
    _promptLabel.text = @"Slope measurement in progress.\nPlease keep iPad stable.";
}

- (void)stopMotionManager
{
    [_motionManager stopDeviceMotionUpdates];
    [_motionManager stopAccelerometerUpdates];
    [_locationManager stopUpdatingHeading];
}

double square (double x)
{
    return x*x;
}

- (void) slopesFromAccelerometer:(int)nReadings
{
/*double xyz[3];
double ax, ay, az;
xyz[0] = _data.accelX[0];
xyz[1] = _data.accelY[0];
xyz[2] = _data.accelZ[0];
ax = xyz[0];
ay = xyz[1];
az = xyz[2];
double xAngle = atan( ax / (sqrt(square(ay) + square(az))));
double yAngle = atan( ay / (sqrt(square(ax) + square(az))));
double zAngle = atan( sqrt(square(ax) + square(ay)) / az);

xAngle *= 180.00;   yAngle *= 180.00;   zAngle *= 180.00;
xAngle /= 3.141592; yAngle /= 3.141592; zAngle /= 3.141592;*/
    double denom = sqrt (square(_data.accelX[0])+square(_data.accelY[0])+square(_data.accelZ[0]));
    double angz = acos (_data.accelZ[0]/denom);
    double angy = acos (_data.accelY[0]/denom);
    double angx = acos (_data.accelX[0]/denom);
    angx *= RADtoDEG;
    angy *= RADtoDEG;
    angz *= RADtoDEG;
    angx = 90.0 - angx;
    angy = 180.0 - angy;
    angz = 180.0 - angz;
    _data.frontSlopeDegrees = angz;
    _data.sideSlopeDegrees = angx;
    _data.frontSlopePct = tan(_data.frontSlopeDegrees * DEGtoRAD) * 100;
    _data.sideSlopePct = tan(_data.sideSlopeDegrees * DEGtoRAD) * 100;
    _data.maxSlopePct = ComputeMaxSlope(_data.frontSlopePct, _data.sideSlopePct);
}
- (void)computeSlopeFromDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    if (_counter == COUNT)
    {
        [self stopMotionManager];
        
        if (_hasRun)
        {
            _data.gravX[1] = (_gSumX / COUNT);
            _data.gravY[1] = (_gSumY / COUNT);
            _data.gravZ[1] = (_gSumZ / COUNT);
            
            _data.accelX[1] = (_aSumX / COUNT);
            _data.accelY[1] = (_aSumY / COUNT);
            _data.accelZ[1] = (_aSumZ / COUNT);
            
            _data.yaw[1] = (_yawSum / COUNT);
            _data.pitch[1] = (_pitchSum / COUNT);
            _data.roll[1] = (_rollSum / COUNT);
            
            [self slopesFromAccelerometer:2];
            
            [self slopeMeasurementComplete];
        }
        
        else
        {
            _data.gravX[0] = (_gSumX / COUNT);
            _data.gravY[0] = (_gSumY / COUNT);
            _data.gravZ[0] = (_gSumZ / COUNT);
            
            _data.accelX[0] = (_aSumX / COUNT);
            _data.accelY[0] = (_aSumY / COUNT);
            _data.accelZ[0] = (_aSumZ / COUNT);
            
            _data.yaw[0] = (_yawSum / COUNT) * RADtoDEG;
            _data.pitch[0] = (_pitchSum / COUNT) * RADtoDEG;
            _data.roll[0] = (_rollSum / COUNT) * RADtoDEG;
            
            _data.heading = (_sumHeading / COUNT);
            [self slopesFromAccelerometer:1];
            if (_data.maxSlopePct < (_calibrationTarget - _flipRadius) ||
                (_data.maxSlopePct > (_calibrationTarget + _flipRadius)))
            {
                [self slopeMeasurementComplete];
            }
            
            else
            {
                _hasRun = YES;
                _promptLabel.text = @"Flip the iPad in the opposite direction and tap 'Continue' to calibrate measurement.";
                
                [_startCancelButton setTitle:@"Continue"
                                    forState:UIControlStateNormal];
                
                [self resetSumsAndCounter];
                _status = SCStatusStart;
            }
        }
        _counter++;
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
            [self resetSumsAndCounter];
        
        _counter++;
        
        _aSumX += acceleration.x;
        _aSumY += acceleration.y;
        _aSumZ += acceleration.z;
        
        _gSumX += deviceMotion.gravity.x;
        _gSumY += deviceMotion.gravity.y;
        _gSumZ += deviceMotion.gravity.z;
        double uacx = deviceMotion.userAcceleration.x;
        double uacy = deviceMotion.userAcceleration.y;
        double uacz = deviceMotion.userAcceleration.z;
        _yawSum += deviceMotion.attitude.yaw;
        _pitchSum += deviceMotion.attitude.pitch;
        _rollSum += deviceMotion.attitude.roll;
        
        _sumHeading += _locationManager.heading.trueHeading;
        
        _progressView.progress = (_counter / (CGFloat)COUNT);
    }
}

- (void)resetSumsAndCounter
{
    _maxX = _maxY = _maxZ = -10.0;
    _minX = _minY = _minZ = 10.0;
    _gSumX = _gSumY = _gSumZ = 0.0;
    _aSumX = _aSumY = _aSumZ = 0.0;
    _yawSum = _pitchSum = _rollSum = 0.0;
    _sumHeading = 0.0;
    _counter = 0;
}

- (void)slopeMeasurementComplete
{
    _headingLabel.text = [NSString stringWithFormat:@"Heading = %.02f\u00B0", _data.heading];
    _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.02f%%", _data.frontSlopeDegrees];
    _sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.02f%%", _data.sideSlopeDegrees];
    _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.02f%%", _data.maxSlopePct];
    _maxSlopeLabel.text = [NSString stringWithFormat:@"%.5f %.5f %.5f", _data.accelX[0],_data.accelY[0],_data.accelZ[0]];
    
    _promptLabel.text = @"Press 'Done' to continue inventory.";
    
    [_unableButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    
    _unable = NO;
    
    _startCancelButton.hidden = YES;
    _unableButton.enabled = YES;
    [self updateButtonAppearance:_unableButton];
    
    _progressView.hidden = YES;
    _hasRun = NO;
    
    _manualButton.hidden = NO;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    BOOL rtn = NO;
    
    if (_delegate)
        rtn = [_delegate shouldUseCalibration:self];
    
    return rtn;
}

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(CGFloat)value
{
    _data.frontSlopePct = value;
    _data.maxSlopePct = ComputeMaxSlope(_data.frontSlopePct, _data.sideSlopePct);
    
    _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.02f%%", _data.frontSlopePct];
    _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.02f%%", _data.maxSlopePct];
    
    [sliderView hideSliderController:YES];
}

- (void)sliderViewDidCancel:(NVSliderController *)sliderView
{
    [sliderView hideSliderController:YES];
}

@end