//  NVTextVC.h
//  CCodeLibrary

@import UIKit;

@interface NVTextVC : UIViewController

@property (nonatomic) CGFloat minFontSize, maxFontSize;
@property BOOL zoomingEnabled, clampTextViewToText;
@property (nonatomic, copy) NSString *redSubstring, *greenSubstring, *blueSubstring;

- (id)initWithText:(NSString *)text
          fontSize:(CGFloat)fontSize;

CGSize sizeOfString(NSString *string, UIFont *font);

@end
