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
@property NSString *title;

- (id)initWithView:(UIView *)fromView;
- (void)popoverCancel:(UIButton *)sender;
- (void)showAfter:(float)seconds
        withTitle:(NSString*)title;
- (void)showAfter:(float)seconds
        withTitle:(NSString *)title
        andButton:(NSString *)button;
- (void)updateProgress:(float)progress;
- (void)hide;

@end