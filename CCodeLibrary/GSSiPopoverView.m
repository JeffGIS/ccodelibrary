//  GSSiPopoverView.m
//  CCodeLibrary

#import "GSSiPopoverView.h"
#import "FTPDataPull.h"
#import "CRAPI.h"

#define MIN_SHOWTIME 2

@interface GSSiPopoverView ()

@property (nonatomic) UIFont *font;

@end

@implementation GSSiPopoverView

- (id)initWithView:(UIView *)fromView
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.clearColor;
        _fromView = fromView;
        _hideAtCancel = YES;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            _font = [UIFont boldSystemFontOfSize:24.0];
        
        else
            _font = [UIFont boldSystemFontOfSize:40.0];
        
        _popover = [[UIView alloc] init];
        _popover.translatesAutoresizingMaskIntoConstraints = NO;
        
        _popover.backgroundColor = [UIColor colorWithRed:0.0
                                                   green:0.0
                                                    blue:0.3
                                                   alpha:0.9];
        
        _popover.layer.cornerRadius = 20.0;
        
        [self addSubview:_popover];
        
        CGFloat tabBarAdj = 0.0;
        
        if ([[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"NVMobile"])
            tabBarAdj = 24.5;
        
        CGFloat width = MIN(fromView.frame.size.height, fromView.frame.size.width);
        CGFloat height = MAX(fromView.frame.size.height, fromView.frame.size.width);
        
        [_popover.leadingAnchor constraintEqualToAnchor:self.centerXAnchor
                                               constant:(-width / 2.5)].active = YES;
        
        [_popover.trailingAnchor constraintEqualToAnchor:self.centerXAnchor
                                                constant:(width / 2.5)].active = YES;
        
        [_popover.topAnchor constraintEqualToAnchor:self.centerYAnchor
                                           constant:(-height / 5.0) + tabBarAdj].active = YES;
        
        [_popover.bottomAnchor constraintEqualToAnchor:self.centerYAnchor
                                              constant:(height / 5.0) + tabBarAdj].active = YES;
        
        _progressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                     progressColor:UIColor.whiteColor];
        
        [_popover addSubview:_progressView];
        
        [_progressView.leadingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                    constant:(-width / 2.75)].active = YES;
        
        [_progressView.trailingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                     constant:(width / 2.75)].active = YES;
        
        [_progressView.topAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                constant:(-height / 64.0)].active = YES;
        
        [_progressView.bottomAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                   constant:(height / 64.0)].active = YES;
        
        _popoverCancel = [[UIButton alloc] init];
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
        
        [_popoverCancel.leadingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                     constant:(-width / 5.0)].active = YES;
        
        [_popoverCancel.trailingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                      constant:(width / 5.0)].active = YES;
        
        [_popoverCancel.topAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                 constant:(height / 10.0)].active = YES;
        
        [_popoverCancel.bottomAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                    constant:(height / 6.0)].active = YES;
        
        _popoverLabel = [[UILabel alloc] init];
        _popoverLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _popoverLabel.backgroundColor = UIColor.clearColor;
        _popoverLabel.textColor = UIColor.whiteColor;
        _popoverLabel.font = _font;
        _popoverLabel.numberOfLines = 0;
        _popoverLabel.text = _title;
        _popoverLabel.textAlignment = NSTextAlignmentCenter;
        _popoverLabel.adjustsFontSizeToFitWidth = YES;
        
        [_popover addSubview:_popoverLabel];
        
        [_popoverLabel.leadingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                    constant:(-width / 2.75)].active = YES;
        
        [_popoverLabel.trailingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                     constant:(width / 2.75)].active = YES;
        
        [_popoverLabel.topAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                constant:(-height / 5.3)].active = YES;
        
        [_popoverLabel.bottomAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                   constant:(-height / 36.0)].active = YES;
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _progressLabel.backgroundColor = UIColor.clearColor;
        _progressLabel.textColor = UIColor.whiteColor;
        _progressLabel.font = [UIFont systemFontOfSize:28.0];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.adjustsFontSizeToFitWidth = YES;
        _progressLabel.text = @"0% complete";
        
        [_popover addSubview:_progressLabel];
        
        [_progressLabel.leadingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                     constant:(-width / 2.75)].active = YES;
        
        [_progressLabel.trailingAnchor constraintEqualToAnchor:_popover.centerXAnchor
                                                      constant:(width / 2.75)].active = YES;
        
        [_progressLabel.topAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                 constant:(height / 44.0)].active = YES;
        
        [_progressLabel.bottomAnchor constraintEqualToAnchor:_popover.centerYAnchor
                                                    constant:(height / 12.0)].active = YES;
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
    [self show];
}

- (void)show
{
    [_fromView addSubview:self];
    
    [self.leadingAnchor constraintEqualToAnchor:_fromView.leadingAnchor].active = YES;
    [self.trailingAnchor constraintEqualToAnchor:_fromView.trailingAnchor].active = YES;
    [self.topAnchor constraintEqualToAnchor:_fromView.topAnchor].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:_fromView.bottomAnchor].active = YES;
}

- (void)hideFromTimer:(NSTimer *)timer
{
    [self hide];
}

- (void)hide
{
    [_timer invalidate];
    
    if (self.superview)
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
}

- (void)setTitle:(NSString *)title
{
    _popoverLabel.text = title;
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