//  RHPlayer.m
//  CCodeLibrary

#import "RHPlayer.h"
@import AVFoundation;
#import "CRAPI.h"
#import "RHController.h"
#import "NVSpreadsheetVC.h"

void static const *playerItemContext;

@interface RHPlayer ()

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *item;
@property BOOL isPlaying, isAtEnd;
@property (nonatomic) RHClip *currentClip;
@property (nonatomic) id timeObserver;
@property (nonatomic) UIButton *returnButton, *stepForward, *stepBackward;
@property (nonatomic) UISlider *progressSlider;

@end

@implementation RHPlayer

+ (instancetype)playerWithClip:(RHClip *)clip
                      delegate:(id)delegate
{
    RHPlayer *player = RHPlayer.new;
    player.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    player.delegate = delegate;
    player.currentClip = clip;
    return player;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_delegate && [_delegate respondsToSelector:@selector(vidDirForPropNum:)])
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@",
                          [_delegate vidDirForPropNum:_currentClip.propNum],
                          _currentClip.videoFileName];
        
        CRAPI.sharedInstance.rhVideoURL = [NSURL fileURLWithPath:path isDirectory:NO];
    }
    
    else {NSLog(@"ERROR: VidDirForPropNum method not implemented by delegate.");}
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(resignedActive:)
                                               name:@"didResignActive"
                                             object:nil];
}

- (void)resignedActive:(id)selector
{
    [self stopSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupVideoPlayer];
    [self setupControls];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isPlaying)
    {
        [_player pause];
        [_player removeTimeObserver:_timeObserver];
    }
    
    [_item removeObserver:self
               forKeyPath:@"status"
                  context:&playerItemContext];
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:AVPlayerItemDidPlayToEndTimeNotification
                                                object:_item];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)stopSession
{
    if (_isPlaying)
    {
        [_player pause];
    }
    
    _isPlaying = NO;
}

- (void)setupVideoPlayer
{
    _isPlaying = NO;
    
    if (CRAPI.sharedInstance.rhVideoURL && CRAPI.sharedInstance.rhVideoURL.path.length)
    {
        AVAsset *asset = [AVAsset assetWithURL:CRAPI.sharedInstance.rhVideoURL];
        NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
        
        _item = [AVPlayerItem playerItemWithAsset:asset
                     automaticallyLoadedAssetKeys:assetKeys];
        
        if (_item)
        {
            NSKeyValueObservingOptions options =
            NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
            
            [_item addObserver:self
                    forKeyPath:@"status"
                       options:options
                       context:&playerItemContext];
            
            [NSNotificationCenter.defaultCenter addObserver:self
                                                   selector:@selector(playerDidFinishPlaying:)
                                                       name:AVPlayerItemDidPlayToEndTimeNotification
                                                     object:_item];
            
            _player = [AVPlayer playerWithPlayerItem:_item];
            
            if (_player)
            {
                _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
                CMTime endTime = CMTimeMake((_currentClip.endTime * 1000), 1000);
                NSMutableArray<NSValue *> *times = NSMutableArray.array;
                [times addObject:[NSValue valueWithCMTime:endTime]];
                __weak __typeof(self)welf = self;
                
                _timeObserver = [_player addBoundaryTimeObserverForTimes:times queue:NULL
                                usingBlock:^{
                                    [welf playerTapped];
                                    [welf.progressSlider setValue:welf.progressSlider.maximumValue
                                                         animated:NO];
                                    welf.isAtEnd = YES;
                                }];
                
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
                
                if (playerLayer)
                {
                    playerLayer.frame = self.view.bounds;
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    [self.view.layer addSublayer:playerLayer];
                    
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(playerTapped)];
                    
                    [self.view addGestureRecognizer:tap];
                    [self setStartPosition];
                }
                
                else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayerLayer.");}
            }
            
            else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayer.");}
        }
        
        else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayerItem.");}
    }
    
    else {NSLog(@"AVPlayer ERROR: There is no video to play.");}
}

- (void)setupControls
{
    CGFloat margin = 10.0, width = 80.0, height = 60.0, insets = 4.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        width = 60.0, height = 45.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.imageEdgeInsets = UIEdgeInsetsMake(insets, insets, insets, insets);
    _returnButton.backgroundColor = UIColor.blackColor;
    
    [_returnButton setImage:[UIImage imageWithContentsOfFile:
                             [NSBundle.mainBundle pathForResource:@"returnIcon"
                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
    
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_returnButton constrainTopToAnchor:self.view.topAnchor constant:margin];
    [_returnButton constrainWidthToConstant:width];
    [_returnButton constrainHeightToConstant:height];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _stepForward = [UIButton buttonWithType:UIButtonTypeCustom];
    _stepForward.translatesAutoresizingMaskIntoConstraints = NO;
    _stepForward.backgroundColor = UIColor.blackColor;
    [_stepForward setTitle:@"  +  " forState:UIControlStateNormal];
    [_stepForward setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_stepForward setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    _stepForward.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [self.view addSubview:_stepForward];
    [_stepForward constrainBottomToAnchor:self.view.bottomAnchor constant:-margin];
    [_stepForward constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_stepForward constrainHeightToConstant:height];
    
    [_stepForward addTarget:self
                     action:@selector(stepForwardTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _stepBackward = [UIButton buttonWithType:UIButtonTypeCustom];
    _stepBackward.translatesAutoresizingMaskIntoConstraints = NO;
    _stepBackward.backgroundColor = UIColor.blackColor;
    [_stepBackward setTitle:@"  -  " forState:UIControlStateNormal];
    [_stepBackward setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_stepBackward setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    _stepBackward.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [self.view addSubview:_stepBackward];
    [_stepBackward constrainBottomToAnchor:_stepForward.bottomAnchor];
    [_stepBackward constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_stepBackward constrainHeightToAnchor:_stepForward.heightAnchor];
    
    [_stepBackward addTarget:self
                      action:@selector(stepBackwardTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _progressSlider = UISlider.new;
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _progressSlider.minimumValue = _currentClip.startTime;
    _progressSlider.maximumValue = _currentClip.endTime;
    [_progressSlider setValue:_progressSlider.minimumValue animated:NO];
    
    [self.view addSubview:_progressSlider];
    [_progressSlider constrainLeadingToAnchor:_stepBackward.trailingAnchor constant:margin];
    [_progressSlider constrainTrailingToAnchor:_stepForward.leadingAnchor constant:-margin];
    [_progressSlider constrainBottomToAnchor:_stepForward.bottomAnchor];
    [_progressSlider constrainHeightToAnchor:_stepForward.heightAnchor];
    
    [_progressSlider addTarget:self
                        action:@selector(progressSliderValueChanged)
              forControlEvents:UIControlEventValueChanged];
    
    [_progressSlider addTarget:self
                        action:@selector(progressSliderTouchUp)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if (context != &playerItemContext)
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        
        if ([statusNumber isKindOfClass:NSNumber.class])
            status = statusNumber.integerValue;
        
        switch (status)
        {
            case AVPlayerItemStatusReadyToPlay:
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"AVPlayer ERROR: Player status failed: %@.",
                      _item.error.localizedDescription);
                break;
            case AVPlayerItemStatusUnknown:
                break;
        }
    }
}

- (void)playerDidFinishPlaying:(AVPlayerItem *)item
{
    [_player removeTimeObserver:_timeObserver];
    _isPlaying = NO;
    _isAtEnd = YES;
}

- (void)setStartPosition
{
    CMTime time = CMTimeMake((_currentClip.startTime * 1000), 1000);
    [_player.currentItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [_progressSlider setValue:0.0 animated:NO];
}

- (void)playerTapped
{
    if (_isPlaying)
    {
        [_player pause];
        [_player removeTimeObserver:_timeObserver];
    }
    
    else
    {
        if (_isAtEnd)
        {
            [self setStartPosition];
            _isAtEnd = NO;
        }
        
        [_player play];
        
        __weak __typeof(self)welf = self;
        
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 50) queue:NULL
                                                         usingBlock:^(CMTime time)
                         {
                             [welf.progressSlider setValue:CMTimeGetSeconds(welf.player.currentItem.currentTime)
                                                  animated:NO];
                         }];
    }
    
    _isPlaying = !_isPlaying;
    [self setStepperHidden:_isPlaying];
}

- (void)returnButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)progressSliderValueChanged
{
    if (_isPlaying)
        [self playerTapped];
    
    CMTime time = CMTimeMake((_progressSlider.value * 1000), 1000);
    [_player.currentItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)progressSliderTouchUp
{
    [_progressSlider setValue:_progressSlider.value animated:NO];
}

- (void)setStepperHidden:(BOOL)hidden
{
    _stepBackward.hidden = hidden;
    _stepForward.hidden = hidden;
}

- (void)stepForwardTapped
{
    if (CMTimeGetSeconds(_player.currentItem.currentTime) < _currentClip.endTime)
    {
        [_player.currentItem stepByCount:1];
        [self performSelector:@selector(updateSlider) withObject:nil afterDelay:0.1];
    }
}

- (void)stepBackwardTapped
{
    if (CMTimeGetSeconds(_player.currentItem.currentTime) > _currentClip.startTime)
    {
        [_player.currentItem stepByCount:-1];
        [self performSelector:@selector(updateSlider) withObject:nil afterDelay:0.1];
        _isAtEnd = NO;
    }
}

- (void)updateSlider
{
    [_progressSlider setValue:CMTimeGetSeconds(_player.currentItem.currentTime)
                     animated:NO];
}

@end
