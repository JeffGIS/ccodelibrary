//  NVFrontBackPhotoCapture.h
//  CCodeLibrary

@import Foundation;

@class NVFrontBackPhotoCapture;

@protocol NVFrontBackPhotoCaptureDelegate<NSObject>

- (void)frontBackPhotoCaptureDidReturnFrontImage:(UIImage *)frontImage
                                       backImage:(UIImage *)backImage
                                      atLocation:(LLPOINT)location
                                     withHeading:(int) heading
                                     numLocationUpdates:(int)nLocUpdates
                               numHeadingUpdates:(int)nHeadUpdates;

@end

@interface NVFrontBackPhotoCapture : NSObject <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property int nLocationUpdates;
@property int nHeadingUpdates;
@property NSMutableArray * headingUpdates;
@property NSMutableArray * locationUpdates;
@property BOOL wantFrontImage;
+ (instancetype)frontBackPhotoCaptureWithDelegate:(id)delegate
                                      wantHeading:(BOOL)wantHeading;
- (void)takePhotos;

@end
