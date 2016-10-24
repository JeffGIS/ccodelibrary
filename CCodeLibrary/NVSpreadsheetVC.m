//  NVSpreadsheetVC.m
//  CCodeLibrary

#import "NVSpreadsheetVC.h"
#import "NVSpreadsheet.h"
#import "NVSpreadsheetCell.h"
#import "NSIndexPath+NVSpreadsheet.h"

@interface NVSpreadsheetVC () <NVSpreadsheetDataSource, NVSpreadsheetDelegate>

@property (nonatomic) NVSpreadsheet *nvss;
@property (nonatomic) UIButton *swap, *returnToOrigin;
@property (nonatomic) CGFloat columnWidth, rowHeight;

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
    
    self.view.backgroundColor = UIColor.darkGrayColor;
    _flipped = NO;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _rowHeight = 36.0;
        _columnWidth = 108.0;
    }
    
    else
    {
        _rowHeight = 56.0;
        _columnWidth = 216.0;
    }
    
    UIView *topSpace = UIView.new;
    topSpace.translatesAutoresizingMaskIntoConstraints = NO;
    topSpace.backgroundColor = UIColor.clearColor;
    
    [self.view addSubview:topSpace];
    [topSpace constrainTopToAnchor:self.view.topAnchor];
    [topSpace constrainLeadingToAnchor:self.view.leadingAnchor];
    [topSpace constrainTrailingToAnchor:self.view.trailingAnchor];
    [topSpace constrainHeightToConstant:60.0];
    
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

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_columnWidth, _rowHeight);
}

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    if (_flipped)
        return ([_delegate numColumnsInSpreadsheet] + 1);
    
    else
        return ([_delegate numRowsInSpreadsheet] + 1);
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    if (_flipped)
        return ([_delegate numRowsInSpreadsheet] + 1);
    
    else
        return ([_delegate numColumnsInSpreadsheet] + 1);
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
        
        UIEdgeInsets insets = UIEdgeInsetsMake((_rowHeight * 0.1), (_rowHeight * 0.1),
                                               (_rowHeight * 0.1), (_rowHeight * 0.1));
        
        _returnToOrigin = [UIButton buttonWithType:UIButtonTypeCustom];
        _returnToOrigin.translatesAutoresizingMaskIntoConstraints = NO;
        _returnToOrigin.backgroundColor = UIColor.whiteColor;
        _returnToOrigin.imageEdgeInsets = insets;
        
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
    
}

- (void)swap:(UIButton *)button
{
    _flipped = !_flipped;
    [_nvss reloadData];
}

- (void)returnToOrigin:(UIButton *)button
{
    [_nvss returnToOrigin];
}

@end
