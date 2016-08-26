//  NVWebView.m
//  CCodeLibrary

#import "NVWebView.h"
@import WebKit;
#import "UserDefaults.h"
#import "NVPopoverTableView.h"
#import "NVAlertView.h"
#import "CRAPI.h"

@interface NVWebView () <WKNavigationDelegate,NVPopoverTableViewDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIButton *returnButton, *realtor;
@property (nonatomic) CGFloat headerHeight, headerSideMargin, zoomScale, zoomRotation;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (nonatomic) CGPoint zoomPoint;
@property int numPages, zoomPage;
@property BOOL isFile, navigationComplete;

@end

@implementation NVWebView

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString
{
    NVWebView *nvwv = NVWebView.new;
    [nvwv addWebViewToView:view];
    nvwv.zoomPoint = CGPointZero;
    nvwv.zoomScale = nvwv.zoomRotation = 0.0;
    nvwv.numPages = nvwv.zoomPage = 1;
    nvwv.isFile = NO;
    nvwv.navigationComplete = NO;
    
    nvwv.realtor = [UIButton buttonWithType:UIButtonTypeCustom];
    nvwv.realtor.translatesAutoresizingMaskIntoConstraints = NO;
    nvwv.realtor.backgroundColor = UIColor.clearColor;
    nvwv.realtor.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
    nvwv.realtor.hidden = YES;
    
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
    
    nvwv.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    nvwv.indicator.translatesAutoresizingMaskIntoConstraints = NO;
    nvwv.indicator.transform = CGAffineTransformMakeScale(2.0, 2.0);
    [nvwv addSubview:nvwv.indicator];
    [nvwv.indicator startAnimating];
    
    [nvwv.indicator.leadingAnchor constraintEqualToAnchor:nvwv.centerXAnchor constant:(-nvwv.indicator.frame.size.width / 2.0)].active = YES;
    [nvwv.indicator.trailingAnchor constraintEqualToAnchor:nvwv.centerXAnchor constant:(nvwv.indicator.frame.size.width / 2.0)].active = YES;
    [nvwv.indicator.topAnchor constraintEqualToAnchor:nvwv.centerYAnchor constant:(-nvwv.indicator.frame.size.height / 2.0)].active = YES;
    [nvwv.indicator.bottomAnchor constraintEqualToAnchor:nvwv.centerYAnchor constant:(nvwv.indicator.frame.size.height / 2.0)].active = YES;
    
    urlString = [NSString stringWithFormat:@"http://%@", urlString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [nvwv.webView loadRequest:urlRequest];
    
    [nvwv show];
    
    return nvwv;
}

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path
{
    
    if (!path)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:view
                                                          delegate:CRAPI.sharedInstance
                                                             title:@"This file does not currently exist."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
#pragma unused(alert)
        return nil;
    }
    
    NVWebView *nvwv = NVWebView.new;
    [nvwv addWebViewToView:view];
    nvwv.zoomPoint = CGPointZero;
    nvwv.zoomScale = nvwv.zoomRotation = 0.0;
    nvwv.numPages = nvwv.zoomPage = 1;
    nvwv.isFile = YES;
    nvwv.navigationComplete = NO;
    
    NSURL *url = [NSURL fileURLWithPath:path];

    if ([path.pathExtension isEqualToString:@"pdf"] || [path.pathExtension isEqualToString:@"PDF"])
    {
        CFURLRef urlRef = (__bridge CFURLRef)url;
        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL(urlRef);
        nvwv.numPages = (int)CGPDFDocumentGetNumberOfPages(pdfRef);
        CGPDFDocumentRelease(pdfRef);
    }
    
    [nvwv.webView loadFileURL:url allowingReadAccessToURL:url];
    [nvwv show];
    
    return nvwv;
}

- (void)addWebViewToView:(UIView *)view
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = UIColor.grayColor;
    _headerHeight = 60.0;
    _headerSideMargin = 8.0;
    self.alpha = 0.0;
    
    _tabBar = view.parentViewController.tabBarController.tabBar;
    _tabBar.userInteractionEnabled = NO;
    
    [view addSubview:self];
    
    [self constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:_tabBar.frame.size.height];
    
    _webView = WKWebView.new;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.navigationDelegate = self;
    _webView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(webViewWasTapped:)];
    
    [_webView addGestureRecognizer:tapGesture];
    
    [self addSubview:_webView];
    
    [_webView constrainToView:self leading:0.0 trailing:0.0 top:_headerHeight bottom:0.0];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    _returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.lightGrayColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_returnButton];
    
    [_returnButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                constant:_headerSideMargin].active = YES;
    
    [_returnButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:20.0].active = YES;
    [_returnButton.bottomAnchor constraintEqualToAnchor:_webView.topAnchor].active = YES;
}

- (void)show
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 1.0;
                         _tabBar.alpha = 0.0;
                     }];
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

- (void)showRealtorButton
{
    _realtor.hidden = NO;
}

- (void)hideReturnButton
{
    _tabBar.userInteractionEnabled = YES;
    _tabBar.alpha = 1.0;
    [_returnButton removeFromSuperview];
    [self constrainToView:self.superview leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    [_webView constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
}

- (void)returnButtonTapped:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidReturn:)])
        [_delegate webViewDidReturn:self];
    
    else
        [self hide:YES];
}

- (void)zoomToPoint:(CGPoint)point
         withinPage:(int)page
          withScale:(CGFloat)scale
           rotation:(CGFloat)rotation
{
    _zoomPoint = point;
    _zoomPage = page;
    _zoomScale = scale;
    _zoomRotation = rotation;
    
    if (_navigationComplete)
        [self updatePosition];
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
                 atIndex:(NSInteger)index
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

- (void)updatePosition
{
    if (_zoomPage > 1)
    {
        CGFloat pageHeight = (_webView.scrollView.contentSize.height / _numPages);
        _zoomPoint.x *= _webView.scrollView.contentSize.width;
        _zoomPoint.y *= pageHeight;
        _zoomPoint.y += (pageHeight * (_zoomPage - 1));
    }
    
    CGSize zoomSize = CGSizeMake((_webView.scrollView.bounds.size.width / _zoomScale),
                                 (_webView.scrollView.bounds.size.height / _zoomScale));
    
    CGRect zoomRect = CGRectMake((_zoomPoint.x - (zoomSize.width / 2.0)),
                                 (_zoomPoint.y - (zoomSize.height / 2.0)),
                                 zoomSize.width, zoomSize.height);
    
    [_webView.scrollView zoomToRect:zoomRect
                           animated:NO];
    
    _webView.scrollView.transform = CGAffineTransformMakeRotation(_zoomRotation * DEGtoRAD);
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation
{
    [_indicator removeFromSuperview];
    [_indicator stopAnimating];
    
    if (_isFile)
    {
        _webView.scrollView.minimumZoomScale = 1.0;
        _webView.scrollView.maximumZoomScale = 100.0;
        _webView.scrollView.bouncesZoom = NO;
        _webView.scrollView.directionalLockEnabled = NO;
        _webView.scrollView.clipsToBounds = NO;
        
        [self updatePosition];
        _navigationComplete = YES;
    }
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    NSLog(@"WebView Failed Navigation ERROR:%@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    NSLog(@"WebView Failed Provisional Navigation ERROR:%@", error.localizedDescription);
}

- (void)webViewWasTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_webView.scrollView];
    CGFloat pageHeight = (_webView.scrollView.contentSize.height / _numPages);
    int pageNum = (int)ceilf(point.y / pageHeight);
    CGFloat offset = (CGFloat)(pageHeight * (pageNum - 1));
    point.y -= offset;
    
    point.x = (point.x / _webView.scrollView.contentSize.width);
    point.y = (point.y / pageHeight);
    
    if (_delegate && [_delegate respondsToSelector:@selector(webView:wasTappedAtPoint:withinPage:)])
    {
        [_delegate webView:self
          wasTappedAtPoint:point
                withinPage:pageNum];
    }
}

@end