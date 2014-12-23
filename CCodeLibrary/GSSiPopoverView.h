//  GSSiPopoverView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class GSSiPopoverView;

@protocol GSSiPopoverViewDelegate <NSObject>

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView;

@end

@interface GSSiPopoverView : UIView

@property id delegate;
@property UIView *popover;
@property UIView *fromView;
@property (nonatomic) UIProgressView *progressView;
@property UIButton *popoverCancel;
@property UILabel *popoverLabel;
@property BOOL inShowAfter;
@property NSTimer *timer;
@property int showTime;
@property NSString *title;

- (id)initWithView:(UIView *)fromView;
- (void)popoverCancel:(UIButton *)sender;

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString*)title;

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString *)title
        andButton:(NSString *)button;

- (void)updateProgress:(CGFloat)progress;
- (void)hide;

@end