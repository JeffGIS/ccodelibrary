//  NVAlertView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVAlertView;

@protocol NVAlertViewDelegate <NSObject>

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSUInteger)buttonIndex;

@end

@interface NVAlertView : UIView

@property (nonatomic, weak) id <NVAlertViewDelegate> delegate;

+ (NVAlertView *)showLargeAlertViewinView:(UIView *)view
                                 delegate:(id)delegate
                                    title:(NSString *)title
                          buttonTextArray:(NSArray *)buttonTextArray
                         destructiveIndex:(NSUInteger)destructiveIndex;

- (void)hideLargeAlertView:(BOOL)animated;

@end