//  NVCRISSignupView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVCRISSignupView;

@protocol NVCRISSignupViewDelegate <NSObject>

- (void)signupView:(NVCRISSignupView *)signupView
     didReturnName:(NSString *)name
      organization:(NSString *)organization
             phone:(NSString *)phone
             email:(NSString *)email;

- (void)signupView:(NVCRISSignupView *)signupView
didReturnUserNumber:(NSString *)userNumber;

@end

@interface NVCRISSignupView : UIView

+ (instancetype)showSignupViewinView:(UIView *)view
                            delegate:(id)delegate;

- (void)hideSignupView:(BOOL)animated;
- (void)presentKeyboard;
- (void)goBack;

@end