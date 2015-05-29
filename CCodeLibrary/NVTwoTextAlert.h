//  NVTwoTextAlert.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVTwoTextAlert;

@protocol NVTwoTextAlertDelegate <NSObject>

- (void)twoTextAlert:(NVTwoTextAlert *)twoTextAlert
    didReturnTopText:(NSString *)topText
          bottomText:(NSString *)bottomText;

@end

@interface NVTwoTextAlert : UIView  <UITextFieldDelegate>

@property (nonatomic, weak) id <NVTwoTextAlertDelegate> delegate;
@property (nonatomic) UIKeyboardType topTextKeyboardType, bottomTextKeyboardType;
@property (nonatomic) NSInteger minimumCharacters;

+ (NVTwoTextAlert *)showTwoTextAlertInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                            topPlaceholder:(NSString *)topPlaceholder
                         bottomPlaceholder:(NSString *)bottomPlaceholder;

- (void)hideTwoTextAlert:(BOOL)animated;

@end