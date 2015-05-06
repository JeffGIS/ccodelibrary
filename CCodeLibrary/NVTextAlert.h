//  NVTextAlert.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVTextAlert;

@protocol NVTextAlertDelegate <NSObject>

- (void)textAlert:(NVTextAlert *)textAlert
    didReturnText:(NSString *)text;

@end

@interface NVTextAlert : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id <NVTextAlertDelegate> delegate;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) NSInteger minimumCharacters;

+ (NVTextAlert *)showTextAlertinView:(UIView *)view
                            delegate:(id)delegate
                               title:(NSString *)title;

- (void)hideTextAlert:(BOOL)animated;

@end