//  SlopeViewController.m
//  CCodeLibrary

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "GSSiSlopeViewController.h"
#import "CRAPI.h"
#import "MathUtil.h"
#import "NVProgressView.h"
#import "SharedDefaults.h"

static CGFloat _deviceVals[5][4];
static CGFloat _targetValues[5];
static NSInteger _nCalibrationPoints;

typedef NS_ENUM(NSInteger, SCStatus)
{
    SCStatusStart,
    SCStatusCancel,
};

static int COUNT=100;

@interface GSSiSlopeViewController ()

@property (nonatomic) UIButton *unableButton, *startCancelButton, *manualButton;
@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UILabel *frontSlopeLabel, *sideSlopeLabel, *maxSlopeLabel, *promptLabel;
@property (nonatomic) CGFloat steadyDiff;
@property (nonatomic) CGFloat xRange, yRange, zRange;
@property (nonatomic) CGFloat maxX, minX, maxY, minY, maxZ, minZ;
@property (nonatomic) CGFloat aSumX, aSumY, aSumZ;
@property (nonatomic) NVSlopeData data;
@property NSInteger counter, headingCounter;
@property (nonatomic) CGFloat minHead, maxHead;
@property (nonatomic) CGFloat lastDegrees;
@property (nonatomic) CGFloat sumHeading, baseHeading;
@property (nonatomic) UILabel *headingLabel, *calDateLabel;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CMMotionManager *motionManager;
@property SCStatus status;
@property BOOL unable, hasRun;

@end

@implementation GSSiSlopeViewController

+ (GSSiSlopeViewController *)slopeControllerWithCriticalValue:(CGFloat)criticalVal
                                            criticalSideValue:(CGFloat)criticalSideVal
                                                   errorValue:(CGFloat)errVal
                                               useCalibration:(BOOL)useCalibration
                                                 steadyFactor:(CGFloat)steadyFac
                                                  countFactor:(CGFloat)countFac
                                               displayDegrees:(BOOL)displayDegrees
                                                     delegate:(id)delegate;
{
    GSSiSlopeViewController *slopeController = [[GSSiSlopeViewController alloc] init];
    slopeController.displayDegrees = displayDegrees;
    slopeController.useCalibration = useCalibration;
    slopeController.useHeadingCalibration = NO;
    slopeController.delegate = delegate;
    slopeController.steadyFactor = max (steadyFac,1.0);
    
    if (countFac)
        slopeController.countFactor = countFac;
    else
        slopeController.countFactor = 1.0;
    
    slopeController.criticalValue = criticalVal;
    slopeController.criticalSideValue = criticalSideVal;
    slopeController.errorValue = errVal;
    slopeController.promptText = @"Place the iPad with the arrow pointing toward the downslope and tap 'Start' to begin measurement.";
    
    NVSlopeData data;
    memset(&data, 0, sizeof(data));
    slopeController.data = data;
    
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
    
    _calDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 964.0, 728.0, 60.0)];
    _calDateLabel.backgroundColor = UIColor.clearColor;
    _calDateLabel.font = [UIFont boldSystemFontOfSize:28.0];
    _calDateLabel.adjustsFontSizeToFitWidth = YES;
    _calDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_calDateLabel];
    
    NSDate *date = NSDate.date;
    NSDate *lastCalDate = [SharedDefaults.defaults dateForKey:@"LastCalDate"];
    
    if (lastCalDate)
    {
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setDateFormat:@"dd"];
        NSString *currentDay = [dayFormatter stringFromDate:date];
        NSString *lastCalDay = [dayFormatter stringFromDate:lastCalDate];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm a"];
        [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        NSString *lastCalTime = [timeFormatter stringFromDate:lastCalDate];
        
        NSTimeInterval timeSinceCal = [date timeIntervalSinceDate:lastCalDate];
        timeSinceCal = floor(timeSinceCal / 86400);
        
        if (timeSinceCal > 5.0)
        {
            _calDateLabel.text = @"WARNING: Slope not calibrated.";
            _calDateLabel.textColor = UIColor.redColor;
        }
        
        else if (timeSinceCal > 1.0 || ![currentDay isEqualToString:lastCalDay])
        {
            timeSinceCal = max(timeSinceCal, 1.0);
            
            _calDateLabel.text = [NSString stringWithFormat:@"WARNING: Calibrated %.0f days ago.", timeSinceCal];
            _calDateLabel.textColor = UIColor.redColor;
        }
        
        else
        {
            _calDateLabel.text = [NSString stringWithFormat:@"Calibrated today at %@", lastCalTime];
            _calDateLabel.textColor = UIColor.blackColor;
        }
    }
    
    else
    {
        _calDateLabel.text = @"WARNING: This device has NOT been calibrated.";
        _calDateLabel.textColor = UIColor.redColor;
        _useCalibration = NO;
    }
    
    if (_useCalibration)
        [self loadCalibration];
    
    self.view.backgroundColor = CRAPI.sharedInstance.defaultColors.backgroundColor;
    _steadyDiff = 0.02 * _steadyFactor;
    COUNT = 100 * _countFactor;
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
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.frame = CGRectMake(676.0, 20.0, 72.0, 72.0);
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"question-256x256"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"questionMarkHighlighted"
                                                                                        ofType:@"png"]]
                forState:UIControlStateHighlighted];
    
    [helpButton addTarget:self
                   action:@selector(helpButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:helpButton];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationFaceUp;
    _locationManager.delegate = self;
    
    _motionManager = [[CMMotionManager alloc] init];
    [self resetSumsAndCounter];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupUnableButton
{
    _unableButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 884.0, 400.0, 80.0)];
    
    [_unableButton addTarget:self
                      action:@selector(goBack:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self setupButton:_unableButton
                title:@"Unable"];
}

- (void)setupStartCancelButton
{
    _startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 564.0, 400.0, 80.0)];
    
    [_startCancelButton addTarget:self
                           action:@selector(startCancel:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self setupButton:_startCancelButton
                title:@"Start"];
}

- (void)setupLabels
{
    _headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 594.0, 568.0, 60.0)];
    _frontSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 664.0, 568.0, 60.0)];
    _sideSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 734.0, 568.0, 60.0)];
    _maxSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 804.0, 568.0, 60.0)];
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 728.0, 194.0)];
    
    _promptLabel.center = CGPointMake(384.0, (((_arrowView.frame.origin.y + _arrowView.frame.size.height) +
                                               _startCancelButton.frame.origin.y) / 2.0));
    
    [self setupLabel:_headingLabel];
    [self setupLabel:_frontSlopeLabel];
    [self setupLabel:_sideSlopeLabel];
    [self setupLabel:_maxSlopeLabel];
    [self setupLabel:_promptLabel];
    _promptLabel.text = _promptText;
    
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
    CGPoint pvCenter = CGPointMake(384.0, ((_startCancelButton.center.y + _unableButton.center.y) / 2.0));
    
    _progressView = [[NVProgressView alloc] initWithCenter:pvCenter
                                                     width:688.0
                                                trackColor:UIColor.blackColor
                                             progressColor:UIColor.whiteColor];
    
    _progressView.progress = 0.0;
    [self.view addSubview:_progressView];
    _progressView.hidden = YES;
}

- (void)setupManualButton
{
    _manualButton = [[UIButton alloc] initWithFrame:CGRectMake(104.0, (((_promptLabel.center.y * 3.0) + _headingLabel.center.y) / 4.0),
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
    
    [button setTitleColor:UIColor.lightGrayColor
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
        [self startManagers];
        [self resetSumsAndCounter];
        
        _status = SCStatusCancel;
        _unableButton.enabled = NO;
        _progressView.hidden = NO;
        
        [_startCancelButton setTitle:@"Cancel"
                            forState:UIControlStateNormal];
    }
    
    else if (_status == SCStatusCancel)
    {
        [self stopManagers];
        
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
    NVSliderController *slider;
    
    if (_displayDegrees)
    {
        slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                      width:728.0
                                                 startValue:_data.frontSlopeDegrees
                                                   minValue:(_data.frontSlopeDegrees - 2.0)
                                                   maxValue:(_data.frontSlopeDegrees + 2.0)
                                                   delegate:self
                                              configuration:NVSliderConfigurationManualSlope
                                                       type:NVSliderMeasurementTypeDefault
                                                       unit:@""];
    }
    
    else
    {
        slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                      width:728.0
                                                 startValue:_data.frontSlopePct
                                                   minValue:(_data.frontSlopePct - 2.0)
                                                   maxValue:(_data.frontSlopePct + 2.0)
                                                   delegate:self
                                              configuration:NVSliderConfigurationManualSlope
                                                       type:NVSliderMeasurementTypeDefault
                                                       unit:@""];
    }
   
    [slider showSliderControllerInView:self.view
                              animated:YES
                               overlay:YES];
}

- (void)startManagers
{
    typedef void (^CMAccelerometerHandler)(CMAccelerometerData *accelerometerData, NSError *error);
    _motionManager.accelerometerUpdateInterval = 0.04;
    
    if (CLLocationManager.headingAvailable && !_hasRun)
        [_locationManager startUpdatingHeading];
    
    if ([_motionManager isAccelerometerAvailable])
    {
        [_motionManager startAccelerometerUpdatesToQueue:NSOperationQueue.currentQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                                 [self computeSlopeFromAccelerometer:accelerometerData];
                                                 
                                                 if(error)
                                                     NSLog(@"DeviceMotionError:%@", error.localizedDescription);
                                             }];
    }

    _promptLabel.text = @"Slope measurement in progress.\nPlease keep iPad stable.";
}

- (void)stopManagers
{
    [_motionManager stopAccelerometerUpdates];
    [_locationManager stopUpdatingHeading];
    _locationManager.delegate = nil;
}

- (void)stopMotionManager
{
    [_motionManager stopDeviceMotionUpdates];
    [_motionManager stopAccelerometerUpdates];
    [_locationManager stopUpdatingHeading];
}

- (BOOL)loadCalibration
{
    BOOL rtn = NO;
   
    NSArray *calibrationValues = SharedDefaults.defaults.calibrationValueArray;
    NSArray *targetValues = [calibrationValues[NVCalibrationArrayIndexValue] copy];
    _nCalibrationPoints = targetValues.count;
    int currentType = (NVCalibrationType)[calibrationValues[NVCalibrationArrayIndexType][0] intValue];
    _displayDegrees = (currentType == NVCalibrationTypeDegrees);
        
    if (_nCalibrationPoints > 1 && _nCalibrationPoints < 6)
    {
        _targetValues[0] = 0.0;
        NSArray *deviceValuesArray = [calibrationValues[NVCalibrationArrayDeviceValues] copy];
        NSNumber *num = deviceValuesArray[0];
        _deviceVals[0][0] = num.doubleValue;
        //num = deviceValuesArray[1];
        _deviceVals[0][1] = [(NSNumber *)deviceValuesArray[1] doubleValue];
        int dvIndex = 2;
        
        for (int i = 1; i < _nCalibrationPoints; i++)
        {
            NSNumber *num = targetValues[i];
            _targetValues[i] = num.doubleValue;
            int currentType = (NVCalibrationType)[calibrationValues[NVCalibrationArrayIndexType][i] intValue];
            
            if (currentType == NVCalibrationTypeRunningSlope)
                _targetValues[i] = (atan(_targetValues[i] / 100) * RADtoDEG);
            
            for (int j = 0; j < 4; j++)
            {
                if ((dvIndex + 1) < deviceValuesArray.count)
                    _deviceVals[i][j] = [(NSNumber *)deviceValuesArray[dvIndex++] doubleValue];
            }
        }
        
        rtn = YES;
    }
    
    return rtn;
}

- (CGFloat)adjustSlope:(CGFloat)slope
           isSideSlope:(BOOL)isSideSlope
{
    CGFloat adjustedSlope = 0.0;
    CGFloat priorValue = 0.0;
    CGFloat trueDegreesPerDeviceDegree = 0.0;
    int index = 0, i = 0;
    
    if (!_useCalibration)
        return slope;
    
    if (isSideSlope)
    {
        priorValue = _deviceVals[0][1];
        
        if (slope < priorValue)
            index = 3;
        
        else
            index = 2;
    }
    
    else
    {
        priorValue = _deviceVals[0][0];
        
        if (slope < priorValue)
            index = 1;
        
        else
            index = 0;
    }
    
    trueDegreesPerDeviceDegree = fabs((_targetValues[1] - _targetValues[0]) /
                                      (_deviceVals[1][index] - priorValue));
    
    for (i = 1 ; i < _nCalibrationPoints; i++)
    {
        if (index == 1 || index == 3)//downslope
        {
            if (slope >= _deviceVals[i][index])
            {
                adjustedSlope = -_targetValues[i-1] - fabs(slope - priorValue) * trueDegreesPerDeviceDegree;
                return adjustedSlope;
            }
        }
        
        else//upslope
        {
            if (slope <= _deviceVals[i][index])
            {
                adjustedSlope = _targetValues[i-1] + fabs(slope - priorValue) * trueDegreesPerDeviceDegree;
                return adjustedSlope;
            }
        }
        
        if (i < _nCalibrationPoints -1 )
        {
            trueDegreesPerDeviceDegree = fabs((_targetValues[i] - _targetValues[i-1]) /
                                              (_deviceVals[i][index] - priorValue));
        }
        
        priorValue = _deviceVals[i][index];
    }
    
    i = (int)_nCalibrationPoints;
    
    if (index == 1 || index == 3)//downslope
        adjustedSlope = (-_targetValues[i - 1] - fabs(slope - priorValue) * trueDegreesPerDeviceDegree);
    
    else
        adjustedSlope = (_targetValues[i - 1] + fabs(slope - priorValue) * trueDegreesPerDeviceDegree);

    return adjustedSlope;
}

- (void)slopesFromAccelerometer:(int)nReadings
{
    CGFloat denom = sqrt(square(_data.accelX[0]) + square(_data.accelY[0]) + square(_data.accelZ[0]));
    //CGFloat angz = acos(_data.accelZ[0] / denom);
    CGFloat angy = acos(_data.accelY[0] / denom);
    CGFloat angx = acos(_data.accelX[0] / denom);
    angx *= RADtoDEG;
    angy *= RADtoDEG;
    //angz *= RADtoDEG;
    angx = (angx - 90.0);
    angy = (angy - 90.0);
    //angz = (180.0 - angz);
    _lastDegrees = angy;
    
    _data.frontSlopeDegrees = [self adjustSlope:angy
                                    isSideSlope:NO];
    
    _data.sideSlopeDegrees = [self adjustSlope:angx
                                   isSideSlope:YES];
    
    _data.frontSlopePct = (tan(_data.frontSlopeDegrees * DEGtoRAD) * 100);
    _data.sideSlopePct = (tan(_data.sideSlopeDegrees * DEGtoRAD) * 100);
    _data.maxSlopePct = ComputeMaxSlope(_data.frontSlopePct, _data.sideSlopePct);
    _data.maxSlopeDegrees = (atan(_data.maxSlopePct / 100) * RADtoDEG);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"location ERROR:%@", error.localizedDescription);
}

-(CGFloat)correctedHeading:(CGFloat)heading
{
    CGFloat corrected = heading;
    
    _minHead = min(_minHead,heading);
    _maxHead = max(_maxHead,heading);
    
    if (_baseHeading - heading < -180)
        corrected = heading - 360.0;
    
    else if (_baseHeading - heading > 180)
        corrected = heading + 360.0;
    
    return corrected;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    if (!_headingCounter)
        _baseHeading = newHeading.trueHeading;
    
    _sumHeading += [self correctedHeading:newHeading.trueHeading];
    _headingCounter++;
}

- (void)computeSlopeFromAccelerometer:(CMAccelerometerData *)accelerometerData
{
    if (_counter == COUNT)
    {
        
        if (_hasRun)
        {
            [self stopManagers];
            
            _data.accelX[1] = (_aSumX / COUNT);
            _data.accelY[1] = (_aSumY / COUNT);
            _data.accelZ[1] = (_aSumZ / COUNT);
            
            [self slopesFromAccelerometer:2];
            [self slopeMeasurementComplete];
        }
        
        else if (_headingCounter || !CLLocationManager.headingAvailable)
        {
            [self stopManagers];
            
            _data.accelX[0] = (_aSumX / COUNT);
            _data.accelY[0] = (_aSumY / COUNT);
            _data.accelZ[0] = (_aSumZ / COUNT);
            
            if (_headingCounter)
            {
                _data.heading = _sumHeading / _headingCounter;
                _data.heading = Between0And360D(_data.heading);
            }
            else
            {
                _data.heading = 999;
                _headingCounter = 1;
            }
            
            [self slopesFromAccelerometer:1];
            
            if (_data.maxSlopePct < (_criticalValue - _errorValue) ||
                (_data.maxSlopePct > (_criticalValue + _errorValue)))
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
        
        if (_headingCounter)
            _counter++;
    }
    
    else if (_counter < COUNT)
    {
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        _maxX = max(_maxX, acceleration.x);
        _minX = min(_minX, acceleration.x);
        _maxY = max(_maxY, acceleration.y);
        _minY = min(_minY, acceleration.y);
        _maxZ = max(_maxZ, acceleration.z);
        _minZ = min(_minZ, acceleration.z);
        _xRange = (_maxX - _minX);
        _yRange = (_maxY - _minY);
        _zRange = (_maxZ - _minZ);
        
        if (_yRange > _steadyDiff ||
            _xRange > _steadyDiff ||
            _zRange > _steadyDiff)
        {
            [self resetSumsAndCounter];
        }
        
        
        _aSumX += acceleration.x;
        _aSumY += acceleration.y;
        _aSumZ += acceleration.z;
        
        _counter++;
        
        _progressView.progress = (_counter / (CGFloat)COUNT);
    }
}

- (void)resetSumsAndCounter
{
    _maxX = _maxY = _maxZ = -10.0;
    _minX = _minY = _minZ = 10.0;
    _aSumX = _aSumY = _aSumZ = 0.0;
    _sumHeading = 0.0;
    _counter = 0;
    _headingCounter = 0;
    _minHead = 10000;
    _maxHead = -10000;
}

- (void)slopeMeasurementComplete
{
    if (_displayDegrees)
    {
        _headingLabel.text = [NSString stringWithFormat:@"Heading = %.01f\u00B0", _data.heading];
        _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.01f\u00B0", _data.frontSlopeDegrees];
        _sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.01f\u00B0", _data.sideSlopeDegrees];
        _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.01f\u00B0", _data.maxSlopeDegrees];
        
        /*_maxSlopeLabel.text = [NSString stringWithFormat:@"%.5f %.5f %.5f",
                               _data.accelX[0], _data.accelY[0], _data.accelZ[0]];*/
    }
    
    else
    {
        _headingLabel.text = [NSString stringWithFormat:@"Heading = %.01f\u00B0", _data.heading];
        _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.01f%%", _data.frontSlopePct];
        _sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.01f%%", _data.sideSlopePct];
        _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.01f%%", _data.maxSlopePct];
        
        /*_maxSlopeLabel.text = [NSString stringWithFormat:@"%.3f %ld %.1f %.1f",
        _lastDegrees,(long)_headingCounter,_minHead,_maxHead];*/
    }
    
    _promptLabel.text = @"Press 'Done' to continue.";
    
    [_unableButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    
    _unable = NO;
    
    _startCancelButton.hidden = YES;
    _unableButton.enabled = YES;
    [self updateButtonAppearance:_unableButton];
    
    _progressView.hidden = YES;
    _hasRun = NO;
    
    _manualButton.hidden = NO;
    
    if ((fabs(_data.frontSlopePct) > (_criticalValue - _errorValue)) &&
        (fabs(_data.frontSlopePct) < (_criticalValue + _errorValue)))
    {
        NVSliderController *slider;
        
        if (_displayDegrees)
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:728.0
                                                     startValue:_data.frontSlopeDegrees
                                                       minValue:(_data.frontSlopeDegrees - 2.0)
                                                       maxValue:(_data.frontSlopeDegrees + 2.0)
                                                       delegate:self
                                                  configuration:NVSliderConfigurationManualSlope
                                                           type:NVSliderMeasurementTypeFrontSlope
                                                           unit:@""];
        }
        
        else
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:728.0
                                                     startValue:_data.frontSlopePct
                                                       minValue:(_data.frontSlopePct - 2.0)
                                                       maxValue:(_data.frontSlopePct + 2.0)
                                                       delegate:self
                                                  configuration:NVSliderConfigurationManualSlope
                                                           type:NVSliderMeasurementTypeFrontSlope
                                                           unit:@""];
        }
        
        [slider showSliderControllerInView:self.view
                                  animated:YES
                                   overlay:YES];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return _useHeadingCalibration;
}

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(CGFloat)value
{
    NVSliderMeasurementType type = sliderView.type;
    
    if (_displayDegrees)
    {
        switch (type)
        {
            case NVSliderMeasurementTypeFrontSlope:
            case NVSliderMeasurementTypeDefault:
                _data.manualFrontSlopeDegrees = value;
                _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.02f\u00B0", _data.manualFrontSlopeDegrees];
                _data.frontManualStatus = NVManualStatusManual;
                break;
                
            case NVSliderMeasurementTypeSideSlope:
                _data.manualSideSlopeDegrees = value;
                _sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.02f\u00B0", _data.manualSideSlopeDegrees];
                _data.sideManualStatus = NVManualStatusManual;
                break;
                
            default:
                break;
        }
    }
    
    else
    {
        switch (type)
        {
            case NVSliderMeasurementTypeFrontSlope:
            case NVSliderMeasurementTypeDefault:
                _data.manualFrontSlopePct = value;
                _frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.02f%%", _data.manualFrontSlopePct];
                _data.frontManualStatus = NVManualStatusManual;
                break;
                
            case NVSliderMeasurementTypeSideSlope:
                _data.manualSideSlopePct = value;
                _sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.02f%%", _data.manualSideSlopePct];
                _data.sideManualStatus = NVManualStatusManual;
                break;
                
            default:
                break;
        }
    }
    
    [sliderView hideSliderController:YES];
    
    if ((type == NVSliderMeasurementTypeFrontSlope) &&
        (fabs(_data.sideSlopePct) > (_criticalSideValue - _errorValue)) &&
        (fabs(_data.sideSlopePct) < (_criticalSideValue + _errorValue)))
    {
        NVSliderController *slider;
        
        if (_displayDegrees)
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:728.0
                                                     startValue:_data.sideSlopeDegrees
                                                       minValue:(_data.sideSlopeDegrees - 2.0)
                                                       maxValue:(_data.sideSlopeDegrees + 2.0)
                                                       delegate:self
                                                  configuration:NVSliderConfigurationManualSlope
                                                           type:NVSliderMeasurementTypeSideSlope
                                                           unit:@""];
        }
        
        else
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:728.0
                                                     startValue:_data.sideSlopePct
                                                       minValue:(_data.sideSlopePct - 2.0)
                                                       maxValue:(_data.sideSlopePct + 2.0)
                                                       delegate:self
                                                  configuration:NVSliderConfigurationManualSlope
                                                           type:NVSliderMeasurementTypeSideSlope
                                                           unit:@""];
        }
        
        [slider showSliderControllerInView:self.view
                                  animated:YES
                                   overlay:YES];
    }
}

- (void)sliderViewDidCancel:(NVSliderController *)sliderView
{
    switch (sliderView.type)
    {
        case NVSliderMeasurementTypeFrontSlope:
            _data.frontManualStatus = NVManualStatusCancelled;
            break;
            
        case NVSliderMeasurementTypeSideSlope:
            _data.sideManualStatus = NVManualStatusCancelled;
            break;
            
        default:
            break;
    }
    
    [sliderView hideSliderController:YES];
}

- (void)removeManualMeasurementButton
{
    [_manualButton removeFromSuperview];
}

- (void)removeCalDateLabel
{
    [_calDateLabel removeFromSuperview];
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

- (void)setPromptText:(NSString *)promptText
{
    _promptText = promptText;
    _promptLabel.text = promptText;
}

- (void)helpButtonTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@""
                                                       ofType:@"pdf"];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath];
#pragma unused(nvwv)
}

@end