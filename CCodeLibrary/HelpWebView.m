//  HelpWebView.m
//  CCodeLibrary

#import "HelpWebView.h"
#import "UserDefaults.h"
#import "GSSiPopoverView.h"
@import MediaPlayer;

@interface HelpWebView ()

@property (nonatomic) UIWebView *webView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) MPMoviePlayerController *mpController;

@end

@implementation HelpWebView

+ (HelpWebView *)showHelpWebView:(UIView *)view
                     presenterID:(NSString *)presenterID
                          tabBar:(UITabBar *)tabBar
{
    UIScreen *screen = UIScreen.mainScreen;
    
    HelpWebView *helpView = [[HelpWebView alloc] initWithFrame:screen.bounds];
    helpView.backgroundColor = UIColor.darkGrayColor;
    helpView.alpha = 0.0;
    helpView.tabBar = tabBar;
    
    [view addSubview:helpView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 20.0, 160.0, 40.0)];
    
    returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    returnButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    
    [returnButton setTitle:@"< Return"
                  forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UserDefaults.defaults.appleBlue
                       forState:UIControlStateHighlighted];
    
    [returnButton addTarget:helpView
                     action:@selector(dismissHelp:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [helpView addSubview:returnButton];
    
    helpView.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 60.0,
                                                                   helpView.frame.size.width,
                                                                   helpView.frame.size.height - 60.0)];
    helpView.webView.scalesPageToFit = YES;
    helpView.webView.userInteractionEnabled = YES;
    helpView.webView.allowsInlineMediaPlayback = YES;
    helpView.webView.mediaPlaybackRequiresUserAction = NO;
    helpView.webView.backgroundColor = UIColor.lightGrayColor;
    [helpView addSubview:helpView.webView];
    
    UIButton *youTubeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    youTubeButton.frame = CGRectMake(0.0, 0.0, 90.0, 90.0);
    
    youTubeButton.center = CGPointMake((helpView.webView.frame.size.width / 2.0),
                                       (helpView.webView.frame.size.height - 45.0));
    
    [youTubeButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"videoplaybutton"
                                                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
    
    [youTubeButton addTarget:helpView
                      action:@selector(playVideo:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [helpView.webView addSubview:youTubeButton];
    
    NSString *path = [NSBundle.mainBundle pathForResource:[presenterID stringByReplacingOccurrencesOfString:@" "
                                                                                                 withString:@""]
                                                   ofType:@"pdf"];
    
    if (!path)
    {
        GSSiPopoverView *popover = [[GSSiPopoverView alloc] initWithView:helpView];
        popover.progressView.hidden = YES;
        popover.userInteractionEnabled = NO;
        helpView.webView.userInteractionEnabled = NO;
        
        popover.popoverLabel.frame = CGRectMake(0.0, 0.0,
                                                popover.popover.frame.size.width,
                                                popover.popover.frame.size.height);
        
        popover.popoverLabel.font = [UIFont boldSystemFontOfSize:48.0];
        
        [popover showAfter:0.0
                 withTitle:[NSString stringWithFormat:@"No help file exists at this time for %@", presenterID]
                 andButton:nil];
    }
    
    else
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSData *pdfData = [[NSData alloc] initWithContentsOfURL:url];
        
        [helpView.webView loadData:pdfData
                          MIMEType:@"application/pdf"
                  textEncodingName:@"UTF-8"
                           baseURL:url];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         helpView.alpha = 1.0;
                         tabBar.alpha = 0.0;
                     }];
    
    return helpView;
}

- (void)playVideo:(UIButton *)button
{
    NSURL *videoURL = [NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"ODR_CRISInventoryScreen"
                                                                           ofType:@"mp4"]];
    
    _mpController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    
    _mpController.controlStyle = MPMovieControlStyleFullscreen;
    [_mpController prepareToPlay];
    
    UIWindow *backgroundWindow = UIApplication.sharedApplication.keyWindow;
    
    _mpController.view.frame = backgroundWindow.frame;
    [backgroundWindow addSubview:_mpController.view];
    
    UIView *statusBarBlocker = [[UIView alloc] initWithFrame:
                                CGRectMake(0.0, 0.0, backgroundWindow.frame.size.width, 20.0)];
    
    statusBarBlocker.backgroundColor = UIColor.blackColor;
    [backgroundWindow addSubview:statusBarBlocker];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(promoVideoFinished:)
                                               name:MPMoviePlayerPlaybackDidFinishNotification
                                             object:_mpController];
    
    [_mpController play];
}

- (void)promoVideoFinished:(NSNotification *)notification
{
    [_mpController.view removeFromSuperview];
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
                                                object:_mpController];
    
    _mpController = nil;
}

- (void)dismissHelp:(UIButton *)button
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                         _tabBar.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight
{
    UIWindow *backgroundWindow = UIApplication.sharedApplication.keyWindow;
    
    if ([backgroundWindow.subviews containsObject:_mpController.view])
    {
        [UIView animateWithDuration:duration animations:^{
            _mpController.view.frame = CGRectMake(0.0, 0.0, backgroundWindow.frame.size.height,
                                                  backgroundWindow.frame.size.width);
        }];
    }
}

/*
- (void)playYouTubeVideo:(UIButton *)button
{
    NSURL *url = [NSURL URLWithString:@"ftp://waypoint:pointway4*@thmgis.com/Bill/YouTubeURLs.txt"];
    NSURLSession *urlSession = NSURLSession.sharedSession;
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url
                                               completionHandler:^(NSData * _Nullable data,
                                                                   NSURLResponse * _Nullable response,
                                                                   NSError * _Nullable error) {
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (error)
                                                       {
                                                           NSLog(@"YouTube URL Request ERROR from %@:%@",
                                                                 url.description, error.localizedDescription);
                                                       }
                                                       
                                                       else
                                                       {
                                                           NSString *dataString = [[NSString alloc] initWithData:data
                                                                                                        encoding:NSUTF8StringEncoding];
                                                           
                                                           if ([dataString containsString:_youtubeID])
                                                           {
                                                               NSArray *urlArray = [dataString componentsSeparatedByString:@"\n"];
                                                               NSString *urlString = @"";
                                                               
                                                               for (int i = 0; i < urlArray.count; i++)
                                                               {
                                                                   NSString *ytURL = urlArray[i];
                                                                   NSRange range = [ytURL rangeOfString:@"\t"];
                                                                   NSUInteger index = range.location;
                                                                   
                                                                   if ([[ytURL substringToIndex:index] isEqualToString:_youtubeID])
                                                                   {
                                                                       urlString = [ytURL substringFromIndex:index];
                                                                       break;
                                                                   }
                                                               }
                                                               
                                                               YTPlayerView *youTubePlayer = [[YTPlayerView alloc] initWithFrame:_webView.frame];
                                                               youTubePlayer.playbackQuality = kYTPlaybackQualityAuto;
                                                               youTubePlayer.delegate = self;
                                                               [self addSubview:youTubePlayer];
                                                               
                                                               [youTubePlayer loadWithVideoId:urlString];
                                                           }
                                                       }
                                                       
                                                       [urlSession invalidateAndCancel];
                                                   });
                                               }];
    
    [dataTask resume];
}

- (UIColor *)playerViewPreferredWebViewBackgroundColor:(YTPlayerView *)playerView
{
    return UIColor.blackColor;
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [playerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView
  didChangeToState:(YTPlayerState)state
{
    if (state == kYTPlayerStateEnded)
        [playerView removeFromSuperview];
}
*/

@end