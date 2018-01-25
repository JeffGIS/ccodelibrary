//  RHRecorder.m
//  CCodeLibrary

#import "RHRecorder.h"
@import AVFoundation;
@import CoreLocation;
#import "CRAPI.h"
#import "RHController.h"
#import "NVSpreadsheetVC.h"

@interface RHRecorder () <AVCaptureFileOutputRecordingDelegate,CLLocationManagerDelegate,RHControllerDelegate>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureMovieFileOutput *output;
@property (nonatomic) AVCaptureVideoPreviewLayer *preview;
@property BOOL isRecording, canGetLocation;
@property (nonatomic) CLLocationManager *locMgr;
@property RHController *controller;
@property (nonatomic, copy) NSString *outputDir;
@property (nonatomic) NSMutableString *locations;
@property (nonatomic) NSTimer *locationTimer;
@property int time, propNum;

@end

@implementation RHRecorder

+ (instancetype)recorderWithPropNum:(int)propNum
                           delegate:(id)delegate
{
    RHRecorder *recorder = RHRecorder.new;
    recorder.propNum = propNum;
    recorder.delegate = delegate;
    return recorder;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    return self;
}

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
    
    _canGetLocation = NO;
    _locations = NSMutableString.string;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        _locMgr = CLLocationManager.new;
        _locMgr.delegate = self;
        
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined)
        {
            if ([_locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
                [_locMgr requestWhenInUseAuthorization];
            
            else {NSLog(@"CLLocationManager ERROR: Not able to request authorization.");}
        }
        
        else
            _canGetLocation = YES;
    }
    
    else {NSLog(@"CLLocationManager ERROR: Location services NOT enabled on this device.");}
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
    
    [self setupVideoRecorder];
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
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return !_isRecording;
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
    
    if (_locationTimer.isValid)
        [_locationTimer invalidate];
    
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
                    
                    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
                    
                    if (_preview)
                    {
                        _preview.frame = self.view.bounds;
                        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        [self.view.layer addSublayer:_preview];
                        
                        _output = AVCaptureMovieFileOutput.new;
                        _output.minFreeDiskSpaceLimit = 1048576;
                        
                        if (_output && [_session canAddOutput:_output])
                        {
                            [_session addOutput:_output];
                            _outputDir = [_delegate vidDirForPropNum:_propNum];
                            
                            [NSFileManager.new createDirectoryAtPath:_outputDir
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:&error];
                            
                            if (!error)
                            {
                                [self updateVideoOrientation];
                            }
                            
                            else {NSLog(@"NSFileManager Directory Create ERROR: %@", error.localizedDescription);}
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
    
    _controller = RHController.new;
    [_controller showInView:self.view delegate:self];
}

- (void)updateVideoOrientation
{
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeLeft;
    
    if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft)
        orientation = AVCaptureVideoOrientationLandscapeRight;
    
    if (_preview.connection.isVideoOrientationSupported)
        _preview.connection.videoOrientation = orientation;
    
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection.isVideoOrientationSupported)
        connection.videoOrientation = orientation;
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
        CRAPI.sharedInstance.rhVideoURL = outputFileURL;
        [_controller updateConnectButton];
    }
}

- (void)controllerDidTapPlayRecordButton
{
    if (_isRecording)
    {
        [_controller stopTimer:NO];
        [_output stopRecording];
        
        if (_locationTimer.isValid)
            [_locationTimer invalidate];
        
        _isRecording = NO;
        
        [_controller.playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                                [NSBundle.mainBundle pathForResource:@"VideoRecordIcon"
                                                                              ofType:@"png"]]
                                      forState:UIControlStateNormal];
        
        if (_locations && _locations.length)
        {
            NSError *error = nil;
            NSString *txtPath = [NSString stringWithFormat:@"%@/%d.txt", _outputDir, _time];
            [_locations.copy writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            if (error) {NSLog(@"Locations List write to file ERROR: %@", error.localizedDescription);}
        }
        
        else {NSLog(@"ERROR: Empty Locations List");}
    }
    
    else
    {
        NSFileManager *fm = NSFileManager.defaultManager;
        _time = (int)NSDate.date.timeIntervalSince1970;
        NSString *vidPath = [NSString stringWithFormat:@"%@/%d.mov", _outputDir, _time];
        NSURL *vidURL = [NSURL fileURLWithPath:vidPath isDirectory:NO];
        
        if ([fm fileExistsAtPath:vidURL.path])
        {
            NSError *error = nil;
            
            if (![fm removeItemAtPath:vidURL.path error:&error])
                {NSLog(@"NSFileManager ERROR: Couldn't remove previous output video file.");}
        }
        
        [_output startRecordingToOutputFileURL:vidURL recordingDelegate:self];
        [_controller startTimer];
        _isRecording = YES;
        
        [_controller.playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                                [NSBundle.mainBundle pathForResource:@"VideoStopIcon"
                                                                              ofType:@"png"]]
                                      forState:UIControlStateNormal];
        
        if (_canGetLocation)
        {
            [_locMgr requestLocation];
            
            _locationTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                              target:_locMgr
                                                            selector:@selector(requestLocation)
                                                            userInfo:nil
                                                             repeats:YES];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self performSelector:@selector(updateVideoOrientation) withObject:nil afterDelay:duration];
}

- (void)controllerDidTapConnectButton
{
    CRAPI.sharedInstance.peerConnect.fileToSend = CRAPI.sharedInstance.rhVideoURL;
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
    
    [_locations appendString:[NSString stringWithFormat:@"%f\t%f\t%@\n",
                              (float)coordinate.latitude, (float)coordinate.longitude, _controller.currentTime]];
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
        _canGetLocation = YES;
    }
}

@end
