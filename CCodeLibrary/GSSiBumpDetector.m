//  GSSiBumpDetector.m
//  CCodeLibrary

#import "GSSiBumpDetector.h"
#import "UserDefaults.h"
@import AVFoundation;
@import CoreMotion;

@interface GSSiBumpDetector ()

@property (nonatomic) NSInteger countdownTime, countdownStart;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) UILabel *countdownLabel, *titleLabel, *promptLabel;
@property (nonatomic) UIButton *start, *cancel, *help, *reference, *link, *comment;
@property (nonatomic) BOOL timerIsFiring, isFirstTime, isComplete;
@property (nonatomic) AVAudioPlayer *beep, *finalBeep;
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CMAcceleration userAcceleration, gravity;
@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NVWebView *webView;

@end

@implementation GSSiBumpDetector

+ (GSSiBumpDetector *)showBumpDetectorWithView:(UIView *)view
                                  coundownTime:(NSInteger)countdownTime
                                         title:(NSString *)title
                                        prompt:(NSString *)prompt
                                      delegate:(id)delegate
{
    GSSiBumpDetector *bd = [[GSSiBumpDetector alloc] initWithFrame:view.frame];
    bd.delegate = delegate;
    bd.countdownTime = bd.countdownStart = countdownTime;
    bd.timerIsFiring = bd.isComplete = NO;
    bd.isFirstTime = YES;
    bd.backgroundColor = UserDefaults.defaults.appleBlue;
    bd.alpha = 0.0;
    
    [view addSubview:bd];
    
    CGSize size = view.frame.size;
    
    bd.countdownLabel = [[UILabel alloc] initWithFrame:
                                   CGRectMake((size.width * 0.12), (size.height * 0.3025),
                                              (size.width * 0.76), (size.height * 0.57))];
    
    bd.countdownLabel.backgroundColor = UIColor.blackColor;
    bd.countdownLabel.textColor = UIColor.whiteColor;
    bd.countdownLabel.font = [UIFont boldSystemFontOfSize:360.0];
    bd.countdownLabel.textAlignment = NSTextAlignmentCenter;
    bd.countdownLabel.adjustsFontSizeToFitWidth = YES;
    bd.countdownLabel.numberOfLines = 0;
    bd.countdownLabel.layer.borderColor = UIColor.whiteColor.CGColor;
    bd.countdownLabel.layer.borderWidth = 4.0;
    bd.countdownLabel.layer.cornerRadius = 10.0;
    bd.countdownLabel.layer.masksToBounds = YES;
    bd.countdownLabel.layer.backgroundColor = UIColor.blackColor.CGColor;
    [bd updateCountdownLabelText];
    [bd addSubview:bd.countdownLabel];
    
    DPOINT ul = {0}, lr = {0};
    ul.x = 0.4175, ul.y = 0.295, lr.x = 0.625, lr.y = 0.465;
    
    NVPDFDrawing *drawing = [NVPDFDrawing drawingWithID:@"1.46"
                                                   name:@"MINIMUM TIME FOR DOOR CLOSER"
                                                   type:@"FIGURE"
                                                   page:26
                                              upperLeft:ul lowerRight:lr];
    
    bd.webView = [NVWebView showPDFDrawing:drawing
                                        fromDocument:NVPDFDocumentADAChecklist
                                              inView:bd.countdownLabel
                                         enableSwipe:NO];
    
    bd.titleLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake((size.width * 0.05), (size.height * 0.025),
                                          (size.width * 0.9), (size.height * 0.15))];
    
    bd.titleLabel.backgroundColor = UIColor.clearColor;
    bd.titleLabel.textColor = UIColor.whiteColor;
    bd.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    bd.titleLabel.textAlignment = NSTextAlignmentCenter;
    bd.titleLabel.adjustsFontSizeToFitWidth = YES;
    bd.titleLabel.numberOfLines = 5;
    bd.titleLabel.text = title;
    [bd addSubview:bd.titleLabel];
    
    bd.promptLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake((size.width * 0.05), (size.height * 0.185),
                                          (size.width * 0.9), (size.height * 0.05))];
    
    bd.promptLabel.backgroundColor = UIColor.clearColor;
    bd.promptLabel.textColor = UIColor.whiteColor;
    bd.promptLabel.font = [UIFont boldSystemFontOfSize:36.0];
    bd.promptLabel.textAlignment = NSTextAlignmentCenter;
    bd.promptLabel.adjustsFontSizeToFitWidth = YES;
    bd.promptLabel.numberOfLines = 5;
    bd.promptLabel.text = prompt;
    [bd addSubview:bd.promptLabel];
    
    bd.help = [bd facButton:@"Help" tag:NVFacButtonTypeHelp];
    
    bd.help.frame = CGRectMake((size.width * 0.04), (size.height * 0.235),
                               (size.width * 0.2), (size.height * 0.05));
    
    [bd addSubview:bd.help];
    
    bd.reference = [bd facButton:@"Reference" tag:NVFacButtonTypeReference];
    
    bd.reference.frame = CGRectMake((size.width * 0.28), (size.height * 0.235),
                                    (size.width * 0.2), (size.height * 0.05));
    
    [bd addSubview:bd.reference];
    
    bd.link = [bd facButton:@"Link" tag:NVFacButtonTypeLink];
    
    bd.link.frame = CGRectMake((size.width * 0.52), (size.height * 0.235),
                               (size.width * 0.2), (size.height * 0.05));
    
    [bd addSubview:bd.link];
    
    bd.comment = [bd facButton:@"Comment" tag:NVFacButtonTypeComment];
    
    bd.comment.frame = CGRectMake((size.width * 0.76), (size.height * 0.235),
                                  (size.width * 0.2), (size.height * 0.05));
    
    [bd addSubview:bd.comment];
    
    
    bd.start = [[UIButton alloc] initWithFrame:
                                CGRectMake((size.width * 0.05), (size.height * 0.9),
                                           (size.width * 0.4), (size.height * 0.075))];
    
    [bd setupButton:bd.start
             target:bd
           selector:@selector(startBumpDetection:)
              title:@"Start"];
    
    bd.start.backgroundColor = UserDefaults.defaults.darkGreen;
    [bd addSubview:bd.start];
    
    bd.cancel = [[UIButton alloc] initWithFrame:
                                 CGRectMake((size.width * 0.55), (size.height * 0.9),
                                            (size.width * 0.4), (size.height * 0.075))];
    
    [bd setupButton:bd.cancel
             target:bd
           selector:@selector(cancelBumpDetection:)
              title:@"Cancel"];
    
    bd.cancel.backgroundColor = UIColor.blackColor;
    [bd addSubview:bd.cancel];
    
    NSError *error = nil;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error)
        NSLog(@"AVAudioSession set category ERROR");
    
    bd.beep = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.mp3",
                                                        NSBundle.mainBundle.resourcePath]] error:nil];
    
    bd.finalBeep = [[AVAudioPlayer alloc] initWithContentsOfURL:
                              [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/finalBeep.mp3",
                                                      NSBundle.mainBundle.resourcePath]] error:nil];
    
    [bd.beep prepareToPlay];
    [bd.finalBeep prepareToPlay];
    bd.finalBeep.volume = 1.0;
    bd.motionManager = CMMotionManager.new;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         bd.alpha = 1.0;
                     }];
    
    return bd;
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
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideBumpDetector:(BOOL)animated
{
    [_webView hide:NO];
    
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
    
    if (_countdownTime > 0)
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
    if ([_countdownLabel.subviews containsObject:_webView])
        [_webView hide:NO];
    
    if (_isComplete)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(bumpDetector:didReturnTimeInterval:)])
        {
            NSDecimal dIn = [NSNumber numberWithDouble:_elapsedTime].decimalValue;
            NSDecimal dOut;
            NSDecimalRound(&dOut, &dIn, 1, NSRoundPlain);
            NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithDecimal:dOut];
            NSString *resultString = result.stringValue;
            [_delegate bumpDetector:self didReturnTimeInterval:resultString];
        }
    }
    
    else if (_motionManager.deviceMotionActive)
    {
        [_motionManager stopDeviceMotionUpdates];
        _isFirstTime = YES;
        [self updateCountdownLabelText];
        _start.backgroundColor = UserDefaults.defaults.darkGreen;
        [_start setTitle:@"Start" forState:UIControlStateNormal];
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
                _start.backgroundColor = UserDefaults.defaults.darkGreen;
                [_start setTitle:@"Start" forState:UIControlStateNormal];
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
            _start.backgroundColor = UIColor.redColor;
            [_start setTitle:@"Stop" forState:UIControlStateNormal];
            _beep.volume = 0.0;
            [_beep play];
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
        _start.backgroundColor = UserDefaults.defaults.darkGreen;
        [_start setTitle:@"Start" forState:UIControlStateNormal];
        [_start setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _start.layer.borderColor = UIColor.whiteColor.CGColor;
        [_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        _isComplete = NO;
        return;
    }
    
    if (_timer.valid)
        [_timer invalidate];
    
    if (_delegate && [_delegate respondsToSelector:@selector(bumpDetectorDidCancel:)])
        [_delegate bumpDetectorDidCancel:self];
    
    else
        [self hideBumpDetector:YES];
}

- (void)startMotionManager
{
    if (_motionManager.isDeviceMotionAvailable)
    {
        _motionManager.deviceMotionUpdateInterval = 0.1;
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
            _start.backgroundColor = UIColor.whiteColor;
            [_start setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            _start.layer.borderColor = UIColor.blackColor.CGColor;
            [_start setTitle:@"Use It" forState:UIControlStateNormal];
            [_cancel setTitle:@"Do Over" forState:UIControlStateNormal];
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
                         
                         _start.frame = CGRectMake(((frame.size.height + tabBarHeight) * 0.05),
                                                         ((frame.size.width - tabBarHeight) * 0.85),
                                                         ((frame.size.height + tabBarHeight) * 0.4),
                                                         ((frame.size.width - tabBarHeight) * 0.1));
                         
                         _cancel.frame = CGRectMake(((frame.size.height + tabBarHeight) * 0.55),
                                                         ((frame.size.width - tabBarHeight) * 0.85),
                                                         ((frame.size.height + tabBarHeight) * 0.4),
                                                         ((frame.size.width - tabBarHeight) * 0.1));
                         
                     }];
}

- (UIButton *)facButton:(NSString *)title
                    tag:(NVFacButtonType)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button addTarget:self
               action:@selector(facButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)facButtonTapped:(UIButton *)button
{
    switch (button.tag)
    {
        case NVFacButtonTypeHelp:
            break;
        case NVFacButtonTypeReference:
            break;
        case NVFacButtonTypeLink:
            break;
        case NVFacButtonTypeComment:
            break;
        default:break;
    }
}

@end
