//  NVPDFDefCreatorVC.m
//  CCodeLibrary

#import "NVPDFDefCreatorVC.h"
#import "UserDefaults.h"
#import "SQLiteLib.h"
#import "FTPDataPush.h"
#import "NVPopoverTableView.h"

#define CURRENT_TABLE @"ADASTANDARDS"
#define DB_FILENAME @"NVPDFDefDatabase"
#define DB_FILETYPE @"sqlite3"

@interface NVPDFDefDatabase ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic) sqlite3nv *database;
@property BOOL isOpen;

@end

@implementation NVPDFDefDatabase

+ (instancetype)staticDatabase
{
    NVPDFDefDatabase *pdfdb = [[NVPDFDefDatabase alloc] initWithPath:[NSBundle.mainBundle pathForResource:DB_FILENAME
                                                                                                   ofType:DB_FILETYPE]];
    
    return pdfdb;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self)
        _path = path;
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _path = [NSString stringWithFormat:@"%@/%@.%@", UserDefaults.defaults.localFilePath, DB_FILENAME, DB_FILETYPE];
        BOOL opened = self.open;
        
        NSString *cmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "page INTEGER, ulx REAL, uly REAL, lrx REAL, lry REAL, type TEXT, identifier TEXT, "
        "name TEXT, UNIQUE(type, identifier));", CURRENT_TABLE];
        
        SQLOK(__FILE__,__LINE__, SQLiteExec(_database, cmd.UTF8String, 0, 0, 0), _database);
        [self close:opened];
    }
    
    return self;
}

- (BOOL)open
{
    BOOL rtn = NO;
    
    if (!_isOpen)
    {
        _isOpen = !SQLOK(__FILE__,__LINE__, SQLite_Open(_path.UTF8String, &_database), _database);
        //NSLog(@"NVPDFDefs Database open");
        rtn = YES;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(__FILE__,__LINE__, SQLite_Close(&_database), _database);
        //NSLog(@"NVPDFDefs Database close");
        _isOpen = NO;
    }
}

- (void)dealloc
{
    [self close:_isOpen];
}

- (void)addDrawing:(NVPDFDrawing *)drawing
{
    BOOL opened = self.open;
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES "
                     "(null,'%d','%.4f','%.4f','%.4f','%.4f','%@','%@','%@');",
                     CURRENT_TABLE, drawing.page, drawing.upperLeft.x, drawing.upperLeft.y,
                     drawing.lowerRight.x, drawing.lowerRight.y, drawing.type, drawing.identifier, drawing.name];
    
    SQLOK(__FILE__,__LINE__, SQLiteExec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    [self close:opened];
}

- (int)count
{
    int rtn = 0;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT Count(*) FROM %@;", CURRENT_TABLE];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        rtn = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return rtn;
}

- (NSArray<NVPDFDrawing *> *)drawings
{
    NSMutableArray<NVPDFDrawing *> *drawings = NSMutableArray.array;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    DPOINT ul = {0}, lr = {0};
    LPSTR type = {0}, identifier = {0}, name = {0};
    int iCol = 1, page = 0;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY type ASC, identifier ASC;", CURRENT_TABLE];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        iCol = 1;
        page = sqlite3_column_int(statement, iCol++);
        ul.x = sqlite3_column_double(statement, iCol++);
        ul.y = sqlite3_column_double(statement, iCol++);
        lr.x = sqlite3_column_double(statement, iCol++);
        lr.y = sqlite3_column_double(statement, iCol++);
        type = (LPSTR)sqlite3_column_text(statement, iCol++);
        identifier = (LPSTR)sqlite3_column_text(statement, iCol++);
        name = (LPSTR)sqlite3_column_text(statement, iCol);
        
        NVPDFDrawing *drawing = [NVPDFDrawing drawingWithID:[NSString stringWithUTF8String:identifier]
                                                       name:[NSString stringWithUTF8String:name]
                                                       type:[NSString stringWithUTF8String:type]
                                                       page:page upperLeft:ul lowerRight:lr];

        [drawings addObject:drawing];
    }
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return drawings.copy;
}

- (NVPDFDrawing *)drawingWithType:(NSString *)type
                       identifier:(NSString *)identifier
{
    NVPDFDrawing *drawing = nil;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    DPOINT ul = {0}, lr = {0};
    LPSTR theType = {0}, theIdentifier = {0}, name = {0};
    int iCol = 1, page = 0;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE type='%@' AND identifier='%@';",
                       CURRENT_TABLE, type, identifier];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        iCol = 1;
        page = sqlite3_column_int(statement, iCol++);
        ul.x = sqlite3_column_double(statement, iCol++);
        ul.y = sqlite3_column_double(statement, iCol++);
        lr.x = sqlite3_column_double(statement, iCol++);
        lr.y = sqlite3_column_double(statement, iCol++);
        theType = (LPSTR)sqlite3_column_text(statement, iCol++);
        theIdentifier = (LPSTR)sqlite3_column_text(statement, iCol++);
        name = (LPSTR)sqlite3_column_text(statement, iCol);
        
        drawing = [NVPDFDrawing drawingWithID:[NSString stringWithUTF8String:theIdentifier]
                                         name:[NSString stringWithUTF8String:name]
                                         type:[NSString stringWithUTF8String:theType]
                                         page:page upperLeft:ul lowerRight:lr];
    }
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return drawing;
}

@end

@interface NVPDFDefCreatorVC () <FTPDataPushDelegate, NVPopoverTableViewDelegate>

@property int page, section, id1, id2, id3, id4, id5, id6, maxPage;
@property (nonatomic, copy) NSString *drawingID, *type, *name;
@property (nonatomic, copy) NSArray *typesArray;
@property DPOINT ul, lr;
@property (nonatomic) UIView *containerView;
@property NVPDFDocument document;
@property (nonatomic) NVPDFDrawing *drawing;
@property (nonatomic) NVWebView *webView;
@property (nonatomic) UISegmentedControl *typeSC, *sectSC, *pageSC, *ulxSC, *ulySC, *lrxSC, *lrySC;
@property (nonatomic) UISegmentedControl *id1SC, *id2SC, *id3SC, *id4SC, *id5SC, *id6SC;
@property (nonatomic) UILabel *pageSectIDLabel, *drawingDefLabel, *countLabel;
@property (nonatomic) FTPDataPush *push;

@end

@implementation NVPDFDefCreatorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    CGFloat margin = 10.0;
    _name = _drawingID = _type = @"NONE";
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
    
    _drawing = [NVPDFDrawing drawingWithID:_drawingID name:_name type:_type
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
    
    NSArray *items = @[@"-1", @"-10", @"-25", @"+25", @"+10", @"+1"];
    
    UILabel *pageLabel = UILabel.new;
    [self setupLabel:pageLabel text:@"PAGE"];
    [pageLabel constrainTopToAnchor:_typeSC.bottomAnchor constant:margin];
    
    _pageSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_pageSC];
    [_pageSC constrainTopToAnchor:pageLabel.topAnchor];
    [_pageSC constrainLeadingToAnchor:pageLabel.trailingAnchor];
    
    UIButton *zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomButton.translatesAutoresizingMaskIntoConstraints = NO;
    zoomButton.backgroundColor = UIColor.whiteColor;
    zoomButton.layer.borderColor = UIColor.blackColor.CGColor;
    zoomButton.layer.borderWidth = 2.0;
    zoomButton.adjustsImageWhenHighlighted = YES;
    zoomButton.showsTouchWhenHighlighted = YES;
    
    [zoomButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                          [NSBundle.mainBundle pathForResource:@"zoom"
                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [self.view addSubview:zoomButton];
    [zoomButton constrainTopToAnchor:pageLabel.topAnchor constant:-2.0];
    [zoomButton constrainLeadingToAnchor:_pageSC.trailingAnchor constant:(margin - 2.0)];
    [zoomButton constrainTrailingToAnchor:_typeSC.trailingAnchor constant:2.0];
    [zoomButton constrainHeightToAnchor:_pageSC.heightAnchor multiplier:1.1];
    [zoomButton constrainWidthToAnchor:zoomButton.heightAnchor multiplier:1.5];
    
    [zoomButton addTarget:self
                   action:@selector(zoomButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    
    items = @[@"-1", @"-10", @"-100", @"+100", @"+10", @"+1"];
    
    UILabel *sectLabel = UILabel.new;
    [self setupLabel:sectLabel text:@"SECT"];
    [sectLabel constrainTopToAnchor:pageLabel.bottomAnchor constant:margin];
    
    _sectSC = [[UISegmentedControl alloc] initWithItems:items];
    [self setupSC:_sectSC];
    [_sectSC constrainTopToAnchor:sectLabel.topAnchor];
    [_sectSC constrainLeadingToAnchor:sectLabel.trailingAnchor];
    
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    listButton.translatesAutoresizingMaskIntoConstraints = NO;
    listButton.backgroundColor = UIColor.whiteColor;
    listButton.layer.borderColor = UIColor.blackColor.CGColor;
    listButton.layer.borderWidth = 2.0;
    listButton.adjustsImageWhenHighlighted = YES;
    listButton.showsTouchWhenHighlighted = YES;
    
    [listButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                    [NSBundle.mainBundle pathForResource:@"list"
                                                                  ofType:@"png"]]
                          forState:UIControlStateNormal];
    
    [self.view addSubview:listButton];
    [listButton constrainTopToAnchor:sectLabel.topAnchor constant:-2.0];
    [listButton constrainLeadingToAnchor:_sectSC.trailingAnchor constant:(margin - 2.0)];
    [listButton constrainTrailingToAnchor:_typeSC.trailingAnchor constant:2.0];
    [listButton constrainHeightToAnchor:_typeSC.heightAnchor multiplier:1.1];
    [listButton constrainWidthToAnchor:listButton.heightAnchor multiplier:1.5];
    
    [listButton addTarget:self
                   action:@selector(listButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    
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
    _pageSectIDLabel.font = [UIFont fontWithName:@"CourierNewPSMT" size:24.0];
    [self.view addSubview:_pageSectIDLabel];
    [_pageSectIDLabel constrainLeadingToAnchor:self.view.leadingAnchor constant:(margin / 2.0)];
    [_pageSectIDLabel constrainTopToAnchor:lryLabel.bottomAnchor constant:margin];
    [self updatePageSectIDLabel];
    
    _drawingDefLabel = UILabel.new;
    _drawingDefLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _drawingDefLabel.backgroundColor = _pageSectIDLabel.backgroundColor;
    _drawingDefLabel.textColor = _pageSectIDLabel.textColor;
    _drawingDefLabel.font = _pageSectIDLabel.font;
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
    [saveButton constrainTopToAnchor:_lrySC.bottomAnchor constant:margin];
    [saveButton constrainWidthToConstant:120.0];
    
    [saveButton addTarget:self
                   action:@selector(saveButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.translatesAutoresizingMaskIntoConstraints = NO;
    uploadButton.backgroundColor = UIColor.redColor;
    uploadButton.titleLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:40.0];
    uploadButton.layer.borderColor = UIColor.blackColor.CGColor;
    uploadButton.layer.borderWidth = 2.0;
    [uploadButton setTitle:@"PUSH" forState:UIControlStateNormal];
    [uploadButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [uploadButton setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    [self.view addSubview:uploadButton];
    [uploadButton constrainTrailingToAnchor:_typeSC.trailingAnchor];
    [uploadButton constrainTopToAnchor:saveButton.bottomAnchor constant:margin];
    [uploadButton constrainWidthToAnchor:saveButton.widthAnchor];
    [uploadButton constrainHeightToAnchor:saveButton.heightAnchor];
    [uploadButton constrainBottomToAnchor:_containerView.topAnchor constant:-margin];
    
    [uploadButton addTarget:self
                     action:@selector(uploadButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    _countLabel = UILabel.new;
    _countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_countLabel];
    [_countLabel constrainTopToAnchor:_typeSC.topAnchor];
    [_countLabel constrainHeightToAnchor:_typeSC.heightAnchor];
    [_countLabel constrainLeadingToAnchor:returnButton.trailingAnchor constant:margin];
    _countLabel.backgroundColor = UIColor.blackColor;
    _countLabel.textColor = saveButton.backgroundColor;
    _countLabel.font = saveButton.titleLabel.font;
    _countLabel.text = [NSString stringWithFormat:@"%d", NVPDFDefDatabase.new.count];
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

- (void)saveButtonTapped
{
    if (_typeSC.selectedSegmentIndex == UISegmentedControlNoSegment)
        showAlert(@"ERROR: No type selected.");
    
    else if ([_drawingID isEqualToString:@"NONE"])
        showAlert(@"ERROR: No drawing ID.");
    
    else
    {
        NVPDFDefDatabase *pdfdb = NVPDFDefDatabase.new;
        [pdfdb addDrawing:_drawing];
        _countLabel.text = [NSString stringWithFormat:@"%d", pdfdb.count];
    }
}

- (void)uploadButtonTapped
{
    _push = FTPDataPush.push;
    _push.delegate = self;
    
    NVPDFDefDatabase *pdfdb = NVPDFDefDatabase.new;
    NSString *file = pdfdb.path.lastPathComponent;
    
    [_push sendFile:file
      fromDirectory:pdfdb.path.stringByDeletingLastPathComponent
             toFile:file
        toDirectory:@"NVCRIS/UploadedDatabases"
     deleteWhenDone:NO
     appendFileName:NO];
}

- (void)zoomButtonTapped
{
    _ul.x = _ul.y = 0.0;
    _lr.x = _lr.y = 1.0;
    _drawing.upperLeft = _ul;
    _drawing.lowerRight = _lr;
    
    [self updateWebview];
    [self updateDrawingDefLabel];
}

- (void)listButtonTapped
{
    NSMutableArray *textArray = NSMutableArray.array;
    
    for (NVPDFDrawing *drawing in NVPDFDefDatabase.new.drawings)
        [textArray addObject:[NSString stringWithFormat:@"%@:%@", drawing.type, drawing.identifier]];
    
    [NVPopoverTableView showPopoverTableViewInView:self.view
                                          delegate:self
                                             title:CURRENT_TABLE
                                         textArray:textArray.copy
                                     includeCancel:YES];
}

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
                 atIndex:(NSInteger)index
{
    _drawing = [NVPDFDefDatabase.new drawingWithType:textBeforeColon(text)
                                          identifier:textAfterFirstColon(text)];
    
    _page = _drawing.page;
    _lr = _drawing.lowerRight;
    _ul = _drawing.upperLeft;
    _type = _drawing.type;
    _drawingID = _drawing.identifier;
    
    if ([_type isEqualToString:@"SECTION"])
        [_typeSC setSelectedSegmentIndex:0];
    
    else if ([_type isEqualToString:@"TABLE"])
        [_typeSC setSelectedSegmentIndex:1];
    
    else if ([_type isEqualToString:@"FIGURE"])
        [_typeSC setSelectedSegmentIndex:2];
    
    else if ([_type isEqualToString:@"ITEM"])
        [_typeSC setSelectedSegmentIndex:3];
    
    [self updateWebview];
    [self updateDrawingDefLabel];
    
    _pageSectIDLabel.text = [NSString stringWithFormat:@"PAGE:%d,TYPE:%@,ID:%@",
                             _page, _type, _drawingID];
    
    [popoverTableView hide:YES];
}

- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView
{
    [popoverTableView hide:YES];
}

- (void)FTPPushDidComplete:(FTPDataType)dataType
                withStatus:(FTPStatus)status
           andStatusString:(NSString *)statusString
                  filePath:(NSString *)path
{
    NSLog(@"FTP push completed:%@", statusString);
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
                diff = -1;
                break;
            case 1:
                diff = -10;
                break;
            case 2:
                if (sc == _pageSC)
                    diff = -25;
                else
                    diff = -100;
                break;
            case 3:
                if (sc == _pageSC)
                    diff = 25;
                else
                    diff = 100;
                break;
            case 4:
                diff = 10;
                break;
            case 5:
                diff = 1;
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
            
            if (!_id1)
                _id2 = _id3 = _id4 = _id5 = _id6 = 0;
        }
        
        else if (sc == _id2SC)
        {
            _id2 += diff;
            
            if (!_id2)
                _id3 = _id4 = _id5 = _id6 = 0;
        }
        
        else if (sc == _id3SC)
        {
            _id3 += diff;
            
            if (!_id3)
                _id4 = _id5 = _id6 = 0;
        }
        
        else if (sc == _id4SC)
        {
            _id4 += diff;
            
            if (!_id4)
                _id5 = _id6 = 0;
        }
        
        else if (sc == _id5SC)
        {
            _id5 += diff;
            
            if (!_id5)
                _id6 = 0;
        }
        
        else if (sc == _id6SC)
            _id6 += diff;
        
        if (_id6)
            _id5 = MAX(_id5, 1);
        
        if (_id5)
            _id4 = MAX(_id4, 1);
        
        if (_id4)
            _id3 = MAX(_id3, 1);
        
        if (_id3)
            _id2 = MAX(_id2, 1);
        
        if (_id2)
            _id1 = MAX(_id1, 1);
        
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
        _drawingID = [NSString stringWithFormat:@"%d", _section];
        int asciiStart = 64;
        
        if (_id1)
        {
            if (_id1 > 0)
                _drawingID = [NSString stringWithFormat:@"%@.%d", _drawingID, _id1];
            
            else
                _drawingID = [NSString stringWithFormat:@"%@.%c", _drawingID, (asciiStart - _id1)];
            
            if (_id2)
            {
                if (_id2 > 0)
                    _drawingID = [NSString stringWithFormat:@"%@.%d", _drawingID, _id2];
                
                else
                    _drawingID = [NSString stringWithFormat:@"%@.%c", _drawingID, (asciiStart - _id2)];
                
                if (_id3)
                {
                    if (_id3 > 0)
                        _drawingID = [NSString stringWithFormat:@"%@.%d", _drawingID, _id3];
                    
                    else
                        _drawingID = [NSString stringWithFormat:@"%@.%c", _drawingID, (asciiStart - _id3)];
                    
                    if (_id4)
                    {
                        if (_id4 > 0)
                            _drawingID = [NSString stringWithFormat:@"%@.%d", _drawingID, _id4];
                        
                        else
                            _drawingID = [NSString stringWithFormat:@"%@.%c", _drawingID, (asciiStart - _id4)];
                        
                        if (_id5)
                        {
                            if (_id5 > 0)
                                _drawingID = [NSString stringWithFormat:@"%@.%d", _drawingID, _id5];
                            
                            else
                                _drawingID = [NSString stringWithFormat:@"%@.%c", _drawingID, (asciiStart - _id5)];
                            
                            if (_id6)
                            {
                                if (_id6 > 0)
                                    _drawingID = [NSString stringWithFormat:@"%@.%d", _drawingID, _id6];
                                
                                else
                                    _drawingID = [NSString stringWithFormat:@"%@.%c", _drawingID, (asciiStart - _id6)];
                            }
                        }
                    }
                }
            }
        }
    }
    
    else
    {
        _drawingID = @"NONE";
        _id1 = _id2 = _id3 = _id4 = _id5 = _id6 = 0;
    }
    
    _drawing.identifier = _drawingID;
    _drawing.type = _type;
    
    _pageSectIDLabel.text = [NSString stringWithFormat:@"PAGE:%d,TYPE:%@,ID:%@",
                             _page, _type, _drawingID];
}

- (void)updateDrawingDefLabel
{
    _drawingDefLabel.text = [NSString stringWithFormat:@"ULX:%.4f,ULY:%.4f,LRX:%.4f,LRY:%.4f",
                             _ul.x, _ul.y, _lr.x, _lr.y];
}

@end
