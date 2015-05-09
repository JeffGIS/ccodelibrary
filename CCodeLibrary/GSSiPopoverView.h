//  GSSiPopoverView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVProgressView.h"

@class GSSiPopoverView;

@protocol GSSiPopoverViewDelegate <NSObject>

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView;

@end

@interface GSSiPopoverView : UIView

@property (nonatomic, weak) id <GSSiPopoverViewDelegate> delegate;
@property (nonatomic) UIView *popover;
@property (nonatomic) UIView *fromView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UIButton *popoverCancel;
@property (nonatomic) UILabel *popoverLabel;
@property (nonatomic) BOOL inShowAfter;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) int showTime;
@property (nonatomic) NSString *title;

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