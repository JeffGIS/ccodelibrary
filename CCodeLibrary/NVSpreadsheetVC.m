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
@import MessageUI;

@interface NVSpreadsheetVC () <NVSpreadsheetDataSource,NVSpreadsheetDelegate,NVAlertViewDelegate,MFMailComposeViewControllerDelegate,NVDocumentManagerDelegate,NVPopoverTableViewDelegate>

@property (nonatomic) NVSpreadsheet *nvss;
@property (nonatomic) UIButton *swap, *returnToOrigin;
@property (nonatomic) CGFloat columnWidth, rowHeight;
@property (nonatomic) UITextField *titleTextField;
@property (nonatomic) NSInteger selectedRow, selectedColumn;

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
    _flipped = NO;
    
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
    
    UIView *topSpace = UIView.new;
    topSpace.translatesAutoresizingMaskIntoConstraints = NO;
    topSpace.backgroundColor = UIColor.clearColor;
    
    [self.view addSubview:topSpace];
    [topSpace constrainTopToAnchor:self.view.topAnchor];
    [topSpace constrainLeadingToAnchor:self.view.leadingAnchor];
    [topSpace constrainTrailingToAnchor:self.view.trailingAnchor];
    [topSpace constrainHeightToConstant:_rowHeight];
    
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
    
    [topSpace addSubview:export];
    [export constrainLeadingToAnchor:topSpace.leadingAnchor];
    [export constrainTopToAnchor:topSpace.topAnchor];
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
    
    [topSpace addSubview:delete];
    [delete constrainLeadingToAnchor:export.trailingAnchor];
    [delete constrainTopToAnchor:topSpace.topAnchor];
    [delete constrainHeightToConstant:_rowHeight];
    [delete constrainWidthToConstant:_rowHeight];
    
    UIButton *mapIt = [UIButton buttonWithType:UIButtonTypeCustom];
    mapIt.translatesAutoresizingMaskIntoConstraints = NO;
    mapIt.backgroundColor = UIColor.clearColor;
    mapIt.selected = CRAPI.sharedInstance.mapPropList;
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
    
    [topSpace addSubview:mapIt];
    [mapIt constrainLeadingToAnchor:delete.trailingAnchor];
    [mapIt constrainTopToAnchor:topSpace.topAnchor];
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
    
    [topSpace addSubview:create];
    [create constrainTrailingToAnchor:topSpace.trailingAnchor];
    [create constrainTopToAnchor:topSpace.topAnchor];
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
    
    [topSpace addSubview:select];
    [select constrainTrailingToAnchor:create.leadingAnchor];
    [select constrainTopToAnchor:topSpace.topAnchor];
    [select constrainHeightToConstant:_rowHeight];
    [select constrainWidthToConstant:_rowHeight];
    
    UIButton *realtor = [UIButton buttonWithType:UIButtonTypeCustom];
    realtor.translatesAutoresizingMaskIntoConstraints = NO;
    realtor.backgroundColor = UIColor.clearColor;
    realtor.imageEdgeInsets = insets;
    
    [realtor setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteHouse"
                                                                                     ofType:@"png"]]
             forState:UIControlStateNormal];
    
    [realtor addTarget:self
                action:@selector(realtor:)
      forControlEvents:UIControlEventTouchUpInside];
    
    [topSpace addSubview:realtor];
    [realtor constrainTrailingToAnchor:select.leadingAnchor];
    [realtor constrainTopToAnchor:topSpace.topAnchor];
    [realtor constrainHeightToConstant:_rowHeight];
    [realtor constrainWidthToConstant:_rowHeight];
    
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
    
    [topSpace addSubview:_titleTextField];
    [_titleTextField constrainLeadingToAnchor:mapIt.trailingAnchor];
    [_titleTextField constrainTrailingToAnchor:realtor.leadingAnchor];
    [_titleTextField constrainTopToAnchor:topSpace.topAnchor];
    [_titleTextField constrainHeightToConstant:_rowHeight];
    
    _nvss = [[NVSpreadsheet alloc] initWithNumberOfHeaderRows:1
                                        numberOfHeaderColumns:1
                                                        frame:CGRectZero];
    
    _nvss.translatesAutoresizingMaskIntoConstraints = NO;
    _nvss.bounces = NO;
    
    [_nvss registerCellClass:NVGridCell.class
  forCellWithReuseIdentifier:@"GridCell"];
    
    [_nvss registerCellClass:NVTopRowCell.class
  forCellWithReuseIdentifier:@"TopRowCell"];
    
    [_nvss registerCellClass:NVLeftColumnCell.class
  forCellWithReuseIdentifier:@"LeftColumnCell"];
    
    _nvss.delegate = self;
    _nvss.dataSource = self;
    
    [self.view addSubview:_nvss];
    [_nvss constrainLeadingToAnchor:self.view.leadingAnchor];
    [_nvss constrainTrailingToAnchor:self.view.trailingAnchor];
    [_nvss constrainTopToAnchor:topSpace.bottomAnchor];
    [_nvss constrainBottomToAnchor:self.view.bottomAnchor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:NSBundle.mainBundle];
    
    UIViewController *fovc = [storyboard instantiateViewControllerWithIdentifier:@"FieldOptionsVC"];
    
    [NVTabBarEdit tabBarController:self.tabBarController
       replaceViewControllerWithID:@"FindVC"
                withViewController:fovc];
    
    UIViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DestinationsVC"];
    
    [NVTabBarEdit tabBarController:self.tabBarController
       replaceViewControllerWithID:@"ApplicationsVC"
                withViewController:dvc];
    
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

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_columnWidth, _rowHeight);
}

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    if (_flipped)
        return MAX(([_delegate numColumnsInSpreadsheet] + 1), 17);
    
    else
        return MAX(([_delegate numRowsInSpreadsheet] + 1), 17);
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    if (_flipped)
        return MAX(([_delegate numRowsInSpreadsheet] + 1), 17);
    
    else
        return MAX(([_delegate numColumnsInSpreadsheet] + 1), 17);
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
            [_returnToOrigin constrainCenterXToAnchor:gc.centerXAnchor constant:(_columnWidth * 0.25)];
            [_returnToOrigin constrainCenterYToAnchor:gc.centerYAnchor];
            [_returnToOrigin constrainWidthToConstant:(_columnWidth * 0.4)];
            [_returnToOrigin constrainHeightToConstant:(_rowHeight * 0.8)];
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
            [_swap constrainCenterXToAnchor:gc.centerXAnchor constant:(-_columnWidth * 0.25)];
            [_swap constrainCenterYToAnchor:gc.centerYAnchor];
            [_swap constrainWidthToConstant:(_columnWidth * 0.4)];
            [_swap constrainHeightToConstant:(_rowHeight * 0.8)];
        }
    }
    
    else if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn > 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"TopRowCell"
                                                          forIndexPath:indexPath];
        
        NVTopRowCell *tr = (NVTopRowCell *)cell;
        
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
    }
    
    return cell;
}

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.nvSpreadsheetColumn == 0)
    {
        
    }
    
    else
    {
        _selectedRow = indexPath.nvSpreadsheetRow;
        _selectedColumn = indexPath.nvSpreadsheetColumn;
        
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:@"Spreadsheet Options"
                                                   buttonTextArray:@[@"Map It", @"Cancel"]
                                                  destructiveIndex:0];
        alert.identifier = @"MapIt";
    }
}

- (void)swap:(UIButton *)button
{
    _flipped = !_flipped;
    [_nvss flipLongPressGesture:_flipped];
    [_nvss reloadData];
}

- (void)returnToOrigin:(UIButton *)button
{
    [_nvss returnToOrigin];
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

- (void)spreadsheetViewDidEditTopRowText:(NSString *)text
                                 atIndex:(NSInteger)index
{
    [_delegate spreadsheetDidEditColumnHeaderText:text
                                          atIndex:index];
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
    CRAPI.sharedInstance.mapPropList = button.selected;
}

- (void)create:(UIButton *)button
{
    [_delegate spreadsheetDidCreateList];
    _titleTextField.text = [_delegate titleTextForSpreadsheet];
    [_nvss reloadData];
}

- (void)select:(UIButton *)button
{
    int selectedFile = 0;
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
    [alertView hideLargeAlertView:YES];
    
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
            [_delegate spreadsheetDidMapItForRow:_selectedRow
                                          column:_selectedColumn
                                tabBarController:self.tabBarController];
        }
    }
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

@end
