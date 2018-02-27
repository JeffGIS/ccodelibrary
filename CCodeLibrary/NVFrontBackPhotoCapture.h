//  NVFrontBackPhotoCapture.h
//  CCodeLibrary

@import Foundation;

@class NVFrontBackPhotoCapture;

@protocol NVFrontBackPhotoCaptureDelegate<NSObject>

- (void)frontBackPhotoCaptureDidReturnFrontImage:(UIImage *)frontImage
                                       backImage:(UIImage *)backImage;

@end

@interface NVFrontBackPhotoCapture : NSObject

+ (instancetype)frontBackPhotoCaptureWithDelegate:(id)delegate;
- (void)takePhotos;

@end
