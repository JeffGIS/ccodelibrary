//  NVFrontBackPhotoCapture.h
//  CCodeLibrary

@import Foundation;

@class NVFrontBackPhotoCapture;

@protocol NVFrontBackPhotoCaptureDelegate<NSObject>

- (void)frontBackPhotoCaptureDidReturnFrontImage:(UIImage *)frontImage
                                       backImage:(UIImage *)backImage
                                      atLocation:(CLLocation*)location
                                     withHeading:(int) heading;

@end

@interface NVFrontBackPhotoCapture : NSObject <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;

+ (instancetype)frontBackPhotoCaptureWithDelegate:(id)delegate;
- (void)takePhotos;

@end
