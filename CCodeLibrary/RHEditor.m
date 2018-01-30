//  RHEditor.m
//  CCodeLibrary

#import "RHEditor.h"
@import AVFoundation;
#import "CRAPI.h"
#import "NVTextAlert.h"
#import "NVTextViewAlert.h"
#import "NVSpreadsheetVC.h"
#import "RHClip.h"

void static const *playerItemContext;

@interface RHEditor () <NVTextAlertDelegate,NVAlertViewDelegate,NVTextViewAlertDelegate>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *item;
@property BOOL isPlaying, isAtEnd;
@property (nonatomic) BOOL inEditMode;
@property (nonatomic) id timeObserver;
@property (nonatomic) UIButton *returnButton, *placeMarkers, *stepForward, *stepBackward;
@property (nonatomic) UISlider *progressSlider;
@property (nonatomic) UIView *markupView, *beginning, *ending, *maskView;
@property (nonatomic) RHClip *currentClip;
@property int propNum;

@end

@implementation RHEditor

+ (instancetype)editorWithPropNum:(int)propNum
                         delegate:(id)delegate
{
    RHEditor *editor = RHEditor.new;
    editor.propNum = propNum;
    editor.delegate = delegate;
    editor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return editor;
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

- (void)setupVideoPlayer
{
    _isPlaying = NO;
    
    if (CRAPI.sharedInstance.rhVideoURL && CRAPI.sharedInstance.rhVideoURL.path.length)
    {
        NSError *error = nil;
        
        NSString *txtPath = [CRAPI.sharedInstance.rhVideoURL.path stringByReplacingOccurrencesOfString:@"mov"
                                                                                            withString:@"txt"];
        
        NSString *locations = [NSString stringWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {NSLog(@"Locations List ERROR: Couldn't open or doesn't exist.");}
        
        else if (locations && locations.length)
            {NSLog(@"\nLocations List:\n%@", locations);}
        
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
        width = 60.0, markupHeight = 40.0;

    [_returnButton constrainWidthToConstant:width];
    [_returnButton constrainHeightToAnchor:_returnButton.widthAnchor];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _markupView = UIView.new;
    _markupView.translatesAutoresizingMaskIntoConstraints = NO;
    _markupView.alpha = 0.5;
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
    [_placeMarkers setTitle:@"  Mark Beginning  " forState:UIControlStateNormal];
    [_placeMarkers setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_placeMarkers setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    _placeMarkers.titleLabel.font = [UIFont boldSystemFontOfSize:(markupHeight * 0.6)];
    
    [self.view addSubview:_placeMarkers];
    [_placeMarkers constrainCenterXToAnchor:self.view.centerXAnchor];
    [_placeMarkers constrainBottomToAnchor:_markupView.topAnchor constant:-(margin / 2)];
    [_placeMarkers constrainHeightToAnchor:_markupView.heightAnchor];
    
    [_placeMarkers addTarget:self
                      action:@selector(placeMarkersTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _stepForward = [UIButton buttonWithType:UIButtonTypeCustom];
    _stepForward.translatesAutoresizingMaskIntoConstraints = NO;
    _stepForward.backgroundColor = UIColor.whiteColor;
    [_stepForward setTitle:@"   +   " forState:UIControlStateNormal];
    [_stepForward setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_stepForward setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    _stepForward.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [self.view addSubview:_stepForward];
    [_stepForward constrainBottomToAnchor:_placeMarkers.bottomAnchor];
    [_stepForward constrainTopToAnchor:_placeMarkers.topAnchor];
    [_stepForward constrainLeadingToAnchor:_placeMarkers.trailingAnchor];
    
    [_stepForward addTarget:self
                     action:@selector(stepForwardTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _stepBackward = [UIButton buttonWithType:UIButtonTypeCustom];
    _stepBackward.translatesAutoresizingMaskIntoConstraints = NO;
    _stepBackward.backgroundColor = UIColor.whiteColor;
    [_stepBackward setTitle:@"   -   " forState:UIControlStateNormal];
    [_stepBackward setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_stepBackward setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    _stepBackward.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [self.view addSubview:_stepBackward];
    [_stepBackward constrainBottomToAnchor:_placeMarkers.bottomAnchor];
    [_stepBackward constrainTopToAnchor:_placeMarkers.topAnchor];
    [_stepBackward constrainTrailingToAnchor:_placeMarkers.leadingAnchor];
    
    [_stepBackward addTarget:self
                      action:@selector(stepBackwardTapped)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)playerTapped
{
    if (_inEditMode)
        return;
    
    if (_isPlaying)
    {
        [_player pause];
        [_player removeTimeObserver:_timeObserver];
    }
    
    else
    {
        if (_isAtEnd)
        {
            [_player.currentItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
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
            
            [welf updatePlaceMarkersButton];
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
    [_player.currentItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    _isAtEnd = NO;
    
    [self performSelector:@selector(updatePlaceMarkersButton) withObject:nil afterDelay:0.1];
}

- (void)progressSliderTouchUp
{
    [_progressSlider setValue:_progressSlider.value animated:NO];
}

- (void)placeMarkersTapped
{
    double time = CMTimeGetSeconds(_player.currentItem.currentTime);
    CGFloat dCenter = ((_progressSlider.maximumValue / 2) - time);
    dCenter /= (_progressSlider.maximumValue / 2);
    dCenter *= _beginning.frame.size.width;
    
    CGFloat xPos = (time / _progressSlider.maximumValue);
    xPos *= _progressSlider.frame.size.width;
    xPos += _progressSlider.frame.origin.x;
    xPos += dCenter;
    
    if ([_placeMarkers.titleLabel.text containsString:@"Beginning"])
    {
        [_markupView addSubview:_beginning];
        _beginning.center = CGPointMake(xPos, _markupView.frame.size.height / 2);
        
        _currentClip = RHClip.new;
        _currentClip.notes = @"";
        _currentClip.title = @"";
        _currentClip.startTime = time;
        _currentClip.propNum = _propNum;
        _currentClip.videoFileName = CRAPI.sharedInstance.rhVideoURL.lastPathComponent;
        
        [_placeMarkers setTitle:@"  Mark Ending  " forState:UIControlStateNormal];
    }
    
    else
    {
        if (_isPlaying)
        {
            [_player pause];
            [_player removeTimeObserver:_timeObserver];
        }
        
        [_markupView addSubview:_ending];
        _ending.center = CGPointMake(xPos, _markupView.frame.size.height / 2);
        _currentClip.endTime = time;
        
        if (!CGRectIntersectsRect(_beginning.frame, _ending.frame))
        {
            [_markupView addSubview:_maskView];
            [_maskView constrainTopToAnchor:_markupView.topAnchor];
            [_maskView constrainBottomToAnchor:_markupView.bottomAnchor];
            [_maskView constrainLeadingToAnchor:_beginning.trailingAnchor];
            [_maskView constrainTrailingToAnchor:_ending.leadingAnchor];
        }
        
        [_placeMarkers setTitle:@"  Mark Beginning  " forState:UIControlStateNormal];
        self.inEditMode = YES;
        
        NVTextAlert *alert = [NVTextAlert showTextAlertinView:self.view
                                                     delegate:self
                                                        title:@"Enter Title for this Clip"];

        alert.minimumCharacters = 0;
        alert.blockTapDismiss = YES;
    }
}

- (void)textAlert:(NVTextAlert *)textAlert
    didReturnText:(NSString *)text
{
    [textAlert hideTextAlert:NO];
    
    _currentClip.title = text;
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:@"Select Quality for this Clip"
                                               buttonTextArray:@[@"Pro", @"Con", @"Neutral"]
                                              destructiveIndex:0];
    
    alert.identifier = @"Quality";
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:NO];
    
    if ([alertView.identifier isEqualToString:@"Quality"])
    {
        switch (buttonIndex)
        {
            case 0://pro
                _currentClip.quality = RHClipQualityPro;
                break;
            case 1://con
                _currentClip.quality = RHClipQualityCon;
                break;
            case 2://neutral
                _currentClip.quality = RHClipQualityNeutral;
                break;
            default:break;
        }
        
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:@"Do You Have Notes for this Clip?"
                                                   buttonTextArray:@[@"Yes", @"No"]
                                                  destructiveIndex:0];
        
        alert.identifier = @"Notes";
    }
    
    else if ([alertView.identifier isEqualToString:@"Notes"])
    {
        if (!buttonIndex)
        {
            NVTextViewAlert *alert = [NVTextViewAlert showTextViewAlertinView:self.view
                                                                     delegate:self
                                                                        title:@"Enter Notes for this Clip"
                                                                         text:@""];
#pragma unused(alert)
        }
        
        else
            [self finishCurrentClip];
    }
}

- (void)textViewAlertDidCancel:(NVTextViewAlert *)textViewAlert
{
    [textViewAlert hideTextViewAlert:YES];
}

- (void)textViewAlert:(NVTextViewAlert *)textViewAlert
        didReturnText:(NSString *)text
{
    [textViewAlert hideTextViewAlert:YES];
    _currentClip.notes = text;
    [self finishCurrentClip];
}

- (void)finishCurrentClip
{
    if (_delegate && [_delegate respondsToSelector:@selector(addVideoClip:)])
        [_delegate addVideoClip:_currentClip];
    
    [_beginning removeFromSuperview];
    [_ending removeFromSuperview];
    [_maskView removeFromSuperview];
    
    self.inEditMode = NO;
}

- (void)stepForwardTapped
{
    if (_isPlaying)
        [self playerTapped];
    
    [_player.currentItem stepByCount:1];
    [self performSelector:@selector(updateSlider) withObject:nil afterDelay:0.1];
}

- (void)stepBackwardTapped
{
    if (_isPlaying)
        [self playerTapped];
    
    [_player.currentItem stepByCount:-1];
    [self performSelector:@selector(updateSlider) withObject:nil afterDelay:0.1];
}

- (void)updateSlider
{
    [_progressSlider setValue:CMTimeGetSeconds(_player.currentItem.currentTime)
                     animated:NO];
    
    [self updatePlaceMarkersButton];
}

- (void)updatePlaceMarkersButton
{
    if ([_placeMarkers.titleLabel.text containsString:@"Ending"])
    {
        if (CMTimeGetSeconds(_player.currentItem.currentTime) < _currentClip.startTime)
        {
            _placeMarkers.alpha = 0.5;
            _placeMarkers.userInteractionEnabled = NO;
        }
        
        else
        {
            _placeMarkers.alpha = 1.0;
            _placeMarkers.userInteractionEnabled = YES;
        }
    }
}

- (void)setInEditMode:(BOOL)inEditMode
{
    _inEditMode = inEditMode;
    _placeMarkers.hidden = _stepForward.hidden = _stepBackward.hidden = inEditMode;
}

@end
