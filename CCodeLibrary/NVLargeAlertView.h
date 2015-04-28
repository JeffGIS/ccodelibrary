//  NVLargeAlertView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NVLargeAlertIndex)
{
    NVLargeAlertIndexTopButton,
    NVLargeAlertIndexBottomButton,
    NVLargeAlertIndexNone,
};

@class NVLargeAlertView;

@protocol NVLargeAlertViewDelegate <NSObject>

- (void)largeAlertView:(NVLargeAlertView *)largeAlertView
   didTapButtonAtIndex:(NVLargeAlertIndex)buttonIndex;

@end

@interface NVLargeAlertView : UIView

@property (nonatomic, weak) id <NVLargeAlertViewDelegate> delegate;

+ (NVLargeAlertView *)showLargeAlertViewinView:(UIView *)view
                                      delegate:(id)delegate
                                         title:(NSString *)title
                                 topButtonText:(NSString *)topButtontext
                              bottomButtonText:(NSString *)bottomButtonText
                              destructiveIndex:(NVLargeAlertIndex)destructiveIndex;

- (void)hideLargeAlertView:(BOOL)animated;

@end