//  NVTextViewAlert.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVTextViewAlert;

@protocol NVTextViewAlertDelegate <NSObject>

- (void)textViewAlert:(NVTextViewAlert *)textViewAlert
        didReturnText:(NSString *)text;

- (void)textViewAlertDidCancel:(NVTextViewAlert *)textViewAlert;

@end

@interface NVTextViewAlert : UIView

+ (instancetype)showTextViewAlertinView:(UIView *)view
                               delegate:(id)delegate
                                  title:(NSString *)title
                                   text:(NSString *)text;

- (void)hideTextViewAlert:(BOOL)animated;

@end