//  NVKeyboard.h
//  CCodeLibrary

@import UIKit;

@class NVKeyboard;

@protocol NVKeyboardDelegate <NSObject>

@end

@interface NVKeyboardButton : UIButton

@end

@interface NVKeyboard : UIView

@property (nonatomic) UIImage *blackKeyboard, *whiteKeyboard;
@property (nonatomic) UIImage *blackUpArrow, *whiteUpArrow;
@property (nonatomic) UIImage *blackBackspace, *whiteBackspace;

+ (instancetype)showKeyboardInView:(UIView *)view
                          delegate:(id)delegate;

- (void)hide;

@end
