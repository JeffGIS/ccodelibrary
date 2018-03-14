//  HeightCalculator.m
//  CCodeLibrary

#import "HeightCalculator.h"
@import AVFoundation;
@import CoreMotion;

@interface HeightCalculator ()

@property (nonatomic, weak) id<HeightCalculatorDelegate> delegate;
@property (nonatomic) CMMotionManager *motionManager;
@property double distance, height, sumX, sumY, sumZ, firstHeight;
@property BOOL collectData;
@property int counter, count, collectionMode;

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
    UITapGestureRecognizer *tap = UITapGestureRecognizer.new;
    [tap addTarget:self action:@selector(viewTapped)];
    
    [self.view addGestureRecognizer:tap];
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
    _count = 50;
    _counter = _collectionMode = 0;
    _collectData = NO;
    _distance = 10.0;
    
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
    if (_collectData)
    {
        if (_counter == _count)
        {
            _collectData = NO;
            double accelX = (_sumX / _count);
            double accelY = (_sumY / _count);
            double accelZ = (_sumZ / _count);
            
            double denom = sqrt(square(accelX) + square(accelY) + square(accelZ));
            double angleZ = -(acos(accelZ / denom) - M_PI_2);
            double heightZ = (tan(angleZ) * _distance);
            NSLog(@"HEIGHT %d = %f", _collectionMode, heightZ);
            
            if (_collectionMode == 1)
                _firstHeight = heightZ;
            
            else if (_collectionMode == 2)
            {
                _collectionMode = 0;
                _height = fabs(heightZ - _firstHeight);
                NSLog(@"TOTAL HEIGHT = %f", _height);
            }
        }
        
        else if (_counter < _count)
        {
            CMAcceleration acceleration = accelerometerData.acceleration;
            
            _sumX += acceleration.x;
            _sumY += acceleration.y;
            _sumZ += acceleration.z;
            _counter++;
        }
    }
}

- (void)returnButtonTapped
{
    [_motionManager stopAccelerometerUpdates];
    
    if (_delegate && [_delegate respondsToSelector:@selector(heightCalculator:returnedHeight:)])
        [_delegate heightCalculator:self returnedHeight:_height];
}

- (void)viewTapped
{
    if (!_collectData)
    {
        _collectionMode++;
        _counter = _sumX = _sumY = _sumZ = 0;
        _collectData = YES;
    }
}

@end
