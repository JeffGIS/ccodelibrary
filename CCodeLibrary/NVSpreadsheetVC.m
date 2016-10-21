//  NVSpreadsheetVC.m
//  CCodeLibrary

#import "NVSpreadsheetVC.h"
#import "NVSpreadsheet.h"
#import "NVSpreadsheetCell.h"
#import "NSIndexPath+NVSpreadsheet.h"

@interface NVSpreadsheetVC () <NVSpreadsheetDataSource, NVSpreadsheetDelegate>

@property (nonatomic) UIButton *returnButton;
@property (nonatomic) NSMutableSet *selectedGridCells;
@property (nonatomic) NSMutableArray *tableData;
@property (nonatomic) NSString *cellDataBuffer;
@property (nonatomic) NVSpreadsheet *nvss;

@end

@implementation NVSpreadsheetVC

+ (instancetype)presentSpreadsheetInViewController:(UIViewController *)viewController
                                           numRows:(NSUInteger)numRows
                                        numColumns:(NSUInteger)numColumns
                                          delegate:(id)delegate
{
    NVSpreadsheetVC *nvsvc = NVSpreadsheetVC.new;
    nvsvc.rows = numRows;
    nvsvc.columns = numColumns;
    nvsvc.delegate = delegate;
    
    [viewController presentViewController:nvsvc
                                 animated:YES
                               completion:nil];
    
    return nvsvc;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.darkGrayColor;
    
    UIView *topSpace = UIView.new;
    topSpace.translatesAutoresizingMaskIntoConstraints = NO;
    topSpace.backgroundColor = UIColor.clearColor;
    
    [self.view addSubview:topSpace];
    [topSpace constrainTopToAnchor:self.view.topAnchor];
    [topSpace constrainLeadingToAnchor:self.view.leadingAnchor];
    [topSpace constrainTrailingToAnchor:self.view.trailingAnchor];
    [topSpace constrainHeightToConstant:50.0];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    _returnButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.lightGrayColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [topSpace addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:topSpace.leadingAnchor];
    [_returnButton constrainTopToAnchor:topSpace.topAnchor];
    [_returnButton constrainBottomToAnchor:topSpace.bottomAnchor];
    
    _tableData = NSMutableArray.array;
    
    for (NSUInteger rowNumber = 0; rowNumber < (_rows + 1); rowNumber++)
    {
        NSMutableArray *row = NSMutableArray.array;
        
        for (NSUInteger columnNumber = 0; columnNumber < (_columns + 1); columnNumber++)
            [row addObject:[NSString stringWithFormat:@"R%i:C%i", rowNumber, columnNumber]];
        
        [_tableData addObject:row];
    }
    
    _selectedGridCells = NSMutableSet.set;
    
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

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat leftColumnWidth = 150.0, topRowHeight = 50.0;
    CGFloat gridCellWidth = 150.0, gridCellHeight = 50.0;
    
    if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn == 0)
        return CGSizeMake(leftColumnWidth, topRowHeight);
    
    if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn > 0)
        return CGSizeMake(gridCellWidth, topRowHeight);

    if (indexPath.nvSpreadsheetRow > 0 && indexPath.nvSpreadsheetColumn == 0)
        return CGSizeMake(leftColumnWidth, gridCellHeight);
    
    return CGSizeMake(gridCellWidth, gridCellHeight);
}

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    NSInteger rows = _tableData.count;
    return rows;
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    NSArray *rowData = _tableData.lastObject;
    NSInteger cols = rowData.count;
    return cols;
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
        gc.textLabel.numberOfLines = 0;
        cell.backgroundColor = UIColor.lightGrayColor;
    }
    
    else if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn > 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"TopRowCell"
                                                          forIndexPath:indexPath];
        NVTopRowCell *tr = (NVTopRowCell *)cell;
        tr.textLabel.text = [NSString stringWithFormat:@"Row %i", indexPath.nvSpreadsheetColumn];
        cell.backgroundColor = UIColor.whiteColor;
    }
    
    else if (indexPath.nvSpreadsheetRow > 0 && indexPath.nvSpreadsheetColumn == 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"LeftColumnCell"
                                                          forIndexPath:indexPath];
        NVLeftColumnCell *lc = (NVLeftColumnCell *)cell;
        lc.textLabel.text = [NSString stringWithFormat:@"Col %i", indexPath.nvSpreadsheetRow];
        
        if (indexPath.nvSpreadsheetRow % 2 == 0)
        {
            cell.backgroundColor = [UIColor colorWithRed:(222.0 / 255.0)
                                                   green:(243.0 / 255.0)
                                                    blue:(250.0 / 255.0)
                                                   alpha:1.0];
        }
        
        else
        {
            cell.backgroundColor = [UIColor colorWithRed:(233.0 / 255.0)
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
        NSArray *colData = [_tableData objectAtIndex:indexPath.nvSpreadsheetRow];
        NSString *rowData = [colData objectAtIndex:indexPath.nvSpreadsheetColumn];
        gc.textLabel.text = rowData;
        
        if (indexPath.nvSpreadsheetRow % 2 == 0)
        {
            cell.backgroundColor = [UIColor colorWithRed:(242.0 / 255.0)
                                                   green:(242.0 / 255.0)
                                                    blue:(242.0 / 255.0)
                                                   alpha:1.0];
        }
        
        else
        {
            cell.backgroundColor = [UIColor colorWithRed:(250.0 / 255.0)
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
    if ([_selectedGridCells containsObject:indexPath])
    {
        [_selectedGridCells removeObject:indexPath];
        
        [spreadsheetView deselectItemAtIndexPath:indexPath
                                        animated:YES];
    }
    
    else
    {
        [_selectedGridCells removeAllObjects];
        [_selectedGridCells addObject:indexPath];
    }
}

- (BOOL)spreadsheetView:(NVSpreadsheet *)spreadsheetView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)spreadsheetView:(NVSpreadsheet *)spreadsheetView
       canPerformAction:(SEL)action
     forItemAtIndexPath:(NSIndexPath *)indexPath
             withSender:(id)sender
{
    if (action == @selector(cut:) || action == @selector(copy:) || action == @selector(paste:))
        return YES;
    
    return NO;
}

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
          performAction:(SEL)action
     forItemAtIndexPath:(NSIndexPath *)indexPath
             withSender:(id)sender
{
    NSMutableArray *rowData = [_tableData objectAtIndex:indexPath.nvSpreadsheetRow];
    
    if (action == @selector(cut:))
    {
        _cellDataBuffer = [rowData objectAtIndex:indexPath.row];
        
        [rowData replaceObjectAtIndex:indexPath.row
                           withObject:@""];
        
        [spreadsheetView reloadData];
        
    }
    
    else if (action == @selector(copy:))
        _cellDataBuffer = [rowData objectAtIndex:indexPath.row];
    
    else if (action == @selector(paste:))
    {
        if (_cellDataBuffer)
        {
            [rowData replaceObjectAtIndex:indexPath.row
                               withObject:_cellDataBuffer];
            
            [spreadsheetView reloadData];
        }
    }
}

@end
