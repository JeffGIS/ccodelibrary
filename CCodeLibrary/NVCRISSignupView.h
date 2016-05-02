//  NVCRISSignupView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVCRISSignupView;

@protocol NVCRISSignupViewDelegate <NSObject>

@end

@interface NVCRISSignupView : UIView

+ (instancetype)showSignupViewinView:(UIView *)view
                            delegate:(id)delegate;

@end