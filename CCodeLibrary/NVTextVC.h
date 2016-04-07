//  NVTextVC.h
//  CCodeLibrary

@import UIKit;

@interface NVTextVC : UIViewController

@property (nonatomic) CGFloat minFontSize, maxFontSize;
@property BOOL zoomingEnabled, clampTextViewToText;

- (id)initWithText:(NSString *)text
          fontSize:(CGFloat)fontSize;

CGSize sizeOfString(NSString *string, UIFont *font);

@end