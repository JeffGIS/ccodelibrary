//  NVImagePickerController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVImagePickerController : UIImagePickerController

@property BOOL showsTimeStamp;

- (id)initWithDelegate:(id)delegate;

@end