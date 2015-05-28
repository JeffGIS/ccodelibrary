//  NVTestSlopeController.m
//  CCodeLibrary

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "NVTestSlopeController.h"
#import "CRAPI.h"
#import "MathUtil.h"
#import "NVProgressView.h"

typedef NS_ENUM(NSInteger, SCStatus)
{
    SCStatusStart,
    SCStatusCancel,
};

typedef NS_ENUM(NSInteger, ManualMeasurementType)
{
    ManualMeasurementTypeDefault,
    ManualMeasurementTypeHeading,
    ManualMeasurementTypeSlope,
};

#define COUNT 60

@interface NVTestSlopeController ()

@property (nonatomic) UIButton *unableButton, *startCancelButton, *manualButton;
@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UILabel *frontSlopeLabel, *sideSlopeLabel, *maxSlopeLabel, *promptLabel;
@property (nonatomic) CGFloat steadyDiff;
@property (nonatomic) CGFloat xRange, yRange, zRange;
@property (nonatomic) CGFloat maxX, minX, maxY, minY, maxZ, minZ;
@property (nonatomic) CGFloat gSumX, gSumY, gSumZ, aSumX, aSumY, aSumZ, yawSum, pitchSum, rollSum;
@property (nonatomic) CGFloat rmSum11, rmSum12, rmSum13, rmSum21, rmSum22, rmSum23, rmSum31, rmSum32, rmSum33;
@property (nonatomic) CGFloat qSumX, qSumY, qSumZ, qSumW;
@property (nonatomic) NVSlopeTestData data;
@property (nonatomic) NSInteger counter;
@property (nonatomic) CGFloat sumTrueHeading, sumMagneticHeading;
@property (nonatomic) UILabel *headingLabel;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CMMotionManager *motionManager;
@property SCStatus status;
@property ManualMeasurementType manualType;

@end

@implementation NVTestSlopeController

+ (NVTestSlopeController *)slopeControllerWithDelegate:(id)delegate
{
    NVTestSlopeController *slopeController = [[NVTestSlopeController alloc] init];
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
    
    UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    
    self.view.backgroundColor = CRAPI.sharedInstance.defaultColors.backgroundColor;
    _steadyDiff = 0.015;
    _maxX = _maxY = _maxZ = -10.0;
    _minX = _minY = _minZ = 10.0;
    _status = SCStatusStart;
    
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
    
    if (_delegate)
    {
        _data.batteryLevel = UIDevice.currentDevice.batteryLevel;
        _data.orientation = UIDevice.currentDevice.orientation;
        
        [_delegate testSlopeViewController:self
                    didReturnSlopeTestData:_data];
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
    NVLargeAlertView *alert = [NVLargeAlertView showLargeAlertViewinView:self.view
                                                                delegate:self
                                                                   title:@"Which Manual Measurement Type?"
                                                           topButtonText:@"Heading"
                                                        bottomButtonText:@"Slope"
                                                        destructiveIndex:NVLargeAlertIndexNone];
#pragma unused(alert)
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
    
    _promptLabel.text = @"Slope measurement in progress.\nPlease keep iPad stable.";
}

- (void)stopMotionManager
{
    [_motionManager stopDeviceMotionUpdates];
    [_motionManager stopAccelerometerUpdates];
    [_locationManager stopUpdatingHeading];
}

- (void)computeSlopeFromDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    if (_counter == COUNT)
    {
        [self stopMotionManager];
        
        _data.gravX = (_gSumX / COUNT);
        _data.gravY = (_gSumY / COUNT);
        _data.gravZ = (_gSumZ / COUNT);
        
        _data.accelX = (_aSumX / COUNT);
        _data.accelY = (_aSumY / COUNT);
        _data.accelZ = (_aSumZ / COUNT);
        
        _data.yaw = (_yawSum / COUNT);
        _data.pitch = (_pitchSum / COUNT);
        _data.roll = (_rollSum / COUNT);
        
        _data.rm11 = (_rmSum11 / COUNT);
        _data.rm12 = (_rmSum12 / COUNT);
        _data.rm13 = (_rmSum13 / COUNT);
        _data.rm21 = (_rmSum21 / COUNT);
        _data.rm22 = (_rmSum22 / COUNT);
        _data.rm23 = (_rmSum23 / COUNT);
        _data.rm31 = (_rmSum31 / COUNT);
        _data.rm32 = (_rmSum32 / COUNT);
        _data.rm33 = (_rmSum33 / COUNT);
        
        _data.quatX = (_qSumX / COUNT);
        _data.quatY = (_qSumY / COUNT);
        _data.quatZ = (_qSumZ / COUNT);
        _data.quatW = (_qSumW / COUNT);
        
        _data.trueHeading = (_sumTrueHeading / COUNT);
        _data.magneticHeading = (_sumMagneticHeading / COUNT);
        
        _data.deviceSlope = (tan(-atan2(_data.accelY,
                                        sqrt(pow(_data.accelX, 2) +
                                             pow(_data.accelZ, 2)))) * 100.0);
        
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
            [self resetSumsAndCounter];
        
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
        
        _rmSum11 += deviceMotion.attitude.rotationMatrix.m11;
        _rmSum12 += deviceMotion.attitude.rotationMatrix.m12;
        _rmSum13 += deviceMotion.attitude.rotationMatrix.m13;
        _rmSum21 += deviceMotion.attitude.rotationMatrix.m21;
        _rmSum22 += deviceMotion.attitude.rotationMatrix.m22;
        _rmSum23 += deviceMotion.attitude.rotationMatrix.m23;
        _rmSum31 += deviceMotion.attitude.rotationMatrix.m31;
        _rmSum32 += deviceMotion.attitude.rotationMatrix.m32;
        _rmSum33 += deviceMotion.attitude.rotationMatrix.m33;
        
        _qSumX += deviceMotion.attitude.quaternion.x;
        _qSumY += deviceMotion.attitude.quaternion.y;
        _qSumZ += deviceMotion.attitude.quaternion.z;
        _qSumW += deviceMotion.attitude.quaternion.w;
        
        _sumTrueHeading += _locationManager.heading.trueHeading;
        _sumMagneticHeading += _locationManager.heading.magneticHeading;
        
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
    _rmSum11 = _rmSum12 = _rmSum13 = 0.0;
    _rmSum21 = _rmSum22 = _rmSum23 = 0.0;
    _rmSum31 = _rmSum32 = _rmSum33 = 0.0;
    _qSumX = _qSumY = _qSumZ = _qSumW = 0.0;
    _sumTrueHeading = _sumMagneticHeading =  0.0;
    _counter = 0;
}

- (void)slopeMeasurementComplete
{
    _headingLabel.text = [NSString stringWithFormat:@"Device Heading = %.02f\u00B0", _data.trueHeading];
    _frontSlopeLabel.text = [NSString stringWithFormat:@"Manual Heading = %.02f\u00B0", _data.manualHeading];
    _sideSlopeLabel.text = [NSString stringWithFormat:@"Device Slope = %+.02f%%", _data.deviceSlope];
    _maxSlopeLabel.text = [NSString stringWithFormat:@"Manual Slope = %+.02f%%", _data.manualSlope];
    
    _promptLabel.text = @"Press 'Done' to continue inventory.";
    
    [_unableButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    
    _startCancelButton.hidden = YES;
    _unableButton.enabled = YES;
    [self updateButtonAppearance:_unableButton];
    
    _progressView.hidden = YES;
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
    switch (_manualType)
    {
        case ManualMeasurementTypeHeading:
            _data.manualHeading = value;
            _frontSlopeLabel.text = [NSString stringWithFormat:@"Manual Heading = %.02f\u00B0", _data.manualHeading];
            break;
            
        case ManualMeasurementTypeSlope:
            _data.manualSlope = value;
            _maxSlopeLabel.text = [NSString stringWithFormat:@"Manual Slope = %+.02f%%", _data.manualSlope];
            break;
        
        default:
            break;
    }
    
    [sliderView hideSliderController:YES];
}

- (void)sliderViewDidCancel:(NVSliderController *)sliderView
{
    [sliderView hideSliderController:YES];
}

- (void)largeAlertView:(NVLargeAlertView *)largeAlertView
   didTapButtonAtIndex:(NVLargeAlertIndex)buttonIndex
{
    CGFloat value = 0.0, radius = 0.0;
    
    switch (buttonIndex)
    {
        case NVLargeAlertIndexTopButton:
            _manualType = ManualMeasurementTypeHeading;
            value = _data.trueHeading;
            radius = 30.0;
            break;
            
        case NVLargeAlertIndexBottomButton:
            _manualType = ManualMeasurementTypeSlope;
            value = _data.deviceSlope;
            radius = 4.0;
            break;
            
        default:
            break;
    }
    
    [largeAlertView hideLargeAlertView:NO];
    
    NVSliderController *slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                                      width:728.0
                                                                 startValue:value
                                                                   minValue:(value - radius)
                                                                   maxValue:(value + radius)
                                                                   delegate:self
                                                              configuration:NVSliderConfigurationManualSlope];
    
    [slider showSliderControllerInView:self.view
                              animated:YES
                               overlay:YES];
}

@end