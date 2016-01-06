//  NVAlertView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVAlertView;

@protocol NVAlertViewDelegate <NSObject>

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface NVAlertView : UIView

@property (nonatomic, weak) id <NVAlertViewDelegate> delegate;
@property (nonatomic) NSString *identifier;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIColor *buttonBorderColor;

+ (NVAlertView *)showLargeAlertViewinView:(UIView *)view
                                 delegate:(id)delegate
                                    title:(NSString *)title
                          buttonTextArray:(NSArray *)buttonTextArray
                         destructiveIndex:(NSUInteger)destructiveIndex;//1-indexed (use '0' if none)

- (void)hideLargeAlertView:(BOOL)animated;
- (void)willRotateWithDuration:(NSTimeInterval)duration;

@end