//  SlopeViewController.m
//  CCodeLibrary

@import CoreLocation;
@import CoreMotion;
#import "GSSiSlopeViewController.h"
#import "CRAPI.h"
#import "MathUtil.h"
#import "NVProgressView.h"
#import "SharedDefaults.h"
#import "WIT_MotionInput.h"

static double _deviceVals[5][4];
static double _targetValues[5];
static NSInteger _nCalibrationPoints;
static double WitMotionAngles[3]; //roll,pitch,yaw

typedef NS_ENUM(NSInteger, SCStatus)
{
    SCStatusStart,
    SCStatusCancel,
};

static int COUNT=100;
#define MIN_HEADING_COUNTER 5

@interface GSSiSlopeViewController ()

@property (nonatomic) UIButton *unableButton, *startCancelButton, *manualFront, *manualSide, *cancelButton, *doesNotExistButton;
@property (nonatomic) UIImageView *arrowView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UILabel *frontSlopeLabel, *sideSlopeLabel, *maxSlopeLabel, *promptLabel;
@property double steadyDiff;
@property double xRange, yRange, zRange;
@property double maxX, minX, maxY, minY, maxZ, minZ;
@property double aSumX, aSumY, aSumZ;
@property (nonatomic) NVSlopeData data;
@property NSInteger counter, headingCounter;
@property double minHead, maxHead;
@property double lastDegrees;
@property double sumHeading, baseHeading;
@property (nonatomic) UILabel *headingLabel, *calDateLabel;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CMMotionManager *motionManager;
@property SCStatus status;
@property BOOL unable, hasRun;
@property (nonatomic) NSMutableArray<CLLocation *> *locations;
@property WIT_MotionInput *witMotionInput;
@property BOOL inWitMotionCalibrate;

@end

@implementation GSSiSlopeViewController

+ (GSSiSlopeViewController *)slopeControllerWithCriticalValue:(double)criticalVal
                                            criticalSideValue:(double)criticalSideVal
                                                   errorValue:(double)errVal
                                               useCalibration:(BOOL)useCalibration
                                        useHeadingCalibration:(BOOL)useHeadingCalibration
                                                 steadyFactor:(double)steadyFac
                                                  countFactor:(double)countFac
                                               displayDegrees:(BOOL)displayDegrees
                                                     delegate:(id)delegate;
{
    GSSiSlopeViewController *slopeController = [[GSSiSlopeViewController alloc] init];
    slopeController.displayDegrees = displayDegrees;
    slopeController.useCalibration = useCalibration;
    slopeController.useHeadingCalibration = useHeadingCalibration;
    slopeController.delegate = delegate;
    slopeController.steadyFactor = max (steadyFac,1.0);
    slopeController.hideDoesNotExistButton = NO;
    slopeController.fromCalibration = NO;
    slopeController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if (countFac)
        slopeController.countFactor = countFac;
    else
        slopeController.countFactor = 1.0;
    
    slopeController.criticalValue = criticalVal;
    slopeController.criticalSideValue = criticalSideVal;
    slopeController.errorValue = errVal * criticalVal;
    slopeController.errorValueSide = errVal * criticalSideVal;
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
    _wantWitMotion = YES;
    _inWitMotionCalibrate = NO;
    if (_wantWitMotion)
        _witMotionInput = WIT_MotionInput.new;
    if (!_fromCalibration)
    {
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
    }
    
    if (_useCalibration)
        [self loadCalibration];
    
    self.view.backgroundColor = UserDefaults.defaults.defaultColors.backgroundColor;
    
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
    
    if (!_fromCalibration)
    {
        [self setupManualButtons];
        [self setupDoesNotExistButton];
    }
    
    if (!CRAPI.sharedInstance.controlledInterface)
        [self setupCancelButton];
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.frame = CGRectMake(668.0, 20.0, 80.0, 80.0);
    
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
    if (_wantWitMotion)
    {
        UIButton *zeroButton = [UIButton buttonWithType:UIButtonTypeCustom];
        zeroButton.frame = CGRectMake(568.0, 120.0, 190.0, 80.0);
        [self setupButton:zeroButton    title:@"Zero"];
        [zeroButton addTarget:self
                       action:@selector(zeroButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
   }
    _locationManager = CLLocationManager.new;
    _locationManager.headingFilter = kCLHeadingFilterNone;
    _locationManager.headingOrientation = CLDeviceOrientationFaceUp;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    _motionManager = CMMotionManager.new;
    [self resetSumsAndCounter];

    if (_hideDoesNotExistButton || _fromCalibration)
        [self hideDoesNotExist];
    if (_fromCalibration)
        _unableButton.hidden = YES;
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(resignedActive:)
                                               name:@"didResignActive"
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(becameActive:)
                                               name:@"didBecomeActive"
                                             object:nil];
    
    if (CRAPI.sharedInstance.inSdwkMode)
    {
        UIButton *autoLoopStartStop = [UIButton buttonWithType:UIButtonTypeCustom];
        autoLoopStartStop.translatesAutoresizingMaskIntoConstraints = NO;
        autoLoopStartStop.backgroundColor = UIColor.blackColor;
        
        if (CRAPI.sharedInstance.inAutoLoopMode)
        {
            [self setupButton:autoLoopStartStop title:@"Stop Auto Loop"];
            _useHeadingCalibration = NO;
            _errorValue = 0.0;
            _cancelButton.hidden = YES;
            _startCancelButton.hidden = YES;
            
            [self startCancel];
            
            if (CLLocationManager.locationServicesEnabled)
            {
                _locations = NSMutableArray.new;
                [_locationManager startUpdatingLocation];
            }
        }
        
        else
            [self setupButton:autoLoopStartStop title:@"Start Auto Loop"];
        
        autoLoopStartStop.titleLabel.font = [UIFont systemFontOfSize:32.0];
        
        [autoLoopStartStop addTarget:self
                              action:@selector(startStopAutoLoop:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        [autoLoopStartStop constrainLeadingToAnchor:self.view.leadingAnchor constant:20.0];
        [autoLoopStartStop constrainTopToAnchor:self.view.topAnchor constant:100.0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)resignedActive:(id)selector
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"didResignActive" object:nil];
    [self stopMotionManager];
}

- (void)becameActive:(id)selector
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"didBecomeActive" object:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(gssiSlopeViewControllerDidCancelForSystemCalibration:)])
        [_delegate gssiSlopeViewControllerDidCancelForSystemCalibration:self];
}

- (void)setupUnableButton
{
    _unableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _unableButton.frame = CGRectMake(56.0, 884.0, 300.0, 80.0);
    
    [_unableButton addTarget:self
                      action:@selector(goBack)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self setupButton:_unableButton title:@"Unable"];
    _unableButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
}

- (void)setupStartCancelButton
{
    _startCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startCancelButton.frame = CGRectMake(184.0, 564.0, 400.0, 80.0);
    
    [_startCancelButton addTarget:self
                           action:@selector(startCancel)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self setupButton:_startCancelButton title:@"Start"];
}

- (void)setupCancelButton
{
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(20.0, 30.0, 60.0, 60.0);
    
    [_cancelButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"backButton"
                                                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
    
    [_cancelButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"backButtonHighlighted"
                                                                                           ofType:@"png"]]
                   forState:UIControlStateHighlighted];
    
    [_cancelButton addTarget:self
                      action:@selector(cancelTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_cancelButton];
}

- (void)setupDoesNotExistButton
{
    _doesNotExistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doesNotExistButton.frame = CGRectMake(412.0, 884.0, 300.0, 80.0);
    
    [_doesNotExistButton addTarget:self
                            action:@selector(doesNotExistTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self setupButton:_doesNotExistButton
                title:@"Does Not Exist"];
    
    _doesNotExistButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
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
    _frontSlopeLabel.layer.borderColor = UIColor.redColor.CGColor;
    _sideSlopeLabel.layer.borderColor = UIColor.redColor.CGColor;
    _frontSlopeLabel.layer.borderWidth = 0.0;
    _sideSlopeLabel.layer.borderWidth = 0.0;
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

- (void)setupManualButtons
{
    CGFloat yCenter = (((CGRectGetMaxY(_promptLabel.frame) + CGRectGetMinY(_headingLabel.frame)) / 2.0) - 40.0);
    
    _manualFront = [UIButton buttonWithType:UIButtonTypeCustom];
    _manualFront.frame = CGRectMake(0.0, 0.0, 300.0, 60.0);
    _manualFront.center = CGPointMake((self.view.frame.size.width * 0.25), yCenter);
    
    [_manualFront addTarget:self
                     action:@selector(manualFrontTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _manualFront.hidden = YES;
    [self setupButton:_manualFront title:@"Manual Running"];
    _manualFront.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    _manualSide = [UIButton buttonWithType:UIButtonTypeCustom];
    _manualSide.frame = CGRectMake(0.0, 0.0, 300.0, 60.0);
    _manualSide.center = CGPointMake((self.view.frame.size.width * 0.75), yCenter);
    
    [_manualSide addTarget:self
                    action:@selector(manualSideTapped)
          forControlEvents:UIControlEventTouchUpInside];
    
    _manualSide.hidden = YES;
    [self setupButton:_manualSide title:@"Manual Cross"];
    _manualSide.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UserDefaults.defaults.defaultColors.titleColor forState:UIControlStateNormal];
    [button setTitleColor:UserDefaults.defaults.defaultColors.highlightedColor forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:72.0];
    button.layer.cornerRadius = 10.0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self updateButtonAppearance:button];
    [self.view addSubview:button];
}

- (void)updateButtonAppearance:(UIButton *)button
{
    if (button.enabled)
        button.backgroundColor = UserDefaults.defaults.defaultColors.enabledColor;
    
    else
        button.backgroundColor = UserDefaults.defaults.defaultColors.disabledColor;
}

- (void)setupLabel:(UILabel *)label
{
    label.textColor = UserDefaults.defaults.defaultColors.textColor;
    label.font = [UIFont boldSystemFontOfSize:44.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self.view addSubview:label];
}

- (void)goBack
{
    [self stopMotionManager];
    
    if (_unable)
        _data.frontSlopePct = _data.sideSlopePct = _data.frontSlopeDegrees = _data.sideSlopeDegrees = _data.heading = -9999.0;
    
    if (_wantLocation)
    {
        [_locationManager stopUpdatingLocation];
        
        int count = 0;
        CLLocationDegrees lat = 0.0, lon = 0.0;
        int numCoords = min(5, (int)(_locations.count - 1));
        
        for (int i = (int)(_locations.count - numCoords); i < _locations.count; i++)
        {
            CLLocationCoordinate2D coord = _locations[i].coordinate;
            lat += coord.latitude;
            lon += coord.longitude;
            count++;
        }
        
        CLLocationCoordinate2D avgCoord = CLLocationCoordinate2DMake((lat / (double)count),
                                                                     (lon / (double)count));
        
        if (_delegate)
        {
            [_delegate gssiSlopeViewController:self
                            didReturnSlopeData:_data
                                      location:avgCoord];
        }
    }
    else
    {
        if (_delegate)
        {
            [_delegate gssiSlopeViewController:self
                            didReturnSlopeData:_data];
        }
    }
}

- (void)doesNotExistTapped:(UIButton *)button
{
    [self stopMotionManager];
    
    if (_unable)
        _data.frontSlopePct = _data.sideSlopePct = _data.frontSlopeDegrees = _data.sideSlopeDegrees = _data.heading = -9998.0;
    
    if (_delegate)
    {
        [_delegate gssiSlopeViewController:self
                        didReturnSlopeData:_data];
    }
}

- (void)cancelTapped:(UIButton *)button
{
    [self stopMotionManager];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


- (void)startCancel
{
    if (_status == SCStatusStart)
    {
        if (_inWitMotionCalibrate)
        {
            [_witMotionInput rightCalibrate];
            _inWitMotionCalibrate = NO;
        }
        else
        {
            [self startManagers];
            [self resetSumsAndCounter];
            
            _status = SCStatusCancel;
            _unableButton.enabled = _doesNotExistButton.enabled = NO;
            _progressView.hidden = NO;
            
            [_startCancelButton setTitle:@"Cancel"
                                forState:UIControlStateNormal];
        }
    }
    
    else if (_status == SCStatusCancel)
    {
        [self stopManagers];
        
        _status = SCStatusStart;
        _unableButton.enabled = _doesNotExistButton.enabled = YES;
        _progressView.hidden = YES;
        
        [_startCancelButton setTitle:@"Start"
                            forState:UIControlStateNormal];
    }
    
    [self updateButtonAppearance:_unableButton];
    [self updateButtonAppearance:_doesNotExistButton];
}

- (void)manualFrontTapped
{
    NVSliderController *slider = nil;
    
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
                                                       unit:@"°"];
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
                                                       unit:@"%"];
    }
    
    [slider showSliderControllerInView:self.view
                              animated:YES
                               overlay:YES];
    
    [slider removeRequiredFromLabel];
}

- (void)manualSideTapped
{
    NVSliderController *slider = nil;
    
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
                                                       unit:@"°"];
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
                                                       unit:@"%"];
    }
    
    [slider showSliderControllerInView:self.view
                              animated:YES
                               overlay:YES];
    
    [slider removeRequiredFromLabel];
}

- (void)startManagers
{
    typedef void (^CMAccelerometerHandler)(CMAccelerometerData *accelerometerData, NSError *error);
    _motionManager.accelerometerUpdateInterval = 0.04;
    
    if ([_motionManager isAccelerometerAvailable])
    {
        [_motionManager startAccelerometerUpdatesToQueue:NSOperationQueue.currentQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                                 [self computeSlopeFromAccelerometer:accelerometerData];
                                                 
                                                 if(error)
                                                     NSLog(@"DeviceMotionError:%@", error.localizedDescription);
                                             }];
    }
    
    if (CLLocationManager.headingAvailable && !_hasRun)
        [_locationManager startUpdatingHeading];
    if (_wantLocation)
    {
        _locations = NSMutableArray.new;
        [_locationManager startUpdatingLocation];
    }
    if (_wantWitMotion)
    {
        [_witMotionInput startInput];
    }
    _promptLabel.text = @"Slope measurement in progress.\nPlease keep iPad stable.";
}

- (void)stopManagers
{
    [_motionManager stopAccelerometerUpdates];
    [_locationManager stopUpdatingHeading];
    [_witMotionInput cancel];
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
        num = deviceValuesArray[1];
        _deviceVals[0][1] = [(NSNumber *)deviceValuesArray[1] doubleValue];
        int dvIndex = 2;
        
        for (int i = 1; i < _nCalibrationPoints; i++)
        {
            num = targetValues[i];
            _targetValues[i] = num.doubleValue;
            int currentType = (NVCalibrationType)[calibrationValues[NVCalibrationArrayIndexType][i] intValue];
            
            if (currentType == NVCalibrationTypeRunningSlope)
                _targetValues[i] = (atan(_targetValues[i] / 100) * RADtoDEG);
            
            for (int j = 0; j < 4; j++)
            {
                if (dvIndex < deviceValuesArray.count)
                {
                    num = deviceValuesArray[dvIndex++];
                    _deviceVals[i][j] = num.doubleValue;
                }
            }
        }
        
        rtn = YES;
    }
    
    return rtn;
}

- (double)adjustSlope:(double)slope
           isSideSlope:(BOOL)isSideSlope
{
    double adjustedSlope = 0.0;
    double priorValue = 0.0;
    double trueDegreesPerDeviceDegree = 0.0;
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

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"location ERROR:%@", error.localizedDescription);
}

- (double)correctedHeading:(double)heading
{
    double corrected = heading;
    
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
    if (_headingCounter == MIN_HEADING_COUNTER)
        _baseHeading = newHeading.trueHeading;
    
    if (_headingCounter >= MIN_HEADING_COUNTER)
        _sumHeading += [self correctedHeading:newHeading.trueHeading];
    
    _headingCounter++;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [_locations addObject:locations.lastObject];
}

- (void)computeSlopeFromAccelerometer:(CMAccelerometerData *)accelerometerData
{
    if (_counter == COUNT)
    {
        if (_headingCounter > (MIN_HEADING_COUNTER + 10) || !CLLocationManager.headingAvailable)
        {
            
            _data.accelX = (_aSumX / COUNT);
            _data.accelY = (_aSumY / COUNT);
            _data.accelZ = (_aSumZ / COUNT);
            
            if (_headingCounter)
            {
                _data.heading = _sumHeading / (_headingCounter - MIN_HEADING_COUNTER);
                _data.heading = Between0And360D(_data.heading);
            }
            
            else
            {
                _data.heading = 999;
                _headingCounter = 1;
            }
            
            double denom = sqrt(square(_data.accelX) + square(_data.accelY) + square(_data.accelZ));
            double angy = acos(_data.accelY / denom);
            double angx = acos(_data.accelX / denom);
            angx *= RADtoDEG;
            angy *= RADtoDEG;
            angx = (angx - 90.0);
            angy = (angy - 90.0);

            if (_wantWitMotion)
            {
                if ([_witMotionInput getResults:WitMotionAngles] > 4)
                {
                    angy = WitMotionAngles[1];
                    angx = WitMotionAngles[0];
                }
                else
                {
                    [self resetSumsAndCounter];
                    return;
                }
            }
            _lastDegrees = angy;
            [self stopManagers];

            _data.frontSlopeDegrees = [self adjustSlope:angy isSideSlope:NO];
            _data.sideSlopeDegrees = [self adjustSlope:angx isSideSlope:YES];
            
            _data.frontSlopePct = (tan(_data.frontSlopeDegrees * DEGtoRAD) * 100);
            _data.sideSlopePct = (tan(_data.sideSlopeDegrees * DEGtoRAD) * 100);
            _data.maxSlopePct = ComputeMaxSlope(_data.frontSlopePct, _data.sideSlopePct);
            _data.maxSlopeDegrees = (atan(_data.maxSlopePct / 100) * RADtoDEG);
            [self slopeMeasurementComplete];
        }
        
        if (_headingCounter  > MIN_HEADING_COUNTER + 10)
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
        
        _progressView.progress = (_counter / (double)COUNT);
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
    if (_witMotionInput)
        [_witMotionInput restart];
}

- (void)slopeMeasurementComplete
{
    if (CRAPI.sharedInstance.inAutoLoopMode)
    {
        [self stopMotionManager];
        [_locationManager stopUpdatingLocation];
        
        int count = 0;
        CLLocationDegrees lat = 0.0, lon = 0.0;
        int numCoords = min(5, (int)(_locations.count));
        
        for (int i = (int)(_locations.count - numCoords); i < _locations.count; i++)
        {
            CLLocationCoordinate2D coord = _locations[i].coordinate;
            lat += coord.latitude;
            lon += coord.longitude;
            count++;
        }
        
        CLLocationCoordinate2D avgCoord = CLLocationCoordinate2DMake((lat / (double)count),
                                                                     (lon / (double)count));
        
        if (_delegate)
        {
            [_delegate gssiSlopeViewController:self
                            didReturnSlopeData:_data
                                      location:avgCoord];
        }
        
        return;
    }
    
    if (_displayDegrees)
    {
        _headingLabel.text = [NSString stringWithFormat:@"Heading = %.01f°", _data.heading];
        _frontSlopeLabel.text = [NSString stringWithFormat:@"Running Slope = %+.01f°", _data.frontSlopeDegrees];
        _sideSlopeLabel.text = [NSString stringWithFormat:@"Cross Slope = %+.01f°", _data.sideSlopeDegrees];
        _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.01f°", _data.maxSlopeDegrees];
    }
    
    else
    {
        _headingLabel.text = [NSString stringWithFormat:@"Heading = %.01f°", _data.heading];
        _frontSlopeLabel.text = [NSString stringWithFormat:@"Running Slope = %+.01f%%", _data.frontSlopePct];
        _sideSlopeLabel.text = [NSString stringWithFormat:@"Cross Slope = %+.01f%%", _data.sideSlopePct];
        _maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.01f%%", _data.maxSlopePct];
    }
    
    if (fabs(_data.frontSlopePct) > fabs(_criticalValue))
        _frontSlopeLabel.layer.borderWidth = 4.0;
    
    else
        _frontSlopeLabel.layer.borderWidth = 0.0;
    
    if (fabs(_data.sideSlopePct) > fabs(_criticalSideValue))
        _sideSlopeLabel.layer.borderWidth = 4.0;
    
    else
        _sideSlopeLabel.layer.borderWidth = 0.0;
    
    _promptLabel.text = @"Press 'Done' to continue.";
    [_unableButton setTitle:@"Done" forState:UIControlStateNormal];
    _unableButton.hidden = NO;
    
    _startCancelButton.hidden = _progressView.hidden = _cancelButton.hidden = YES;
    _unable = _hasRun = NO;
    _unableButton.enabled = _doesNotExistButton.enabled = YES;
    [self updateButtonAppearance:_unableButton];
    [self updateButtonAppearance:_doesNotExistButton];
    _manualFront.hidden = NO;
    _manualSide.hidden = NO;
    
    [self hideDoesNotExist];
    
    if ((fabs(_data.frontSlopePct) > (_criticalValue - _errorValue)) &&
        (fabs(_data.frontSlopePct) < (_criticalValue + _errorValue)))
    {
        NVSliderController *slider = nil;
        
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
                                                           unit:@"°"];
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
                                                           unit:@"%"];
        }
        
        [slider showSliderControllerInView:self.view
                                  animated:YES
                                   overlay:YES];
    }
    else if ((fabs(_data.sideSlopePct) > (_criticalSideValue - _errorValueSide)) &&
        (fabs(_data.sideSlopePct) < (_criticalSideValue + _errorValueSide)))
    {
        NVSliderController *slider = nil;
        
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
                                                           unit:@"°"];
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
                                                           unit:@"%"];
        }
        
        [slider showSliderControllerInView:self.view
                                  animated:YES
                                   overlay:YES];
    }

}

- (void)hideDoesNotExist
{
    _doesNotExistButton.hidden = YES;
    _unableButton.frame = CGRectMake(184.0, _unableButton.frame.origin.y, 400.0, _unableButton.frame.size.height);
    _unableButton.titleLabel.font = [UIFont boldSystemFontOfSize:72.0];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    if (!CRAPI.sharedInstance.showCompassCalibrationScreen)
        return NO;
    
    else
        return _useHeadingCalibration;
}

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(double)value
{
    NVSliderMeasurementType type = sliderView.type;
    
    if (_displayDegrees)
    {
        switch (type)
        {
            case NVSliderMeasurementTypeFrontSlope:
            case NVSliderMeasurementTypeDefault:
                _data.manualFrontSlopeDegrees = value;
                
                _frontSlopeLabel.text = [NSString stringWithFormat:@"Running Slope = %+.02f°",
                                         _data.manualFrontSlopeDegrees];
                
                _data.frontManualStatus = NVManualStatusManual;
                break;
            case NVSliderMeasurementTypeSideSlope:
                _data.manualSideSlopeDegrees = value;
                
                _sideSlopeLabel.text = [NSString stringWithFormat:@"Cross Slope = %+.02f°",
                                        _data.manualSideSlopeDegrees];
                
                _data.sideManualStatus = NVManualStatusManual;
                break;
            default:break;
        }
    }
    
    else
    {
        switch (type)
        {
            case NVSliderMeasurementTypeFrontSlope:
            case NVSliderMeasurementTypeDefault:
                _data.manualFrontSlopePct = value;
                _frontSlopeLabel.text = [NSString stringWithFormat:@"Running Slope = %+.02f%%", _data.manualFrontSlopePct];
                _data.frontManualStatus = NVManualStatusManual;
                
                if (fabs(_data.manualFrontSlopePct) > fabs(_criticalValue))
                    _frontSlopeLabel.layer.borderWidth = 4.0;
                
                else
                    _frontSlopeLabel.layer.borderWidth = 0.0;
                break;
            case NVSliderMeasurementTypeSideSlope:
                _data.manualSideSlopePct = value;
                _sideSlopeLabel.text = [NSString stringWithFormat:@"Cross Slope = %+.02f%%", _data.manualSideSlopePct];
                _data.sideManualStatus = NVManualStatusManual;
                
                if (fabs(_data.manualSideSlopePct) > fabs(_criticalSideValue))
                    _sideSlopeLabel.layer.borderWidth = 4.0;
                
                else
                    _sideSlopeLabel.layer.borderWidth = 0.0;
                break;
            default:break;
        }
    }
    
    [sliderView hideSliderController:YES];
    
    if ((type == NVSliderMeasurementTypeFrontSlope) &&
        (fabs(_data.sideSlopePct) > (_criticalSideValue - _errorValueSide)) &&
        (fabs(_data.sideSlopePct) < (_criticalSideValue + _errorValueSide)))
    {
        NSLog(@"sidePct=%f, critSV=%f, errorVal=%f", _data.sideSlopePct, _criticalSideValue, _errorValue);
        
        NVSliderController *slider = nil;
        
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
                                                           unit:@"°"];
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
                                                           unit:@"%"];
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
        default:break;
    }
    
    [sliderView hideSliderController:YES];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (CRAPI.sharedInstance.presentUpsideDown)
        return UIInterfaceOrientationPortraitUpsideDown;
    
    else
        return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (CRAPI.sharedInstance.presentUpsideDown)
        return UIInterfaceOrientationMaskPortraitUpsideDown;
    
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void)setPromptText:(NSString *)promptText
{
    _promptText = promptText;
    _promptLabel.text = promptText;
}

- (void)helpButtonTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"NVCRISHelp_SlopeVC"
                                                       ofType:@"pdf"];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath
                                          delegate:nil];
#pragma unused(nvwv)
}

- (void)startStopAutoLoop:(UIButton *)button
{
    CRAPI.sharedInstance.inAutoLoopMode = !CRAPI.sharedInstance.inAutoLoopMode;
    
    _cancelButton.hidden = CRAPI.sharedInstance.inAutoLoopMode;
    _startCancelButton.hidden = CRAPI.sharedInstance.inAutoLoopMode;
    _useHeadingCalibration = !CRAPI.sharedInstance.inAutoLoopMode;
    
    if (CRAPI.sharedInstance.inAutoLoopMode)
    {
        [button setTitle:@"Stop Auto Loop" forState:UIControlStateNormal];
        _errorValue = 0.0;
        
        if (CLLocationManager.locationServicesEnabled)
        {
            _locations = NSMutableArray.new;
            [_locationManager startUpdatingLocation];
        }
    }
    
    else
    {
        [_locationManager stopUpdatingLocation];
        [button setTitle:@"Start Auto Loop" forState:UIControlStateNormal];
        _errorValue = SDWK_ERROR_VAL;
    }
    
    [self startCancel];
}
 - (void) zeroButtonTapped:(UIButton *)button
 {
     [_witMotionInput startCalibration];
     _promptLabel.text = @"Reverse the direction and hit Start";
     [_witMotionInput leftCalibrate];
     _inWitMotionCalibrate = YES;
 }
@end
