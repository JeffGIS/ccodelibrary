//  NVSpreadsheetView.m
//  CCodeLibrary

#import "NVSpreadsheetView.h"
#import "SpreadSheetViewCell.h"
#import "UserDefaults.h"
#import "NVAlertView.h"
@import MessageUI;
#import "CRAPI.h"
#import "NVPopoverTableView.h"

@interface NVSpreadsheetView () <NVAlertViewDelegate,MFMailComposeViewControllerDelegate,NVDocumentManagerDelegate,NVPopoverTableViewDelegate>

@property (nonatomic) UIScrollView *contentView, *rowHeaderView, *columnHeaderView;
@property (nonatomic) NSDate *touchDown, *touchUp;
@property (nonatomic) NSArray *alphabet;
@property (nonatomic) CGFloat fontSize, borderWidth;
@property (nonatomic) UIView *rowHeaderOverlap, *columnHeaderOverlap;
@property (nonatomic) UIButton *returnToOrigin, *delete, *export, *create, *select, *mapIt, *swap;
@property (nonatomic) SpreadSheetViewCell *cellForEditing;
@property (nonatomic) UITextField *textField, *titleTextField;

@end

@implementation NVSpreadsheetView

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                       flipped:(BOOL)flipped
                                      delegate:(id)delegate
{
    NVSpreadsheetView *ssv = NVSpreadsheetView.new;
    ssv.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.backgroundColor = UIColor.grayColor;
    ssv.rows = rows;
    ssv.columns = columns;
    ssv.delegate = delegate;
    ssv.flipped = flipped;
    ssv.activeColumns = ssv.activeRows = 0;
    ssv.borderWidth = 1.5;
    
    ssv.textField = UITextField.new;
    ssv.textField.delegate = ssv;
    ssv.textField.layer.borderColor = UIColor.redColor.CGColor;
    ssv.textField.layer.borderWidth = 6.0;
    ssv.textField.textAlignment = NSTextAlignmentCenter;
    ssv.textField.clearButtonMode = UITextFieldViewModeAlways;
    ssv.textField.adjustsFontSizeToFitWidth = YES;
    
    CGFloat borderWidth = 1.5;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ssv.rowHeight = 36.0;
        ssv.columnWidth = 108.0;
        ssv.fontSize = 14.0;
    }
    
    else
    {
        ssv.rowHeight = 56.0;
        ssv.columnWidth = 216.0;
        ssv.fontSize = 19.0;
    }
    
    UIEdgeInsets insets = UIEdgeInsetsMake((ssv.rowHeight * 0.1), (ssv.rowHeight * 0.1),
                                           (ssv.rowHeight * 0.1), (ssv.rowHeight * 0.1));
    
    [view addSubview:ssv];
    
    [ssv constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    ssv.export = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.export.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.export.backgroundColor = UIColor.clearColor;
    ssv.export.imageEdgeInsets = insets;
    
    [ssv.export setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteUpload"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [ssv.export addTarget:ssv
                   action:@selector(export:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.export];
    
    [ssv.export.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor].active = YES;
    [ssv.export.topAnchor constraintEqualToAnchor:ssv.topAnchor].active = YES;
    [ssv.export.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [ssv.export.widthAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    
    ssv.delete = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.delete.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.delete.backgroundColor = UIColor.clearColor;
    ssv.delete.imageEdgeInsets = insets;
    
    [ssv.delete setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteTrashCan"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [ssv.delete addTarget:ssv
                   action:@selector(delete:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.delete];
    
    [ssv.delete.leadingAnchor constraintEqualToAnchor:ssv.export.trailingAnchor].active = YES;
    [ssv.delete.topAnchor constraintEqualToAnchor:ssv.topAnchor].active = YES;
    [ssv.delete.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [ssv.delete.widthAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    
    ssv.mapIt = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.mapIt.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.mapIt.backgroundColor = UIColor.clearColor;
    ssv.mapIt.selected = CRAPI.sharedInstance.mapPropList;
    ssv.mapIt.imageEdgeInsets = insets;
    
    [ssv.mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapItWithX"
                                                                                       ofType:@"png"]]
               forState:UIControlStateNormal];
    
    [ssv.mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapItWithX"
                                                                                       ofType:@"png"]]
               forState:UIControlStateNormal|UIControlStateHighlighted];
    
    [ssv.mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapIt"
                                                                                       ofType:@"png"]]
               forState:UIControlStateSelected];
    
    [ssv.mapIt setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteMapIt"
                                                                                       ofType:@"png"]]
               forState:UIControlStateSelected|UIControlStateHighlighted];
    
    [ssv.mapIt addTarget:ssv
                  action:@selector(toggleMapIt:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.mapIt];
    
    [ssv.mapIt.leadingAnchor constraintEqualToAnchor:ssv.delete.trailingAnchor].active = YES;
    [ssv.mapIt.topAnchor constraintEqualToAnchor:ssv.topAnchor].active = YES;
    [ssv.mapIt.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [ssv.mapIt.widthAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    
    ssv.create = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.create.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.create.backgroundColor = UIColor.clearColor;
    ssv.create.imageEdgeInsets = insets;
    
    [ssv.create setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whitePlus"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [ssv.create addTarget:ssv
                   action:@selector(create:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.create];
    
    [ssv.create.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor].active = YES;
    [ssv.create.topAnchor constraintEqualToAnchor:ssv.topAnchor].active = YES;
    [ssv.create.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [ssv.create.widthAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    
    ssv.select = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.select.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.select.backgroundColor = UIColor.clearColor;
    ssv.select.imageEdgeInsets = insets;
    
    [ssv.select setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteList"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [ssv.select addTarget:ssv
                   action:@selector(select:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.select];
    
    [ssv.select.trailingAnchor constraintEqualToAnchor:ssv.create.leadingAnchor].active = YES;
    [ssv.select.topAnchor constraintEqualToAnchor:ssv.topAnchor].active = YES;
    [ssv.select.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [ssv.select.widthAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    
    ssv.titleTextField = UITextField.new;
    ssv.titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.titleTextField.delegate = ssv;
    ssv.titleTextField.textAlignment = NSTextAlignmentCenter;
    ssv.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    ssv.titleTextField.font = [UIFont boldSystemFontOfSize:(ssv.fontSize * 1.5)];
    ssv.titleTextField.textColor = UIColor.whiteColor;
    ssv.titleTextField.adjustsFontSizeToFitWidth = YES;
    ssv.titleTextField.text = [delegate ssvGetTitleText];
    
    [ssv addSubview:ssv.titleTextField];
    
    [ssv.titleTextField.leadingAnchor constraintEqualToAnchor:ssv.mapIt.trailingAnchor].active = YES;
    [ssv.titleTextField.trailingAnchor constraintEqualToAnchor:ssv.select.leadingAnchor].active = YES;
    [ssv.titleTextField.topAnchor constraintEqualToAnchor:ssv.topAnchor].active = YES;
    [ssv.titleTextField.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    
    SpreadSheetViewCell *cell = SpreadSheetViewCell.new;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    cell.row = 0;
    cell.column = 0;
    cell.backgroundColor = UserDefaults.defaults.appleGray;
    cell.layer.borderWidth = borderWidth;
    
    [ssv addSubview:cell];
    
    [cell.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor constant:-borderWidth].active = YES;
    [cell.topAnchor constraintEqualToAnchor:ssv.topAnchor constant:ssv.rowHeight].active = YES;
    [cell.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [cell.widthAnchor constraintEqualToConstant:(ssv.columnWidth + borderWidth)].active = YES;
    
    ssv.returnToOrigin = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.returnToOrigin.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.returnToOrigin.backgroundColor = UIColor.whiteColor;
    ssv.returnToOrigin.imageEdgeInsets = insets;
    
    ssv.returnToOrigin.layer.cornerRadius = 4.0;
    ssv.returnToOrigin.layer.borderWidth = 1.0;
    ssv.returnToOrigin.layer.borderColor = UIColor.blackColor.CGColor;
    
    [ssv.returnToOrigin setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"diagonalArrow"
                                                                                                ofType:@"png"]]
                        forState:UIControlStateNormal];
    
    [ssv.returnToOrigin addTarget:ssv
                           action:@selector(returnToOrigin:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.returnToOrigin];
    
    [ssv.returnToOrigin.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor constant:(ssv.columnWidth * 0.25)].active = YES;
    [ssv.returnToOrigin.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor].active = YES;
    [ssv.returnToOrigin.widthAnchor constraintEqualToConstant:(ssv.columnWidth * 0.4)].active = YES;
    [ssv.returnToOrigin.heightAnchor constraintEqualToConstant:(ssv.rowHeight * 0.8)].active = YES;
    
    ssv.swap = [UIButton buttonWithType:UIButtonTypeCustom];
    ssv.swap.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.swap.backgroundColor = UIColor.whiteColor;
    
    ssv.swap.imageEdgeInsets = UIEdgeInsetsMake((-ssv.rowHeight * 0.1), (-ssv.rowHeight * 0.1),
                                                (-ssv.rowHeight * 0.1), (-ssv.rowHeight * 0.1));
    
    ssv.swap.layer.cornerRadius = 4.0;
    ssv.swap.layer.borderWidth = 1.0;
    ssv.swap.layer.borderColor = UIColor.blackColor.CGColor;
    
    [ssv.swap setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"swapIcon"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [ssv.swap setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"swapIconHighlighted"
                                                                                      ofType:@"png"]]
              forState:UIControlStateHighlighted];
    
    [ssv.swap addTarget:ssv
                 action:@selector(swap:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.swap];
    
    [ssv.swap.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor constant:(-ssv.columnWidth * 0.25)].active = YES;
    [ssv.swap.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor].active = YES;
    [ssv.swap.widthAnchor constraintEqualToConstant:(ssv.columnWidth * 0.4)].active = YES;
    [ssv.swap.heightAnchor constraintEqualToConstant:(ssv.rowHeight * 0.8)].active = YES;
    
    ssv.rowHeaderView = UIScrollView.new;
    ssv.rowHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.rowHeaderView.bounces = NO;
    ssv.rowHeaderView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.rowHeaderView.layer.borderWidth = borderWidth;
    ssv.rowHeaderView.delegate = ssv;
    
    [ssv addSubview:ssv.rowHeaderView];
    
    if (ssv.flipped)
    {
        ssv.rowHeaderView.contentSize = CGSizeMake((ssv.columnWidth * ssv.rows), ssv.rowHeight);
        [ssv.rowHeaderView.leadingAnchor constraintEqualToAnchor:cell.trailingAnchor].active = YES;
        [ssv.rowHeaderView.topAnchor constraintEqualToAnchor:ssv.titleTextField.bottomAnchor].active = YES;
        [ssv.rowHeaderView.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
        [ssv.rowHeaderView.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor constant:borderWidth].active = YES;
    }
    
    else
    {
        ssv.rowHeaderView.contentSize = CGSizeMake(ssv.columnWidth, (ssv.rowHeight * ssv.rows));
        [ssv.rowHeaderView.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor constant:-borderWidth].active = YES;
        [ssv.rowHeaderView.topAnchor constraintEqualToAnchor:cell.bottomAnchor].active = YES;
        [ssv.rowHeaderView.widthAnchor constraintEqualToConstant:(ssv.columnWidth + borderWidth)].active = YES;
        [ssv.rowHeaderView.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    }
    
    UITapGestureRecognizer *rowHeaderTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                   action:@selector(ssvTapped:)];
    
    [ssv.rowHeaderView addGestureRecognizer:rowHeaderTap];
    
    for (int r = 0; r < ssv.rows; r++)
    {
        CGRect cellFrame = CGRectZero;
        
        if (ssv.flipped)
            cellFrame = CGRectMake((r * ssv.columnWidth), 0.0, ssv.columnWidth, ssv.rowHeight);
        
        else
            cellFrame = CGRectMake(0.0, (r * ssv.rowHeight), (ssv.columnWidth + ssv.borderWidth), ssv.rowHeight);
        
        SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:cellFrame];
        
        cell.row = (NSUInteger)(r + 1);
        cell.column = 0;
        cell.font = [UIFont boldSystemFontOfSize:ssv.fontSize];
        cell.identifier = [NSString stringWithFormat:@"%i", (r + 1)];
        cell.text = cell.identifier;
        cell.backgroundColor = UserDefaults.defaults.appleGray;
        
        [ssv.rowHeaderView addSubview:cell];
    }
    
    ssv.alphabet = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                     @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    ssv.columnHeaderView = UIScrollView.new;
    ssv.columnHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.columnHeaderView.bounces = NO;
    ssv.columnHeaderView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.columnHeaderView.layer.borderWidth = borderWidth;
    ssv.columnHeaderView.delegate = ssv;
    
    [ssv addSubview:ssv.columnHeaderView];
    
    if (ssv.flipped)
    {
        ssv.columnHeaderView.contentSize = CGSizeMake(ssv.columnWidth, (ssv.rowHeight * ssv.columns));
        [ssv.columnHeaderView.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor constant:-borderWidth].active = YES;
        [ssv.columnHeaderView.topAnchor constraintEqualToAnchor:cell.bottomAnchor].active = YES;
        [ssv.columnHeaderView.widthAnchor constraintEqualToConstant:(ssv.columnWidth + borderWidth)].active = YES;
        [ssv.columnHeaderView.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    }
    
    else
    {
        ssv.columnHeaderView.contentSize = CGSizeMake((ssv.columnWidth * ssv.columns), ssv.rowHeight);
        [ssv.columnHeaderView.leadingAnchor constraintEqualToAnchor:cell.trailingAnchor].active = YES;
        [ssv.columnHeaderView.topAnchor constraintEqualToAnchor:ssv.titleTextField.bottomAnchor].active = YES;
        [ssv.columnHeaderView.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
        [ssv.columnHeaderView.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor constant:borderWidth].active = YES;
    }
    
    UITapGestureRecognizer *columnHeaderTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                      action:@selector(ssvTapped:)];
    
    [ssv.columnHeaderView addGestureRecognizer:columnHeaderTap];
    
    for (int c = 0; c < ssv.columns; c++)
    {
        CGRect cellFrame = CGRectZero;
        
        if (ssv.flipped)
            cellFrame = CGRectMake(0.0, (c * ssv.rowHeight), (ssv.columnWidth + ssv.borderWidth), ssv.rowHeight);
        
        else
            cellFrame = CGRectMake((c * ssv.columnWidth), 0.0, ssv.columnWidth, ssv.rowHeight);
        
        SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:cellFrame];
        
        cell.row = 0;
        cell.column = (NSUInteger)(c + 1);
        cell.font = [UIFont boldSystemFontOfSize:ssv.fontSize];
        cell.identifier = ssv.alphabet[c];
        cell.text = [NSString stringWithFormat:@"Property %@", cell.identifier];
        cell.backgroundColor = UserDefaults.defaults.appleGray;
        
        [ssv.columnHeaderView addSubview:cell];
    }
    
    ssv.contentView = UIScrollView.new;
    ssv.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.contentView.bounces = NO;
    ssv.contentView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.contentView.layer.borderWidth = borderWidth;
    ssv.contentView.delegate = ssv;
    
    [ssv addSubview:ssv.contentView];
    
    if (ssv.flipped)
    {
        ssv.contentView.contentSize = CGSizeMake((ssv.columnWidth * ssv.rows), (ssv.rowHeight * ssv.columns));
        [ssv.contentView.leadingAnchor constraintEqualToAnchor:ssv.columnHeaderView.trailingAnchor].active = YES;
        [ssv.contentView.topAnchor constraintEqualToAnchor:ssv.rowHeaderView.bottomAnchor].active = YES;
    }
    
    else
    {
        ssv.contentView.contentSize = CGSizeMake((ssv.columnWidth * ssv.columns), (ssv.rowHeight * ssv.rows));
        [ssv.contentView.leadingAnchor constraintEqualToAnchor:ssv.rowHeaderView.trailingAnchor].active = YES;
        [ssv.contentView.topAnchor constraintEqualToAnchor:ssv.columnHeaderView.bottomAnchor].active = YES;
    }
    
    [ssv.contentView.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    [ssv.contentView.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor constant:borderWidth].active = YES;
    
    UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                 action:@selector(ssvTapped:)];
    
    [ssv.contentView addGestureRecognizer:contentTap];
    
    UILongPressGestureRecognizer *headerLP = [[UILongPressGestureRecognizer alloc] initWithTarget:ssv
                                                                                           action:@selector(ssvLongPressed:)];
    [ssv.columnHeaderView addGestureRecognizer:headerLP];
    
    for (int r = 0; r < ssv.rows; r++)
    {
        for (int c = 0; c < ssv.columns; c++)
        {
            CGRect cellFrame = CGRectZero;
            
            if (ssv.flipped)
                cellFrame = CGRectMake((r * ssv.columnWidth), (c * ssv.rowHeight), ssv.columnWidth, ssv.rowHeight);
            
            else
                cellFrame = CGRectMake((c * ssv.columnWidth), (r * ssv.rowHeight), ssv.columnWidth, ssv.rowHeight);
            
            SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:cellFrame];
            
            cell.row = (NSUInteger)(r + 1);
            cell.column = (NSUInteger)(c + 1);
            cell.identifier = [NSString stringWithFormat:@"%@%lu", ssv.alphabet[c], (unsigned long)cell.row];
            cell.backgroundColor = UIColor.whiteColor;
            cell.font = [UIFont systemFontOfSize:ssv.fontSize];
            
            [ssv.contentView addSubview:cell];
        }
    }
    
    CGFloat headerOverlapWidth = 4.0;
    
    ssv.rowHeaderOverlap = UIView.new;
    ssv.rowHeaderOverlap.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.rowHeaderOverlap.backgroundColor = UIColor.yellowColor;
    ssv.rowHeaderOverlap.alpha = 0.5;
    ssv.rowHeaderOverlap.hidden = YES;
    
    [ssv addSubview:ssv.rowHeaderOverlap];
    
    [ssv.rowHeaderOverlap.leadingAnchor constraintEqualToAnchor:ssv.contentView.leadingAnchor constant:borderWidth].active = YES;
    [ssv.rowHeaderOverlap.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    [ssv.rowHeaderOverlap.widthAnchor constraintEqualToConstant:headerOverlapWidth].active = YES;
    
    if (ssv.flipped)
        [ssv.rowHeaderOverlap.topAnchor constraintEqualToAnchor:ssv.rowHeaderView.topAnchor].active = YES;
    
    else
        [ssv.rowHeaderOverlap.topAnchor constraintEqualToAnchor:ssv.columnHeaderView.topAnchor].active = YES;
    
    ssv.columnHeaderOverlap = UIView.new;
    ssv.columnHeaderOverlap.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.columnHeaderOverlap.backgroundColor = UIColor.yellowColor;
    ssv.columnHeaderOverlap.alpha = 0.5;
    ssv.columnHeaderOverlap.hidden = YES;
    
    [ssv addSubview:ssv.columnHeaderOverlap];
    
    [ssv.columnHeaderOverlap.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor].active = YES;
    [ssv.columnHeaderOverlap.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor].active = YES;
    [ssv.columnHeaderOverlap.topAnchor constraintEqualToAnchor:ssv.contentView.topAnchor constant:borderWidth].active = YES;
    [ssv.columnHeaderOverlap.heightAnchor constraintEqualToConstant:headerOverlapWidth].active = YES;
    
    return ssv;
}

- (void)setRowHeaderText:(NSArray *)rowHeaderText
{
    for (SpreadSheetViewCell *cells in _rowHeaderView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class] && cells.row <= rowHeaderText.count)
        {
            NSString *text = rowHeaderText[cells.row - 1];
            
            text = [text stringByReplacingOccurrencesOfString:@" ("
                                                   withString:@"\n("];
            
            cells.text = text;
        }
    }
}

- (void)setColumnHeaderText:(NSArray *)columnHeaderText
{
    for (SpreadSheetViewCell *cells in _columnHeaderView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class] && cells.column <= columnHeaderText.count)
            cells.text = columnHeaderText[cells.column - 1];
    }
}

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column
{
    for (SpreadSheetViewCell *cells in _columnHeaderView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class] && row == 1 && cells.column == column)
            cells.text = text;
    }
    
    for (SpreadSheetViewCell *cells in _contentView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class] && cells.row == (row - 1) && cells.column == column)
            cells.text = text;
    }
}

- (void)ssvTapped:(UITapGestureRecognizer *)gesture
{
    if (_textField.isFirstResponder)
    {
        [_textField resignFirstResponder];
        return;
    }
    
    else if (_titleTextField.isFirstResponder)
    {
        [_titleTextField resignFirstResponder];
        return;
    }
    
    CGPoint point = [gesture locationInView:gesture.view];
    NSString *selection = @"";
    NSUInteger xID = 0, yID = 0, actRows = 0, actColumns = 0;
    
    if (_flipped)
    {
        xID = (point.y / _rowHeight);
        yID = (point.x / _columnWidth);
        actRows = _activeColumns;
        actColumns = _activeRows;
    }
    
    else
    {
        xID = (point.x / _columnWidth);
        yID = (point.y / _rowHeight);
        actRows = _activeRows;
        actColumns = _activeColumns;
    }
    
    if (gesture.view == _contentView)
    {
        selection = [NSString stringWithFormat:@"%@%ld", _alphabet[xID], (long)(yID + 1)];
        
        for (SpreadSheetViewCell *cells in _contentView.subviews)
        {
            if ([cells isKindOfClass:SpreadSheetViewCell.class] &&
                [cells.identifier isEqualToString:selection] &&
                cells.column <= _activeColumns && cells.row <= _activeRows && _delegate)
            {
                [_delegate ssvCellWasTappedAtRowIndex:(yID + 1)
                                          columnIndex:(xID + 1)];
            }
        }
    }
    
    else if (gesture.view == _rowHeaderView)
    {
        selection = [NSString stringWithFormat:@"%ld", (long)(yID + 1)];
        
        for (SpreadSheetViewCell *cells in _rowHeaderView.subviews)
        {
            if ([cells isKindOfClass:SpreadSheetViewCell.class] &&
                [cells.identifier isEqualToString:selection])
            {
                NSLog(@"Row Header %@:\"%@\"", cells.identifier, cells.text);
            }
        }
    }
    
    else if (gesture.view == _columnHeaderView)
    {
        selection = [NSString stringWithFormat:@"%@", _alphabet[xID]];
        
        for (SpreadSheetViewCell *cells in _columnHeaderView.subviews)
        {
            if ([cells isKindOfClass:SpreadSheetViewCell.class] &&
                [cells.identifier isEqualToString:selection])
            {
                NSLog(@"Column Header %@:\"%@\"", cells.identifier, cells.text);
            }
        }
    }
}

- (void)ssvLongPressed:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    NSString *selection = @"";
    NSUInteger xID = 0, yID = 0, actRows = 0, actColumns = 0;
    
    if (_flipped)
    {
        xID = (point.y / _rowHeight);
        yID = (point.x / _columnWidth);
        actRows = _activeColumns;
        actColumns = _activeRows;
    }
    
    else
    {
        xID = (point.x / _columnWidth);
        yID = (point.y / _rowHeight);
        actRows = _activeRows;
        actColumns = _activeColumns;
    }
    
    if (gesture.view == _contentView)
    {
        selection = [NSString stringWithFormat:@"%@%i", _alphabet[xID], (yID + 1)];
        
        for (SpreadSheetViewCell *cells in _contentView.subviews)
        {
            if ([cells isKindOfClass:SpreadSheetViewCell.class] &&
                [cells.identifier isEqualToString:selection] && cells.column <= _activeColumns)
            {
                [self editCell:cells
                        inView:_contentView];
            }
        }
    }
    
    else if (gesture.view == _rowHeaderView)
    {
        selection = [NSString stringWithFormat:@"%i", (yID + 1)];
        
        for (SpreadSheetViewCell *cells in _rowHeaderView.subviews)
        {
            if ([cells isKindOfClass:SpreadSheetViewCell.class] &&
                [cells.identifier isEqualToString:selection] && cells.row <= _activeRows)
            {
                [self editCell:cells
                        inView:_rowHeaderView];
            }
        }
    }
    
    else if (gesture.view == _columnHeaderView)
    {
        selection = [NSString stringWithFormat:@"%@", _alphabet[xID]];
        
        for (SpreadSheetViewCell *cells in _columnHeaderView.subviews)
        {
            if ([cells isKindOfClass:SpreadSheetViewCell.class] &&
                [cells.identifier isEqualToString:selection] && cells.column <= _activeColumns)
            {
                [self editCell:cells
                        inView:_columnHeaderView];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    if (scrollView == _contentView)
    {
        if (_flipped)
        {
            _rowHeaderView.contentOffset = CGPointMake(offset.x, 0.0);
            _columnHeaderView.contentOffset = CGPointMake(0.0, offset.y);
        }
        
        else
        {
            _rowHeaderView.contentOffset = CGPointMake(0.0, offset.y);
            _columnHeaderView.contentOffset = CGPointMake(offset.x, 0.0);
        }
        
        _rowHeaderOverlap.hidden = (offset.x < 1.0);
        _columnHeaderOverlap.hidden = (offset.y < 1.0);
    }
    
    else if (scrollView == _rowHeaderView)
    {
        if (_flipped)
            _contentView.contentOffset = CGPointMake(offset.x, _contentView.contentOffset.y);
        
        else
            _contentView.contentOffset = CGPointMake(_contentView.contentOffset.x, offset.y);
    }
    
    else if (scrollView == _columnHeaderView)
    {
        if (_flipped)
            _contentView.contentOffset = CGPointMake(_contentView.contentOffset.x, offset.y);
        
        else
            _contentView.contentOffset = CGPointMake(offset.x, _contentView.contentOffset.y);
    }
}

- (void)returnToOrigin:(UIButton *)button
{
    [_rowHeaderView setContentOffset:_rowHeaderView.contentOffset
                            animated:NO];
    
    [_columnHeaderView setContentOffset:_columnHeaderView.contentOffset
                               animated:NO];
    
    [_contentView setContentOffset:CGPointMake(0.0, 0.0)
                          animated:YES];
}

- (void)swap:(UIButton *)button
{
    _flipped = !_flipped;
    
    if (_delegate && [_delegate respondsToSelector:@selector(ssvDidSetFlipped:)])
        [_delegate ssvDidSetFlipped:_flipped];
}

- (void)export:(UIButton *)button
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self
                                                      delegate:self
                                                         title:@"Select Export Method"
                                               buttonTextArray:@[@"Export as Email Attachment", @"Export to Cloud", @"Cancel"]
                                              destructiveIndex:0];
    alert.identifier = @"ExportPrompt";
}

- (void)delete:(UIButton *)button
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self
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
    if (_delegate && [_delegate respondsToSelector:@selector(ssvCreateWasTapped)])
    {
        [_delegate ssvCreateWasTapped];
        _titleTextField.text = [_delegate ssvGetTitleText];
    }
}

- (void)select:(UIButton *)button
{
    int selectedFile = 0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(ssvGetFileList)])
    {
        NSArray *fileList = [_delegate ssvGetFileList];
        
        if (fileList.count > 0 && [_delegate respondsToSelector:@selector(ssvSetCurrentFile:)])
        {
            NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self
                                                                              delegate:self
                                                                                 title:@"Select Spreadsheet"
                                                                             textArray:fileList
                                                                         includeCancel:YES];
#pragma unused(nvptv)
        }
    }
}

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
{
    [popoverTableView hide:YES];
    [_delegate ssvSetCurrentFile:text];
    _titleTextField.text = [_delegate ssvGetTitleText];
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
                    composer.subject = [NSString stringWithFormat:@"%@ from GMMobile", fileName];
                    
                    [composer setMessageBody:@"The tab-delimited text file attached to this email was created by GMMobile."
                                      isHTML:NO];
                    
                    [composer setToRecipients:[NSArray arrayWithObjects:@"jeffgis@aol.com", @"wildbillmunson@gmail.com", nil]];
                    
                    [composer addAttachmentData:[tabbedOutput dataUsingEncoding:NSUTF8StringEncoding]
                                       mimeType:@"text/plain"
                                       fileName:fileName];
                    
                    [self.parentViewController presentViewController:composer
                                                            animated:YES
                                                          completion:nil];
                }
                
                else
                {
                    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self
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
    
    if ([alertView.identifier isEqualToString:@"DeletePrompt"])
    {
        if (buttonIndex == 0)
        {
            [_delegate ssvDeleteCurrentFile];
            _titleTextField.text = [_delegate ssvGetTitleText];
        }
    }
    
    [alertView hideLargeAlertView:YES];
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
    
    [self.parentViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self
                                                      delegate:self
                                                         title:resultString
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (void)documentManagerDidCompleteWithMessage:(NSString *)message
                                     filepath:(NSString *)filepath
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self
                                                      delegate:self
                                                         title:message
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (NSString *)tabbedOutput
{
    NSMutableArray *rowHeaders = NSMutableArray.array;
    NSMutableArray *contents = NSMutableArray.array;
    NSMutableString *tabbedOutput = NSMutableString.string;
    
    for (SpreadSheetViewCell *cells in _rowHeaderView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class])
        {
            if (cells.row <= _activeRows)
            {
                NSString *text = @"";
                
                if (cells.text)
                {
                    text = [cells.text stringByReplacingOccurrencesOfString:@"\n"
                                                                 withString:@" "];
                }
                
                [rowHeaders addObject:text];
            }
        }
    }
    
    for (SpreadSheetViewCell *cells in _contentView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class])
        {
            if (cells.row <= _activeRows && cells.column <= _activeColumns)
            {
                NSString *text = @"";
                
                if (cells.text)
                {
                    text = [cells.text stringByReplacingOccurrencesOfString:@"\n"
                                                                 withString:@" "];
                }
                
                [contents addObject:text];
            }
        }
    }
    
    NSInteger index = 0;
    
    [tabbedOutput appendFormat:@"%@", rowHeaders[0]];
    
    for (int i = 0; i < _activeColumns; i++)
        [tabbedOutput appendFormat:@"\t%@", contents[index++]];
    
    for (int i = 1; i < rowHeaders.count; i++)
    {
        [tabbedOutput appendFormat:@"\n%@", rowHeaders[i]];
        
        for (int j = 0; j < _activeColumns; j++)
            [tabbedOutput appendFormat:@"\t%@", contents[index++]];
    }
    
    return tabbedOutput.copy;
}

- (NSString *)fileName
{
    NSString *fileName = @"Spreadsheet.txt";
    
    if (_titleTextField.text.length)
        fileName = [NSString stringWithFormat:@"%@.txt", _titleTextField.text];
    
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return fileName;
}

- (void)editCell:(SpreadSheetViewCell *)cell
          inView:(UIScrollView *)view
{
    _textField.text = cell.text;
    _textField.font = cell.font;
    _textField.frame = cell.frame;
    _textField.backgroundColor = cell.backgroundColor;
    [view addSubview:_textField];
    [_textField becomeFirstResponder];
    _cellForEditing = cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _titleTextField)
    {
        if (_delegate)
        {
            if ([_delegate respondsToSelector:@selector(ssvDidEditTitleText:)])
            {
                [_delegate ssvDidEditTitleText:textField.text];
                _titleTextField.text = [_delegate ssvGetTitleText];
            }
        }
    }
    else if (textField == _textField)
    {
        _cellForEditing.text = textField.text;
        [textField removeFromSuperview];
        
        if (_delegate)
        {
            if (_cellForEditing.superview == _columnHeaderView)
            {
                if ([_delegate respondsToSelector:@selector(ssvDidEditColumnHeaderText:atIndex:)])
                {
                    [_delegate ssvDidEditColumnHeaderText:textField.text
                                                  atIndex:_cellForEditing.column];
                }
            }
            
            else if (_cellForEditing.superview == _rowHeaderView)
            {
                if ([_delegate respondsToSelector:@selector(ssvDidEditRowHeaderText:atIndex:)])
                {
                    [_delegate ssvDidEditRowHeaderText:textField.text
                                               atIndex:_cellForEditing.row];
                }
            }
            
            else if (_cellForEditing.superview == _contentView)
            {
                if ([_delegate respondsToSelector:@selector(ssvDidEditText:forCellAtRow:column:)])
                {
                    [_delegate ssvDidEditText:textField.text
                                 forCellAtRow:_cellForEditing.row
                                       column:_cellForEditing.column];
                }
            }
        }
    }
}

- (void)clearContents
{
    for (SpreadSheetViewCell *cells in _contentView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class])
            cells.text = @"";
    }
    
    for (SpreadSheetViewCell *cells in _columnHeaderView.subviews)
    {
        if ([cells isKindOfClass:SpreadSheetViewCell.class])
            cells.text = cells.identifier;
    }
}

@end