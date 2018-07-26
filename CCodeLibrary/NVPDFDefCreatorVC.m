//  NVPDFDefCreatorVC.m
//  CCodeLibrary

#import "NVPDFDefCreatorVC.h"
#import "UserDefaults.h"
#import "NVPDFDrawing.h"

@interface NVPDFDefCreatorVC ()

@property int page;
@property DPOINT ul, lr;
@property (nonatomic) UIView *containerView;
@property NVPDFDocument document;
@property (nonatomic) NVPDFDrawing *drawing;
@property (nonatomic) NVWebView *webView;
@property (nonatomic) UISegmentedControl *pageSC, *ulxSC, *ulySC, *lrxSC, *lrySC;

@end

@implementation NVPDFDefCreatorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    CGFloat margin = 20.0;
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.backgroundColor = UIColor.clearColor;
    [returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    [self.view addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [returnButton constrainTopToAnchor:self.view.topAnchor];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _document = NVPDFDocumentFederalADA;
    _page = 1;
    _ul.x = _ul.y = 0.1;
    _lr.x = _lr.y = 1.0;
    
    _containerView = UIView.new;
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.backgroundColor = UIColor.grayColor;
    _containerView.layer.borderColor = UIColor.blackColor.CGColor;
    _containerView.layer.borderWidth = 1.0;
    [self.view addSubview:_containerView];
    [_containerView constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_containerView constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_containerView constrainTopToAnchor:self.view.centerYAnchor];
    [_containerView constrainBottomToAnchor:self.view.bottomAnchor constant:-margin];
    
    _drawing = [NVPDFDrawing drawingWithID:@"" name:@"" type:@""
                                      page:_page upperLeft:_ul lowerRight:_lr];
    
    NSArray *items = @[@"-25", @"-10", @"-5", @"-1", @"+1", @"+5", @"+10", @"+25"];
    
    UILabel *pageLabel = UILabel.new;
    [self setupLabel:pageLabel];
    pageLabel.text = @"PAGE";
    [pageLabel constrainTopToAnchor:returnButton.bottomAnchor constant:margin];
    
    _pageSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_pageSC];
    [_pageSC constrainTopToAnchor:pageLabel.topAnchor];
    [_pageSC constrainLeadingToAnchor:pageLabel.trailingAnchor];
    
    items = @[@"-.500", @"-.250", @"-.100", @"-.025", @"+.025", @"+.100", @"+.250", @"+.500"];
    
    UILabel *ulxLabel = UILabel.new;
    [self setupLabel:ulxLabel];
    ulxLabel.text = @"ULX";
    [ulxLabel constrainTopToAnchor:pageLabel.bottomAnchor constant:margin];
    
    _ulxSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_ulxSC];
    [_ulxSC constrainTopToAnchor:ulxLabel.topAnchor];
    [_ulxSC constrainLeadingToAnchor:ulxLabel.trailingAnchor];
    
    UILabel *ulyLabel = UILabel.new;
    [self setupLabel:ulyLabel];
    ulyLabel.text = @"ULY";
    [ulyLabel constrainTopToAnchor:ulxLabel.bottomAnchor constant:margin];
    
    _ulySC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_ulySC];
    [_ulySC constrainTopToAnchor:ulyLabel.topAnchor];
    [_ulySC constrainLeadingToAnchor:ulyLabel.trailingAnchor];
    
    UILabel *lrxLabel = UILabel.new;
    [self setupLabel:lrxLabel];
    lrxLabel.text = @"LRX";
    [lrxLabel constrainTopToAnchor:ulyLabel.bottomAnchor constant:margin];
    
    _lrxSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_lrxSC];
    [_lrxSC constrainTopToAnchor:lrxLabel.topAnchor];
    [_lrxSC constrainLeadingToAnchor:lrxLabel.trailingAnchor];
    
    UILabel *lryLabel = UILabel.new;
    [self setupLabel:lryLabel];
    lryLabel.text = @"LRY";
    [lryLabel constrainTopToAnchor:lrxLabel.bottomAnchor constant:margin];
    
    _lrySC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_lrySC];
    [_lrySC constrainTopToAnchor:lryLabel.topAnchor];
    [_lrySC constrainLeadingToAnchor:lryLabel.trailingAnchor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _webView = [NVWebView showPDFDrawing:_drawing
                            fromDocument:_document
                                  inView:_containerView
                          withHighlights:@""
                             enableSwipe:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupLabel:(UILabel *)label
{
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = UIColor.clearColor;
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:24.0];
    [self.view addSubview:label];
    [label constrainLeadingToAnchor:self.view.leadingAnchor];
    [label constrainHeightToConstant:40.0];
    [label constrainWidthToConstant:70.0];
}

- (void)setupSC:(UISegmentedControl *)sc
{
    sc.translatesAutoresizingMaskIntoConstraints = NO;
    sc.backgroundColor = UIColor.blackColor;
    sc.tintColor = UIColor.whiteColor;
    sc.momentary = YES;
    sc.layer.borderWidth = 2.0;
    sc.layer.borderColor = UIColor.whiteColor.CGColor;
    
    [sc setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:28.0]
                                                           forKey:NSFontAttributeName]
                      forState:UIControlStateNormal];
    
    [self.view addSubview:sc];
    [sc constrainTrailingToAnchor:self.view.trailingAnchor constant:-10.0];
    [sc constrainHeightToConstant:40.0];
    [sc addTarget:self action:@selector(scTapped:) forControlEvents:UIControlEventValueChanged];
}

- (void)returnButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scTapped:(UISegmentedControl *)sc
{
    float diff = 0.0;
    
    if (sc == _pageSC)
    {
        switch (sc.selectedSegmentIndex)
        {
            case 0:
                diff = -25;
                break;
            case 1:
                diff = -10;
                break;
            case 2:
                diff = -5;
                break;
            case 3:
                diff = -1;
                break;
            case 4:
                diff = 1;
                break;
            case 5:
                diff = 5;
                break;
            case 6:
                diff = 10;
                break;
            case 7:
                diff = 25;
                break;
        }
        
        _page += diff;
        _drawing.page = _page;
    }
    
    else switch (sc.selectedSegmentIndex)
    {
        case 0:
            diff = -0.5;
            break;
        case 1:
            diff = -0.25;
            break;
        case 2:
            diff = -0.1;
            break;
        case 3:
            diff = -0.025;
            break;
        case 4:
            diff = 0.025;
            break;
        case 5:
            diff = 0.1;
            break;
        case 6:
            diff = 0.25;
            break;
        case 7:
            diff = 0.5;
            break;
    }
    
    if (sc == _ulxSC)
    {
        _ul.x += diff;
        _ul.x = MAX(_ul.x, 0.0);
        _ul.x = MIN(_ul.x, _lr.x);
        _drawing.upperLeft = _ul;
    }
    
    else if (sc == _ulySC)
    {
        _ul.y += diff;
        _ul.y = MAX(_ul.y, 0.0);
        _ul.y = MIN(_ul.y, _lr.y);
        _drawing.upperLeft = _ul;
    }
    
    else if (sc == _lrxSC)
    {
        _lr.x += diff;
        _lr.x = MAX(_lr.x, _ul.x);
        _lr.x = MIN(_lr.x, 1.0);
        _drawing.lowerRight = _lr;
    }
    
    else if (sc == _lrySC)
    {
        _lr.y += diff;
        _lr.y = MAX(_lr.y, _ul.y);
        _lr.y = MIN(_lr.y, 1.0);
        _drawing.lowerRight = _lr;
    }
    
    [_webView removeFromSuperview];
    
    _webView = [NVWebView showPDFDrawing:_drawing
                            fromDocument:_document
                                  inView:_containerView
                          withHighlights:@""
                             enableSwipe:NO];
}

@end
