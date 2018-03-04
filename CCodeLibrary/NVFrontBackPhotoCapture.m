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

@end

@implementation NVFrontBackPhotoCapture

+ (instancetype)frontBackPhotoCaptureWithDelegate:(id)delegate
{
    NVFrontBackPhotoCapture *capture = NVFrontBackPhotoCapture.new;
    capture.backImageIsTaken = NO;
    capture.delegate = delegate;

    return capture;
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
    
    if (error) {NSLog(@"AVCaptureDeviceInput ERROR: %@", error.localizedDescription);}
    
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
             if (error) {NSLog(@"AVCaptureStillImageOutput ERROR: %@", error.localizedDescription);}
             
             else
             {
                 NSData *imageData =  [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 UIImage *image = [[UIImage alloc]initWithData:imageData];
                 
                 if (_backImageIsTaken)
                 {
                     _frontImage = image;
                     [_session stopRunning];
                     _session = nil;
                     
                     if (_delegate && [_delegate respondsToSelector:@selector
                                       (frontBackPhotoCaptureDidReturnFrontImage:backImage:)])
                     {
                         [_delegate frontBackPhotoCaptureDidReturnFrontImage:_frontImage
                                                                   backImage:_backImage];
                     }
                     
                 }
                 
                 else
                 {
                     _backImageIsTaken = YES;
                     _backImage = image;
                     [_session stopRunning];
                     _session = nil;
                     [self takePhotos];
                 }
             }
         }];
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
