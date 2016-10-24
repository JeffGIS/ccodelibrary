//  NVSpreadsheetVC.m
//  CCodeLibrary

#import "NVSpreadsheetVC.h"
#import "NVSpreadsheet.h"
#import "NVSpreadsheetCell.h"
#import "NSIndexPath+NVSpreadsheet.h"

@interface NVSpreadsheetVC () <NVSpreadsheetDataSource, NVSpreadsheetDelegate>

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
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.backgroundColor = UIColor.clearColor;
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    returnButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    
    [returnButton setTitle:@"< Return"
                  forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.lightGrayColor
                       forState:UIControlStateHighlighted];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [topSpace addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:topSpace.leadingAnchor];
    [returnButton constrainTopToAnchor:topSpace.topAnchor];
    [returnButton constrainBottomToAnchor:topSpace.bottomAnchor];
    
    NVSpreadsheet *nvss = [[NVSpreadsheet alloc] initWithNumberOfHeaderRows:1
                                                      numberOfHeaderColumns:1
                                                                      frame:CGRectZero];
    
    nvss.translatesAutoresizingMaskIntoConstraints = NO;
    nvss.bounces = NO;
    
    [nvss registerCellClass:NVGridCell.class
 forCellWithReuseIdentifier:@"GridCell"];
    
    [nvss registerCellClass:NVTopRowCell.class
 forCellWithReuseIdentifier:@"TopRowCell"];
    
    [nvss registerCellClass:NVLeftColumnCell.class
 forCellWithReuseIdentifier:@"LeftColumnCell"];
    
    nvss.delegate = self;
    nvss.dataSource = self;
    
    [self.view addSubview:nvss];
    [nvss constrainLeadingToAnchor:self.view.leadingAnchor];
    [nvss constrainTrailingToAnchor:self.view.trailingAnchor];
    [nvss constrainTopToAnchor:topSpace.bottomAnchor];
    [nvss constrainBottomToAnchor:self.view.bottomAnchor];
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
    return CGSizeMake(216.0, 56.0);
}

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    return (_rows + 1);
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView
{
    return (_columns + 1);
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
        cell.userInteractionEnabled = NO;
    }
    
    else if (indexPath.nvSpreadsheetRow == 0 && indexPath.nvSpreadsheetColumn > 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"TopRowCell"
                                                          forIndexPath:indexPath];
        NVTopRowCell *tr = (NVTopRowCell *)cell;
        tr.textLabel.text = [_delegate headerTextForColumn:indexPath.nvSpreadsheetColumn];
        cell.backgroundColor = UIColor.whiteColor;
    }
    
    else if (indexPath.nvSpreadsheetRow > 0 && indexPath.nvSpreadsheetColumn == 0)
    {
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"LeftColumnCell"
                                                          forIndexPath:indexPath];
        NVLeftColumnCell *lc = (NVLeftColumnCell *)cell;
        lc.textLabel.text = [_delegate headerTextForRow:indexPath.nvSpreadsheetRow];
        lc.textLabel.numberOfLines = 2;
        lc.textLabel.adjustsFontSizeToFitWidth = YES;
        
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

        gc.textLabel.text = [_delegate textForColumn:indexPath.nvSpreadsheetColumn
                                                 row:indexPath.nvSpreadsheetRow];
        
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
    
}

@end
