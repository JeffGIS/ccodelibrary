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
@property (nonatomic, copy) NSString *identifier;
@property int ident;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIColor *buttonBorderColor;
@property (nonatomic, copy) NSArray *buttonIdentifiers;
@property (nonatomic, copy) NSArray *buttonTextArray;

+ (instancetype)showLargeAlertViewinView:(UIView *)view
                                delegate:(id)delegate
                                   title:(NSString *)title
                         buttonTextArray:(NSArray *)buttonTextArray
                        destructiveIndex:(NSUInteger)destructiveIndex;//1-indexed (use '0' if none)

- (void)hideLargeAlertView:(BOOL)animated;
- (void)showTabBar;
- (void)updateTitle:(NSString *)text;


@end
