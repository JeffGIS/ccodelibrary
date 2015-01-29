//  GSSiPopoverView.m
//  CCodeLibrary

#import "GSSiPopoverView.h"
#import "FTPDataPull.h"

#define MIN_SHOWTIME 2

@interface GSSiPopoverView ()

@property (nonatomic) UIFont *font;

@end

@implementation GSSiPopoverView


- (id)initWithView:(UIView *)fromView
{
    CGRect frame = fromView.frame;
    self = [super initWithFrame:frame];
    
    if (self)
    {
        UIView *popoverView = self;
        self.fromView = fromView;
        popoverView.backgroundColor = UIColor.clearColor;
        _font = [UIFont boldSystemFontOfSize:40.0];
        
        _popover = [[UIView alloc] initWithFrame:CGRectMake((fromView.frame.size.width / 4.0), (fromView.frame.size.height / 4.0),
                                                            (fromView.frame.size.width / 2.0), (fromView.frame.size.height / 2.0))];
        
        _popover.backgroundColor = [UIColor colorWithRed:0.0
                                                   green:0.0
                                                    blue:0.3
                                                   alpha:0.85];
        
        _popover.layer.cornerRadius = 20.0;
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGRect progFrame = _popover.frame;
        progFrame.size.width *= 0.75;
        _progressView.frame = progFrame;
        _progressView.center = CGPointMake((_popover.frame.size.width / 2.0), (_popover.frame.size.height / 2.0));
        _progressView.progressTintColor = UIColor.whiteColor;
        _progressView.trackTintColor = UserDefaults.defaults.appleBlue;
        _progressView.progress = 0.0;
        
        _popoverCancel = [[UIButton alloc] initWithFrame:CGRectMake((_popover.frame.size.width * 0.25),
                                                                    (_popover.frame.size.height * 0.75),
                                                                    (_popover.frame.size.width * 0.5),
                                                                    (_popover.frame.size.height * 0.15))];
        
        _popoverCancel.layer.cornerRadius = 10.0;
        _popoverCancel.backgroundColor = UIColor.whiteColor;
        _popoverCancel.titleLabel.font = _font;
        _popoverCancel.titleLabel.adjustsFontSizeToFitWidth = YES;
        
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
        _popoverLabel.text = self.title;
        _popoverLabel.textAlignment = NSTextAlignmentCenter;
        _popoverLabel.adjustsFontSizeToFitWidth = YES;
        
        [popoverView addSubview:_popover];
        [_popover addSubview:_progressView];
        [_popover addSubview:_popoverCancel];
        [_popover addSubview:_popoverLabel];
    }
    
    return self;
}

- (void)popoverCancel:(UIButton *)sender
{
    _popoverCancel.titleLabel.font = _font;
    [self removeFromSuperview];
    
    if (self.delegate)
        [self.delegate GSSiPopoverViewdidCancel:self];
}

- (void)showFromTimer:(NSTimer*)timer
{
    [self show];
}
- (void)show
{
    [self.fromView addSubview:self];
}

- (void) hideFromTimer:(NSTimer *)timer
{
    [self hide];
}

- (void)hide
{
    [self.timer invalidate];
    
    if (self.superview)
    {
        int seconds = (NSDate.timeIntervalSinceReferenceDate - self.showTime);
        
        if (seconds < MIN_SHOWTIME)
        {
            self.showTime = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                          target:self
                                                        selector:@selector(hideFromTimer:)
                                                        userInfo:nil
                                                         repeats:NO];
        }
        
        else
            [self removeFromSuperview];
    }
}

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString *)title
        andButton:(NSString *)button
{
    if (button)
    {
        [_popoverCancel setTitle:button
                        forState:UIControlStateNormal];
        
        _popoverCancel.hidden = NO;
    }
    
    else
        _popoverCancel.hidden = YES;
    
    [self showAfter:seconds
          withTitle:title];
}

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString *)title
{
    self.title = title;
    _popoverLabel.text = title;
    
    if (seconds > 0.0)
    {
        self.showTime = NSDate.timeIntervalSinceReferenceDate;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                      target:self
                                                    selector:@selector(showFromTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
    }
    
    else
        [self show];
}

- (void)updateProgress:(CGFloat)progress
{
    _progressView.progress = progress;
}

- (void)setTitle:(NSString *)title
{
    self.popoverLabel.text = title;
}

@end