//  HeightCalculator.m
//  CCodeLibrary

#import "HeightCalculator.h"
#import "CRAPI.h"
@import AVFoundation;
@import CoreMotion;

@interface HeightCalculator ()

@property (nonatomic, weak) id<HeightCalculatorDelegate> delegate;
@property (nonatomic) CMMotionManager *motionManager;
@property double sumX, sumY, sumZ, firstHeight;
@property float distance, height;
@property BOOL collectData;
@property int counter, count, collectionMode;
@property (nonatomic) UIButton *startButton;
@property (nonatomic) UILabel *distanceLabel;

@end

@implementation HeightCalculator

+ (instancetype)presentHeightCalculatorInController:(UIViewController *)controller
                                           delegate:(id<HeightCalculatorDelegate>)delegate
{
    HeightCalculator *hc = HeightCalculator.new;
    hc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    hc.delegate = delegate;
    hc.distance = 10.0;
    [controller presentViewController:hc animated:YES completion:nil];
    
    return hc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    [self createPreviewLayer];
    [self createButtonsAndSlider];
    [self createCrosshairs];
    [self startAccelerometerUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)createButtonsAndSlider
{
    CGFloat sizeFactor = 22.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        sizeFactor = 16.0;
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.backgroundColor = UIColor.whiteColor;
    returnButton.titleLabel.numberOfLines = 0;
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:(sizeFactor * 2)];
    [returnButton setTitle:@"R\nE\nT\nU\nR\nN" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    
    [self.view addSubview:returnButton];
    [returnButton constrainTopToAnchor:self.view.topAnchor];
    [returnButton constrainBottomToAnchor:self.view.bottomAnchor];
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor];
    [returnButton constrainWidthToConstant:(sizeFactor * 2.5)];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.translatesAutoresizingMaskIntoConstraints = NO;
    _startButton.backgroundColor = UIColor.whiteColor;
    _startButton.titleLabel.numberOfLines = 0;
    _startButton.titleLabel.font = [UIFont boldSystemFontOfSize:(sizeFactor * 2)];
    [_startButton setTitle:@"T\nA\nP\n\nT\nO\n\nS\nT\nA\nR\nT" forState:UIControlStateNormal];
    [_startButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    
    [self.view addSubview:_startButton];
    [_startButton constrainTopToAnchor:self.view.topAnchor];
    [_startButton constrainBottomToAnchor:self.view.bottomAnchor];
    [_startButton constrainTrailingToAnchor:self.view.trailingAnchor];
    [_startButton constrainWidthToConstant:(sizeFactor * 2.5)];
    
    [_startButton addTarget:self
                     action:@selector(startButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _distanceLabel = UILabel.new;
    _distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _distanceLabel.textColor = UIColor.whiteColor;
    _distanceLabel.font = [UIFont boldSystemFontOfSize:(sizeFactor * 1.6)];
    [self updateDistanceLabel];
    
    [self.view addSubview:_distanceLabel];
    [_distanceLabel constrainCenterXToAnchor:self.view.centerXAnchor];
    [_distanceLabel constrainBottomToAnchor:self.view.bottomAnchor constant:-sizeFactor];
    
    UISlider *distanceSlider = UISlider.new;
    distanceSlider.translatesAutoresizingMaskIntoConstraints = NO;
    distanceSlider.minimumValue = 5.0;
    distanceSlider.maximumValue = 25.0;
    [distanceSlider setValue:_distance animated:NO];
    
    [self.view addSubview:distanceSlider];
    [distanceSlider constrainBottomToAnchor:_distanceLabel.topAnchor constant:-sizeFactor];
    [distanceSlider constrainLeadingToAnchor:returnButton.trailingAnchor constant:sizeFactor];
    [distanceSlider constrainTrailingToAnchor:_startButton.leadingAnchor constant:-sizeFactor];
    
    [distanceSlider addTarget:self
                       action:@selector(sliderValueChanged:)
             forControlEvents:UIControlEventValueChanged];
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
            [CRAPI.sharedInstance playFinalBeep];
            _collectData = NO;
            double accelX = (_sumX / _count);
            double accelY = (_sumY / _count);
            double accelZ = (_sumZ / _count);
            
            double denom = sqrt(square(accelX) + square(accelY) + square(accelZ));
            double angleZ = -(acos(accelZ / denom) - M_PI_2);
            double heightZ = (tan(angleZ) * _distance);
            
            if (_collectionMode == 1)
                _firstHeight = heightZ;
            
            else if (_collectionMode == 2)
            {
                _collectionMode = 0;
                _height = ((roundf(fabs(heightZ - _firstHeight) * 100)) / 100);
                showAlert([NSString stringWithFormat:@"Height = %.2f feet.", _height]);
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

- (void)startButtonTapped
{
    if (!_collectData)
    {
        [CRAPI.sharedInstance playBeep];
        _collectionMode++;
        _counter = _sumX = _sumY = _sumZ = 0;
        _collectData = YES;
    }
}

- (void)sliderValueChanged:(UISlider *)slider
{
    float value = roundf(slider.value * 2);
    _distance = (value / 2);
    [self updateDistanceLabel];
}

- (void)updateDistanceLabel
{
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %.1f feet", _distance];
}

@end
