//  NVWebKitVC.m
//  CCodeLibrary

#import "NVWebKitVC.h"
@import WebKit;
#import "UserDefaults.h"
#import "NVPopoverTableView.h"

@interface NVWebKitVC () <WKNavigationDelegate,NVPopoverTableViewDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIButton *returnButton, *realtor;
@property (nonatomic) CGFloat headerHeight, headerSideMargin;

@end

@implementation NVWebKitVC

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.grayColor;
    _headerHeight = 48.0;
    _headerSideMargin = 8.0;
    
    _webView = WKWebView.new;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.navigationDelegate = self;
    
    [self.view addSubview:_webView];
    
    [_webView constrainToView:self.view leading:0.0 trailing:0.0 top:_headerHeight bottom:0.0];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    _returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UserDefaults.defaults.appleGray
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    
    [_returnButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                constant:_headerSideMargin].active = YES;
    
    [_returnButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_returnButton.bottomAnchor constraintEqualToAnchor:_webView.topAnchor].active = YES;
    
    _realtor = [UIButton buttonWithType:UIButtonTypeCustom];
    _realtor.translatesAutoresizingMaskIntoConstraints = NO;
    _realtor.backgroundColor = UIColor.clearColor;
    _realtor.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
    
    [_realtor setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteHouse"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [_realtor addTarget:self
                 action:@selector(realtor:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_realtor];
    
    [_realtor.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                            constant:-_headerSideMargin].active = YES;
    
    [_realtor.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_realtor.heightAnchor constraintEqualToConstant:_headerHeight].active = YES;
    [_realtor.widthAnchor constraintEqualToConstant:_headerHeight].active = YES;
    
    _urlString = [NSString stringWithFormat:@"http://%@", _urlString];
    NSURL *url = [NSURL URLWithString:_urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)realtor:(UIButton *)button
{
    NSArray *realtorList = @[@"www.edinarealty.com", @"www.remax.com", @"www.trulia.com", @"www.zillow.com"];
    
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Select Realtor Website"
                                                                     textArray:realtorList
                                                                 includeCancel:YES];
#pragma unused(nvptv)
}


- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
{
    [popoverTableView hide:YES];
    
    _urlString = [NSString stringWithFormat:@"http://%@", text];
    NSURL *url = [NSURL URLWithString:_urlString];
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