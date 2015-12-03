//  HelpWebView.m
//  CCodeLibrary

#import "HelpWebView.h"
#import "UserDefaults.h"
#import "GSSiPopoverView.h"
#import "Y

@interface HelpWebView ()

@property (nonatomic) UIWebView *webView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) NSString *youtubeID;

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
    
    helpView.youtubeID = [presenterID stringByReplacingOccurrencesOfString:@" "
                                                                withString:@""];
    
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
    youTubeButton.frame = CGRectMake(0.0, 0.0, 160.0, 113.0);
    
    youTubeButton.center = CGPointMake((helpView.webView.frame.size.width / 2.0),
                                       (helpView.webView.frame.size.height - 60.0));
    
    [youTubeButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"YouTubeIcon"
                                                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
    
    [youTubeButton addTarget:helpView
                      action:@selector(playYouTubeVideo:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [helpView.webView addSubview:youTubeButton];
    
    NSString *path = [NSBundle.mainBundle pathForResource:helpView.youtubeID
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
                                                               NSRange range = [dataString rangeOfString:_youtubeID];
                                                               NSUInteger indexOfURL = ((range.location + _youtubeID.length) + 1);
                                                               NSString *urlString = [dataString substringFromIndex:indexOfURL];
                                                               
                                                               
                                                           }
                                                       }
                                                       
                                                       [urlSession invalidateAndCancel];
                                                   });
                                               }];
    
    [dataTask resume];
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
    CGRect frame = self.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.frame = CGRectMake(frame.origin.y, frame.origin.x,
                                                 frame.size.height, frame.size.width);
                     }];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _webView.frame = CGRectMake(0.0, 60.0, frame.size.height,
                                                     (frame.size.width - 60.0));
                     }];
}

@end