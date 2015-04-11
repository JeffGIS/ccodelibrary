//  GSSiBumpDetector.m
//  CCodeLibrary

#import "GSSiBumpDetector.h"
#import "UserDefaults.h"

@interface GSSiBumpDetector ()

@property (nonatomic) NSInteger countdownTime, countdownStart;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) UILabel *countdownLabel, *titleLabel;
@property (nonatomic) UIButton *startButton, *cancelButton;
@property (nonatomic) BOOL timerIsFiring;

@end

@implementation GSSiBumpDetector

+ (GSSiBumpDetector *)showBumpDetectorWithView:(UIView *)view
                                  coundownTime:(NSInteger)countdownTime
                                      delegate:(id)delegate
{
    GSSiBumpDetector *bumpDetector = [[GSSiBumpDetector alloc] initWithFrame:view.frame];
    bumpDetector.delegate = delegate;
    bumpDetector.countdownTime = bumpDetector.countdownStart = countdownTime;
    bumpDetector.timerIsFiring = NO;
    bumpDetector.backgroundColor = UserDefaults.defaults.appleBlue;
    bumpDetector.alpha = 0.0;
    
    [view addSubview:bumpDetector];
    
    CGSize size = view.frame.size;
    
    bumpDetector.countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((size.width * 0.2), (size.height * 0.2),
                                                                            (size.width * 0.6), (size.height * 0.6))];
    
    bumpDetector.countdownLabel.backgroundColor = UIColor.blackColor;
    bumpDetector.countdownLabel.textColor = UIColor.whiteColor;
    bumpDetector.countdownLabel.font = [UIFont boldSystemFontOfSize:360.0];
    bumpDetector.countdownLabel.textAlignment = NSTextAlignmentCenter;
    bumpDetector.countdownLabel.adjustsFontSizeToFitWidth = YES;
    [bumpDetector updateCountdownLabelText];
    
    [bumpDetector addSubview:bumpDetector.countdownLabel];
    
    bumpDetector.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, (size.width - 40.0),
                                                                        ((size.height * 0.2) - 40.0))];
    
    bumpDetector.titleLabel.backgroundColor = UIColor.clearColor;
    bumpDetector.titleLabel.textColor = UIColor.whiteColor;
    bumpDetector.titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    bumpDetector.titleLabel.textAlignment = NSTextAlignmentCenter;
    bumpDetector.titleLabel.adjustsFontSizeToFitWidth = YES;
    bumpDetector.titleLabel.text = @"Collision Detection Manager";
    
    [bumpDetector addSubview:bumpDetector.titleLabel];
    
    bumpDetector.startButton = [[UIButton alloc] initWithFrame:CGRectMake((size.width * 0.05), (size.height * 0.85),
                                                                          (size.width * 0.4), (size.height * 0.1))];
    [bumpDetector setupButton:bumpDetector.startButton
                       target:bumpDetector
                     selector:@selector(startBumpDetection:)
                        title:@"Start"];
    
    [bumpDetector addSubview:bumpDetector.startButton];
    
    bumpDetector.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((size.width * 0.55), (size.height * 0.85),
                                                                           (size.width * 0.4), (size.height * 0.1))];
    [bumpDetector setupButton:bumpDetector.cancelButton
                       target:bumpDetector
                     selector:@selector(cancelBumpDetection:)
                        title:@"Cancel"];
    
    [bumpDetector addSubview:bumpDetector.cancelButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         bumpDetector.alpha = 1.0;
                     }];
    
    return bumpDetector;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideBumpDetector:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
    
    else
        [self removeFromSuperview];
}

- (void)updateCountdown:(NSTimer *)timer
{
    _countdownTime--;
    [self updateCountdownLabelText];
}

- (void)startBumpDetection:(UIButton *)button
{
    if (_timerIsFiring)
    {
        if (_timer.valid)
        {
            [_timer invalidate];
            
            if (!_timer.valid)
            {
                _timerIsFiring = NO;
                _countdownTime = _countdownStart;
                [self updateCountdownLabelText];
                
                [_startButton setTitle:@"Start"
                              forState:UIControlStateNormal];
            }
        }
        
        return;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(updateCountdown:)
                                            userInfo:nil
                                             repeats:YES];
    
    if (_timer.valid)
    {
        _timerIsFiring = YES;
        
        [_startButton setTitle:@"Stop"
                      forState:UIControlStateNormal];
    }
}

- (void)updateCountdownLabelText
{
    _countdownLabel.text = [NSString stringWithFormat:@"%ld", (long)_countdownTime];
}

- (void)cancelBumpDetection:(UIButton *)button
{
    if (_timer.valid)
        [_timer invalidate];
    
    if (_delegate)
        [_delegate bumpDetectorDidCancel:self];
    
    else
        [self hideBumpDetector:YES];
}

@end