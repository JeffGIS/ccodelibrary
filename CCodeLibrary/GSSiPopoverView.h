//  GSSiPopoverView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface GSSiPopoverView : UIView

@property UIView *popover;
@property UIView *fromView;
@property (nonatomic) UIProgressView *progressView;
@property UIButton *popoverCancel;
@property UILabel *popoverLabel;
@property BOOL inShowAfter;
@property NSTimer *timer;
@property int showTime;

- (id)initWithView:(UIView *)fromView;
- (void)popoverCancel:(UIButton *)sender;
- (void)show;
- (void)hide;
- (void)showAfter:(float)seconds;
- (void)updateProgress:(float)progress;

@end