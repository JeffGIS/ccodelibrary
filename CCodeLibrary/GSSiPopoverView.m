//  GSSiPopoverView.m
//  CCodeLibrary

#import "GSSiPopoverView.h"
#import "FTPDataPull.h"
#import "CRAPI.h"

#define MIN_SHOWTIME 2

@interface GSSiPopoverView ()

@property (nonatomic) UIFont *font;
@property (nonatomic) NSTimer *timer;

@end

@implementation GSSiPopoverView

- (id)initWithView:(UIView *)fromView
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.clearColor;
        self.parentView = fromView;
        [fromView addSubview:self];
        //[self constrainToView:fromView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
        self.hidden = YES;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            _font = [UIFont boldSystemFontOfSize:24.0];
        
        else
            _font = [UIFont boldSystemFontOfSize:40.0];
        
        _popover = UIView.new;
        _popover.translatesAutoresizingMaskIntoConstraints = NO;
        
        _popover.backgroundColor = [UIColor colorWithRed:0.0
                                                   green:0.0
                                                    blue:0.3
                                                   alpha:0.9];
        
        _popover.layer.cornerRadius = 20.0;
        
        CGFloat width = MIN(fromView.frame.size.height, fromView.frame.size.width);
        CGFloat height = MAX(fromView.frame.size.height, fromView.frame.size.width);
        
        [self addSubview:_popover];
        /*
        [_popover constrainLeadingToAnchor:self.centerXAnchor constant:(-width / 2.5)];
        [_popover constrainTrailingToAnchor:self.centerXAnchor constant:(width / 2.5)];
        [_popover constrainTopToAnchor:self.centerYAnchor constant:(-height / 5.0)];
        [_popover constrainBottomToAnchor:self.centerYAnchor constant:(height / 5.0)];*/
        
        _progressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                     progressColor:UIColor.whiteColor];
        
        [_popover addSubview:_progressView];
        /*
        [_progressView constrainLeadingToAnchor:_popover.centerXAnchor constant:(-width / 2.75)];
        [_progressView constrainTrailingToAnchor:_popover.centerXAnchor constant:(width / 2.75)];
        [_progressView constrainTopToAnchor:_popover.centerYAnchor constant:(-height / 64.0)];
        [_progressView constrainBottomToAnchor:_popover.centerYAnchor constant:(height / 64.0)];
        */
        _popoverCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _popoverCancel.translatesAutoresizingMaskIntoConstraints = NO;
        _popoverCancel.layer.cornerRadius = 10.0;
        _popoverCancel.backgroundColor = UIColor.whiteColor;
        _popoverCancel.titleLabel.font = _font;
        _popoverCancel.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [_popoverCancel setTitleColor:UIColor.blackColor
                             forState:UIControlStateNormal];
        
        [_popoverCancel setTitleColor:UIColor.grayColor
                             forState:UIControlStateHighlighted];
        
        [_popoverCancel setTitle:@"Cancel"
                        forState:UIControlStateNormal];
        
        [_popoverCancel addTarget:self
                           action:@selector(popoverCancel:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [_popover addSubview:_popoverCancel];
        /*
        [_popoverCancel constrainLeadingToAnchor:_popover.centerXAnchor constant:(-width / 5.0)];
        [_popoverCancel constrainTrailingToAnchor:_popover.centerXAnchor constant:(width / 5.0)];
        [_popoverCancel constrainTopToAnchor:_popover.centerYAnchor constant:(height / 10.0)];
        [_popoverCancel constrainBottomToAnchor:_popover.centerYAnchor constant:(height / 6.0)];
        */
        _popoverLabel = UILabel.new;
        _popoverLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _popoverLabel.backgroundColor = UIColor.clearColor;
        _popoverLabel.textColor = UIColor.whiteColor;
        _popoverLabel.font = _font;
        _popoverLabel.numberOfLines = 0;
        _popoverLabel.text = _title;
        _popoverLabel.textAlignment = NSTextAlignmentCenter;
        _popoverLabel.adjustsFontSizeToFitWidth = YES;
        
        [_popover addSubview:_popoverLabel];
        /*
        [_popoverLabel constrainLeadingToAnchor:_popover.centerXAnchor constant:(-width / 2.75)];
        [_popoverLabel constrainTrailingToAnchor:_popover.centerXAnchor constant:(width / 2.75)];
        [_popoverLabel constrainTopToAnchor:_popover.centerYAnchor constant:(-height / 5.3)];
        [_popoverLabel constrainBottomToAnchor:_popover.centerYAnchor constant:(-height / 36.0)];
        */
        _progressLabel = UILabel.new;
        _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _progressLabel.backgroundColor = UIColor.clearColor;
        _progressLabel.textColor = UIColor.whiteColor;
        _progressLabel.font = [UIFont systemFontOfSize:28.0];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.adjustsFontSizeToFitWidth = YES;
        _progressLabel.text = @"0% complete";
        
        [_popover addSubview:_progressLabel];
        /*
        [_progressLabel constrainLeadingToAnchor:_popover.centerXAnchor constant:(-width / 2.75)];
        [_progressLabel constrainTrailingToAnchor:_popover.centerXAnchor constant:(width / 2.75)];
        [_progressLabel constrainTopToAnchor:_popover.centerYAnchor constant:(height / 44.0)];
        [_progressLabel constrainBottomToAnchor:_popover.centerYAnchor constant:(height / 12.0)];
         */
    }
    
    return self;
}

- (void)popoverCancel:(UIButton *)sender
{
    _popoverCancel.titleLabel.font = _font;
    
    if (_delegate)
        [_delegate GSSiPopoverViewdidCancel:self];
    
    if (_hideAtCancel)
        [self removeFromSuperview];
}

- (void)showFromTimer:(NSTimer *)timer
{
    [timer invalidate];
    _timer = nil;
    [self show];
}

- (void)show
{
    self.hidden = NO;
    [_parentView bringSubviewToFront:self];
}

- (void)hideFromTimer:(NSTimer *)timer
{
    [timer invalidate];
    _timer = nil;
    self.hidden = YES;
    [self hide];
}

- (void)hide
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
        self.hidden = YES;
    }
    else if (self.superview)
    {
        int seconds = (NSDate.timeIntervalSinceReferenceDate - _showTime);
        
        if (seconds < MIN_SHOWTIME)
        {
            _showTime = 0;
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                      target:self
                                                    selector:@selector(hideFromTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
        }
        
        else
            self.hidden = YES;
    }
}

- (void)showAfter:(CGFloat)seconds
        withTitle:(NSString *)title
        andButton:(NSString *)button
{
    if (button)
    {
        [_popoverCancel setTitle:button forState:UIControlStateNormal];
        _cancelButtonTitle = button;
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
    _title = title;
    _popoverLabel.text = title;
    
    if (seconds > 0.0)
    {
        _showTime = NSDate.timeIntervalSinceReferenceDate;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:seconds
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
    
    _progressLabel.text = [NSString stringWithFormat:@"%i%% complete",
                           (int)roundf(progress * 100.0)];
    
    [_parentView bringSubviewToFront:self];
}

- (void)setTitle:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _popoverLabel.text = title;
    });
}

- (void)setCancelButtonTitle:(NSString *)title
{
    [_popoverCancel setTitle:title
                    forState:UIControlStateNormal];
}

- (void)dealloc
{
    NSLog(@"Popover dealloc");
}

@end
