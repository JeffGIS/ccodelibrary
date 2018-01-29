//  RHPlayer.m
//  CCodeLibrary

#import "RHPlayer.h"
@import AVFoundation;
#import "CRAPI.h"
#import "RHController.h"
#import "NVSpreadsheetVC.h"

void static const *playerItemContext;

@interface RHPlayer () <RHControllerDelegate,NVPeerConnectDelegate>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *item;
@property BOOL isPlaying;
@property (nonatomic) RHController *controller;
@property (nonatomic) RHClip *currentClip;
@property (nonatomic) id timeObserver;

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
    CRAPI.sharedInstance.peerConnect.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopSession];
    
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
    [CRAPI.sharedInstance.peerConnect stopBrowsing];
    
    if (_isPlaying)
    {
        [_controller stopTimer:NO];
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
                                                                  [welf controllerDidTapPlayRecordButton];
                                                              }];
                
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
                
                if (playerLayer)
                {
                    playerLayer.frame = self.view.bounds;
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    [self.view.layer addSublayer:playerLayer];
                }
                
                else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayerLayer.");}
            }
            
            else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayer.");}
        }
        
        else {NSLog(@"AVPlayer ERROR: Couldn't create AVPlayerItem.");}
    }
    
    else {NSLog(@"AVPlayer ERROR: There is no video to play.");}
    
    if (![self.view.subviews containsObject:_controller])
    {
        _controller = RHController.new;
        [_controller showInView:self.view delegate:self];
    }
    
    else
        [self.view bringSubviewToFront:_controller];
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
    [self videoStopped];
}

- (void)videoStopped
{
    _isPlaying = NO;
    [_controller stopTimer:NO];
    
    [_controller.playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                            [NSBundle.mainBundle pathForResource:@"VideoPlayIcon"
                                                                          ofType:@"png"]]
                                  forState:UIControlStateNormal];
}

- (void)controllerDidTapPlayRecordButton
{
    if (_isPlaying)
    {
        [_player pause];
        [self videoStopped];
    }
    
    else
    {
        CMTime time = CMTimeMake((_currentClip.startTime * 1000), 1000);
        [_player seekToTime:time];
        [_player play];
        [_controller startTimer];
        _isPlaying = YES;
        
        [_controller.playRecordButton setImage:[UIImage imageWithContentsOfFile:
                                                [NSBundle.mainBundle pathForResource:@"VideoStopIcon"
                                                                              ofType:@"png"]]
                                      forState:UIControlStateNormal];
    }
}

- (void)controllerDidTapConnectButton
{
    [CRAPI.sharedInstance.peerConnect startBrowsing];
}

- (void)controllerDidTapReturnButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)peerConnectDidReceiveFileAtUrl:(NSURL *)url
{
    NSError *error = nil;
    NSFileManager *fm = NSFileManager.new;
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@",
                            UserDefaults.defaults.localFilePath, url.lastPathComponent];
    
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath isDirectory:NO];
    [fm moveItemAtPath:url.path toPath:outputURL.path error:&error];
    
    CRAPI.sharedInstance.rhVideoURL = outputURL;
    [self performSelectorOnMainThread:@selector(setupVideoPlayer) withObject:nil waitUntilDone:YES];
}

@end
