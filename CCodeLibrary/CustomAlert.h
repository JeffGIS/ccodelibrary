//  CustomAlert.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CustomAlert;

@protocol CustomAlertDelegate <NSObject>

- (void)customAlertView:(CustomAlert *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomAlert : UIView
{
    id delegate;
    UIView *alertView;
}

@property id delegate;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)AlertDelegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle;

- (void)showInView:(UIView*)view;

@end