//  NVSecretAlertView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVSecretAlertView : UIView

+ (NVSecretAlertView *)showSecretAlertViewinView:(UIView *)view
                                           title:(NSString *)title
                                     deviceNames:(NSArray *)deviceNames;

@end
