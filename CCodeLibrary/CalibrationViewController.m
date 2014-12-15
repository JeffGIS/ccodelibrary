//  CalibrationViewController.m
//  CCodeLibrary

#import "CalibrationViewController.h"

#define CAL_STABILITY 0
#define CAL_BEGIN 1
#define SHORT_COUNT 50
#define LONG_COUNT 500
#define SC_START 0
#define SC_CANCEL 1

@interface CalibrationViewController ()

@end

@implementation CalibrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self)
    {
        
    }
    
    return self;
}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager;
    id appDelegate = UIApplication.sharedApplication.delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)])
        motionManager = [appDelegate motionManager];
    
    return motionManager;
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
    self.calibrationOption = CAL_STABILITY;
    self.maxX = self.maxY = -1.0;
    self.minX = self.minY = 1.0;
    self.xRange = self.yRange = 0.0;
    self.sumX = self.sumY = 0.0;
    self.counter = 0;
    self.startCancelState = SC_START;
    self.hasRun = NO;
    self.xAdj = [SharedDefaults.defaults CGFloatForKey:@"XAdj"];
    self.yAdj = [SharedDefaults.defaults CGFloatForKey:@"YAdj"];
    
    [self setupTitleLabel];
    [self setupReturnButton];
    [self setupStartCancelButton];
    [self setupProgressView];
    [self setupProgressLabel];
    [self setupResultsLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupTitleLabel
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(224.0, 20.0, 320.0, 60.0)];
    [self.view addSubview:self.titleLabel];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.text = @"Calibration";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:60.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setupReturnButton
{
    self.returnButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 20.0, 180.0, 60.0)];
    
    [self.returnButton addTarget:self
                          action:@selector(goBack:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.returnButton];
    
    [self setupButton:self.returnButton
                title:@"< Return"
                 font:[UIFont boldSystemFontOfSize:36.0]];
}

- (void)setupStartCancelButton
{
    self.startCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(144.0, 840.0, 480.0, 90.0)];
    
    [self.startCancelButton addTarget:self
                               action:@selector(startCancel:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.startCancelButton];
    
    [self setupButton:self.startCancelButton
                title:@"Start Calibration"
                 font:[UIFont boldSystemFontOfSize:48.0]];
}

- (void)setupProgressView
{
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(60.0, 140.0, 648.0, 9.0)];
    self.progressView.progressTintColor = UIColor.whiteColor;
    self.progressView.trackTintColor = UIColor.blackColor;
    self.progressView.progress = 0.0;
    [self.view addSubview:self.progressView];
}

- (void)setupProgressLabel
{
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 180.0, 648.0, 260.0)];
    [self.view addSubview:self.progressLabel];
    self.progressLabel.textColor = UIColor.whiteColor;
    self.progressLabel.font = [UIFont boldSystemFontOfSize:48.0];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.numberOfLines = 0;
}

- (void)setupResultsLabel
{
    self.resultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 480.0, 648.0, 180.0)];
    [self.view addSubview:self.resultsLabel];
    self.resultsLabel.textColor = UIColor.whiteColor;
    self.resultsLabel.font = [UIFont boldSystemFontOfSize:48.0];
    self.resultsLabel.textAlignment = NSTextAlignmentCenter;
    self.resultsLabel.numberOfLines = 0;
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
               font:(UIFont *)font
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    button.titleLabel.font = font;
    button.layer.cornerRadius = 10.0;
    button.layer.borderColor = UserDefaults.defaults.green.CGColor;
    button.layer.borderWidth = 6.0;
    button.backgroundColor = UIColor.whiteColor;
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
        
        [self.startCancelButton setTitle:@"Cancel Calibration"
                                forState:UIControlStateNormal];
    }
    
    else if (self.startCancelState == SC_CANCEL)
    {
        [self.motionManager stopDeviceMotionUpdates];
        self.startCancelState = SC_START;
        
        [self.startCancelButton setTitle:@"Start Calibration"
                                forState:UIControlStateNormal];
    }
}

- (void)startMotionManager
{
    self.motionManager.deviceMotionUpdateInterval = 0.02;
    
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
    if (self.calibrationOption == CAL_STABILITY)
    {
        self.progressLabel.text = @"Verifying Stability";
        self.progressView.progress = 0.0;
        
        if (self.counter == SHORT_COUNT)
        {
            self.counter = 0;
            
            if (self.yRange < 0.0005 && self.xRange < 0.0005)
                self.calibrationOption = CAL_BEGIN;
            
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
    
    else if (self.calibrationOption == CAL_BEGIN)
    {
        self.progressLabel.text = @"Running Calibration";
        
        if (self.counter == LONG_COUNT)
        {
            [self.motionManager stopDeviceMotionUpdates];
            
            if (self.hasRun)
            {
                self.x2 = (self.sumX - (self.xAdj * LONG_COUNT)) / LONG_COUNT;
                self.y2 = (self.sumY - (self.yAdj * LONG_COUNT)) / LONG_COUNT;
                CGFloat zSlope = (self.sumZ / LONG_COUNT);
                CGFloat xError = ((self.x1 + self.x2) / 2.0);
                CGFloat yError = ((self.y1 + self.y2) / 2.0);
                
                CGFloat frontSlope1 = (100.0 * sin(-atan2(self.y1, sqrt(pow(self.x1, 2) + pow(zSlope, 2)))));
                CGFloat sideSlope1 = (100.0 * sin(atan2(self.x1, sqrt(pow(self.y1, 2) + pow(zSlope, 2)))));
                CGFloat frontSlope2 = (100.0 * sin(-atan2(self.y2, sqrt(pow(self.x2, 2) + pow(zSlope, 2)))));
                CGFloat sideSlope2 = (100.0 * sin(atan2(self.x2, sqrt(pow(self.y2, 2) + pow(zSlope, 2)))));
             
                self.progressLabel.text = [NSString stringWithFormat:
                                           @"Front Slope (1) = %+.2f%%\nSide Slope (1) = %+.2f%%\nFront Slope (2) = %+.2f%%\nSide Slope (2) = %+.2f%%",
                                           frontSlope1, sideSlope1, frontSlope2, sideSlope2];
                
                CGFloat frontSlopeError = (100.0 * sin(-atan2(yError, sqrt(pow(xError, 2) + pow(zSlope, 2)))));
                CGFloat sideSlopeError = (100.0 * sin(atan2(xError, sqrt(pow(yError, 2) + pow(zSlope, 2)))));
                
                self.resultsLabel.text = [NSString stringWithFormat:@"Front Slope Error = %+.2f%%\nSide Slope Error = %+.2f%%",
                                          frontSlopeError, sideSlopeError];
                
                self.xAdj += xError;
                self.yAdj += yError;
                
                [SharedDefaults.defaults saveCGFloat:self.xAdj
                                              forKey:@"XAdj"];
                
                [SharedDefaults.defaults saveCGFloat:self.yAdj
                                              forKey:@"YAdj"];
                
                self.hasRun = NO;
            }
            
            else
            {
                self.x1 = (self.sumX - (self.xAdj * LONG_COUNT)) / LONG_COUNT;
                self.y1 = (self.sumY - (self.yAdj * LONG_COUNT)) / LONG_COUNT;
                CGFloat zSlope = (self.sumZ / LONG_COUNT);
                
                CGFloat frontSlope = (100.0 * sin(-atan2(self.y1, sqrt(pow(self.x1, 2) + pow(zSlope, 2)))));
                CGFloat sideSlope = (100.0 * sin(atan2(self.x1, sqrt(pow(self.y1, 2) + pow(zSlope, 2)))));
                
                self.progressLabel.text = [NSString stringWithFormat:@"Front Slope (1) = %+.2f%%\nSide Slope (1) = %+.2f%%",
                                           frontSlope, sideSlope];
                
                self.hasRun = YES;
            }
            
            self.counter = 0;
            self.sumX = self.sumY = 0.0;
            self.calibrationOption = CAL_STABILITY;
            self.startCancelState = SC_START;
            
            [self.startCancelButton setTitle:@"Continue Calibration"
                                    forState:UIControlStateNormal];
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

@end