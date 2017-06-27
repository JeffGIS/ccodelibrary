//  NVTextAlert.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVTextAlert;

@protocol NVTextAlertDelegate <NSObject>

- (void)textAlert:(NVTextAlert *)textAlert
    didReturnText:(NSString *)text;

@optional
- (void)textField:(UITextField *)textField
changeCharactersInRange:(NSRange)range
replacementString:(NSString *)string;

@end

@interface NVTextAlert : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id <NVTextAlertDelegate> delegate;
@property UIKeyboardType keyboardType;
@property UITextAutocapitalizationType capitalizationType;
@property NSInteger minimumCharacters;
@property (nonatomic, copy) NSString *text;
@property BOOL blockWhiteSpace, useCustomFormat;

+ (NVTextAlert *)showTextAlertinView:(UIView *)view
                            delegate:(id)delegate
                               title:(NSString *)title;

- (void)hideTextAlert:(BOOL)animated;
- (void)willRotateWithDuration:(NSTimeInterval)duration;

@end
