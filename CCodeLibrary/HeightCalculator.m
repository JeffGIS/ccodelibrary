//  HeightCalculator.m
//  CCodeLibrary

#import "HeightCalculator.h"
@import AVFoundation;
@import CoreMotion;

@interface HeightCalculator ()

@property (nonatomic, weak) id<HeightCalculatorDelegate> delegate;
@property (nonatomic) CMMotionManager *motionManager;
@property double height;

@end

@implementation HeightCalculator

+ (instancetype)presentHeightCalculatorInController:(UIViewController *)controller
                                           delegate:(id<HeightCalculatorDelegate>)delegate
{
    HeightCalculator *hc = HeightCalculator.new;
    hc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    hc.delegate = delegate;
    [controller presentViewController:hc animated:YES completion:nil];
    
    return hc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    [self createPreviewLayer];
    [self createButtons];
    [self createCrosshairs];
    [self startAccelerometerUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)createPreviewLayer
{
    AVCaptureSession *session = AVCaptureSession.new;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    
    [session addInput:input];
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.frame = self.view.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:preview];
    [session startRunning];
}

- (void)createButtons
{
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.backgroundColor = UIColor.clearColor;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    
    else
        returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    
    returnButton.titleLabel.layer.shadowColor = UIColor.blackColor.CGColor;
    returnButton.titleLabel.layer.shadowOpacity = 1.0;
    returnButton.titleLabel.layer.shadowRadius = 4.0;
    returnButton.titleLabel.layer.shadowOffset = CGSizeZero;
    [returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [self.view addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:20.0];
    [returnButton constrainTopToAnchor:self.view.topAnchor constant:10.0];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)createCrosshairs
{
    UIImage *crosshairs = [UIImage imageWithContentsOfFile:
                           [NSBundle.mainBundle pathForResource:@"newCrosshairs"
                                                         ofType:@"png"]];
    
    UIImageView *crosshairsView = UIImageView.new;
    crosshairsView.translatesAutoresizingMaskIntoConstraints = NO;
    crosshairsView.image = crosshairs;
    
    [self.view addSubview:crosshairsView];
    [crosshairsView constrainCenterXToAnchor:self.view.centerXAnchor];
    [crosshairsView constrainCenterYToAnchor:self.view.centerYAnchor];
}

- (void)startAccelerometerUpdates
{
    _motionManager = CMMotionManager.new;
    _motionManager.accelerometerUpdateInterval = 0.02;
    typedef void (^CMAccelerometerHandler)(CMAccelerometerData *accelerometerData, NSError *error);
    
    if (_motionManager.isAccelerometerAvailable)
    {
        [_motionManager startAccelerometerUpdatesToQueue:NSOperationQueue.currentQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                                 [self computeSlopeFromAccelerometer:accelerometerData];
                                                 
                                                 if(error)
                                                     NSLog(@"CMMotionManager ERROR: %@", error.localizedDescription);
                                             }];
    }
    
    else {NSLog(@"CMMotionManager ERROR: No Accelerometer Data Available.");}
}

- (void)computeSlopeFromAccelerometer:(CMAccelerometerData *)accelerometerData
{
    CMAcceleration accel = accelerometerData.acceleration;
    
    double denom = sqrt(square(accel.x) + square(accel.y) + square(accel.z));
    double angleX = ((acos(accel.x / denom)) * RADtoDEG);
    double angleY = ((acos(accel.y / denom)) * RADtoDEG);
    double angleZ = ((acos(accel.z / denom)) * RADtoDEG);
    NSLog(@"%f, %f, %f", angleX, angleY, angleZ);
}

- (void)returnButtonTapped
{
    [_motionManager stopAccelerometerUpdates];
    
    if (_delegate && [_delegate respondsToSelector:@selector(heightCalculator:returnedHeight:)])
        [_delegate heightCalculator:self returnedHeight:_height];
}

@end
