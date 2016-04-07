//  NVWebView.m
//  CCodeLibrary

#import "NVWebView.h"
@import WebKit;
#import "UserDefaults.h"
#import "NVPopoverTableView.h"

@interface NVWebView () <WKNavigationDelegate,NVPopoverTableViewDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIButton *returnButton, *realtor;
@property (nonatomic) CGFloat headerHeight, headerSideMargin;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation NVWebView

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString
{
    NVWebView *nvwv = NVWebView.new;
    nvwv.translatesAutoresizingMaskIntoConstraints = NO;
    nvwv.backgroundColor = UIColor.grayColor;
    nvwv.headerHeight = 48.0;
    nvwv.headerSideMargin = 8.0;
    nvwv.alpha = 0.0;
    
    nvwv.tabBar = view.parentViewController.tabBarController.tabBar;
    nvwv.tabBar.userInteractionEnabled = NO;
    
    [view addSubview:nvwv];
    
    [nvwv constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:nvwv.tabBar.frame.size.height];
    
    nvwv.webView = WKWebView.new;
    nvwv.webView.translatesAutoresizingMaskIntoConstraints = NO;
    nvwv.webView.allowsBackForwardNavigationGestures = YES;
    nvwv.webView.navigationDelegate = self;
    
    [nvwv addSubview:nvwv.webView];
    
    [nvwv.webView constrainToView:nvwv leading:0.0 trailing:0.0 top:nvwv.headerHeight bottom:0.0];
    
    nvwv.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nvwv.returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    nvwv.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    nvwv.returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    nvwv.returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [nvwv.returnButton setTitle:@"< Return"
                       forState:UIControlStateNormal];
    
    [nvwv.returnButton setTitleColor:UIColor.whiteColor
                            forState:UIControlStateNormal];
    
    [nvwv.returnButton setTitleColor:UserDefaults.defaults.appleGray
                            forState:UIControlStateHighlighted];
    
    [nvwv.returnButton addTarget:nvwv
                          action:@selector(returnButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [nvwv addSubview:nvwv.returnButton];
    
    [nvwv.returnButton.leadingAnchor constraintEqualToAnchor:nvwv.leadingAnchor
                                                    constant:nvwv.headerSideMargin].active = YES;
    
    [nvwv.returnButton.topAnchor constraintEqualToAnchor:nvwv.topAnchor].active = YES;
    [nvwv.returnButton.bottomAnchor constraintEqualToAnchor:nvwv.webView.topAnchor].active = YES;
    
    nvwv.realtor = [UIButton buttonWithType:UIButtonTypeCustom];
    nvwv.realtor.translatesAutoresizingMaskIntoConstraints = NO;
    nvwv.realtor.backgroundColor = UIColor.clearColor;
    nvwv.realtor.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
    
    [nvwv.realtor setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteHouse"
                                                                                          ofType:@"png"]]
                  forState:UIControlStateNormal];
    
    [nvwv.realtor addTarget:nvwv
                     action:@selector(realtor:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [nvwv addSubview:nvwv.realtor];
    
    [nvwv.realtor.trailingAnchor constraintEqualToAnchor:nvwv.trailingAnchor
                                            constant:-nvwv.headerSideMargin].active = YES;
    
    [nvwv.realtor.topAnchor constraintEqualToAnchor:nvwv.topAnchor].active = YES;
    [nvwv.realtor.heightAnchor constraintEqualToConstant:nvwv.headerHeight].active = YES;
    [nvwv.realtor.widthAnchor constraintEqualToConstant:nvwv.headerHeight].active = YES;
    
    urlString = [NSString stringWithFormat:@"http://%@", urlString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [nvwv.webView loadRequest:urlRequest];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvwv.alpha = 1.0;
                         nvwv.tabBar.alpha = 0.0;
                     }];
    
    return nvwv;
}

- (void)hide:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                             _tabBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             _tabBar.userInteractionEnabled = YES;
                         }];
    }
    
    else
    {
        [self removeFromSuperview];
        _tabBar.userInteractionEnabled = YES;
    }
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self hide:YES];
}

- (void)realtor:(UIButton *)button
{
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self
                                                                      delegate:self
                                                                         title:@"Select Realtor Website"
                                                                     textArray:UserDefaults.defaults.realtorList
                                                                 includeCancel:YES];
#pragma unused(nvptv)
}


- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
{
    [popoverTableView hide:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@", text];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
}

- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView
{
    [popoverTableView hide:YES];
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    NSLog(@"WebView ERROR:%@", error.localizedDescription);
}

@end