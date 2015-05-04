//  NVPhotoViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVPhotoViewController : UIViewController <UIGestureRecognizerDelegate>

+ (NVPhotoViewController *)viewerWithPhotosFromDirectory:(NSString *)directory;

@end