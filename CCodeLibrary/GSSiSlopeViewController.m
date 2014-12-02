//  SlopeViewController.m
//  CCodeLibrary

#import "GSSiSlopeViewController.h"

#define SLOPE_STABILITY 0
#define SLOPE_BEGIN 1
#define SHORT_COUNT 50
#define LONG_COUNT 200
#define SC_START 0
#define SC_CANCEL 1

@interface GSSiSlopeViewController ()

@end

@implementation GSSiSlopeViewController

- (id)initWithTarget:(CGFloat)target
           forceFlip:(CGFloat)forceFlip
{
    self = [super init];
    
    if (self)
    {
        self.target = target;
        self.forceFlip = forceFlip;
    }
    
    return self;
}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    id appDelegate = UIApplication.sharedApplication.delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)])
        motionManager = [appDelegate motionManager];
    
    return motionManager;
}

- (CLLocationManager *)locationManager
{
    CLLocationManager *locationManager = nil;
    id appDelegate = UIApplication.sharedApplication.delegate;
    
    if ([appDelegate respondsToSelector:@selector(locationManager)])
        locationManager = [appDelegate locationManager];
    
    locationManager.delegate = self;
    return locationManager;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    self.calibrationOption = SLOPE_STABILITY;
    self.maxX = self.maxY = -1.0;
    self.minX = self.minY = 1.0;
    self.xRange = self.yRange = 0.0;
    self.sumX = self.sumY = 0.0;
    self.sumHeading = self.avgHeading = 0.0;
    self.counter = self.headingCounter = 0;
    self.startCancelState = SC_START;
    self.hasRun = NO;
    self.headingCounter = 0;
    
    [self setupUnableButton];
    [self setupStartCancelButton];
    [self setupArrowView];
    [self setupLabels];
    [self setupProgressView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupUnableButton
{
    self.unableButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 904.0, 400.0, 100.0)];
    
    [self.unableButton addTarget:self
                          action:@selector(goBack:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.unableButton];
    
    [self setupButton:self.unableButton
                title:@"Unable"];
}

- (void)setupStartCancelButton
{
    self.startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(184.0, 564.0, 400.0, 100.0)];
    
    [self.startCancelButton addTarget:self
                               action:@selector(startCancel:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.startCancelButton];
    
    [self setupButton:self.startCancelButton
                title:@"Start"];
}

- (void)setupLabels
{
    self.headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 614.0, 568.0, 60.0)];
    self.frontSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 684.0, 568.0, 60.0)];
    self.sideSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 754.0, 568.0, 60.0)];
    self.maxSlopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 824.0, 568.0, 60.0)];
    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 340.0, 728.0, 194.0)];
    
    [self.view addSubview:self.headingLabel];
    [self.view addSubview:self.frontSlopeLabel];
    [self.view addSubview:self.sideSlopeLabel];
    [self.view addSubview:self.maxSlopeLabel];
    [self.view addSubview:self.promptLabel];
    
    [self setupLabel:self.headingLabel];
    [self setupLabel:self.frontSlopeLabel];
    [self setupLabel:self.sideSlopeLabel];
    [self setupLabel:self.maxSlopeLabel];
    [self setupLabel:self.promptLabel];
    
    self.promptLabel.text = @"Place the iPad with the arrow pointing toward the downslope and tap 'Start' to begin measurement.";
}

- (void)setupArrowView
{
    self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(240.0, 20.0, 288.0, 320.0)];
    self.arrowView.image = UserDefaults.defaults.whiteArrow;
    [self.view addSubview:self.arrowView];
}

- (void)setupProgressView
{
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(60.0, 781.0, 648.0, 9.0)];
    self.progressView.progressTintColor = UIColor.whiteColor;
    self.progressView.trackTintColor = UIColor.blackColor;
    self.progressView.progress = 0.0;
    [self.view addSubview:self.progressView];
    self.progressView.hidden = YES;
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.grayColor
                 forState:UIControlStateDisabled];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:84.0];
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 6.0;
    
    [self updateButtonAppearance:button];
}

- (void)updateButtonAppearance:(UIButton *)button
{
    if (button.enabled == YES)
    {
        button.backgroundColor = UIColor.whiteColor;
        button.layer.borderColor = UserDefaults.defaults.green.CGColor;
    }
    
    else
    {
        button.backgroundColor = UserDefaults.defaults.green;
        button.layer.borderColor = UIColor.grayColor.CGColor;
    }
}

- (void)setupLabel:(UILabel *)label
{
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont boldSystemFontOfSize:44.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
}

- (void)goBack:(UIButton *)button
{
    [self.motionManager stopDeviceMotionUpdates];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)startCancel:(UIButton *)button
{
    if (self.startCancelState == SC_START)
    {
        [self startMotionManager];
        self.startCancelState = SC_CANCEL;
        self.unableButton.enabled = NO;
        self.progressView.hidden = NO;
        
        [self.startCancelButton setTitle:@"Cancel"
                                forState:UIControlStateNormal];
    }
    
    else if (self.startCancelState == SC_CANCEL)
    {
        [self.motionManager stopDeviceMotionUpdates];
        self.startCancelState = SC_START;
        self.unableButton.enabled = YES;
        self.progressView.hidden = YES;
        
        [self.startCancelButton setTitle:@"Start"
                                forState:UIControlStateNormal];
    }
    
    [self updateButtonAppearance:self.unableButton];
}

- (void)startMotionManager
{
    self.motionManager.deviceMotionUpdateInterval = 0.02;
    
    if (CLLocationManager.headingAvailable == YES && self.hasRun == NO)
        [self.locationManager startUpdatingHeading];
    
    if ([self.motionManager isDeviceMotionAvailable])
    {
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                                toQueue:NSOperationQueue.currentQueue
                                                            withHandler:^(CMDeviceMotion *deviceMotion, NSError *error){
                                                                [self computeSlopeFromGravity:deviceMotion.gravity];
                                                                
                                                                if(error)
                                                                    NSLog(@"%@", error);
                                                            }];
    }
}

- (void)computeSlopeFromGravity:(CMAcceleration)gravity
{
    if (self.calibrationOption == SLOPE_STABILITY)
    {
        self.promptLabel.text = @"Verifying Stability";
        self.progressView.progress = 0.0;
        
        if (self.counter == SHORT_COUNT)
        {
            self.counter = 0;
            
            if (self.yRange < 0.0005 && self.xRange < 0.0005)
                self.calibrationOption = SLOPE_BEGIN;
            
            else
            {
                self.maxX = self.maxY = -1.0;
                self.minX = self.minY = 1.0;
                self.xRange = self.yRange = 0.0;
            }
        }
        
        else
        {
            self.maxX = max(self.maxX, gravity.x);
            self.minX = min(self.minX, gravity.x);
            self.maxY = max(self.maxY, gravity.y);
            self.minY = min(self.minY, gravity.y);
            self.xRange = (self.maxX - self.minX);
            self.yRange = (self.maxY - self.minY);
            self.counter++;
        }
    }
    
    else if (self.calibrationOption == SLOPE_BEGIN)
    {
        self.promptLabel.text = @"Slope measurement in progress.\nPlease keep iPad stable.";
        
        if (self.counter == LONG_COUNT)
        {
            [self.motionManager stopDeviceMotionUpdates];
            
            if (self.hasRun == YES)
            {
                self.x2 = (self.sumX / LONG_COUNT);
                self.y2 = (self.sumY / LONG_COUNT);
                
                self.x1 -= ((self.x1 + self.x2) / 2.0);
                self.y1 -= ((self.y1 + self.y2) / 2.0);
                
                self.frontSlope = (100.0 * sin(-atan2(self.y1, sqrt(pow(self.x1, 2) + pow(self.z, 2)))));
                self.sideSlope = (100.0 * sin(atan2(self.x1, sqrt(pow(self.y1, 2) + pow(self.z, 2)))));
                self.maxSlope = ComputeMaxSlope(self.frontSlope, self.sideSlope);
                
                [self slopeMeasurementComplete];
            }
            
            else
            {
                [self.locationManager stopUpdatingHeading];
                self.avgHeading = (self.sumHeading / self.headingCounter);
                
                self.x1 = (self.sumX / LONG_COUNT);
                self.y1 = (self.sumY / LONG_COUNT);
                self.z = (self.sumZ / LONG_COUNT);
                self.hasRun = YES;
                
                self.frontSlope = (100.0 * sin(-atan2(self.y1, sqrt(pow(self.x1, 2) + pow(self.z, 2)))));
                self.sideSlope = (100.0 * sin(atan2(self.x1, sqrt(pow(self.y1, 2) + pow(self.z, 2)))));
                self.maxSlope = ComputeMaxSlope(self.frontSlope, self.sideSlope);
                
                if (self.maxSlope < (self.target - self.forceFlip) || (self.maxSlope > (self.target + self.forceFlip)))
                    [self slopeMeasurementComplete];
                
                else
                {
                    self.promptLabel.text = @"Flip the iPad in the opposite direction and tap 'Continue' to calibrate measurement.";
                    
                    [self.startCancelButton setTitle:@"Continue"
                                            forState:UIControlStateNormal];
                    
                    self.counter = 0;
                    self.sumX = self.sumY = 0.0;
                    self.calibrationOption = SLOPE_STABILITY;
                    self.startCancelState = SC_START;
                }
            }
        }
        
        else
        {
            self.sumX += gravity.x;
            self.sumY += gravity.y;
            self.sumZ += gravity.z;
            self.counter++;
            self.progressView.progress = (self.counter / (CGFloat)LONG_COUNT);
        }
    }
}

- (void)slopeMeasurementComplete
{
    self.headingLabel.text = [NSString stringWithFormat:@"Heading = %.02f\u00B0", self.avgHeading];
    self.frontSlopeLabel.text = [NSString stringWithFormat:@"Front Slope = %+.02f%%", self.frontSlope];
    self.sideSlopeLabel.text = [NSString stringWithFormat:@"Side Slope = %+.02f%%", self.sideSlope];
    self.maxSlopeLabel.text = [NSString stringWithFormat:@"Max Slope = %.02f%%", self.maxSlope];
    
    self.promptLabel.text = @"Press 'Done' to continue inventory.";
    
    [self.unableButton setTitle:@"Done"
                       forState:UIControlStateNormal];
    
    self.startCancelButton.hidden = YES;
    self.unableButton.enabled = YES;
    [self updateButtonAppearance:self.unableButton];
    
    self.progressView.hidden = YES;
    self.hasRun = NO;
    
    float slopes[2], heading;
    
    slopes[0] = self.frontSlope;
    slopes[1] = self.sideSlope;
    heading = self.avgHeading;
    
    [self.delegate gssiSlopeViewController:self
                          didMeasureSlopes:slopes
                                   heading:heading];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    self.sumHeading += newHeading.trueHeading;
    self.headingCounter++;
}

@end