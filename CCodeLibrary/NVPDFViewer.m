//  NVPDFViewer.m
//  CCodeLibrary

#import "NVPDFViewer.h"
#import "CCodeLibrary/UserDefaults.h"
@import WebKit;

@interface NVPDFViewer ()

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation NVPDFViewer

+ (instancetype)showPDFViewerInView:(UIView *)view
                       withFileName:(NSString *)fileName
                             tabBar:(UITabBar *)tabBar
{
    NVPDFViewer *nvpdf = NVPDFViewer.new;
    nvpdf.translatesAutoresizingMaskIntoConstraints = NO;
    nvpdf.backgroundColor = UIColor.darkGrayColor;
    nvpdf.tabBar = tabBar;
    nvpdf.alpha = 0.0;
    
    [view addSubview:nvpdf];
    
    [nvpdf.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
    [nvpdf.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
    [nvpdf.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    
    [nvpdf.bottomAnchor constraintEqualToAnchor:view.bottomAnchor
                                       constant:tabBar.frame.size.height].active = YES;
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    returnButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [returnButton setTitle:@"< Return"
                  forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UserDefaults.defaults.appleBlue
                       forState:UIControlStateHighlighted];
    
    [returnButton addTarget:nvpdf
                     action:@selector(dismissPDFViewer:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [nvpdf addSubview:returnButton];
    
    [returnButton.leadingAnchor constraintEqualToAnchor:nvpdf.leadingAnchor
                                               constant:20.0].active = YES;
    
    [returnButton.topAnchor constraintEqualToAnchor:nvpdf.topAnchor
                                           constant:10.0].active = YES;
    
    nvpdf.webView = WKWebView.new;
    nvpdf.webView.translatesAutoresizingMaskIntoConstraints = NO;
    nvpdf.webView.userInteractionEnabled = YES;
    nvpdf.webView.backgroundColor = UIColor.lightGrayColor;
    
    [nvpdf addSubview:nvpdf.webView];
    
    [nvpdf.webView.leadingAnchor constraintEqualToAnchor:nvpdf.leadingAnchor].active = YES;
    [nvpdf.webView.trailingAnchor constraintEqualToAnchor:nvpdf.trailingAnchor].active = YES;
    [nvpdf.webView.bottomAnchor constraintEqualToAnchor:nvpdf.bottomAnchor].active = YES;
    [nvpdf.webView.topAnchor constraintEqualToAnchor:returnButton.bottomAnchor].active = YES;
    
    NSString *path = [NSBundle.mainBundle pathForResource:fileName
                                                   ofType:@"pdf"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [nvpdf.webView loadFileURL:url
       allowingReadAccessToURL:url];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvpdf.alpha = 1.0;
                         tabBar.alpha = 0.0;
                     }];
    
    return nvpdf;
}

- (void)dismissPDFViewer:(UIButton *)button
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                         _tabBar.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end