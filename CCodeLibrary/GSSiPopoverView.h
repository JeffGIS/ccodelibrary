//  GSSiPopoverView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVProgressView.h"
#import "UIView+Constraints.h"
@class GSSiPopoverView;

@protocol GSSiPopoverViewDelegate <NSObject>

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView;

@end

@interface GSSiPopoverView : NVConstrainedView

@property (nonatomic, weak) id <GSSiPopoverViewDelegate> delegate;
@property (nonatomic) UIView *popover;
@property (nonatomic) UIView *parentView;
@property (nonatomic) NVProgressView *progressView;
@property (nonatomic) UIButton *popoverCancel;
@property (nonatomic) UILabel *popoverLabel, *progressLabel;
@property BOOL inShowAfter, hideAtCancel;
@property BOOL useConstraints;
@property (nonatomic) int showTime;
@property (nonatomic, copy) NSString *title, *cancelButtonTitle;
@property (nonatomic, copy) NSString *identifier;

- (id)initWithView:(UIView *)fromView;
- (void)popoverCancel:(UIButton *)sender;

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString *)title;

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString *)title
        andButton:(NSString *)button;

- (void)updateProgress:(CGFloat)progress;
- (void)show;
- (void)hide;

@end
