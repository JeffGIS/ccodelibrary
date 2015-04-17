//  GSSiBumpDetector.m
//  CCodeLibrary

#import "GSSiBumpDetector.h"
#import "UserDefaults.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <CoreMotion/CoreMotion.h>

@interface GSSiBumpDetector ()

@property (nonatomic) NSInteger countdownTime, countdownStart;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) UILabel *countdownLabel, *titleLabel;
@property (nonatomic) UIButton *startButton, *cancelButton;
@property (nonatomic) BOOL timerIsFiring, isFirstTime, isComplete;
@property (nonatomic) UIColor *green;
@property (nonatomic) AVAudioPlayer *beep, *finalBeep;
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CMAcceleration userAcceleration, gravity;
@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval elapsedTime;

@end

@implementation GSSiBumpDetector

+ (GSSiBumpDetector *)showBumpDetectorWithView:(UIView *)view
                                  coundownTime:(NSInteger)countdownTime
                                         title:(NSString *)title
                                      delegate:(id)delegate
{
    GSSiBumpDetector *bumpDetector = [[GSSiBumpDetector alloc] initWithFrame:view.frame];
    bumpDetector.delegate = delegate;
    bumpDetector.countdownTime = bumpDetector.countdownStart = countdownTime;
    bumpDetector.timerIsFiring = bumpDetector.isComplete = NO;
    bumpDetector.isFirstTime = YES;
    bumpDetector.backgroundColor = UserDefaults.defaults.appleBlue;
    bumpDetector.alpha = 0.0;
    
    bumpDetector.green = [UIColor colorWithRed:0.0
                                         green:0.6
                                          blue:0.0
                                         alpha:1.0];
    
    [view addSubview:bumpDetector];
    
    CGSize size = view.frame.size;
    
    bumpDetector.countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((size.width * 0.1), (size.height * 0.2),
                                                                            (size.width * 0.8), (size.height * 0.6))];
    
    bumpDetector.countdownLabel.backgroundColor = UIColor.blackColor;
    bumpDetector.countdownLabel.textColor = UIColor.whiteColor;
    bumpDetector.countdownLabel.font = [UIFont boldSystemFontOfSize:360.0];
    bumpDetector.countdownLabel.textAlignment = NSTextAlignmentCenter;
    bumpDetector.countdownLabel.adjustsFontSizeToFitWidth = YES;
    bumpDetector.countdownLabel.numberOfLines = 0;
    bumpDetector.countdownLabel.layer.borderColor = UIColor.whiteColor.CGColor;
    bumpDetector.countdownLabel.layer.borderWidth = 4.0;
    bumpDetector.countdownLabel.layer.cornerRadius = 10.0;
    bumpDetector.countdownLabel.layer.masksToBounds = YES;
    bumpDetector.countdownLabel.layer.backgroundColor = UIColor.blackColor.CGColor;
    [bumpDetector updateCountdownLabelText];
    
    [bumpDetector addSubview:bumpDetector.countdownLabel];
    
    bumpDetector.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, (size.width - 40.0),
                                                                        ((size.height * 0.2) - 40.0))];
    
    bumpDetector.titleLabel.backgroundColor = UIColor.clearColor;
    bumpDetector.titleLabel.textColor = UIColor.whiteColor;
    bumpDetector.titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    bumpDetector.titleLabel.textAlignment = NSTextAlignmentCenter;
    bumpDetector.titleLabel.adjustsFontSizeToFitWidth = YES;
    bumpDetector.titleLabel.numberOfLines = 2;
    bumpDetector.titleLabel.layer.shadowColor = UIColor.blackColor.CGColor;
    bumpDetector.titleLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    bumpDetector.titleLabel.layer.shadowOpacity = 1.0;
    bumpDetector.titleLabel.text = [NSString stringWithFormat:@"Collision Detection Manager\n%@", title];
    
    [bumpDetector addSubview:bumpDetector.titleLabel];
    
    bumpDetector.startButton = [[UIButton alloc] initWithFrame:CGRectMake((size.width * 0.05), (size.height * 0.85),
                                                                          (size.width * 0.4), (size.height * 0.1))];
    
    [bumpDetector setupButton:bumpDetector.startButton
                       target:bumpDetector
                     selector:@selector(startBumpDetection:)
                        title:@"Start"];
    
    bumpDetector.startButton.backgroundColor = bumpDetector.green;
    
    [bumpDetector addSubview:bumpDetector.startButton];
    
    bumpDetector.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((size.width * 0.55), (size.height * 0.85),
                                                                           (size.width * 0.4), (size.height * 0.1))];
    
    [bumpDetector setupButton:bumpDetector.cancelButton
                       target:bumpDetector
                     selector:@selector(cancelBumpDetection:)
                        title:@"Cancel"];
    
    bumpDetector.cancelButton.backgroundColor = UIColor.blackColor;
    
    [bumpDetector addSubview:bumpDetector.cancelButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         bumpDetector.alpha = 1.0;
                     }];
    
    bumpDetector.beep = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.mp3",
                                                        NSBundle.mainBundle.resourcePath]] error:nil];
    
    [bumpDetector.beep prepareToPlay];
    
    bumpDetector.finalBeep = [[AVAudioPlayer alloc] initWithContentsOfURL:
                              [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/finalBeep.mp3",
                                                      NSBundle.mainBundle.resourcePath]] error:nil];
    
    [bumpDetector.finalBeep prepareToPlay];
    bumpDetector.finalBeep.volume = 1.0;
    
    bumpDetector.motionManager = [[CMMotionManager alloc] init];
    
    return bumpDetector;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    button.layer.borderWidth = 4.0;
    button.layer.borderColor = UIColor.whiteColor.CGColor;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
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
    
    if (_countdownTime < 4 && _countdownTime > 0)
    {
        _beep.volume = (1.0 / _countdownTime);
        [_beep play];
    }
    
    else if (_countdownTime == 0)
        [_finalBeep play];

    [self updateCountdownLabelText];
}

- (void)startBumpDetection:(UIButton *)button
{
    if (_isComplete)
    {
        if (_delegate)
        {
            NSDecimal dIn = [[NSNumber numberWithDouble:_elapsedTime] decimalValue];
            NSDecimal dOut;
            NSDecimalRound(&dOut, &dIn, 1, NSRoundPlain);
            
            NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithDecimal:dOut];
            NSString *resultString = result.stringValue;
            
            [_delegate bumpDetector:self
              didReturnTimeInterval:resultString];
        }
    }
    
    else if (_motionManager.deviceMotionActive)
    {
        [_motionManager stopDeviceMotionUpdates];
        _isFirstTime = YES;
        
        [self updateCountdownLabelText];
        
        _startButton.backgroundColor = _green;
        
        [_startButton setTitle:@"Start"
                      forState:UIControlStateNormal];
    }
    
    else if (_timerIsFiring)
    {
        if (_timer.valid)
        {
            [_timer invalidate];
            
            if (!_timer.valid)
            {
                _timerIsFiring = NO;
                _countdownTime = _countdownStart;
                [self updateCountdownLabelText];
                
                _startButton.backgroundColor = _green;
                
                [_startButton setTitle:@"Start"
                              forState:UIControlStateNormal];
            }
        }
    }
    
    else
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateCountdown:)
                                                userInfo:nil
                                                 repeats:YES];
        
        if (_timer.valid)
        {
            _timerIsFiring = YES;
            
            _startButton.backgroundColor = UIColor.redColor;
            
            [_startButton setTitle:@"Stop"
                          forState:UIControlStateNormal];
        }
    }
}

- (void)updateCountdownLabelText
{
    if (_countdownTime > 0)
        _countdownLabel.text = [NSString stringWithFormat:@"%ld", (long)_countdownTime];
    
    else
    {
        if (_timer.valid)
        {
            [_timer invalidate];
            
            if (!_timer.valid)
            {
                _timerIsFiring = NO;
                _countdownTime = _countdownStart;
            }
        }
        
        [self startMotionManager];
    }
}

- (void)cancelBumpDetection:(UIButton *)button
{
    if (_isComplete)
    {
        [self updateCountdownLabelText];
        
        _startButton.backgroundColor = _green;
        
        [_startButton setTitle:@"Start"
                      forState:UIControlStateNormal];
        
        [_startButton setTitleColor:UIColor.whiteColor
                           forState:UIControlStateNormal];
        
        _startButton.layer.borderColor = UIColor.whiteColor.CGColor;
        
        [_cancelButton setTitle:@"Cancel"
                       forState:UIControlStateNormal];
        
        _isComplete = NO;
        
        return;
    }
    
    if (_timer.valid)
        [_timer invalidate];
    
    if (_delegate)
        [_delegate bumpDetectorDidCancel:self];
    
    else
        [self hideBumpDetector:YES];
}

- (void)startMotionManager
{
    _motionManager.deviceMotionUpdateInterval = 0.02;
    
    if ([_motionManager isDeviceMotionAvailable])
    {
        _startTime = NSDate.date;
        
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                            toQueue:NSOperationQueue.currentQueue
                                                        withHandler:^(CMDeviceMotion *deviceMotion, NSError *error){
                                                            [self detectMotion:deviceMotion];
                                                                
                                                                if(error)
                                                                    NSLog(@"CMDeviceMotion Error:%@", error);
                                                            }];
    }
}

- (void)detectMotion:(CMDeviceMotion *)deviceMotion
{
    _elapsedTime = [NSDate.date timeIntervalSinceDate:_startTime];
    _countdownLabel.text = [NSString stringWithFormat:@"Elapsed\nTime:\n%.01f\nseconds", _elapsedTime];
    
    if (!_isFirstTime)
    {
        CGFloat sumXa = (_userAcceleration.x + _gravity.x);
        CGFloat sumYa = (_userAcceleration.y + _gravity.y);
        CGFloat sumZa= (_userAcceleration.z + _gravity.z);
        CGFloat sumXb = (deviceMotion.userAcceleration.x + deviceMotion.gravity.x);
        CGFloat sumYb = (deviceMotion.userAcceleration.y + deviceMotion.gravity.y);
        CGFloat sumZb= (deviceMotion.userAcceleration.z + deviceMotion.gravity.z);
        
        CGFloat diffX = fabs(sumXa - sumXb);
        CGFloat diffY = fabs(sumYa - sumYb);
        CGFloat diffZ = fabs(sumZa - sumZb);
        CGFloat maxDiff = max(diffX, max(diffY, diffZ));
        
        if (maxDiff > 0.1)
        {
            [self.motionManager stopDeviceMotionUpdates];
            _isFirstTime = _isComplete = YES;
            _startButton.backgroundColor = UIColor.whiteColor;
            
            [_startButton setTitleColor:UIColor.blackColor
                               forState:UIControlStateNormal];
            
            _startButton.layer.borderColor = UIColor.blackColor.CGColor;
            
            [_startButton setTitle:@"Use It"
                          forState:UIControlStateNormal];
            
            [_cancelButton setTitle:@"Do Over"
                           forState:UIControlStateNormal];
            
            return;
        }
    }
    
    else
        _isFirstTime = NO;
    
    _userAcceleration = deviceMotion.userAcceleration;
    _gravity = deviceMotion.gravity;
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight
{
    CGRect frame = self.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.frame = CGRectMake(frame.origin.y, frame.origin.x,
                                                 ((frame.size.height + tabBarHeight)),
                                                 ((frame.size.width - tabBarHeight)));
                     }];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _countdownLabel.frame = CGRectMake(((frame.size.height + tabBarHeight) * 0.1),
                                                            ((frame.size.width - tabBarHeight) * 0.2),
                                                            ((frame.size.height + tabBarHeight) * 0.8),
                                                            ((frame.size.width - tabBarHeight) * 0.6));
                         
                         _titleLabel.frame = CGRectMake(20.0, 20.0,
                                                        (frame.size.height + tabBarHeight - 40.0),
                                                        (((frame.size.width - tabBarHeight) * 0.2) - 40.0));
                         
                         _startButton.frame = CGRectMake(((frame.size.height + tabBarHeight) * 0.05),
                                                         ((frame.size.width - tabBarHeight) * 0.85),
                                                         ((frame.size.height + tabBarHeight) * 0.4),
                                                         ((frame.size.width - tabBarHeight) * 0.1));
                         
                         _cancelButton.frame = CGRectMake(((frame.size.height + tabBarHeight) * 0.55),
                                                         ((frame.size.width - tabBarHeight) * 0.85),
                                                         ((frame.size.height + tabBarHeight) * 0.4),
                                                         ((frame.size.width - tabBarHeight) * 0.1));
                         
                     }];
}

@end