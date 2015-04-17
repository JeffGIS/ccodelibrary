//  HelpWebView.m
//  CCodeLibrary

#import "HelpWebView.h"
#import "UserDefaults.h"
#import "GSSiPopoverView.h"

@interface HelpWebView ()

@property (nonatomic) UIWebView *webView;
@property (nonatomic) UITabBar *tabBar;

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
    helpView.webView.backgroundColor = UIColor.lightGrayColor;
    [helpView addSubview:helpView.webView];
    
    presenterID = @"ManageMyLocationMap";
    
    NSString *path = [NSBundle.mainBundle pathForResource:presenterID
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