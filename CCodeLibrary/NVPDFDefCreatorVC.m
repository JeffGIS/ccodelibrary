//  NVPDFDefCreatorVC.m
//  CCodeLibrary

#import "NVPDFDefCreatorVC.h"
#import "UserDefaults.h"
#import "NVPDFDrawing.h"

@interface NVPDFDefDatabase ()

@end

@implementation NVPDFDefDatabase

@end

@interface NVPDFDefCreatorVC ()

@property int page, section, id1, id2, id3, id4, id5, id6, maxPage;
@property (nonatomic, copy) NSString *drawingID, *type;
@property (nonatomic, copy) NSArray *typesArray;
@property DPOINT ul, lr;
@property (nonatomic) UIView *containerView;
@property NVPDFDocument document;
@property (nonatomic) NVPDFDrawing *drawing;
@property (nonatomic) NVWebView *webView;
@property (nonatomic) UISegmentedControl *typeSC, *sectSC, *pageSC, *ulxSC, *ulySC, *lrxSC, *lrySC;
@property (nonatomic) UISegmentedControl *id1SC, *id2SC, *id3SC, *id4SC, *id5SC, *id6SC;
@property (nonatomic) UILabel *pageSectIDLabel, *drawingDefLabel;

@end

@implementation NVPDFDefCreatorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    CGFloat margin = 10.0;
    _drawingID = _type = @"NONE";
    _typesArray = @[@"SECTION", @"TABLE", @"FIGURE", @"ITEM"];
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.backgroundColor = UIColor.clearColor;
    [returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    [self.view addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [returnButton constrainTopToAnchor:self.view.topAnchor];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _document = NVPDFDocumentFederalADA;
    _maxPage = 279;
    _page = 1;
    _ul.x = _ul.y = 0.0;
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
    
    _typeSC = [[UISegmentedControl alloc] initWithItems:_typesArray];
    [self setupSC:_typeSC];
    _typeSC.momentary = NO;
    [_typeSC constrainTopToAnchor:self.view.topAnchor constant:margin];
    [_typeSC constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    
    UILabel *typeLabel = UILabel.new;
    [self setupLabel:typeLabel text:@"TYPE"];
    [typeLabel removeAllConstraints];
    [typeLabel constrainTopToAnchor:_typeSC.topAnchor];
    [typeLabel constrainHeightToAnchor:_typeSC.heightAnchor];
    [typeLabel constrainWidthToConstant:60.0];
    [typeLabel constrainTrailingToAnchor:_typeSC.leadingAnchor];
    
    NSArray *items = @[@"-25", @"-10", @"-5", @"-1", @"+1", @"+5", @"+10", @"+25"];
    
    UILabel *pageLabel = UILabel.new;
    [self setupLabel:pageLabel text:@"PAGE"];
    [pageLabel constrainTopToAnchor:_typeSC.bottomAnchor constant:margin];
    
    _pageSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_pageSC];
    [_pageSC constrainTopToAnchor:pageLabel.topAnchor];
    [_pageSC constrainLeadingToAnchor:pageLabel.trailingAnchor];
    [_pageSC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    items = @[@"-100", @"-10", @"-5", @"-1", @"+1", @"+5", @"+10", @"+100"];
    
    UILabel *sectLabel = UILabel.new;
    [self setupLabel:sectLabel text:@"SECT"];
    [sectLabel constrainTopToAnchor:pageLabel.bottomAnchor constant:margin];
    
    _sectSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_sectSC];
    [_sectSC constrainTopToAnchor:sectLabel.topAnchor];
    [_sectSC constrainLeadingToAnchor:sectLabel.trailingAnchor];
    [_sectSC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    items = @[@"-", @"+"];
    
    UILabel *idLabel = UILabel.new;
    [self setupLabel:idLabel text:@"ID"];
    [idLabel constrainTopToAnchor:sectLabel.bottomAnchor constant:margin];
    
    _id1SC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_id1SC];
    [_id1SC constrainTopToAnchor:idLabel.topAnchor];
    [_id1SC constrainLeadingToAnchor:idLabel.trailingAnchor];
    
    _id2SC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_id2SC];
    [_id2SC constrainTopToAnchor:idLabel.topAnchor];
    [_id2SC constrainLeadingToAnchor:_id1SC.trailingAnchor constant:margin];
    [_id2SC constrainWidthToAnchor:_id1SC.widthAnchor];
    
    _id3SC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_id3SC];
    [_id3SC constrainTopToAnchor:idLabel.topAnchor];
    [_id3SC constrainLeadingToAnchor:_id2SC.trailingAnchor constant:margin];
    [_id3SC constrainWidthToAnchor:_id2SC.widthAnchor];
    
    _id4SC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_id4SC];
    [_id4SC constrainTopToAnchor:idLabel.topAnchor];
    [_id4SC constrainLeadingToAnchor:_id3SC.trailingAnchor constant:margin];
    [_id4SC constrainWidthToAnchor:_id3SC.widthAnchor];
    
    _id5SC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_id5SC];
    [_id5SC constrainTopToAnchor:idLabel.topAnchor];
    [_id5SC constrainLeadingToAnchor:_id4SC.trailingAnchor constant:margin];
    [_id5SC constrainWidthToAnchor:_id4SC.widthAnchor];
    
    _id6SC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_id6SC];
    [_id6SC constrainTopToAnchor:idLabel.topAnchor];
    [_id6SC constrainLeadingToAnchor:_id5SC.trailingAnchor constant:margin];
    [_id6SC constrainWidthToAnchor:_id5SC.widthAnchor];
    [_id6SC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    items = @[@"-.25", @"-.05", @"-.01", @"-.0025", @"+.0025", @"+.01", @"+.05", @"+.25"];
    
    UILabel *ulxLabel = UILabel.new;
    [self setupLabel:ulxLabel text:@"ULX"];
    [ulxLabel constrainTopToAnchor:idLabel.bottomAnchor constant:margin];
    
    _ulxSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_ulxSC];
    [_ulxSC constrainTopToAnchor:ulxLabel.topAnchor];
    [_ulxSC constrainLeadingToAnchor:ulxLabel.trailingAnchor];
    [_ulxSC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    UILabel *ulyLabel = UILabel.new;
    [self setupLabel:ulyLabel text:@"ULY"];
    [ulyLabel constrainTopToAnchor:ulxLabel.bottomAnchor constant:margin];
    
    _ulySC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_ulySC];
    [_ulySC constrainTopToAnchor:ulyLabel.topAnchor];
    [_ulySC constrainLeadingToAnchor:ulyLabel.trailingAnchor];
    [_ulySC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    UILabel *lrxLabel = UILabel.new;
    [self setupLabel:lrxLabel text:@"LRX"];
    [lrxLabel constrainTopToAnchor:ulyLabel.bottomAnchor constant:margin];
    
    _lrxSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_lrxSC];
    [_lrxSC constrainTopToAnchor:lrxLabel.topAnchor];
    [_lrxSC constrainLeadingToAnchor:lrxLabel.trailingAnchor];
    [_lrxSC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    UILabel *lryLabel = UILabel.new;
    [self setupLabel:lryLabel text:@"LRY"];
    [lryLabel constrainTopToAnchor:lrxLabel.bottomAnchor constant:margin];
    
    _lrySC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_lrySC];
    [_lrySC constrainTopToAnchor:lryLabel.topAnchor];
    [_lrySC constrainLeadingToAnchor:lryLabel.trailingAnchor];
    [_lrySC constrainTrailingToAnchor:_typeSC.trailingAnchor];
    
    _pageSectIDLabel = UILabel.new;
    _pageSectIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _pageSectIDLabel.backgroundColor = UIColor.clearColor;
    _pageSectIDLabel.textColor = UIColor.whiteColor;
    _pageSectIDLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:28.0];
    [self.view addSubview:_pageSectIDLabel];
    [_pageSectIDLabel constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_pageSectIDLabel constrainTopToAnchor:lryLabel.bottomAnchor constant:margin];
    [self updatePageSectIDLabel];
    
    _drawingDefLabel = UILabel.new;
    _drawingDefLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _drawingDefLabel.backgroundColor = UIColor.clearColor;
    _drawingDefLabel.textColor = UIColor.whiteColor;
    _drawingDefLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:28.0];
    [self.view addSubview:_drawingDefLabel];
    [_drawingDefLabel constrainLeadingToAnchor:_pageSectIDLabel.leadingAnchor];
    [_drawingDefLabel constrainTopToAnchor:_pageSectIDLabel.bottomAnchor];
    [_drawingDefLabel constrainBottomToAnchor:_containerView.topAnchor constant:-margin];
    [_drawingDefLabel constrainHeightToAnchor:_pageSectIDLabel.heightAnchor];
    [self updateDrawingDefLabel];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.backgroundColor = UserDefaults.defaults.darkGreen;
    saveButton.titleLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:40.0];
    saveButton.layer.borderColor = UIColor.blackColor.CGColor;
    saveButton.layer.borderWidth = 2.0;
    [saveButton setTitle:@"SAVE" forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    [self.view addSubview:saveButton];
    [saveButton constrainTrailingToAnchor:_typeSC.trailingAnchor];
    [saveButton constrainTopToAnchor:_pageSectIDLabel.topAnchor];
    [saveButton constrainHeightToAnchor:_pageSectIDLabel.heightAnchor];
    [saveButton constrainWidthToConstant:120.0];
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
              text:(NSString *)text
{
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = UIColor.clearColor;
    label.textColor = UIColor.whiteColor;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:22.0];
    [self.view addSubview:label];
    [label constrainLeadingToAnchor:self.view.leadingAnchor];
    [label constrainHeightToConstant:40.0];
    [label constrainWidthToConstant:60.0];
}

- (void)setupSC:(UISegmentedControl *)sc
{
    sc.translatesAutoresizingMaskIntoConstraints = NO;
    sc.backgroundColor = UIColor.blackColor;
    sc.tintColor = UIColor.whiteColor;
    sc.momentary = YES;
    sc.layer.borderWidth = 2.0;
    sc.layer.borderColor = UIColor.whiteColor.CGColor;
    
    [sc setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"CourierNewPSMT" size:22.0]
                                                           forKey:NSFontAttributeName]
                      forState:UIControlStateNormal];
    
    [self.view addSubview:sc];
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
    
    if (sc == _typeSC)
    {
        _type = _typesArray[sc.selectedSegmentIndex];
        [self updatePageSectIDLabel];
    }
    
    else if (sc == _pageSC || sc == _sectSC)
    {
        switch (sc.selectedSegmentIndex)
        {
            case 0:
                if (sc == _pageSC)
                    diff = -25;
                else
                    diff = -100;
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
                if (sc == _pageSC)
                    diff = 25;
                else
                    diff = 100;
                break;
            default:break;
        }
        
        if (sc == _pageSC)
        {
            _page += diff;
            _page = MAX(_page, 1);
            _page = MIN(_page, _maxPage);
            _drawing.page = _page;
            [self updateWebview];
        }
        
        else
        {
            _section += diff;
            _section = MAX(_section, 0);
        }
        
        [self updatePageSectIDLabel];
    }
    
    else if (sc.numberOfSegments == 2)
    {
        switch (sc.selectedSegmentIndex)
        {
            case 0:
                diff = -1;
                break;
            case 1:
                diff = 1;
                break;
            default:break;
        }
        
        if (sc == _id1SC)
        {
            _id1 += diff;
            _id1 = MAX(_id1, 0);
        }
        
        else if (sc == _id2SC)
        {
            _id2 += diff;
            _id2 = MAX(_id2, 0);
        }
        
        else if (sc == _id3SC)
        {
            _id3 += diff;
            _id3 = MAX(_id3, 0);
        }
        
        else if (sc == _id4SC)
        {
            _id4 += diff;
            _id4 = MAX(_id4, 0);
        }
        
        else if (sc == _id5SC)
        {
            _id5 += diff;
            _id5 = MAX(_id5, 0);
        }
        
        else if (sc == _id6SC)
        {
            _id6 += diff;
            _id6 = MAX(_id6, 0);
        }
        
        [self updatePageSectIDLabel];
    }
    
    else
    {
        switch (sc.selectedSegmentIndex)
        {
            case 0:
                diff = -0.25;
                break;
            case 1:
                diff = -0.05;
                break;
            case 2:
                diff = -0.01;
                break;
            case 3:
                diff = -0.0025;
                break;
            case 4:
                diff = 0.0025;
                break;
            case 5:
                diff = 0.01;
                break;
            case 6:
                diff = 0.05;
                break;
            case 7:
                diff = 0.25;
                break;
            default:break;
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
        
        [self updateWebview];
        [self updateDrawingDefLabel];
    }
}

- (void)updateWebview
{
    [_webView removeFromSuperview];
    _webView = nil;
    
    _webView = [NVWebView showPDFDrawing:_drawing
                            fromDocument:_document
                                  inView:_containerView
                          withHighlights:@""
                             enableSwipe:NO];
}

- (void)updatePageSectIDLabel
{
    if (_section)
    {
        _drawingID = [NSString stringWithFormat:@"%d.%d.%d.%d.%d.%d.%d",
                      _section, _id1, _id2, _id3, _id4, _id5, _id6];
    }
    
    else
    {
        _drawingID = @"NONE";
        _id1 = _id2 = _id3 = _id4 = _id5 = _id6 = 0;
    }
    
    NSString *text = [NSString stringWithFormat:@"PAGE:%d,TYPE:%@,ID:%@",
                      _page, _type, _drawingID];
    
    while ([[text substringFromIndex:(text.length - 2)] isEqualToString:@".0"])
        text = [text substringToIndex:(text.length - 2)];
    
    _pageSectIDLabel.text = text;
}

- (void)updateDrawingDefLabel
{
    _drawingDefLabel.text = [NSString stringWithFormat:@"ULX:%.4f,ULY:%.4f,LRX:%.4f,LRY:%.4f",
                             _ul.x, _ul.y, _lr.x, _lr.y];
}

@end
