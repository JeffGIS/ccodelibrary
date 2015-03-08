//  GSSiAlertController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class GSSiAlertController;

@protocol GSSiAlertDelegate <NSObject>
@optional

- (void)gssiAlert:(GSSiAlertController *)gssiAlert
clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface GSSiAlertController : NSObject <UIAlertViewDelegate>

@property int option;
@property (nonatomic, weak) id <GSSiAlertDelegate> delegate;

- (id)initWithViewController:(UIViewController *)viewController;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
         otherButtonTitles:(NSArray *)otherButtonTitles
 destructiveButtonPosition:(NSUInteger)destructiveButtonPosition;

@end