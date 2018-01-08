//  RHEditor.m
//  CCodeLibrary

#import "RHEditor.h"
@import AVFoundation;
#import "CRAPI.h"

void static const *playerItemContext;

@interface RHEditor ()

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *item;
@property BOOL isPlaying, isAtEnd;
@property (nonatomic) id timeObserver;
@property (nonatomic) UIButton *returnButton, *placeMarkers;
@property (nonatomic) UISlider *progressSlider;
@property (nonatomic) UIView *markupView, *beginning, *ending, *maskView;

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
    CGFloat margin = 10.0, width = 80.0, markupHeight = 50.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    
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
    [_markupView constrainBottomToAnchor:self.view.bottomAnchor constant:-margin];
    [_markupView constrainHeightToConstant:markupHeight];
    
    _beginning = UIView.new;
    _beginning.backgroundColor = UIColor.greenColor;
    _beginning.frame = CGRectMake(0.0, 0.0, 10.0, markupHeight);
    
    _ending = UIView.new;
    _ending.backgroundColor = UIColor.redColor;
    _ending.frame = CGRectMake(0.0, 0.0, 10.0, markupHeight);
    
    _maskView = UIView.new;
    _maskView.translatesAutoresizingMaskIntoConstraints = NO;
    _maskView.backgroundColor = UIColor.grayColor;
    
    _progressSlider = UISlider.new;
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _progressSlider.maximumValue = CMTimeGetSeconds(_player.currentItem.asset.duration);
    
    [self.view addSubview:_progressSlider];
    
    [_progressSlider constrainToView:_markupView leading:(margin * 2)
                            trailing:-(margin * 2) top:0.0 bottom:0.0];
    
    [_progressSlider addTarget:self
                        action:@selector(progressSliderValueChanged)
              forControlEvents:UIControlEventValueChanged];
    
    [_progressSlider addTarget:self
                        action:@selector(progressSliderTouchUp)
              forControlEvents:UIControlEventTouchUpInside];
    
    _placeMarkers = [UIButton buttonWithType:UIButtonTypeCustom];
    _placeMarkers.translatesAutoresizingMaskIntoConstraints = NO;
    _placeMarkers.backgroundColor = UIColor.blackColor;
    [_placeMarkers setTitle:@"Mark Beginning" forState:UIControlStateNormal];
    [_placeMarkers setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_placeMarkers setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    _placeMarkers.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [self.view addSubview:_placeMarkers];
    [_placeMarkers constrainCenterXToAnchor:self.view.centerXAnchor];
    [_placeMarkers constrainBottomToAnchor:_markupView.topAnchor constant:-margin];
    [_placeMarkers constrainHeightToAnchor:_markupView.heightAnchor];
    
    [_placeMarkers addTarget:self
                      action:@selector(placeMarkersTapped)
            forControlEvents:UIControlEventTouchUpInside];
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

- (void)progressSliderTouchUp
{
    [_progressSlider setValue:_progressSlider.value animated:NO];
}

- (void)placeMarkersTapped
{
    double time = CMTimeGetSeconds(_player.currentTime);
    CGFloat dCenter = ((_progressSlider.maximumValue / 2) - time);
    dCenter /= (_progressSlider.maximumValue / 2);
    dCenter *= _beginning.frame.size.width;
    
    CGFloat xPos = (time / _progressSlider.maximumValue);
    xPos *= _progressSlider.frame.size.width;
    xPos += _progressSlider.frame.origin.x;
    xPos += dCenter;
    
    if ([_placeMarkers.titleLabel.text isEqualToString:@"Mark Beginning"])
    {
        [_markupView addSubview:_beginning];
        _beginning.center = CGPointMake(xPos, _markupView.frame.size.height / 2);
        
        [_placeMarkers setTitle:@"Mark Ending" forState:UIControlStateNormal];
    }
    
    else
    {
        [_markupView addSubview:_ending];
        _ending.center = CGPointMake(xPos, _markupView.frame.size.height / 2);
        
        [_markupView addSubview:_maskView];
        [_maskView constrainTopToAnchor:_markupView.topAnchor];
        [_maskView constrainBottomToAnchor:_markupView.bottomAnchor];
        [_maskView constrainLeadingToAnchor:_beginning.trailingAnchor];
        [_maskView constrainTrailingToAnchor:_ending.leadingAnchor];
        
        _placeMarkers.hidden = YES;
    }
}

@end
