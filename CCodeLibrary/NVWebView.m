//  NVWebView.m
//  CCodeLibrary

#import "NVWebView.h"
#import "NVPopoverTableView.h"
#import "NVAlertView.h"
#import "CRAPI.h"
#import "SymbolDictionary.h"

@implementation NVWebViewMarker

@end

@interface NVWebView () <WKNavigationDelegate,WKUIDelegate,NVPopoverTableViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) UIButton *returnButton, *realtor, *nextButton, *previousButton;
@property (nonatomic) CGFloat headerHeight, headerSideMargin, zoomScale, zoomRotation;
@property (nonatomic) CGFloat origScale, origRotation, markerSize, fontSize;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property CGPoint zoomPoint, origPoint;
@property int numPages, zoomPage, origPage, markerPage;
@property BOOL isFile, navigationComplete, zoomToPDFDrawing, enableSwipe;
@property (nonatomic) NVPDFDrawing *drawing;
@property (nonatomic) NVWebViewMarker *marker;
@property (nonatomic) NSMutableArray<NVWebViewMarker *> *markers;
@property (nonatomic) NSMutableArray<CAShapeLayer *> *lines, *symbols, *polylines, *polygons;
@property (nonatomic) NSMutableArray<NSArray<DPoint *> *> *symbolPoints, *polylinePoints, *polygonPoints;
@property DPOINT markerPosition, ul, lr;
@property (nonatomic) CAShapeLayer *polygon;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation NVWebView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _zoomPoint = CGPointZero;
        _zoomScale = 1.0;
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
    _scrollView.delegate = nil;
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
}

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString
{
    if (urlString && urlString.length)
    {
        NVWebView *nvwv = NVWebView.new;
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
    NSURL *url = [NSURL fileURLWithPath:path];

    if ([type isEqualToString:@"pdf"])
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
                   enableSwipe:(BOOL)enableSwipe
{
    NSString *resourcePath = @"";
    CGFloat aspectRatio = 0.0;
    
    switch (document)
    {
        case NVPDFDocumentMNAccessbility:
            resourcePath = @"2015_mn_accessibility_code";
            aspectRatio = AR077;
            break;
        case NVPDFDocumentFederalADA:
            resourcePath = @"2010ADAStandards";
            aspectRatio = AR077;
            break;
        case NVPDFDocumentADAChecklist:
            resourcePath = @"ada-checklist";
            aspectRatio = AR129;
            break;
        default:break;
    }
    
    NVWebView *nvwv = [NVWebView showWebViewInView:view
                                    showFileAtPath:[NSBundle.mainBundle pathForResource:resourcePath
                                                                                 ofType:@"pdf"]
                                          delegate:nil];
    
    nvwv.enableSwipe = enableSwipe;
    nvwv.zoomToPDFDrawing = YES;
    [nvwv hideReturnButton];
    [nvwv disableUserInteraction];
    nvwv.drawing = drawing;
    
    CGFloat xMargin = 0.0, yMargin = 0.0;
    CGFloat width = ((drawing.lowerRight.x - drawing.upperLeft.x) * aspectRatio);
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
    CGFloat maxImageSize = max(_imageView.frame.size.width, _imageView.frame.size.height);
    CGFloat minContainerSize = min(self.frame.size.width, self.frame.size.height);
    CGFloat minScale = (minContainerSize / maxImageSize);
    _scrollView.minimumZoomScale = minScale;
    _scrollView.maximumZoomScale = (minScale * 100.0);
    [_scrollView setZoomScale:minScale animated:NO];
    _scrollView.alpha = 1.0;
    _scrollView.userInteractionEnabled = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidFinishNavigation)])
        [_delegate webViewDidFinishNavigation];
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
        [self zoomToPage:_drawing.page upperLeft:_drawing.upperLeft lowerRight:_drawing.lowerRight];
    
    else
    {
        if (_zoomPage > 0)
        {
            CGFloat pageHeight = (_scrollView.contentSize.height / _numPages);
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

- (void)zoomToPage:(int)page
         upperLeft:(DPOINT)upperLeft
        lowerRight:(DPOINT)lowerRight
{
    _ul.x = upperLeft.x;
    _ul.y = upperLeft.y;
    _lr.x = lowerRight.x;
    _lr.y = lowerRight.y;
    
    if (page > 1)
    {
        CGFloat pageHeight = (_scrollView.contentSize.height / _numPages);
        upperLeft.x *= _scrollView.contentSize.width;
        upperLeft.y *= pageHeight;
        lowerRight.x *= _scrollView.contentSize.width;
        lowerRight.y *= pageHeight;
        upperLeft.y += (pageHeight * (page - 1));
        lowerRight.y += (pageHeight * (page - 1));
    }
    
    CGSize size = CGSizeMake(lowerRight.x - upperLeft.x, lowerRight.y - upperLeft.y);
    CGRect rect = CGRectMake(upperLeft.x, upperLeft.y, size.width, size.height);
    
    [_scrollView zoomToRect:rect animated:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidZoom)])
        [_delegate webViewDidZoom];
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
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewDidFinishNavigation)])
        [_delegate webViewDidFinishNavigation];
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

- (void)webViewWasTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_scrollView];
    CGFloat pageHeight = (_scrollView.contentSize.height / _numPages);
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
    UIView *overlay = UIView.new;
    overlay.tag = 777;
    overlay.translatesAutoresizingMaskIntoConstraints = NO;
    overlay.backgroundColor = UIColor.clearColor;
    [self.superview addSubview:overlay];
    [overlay constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    if (_enableSwipe)
    {
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(webViewLeftSwiped:)];
        
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        [overlay addGestureRecognizer:leftSwipe];
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(webViewRightSwiped:)];
        
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [overlay addGestureRecognizer:rightSwipe];
    }
}

- (void)enableUserInteraction
{
    [[self.superview viewWithTag:777] removeFromSuperview];
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
    
    if ([self.superview viewWithTag:777])
        [[self.superview viewWithTag:777] constrainToView:self leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
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
    CGFloat pageHeight = (_scrollView.contentSize.height / _numPages);
    
    if (_symbols.count)
    {
        for (int i = 0; i < _symbols.count; i++)
        {
            UIBezierPath *path = [self pathFromPoints:_symbolPoints[i]];
            _symbols[i].path = path.CGPath;
        }
    }
    
    if (_polylines.count)
    {
        for (int i = 0; i < _polylines.count; i++)
        {
            UIBezierPath *path = [self pathFromPoints:_polylinePoints[i]];
            _polylines[i].path = path.CGPath;
        }
    }
    
    if (_polygons.count)
    {
        for (int i = 0; i < _polygons.count; i++)
        {
            UIBezierPath *path = [self pathFromPoints:_polygonPoints[i]];
            _polygons[i].path = path.CGPath;
        }
    }
    
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
    CGFloat xFactor = (_webView.frame.size.width / (_lr.x - _ul.x));
    CGFloat yFactor = (_webView.frame.size.height / (_lr.y - _ul.y));
    CGPoint origin = CGPointMake(((upperLeft.x - _ul.x) * xFactor), ((upperLeft.y - _ul.y) * yFactor));
    CGFloat xSize = (lowerRight.x - upperLeft.x);
    CGFloat ySize = (lowerRight.y - upperLeft.y);
    CGSize size = CGSizeMake((xSize * xFactor), (ySize * yFactor));
    CGRect frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = identifierTag;
    button.backgroundColor = UIColor.clearColor;
    [button addTarget:self action:@selector(windowTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [[self.superview viewWithTag:777] addSubview:button];
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
{
    UIBezierPath *path = UIBezierPath.bezierPath;
    CGFloat pageHeight = (_scrollView.contentSize.height / _numPages);
    DPoint *firstPoint = points[0];
    CGPoint point = CGPointZero;
    point.x = (firstPoint.x * _scrollView.contentSize.width);
    point.y = (firstPoint.y * pageHeight);
    [path moveToPoint:point];
    
    for (int i = 1; i < points.count; i++)
    {
        DPoint *currentPoint = points[i];
        CGPoint point = CGPointZero;
        point.x = (currentPoint.x * _scrollView.contentSize.width);
        point.y = (currentPoint.y * pageHeight);
        [path addLineToPoint:point];
    }
    
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
    UIBezierPath *path = [self pathFromPoints:points];
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
    UIBezierPath *path = [self pathFromPoints:points];
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
    UIBezierPath *path = [self pathFromPoints:points];
    CAShapeLayer *polygon = CAShapeLayer.layer;
    polygon.position = CGPointZero;
    polygon.path = path.CGPath;
    polygon.strokeColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    polygon.lineWidth = 1.0;
    polygon.fillColor = [SymbolDictionary polygonSymbolFillColor:type].CGColor;
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

@end
