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
#import "CCodeLibrary/NVTextVC.h"
@import MessageUI;

@implementation TimeLine
@end

@interface NVSpreadsheetVC () <NVSpreadsheetDataSource,NVSpreadsheetDelegate,NVAlertViewDelegate,MFMailComposeViewControllerDelegate,NVDocumentManagerDelegate,NVPopoverTableViewDelegate,UITextFieldDelegate>

@property (nonatomic) NVSpreadsheet *nvss;
@property (nonatomic) UIButton *swap, *returnToOrigin, *realtor;
@property (nonatomic) CGFloat columnWidth, rowHeight;
@property (nonatomic) UITextField *titleTextField;
@property (nonatomic) NSInteger selectedRow, selectedColumn;
@property (nonatomic) UILabel *numRowsLabel, *numColsLabel;
@property (nonatomic) UIView *topSpace;

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
    _flipped = YES;
    
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
    [_topSpace constrainTopToAnchor:self.view.topAnchor];
    [_topSpace constrainLeadingToAnchor:self.view.leadingAnchor];
    [_topSpace constrainTrailingToAnchor:self.view.trailingAnchor];
    [_topSpace constrainHeightToConstant:_rowHeight];
    
    UIEdgeInsets insets = UIEdgeInsetsMake((_rowHeight * 0.1), (_rowHeight * 0.1),
                                           (_rowHeight * 0.1), (_rowHeight * 0.1));
    
    UIButton *export = [UIButton buttonWithType:UIButtonTypeCustom];
    export.translatesAutoresizingMaskIntoConstraints = NO;
    export.backgroundColor = UIColor.clearColor;
    export.imageEdgeInsets = insets;
    
    [export setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteUpload"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];
    
    [export addTarget:self
               action:@selector(export:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [_topSpace addSubview:export];
    [export constrainLeadingToAnchor:_topSpace.leadingAnchor];
    [export constrainTopToAnchor:_topSpace.topAnchor];
    [export constrainHeightToConstant:_rowHeight];
    [export constrainWidthToConstant:_rowHeight];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    delete.translatesAutoresizingMaskIntoConstraints = NO;
    delete.backgroundColor = UIColor.clearColor;
    delete.imageEdgeInsets = insets;
    
    [delete setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteTrashCan"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];
    
    [delete addTarget:self
               action:@selector(delete:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [_topSpace addSubview:delete];
    [delete constrainLeadingToAnchor:export.trailingAnchor];
    [delete constrainTopToAnchor:_topSpace.topAnchor];
    [delete constrainHeightToConstant:_rowHeight];
    [delete constrainWidthToConstant:_rowHeight];
    
    UIButton *mapIt = [UIButton buttonWithType:UIButtonTypeCustom];
    mapIt.translatesAutoresizingMaskIntoConstraints = NO;
    mapIt.backgroundColor = UIColor.clearColor;
    switch ([_delegate getSpreadSheetType])
    {
        case SST_PropertyList:
            mapIt.selected = CRAPI.sharedInstance.mapPropList;
            break;
        case SST_CrimeList:
            mapIt.selected = CRAPI.sharedInstance.mapCrimeList != nil;
            break;
    }
    mapIt.imageEdgeInsets = insets;
    
    [mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapItWithX"
                                                                                   ofType:@"png"]]
           forState:UIControlStateNormal];
    
    [mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapItWithX"
                                                                                   ofType:@"png"]]
           forState:UIControlStateNormal|UIControlStateHighlighted];
    
    [mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapIt"
                                                                                   ofType:@"png"]]
           forState:UIControlStateSelected];
    
    [mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapIt"
                                                                                   ofType:@"png"]]
           forState:UIControlStateSelected|UIControlStateHighlighted];
    
    [mapIt addTarget:self
              action:@selector(toggleMapIt:)
    forControlEvents:UIControlEventTouchUpInside];
    
    [_topSpace addSubview:mapIt];
    [mapIt constrainLeadingToAnchor:delete.trailingAnchor];
    [mapIt constrainTopToAnchor:_topSpace.topAnchor];
    [mapIt constrainHeightToConstant:_rowHeight];
    [mapIt constrainWidthToConstant:_rowHeight];
    
    UIButton *create = [UIButton buttonWithType:UIButtonTypeCustom];
    create.translatesAutoresizingMaskIntoConstraints = NO;
    create.backgroundColor = UIColor.clearColor;
    create.imageEdgeInsets = insets;
    
    [create setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whitePlus"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];
    
    [create addTarget:self
               action:@selector(create:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [_topSpace addSubview:create];
    [create constrainTrailingToAnchor:_topSpace.trailingAnchor];
    [create constrainTopToAnchor:_topSpace.topAnchor];
    [create constrainHeightToConstant:_rowHeight];
    [create constrainWidthToConstant:_rowHeight];
    
    UIButton *select = [UIButton buttonWithType:UIButtonTypeCustom];
    select.translatesAutoresizingMaskIntoConstraints = NO;
    select.backgroundColor = UIColor.clearColor;
    select.imageEdgeInsets = insets;
    
    [select setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteList"
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];
    
    [select addTarget:self
               action:@selector(select:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [_topSpace addSubview:select];
    [select constrainTrailingToAnchor:create.leadingAnchor];
    [select constrainTopToAnchor:_topSpace.topAnchor];
    [select constrainHeightToConstant:_rowHeight];
    [select constrainWidthToConstant:_rowHeight];
    
    _realtor = [UIButton buttonWithType:UIButtonTypeCustom];
    _realtor.translatesAutoresizingMaskIntoConstraints = NO;
    _realtor.backgroundColor = UIColor.clearColor;
    _realtor.imageEdgeInsets = insets;
    
    [_realtor setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteHouse"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [_realtor addTarget:self action:@selector(realtor:) forControlEvents:UIControlEventTouchUpInside];
    [_topSpace addSubview:_realtor];
    [_realtor constrainTrailingToAnchor:select.leadingAnchor];
    [_realtor constrainTopToAnchor:_topSpace.topAnchor];
    [_realtor constrainHeightToConstant:_rowHeight];
    [_realtor constrainWidthToConstant:_rowHeight];
    
    _titleTextField = UITextField.new;
    _titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _titleTextField.delegate = self;
    _titleTextField.textAlignment = NSTextAlignmentCenter;
    _titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _titleTextField.textColor = UIColor.whiteColor;
    _titleTextField.adjustsFontSizeToFitWidth = YES;
    _titleTextField.tintColor = UIColor.lightGrayColor;
    _titleTextField.text = _delegate.titleTextForSpreadsheet;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        _titleTextField.font = [UIFont boldSystemFontOfSize:20];
    
    else
        _titleTextField.font = [UIFont boldSystemFontOfSize:30];
    
    [_topSpace addSubview:_titleTextField];
    [_titleTextField constrainLeadingToAnchor:mapIt.trailingAnchor];
    [_titleTextField constrainTrailingToAnchor:_realtor.leadingAnchor];
    [_titleTextField constrainTopToAnchor:_topSpace.topAnchor];
    [_titleTextField constrainHeightToConstant:_rowHeight];
    
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
    [_nvss constrainLeadingToAnchor:self.view.leadingAnchor];
    [_nvss constrainTrailingToAnchor:self.view.trailingAnchor];
    [_nvss constrainTopToAnchor:_topSpace.bottomAnchor];
    [_nvss constrainBottomToAnchor:self.view.bottomAnchor];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_delegate)
        [_delegate openList];
    
    if (CRAPI.sharedInstance.currentApp == HCConfigMetroProp)
        _realtor.hidden = NO;
    
    else
        _realtor.hidden = YES;
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
    return CGSizeMake((self.view.frame.size.width - _columnWidth), (self.view.frame.size.height - (_rowHeight * 2.0)));
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
        
        if (_flipped)
        {
            tr.textLabel.text = [_delegate headerTextForRow:indexPath.nvSpreadsheetColumn];
            tr.textLabel.numberOfLines = 0;
        }
        
        else
        {
            tr.textLabel.text = [_delegate headerTextForColumn:indexPath.nvSpreadsheetColumn];
            tr.textLabel.numberOfLines = 1;
        }
        
        tr.backgroundColor = UIColor.whiteColor;
    }
    
    else if (indexPath.nvSpreadsheetRow > 0 && indexPath.nvSpreadsheetColumn == 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"LeftColumnCell"
                                                          forIndexPath:indexPath];
        
        NVLeftColumnCell *lc = (NVLeftColumnCell *)cell;
        lc.idLabel.text = [NSString stringWithFormat:@"%li", indexPath.nvSpreadsheetRow];
        
        if (_flipped)
        {
            lc.textLabel.text = [_delegate headerTextForColumn:indexPath.nvSpreadsheetRow];
            lc.textLabel.numberOfLines = 1;
        }
        
        else
        {
            lc.textLabel.text = [_delegate headerTextForRow:indexPath.nvSpreadsheetRow];
            lc.textLabel.numberOfLines = 0;
        }
    
        if (indexPath.nvSpreadsheetRow % 2 == 0)
        {
            lc.backgroundColor = [UIColor colorWithRed:(222.0 / 255.0)
                                                 green:(243.0 / 255.0)
                                                  blue:(250.0 / 255.0)
                                                 alpha:1.0];
        }
        
        else
        {
            lc.backgroundColor = [UIColor colorWithRed:(233.0 / 255.0)
                                                 green:(247.0 / 255.0)
                                                  blue:(252.0 / 255.0)
                                                 alpha:1.0];
        }
    }
        
    else
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell"
                                                          forIndexPath:indexPath];
        
        NVGridCell *gc = (NVGridCell *)cell;
        
        if (_flipped)
        {
            gc.textLabel.text = [_delegate textForColumn:indexPath.nvSpreadsheetRow
                                                     row:indexPath.nvSpreadsheetColumn];
        }
        
        else
        {
            gc.textLabel.text = [_delegate textForColumn:indexPath.nvSpreadsheetColumn
                                                     row:indexPath.nvSpreadsheetRow];
        }
        
        if (indexPath.nvSpreadsheetRow % 2 == 0)
        {
            gc.backgroundColor = [UIColor colorWithRed:(242.0 / 255.0)
                                                 green:(242.0 / 255.0)
                                                  blue:(242.0 / 255.0)
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
    if (indexPath.nvSpreadsheetColumn == 0)
    {
        if (!_flipped)
        {
            NSString *filePath = [_delegate propFieldDescriptionFilePathAtRow:indexPath.nvSpreadsheetRow];
            
            NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                            showFileAtPath:filePath];
            
            [nvwv showRealtorButton];
        }
    }
    
    else if (indexPath.nvSpreadsheetRow == 0)
    {
        if (_flipped)
        {
            NSString *filePath = [_delegate propFieldDescriptionFilePathAtRow:indexPath.nvSpreadsheetColumn];
            
            NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                            showFileAtPath:filePath];
            
            [nvwv showRealtorButton];
        }
    }
    
    else
    {
        if (_flipped)
        {
            _selectedRow = indexPath.nvSpreadsheetColumn;
            _selectedColumn = indexPath.nvSpreadsheetRow;
        }
        
        else
        {
            _selectedRow = indexPath.nvSpreadsheetRow;
            _selectedColumn = indexPath.nvSpreadsheetColumn;
        }
        NSArray * optionsArray = @[@"Map It", @"Cancel"];
        if ([_delegate getSpreadSheetType] == SST_CrimeList)
            optionsArray = @[@"Display Report", @"Cancel"];
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:@"Spreadsheet Options"
                                                   buttonTextArray:optionsArray
                                                  destructiveIndex:0];
        alert.identifier = @"MapIt";
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
    _titleTextField.text = [_delegate titleTextForSpreadsheet];
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
    if ([_delegate spreadsheetCanEditRowHeaderTextAtIndex:index])
    {
        if ([_delegate respondsToSelector:@selector(spreadsheetDidEditColumnHeaderText:atIndex:)])
            [_delegate spreadsheetDidEditColumnHeaderText:text atIndex:index];
    }
    
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
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:[NSString stringWithFormat:@"Are you sure you want to delete %@?", _titleTextField.text]
                                               buttonTextArray:@[@"YES", @"NO"]
                                              destructiveIndex:1];
    alert.identifier = @"DeletePrompt";
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
    _titleTextField.text = [_delegate titleTextForSpreadsheet];
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
#pragma unused(nvptv)
    }
}

- (void)realtor:(UIButton *)button
{
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
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
    
    if ([popoverTableView.title isEqualToString:@"Select Spreadsheet"])
    {
        [_delegate spreadsheetDidSetCurrentList:text];
        _titleTextField.text = [_delegate titleTextForSpreadsheet];
        [_nvss reloadData];
    }
    
    else if ([popoverTableView.title isEqualToString:@"Select Realtor Website"])
    {
        NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                             urlString:text];
        
        [nvwv showRealtorButton];
    }
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
                if (MFMailComposeViewController.canSendMail)
                {
                    NSString *tabbedOutput = [self tabbedOutput];
                    NSString *fileName = [self fileName];
                    
                    MFMailComposeViewController *composer = MFMailComposeViewController.new;
                    composer.mailComposeDelegate = self;
                    composer.subject = [NSString stringWithFormat:@"%@ from NVMobile", fileName];
                    
                    [composer setMessageBody:@"The tab-delimited text file attached to this email was created by NVMobile."
                                      isHTML:NO];
                    
                    [composer setToRecipients:[NSArray arrayWithObjects:@"jeffgis@aol.com", @"wildbillmunson@gmail.com", nil]];
                    
                    [composer addAttachmentData:[tabbedOutput dataUsingEncoding:NSUTF8StringEncoding]
                                       mimeType:@"text/plain"
                                       fileName:fileName];
                    
                    [self presentViewController:composer
                                       animated:YES
                                     completion:nil];
                }
                
                else
                {
                    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                                      delegate:self
                                                                         title:@"ERROR: No mail account setup on device."
                                                               buttonTextArray:@[@"OK"]
                                                              destructiveIndex:0];
#pragma unused(alert)
                }
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
    
    else if ([alertView.identifier isEqualToString:@"DeletePrompt"])
    {
        if (buttonIndex == 0)
        {
            [_delegate spreadsheetDidDeleteCurrentList];
            _titleTextField.text = _delegate.titleTextForSpreadsheet;
            [_nvss reloadData];
        }
    }
    
    else if ([alertView.identifier isEqualToString:@"MapIt"])
    {
        if (buttonIndex == 0)
        {
            switch ([_delegate getSpreadSheetType])
            {
                case SST_PropertyList:
                    [_delegate spreadsheetDidMapItForRow:_selectedRow
                                          column:_selectedColumn
                                tabBarController:self.tabBarController];
                    break;
                case SST_CrimeList:
                {
                    NSString *reportText =
                    [_delegate spreadsheetGetReportForRow:_selectedRow
                                                   column:_selectedColumn];
                    NVTextVC *textVC = [[NVTextVC alloc] initWithText:reportText fontSize:16.0];
                    [self presentViewController:textVC animated:YES completion:nil];
                }
                    break;
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

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NSString *resultString = @"";
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            resultString = @"Mail Cancelled";
            break;
            
        case MFMailComposeResultSaved:
            resultString = @"Mail Saved";
            break;
            
        case MFMailComposeResultSent:
            resultString = @"Mail Sent";
            break;
            
        case MFMailComposeResultFailed:
            resultString = [NSString stringWithFormat:@"Mail Send failure:%@",
                            error.localizedDescription];
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:resultString
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
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

@end
