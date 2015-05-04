//  NVPhotoViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVPhotoViewController : UIViewController

+ (NVPhotoViewController *)viewerWithPhotosFromDirectory:(NSString *)directory;

@end