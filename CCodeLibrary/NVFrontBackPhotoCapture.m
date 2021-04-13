//  NVFrontBackPhotoCapture.m
//  CCodeLibrary

#import "NVFrontBackPhotoCapture.h"
@import AVFoundation;
@import VideoToolbox;

@interface NVFrontBackPhotoCapture ()

@property (nonatomic, weak) id<NVFrontBackPhotoCaptureDelegate> delegate;
@property (nonatomic) UIImage *frontImage, *backImage;
@property BOOL backImageIsTaken;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureStillImageOutput *output;
@property (nonatomic) CLLocation *currentLocation;
@property int currentHeading;

@end

@implementation NVFrontBackPhotoCapture

+ (instancetype)frontBackPhotoCaptureWithDelegate:(id)delegate
                                      wantHeading:(BOOL)wantHeading
{
    NVFrontBackPhotoCapture *capture = NVFrontBackPhotoCapture.new;
    capture.backImageIsTaken = NO;
    capture.wantFrontImage = YES;
    capture.delegate = delegate;
    capture.headingUpdates = NSMutableArray.new;
    capture.locationUpdates = NSMutableArray.new;
    if (wantHeading)
    {
        capture.locationManager = CLLocationManager.new;
        capture.locationManager.headingFilter = kCLHeadingFilterNone;
        capture.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        capture.locationManager.delegate = capture;
        if (CLLocationManager.locationServicesEnabled)
            [capture.locationManager startUpdatingLocation];
        
        if (CLLocationManager.headingAvailable)
            [capture.locationManager startUpdatingHeading];
    }
    return capture;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)heading
{
    _currentHeading = heading.trueHeading;
    NSNumber * head = [NSNumber numberWithInt:_currentHeading];
    [_headingUpdates addObject:head];
    _nHeadingUpdates++;
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    for (CLLocation * loc in locations)
    {
        _currentLocation = loc;
        [_locationUpdates addObject:_currentLocation];
        _nLocationUpdates++;
    }
    return;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    return;
}
-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    return;
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    return;
}
- (void)takePhotos
{
    _session = AVCaptureSession.new;
    [_session beginConfiguration];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *device = nil;
    
    if (_backImageIsTaken)
        device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    
    else
        device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                   error:&error];
    
    if (error)
    {
        NSLog(@"AVCaptureDeviceInput ERROR: %@", error.localizedDescription);
        showAlert(error.localizedDescription);
    }
    
    else
    {
        if ([_session canAddInput:input])
            [_session addInput:input];
        
        _output = AVCaptureStillImageOutput.new;
        _output.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        
        if ([_session canAddOutput:_output])
            [_session addOutput:_output];
        
        [_session commitConfiguration];
        [_session startRunning];
        [self performSelector:@selector(takeThePhoto) withObject:nil afterDelay:0.5];
    }
}

- (void)takeThePhoto
{
    AVCaptureConnection *connection =  [_output connectionWithMediaType:AVMediaTypeVideo];
    if (connection.supportsVideoOrientation)
    {
        connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    if (connection && connection.enabled && connection.active)
    {
        [_output captureStillImageAsynchronouslyFromConnection:connection
                                            completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
         {
             if (error)
             {
                 NSLog(@"AVCaptureStillImageOutput ERROR: %@", error.localizedDescription);
             }
         
             else
             {
                 NSData *imageData =  [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 UIImage *image = [[UIImage alloc]initWithData:imageData];
                 
                 if (self.backImageIsTaken)
                 {
                     self.frontImage = image;
                     [self.session stopRunning];
                     self.session = nil;
                     [self endCapture];
                 }
                 
                 else
                 {
                     self.backImageIsTaken = YES;
                     self.backImage = image;
                     [self.session stopRunning];
                     self.session = nil;
                     if (self.wantFrontImage)
                         [self takePhotos];
                     else
                         [self endCapture];

                 }
             }
         }];
    }
}

-(int) computeCurrentHeading
{
    int rtn = -1;
    if (_nHeadingUpdates >0)
    {
        double AZ1, AZ2;
        double maxDiff = 0;
        NSNumber *az1 = _headingUpdates[_nHeadingUpdates/2];
        AZ1 = DEGtoRAD * az1.doubleValue;
        for (NSNumber * az in _headingUpdates)
        {
            AZ2 = DEGtoRAD * az.doubleValue;
            double azDiff = DeltaAZD (AZ1, AZ2);
            maxDiff = max (maxDiff,azDiff);
        }
        rtn = AZ1 * RADtoDEG;
    }
    return rtn;
}
-(LLPOINT) computeCurrentLocation
{
    LLPOINT rtn = {0,0};
    LLPOINT curloc = {_currentLocation.coordinate.longitude,_currentLocation.coordinate.latitude};
    if (_nLocationUpdates > 0)
    {
        double latTot = 0;
        double lonTot = 0;
        for (CLLocation * loc in _locationUpdates)
        {
            latTot += loc.coordinate.latitude;
            lonTot += loc.coordinate.longitude;
        }
        rtn.lat = latTot / _nLocationUpdates;
        rtn.lon = lonTot / _nLocationUpdates;
    }
    return rtn;
}
- (void) endCapture
{
    LLPOINT curloc = [self computeCurrentLocation];
    int currentHeading = [self computeCurrentHeading];
    if (_delegate && [_delegate respondsToSelector:@selector
                      (frontBackPhotoCaptureDidReturnFrontImage:backImage:atLocation:withHeading:
                       numLocationUpdates:numHeadingUpdates:)])
    {
        [_delegate frontBackPhotoCaptureDidReturnFrontImage:_frontImage
                                                  backImage:_backImage
                                                 atLocation:curloc
                                                withHeading:_currentHeading
                                         numLocationUpdates:_nLocationUpdates
                                          numHeadingUpdates:_nHeadingUpdates];
        
    }
    if (_locationManager)
    {
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _locationManager = nil;
    }

}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
            return device;
    }
    
    return nil;
}

@end
