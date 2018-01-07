//  RHEditor.m
//  CCodeLibrary

#import "RHEditor.h"
@import AVFoundation;
#import "CRAPI.h"

void static const *playerItemContext;

@interface RHEditor ()

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *item;
@property BOOL isPlaying, isAtEnd, constraintsRemoved;
@property (nonatomic) id timeObserver;
@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UISlider *progressSlider;
@property (nonatomic) UIView *markupView, *marker1, *marker2, *maskView;

@end

@implementation RHEditor

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
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
            _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
            
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            
            if (playerLayer)
            {
                playerLayer.frame = self.view.bounds;
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                [self.view.layer addSublayer:playerLayer];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(playerTapped)];
                
                [self.view addGestureRecognizer:tap];
            }
            
            else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayerLayer.");}
        }
        
        else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayerItem.");}
    }
    
    else {NSLog(@"AVPlayer ERROR: There is no video to play.");}
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
                      _player.error.localizedDescription);
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

- (void)setupControls
{
    CGFloat margin = 30.0, inset = 10.0, width = 80.0;
    CGFloat markupHeight = (margin * 1.5);
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    [_returnButton setImage:[UIImage imageWithContentsOfFile:
                             [NSBundle.mainBundle pathForResource:@"returnIcon"
                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
    
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor];
    [_returnButton constrainTopToAnchor:self.view.topAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        width = 60.0;

    [_returnButton constrainWidthToConstant:width];
    [_returnButton constrainHeightToAnchor:_returnButton.widthAnchor];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _markupView = UIView.new;
    _markupView.translatesAutoresizingMaskIntoConstraints = NO;
    _markupView.alpha = 0.4;
    _markupView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_markupView];
    [_markupView constrainLeadingToAnchor:self.view.leadingAnchor];
    [_markupView constrainTrailingToAnchor:self.view.trailingAnchor];
    [_markupView constrainBottomToAnchor:self.view.bottomAnchor];
    [_markupView constrainHeightToConstant:markupHeight];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(markupTapped:)];
    
    [_markupView addGestureRecognizer:tap];
    
    _marker1 = UIView.new;
    _marker1.backgroundColor = UIColor.redColor;
    _marker1.frame = CGRectMake(0.0, 0.0, 40.0, markupHeight);
    
    UIView *line1 = UIView.new;
    line1.translatesAutoresizingMaskIntoConstraints = NO;
    line1.backgroundColor = UserDefaults.defaults.appleBlue;
    [_marker1 addSubview:line1];
    [line1 constrainToView:_marker1 leading:15.0 trailing:-15.0 top:0.0 bottom:0.0];
    
    _marker2 = UIView.new;
    _marker2.backgroundColor = UIColor.redColor;
    _marker2.frame = CGRectMake(0.0, 0.0, 40.0, markupHeight);
    
    UIView *line2 = UIView.new;
    line2.translatesAutoresizingMaskIntoConstraints = NO;
    line2.backgroundColor = UserDefaults.defaults.appleBlue;
    [_marker2 addSubview:line2];
    [line2 constrainToView:_marker2 leading:15.0 trailing:-15.0 top:0.0 bottom:0.0];
    
    _maskView = UIView.new;
    _maskView.translatesAutoresizingMaskIntoConstraints = NO;
    _maskView.backgroundColor = UIColor.grayColor;
    
    _progressSlider = UISlider.new;
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _progressSlider.maximumValue = CMTimeGetSeconds(_player.currentItem.asset.duration);
    
    [self.view addSubview:_progressSlider];
    [_progressSlider constrainLeadingToAnchor:_markupView.leadingAnchor constant:margin];
    [_progressSlider constrainTrailingToAnchor:_markupView.trailingAnchor constant:-margin];
    [_progressSlider constrainBottomToAnchor:_markupView.topAnchor];
    
    [_progressSlider addTarget:self
                        action:@selector(progressSliderValueChanged)
              forControlEvents:UIControlEventValueChanged];
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
            [_player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [_progressSlider setValue:0.0 animated:NO];
            _isAtEnd = NO;
        }
        
        [_player play];
        
        __weak __typeof(self)welf = self;
        
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 50) queue:NULL
                                                         usingBlock:^(CMTime time)
        {
            [welf.progressSlider setValue:CMTimeGetSeconds(welf.player.currentTime)
                                 animated:NO];
        }];
    }
    
    _isPlaying = !_isPlaying;
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
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    _isAtEnd = NO;
}

- (void)markupTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = CGPointMake([gesture locationInView:_markupView].x,
                                _markupView.frame.size.height / 2);
    
    if (![_markupView.subviews containsObject:_marker1])
    {
        _marker1.center = point;
        [_markupView addSubview:_marker1];
    }
    
    else if (![_markupView.subviews containsObject:_marker2])
    {
        _marker2.center = point;
        [_markupView addSubview:_marker2];
        [_markupView addSubview:_maskView];
        [self updateMaskConstraints];
        
        SEL sel = @selector(markerPanned:);
        
        UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:sel];
        
        [_marker1 addGestureRecognizer:pan1];
        
        UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:sel];
        
        [_marker2 addGestureRecognizer:pan2];
    }
}

- (void)markerPanned:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view];
    
    CGFloat xPos = MIN(MAX((gesture.view.center.x + translation.x), CGRectGetMinX(_progressSlider.frame)),
                       CGRectGetMaxX(_progressSlider.frame));
    
    gesture.view.center = CGPointMake(xPos, gesture.view.center.y);
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    if (CGRectIntersectsRect(_marker1.frame, _marker2.frame))
    {
        [_maskView removeAllConstraints];
        _constraintsRemoved = YES;
    }
    
    else if (_constraintsRemoved)
        [self updateMaskConstraints];
}

- (void)updateMaskConstraints
{
    [_maskView constrainTopToAnchor:_markupView.topAnchor];
    [_maskView constrainBottomToAnchor:_markupView.bottomAnchor];
    
    if (CGRectGetMaxX(_marker1.frame) < CGRectGetMinX(_marker2.frame))
    {
        [_maskView constrainLeadingToAnchor:_marker1.trailingAnchor];
        [_maskView constrainTrailingToAnchor:_marker2.leadingAnchor];
        _constraintsRemoved = NO;
    }
    
    else if (CGRectGetMaxX(_marker2.frame) < CGRectGetMinX(_marker1.frame))
    {
        [_maskView constrainLeadingToAnchor:_marker2.trailingAnchor];
        [_maskView constrainTrailingToAnchor:_marker1.leadingAnchor];
        _constraintsRemoved = NO;
    }
    
    else
        _constraintsRemoved = YES;
}

@end
