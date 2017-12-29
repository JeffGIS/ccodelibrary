//  RHController.m
//  CCodeLibrary

#import "RHController.h"
#import "RHRecorder.h"
#import "RHPlayer.h"
#import "CRAPI.h"

@interface RHController ()

@property (nonatomic, weak) id<RHControllerDelegate> delegate;
@property (nonatomic) UIButton *connectButton, *returnButton;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) NSTimer *timer;
@property int seconds, minutes;

@end

@implementation RHController

- (void)showInView:(UIView *)view
          delegate:(id<RHControllerDelegate>)delegate
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = YES;
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
                          action:@selector(playRecordButtonTapped)
                forControlEvents:UIControlEventTouchUpInside];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_returnButton setImage:[UIImage imageWithContentsOfFile:
                             [NSBundle.mainBundle pathForResource:@"returnIcon"
                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
    
    [self addSubview:_returnButton];
    [_returnButton constrainCenterYToAnchor:self.topAnchor constant:(view.frame.size.height / 8)];
    [_returnButton constrainCenterXToAnchor:self.centerXAnchor];
    [_returnButton constrainWidthToAnchor:self.widthAnchor multiplier:0.9];
    [_returnButton constrainHeightToAnchor:self.widthAnchor multiplier:0.9];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _timeLabel = UILabel.new;
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.backgroundColor = UIColor.clearColor;
    _timeLabel.textColor = UIColor.whiteColor;
    _timeLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:32];
    _timeLabel.adjustsFontSizeToFitWidth = YES;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"0:00";
    
    [self addSubview:_timeLabel];
    [_timeLabel constrainBottomToAnchor:_playRecordButton.topAnchor constant:-4.0];
    [_timeLabel constrainLeadingToAnchor:self.leadingAnchor];
    [_timeLabel constrainTrailingToAnchor:self.trailingAnchor];
    
    _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _connectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self updateConnectButton];
    
    if ([delegate isKindOfClass:RHRecorder.class])
    {
        [_connectButton setImage:[UIImage imageWithContentsOfFile:
                                  [NSBundle.mainBundle pathForResource:@"advertiseIcon"
                                                                ofType:@"png"]]
                        forState:UIControlStateNormal];
    }
    
    else
    {
        [_connectButton setImage:[UIImage imageWithContentsOfFile:
                                  [NSBundle.mainBundle pathForResource:@"browseIcon"
                                                                ofType:@"png"]]
                        forState:UIControlStateNormal];
    }
    
    [self addSubview:_connectButton];
    [_connectButton constrainCenterYToAnchor:self.bottomAnchor constant:-(view.frame.size.height / 8)];
    [_connectButton constrainCenterXToAnchor:self.centerXAnchor];
    [_connectButton constrainWidthToAnchor:self.widthAnchor multiplier:0.9];
    [_connectButton constrainHeightToAnchor:self.widthAnchor multiplier:0.9];
    
    [_connectButton addTarget:self
                       action:@selector(connectButtonTapped)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateConnectButton
{
    if (CRAPI.sharedInstance.peerConnect.fileToSend
        && CRAPI.sharedInstance.peerConnect.fileToSend.path.length)
    {
        _connectButton.alpha = 1.0;
        _connectButton.userInteractionEnabled = YES;
    }
    
    else
    {
        _connectButton.alpha = 0.5;
        _connectButton.userInteractionEnabled = NO;
    }
}

- (void)playRecordButtonTapped
{
    [_delegate controllerDidTapPlayRecordButton];
}

- (void)connectButtonTapped
{
    [_delegate controllerDidTapConnectButton];
}

- (void)returnButtonTapped
{
    [_delegate controllerDidTapReturnButton];
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
