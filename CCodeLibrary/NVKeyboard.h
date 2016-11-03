//  NVKeyboard.h
//  CCodeLibrary

@import UIKit;

@class NVKeyboard;

@protocol NVKeyboardDelegate <NSObject>

@end

@interface NVKeyboardButton : UIButton

@end

@interface NVKeyboard : UIView

+ (instancetype)showKeyboardInView:(UIView *)view
                          delegate:(id)delegate;

- (void)hide;

@end
