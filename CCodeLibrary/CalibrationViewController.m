//  CalibrationViewController.m
//  CCodeLibrary

#import "CalibrationViewController.h"

#define CAL_STABILITY 0
#define CAL_BEGIN 1
#define CAL_FLIP 2
#define SHORT_COUNT 50
#define LONG_COUNT 500

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
    CMMotionManager *motionManager = nil;
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
    
    self.returnButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 20.0, 180.0, 60.0)];
    
    [self.returnButton addTarget:self
                          action:@selector(goBack:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.returnButton];
    
    [self setupButton:self.returnButton
                title:@"< Return"
                 font:[UIFont boldSystemFontOfSize:36.0]];
    
    [self startMotionManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateButtonAppearance:self.returnButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
               font:(UIFont *)font
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    button.titleLabel.font = font;
    button.layer.cornerRadius = 10.0;
    button.layer.borderColor = UserDefaults.defaults.green.CGColor;
    button.layer.borderWidth = 6.0;
}

- (void)updateButtonAppearance:(UIButton *)button
{
    if (button.enabled == YES)
    {
        button.backgroundColor = UIColor.whiteColor;
        button.layer.borderColor = UserDefaults.defaults.green.CGColor;
        
        [button setTitleColor:UIColor.blackColor
                     forState:UIControlStateNormal];
    }
    
    else
    {
        button.backgroundColor = UserDefaults.defaults.green;
        button.layer.borderColor = UIColor.grayColor.CGColor;
        
        [button setTitleColor:UIColor.grayColor
                     forState:UIControlStateNormal];
    }
}

- (void)goBack:(UIButton *)button
{
    [self.motionManager stopDeviceMotionUpdates];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
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
    //NSLog(@"x=%f,y=%f,z=%f", gravity.x, gravity.y, gravity.z);
    
    if (self.calibrationOption == CAL_STABILITY)
    {
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
        if (self.counter == LONG_COUNT)
        {
            NSLog(@"%f,%f", (self.sumX / LONG_COUNT), (self.sumY / LONG_COUNT));
        }
        
        else
        {
            self.sumX = self.sumX + gravity.x;
            self.sumY = self.sumY + gravity.y;
            self.counter++;
        }
    }
}

@end