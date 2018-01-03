//  RHRecorder.m
//  CCodeLibrary

#import "RHRecorder.h"
@import AVFoundation;
@import CoreLocation;
#import "CRAPI.h"
#import "RHController.h"

@interface RHRecorder () <AVCaptureFileOutputRecordingDelegate,CLLocationManagerDelegate,RHControllerDelegate>

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureMovieFileOutput *output;
@property (nonatomic) NSURL *outputURL;
@property BOOL isRecording;
@property (nonatomic) CLLocationManager *locMgr;
@property RHController *controller;

@end

@implementation RHRecorder

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(resignedActive:)
                                               name:@"didResignActive"
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(becameActive:)
                                               name:@"didBecomeActive"
                                             object:nil];
}

- (void)resignedActive:(id)selector
{
    [self stopSession];
}

- (void)becameActive:(id)selector
{
    [self startSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        _locMgr = CLLocationManager.new;
        _locMgr.delegate = self;
        
        switch (CLLocationManager.authorizationStatus)
        {
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusAuthorizedAlways:
                [_locMgr requestLocation];
                [self setupVideoRecorder];
                break;
            case kCLAuthorizationStatusNotDetermined:
                if ([_locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
                    [_locMgr requestWhenInUseAuthorization];
                
                else
                {
                    NSLog(@"CLLocationManager ERROR: Not able to request authorization.");
                    [self setupVideoRecorder];
                }
                break;
            default:break;
        }
    }
    
    else
    {
        NSLog(@"CLLocationManager ERROR: Location services NOT enabled on this device.");
        [self setupVideoRecorder];
    }
    
    [self startSession];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)startSession
{
    if (![_session isRunning])
        [_session startRunning];
}

- (void)stopSession
{
    [CRAPI.sharedInstance.peerConnect stopAdvertising];
    [_controller stopTimer:NO];
    
    if ([_output isRecording])
        [_output stopRecording];
    
    if ([_session isRunning])
        [_session stopRunning];
    
    _isRecording = NO;
}

- (void)setupVideoRecorder
{
    _isRecording = NO;
    _session = AVCaptureSession.new;
    [_session beginConfiguration];
    
    AVCaptureDevice *vDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (vDevice)
    {
        NSError *error = nil;
        
        AVCaptureDeviceInput *vInput = [AVCaptureDeviceInput deviceInputWithDevice:vDevice
                                                                             error:&error];
        
        if (vInput && [_session canAddInput:vInput])
        {
            [_session addInput:vInput];
            
            AVCaptureDevice *aDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            
            if (aDevice)
            {
                AVCaptureDeviceInput *aInput = [AVCaptureDeviceInput deviceInputWithDevice:aDevice
                                                                                     error:&error];
                
                if (aInput && [_session canAddInput:aInput])
                {
                    [_session addInput:aInput];
                    
                    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
                    
                    if (preview)
                    {
                        preview.frame = self.view.bounds;
                        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        [self.view.layer addSublayer:preview];
                        
                        _output = AVCaptureMovieFileOutput.new;
                        _output.minFreeDiskSpaceLimit = 1048576;
                        
                        if (_output && [_session canAddOutput:_output])
                        {
                            [_session addOutput:_output];
                            
                            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/output.mov",
                                                    NSTemporaryDirectory()];
                            
                            _outputURL = [NSURL fileURLWithPath:outputPath];
                            
                            AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;
                            
                            if (preview.connection.isVideoOrientationSupported)
                                preview.connection.videoOrientation = orientation;
                            
                            AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
                            
                            if (connection.isVideoOrientationSupported)
                                connection.videoOrientation = orientation;
                            
                            _controller = RHController.new;
                            [_controller showInView:self.view delegate:self];
                        }
                        
                        else {NSLog(@"AVCaptureSession Video Output ERROR: %@", error.localizedDescription);}
                    }
                    
                    else {NSLog(@"AVCaptureSession ERROR: Couldn't create video preview layer.");}
                }
                
                else {NSLog(@"AVCaptureSession Audio Input ERROR: %@", error.localizedDescription);}
            }
            
            else {NSLog(@"AVCaptureSession ERROR: Couldn't create audio device.");}
        }
        
        else {NSLog(@"AVCaptureSession Video Input ERROR: %@", error.localizedDescription);}
    }
    
    else {NSLog(@"AVCaptureSession ERROR: Couldn't create video device.");}
    
    [_session commitConfiguration];
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    if (error)
        {NSLog(@"AVCaptureFileOutput ERROR: %@", error.localizedDescription);}
    
    else if (outputFileURL)
    {
        CRAPI.sharedInstance.peerConnect.fileToSend = outputFileURL;
        CRAPI.sharedInstance.rhVideoURL = outputFileURL;
        [UserDefaults.defaults saveString:outputFileURL.path forKey:@"RHVideoPath"];
        [_controller updateConnectButton];
    }
}

- (void)controllerDidTapPlayRecordButton
{
    if (_isRecording)
    {
        [_controller stopTimer:NO];
        [_output stopRecording];
        _isRecording = NO;
        
        [_controller.playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                                [NSBundle.mainBundle pathForResource:@"VideoRecordIcon"
                                                                              ofType:@"png"]]
                                      forState:UIControlStateNormal];
    }
    
    else
    {
        [_locMgr requestLocation];
        NSFileManager *fileManager = NSFileManager.defaultManager;
        
        if ([fileManager fileExistsAtPath:_outputURL.path])
        {
            NSError *error;
            
            if (![fileManager removeItemAtPath:_outputURL.path error:&error])
                {NSLog(@"NSFileManager ERROR: Couldn't remove previous output video file.");}
        }
        
        [_output startRecordingToOutputFileURL:_outputURL recordingDelegate:self];
        [_controller startTimer];
        _isRecording = YES;
        
        [_controller.playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                                [NSBundle.mainBundle pathForResource:@"VideoStopIcon"
                                                                              ofType:@"png"]]
                                      forState:UIControlStateNormal];
    }
}

- (void)controllerDidTapConnectButton
{
    [CRAPI.sharedInstance.peerConnect startAdvertising];
}

- (void)controllerDidTapReturnButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocationCoordinate2D coordinate = locations.lastObject.coordinate;
    int lat = (int)round(coordinate.latitude * 100000);
    int lon = abs((int)round(coordinate.longitude * 100000));
    NSDate *date = NSDate.date;
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%i_%i_%i.mov",
                            NSTemporaryDirectory(), lat, lon, (int)date.timeIntervalSince1970];
    
    _outputURL = [NSURL fileURLWithPath:outputPath];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"CLLocationManager ERROR: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [_locMgr requestLocation];
        
        if (!_session)
            [self setupVideoRecorder];
    }
}

@end
