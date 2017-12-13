//  RHController.m
//  CCodeLibrary

#import "RHController.h"

@interface RHController ()

@property (nonatomic, weak) id<RHControllerDelegate> delegate;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) NSTimer *timer;
@property int seconds, minutes;

@end

@implementation RHController

- (void)showInView:(UIView *)view
          delegate:(id<RHControllerDelegate>)delegate
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    _timeLabel.text = @"";
    _seconds = _minutes = 0;
    _delegate = delegate;
    
    [view addSubview:self];
    [self constrainTopToAnchor:view.topAnchor];
    [self constrainTrailingToAnchor:view.trailingAnchor];
    [self constrainBottomToAnchor:view.bottomAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [self constrainWidthToConstant:60.0];
    
    else
        [self constrainWidthToConstant:80.0];
    
    _playRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playRecordButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                 [NSBundle.mainBundle pathForResource:@"VideoRecordIcon"
                                                               ofType:@"png"]]
                       forState:UIControlStateNormal];
    
    [self addSubview:_playRecordButton];
    [_playRecordButton constrainCenterXToAnchor:self.centerXAnchor];
    [_playRecordButton constrainCenterYToAnchor:self.centerYAnchor];
    [_playRecordButton constrainWidthToAnchor:self.widthAnchor multiplier:0.9];
    [_playRecordButton constrainHeightToAnchor:self.widthAnchor multiplier:0.9];
    
    [_playRecordButton addTarget:self
                          action:@selector(recordButtonTapped)
                forControlEvents:UIControlEventTouchUpInside];
    
    _timeLabel = UILabel.new;
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.backgroundColor = UIColor.clearColor;
    _timeLabel.textColor = UIColor.whiteColor;
    _timeLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:32];
    _timeLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_timeLabel];
    [_timeLabel constrainTopToAnchor:self.topAnchor constant:10.0];
    [_timeLabel constrainLeadingToAnchor:self.leadingAnchor];
    [_timeLabel constrainTrailingToAnchor:self.trailingAnchor];
}

- (void)recordButtonTapped
{
    [_delegate controllerDidTapPlayRecordButton];
}

- (void)startTimer
{
    _timeLabel.text = @"0:00";
    _seconds = 0;
    _minutes = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(incrementTime)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopTimer
{
    if (_timer.isValid)
        [_timer invalidate];
}

- (void)incrementTime
{
    if (_seconds < 59)
        _seconds++;
    
    else
    {
        _seconds = 0;
        _minutes++;
    }
    
    _timeLabel.text = [NSString stringWithFormat:@"%i:%02i", _minutes, _seconds];
}

@end
