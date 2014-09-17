//
//  GSSiPopoverView.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/17/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSSiPopoverView : UIView

@property UIView * popover;
@property UIView * fromView;
@property UIActivityIndicatorView *popoverIndicator;
@property UIButton *popoverCancel;
@property UILabel *popoverLabel;
@property BOOL inShowAfter;
@property NSTimer *timer;
@property int showTime;
- (id)initWithView:(UIView*)fromView;
- (void)popoverCancel:(UIButton *)sender;
- (void)show;
- (void)hide;
- (void) showAfter:(float) seconds;


@end
