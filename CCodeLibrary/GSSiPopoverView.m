//
//  GSSiPopoverView.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/17/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import "GSSiPopoverView.h"

#define MIN_SHOWTIME 2
@implementation GSSiPopoverView

- (id)initWithView:(UIView*)fromView
{
    CGRect frame = fromView.frame;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *_popoverView = self;
        self.fromView = fromView;
        _popoverView.backgroundColor = UIColor.clearColor;
        
        _popover = [[UIView alloc] initWithFrame:CGRectMake((fromView.frame.size.width / 4.0), (fromView.frame.size.height / 4.0),
                                                            (fromView.frame.size.width / 2.0), (fromView.frame.size.height / 2.0))];
        
        _popover.backgroundColor = [UIColor colorWithWhite:0.0
                                                     alpha:0.8];
        
        _popover.layer.cornerRadius = 20.0;
        
        _popoverIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _popoverIndicator.center = CGPointMake((_popover.frame.size.width / 2.0), (_popover.frame.size.height / 2.0));
        
        _popoverCancel = [[UIButton alloc] initWithFrame:CGRectMake((_popover.frame.size.width * 0.25),
                                                                    (_popover.frame.size.height * 0.75),
                                                                    (_popover.frame.size.width * 0.5),
                                                                    (_popover.frame.size.height * 0.15))];
        
        _popoverCancel.layer.cornerRadius = 10.0;
        _popoverCancel.backgroundColor = UIColor.whiteColor;
        _popoverCancel.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
        
        [_popoverCancel setTitleColor:UIColor.blackColor
                             forState:UIControlStateNormal];
        
        [_popoverCancel setTitle:@"Cancel"
                        forState:UIControlStateNormal];
        
        [_popoverCancel addTarget:self
                           action:@selector(popoverCancel:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        _popoverLabel = [[UILabel alloc] initWithFrame:CGRectMake((_popover.frame.size.width * 0.05),
                                                                  (_popover.frame.size.height * 0.05),
                                                                  (_popover.frame.size.width * 0.9),
                                                                  (_popover.frame.size.height * 0.3))];
        
        _popoverLabel.backgroundColor = UIColor.clearColor;
        _popoverLabel.textColor = UIColor.whiteColor;
        _popoverLabel.font = [UIFont boldSystemFontOfSize:40.0];
        _popoverLabel.numberOfLines = 0;
        _popoverLabel.text = @"Loading Intersection Data";
        _popoverLabel.textAlignment = NSTextAlignmentCenter;
        
        [_popoverView addSubview:_popover];
        [_popover addSubview:_popoverIndicator];
        [_popover addSubview:_popoverCancel];
        [_popover addSubview:_popoverLabel];
    }
    return self;
}
- (void)popoverCancel:(UIButton *)sender
{
    [self removeFromSuperview];
}
- (void)show
{
    [self.fromView addSubview:self];
    [_popoverIndicator startAnimating];
   
}
- (void)hide
{
    [self.timer invalidate];
    if (self.superview != nil)
    {
        int seconds = NSDate.timeIntervalSinceReferenceDate - self.showTime;
        if (seconds < MIN_SHOWTIME)
        {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                          target:self
                                                        selector:@selector(hide)
                                                        userInfo:nil
                                                         repeats:NO];
            
        }
        else
        {
            [_popoverIndicator stopAnimating];
            [self removeFromSuperview];
        }
    }
}

- (void) showAfter:(float) seconds
{
    self.showTime = NSDate.timeIntervalSinceReferenceDate;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                     target:self
                                   selector:@selector(show)
                                   userInfo:nil
                                    repeats:NO];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
