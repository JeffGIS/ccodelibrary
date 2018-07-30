//  NVWebView.m
//  CCodeLibrary

#import "NVWebView.h"
#import "NVPopoverTableView.h"
#import "NVAlertView.h"
#import "CRAPI.h"
#import "SymbolDictionary.h"

@implementation NVWebViewMarker

@end

@implementation NVEllipseView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = UIColor.clearColor;
        self.alpha = 0.4;
        _fillColor = UIColor.redColor;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
    CGContextFillEllipseInRect(context, rect);
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

@end

@interface NVWebView () <WKNavigationDelegate,WKUIDelegate,NVPopoverTableViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIButton *returnButton, *realtor, *nextButton, *previousButton;
@property CGFloat headerHeight, headerSideMargin, zoomScale, zoomRotation;
@property CGFloat origScale, origRotation, markerSize, fontSize, aspectRatio, lastScale;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property CGPoint zoomPoint, origPoint;
@property int zoomPage, origPage, markerPage;
@property BOOL isFile, navigationComplete, zoomToPDFDrawing, enableSwipe;
@property (nonatomic) NVPDFDrawing *drawing;
@property (nonatomic) NVWebViewMarker *marker;
@property (nonatomic) NSMutableArray<NVWebViewMarker *> *markers;
@property (nonatomic) NSMutableArray<CAShapeLayer *> *lines, *symbols, *polylines, *polygons;
@property (nonatomic) NSMutableArray<NSArray<DPoint *> *> *symbolPoints, *polylinePoints, *polygonPoints;
@property DPOINT markerPosition, ul, lr, frameUL, frameLR;
@property (nonatomic) CAShapeLayer *polygon;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic, copy) NSString *highlights;
@property (nonatomic) UIView *overlay;

@end

@implementation NVWebView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _zoomPoint = CGPointZero;
        _zoomScale = _lastScale = 1.0;
        _zoomRotation = 0.0;
        _numPages = _zoomPage = 1;
        _navigationComplete = _zoomToPDFDrawing = _drawsMarkers = NO;
        _rotationEnabled = _drawsMultipleMarkers = _enableSwipe = NO;
        _markerSize = 20.0;
        _fontSize = 32.0;
        _polygon = CAShapeLayer.layer;
        _polygon.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
        _polygon.position = CGPointZero;
    }
    
    return self;
}

- (void)dealloc
{
    [_webView stopLoading];
    _scrollView.delegate = nil;
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
    _scrollView = nil;
    [_webView removeFromSuperview];
    _webView = nil;
}

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString
{
    if (urlString && urlString.length)
    {
        NVWebView *nvwv = NVWebView.new;
        [nvwv setupViewComponents:view];
        [nvwv addWebViewToView:view];
        nvwv.isFile = NO;
        
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
        [nvwv.realtor constrainTrailingToAnchor:nvwv.trailingAnchor constant:-nvwv.headerSideMargin];
        [nvwv.realtor constrainTopToAnchor:nvwv.topAnchor];
        [nvwv.realtor constrainHeightToConstant:nvwv.headerHeight];
        [nvwv.realtor constrainWidthToConstant:nvwv.headerHeight];
        
        nvwv.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        nvwv.indicator.translatesAutoresizingMaskIntoConstraints = NO;
        nvwv.indicator.transform = CGAffineTransformMakeScale(2.0, 2.0);
        [nvwv addSubview:nvwv.indicator];
        [nvwv.indicator startAnimating];
        
        [nvwv.indicator constrainLeadingToAnchor:nvwv.centerXAnchor constant:(-nvwv.indicator.frame.size.width / 2.0)];
        [nvwv.indicator constrainTrailingToAnchor:nvwv.centerXAnchor constant:(nvwv.indicator.frame.size.width / 2.0)];
        [nvwv.indicator constrainTopToAnchor:nvwv.centerYAnchor constant:(-nvwv.indicator.frame.size.height / 2.0)];
        [nvwv.indicator constrainBottomToAnchor:nvwv.centerYAnchor constant:(nvwv.indicator.frame.size.height / 2.0)];
        
        if (![urlString containsString:@"http://"] && ![urlString containsString:@"https://"])
            urlString = [NSString stringWithFormat:@"http://%@", urlString];
        
        NSLog(@"WebView Request to URL: %@", urlString);
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [nvwv.webView loadRequest:urlRequest];
        [nvwv show];
        
        return nvwv;
    }
    
    else
    {
        NSLog(@"NVWebview ERROR:cannot set URL to nil.");
        return nil;
    }
}

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path
                         delegate:(id)delegate
{
    if (!path || !path.length)
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
    [nvwv setupViewComponents:view];
    NSString *type = path.pathExtension.lowercaseString;
    NSString *name = path.stringByDeletingPathExtension;
    name = name.lastPathComponent;
    
    if (delegate)
        nvwv.delegate = delegate;
    
    if ([type isEqualToString:@"jpg"] || [type isEqualToString:@"png"])
        [nvwv addImageToView:view path:path];
    
    else
        [nvwv addWebViewToView:view];
    
    nvwv.isFile = YES;
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    NSError *error = nil;
    
    if (![url checkResourceIsReachableAndReturnError:&error])
        showAlert([NSString stringWithFormat:@"PDF resource not available at %@", path]);
    
    else if ([type isEqualToString:@"pdf"])
    {
        if ([name containsString:@"NVCRISHelp"] || [name containsString:@"VersionHistory"])
            nvwv.isFile = NO;
        
        else
        {
            CFURLRef urlRef = (__bridge CFURLRef)url;
            CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL(urlRef);
            nvwv.numPages = (int)CGPDFDocumentGetNumberOfPages(pdfRef);
            CGPDFDocumentRelease(pdfRef);
            
            UIRotationGestureRecognizer *rotGR = [[UIRotationGestureRecognizer alloc] initWithTarget:nvwv
                                                                                              action:@selector(rotateScrollView:)];
            
            rotGR.delegate = nvwv;
            [nvwv.scrollView addGestureRecognizer:rotGR];
            nvwv.rotationEnabled = YES;
        }
    }
    
    [nvwv bringSubviewToFront:nvwv.returnButton];
    [nvwv.webView loadFileURL:url allowingReadAccessToURL:url];
    [nvwv show];
    return nvwv;
}

+ (instancetype)showPDFDrawing:(NVPDFDrawing *)drawing
                  fromDocument:(NVPDFDocument)document
                        inView:(UIView *)view
                withHighlights:(NSString *)highlights
                   enableSwipe:(BOOL)enableSwipe
{
    NSString *resourcePath = @"";
    
    switch (document)
    {
        case NVPDFDocumentMNAccessbility:
            resourcePath = [NSString stringWithFormat:@"2015_mn_accessibility_code_part%i", drawing.page];
            break;
        case NVPDFDocumentFederalADA:
            resourcePath = [NSString stringWithFormat:@"2010ADAStandards_page%i", drawing.page];
            break;
        case NVPDFDocumentADAChecklist:
            resourcePath = @"ada-checklist";
            break;
        default:break;
    }
    
    NVWebView *nvwv = [NVWebView showWebViewInView:view
                                    showFileAtPath:[NSBundle.mainBundle pathForResource:resourcePath
                                                                                 ofType:@"pdf"]
                                          delegate:nil];
    
    switch (document)
    {
        case NVPDFDocumentMNAccessbility:
            nvwv.aspectRatio = AR077;
            break;
        case NVPDFDocumentFederalADA:
            nvwv.aspectRatio = AR077;
            break;
        case NVPDFDocumentADAChecklist:
            nvwv.aspectRatio = AR129;
            break;
        default:break;
    }
    
    nvwv.enableSwipe = enableSwipe;
    nvwv.zoomToPDFDrawing = YES;
    [nvwv hideReturnButton];
    [nvwv disableUserInteraction];
    nvwv.drawing = drawing;
    nvwv.highlights = highlights;
    
    CGFloat xMargin = 0.0, yMargin = 0.0;
    CGFloat width = ((drawing.lowerRight.x - drawing.upperLeft.x) * nvwv.aspectRatio);
    CGFloat height = (drawing.lowerRight.y - drawing.upperLeft.y);
    CGSize svSize = view.frame.size;
    CGFloat drawingAR = (width / height);
    CGFloat superviewAR = (svSize.width / svSize.height);
    CGFloat arRatio = 0.0;
    
    if (superviewAR > drawingAR)
    {
        arRatio = (drawingAR / superviewAR);
        xMargin = ((svSize.width - (arRatio * svSize.width)) / 2.0);
    }
    
    else
    {
        arRatio = (superviewAR / drawingAR);
        yMargin = ((svSize.height - (arRatio * svSize.height)) / 2.0);
    }
    
    [nvwv setConstraintsToLeading:xMargin trailing:-xMargin top:yMargin bottom:-yMargin];
    
    return nvwv;
}

- (void)setupViewComponents:(UIView *)view
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
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:_fontSize];
    _returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _returnButton.titleLabel.backgroundColor = UIColor.blackColor;
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.leadingAnchor constant:_headerSideMargin];
    [_returnButton constrainTopToAnchor:self.topAnchor constant:20.0];
    
    _symbols = NSMutableArray.array;
    _symbolPoints = NSMutableArray.array;
    _polylines = NSMutableArray.array;
    _polylinePoints = NSMutableArray.array;
    _polygons = NSMutableArray.array;
    _polygonPoints = NSMutableArray.array;
}

- (void)addImageToView:(UIView *)view
                  path:(NSString *)path
{
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    _imageView = [[UIImageView alloc] initWithImage:image];
    
    _scrollView = UIScrollView.new;
    _scrollView.backgroundColor = UIColor.clearColor;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.bouncesZoom = YES;
    _scrollView.bounces = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.alpha = 0.0;
    _scrollView.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(webViewWasTapped:)];
    
    [_scrollView addGestureRecognizer:tapGesture];
    
    UIRotationGestureRecognizer *rotGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(rotateScrollView:)];
    
    rotGR.delegate = self;
    [_scrollView addGestureRecognizer:rotGR];
    _rotationEnabled = YES;
    
    [self addSubview:_scrollView];
    [_scrollView constrainToView:self leading:0.0 trailing:0.0 top:_headerHeight bottom:0.0];
    [_returnButton constrainBottomToAnchor:_scrollView.topAnchor];
    [_scrollView addSubview:_imageView];
    
    [self performSelector:@selector(fitImage) withObject:nil afterDelay:0.1];
}

- (void)fitImage
{
    CGFloat hScale = (self.frame.size.width / _imageView.frame.size.width);
    CGFloat vScale = (self.frame.size.height / _imageView.frame.size.height);
    CGFloat minScale = MIN(hScale, vScale);
    CGFloat scale = MAX(hScale, vScale);
    
    _scrollView.minimumZoomScale = minScale;
    _scrollView.maximumZoomScale = (minScale * 100.0);
    [_scrollView setZoomScale:scale animated:NO];
    _scrollView.alpha = 1.0;
    _scrollView.userInteractionEnabled = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidFinishNavigation:)])
        [_delegate webViewDidFinishNavigation:self];
}

- (void)addWebViewToView:(UIView *)view
{
    _webView = WKWebView.new;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.clipsToBounds = YES;
    _scrollView = _webView.scrollView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(webViewWasTapped:)];
    
    [_webView addGestureRecognizer:tapGesture];
    
    [self addSubview:_webView];
    [_webView constrainToView:self leading:0.0 trailing:0.0 top:_headerHeight bottom:0.0];
    [_returnButton constrainBottomToAnchor:_webView.topAnchor];
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
                             _overlay.alpha = 0.0;
                             self.alpha = 0.0;
                             _tabBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [_overlay removeFromSuperview];
                             [self removeFromSuperview];
                             _tabBar.userInteractionEnabled = YES;
                         }];
    }
    
    else
    {
        [_overlay removeFromSuperview];
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
    
    if ([self.subviews containsObject:_webView])
        [_webView constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    else
        [_scrollView constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
}

- (void)returnButtonTapped:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidReturn:)])
        [_delegate webViewDidReturn:self];
    
    else
        [self hide:YES];
}

- (void)zoomToPoint:(DPOINT)point
         withinPage:(int)page
          withScale:(CGFloat)scale
           rotation:(CGFloat)rotation
{
    _zoomPoint.x = _origPoint.x = point.x;
    _zoomPoint.y = _origPoint.y = point.y;
    _zoomPage = _origPage = page;
    _zoomScale = _origScale = scale;
    _zoomRotation = _origRotation = rotation;
    
    if ([_scrollView.subviews containsObject:_imageView])
        [self performSelector:@selector(updateImageViewPosition) withObject:nil afterDelay:0.25];
    
    else
        [self updatePosition];
}

- (void)updateImageViewPosition
{
    _zoomPoint.x *= _imageView.image.size.width;
    _zoomPoint.y *= _imageView.image.size.height;
    _zoomPoint.y += (_imageView.image.size.height * (_zoomPage - 1));
    
    CGSize zoomSize = CGSizeMake((_imageView.image.size.width / _zoomScale),
                                 (_imageView.image.size.height / _zoomScale));
    
    CGRect zoomRect = CGRectMake((_zoomPoint.x - (zoomSize.width / 2.0)),
                                 (_zoomPoint.y - (zoomSize.height / 2.0)),
                                 zoomSize.width, zoomSize.height);
    
    [_scrollView zoomToRect:zoomRect animated:NO];
    _scrollView.transform = CGAffineTransformMakeRotation(_zoomRotation * DEGtoRAD);
}

- (void)updatePosition
{
    if (_zoomToPDFDrawing)
    {
        [self zoomToPage:min(_drawing.page, _numPages)
               upperLeft:_drawing.upperLeft
              lowerRight:_drawing.lowerRight];
    }
    
    else
    {
        if (_zoomPage > 0)
        {
            CGFloat pageHeight = self.pageHeight;
            _zoomPoint.x *= _scrollView.contentSize.width;
            _zoomPoint.y *= pageHeight;
            _zoomPoint.y += (pageHeight * (_zoomPage - 1));
        }
        
        CGSize zoomSize = CGSizeMake((_scrollView.bounds.size.width / _zoomScale),
                                     (_scrollView.bounds.size.height / _zoomScale));
        
        CGRect zoomRect = CGRectMake((_zoomPoint.x - (zoomSize.width / 2.0)),
                                     (_zoomPoint.y - (zoomSize.height / 2.0)),
                                     zoomSize.width, zoomSize.height);
        
        [_scrollView zoomToRect:zoomRect animated:NO];
        _scrollView.transform = CGAffineTransformMakeRotation(_zoomRotation * DEGtoRAD);
    }
}

- (CGFloat)pageHeight
{
    CGFloat rtn = 0.0;
    
    if (_numPages == 1)
    {
        rtn = MIN((_scrollView.contentSize.width / _aspectRatio),
                  _scrollView.contentSize.height);
    }
    
    else
        rtn = (_scrollView.contentSize.height / _numPages);
    
    return rtn;
}

- (void)zoomToPage:(int)page
         upperLeft:(DPOINT)upperLeft
        lowerRight:(DPOINT)lowerRight
{
    _ul.x = upperLeft.x;
    _ul.y = upperLeft.y;
    _lr.x = lowerRight.x;
    _lr.y = lowerRight.y;
    
    if (page > 0)
    {
        CGFloat pageHeight = self.pageHeight;
        upperLeft.x *= _scrollView.contentSize.width;
        upperLeft.y *= pageHeight;
        lowerRight.x *= _scrollView.contentSize.width;
        lowerRight.y *= pageHeight;
        upperLeft.y += (pageHeight * (page - 1));
        lowerRight.y += (pageHeight * (page - 1));
    }
    
    CGSize size = CGSizeMake((lowerRight.x - upperLeft.x), (lowerRight.y - upperLeft.y));
    CGRect rect = CGRectMake(upperLeft.x, upperLeft.y, size.width, size.height);
    
    [_scrollView zoomToRect:rect animated:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidZoom)])
        [_delegate webViewDidZoom];
    
    if (_highlights && _highlights.length)
    {
        NSArray *highlightArray = [_highlights componentsSeparatedByString:@";"];
        
        for (NSString *highlights in highlightArray)
        {
            NSArray *highlightList = [highlights componentsSeparatedByString:@" "];
            NSString *shapeID = highlightList[0];
            double ulx = ([highlightList[1] intValue] / 1000.0);
            double uly = ([highlightList[2] intValue] / 1000.0);
            double lrx = ([highlightList[3] intValue] / 1000.0);
            double lry = ([highlightList[4] intValue] / 1000.0);
            
            DPOINT ul = {ulx, uly};
            DPOINT lr = {lrx, lry};
            
            if ([shapeID isEqualToString:@"E"])
                [self addEllipseToFrameWithUpperLeft:ul lowerRight:lr];
        }
    }
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

- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation
{
    [_indicator removeFromSuperview];
    [_indicator stopAnimating];
    
    if (_isFile)
    {
        webView.scrollView.minimumZoomScale = 1.0;
        webView.scrollView.maximumZoomScale = 100.0;
        webView.scrollView.bouncesZoom = NO;
        webView.scrollView.directionalLockEnabled = NO;
        webView.scrollView.clipsToBounds = NO;
        webView.scrollView.delegate = self;
        
        [self updatePosition];
        _navigationComplete = YES;
    }
    
    for (UIView *view in webView.subviews)
    {
        for (UIView *subview in view.subviews)
        {
            if ([subview.description containsString:@"WKPDFPageNumberIndicator"])
                subview.hidden = YES;
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidFinishNavigation:)])
        [_delegate webViewDidFinishNavigation:self];
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

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"WebView Process Did Terminate");
}

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"popupURL:%@", navigationAction.request.URL.absoluteString);
    
    NVWebView *popupWindow = [NVWebView showWebViewInView:self.superview
                                                urlString:navigationAction.request.URL.absoluteString];
    
    popupWindow.delegate = (id)self.superview;
    return nil;
}

- (CORNERPOINTS)cornerPoints
{
    CORNERPOINTS points = {0};
    MNMXCORD coords = {0};
    DPOINT dPoint = {0};
    CGPoint offset = _scrollView.contentOffset;
    CGSize size = _scrollView.contentSize;
    
    coords.xmn = (offset.x / size.width);
    coords.ymn = (offset.y / size.height);
    offset.x += self.frame.size.width;
    offset.y += self.frame.size.height;
    coords.xmx = (offset.x / size.width);
    coords.ymx = (offset.y / size.height);
    
    dPoint.x = (coords.xmn);
    dPoint.y = (coords.ymn);
    points.farLeft = dPoint;
    
    dPoint.x = (coords.xmn);
    dPoint.y = (coords.ymx);
    points.nearLeft = dPoint;
    
    dPoint.x = (coords.xmx);
    dPoint.y = (coords.ymn);
    points.farRight = dPoint;
    
    dPoint.x = (coords.xmx);
    dPoint.y = (coords.ymx);
    points.nearRight = dPoint;
    
    return points;
}

- (void)webViewWasTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_scrollView];
    CGFloat pageHeight = self.pageHeight;
    _markerPage = (int)ceilf(point.y / pageHeight);
    CGFloat offset = (CGFloat)(pageHeight * (_markerPage - 1));
    point.y -= offset;
    
    DPOINT dPoint = {0};
    dPoint.x = (point.x / _scrollView.contentSize.width);
    dPoint.y = (point.y / pageHeight);
    
    if (_drawsMarkers)
    {
        if (!_markers)
            _markers = NSMutableArray.array;
        
        if (_drawsMultipleMarkers)
        {
            if (!_lines)
                _lines = NSMutableArray.array;
            
            if (_markers.count)
            {
                UIBezierPath *path = UIBezierPath.bezierPath;
                [path moveToPoint:point];
                [path addLineToPoint:_markers.lastObject.center];
                CAShapeLayer *line = CAShapeLayer.layer;
                line.lineWidth = 4.0;
                line.strokeColor = UIColor.redColor.CGColor;
                line.path = path.CGPath;
                line.position = CGPointZero;
                [_scrollView.layer addSublayer:line];
                [_lines addObject:line];
            }
            
            for (UIView *allMarkers in _markers)
                [allMarkers.superview bringSubviewToFront:allMarkers];
            
            NVWebViewMarker *marker = NVWebViewMarker.new;
            marker.backgroundColor = UIColor.redColor;
            marker.layer.cornerRadius = (_markerSize * 0.5);
            marker.layer.borderColor = UIColor.blackColor.CGColor;
            marker.layer.borderWidth = (_markerSize * 0.1);
            marker.frame = CGRectMake(0.0, 0.0, _markerSize, _markerSize);
            [_markers addObject:marker];
            marker.center = point;
            [_scrollView addSubview:marker];
            marker.position = CGPointMake(dPoint.x, dPoint.y);
        }
        
        else
        {
            if (!_marker)
            {
                _marker = NVWebViewMarker.new;
                _marker.backgroundColor = UIColor.redColor;
                _marker.layer.cornerRadius = (_markerSize * 0.5);
                _marker.layer.borderColor = UIColor.blackColor.CGColor;
                _marker.layer.borderWidth = (_markerSize * 0.1);
                _marker.frame = CGRectMake(0.0, 0.0, _markerSize, _markerSize);
            }
            
            if (![_scrollView.subviews containsObject:_marker])
                [_scrollView addSubview:_marker];
            
            _marker.center = point;
            _markerPosition = dPoint;
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(webView:wasTappedAtPoint:withinPage:)])
    {
        [_delegate webView:self
          wasTappedAtPoint:dPoint
                withinPage:_markerPage];
    }
}

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    if (_isFile)
    {
        if (CGRectContainsPoint(_returnButton.frame, point))
            return _returnButton;
        
        else if (CGRectContainsPoint(_nextButton.frame, point))
            return _nextButton;
        
        else if (CGRectContainsPoint(_previousButton.frame, point))
            return _previousButton;
        
        else
            return _scrollView;
    }
    
    else
    {
        for(UIView *subviews in self.subviews)
        {
            if ([subviews pointInside:[self convertPoint:point
                                                  toView:subviews]
                            withEvent:event])
            {
                return [subviews hitTest:[self convertPoint:point
                                                     toView:subviews]
                               withEvent:event];
            }
        }
        
        return self;
    }
}

- (void)rotateScrollView:(UIRotationGestureRecognizer *)gesture
{
    if (_rotationEnabled)
    {
        _scrollView.transform = CGAffineTransformRotate(gesture.view.transform, gesture.rotation);
        gesture.rotation = 0.0;
    }
    
    else
        gesture.delegate = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)gotoOriginalPosition
{
    [self clearPosition];
    
    DPOINT point = {0};
    point.x = _origPoint.x;
    point.y = _origPoint.y;
    
    [self zoomToPoint:point
           withinPage:_origPage
            withScale:_origScale
             rotation:_origRotation];
}

- (void)disableUserInteraction
{
    _overlay = UIView.new;
    _overlay.tag = 777;
    _overlay.translatesAutoresizingMaskIntoConstraints = NO;
    _overlay.backgroundColor = UIColor.clearColor;
    [self.superview addSubview:_overlay];
    [_overlay constrainToView:self.superview leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    if (_enableSwipe)
    {
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(webViewLeftSwiped:)];
        
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        [_overlay addGestureRecognizer:leftSwipe];
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(webViewRightSwiped:)];
        
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [_overlay addGestureRecognizer:rightSwipe];
    }
}

- (void)enableUserInteraction
{
    [_overlay removeFromSuperview];
}

- (void)disableZoomScroll
{
    _scrollView.panGestureRecognizer.enabled = NO;
    _scrollView.pinchGestureRecognizer.enabled = NO;
    _rotationEnabled = NO;
}

- (void)clearPosition
{
    _scrollView.transform = CGAffineTransformMakeRotation(0.0);
    [_scrollView setZoomScale:1.0 animated:NO];
    [_scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)setConstraintsToLeading:(CGFloat)leading
                       trailing:(CGFloat)trailing
                            top:(CGFloat)top
                         bottom:(CGFloat)bottom
{
    [self constrainToView:self.superview leading:leading trailing:trailing top:top bottom:bottom];
    
    if ([self.subviews containsObject:_webView])
        [_webView constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    else
        [_scrollView constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    if (_overlay)
        [_overlay constrainToView:self.superview leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([scrollView.subviews containsObject:_imageView])
        return _imageView;
    
    else
        return scrollView.subviews.firstObject;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (_symbols.count)
    {
        for (int i = 0; i < _symbols.count; i++)
        {
            UIBezierPath *path = [self pathFromPoints:_symbolPoints[i] closePath:NO];
            _symbols[i].path = path.CGPath;
        }
    }
    
    if (_polylines.count)
    {
        for (int i = 0; i < _polylines.count; i++)
        {
            UIBezierPath *path = [self pathFromPoints:_polylinePoints[i] closePath:NO];
            _polylines[i].path = path.CGPath;
        }
    }
    
    if (_polygons.count)
    {
        for (int i = 0; i < _polygons.count; i++)
        {
            UIBezierPath *path = [self pathFromPoints:_polygonPoints[i] closePath:YES];
            _polygons[i].path = path.CGPath;
        }
    }
    
    CGFloat pageHeight = self.pageHeight;
    
    if (_markers.count)
    {
        for (int i = 0; i < _markers.count; i++)
        {
            NVWebViewMarker *marker = _markers[i];
            
            if ([scrollView.subviews containsObject:marker])
            {
                marker.center = CGPointMake((marker.position.x * scrollView.contentSize.width),
                                            ((marker.position.y * pageHeight) * _markerPage));
            }
        }
        
        for (int i = 0; i < _lines.count; i++)
        {
            UIBezierPath *path = UIBezierPath.bezierPath;
            [path moveToPoint:_markers[i+1].center];
            [path addLineToPoint:_markers[i].center];
            CAShapeLayer *line = _lines[i];
            line.path = path.CGPath;
        }
        
        if ([scrollView.layer.sublayers containsObject:_polygon])
        {
            UIBezierPath *path = UIBezierPath.bezierPath;
            CGPoint start = _markers[0].center;
            [path moveToPoint:start];
            
            for (int i = 1; i < _markers.count; i++)
            {
                CGPoint point = _markers[i].center;
                [path addLineToPoint:point];
            }
            
            _polygon.path = path.CGPath;
            [scrollView.layer addSublayer:_polygon];
        }
    }
    
    else if ([scrollView.subviews containsObject:_marker])
    {
        _marker.center = CGPointMake((_markerPosition.x * scrollView.contentSize.width),
                                     ((_markerPosition.y * pageHeight) * _markerPage));
    }
}

- (void)addTapWindowToFrameWithUpperLeft:(DPOINT)upperLeft
                              lowerRight:(DPOINT)lowerRight
                           identifierTag:(int)identifierTag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = [self frameForUpperLeft:upperLeft lowerRight:lowerRight];
    button.tag = identifierTag;
    button.backgroundColor = UIColor.clearColor;
    [button addTarget:self action:@selector(windowTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_overlay addSubview:button];
}

- (void)addEllipseToFrameWithUpperLeft:(DPOINT)upperLeft
                            lowerRight:(DPOINT)lowerRight
{
    UIView *ellipse = NVEllipseView.new;
    ellipse.frame = [self frameForUpperLeft:upperLeft lowerRight:lowerRight];
    [self addSubview:ellipse];
}

- (BOOL)addViewToFrameWithUpperLeft:(DPOINT)upperLeft
                         lowerRight:(DPOINT)lowerRight
{
    if (upperLeft.x > lowerRight.x)
    {
        double tmp = lowerRight.x;
        lowerRight.x = upperLeft.x;
        upperLeft.x = tmp;
    }
    
    if (upperLeft.y > lowerRight.y)
    {
        double tmp = lowerRight.y;
        lowerRight.y = upperLeft.y;
        upperLeft.y = tmp;
    }
    
    if (upperLeft.x > _lr.x || lowerRight.x < _ul.x ||
        upperLeft.y > _lr.y || lowerRight.y < _ul.y)
    {
        return NO;
    }
    
    upperLeft.x = MAX(upperLeft.x, _ul.x);
    upperLeft.y = MAX(upperLeft.y, _ul.y);
    lowerRight.x = MIN(lowerRight.x, _lr.x);
    lowerRight.y = MIN(lowerRight.y, _lr.y);
    
    upperLeft.x = roundTo1000th(upperLeft.x);
    upperLeft.y = roundTo1000th(upperLeft.y);
    lowerRight.x = roundTo1000th(lowerRight.x);
    lowerRight.y = roundTo1000th(lowerRight.y);
    
    UIView *ellipse = NVEllipseView.new;
    ellipse.frame = [self frameForUpperLeft:upperLeft lowerRight:lowerRight];
    [_overlay addSubview:ellipse];
    
    _frameUL = upperLeft;
    _frameLR = lowerRight;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(viewTapped:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(viewPanned:)];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(viewPinched:)];
    
    [ellipse addGestureRecognizer:tap];
    [ellipse addGestureRecognizer:pan];
    [ellipse addGestureRecognizer:pinch];
    
    return YES;
}

double roundTo1000th(double value)
{
    value *= 1000;
    value += 0.5;
    value = floor(value);
    value /= 1000;
    return value;
}

- (void)viewTapped:(UITapGestureRecognizer *)gesture
{
    NSString *info = [NSString stringWithFormat:@"ULX: %.3f\nULY: %.3f\nLRX: %.3f\nLRY: %.3f",
                      _frameUL.x, _frameUL.y, _frameLR.x, _frameLR.y];
    
    showAlert(info);
    
    if (_delegate && [_delegate respondsToSelector:@selector(tapViewFinished)])
        [_delegate tapViewFinished];
}

- (void)viewPanned:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view];
    float panFactor = 0.001;
    
    if (translation.x > 0 && (_lr.x - _frameLR.x) >= panFactor)
    {
        _frameUL.x += panFactor;
        _frameLR.x += panFactor;
    }
    
    else if (translation.x < 0 && (_frameUL.x - _ul.x) >= panFactor)
    {
        _frameUL.x -= panFactor;
        _frameLR.x -= panFactor;
    }
    
    if (translation.y > 0 && (_lr.y - _frameLR.y) >= panFactor)
    {
        _frameUL.y += panFactor;
        _frameLR.y += panFactor;
    }
    
    else if (translation.y < 0 && (_frameUL.y - _ul.y) >= panFactor)
    {
        _frameUL.y -= panFactor;
        _frameLR.y -= panFactor;
    }
    
    gesture.view.frame = [self frameForUpperLeft:_frameUL lowerRight:_frameLR];
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

- (void)viewPinched:(UIPinchGestureRecognizer *)gesture
{
    float scaleFactor = 0.001;
    
    if ((gesture.scale - _lastScale) > 0)
    {
        if ((_lr.x - _frameLR.x) >= scaleFactor &&
            (_frameUL.x - _ul.x) >= scaleFactor &&
            (_lr.y - _frameLR.y) >= scaleFactor &&
            (_frameUL.y - _ul.y) >= scaleFactor)
        {
            _frameUL.x -= scaleFactor;
            _frameUL.y -= scaleFactor;
            _frameLR.x += scaleFactor;
            _frameLR.y += scaleFactor;
        }
    }
    
    else
    {
        _frameUL.x += scaleFactor;
        _frameUL.y += scaleFactor;
        _frameLR.x -= scaleFactor;
        _frameLR.y -= scaleFactor;
    }
    
    _lastScale = gesture.scale;
    gesture.view.frame = [self frameForUpperLeft:_frameUL lowerRight:_frameLR];
}

- (CGRect)frameForUpperLeft:(DPOINT)upperLeft
                 lowerRight:(DPOINT)lowerRight
{
    CGFloat xFactor = (_webView.frame.size.width / (_lr.x - _ul.x));
    CGFloat yFactor = (_webView.frame.size.height / (_lr.y - _ul.y));
    CGPoint origin = CGPointMake(((upperLeft.x - _ul.x) * xFactor), ((upperLeft.y - _ul.y) * yFactor));
    CGFloat xSize = (lowerRight.x - upperLeft.x);
    CGFloat ySize = (lowerRight.y - upperLeft.y);
    CGSize size = CGSizeMake((xSize * xFactor), (ySize * yFactor));
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

- (void)windowTouchedDown:(UIButton *)button
{
    if (!button.selected)
    {
        for (UIButton *buttons in (button.superview.subviews))
        {
            buttons.backgroundColor = UIColor.clearColor;
            buttons.selected = NO;
        }
        
        button.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3];
        button.selected = YES;
        
        if (_delegate && [_delegate respondsToSelector:@selector(windowWasSelectedWithIdentifierTag:)])
            [_delegate windowWasSelectedWithIdentifierTag:(int)button.tag];
    }
    
    else
    {
        for (UIButton *buttons in (button.superview.subviews))
        {
            buttons.backgroundColor = UIColor.clearColor;
            buttons.selected = NO;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(windowWasSelectedWithIdentifierTag:)])
            [_delegate windowWasSelectedWithIdentifierTag:-1];
    }
}

- (void)removeLastMarker
{
    if ([_scrollView.layer.sublayers containsObject:_polygon])
    {
        [_polygon removeFromSuperlayer];
        
        for (CAShapeLayer *line in _lines)
            line.hidden = NO;
        
        for (UIView *marker in _markers)
            marker.hidden = NO;
        
        if (_delegate && [_delegate respondsToSelector:@selector(webViewDidRemovePolygon)])
            [_delegate webViewDidRemovePolygon];
    }
    
    else
    {
        if (_markers.count)
        {
            NVWebViewMarker *marker = _markers.lastObject;
            [marker removeFromSuperview];
            [_markers removeLastObject];
            
            if (_lines.count)
            {
                CAShapeLayer *line = _lines.lastObject;
                [line removeFromSuperlayer];
                [_lines removeLastObject];
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(webViewDidRemoveLastMarker)])
            [_delegate webViewDidRemoveLastMarker];
    }
}

- (void)webViewLeftSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewWasLeftSwiped)])
        [_delegate webViewWasLeftSwiped];
}

- (void)webViewRightSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewWasRightSwiped)])
        [_delegate webViewWasRightSwiped];
}

- (void)maskPolygon
{
    for (CAShapeLayer *line in _lines)
        line.hidden = YES;
    
    for (UIView *marker in _markers)
        marker.hidden = YES;
    
    UIBezierPath *path = UIBezierPath.bezierPath;
    CGPoint start = _markers[0].center;
    [path moveToPoint:start];
    
    for (int i = 1; i < _markers.count; i++)
    {
        CGPoint point = _markers[i].center;
        [path addLineToPoint:point];
    }
    
    _polygon.path = path.CGPath;
    [_scrollView.layer addSublayer:_polygon];
}

- (UIBezierPath *)pathFromPoints:(NSArray<DPoint *> *)points
                       closePath:(BOOL)closePath
{
    UIBezierPath *path = UIBezierPath.bezierPath;
    CGFloat pageHeight = self.pageHeight;
    DPoint *firstPoint = points[0];
    CGPoint point1 = CGPointZero;
    point1.x = (firstPoint.x * _scrollView.contentSize.width);
    point1.y = (firstPoint.y * pageHeight);
    [path moveToPoint:point1];
    
    for (int i = 1; i < points.count; i++)
    {
        DPoint *currentPoint = points[i];
        CGPoint point = CGPointZero;
        point.x = (currentPoint.x * _scrollView.contentSize.width);
        point.y = (currentPoint.y * pageHeight);
        [path addLineToPoint:point];
    }
    
    if (closePath)
        [path addLineToPoint:point1];
    
    return path;
}

- (void)drawShapeWithPoint:(DPoint *)point
                      type:(PointSymbols)type
{
    NSArray<DPoint *> *symbolDef = [SymbolDictionary symbolDefForType:type];
    NSMutableArray<DPoint *> *symbolPoints = NSMutableArray.array;
    
    for (DPoint *points in symbolDef)
    {
        DPoint *newPoint = points;
        newPoint.x *= 0.0025;
        newPoint.y *= 0.0025;
        newPoint.x += point.x;
        newPoint.y += point.y;
        [symbolPoints addObject:newPoint];
    }
    
    NSArray<DPoint *> *points = symbolPoints.copy;
    UIBezierPath *path = [self pathFromPoints:points closePath:NO];
    CAShapeLayer *shape = CAShapeLayer.layer;
    shape.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5].CGColor;
    shape.position = CGPointZero;
    shape.path = path.CGPath;
    shape.strokeColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    shape.lineWidth = 1.0;
    [_scrollView.layer addSublayer:shape];
    [_symbolPoints addObject:points];
    [_symbols addObject:shape];
}

- (void)drawPolylineWithPoints:(NSArray<DPoint *> *)points
                          type:(PolylineSymbols)type
{
    CGFloat lineWidth = 0.0;
    UIBezierPath *path = [self pathFromPoints:points closePath:NO];
    CAShapeLayer *polyline = CAShapeLayer.layer;
    polyline.position = CGPointZero;
    polyline.path = path.CGPath;
    polyline.strokeColor = [SymbolDictionary polylineStrokeColor:type lineWidth:&lineWidth].CGColor;
    polyline.lineWidth = lineWidth;
    polyline.fillColor = UIColor.clearColor.CGColor;
    [_scrollView.layer addSublayer:polyline];
    [_polylinePoints addObject:points];
    [_polylines addObject:polyline];
}

- (void)drawPolygonWithPoints:(NSArray<DPoint *> *)points
                         type:(PolygonSymbols)type
{
    UIBezierPath *path = [self pathFromPoints:points closePath:YES];
    CAShapeLayer *polygon = CAShapeLayer.layer;
    polygon.position = CGPointZero;
    polygon.path = path.CGPath;
    polygon.strokeColor = UIColor.yellowColor.CGColor;
    polygon.lineWidth = 4.0;
    polygon.fillColor = UIColor.clearColor.CGColor;
    [_scrollView.layer addSublayer:polygon];
    [_polygonPoints addObject:points];
    [_polygons addObject:polygon];
}

- (void)showNextAndPrevious
{
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    _nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:(_fontSize * 1.5)];
    _nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _nextButton.titleLabel.backgroundColor = UIColor.blackColor;
    [_nextButton setTitle:@">>" forState:UIControlStateNormal];
    [_nextButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_nextButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [_nextButton addTarget:self
                    action:@selector(nextButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_nextButton];
    [_nextButton constrainTrailingToAnchor:self.trailingAnchor constant:-20.0];
    [_nextButton constrainBottomToAnchor:self.bottomAnchor constant:-_tabBar.frame.size.height];
    
    _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previousButton.translatesAutoresizingMaskIntoConstraints = NO;
    _previousButton.titleLabel.font = [UIFont boldSystemFontOfSize:(_fontSize * 1.5)];
    _previousButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _previousButton.titleLabel.backgroundColor = UIColor.blackColor;
    [_previousButton setTitle:@"<<" forState:UIControlStateNormal];
    [_previousButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_previousButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [_previousButton addTarget:self
                        action:@selector(previousButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_previousButton];
    [_previousButton constrainLeadingToAnchor:self.leadingAnchor constant:20.0];
    [_previousButton constrainBottomToAnchor:self.bottomAnchor constant:-_tabBar.frame.size.height];
}

- (void)nextButtonTapped:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidRequestNextImage:)])
        [_delegate webViewDidRequestNextImage:self];
}

- (void)previousButtonTapped:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidRequestPreviousImage:)])
        [_delegate webViewDidRequestPreviousImage:self];
}

- (void)updateImageViewToImageAtPath:(NSString *)path
{
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    _imageView.image = image;
}

- (void)setRotationEnabled:(BOOL)rotationEnabled
{
    _rotationEnabled = rotationEnabled;
    _scrollView.clipsToBounds = !rotationEnabled;
}

- (void)getHtmlString
{
    [_webView evaluateJavaScript:@"document.documentElement.outerHTML.toString()"
               completionHandler:^(NSString *result, NSError *error)
     {
         if (_delegate && [_delegate respondsToSelector:@selector(webViewDidReturnHtmlString:)])
         {
             if (error)
             {
                 [_delegate webViewDidReturnHtmlString:[NSString stringWithFormat:@"WKWebView HTML ERROR: %@",
                                                        error.localizedDescription]];
             }
             
             else
                 [_delegate webViewDidReturnHtmlString:result];
         }
     }];
}

@end
