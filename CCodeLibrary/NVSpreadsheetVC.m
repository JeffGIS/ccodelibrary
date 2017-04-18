//  NVSpreadsheetVC.m
//  CCodeLibrary

#import "NVSpreadsheetVC.h"
#import "NVSpreadsheet.h"
#import "NVSpreadsheetCell.h"
#import "NSIndexPath+NVSpreadsheet.h"
#import "CRAPI.h"
#import "NVAlertView.h"
#import "NVPopoverTableView.h"
#import "NVTabBarEdit.h"
#import "NVTextVC.h"
@import MessageUI;

@implementation TimeLine
@end

@interface NVSpreadsheetVC () <NVSpreadsheetDataSource,NVSpreadsheetDelegate,NVAlertViewDelegate,NVDocumentManagerDelegate,NVPopoverTableViewDelegate,UITextFieldDelegate>

@property (nonatomic) NVSpreadsheet *nvss;
@property (nonatomic) UIButton *swap, *returnToOrigin, *realtor, *timeLine, *cpyButton, *export, *delete, *mapIt, *create, *select, *help;
@property (nonatomic) CGFloat columnWidth, rowHeight;
@property (nonatomic) UITextField *titleTextField;
@property (nonatomic) UILabel *numRowsLabel, *numColsLabel;
@property (nonatomic) UIView *topSpace;
@property (nonatomic) NSMutableArray <NSNumber *> *selectedRows;
@property (nonatomic) UIColor *selectedRowColor;
@property NSInteger selectedRow, selectedColumn, lastTapSelectedRow;

@end

@implementation NVSpreadsheetVC

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(pasteboardChanged:)
                                               name:UIPasteboardChangedNotification
                                             object:UIPasteboard.generalPasteboard];
    
    self.view.backgroundColor = UIColor.darkGrayColor;
    _selectedRows = NSMutableArray.array;
    _flipped = YES;
    
    _selectedRowColor = [UIColor colorWithRed:(127.0 / 255.0)
                                        green:(255.0 / 255.0)
                                         blue:(127.0 / 255.0)
                                        alpha:0.2];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _rowHeight = 40.0;
        _columnWidth = 120.0;
    }
    
    else
    {
        _rowHeight = 60.0;
        _columnWidth = 220.0;
    }
    
    _topSpace = UIView.new;
    _topSpace.translatesAutoresizingMaskIntoConstraints = NO;
    _topSpace.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_topSpace];
    
    _export = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_export];
    
    [_export setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteUpload"
                                                                                     ofType:@"png"]]
             forState:UIControlStateNormal];
    
    [_export addTarget:self action:@selector(export:) forControlEvents:UIControlEventTouchUpInside];
    
    _delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_delete];
    
    [_delete setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteTrashCan"
                                                                                     ofType:@"png"]]
             forState:UIControlStateNormal];
    
    [_delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    _mapIt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_mapIt];
    
    switch (_delegate.getSpreadSheetType)
    {
        case SST_PropertyList:
            _mapIt.selected = CRAPI.sharedInstance.mapPropList;
            break;
        case SST_CrimeList:
            _mapIt.selected = CRAPI.sharedInstance.mapCrimeList != nil;
            break;
        default:
            break;
    }
    
    [_mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapItWithX"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];
    
    [_mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapItWithX"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal|UIControlStateHighlighted];
    
    [_mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapIt"
                                                                                    ofType:@"png"]]
            forState:UIControlStateSelected];
    
    [_mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapIt"
                                                                                    ofType:@"png"]]
            forState:UIControlStateSelected|UIControlStateHighlighted];
    
    [_mapIt addTarget:self action:@selector(toggleMapIt:) forControlEvents:UIControlEventTouchUpInside];
    
    _create = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_create];
    
    [_create setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whitePlus"
                                                                                     ofType:@"png"]]
             forState:UIControlStateNormal];
    
    [_create addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
    
    _select = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_select];
    
    [_select setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteList"
                                                                                     ofType:@"png"]]
             forState:UIControlStateNormal];
    
    [_select addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    
    _realtor = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_realtor];
    
    [_realtor setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteHouse"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [_realtor addTarget:self action:@selector(realtor:) forControlEvents:UIControlEventTouchUpInside];
    
    _timeLine = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_timeLine];
    
    [_timeLine setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"clockIcon"
                                                                                       ofType:@"png"]]
               forState:UIControlStateNormal];
    
    [_timeLine addTarget:self action:@selector(timeLine:) forControlEvents:UIControlEventTouchUpInside];
    
    _cpyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_cpyButton];
    _cpyButton.userInteractionEnabled = NO;
    _cpyButton.alpha = 0.5;
    
    [_cpyButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"copyIcon"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];

    [_cpyButton addTarget:self action:@selector(performCopy:) forControlEvents:UIControlEventTouchUpInside];
    
    _help = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_help];
    
    [_help setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteQuestionMark"
                                                                                   ofType:@"png"]]
           forState:UIControlStateNormal];
    
    [_help addTarget:self action:@selector(help:) forControlEvents:UIControlEventTouchUpInside];
    
    _titleTextField = UITextField.new;
    _titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _titleTextField.delegate = self;
    _titleTextField.textAlignment = NSTextAlignmentCenter;
    _titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _titleTextField.textColor = UIColor.whiteColor;
    _titleTextField.adjustsFontSizeToFitWidth = YES;
    _titleTextField.tintColor = UIColor.lightGrayColor;
    _titleTextField.text = _delegate.currentListName;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        _titleTextField.font = [UIFont boldSystemFontOfSize:20];
    
    else
        _titleTextField.font = [UIFont boldSystemFontOfSize:30];
    
    [_topSpace addSubview:_titleTextField];
    
    _nvss = [[NVSpreadsheet alloc] initWithNumberOfHeaderRows:1
                                        numberOfHeaderColumns:1
                                                        frame:CGRectZero];
    
    _nvss.translatesAutoresizingMaskIntoConstraints = NO;
    _nvss.bounces = NO;
    [_nvss registerCellClass:NVGridCell.class forCellWithReuseIdentifier:@"GridCell"];
    [_nvss registerCellClass:NVTopRowCell.class forCellWithReuseIdentifier:@"TopRowCell"];
    [_nvss registerCellClass:NVLeftColumnCell.class forCellWithReuseIdentifier:@"LeftColumnCell"];
    _nvss.delegate = self;
    _nvss.dataSource = self;
    
    [self.view addSubview:_nvss];
    [self resetConstraints:UIApplication.sharedApplication.statusBarOrientation];
}

- (void)setupButton:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake((_rowHeight * 0.1), (_rowHeight * 0.1),
                                           (_rowHeight * 0.1), (_rowHeight * 0.1));
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = UIColor.clearColor;
    button.imageEdgeInsets = insets;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_topSpace addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [self resetConstraints:UIApplication.sharedApplication.statusBarOrientation];
    
    if (_delegate)
        [_delegate openList];
    
    if (CRAPI.sharedInstance.currentApp == HCConfigMetroProp)
    {
        _realtor.hidden = NO;
        _timeLine.hidden = YES;
    }
    
    else
    {
        _realtor.hidden = YES;
        _timeLine.hidden = NO;
    }
}

- (void)resetConstraints:(UIInterfaceOrientation)orientation
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [_topSpace removeAllConstraints];
        
        for (UIView *subview in _topSpace.subviews)
            [subview removeAllConstraints];
        
        if (CRAPI.sharedInstance.currentApp == HCConfigCrimes)
        {
            if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                [_topSpace constrainTopToAnchor:self.view.topAnchor constant:32.0];
            
            else
                [_topSpace constrainTopToAnchor:self.view.topAnchor constant:44.0];
        }
    }
    
    else
        [_topSpace constrainTopToAnchor:self.view.topAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone ||
        orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        [_topSpace constrainHeightToConstant:_rowHeight];
        [_export constrainTopToAnchor:_topSpace.topAnchor];
        [_delete constrainTopToAnchor:_topSpace.topAnchor];
        [_mapIt constrainTopToAnchor:_topSpace.topAnchor];
        [_help constrainTopToAnchor:_topSpace.topAnchor];
        [_create constrainTopToAnchor:_topSpace.topAnchor];
        [_select constrainTopToAnchor:_topSpace.topAnchor];
        [_realtor constrainTopToAnchor:_topSpace.topAnchor];
        [_timeLine constrainTopToAnchor:_topSpace.topAnchor];
        [_cpyButton constrainTopToAnchor:_topSpace.topAnchor];
        [_titleTextField constrainLeadingToAnchor:_help.trailingAnchor];
        [_titleTextField constrainTrailingToAnchor:_cpyButton.leadingAnchor];
        [_export constrainWidthToConstant:_rowHeight];
    }
    
    else
    {
        [_topSpace constrainHeightToConstant:(_rowHeight * 2.0)];
        [_titleTextField constrainLeadingToAnchor:_topSpace.leadingAnchor];
        [_titleTextField constrainTrailingToAnchor:_topSpace.trailingAnchor];
        [_export constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_delete constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_mapIt constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_help constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_cpyButton constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_timeLine constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_select constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_create constrainTopToAnchor:_titleTextField.bottomAnchor];
        [_cpyButton constrainLeadingToAnchor:_help.trailingAnchor];
    }
    
    [_topSpace constrainLeadingToAnchor:self.view.leadingAnchor];
    [_topSpace constrainTrailingToAnchor:self.view.trailingAnchor];
    [_delete constrainWidthToAnchor:_export.widthAnchor];
    [_mapIt constrainWidthToAnchor:_delete.widthAnchor];
    [_help constrainWidthToAnchor:_mapIt.widthAnchor];
    [_cpyButton constrainWidthToAnchor:_help.widthAnchor];
    [_timeLine constrainWidthToAnchor:_cpyButton.widthAnchor];
    [_select constrainWidthToAnchor:_timeLine.widthAnchor];
    [_create constrainWidthToAnchor:_select.widthAnchor];
    [_export constrainHeightToConstant:_rowHeight];
    [_delete constrainHeightToAnchor:_export.heightAnchor];
    [_mapIt constrainHeightToAnchor:_delete.heightAnchor];
    [_help constrainHeightToAnchor:_mapIt.heightAnchor];
    [_cpyButton constrainHeightToAnchor:_help.heightAnchor];
    [_timeLine constrainHeightToAnchor:_cpyButton.heightAnchor];
    [_select constrainHeightToAnchor:_timeLine.heightAnchor];
    [_create constrainHeightToAnchor:_select.heightAnchor];
    [_titleTextField constrainHeightToAnchor:_create.heightAnchor];
    [_export constrainLeadingToAnchor:_topSpace.leadingAnchor];
    [_delete constrainLeadingToAnchor:_export.trailingAnchor];
    [_mapIt constrainLeadingToAnchor:_delete.trailingAnchor];
    [_help constrainLeadingToAnchor:_mapIt.trailingAnchor];
    [_create constrainTrailingToAnchor:_topSpace.trailingAnchor];
    [_select constrainTrailingToAnchor:_create.leadingAnchor];
    [_realtor constrainTrailingToAnchor:_select.leadingAnchor];
    [_timeLine constrainTrailingToAnchor:_realtor.trailingAnchor];
    [_cpyButton constrainTrailingToAnchor:_timeLine.leadingAnchor];
    [_titleTextField constrainTopToAnchor:_topSpace.topAnchor];
    [_nvss constrainLeadingToAnchor:self.view.leadingAnchor];
    [_nvss constrainTrailingToAnchor:self.view.trailingAnchor];
    [_nvss constrainTopToAnchor:_topSpace.bottomAnchor];
    [_nvss constrainBottomToAnchor:self.view.bottomAnchor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_delegate)
        [_delegate closeList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CRAPI.sharedInstance.currentApp == HCConfigMetroProp)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
        UIViewController *fovc = [storyboard instantiateViewControllerWithIdentifier:@"FieldOptionsVC"];
        UIViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DestinationsVC"];
        
        [NVTabBarEdit tabBarController:self.tabBarController
           replaceViewControllerWithID:@"FindVC"
                    withViewController:fovc];
        
        if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.gssi.newvisionmetro"])
        {
            [NVTabBarEdit tabBarController:self.tabBarController
               replaceViewControllerWithID:@"NVMetroSettingsVC"
                        withViewController:dvc];
        }
        
        else
        {
            [NVTabBarEdit tabBarController:self.tabBarController
               replaceViewControllerWithID:@"ApplicationsVC"
                        withViewController:dvc];
        }
    }
    
    [_nvss reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)pasteboardChanged:(id)selector
{
    NSLog(@"Pasteboard Item:%@", UIPasteboard.generalPasteboard.strings.lastObject);
}

- (CGSize)gridContainerSize
{
    return CGSizeMake((self.view.frame.size.width - _columnWidth),
                      (self.view.frame.size.height - (_rowHeight * 2.0)));
}

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_columnWidth, _rowHeight);
}

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    if (_flipped)
        return (_delegate.numColumnsInSpreadsheet + 1);
    
    else
        return (_delegate.numRowsInSpreadsheet + 1);
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    if (_flipped)
        return (_delegate.numRowsInSpreadsheet + 1);
    
    else
        return (_delegate.numColumnsInSpreadsheet + 1);
}

- (UICollectionViewCell *)spreadsheetView:(NVSpreadsheet *)spreadsheetView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn == 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell"
                                                          forIndexPath:indexPath];
        
        NVGridCell *gc = (NVGridCell *)cell;
        gc.backgroundColor = UIColor.lightGrayColor;
        
        if (![gc.contentView.subviews containsObject:_returnToOrigin])
        {
            _returnToOrigin = [UIButton buttonWithType:UIButtonTypeCustom];
            _returnToOrigin.translatesAutoresizingMaskIntoConstraints = NO;
            _returnToOrigin.backgroundColor = UIColor.whiteColor;
            
            _returnToOrigin.imageEdgeInsets = UIEdgeInsetsMake((_rowHeight * 0.1), (_rowHeight * 0.1),
                                                               (_rowHeight * 0.1), (_rowHeight * 0.1));
            
            _returnToOrigin.layer.cornerRadius = 4.0;
            _returnToOrigin.layer.borderWidth = 1.0;
            _returnToOrigin.layer.borderColor = UIColor.blackColor.CGColor;
            
            [_returnToOrigin setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"diagonalArrow"
                                                                                                     ofType:@"png"]]
                             forState:UIControlStateNormal];
            
            [_returnToOrigin addTarget:self
                                action:@selector(returnToOrigin:)
                      forControlEvents:UIControlEventTouchUpInside];
            
            [gc.contentView addSubview:_returnToOrigin];
            [_returnToOrigin constrainCenterXToAnchor:gc.centerXAnchor constant:(_columnWidth * 0.2)];
            [_returnToOrigin constrainCenterYToAnchor:gc.centerYAnchor];
            [_returnToOrigin constrainWidthToConstant:(_columnWidth * 0.36)];
            [_returnToOrigin constrainHeightToConstant:(_rowHeight * 0.8)];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(originLongPressed:)];
            
            [_returnToOrigin addGestureRecognizer:longPress];
        }
        
        if (![gc.contentView.subviews containsObject:_swap])
        {
            _swap = [UIButton buttonWithType:UIButtonTypeCustom];
            _swap.translatesAutoresizingMaskIntoConstraints = NO;
            _swap.backgroundColor = UIColor.whiteColor;
            
            _swap.imageEdgeInsets = UIEdgeInsetsMake((-_rowHeight * 0.1), (-_rowHeight * 0.1),
                                                     (-_rowHeight * 0.1), (-_rowHeight * 0.1));
            
            _swap.layer.cornerRadius = 4.0;
            _swap.layer.borderWidth = 1.0;
            _swap.layer.borderColor = UIColor.blackColor.CGColor;
            
            [_swap setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"swapIcon"
                                                                                           ofType:@"png"]]
                   forState:UIControlStateNormal];
            
            [_swap setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"swapIconHighlighted"
                                                                                           ofType:@"png"]]
                   forState:UIControlStateHighlighted];
            
            [_swap addTarget:self
                      action:@selector(swap:)
            forControlEvents:UIControlEventTouchUpInside];
            
            [gc.contentView addSubview:_swap];
            [_swap constrainCenterXToAnchor:gc.centerXAnchor constant:(-_columnWidth * 0.2)];
            [_swap constrainCenterYToAnchor:gc.centerYAnchor];
            [_swap constrainWidthToConstant:(_columnWidth * 0.36)];
            [_swap constrainHeightToConstant:(_rowHeight * 0.8)];
        }
        
        if (![gc.contentView.subviews containsObject:_numColsLabel])
        {
            _numColsLabel = UILabel.new;
            _numColsLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _numColsLabel.textColor = UIColor.whiteColor;
            _numColsLabel.adjustsFontSizeToFitWidth = YES;
            _numColsLabel.textAlignment = NSTextAlignmentCenter;
            [gc.contentView addSubview:_numColsLabel];
            [_numColsLabel constrainTrailingToAnchor:gc.trailingAnchor constant:-1.0];
            [_numColsLabel constrainTopToAnchor:gc.topAnchor constant:1.0];
            [_numColsLabel constrainWidthToConstant:gc.idSize];
            [_numColsLabel constrainHeightToConstant:gc.idSize];
        }
        
        if (![gc.contentView.subviews containsObject:_numRowsLabel])
        {
            _numRowsLabel = UILabel.new;
            _numRowsLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _numRowsLabel.text = [NSString stringWithFormat:@"%li", ([self numberOfRowsInSpreadsheetView:nil] - 1)];
            _numRowsLabel.textColor = UIColor.whiteColor;
            _numRowsLabel.adjustsFontSizeToFitWidth = YES;
            _numRowsLabel.textAlignment = NSTextAlignmentCenter;
            [gc.contentView addSubview:_numRowsLabel];
            [_numRowsLabel constrainLeadingToAnchor:gc.leadingAnchor constant:1.0];
            [_numRowsLabel constrainBottomToAnchor:gc.bottomAnchor constant:-1.0];
            [_numRowsLabel constrainWidthToConstant:gc.idSize];
            [_numRowsLabel constrainHeightToConstant:gc.idSize];
        }
        
        _numColsLabel.text = [NSString stringWithFormat:@"%li", ([self numberOfColumnsInSpreadsheetView:nil] - 1)];
        _numRowsLabel.text = [NSString stringWithFormat:@"%li", ([self numberOfRowsInSpreadsheetView:nil] - 1)];
    }
    
    else if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn > 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"TopRowCell"
                                                          forIndexPath:indexPath];
        
        NVTopRowCell *tr = (NVTopRowCell *)cell;
        tr.idLabel.text = [NSString stringWithFormat:@"%li", indexPath.nvSpreadsheetColumn];
        tr.contentView.backgroundColor = UIColor.clearColor;
        
        if (_flipped)
        {
            tr.textLabel.text = [_delegate headerTextForRow:indexPath.nvSpreadsheetColumn];
            tr.textLabel.numberOfLines = 0;
        }
        
        else
        {
            tr.textLabel.text = [_delegate headerTextForColumn:indexPath.nvSpreadsheetColumn];
            tr.textLabel.numberOfLines = 1;
            
            for (NSNumber *row in _selectedRows)
            {
                if (indexPath.nvSpreadsheetColumn == row.integerValue)
                {
                    tr.contentView.backgroundColor = _selectedRowColor;
                    break;
                }
            }
        }
        
        tr.backgroundColor = UIColor.whiteColor;
    }
    
    else if (indexPath.nvSpreadsheetRow > 0 && indexPath.nvSpreadsheetColumn == 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"LeftColumnCell"
                                                          forIndexPath:indexPath];
        
        NVLeftColumnCell *lc = (NVLeftColumnCell *)cell;
        lc.idLabel.text = [NSString stringWithFormat:@"%li", indexPath.nvSpreadsheetRow];
        lc.contentView.backgroundColor = UIColor.clearColor;
        
        if (_flipped)
        {
            lc.textLabel.text = [_delegate headerTextForColumn:indexPath.nvSpreadsheetRow];
            lc.textLabel.numberOfLines = 1;
            
            for (NSNumber *row in _selectedRows)
            {
                if (indexPath.nvSpreadsheetRow == row.integerValue)
                {
                    lc.contentView.backgroundColor = _selectedRowColor;
                    break;
                }
            }
        }
        
        else
        {
            lc.textLabel.text = [_delegate headerTextForRow:indexPath.nvSpreadsheetRow];
            lc.textLabel.numberOfLines = 0;
        }
    
        if (indexPath.nvSpreadsheetRow % 2 == 0)
        {
            lc.backgroundColor = [UIColor colorWithRed:(210.0 / 255.0)
                                                 green:(230.0 / 255.0)
                                                  blue:(240.0 / 255.0)
                                                 alpha:1.0];
        }
        
        else
        {
            lc.backgroundColor = [UIColor colorWithRed:(235.0 / 255.0)
                                                 green:(245.0 / 255.0)
                                                  blue:(250.0 / 255.0)
                                                 alpha:1.0];
        }
    }
        
    else
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell"
                                                          forIndexPath:indexPath];
        
        NVGridCell *gc = (NVGridCell *)cell;
        gc.contentView.backgroundColor = UIColor.clearColor;
        
        
        if (_flipped)
        {
            gc.textLabel.text = [_delegate textForColumn:indexPath.nvSpreadsheetRow
                                                     row:indexPath.nvSpreadsheetColumn];
            
            for (NSNumber *row in _selectedRows)
            {
                if (indexPath.nvSpreadsheetRow == row.integerValue)
                {
                    gc.contentView.backgroundColor = _selectedRowColor;
                    break;
                }
            }
        }
        
        else
        {
            gc.textLabel.text = [_delegate textForColumn:indexPath.nvSpreadsheetColumn
                                                     row:indexPath.nvSpreadsheetRow];
            
            for (NSNumber *row in _selectedRows)
            {
                if (indexPath.nvSpreadsheetColumn == row.integerValue)
                {
                    gc.contentView.backgroundColor = _selectedRowColor;
                    break;
                }
            }
        }
        
        if (indexPath.nvSpreadsheetRow % 2 == 0)
        {
            gc.backgroundColor = [UIColor colorWithRed:(230.0 / 255.0)
                                                 green:(230.0 / 255.0)
                                                  blue:(230.0 / 255.0)
                                                 alpha:1.0];
        }
        
        else
        {
            gc.backgroundColor = [UIColor colorWithRed:(250.0 / 255.0)
                                                 green:(250.0 / 255.0)
                                                  blue:(250.0 / 255.0)
                                                 alpha:1.0];
        }
        
        gc.userInteractionEnabled = gc.textLabel.text.length;
    }
    
    return cell;
}

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.nvSpreadsheetRow;
    NSInteger column = indexPath.nvSpreadsheetColumn;
    
    if (column == 0)
    {
        if (_flipped)
            [self updateSelectedRowsAtIndex:row];
        
        else
            [self performRowHeaderActionAtIndex:row];
    }
    
    else if (row == 0)
    {
        if (_flipped)
            [self performRowHeaderActionAtIndex:column];
        
        else
            [self updateSelectedRowsAtIndex:column];
    }
    
    else
    {
        [_nvss reloadData];
        
        if (_flipped)
        {
            _selectedRow = column;
            _selectedColumn = row;
        }
        
        else
        {
            _selectedRow = row;
            _selectedColumn = column;
        }
        
        NSArray *optionsArray = NSArray.array;
        
        switch (_delegate.getSpreadSheetType)
        {
            case SST_CrimeList:
                optionsArray = @[@"Display Report"];
                break;
            case SST_PropertyList:
                optionsArray = @[@"Map It", @"Cancel"];
                break;
            default:
                break;
        }
        
        if (optionsArray.count)
        {
            NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                              delegate:self
                                                                 title:@"Spreadsheet Options"
                                                       buttonTextArray:optionsArray
                                                      destructiveIndex:0];
            alert.identifier = @"MapIt";
            
            if (optionsArray.count == 1)
            {
                alert.hidden = YES;
                [self alertView:alert didTapButtonAtIndex:0];
            }
        }
    }
}

- (void)performRowHeaderActionAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(actionForTapOnRowHeader)])
    {
        switch (_delegate.actionForTapOnRowHeader)
        {
            case SSA_SortRows:
                if ([self spreadsheetViewSortOnRow:index])
                    [_nvss reloadData];
                break;
            case SSA_ShowDescription:
            default:
                [self showPropFieldDescriptionAtIndex:index];
                break;
        }
    }
    
    else
        [self showPropFieldDescriptionAtIndex:index];
}

- (SpreadsheetAction)spreadsheetActionForTwoTouchLongPressOnRowHeader
{
    if ([_delegate respondsToSelector:@selector(actionForTwoTouchLongPressOnRowHeader)])
        return _delegate.actionForTwoTouchLongPressOnRowHeader;
    
    else
        return SSA_SortRows;
}

- (void)showPropFieldDescriptionAtIndex:(NSInteger)index
{
    NSString *filePath = [_delegate propFieldDescriptionFilePathAtRow:index];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath];
    
    [nvwv showRealtorButton];
}

- (void)updateSelectedRowsAtIndex:(NSInteger)index
{
    for (NSNumber *row in _selectedRows)
    {
        if (row.integerValue == index)
        {
            [_selectedRows removeObject:row];
            [_nvss reloadData];
            [self resetCopyButton];
            return;
        }
    }
    
    [_selectedRows addObject:[NSNumber numberWithInteger:index]];
    [_nvss reloadData];
    [self resetCopyButton];
}

- (void)resetCopyButton
{
    if (_selectedRows.count)
    {
        _cpyButton.userInteractionEnabled = YES;
        _cpyButton.alpha = 1.0;
    }
    
    else
    {
        _cpyButton.userInteractionEnabled = NO;
        _cpyButton.alpha = 0.5;
    }
}

- (void)swap:(UIButton *)button
{
    _flipped = !_flipped;
    [_nvss reloadData];
}

- (void)returnToOrigin:(UIButton *)button
{
    [_nvss goToUpperLeft];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_delegate spreadsheetDidEditTitleText:textField.text];
    _titleTextField.text = _delegate.currentListName;
}

- (void)spreadsheetViewDidEditColumnHeaderText:(NSString *)text
                                       atIndex:(NSInteger)index
{
    if ([_delegate spreadsheetCanEditColumnHeaderTextAtIndex:index])
    {
        if ([_delegate respondsToSelector:@selector(spreadsheetDidEditRowHeaderText:atIndex:)])
            [_delegate spreadsheetDidEditRowHeaderText:text atIndex:index];
    }
    
    else
        NSLog(@"ERROR:spreadsheetDidEditColumnHeaderText not implemented.");
}

- (void)spreadsheetViewDidEditRowHeaderText:(NSString *)text
                                    atIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(spreadsheetDidEditColumnHeaderText:atIndex:)])
        [_delegate spreadsheetDidEditColumnHeaderText:text atIndex:index];
    
    else
        NSLog(@"ERROR:spreadsheetDidEditRowHeaderText not implemented.");
}

- (BOOL)spreadsheetViewCanEditHeaderOfType:(int)type
                                   atIndex:(NSInteger)index
{
    switch (type)
    {
        case COLUMN_HEADER:
            if ([_delegate respondsToSelector:@selector(spreadsheetCanEditRowHeaderTextAtIndex:)])
                return [_delegate spreadsheetCanEditRowHeaderTextAtIndex:index];
            
            else
            {
                NSLog(@"ERROR:spreadsheetCanEditRowHeaderTextAtIndex not implemented.");
                return NO;
            }
        case ROW_HEADER:
            if ([_delegate respondsToSelector:@selector(spreadsheetCanEditColumnHeaderTextAtIndex:)])
                return [_delegate spreadsheetCanEditColumnHeaderTextAtIndex:index];
            
            else
            {
                NSLog(@"ERROR:spreadsheetCanEditColumnHeaderTextAtIndex not implemented.");
                return NO;
            }
        default:
            return NO;
            break;
    }
}

- (BOOL)spreadsheetIsFlipped
{
    return _flipped;
}

- (void)export:(UIButton *)button
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:@"Select Export Method"
                                               buttonTextArray:@[@"Export as Email Attachment", @"Export to Cloud", @"Cancel"]
                                              destructiveIndex:0];
    alert.identifier = @"ExportPrompt";
}

- (void)delete:(UIButton *)button
{
    NSString *title = @"", *identifier = @"";
    
    if (_selectedRows.count)
    {
        title = @"Are you sure you want to delete selected rows?";
        identifier = @"RowDeletePrompt";
    }
    
    else
    {
        title = [NSString stringWithFormat:@"Are you sure you want to delete %@?", _titleTextField.text];
        identifier = @"SpreadsheetDeletePrompt";
    }
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:title
                                               buttonTextArray:@[@"YES", @"NO"]
                                              destructiveIndex:1];
    alert.identifier = identifier;
}

- (void)toggleMapIt:(UIButton *)button
{
    button.selected = !button.selected;
    switch ([_delegate getSpreadSheetType])
    {
        case SST_PropertyList:
            CRAPI.sharedInstance.mapPropList = button.selected;
            break;
        case SST_CrimeList:
        {
            if (!button.selected)
                CRAPI.sharedInstance.mapCrimeList = nil;
            else
                CRAPI.sharedInstance.mapCrimeList = [_delegate currentListName];
       }
            break;
    }
 }

- (void)create:(UIButton *)button
{
    [_delegate spreadsheetDidCreateList];
    _titleTextField.text = _delegate.currentListName;
    [_nvss reloadData];
}

- (void)select:(UIButton *)button
{
    NSArray *fileList = _delegate.spreadsheetDidGetLists;
    
    if (fileList.count > 0)
    {
        NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                          delegate:self
                                                                             title:@"Select Spreadsheet"
                                                                         textArray:fileList
                                                                     includeCancel:YES];
        nvptv.identifier = @"Select";
    }
}

- (void)realtor:(UIButton *)button
{
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Select Realtor Website"
                                                                     textArray:UserDefaults.defaults.realtorList
                                                                 includeCancel:YES];
    nvptv.identifier = @"Realtor";
}

- (void)timeLine:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(getTimeLine:)])
        [_delegate getTimeLine:self];
}

- (void)performCopy:(UIButton *)button
{
    NSMutableArray *fileList = _delegate.spreadsheetDidGetLists.mutableCopy;

    for (NSString *file in fileList)
    {
        if ([file isEqualToString:_delegate.currentListName])
        {
            [fileList removeObject:file];
            break;
        }
    }
    
    [fileList insertObject:@"New Spreadsheet" atIndex:0];
    
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Select Spreadsheet to Copy Selected Rows"
                                                                     textArray:fileList.copy
                                                                 includeCancel:YES];
    nvptv.identifier = @"CopyRows";
}

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
                 atIndex:(NSInteger)index
{
    if ([popoverTableView.identifier isEqualToString:@"Select"])
    {
        [_delegate spreadsheetDidSetCurrentList:text];
        _titleTextField.text = _delegate.currentListName;
        [_selectedRows removeAllObjects];
        [_nvss reloadData];
    }
    
    else if ([popoverTableView.identifier isEqualToString:@"Realtor"])
    {
        NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                             urlString:text];
        
        [nvwv showRealtorButton];
    }
    
    else if ([popoverTableView.identifier isEqualToString:@"CopyRows"])
    {
        if ([text isEqualToString:@"New Spreadsheet"])
            text = nil;
        
        [_delegate copyRows:_selectedRows toList:text];
    }
    
    [popoverTableView hide:YES];
}

- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView
{
    [popoverTableView hide:YES];
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.identifier isEqualToString:@"ExportPrompt"])
    {
        switch (buttonIndex)
        {
            case 0://Export as Email Attachment
            {
                [NVSendEmail sendEmailWithSubject:[NSString stringWithFormat:@"%@ from NVMobile", self.fileName]
                                          message:@"The tab-delimited text file attached to this email was created by NVMobile."
                                   attachmentData:[self.tabbedOutput dataUsingEncoding:NSUTF8StringEncoding]
                                         mimeType:@"text/plain"
                                         fileName:self.fileName
                                       controller:self];
            }
                break;
            case 1://Export to Cloud
            {
                NSString *tabbedOutput = [self tabbedOutput];
                NSString *fileName = [self fileName];
                NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
                NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
                NSError *error = nil;
                
                [tabbedOutput writeToFile:filepath
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
                
                if (error)
                    NSLog(@"Export to Cloud File Write ERROR:%@", error);
                
                else
                {
                    [CRAPI.sharedInstance.docManager exportDocumentFromFilepath:filepath
                                                                       delegate:self
                                                                 deleteWhenDone:YES];
                }
            }
                break;
            default:
                break;
        }
    }
    
    else if ([alertView.identifier isEqualToString:@"SpreadsheetDeletePrompt"])
    {
        if (buttonIndex == 0)
        {
            [_delegate spreadsheetDidDeleteCurrentList];
            _titleTextField.text = _delegate.currentListName;
            [_nvss reloadData];
        }
    }
    
    else if ([alertView.identifier isEqualToString:@"RowDeletePrompt"])
    {
        if (buttonIndex == 0)
        {
            NSMutableArray *tempArray = NSMutableArray.array;
            
            for (NSNumber *row in _selectedRows)
                [tempArray addObject:[NSNumber numberWithInteger:(row.integerValue - 1)]];
            
            [_delegate deleteRows:tempArray.copy];
            [_selectedRows removeAllObjects];
            
            if (!_flipped && _delegate.numColumnsInSpreadsheet == 0)
                _flipped = YES;
            
            [_nvss reloadData];
        }
    }
    
    else if ([alertView.identifier isEqualToString:@"MapIt"])
    {
        if (buttonIndex == 0)
        {
            switch (_delegate.getSpreadSheetType)
            {
                case SST_PropertyList:
                    [_delegate spreadsheetDidMapItForRow:_selectedRow
                                                  column:_selectedColumn
                                        tabBarController:self.tabBarController];
                    break;
                case SST_CrimeList:
                {
                    NSString *reportText = [_delegate spreadsheetGetReportForRow:_selectedRow
                                                                          column:_selectedColumn];
                    
                    NVTextVC *textVC = [[NVTextVC alloc] initWithText:reportText fontSize:16.0];
                    NSArray * searchStrings = [_delegate getSearchStrings];
                    textVC.redSubstring = @"";
                    if (searchStrings.count > 0)
                        textVC.redSubstring = searchStrings[0];
                    textVC.greenSubstring = @"";
                    if (searchStrings.count > 1)
                        textVC.greenSubstring = searchStrings[1];
                    textVC.blueSubstring = @"";
                    if (searchStrings.count > 2)
                        textVC.blueSubstring = searchStrings[2];
                    [self presentViewController:textVC animated:YES completion:nil];
                    break;
                }
            }
        }
    }
    
    else if ([alertView.identifier isEqualToString:@"SpreadsheetNavigation"])
    {
        switch (buttonIndex)
        {
            case 0://cancel
                break;
            case 1:
                [_nvss goToTop];
                break;
            case 2:
                [_nvss goToBottom];
                break;
            case 3:
                [_nvss goToLeftSide];
                break;
            case 4:
                [_nvss goToRightSide];
                break;
            case 5:
                [_nvss goToUpperLeft];
                break;
            case 6:
                [_nvss goToUpperRight];
                break;
            case 7:
                [_nvss goToLowerLeft];
                break;
            case 8:
                [_nvss goToLowerRight];
                break;
            default:
                break;
        }
    }
    
    [alertView hideLargeAlertView:YES];
}

- (NSString *)fileName
{
    NSString *fileName = @"Spreadsheet.txt";
    
    if (_titleTextField.text.length)
        fileName = [NSString stringWithFormat:@"%@.txt", _titleTextField.text];
    
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return fileName;
}

- (NSString *)tabbedOutput
{
    NSMutableString *output = NSMutableString.string;
    NSInteger rows = (_delegate.numRowsInSpreadsheet + 1);
    NSInteger columns = (_delegate.numColumnsInSpreadsheet + 1);
    NSString *text = nil;
    
    for (int i = 1; i < rows; i++)
    {
        text = [[_delegate headerTextForRow:i] stringByReplacingOccurrencesOfString:@"\n"
                                                                         withString:@" "];
        
        if (!text)
            text = @"";
        
        [output appendString:[NSString stringWithFormat:@"%@\t", text]];
        
        for (int j = 1; j < columns; j++)
        {
            text = [[_delegate textForColumn:j row:i] stringByReplacingOccurrencesOfString:@"\n"
                                                                                withString:@" "];
            
            if (!text)
                text = @"";
            
            [output appendString:text];
            
            if (j < (columns - 1))
                [output appendString:@"\t"];
        }
        
        if (i < (rows - 1))
            [output appendString:@"\n"];
    }
    
    return output.copy;
}

- (void)documentManagerDidCompleteWithMessage:(NSString *)message
                                     filepath:(NSString *)filepath
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:message
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (void)originLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:@"Spreadsheet Navigation Options"
                                                   buttonTextArray:@[@"Cancel", @"Go to Top", @"Go to Bottom", @"Go to Left Side", @"Go to Right Side",
                                                                     @"Go to Upper Left", @"Go to Upper Right", @"Go to Lower Left", @"Go to Lower Right"]
                                                  destructiveIndex:0];
        alert.identifier = @"SpreadsheetNavigation";
    }
}

- (NSString *)spreadsheetViewRowHeaderPrefixAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(spreadsheetRowHeaderTextPrefixAtIndex:)])
        return [_delegate spreadsheetRowHeaderTextPrefixAtIndex:index];
    
    else
    {
        NSLog(@"ERROR:spreadsheetRowHeaderTextPrefixAtIndex not implemented.");
        return nil;
    }
}

- (void)spreadsheetViewInEditingMode:(BOOL)editingMode
{
    if (editingMode)
    {
        _topSpace.userInteractionEnabled = NO;
        _topSpace.alpha = 0.5;
        _swap.userInteractionEnabled = NO;
        _swap.alpha = 0.5;
        _returnToOrigin.userInteractionEnabled = NO;
        _returnToOrigin.alpha = 0.5;
    }
    
    else
    {
        _topSpace.userInteractionEnabled = YES;
        _topSpace.alpha = 1.0;
        _swap.userInteractionEnabled = YES;
        _swap.alpha = 1.0;
        _returnToOrigin.userInteractionEnabled = YES;
        _returnToOrigin.alpha = 1.0;
    }
}

- (BOOL)spreadsheetViewSortOnRow:(NSInteger)row
{
    if ([_delegate respondsToSelector:@selector(spreadsheetSortOnRow:)])
        return [_delegate spreadsheetSortOnRow:row];
    
    else
    {
        NSLog(@"ERROR:spreadsheetSortOnRow not implemented.");
        return NO;
    }
}

- (BOOL)multiSelectRequestedAtIndex:(NSInteger)index
{
    BOOL rtn = NO;
    
    if (_selectedRows.count)
    {
        NSInteger lastSelectedRow = _selectedRows.lastObject.integerValue;
        
        if (lastSelectedRow == _lastTapSelectedRow)
            [_selectedRows removeLastObject];
        
        if (index >= lastSelectedRow)
        {
            for (NSInteger i = lastSelectedRow; i <= index; i++)
            {
                BOOL addRow = YES;
                
                for (NSNumber *row in _selectedRows)
                {
                    if (i == row.integerValue)
                    {
                        [_selectedRows removeObject:row];
                        addRow = NO;
                        break;
                    }
                }
                
                if (addRow)
                    [_selectedRows addObject:[NSNumber numberWithInteger:i]];
            }
        }
        
        else
        {
            for (NSInteger i = lastSelectedRow; i >= index; i--)
            {
                BOOL addRow = YES;
                
                for (NSNumber *row in _selectedRows)
                {
                    if (i == row.integerValue)
                    {
                        [_selectedRows removeObject:row];
                        addRow = NO;
                        break;
                    }
                }
                
                if (addRow)
                    [_selectedRows addObject:[NSNumber numberWithInteger:i]];
            }
        }
        
        rtn = YES;
    }
    
    return rtn;
}

- (void)spreadsheetSwapEnabled:(BOOL)enabled
{
    if (enabled)
    {
        _swap.alpha = 1.0;
        _swap.userInteractionEnabled = YES;
    }
    
    else
    {
        _swap.alpha = 0.5;
        _swap.userInteractionEnabled = NO;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [self resetConstraints:toInterfaceOrientation];
}

- (void)help:(UIButton *)button
{
    NSString *filePath = _delegate.filePathForHelpFile;
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath];
#pragma unused(nvwv)
}

@end
