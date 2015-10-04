//  NVSpreadsheetView.m
//  CCodeLibrary

#import "NVSpreadsheetView.h"
#import "SpreadSheetViewCell.h"
#import "UserDefaults.h"

@interface NVSpreadsheetView ()

@property (nonatomic) UIScrollView *contentView, *rowHeaderView, *columnHeaderView;
@property (nonatomic) NSDate *touchDown, *touchUp;
@property (nonatomic) NSArray *alphabet;
@property (nonatomic) CGFloat headerFontSize;
@property (nonatomic) UIView *rowHeaderOverlap, *columnHeaderOverlap;
@property (nonatomic) UIButton *returnToOrigin;
@property (nonatomic) SpreadSheetViewCell *cellForEditing;
@property (nonatomic) UITextField *textField;
@property BOOL inEditMode;

@end

@implementation NVSpreadsheetView

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                         frame:(CGRect)frame
                                      editable:(BOOL)editable
                                    selectable:(BOOL)selectable
                                      delegate:(id)delegate
{
    NVSpreadsheetView *ssv = [[NVSpreadsheetView alloc] initWithFrame:frame];
    ssv.backgroundColor = UserDefaults.defaults.appleGray;
    ssv.rows = rows;
    ssv.columns = columns;
    ssv.editable = editable;
    ssv.selectable = selectable;
    ssv.delegate = delegate;
    ssv.inEditMode = NO;
    
    ssv.textField = [[UITextField alloc] init];
    ssv.textField.delegate = ssv;
    ssv.textField.layer.borderColor = UIColor.redColor.CGColor;
    ssv.textField.layer.borderWidth = 6.0;
    ssv.textField.textAlignment = NSTextAlignmentCenter;
    ssv.textField.clearButtonMode = UITextFieldViewModeAlways;
    
    CGFloat rtobMargin = 0.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ssv.rowHeight = 27.0;
        ssv.columnWidth = 108.0;
        ssv.headerFontSize = 12.0;
        rtobMargin = 2.0;
    }
    
    else
    {
        ssv.rowHeight = 54.0;
        ssv.columnWidth = 216.0;
        ssv.headerFontSize = 24.0;
        rtobMargin = 5.0;
    }
    
    SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, ssv.columnWidth, ssv.rowHeight)];
    cell.row = 0;
    cell.column = 0;
    cell.backgroundColor = UserDefaults.defaults.appleGray;
    cell.layer.borderWidth = 1.5;
    
    [ssv addSubview:cell];
    
    ssv.returnToOrigin = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, (ssv.rowHeight + (rtobMargin * 6.0)),
                                                                    (ssv.rowHeight - (rtobMargin * 2.0)))];
    ssv.returnToOrigin.center = cell.center;
    ssv.returnToOrigin.backgroundColor = UIColor.whiteColor;
    
    ssv.returnToOrigin.imageEdgeInsets = UIEdgeInsetsMake(rtobMargin, (rtobMargin * 5.0),
                                                          rtobMargin, (rtobMargin * 5.0));
    
    ssv.returnToOrigin.layer.cornerRadius = 4.0;
    ssv.returnToOrigin.layer.borderWidth = 1.0;
    ssv.returnToOrigin.layer.borderColor = UIColor.darkGrayColor.CGColor;
    
    [ssv.returnToOrigin setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"diagonalArrow"
                                                                                                ofType:@"png"]]
                        forState:UIControlStateNormal];
    
    [ssv.returnToOrigin addTarget:ssv
                           action:@selector(returnToOrigin:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [ssv addSubview:ssv.returnToOrigin];
    
    ssv.rowHeaderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, ssv.rowHeight, ssv.columnWidth,
                                                                       (ssv.frame.size.height - ssv.rowHeight))];
    
    ssv.rowHeaderView.bounces = NO;
    ssv.rowHeaderView.contentSize = CGSizeMake(ssv.columnWidth, (ssv.rowHeight * ssv.rows));
    ssv.rowHeaderView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.rowHeaderView.layer.borderWidth = 1.5;
    ssv.rowHeaderView.delegate = ssv;
    
    UITapGestureRecognizer *rowHeaderTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                   action:@selector(ssvTapped:)];
    
    [ssv.rowHeaderView addGestureRecognizer:rowHeaderTap];
    
    for (int r = 0; r < ssv.rows; r++)
    {
        SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:CGRectMake(0.0, (r * ssv.rowHeight),
                                                                                          ssv.columnWidth, ssv.rowHeight)];
        
        cell.row = (NSUInteger)(r + 1);
        cell.column = 0;
        cell.font = [UIFont boldSystemFontOfSize:ssv.headerFontSize];
        cell.identifier = [NSString stringWithFormat:@"%i", (r + 1)];
        cell.text = cell.identifier;
        cell.backgroundColor = UserDefaults.defaults.appleGray;
        
        [ssv.rowHeaderView addSubview:cell];
    }
    
    [ssv addSubview:ssv.rowHeaderView];
    
    ssv.alphabet = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                     @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    ssv.columnHeaderView = [[UIScrollView alloc] initWithFrame:CGRectMake(ssv.columnWidth, 0.0,
                                                                          (ssv.frame.size.width - ssv.columnWidth),
                                                                          ssv.rowHeight)];
    
    ssv.columnHeaderView.bounces = NO;
    ssv.columnHeaderView.contentSize = CGSizeMake((ssv.columnWidth * ssv.columns), ssv.rowHeight);
    ssv.columnHeaderView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.columnHeaderView.layer.borderWidth = 1.5;
    ssv.columnHeaderView.delegate = ssv;
    
    UITapGestureRecognizer *columnHeaderTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                      action:@selector(ssvTapped:)];
    
    [ssv.columnHeaderView addGestureRecognizer:columnHeaderTap];
    
    UILongPressGestureRecognizer *columnHeaderLP = [[UILongPressGestureRecognizer alloc] initWithTarget:ssv
                                                                                                 action:@selector(ssvLongPressed:)];
    
    [ssv.columnHeaderView addGestureRecognizer:columnHeaderLP];
    
    for (int c = 0; c < ssv.columns; c++)
    {
        SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:CGRectMake((c * ssv.columnWidth), 0.0,
                                                                                          ssv.columnWidth, ssv.rowHeight)];
        
        cell.row = 0;
        cell.column = (NSUInteger)(c + 1);
        cell.font = [UIFont boldSystemFontOfSize:ssv.headerFontSize];
        cell.identifier = ssv.alphabet[c];
        cell.text = cell.identifier;
        cell.backgroundColor = UserDefaults.defaults.appleGray;
        
        [ssv.columnHeaderView addSubview:cell];
    }
    
    [ssv addSubview:ssv.columnHeaderView];
    
    ssv.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(ssv.columnWidth, ssv.rowHeight,
                                                                     (ssv.frame.size.width - ssv.columnWidth),
                                                                     ssv.frame.size.height - ssv.rowHeight)];
    
    ssv.contentView.bounces = NO;
    ssv.contentView.contentSize = CGSizeMake((ssv.columnWidth * ssv.columns), (ssv.rowHeight * ssv.rows));
    ssv.contentView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.contentView.layer.borderWidth = 1.5;
    ssv.contentView.delegate = ssv;
    
    UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                 action:@selector(ssvTapped:)];
    
    [ssv.contentView addGestureRecognizer:contentTap];
    
    for (int r = 0; r < ssv.rows; r++)
    {
        for (int c = 0; c < ssv.columns; c++)
        {
            SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:CGRectMake((c * ssv.columnWidth), (r * ssv.rowHeight),
                                                                                              ssv.columnWidth, ssv.rowHeight)];
            
            cell.row = (NSUInteger)(r + 1);
            cell.column = (NSUInteger)(c + 1);
            cell.identifier = [NSString stringWithFormat:@"%@%lu", ssv.alphabet[c], (unsigned long)cell.row];
            cell.backgroundColor = UIColor.whiteColor;
            
            [ssv.contentView addSubview:cell];
        }
    }
    
    [ssv addSubview:ssv.contentView];
    
    ssv.rowHeaderOverlap = [[UIView alloc] initWithFrame:CGRectMake((ssv.contentView.frame.origin.x + ssv.contentView.layer.borderWidth),
                                                                    ssv.rowHeaderView.layer.borderWidth, 4.0,
                                                                    ssv.frame.size.height - (ssv.contentView.layer.borderWidth * 2.0))];
    
    ssv.rowHeaderOverlap.backgroundColor = UIColor.yellowColor;
    ssv.rowHeaderOverlap.alpha = 0.5;
    ssv.rowHeaderOverlap.hidden = YES;
    [ssv addSubview:ssv.rowHeaderOverlap];
    
    ssv.columnHeaderOverlap = [[UIView alloc] initWithFrame:CGRectMake(ssv.columnHeaderView.layer.borderWidth,
                                                                       (ssv.contentView.frame.origin.y + ssv.contentView.layer.borderWidth),
                                                                       ssv.frame.size.width - (ssv.contentView.layer.borderWidth * 2.0), 4.0)];
    
    ssv.columnHeaderOverlap.backgroundColor = UIColor.yellowColor;
    ssv.columnHeaderOverlap.alpha = 0.5;
    ssv.columnHeaderOverlap.hidden = YES;
    [ssv addSubview:ssv.columnHeaderOverlap];
    
    [view addSubview:ssv];
    
    return ssv;
}

- (void)setRowHeaderText:(NSArray *)rowHeaderText
{
    for (SpreadSheetViewCell *cell in _rowHeaderView.subviews)
    {
        if ([cell isKindOfClass:SpreadSheetViewCell.class] && cell.row <= rowHeaderText.count)
        {
            NSString *text = rowHeaderText[cell.row - 1];
            
            text = [text stringByReplacingOccurrencesOfString:@" ("
                                                   withString:@"\n("];
            
            cell.text = text;
        }
    }
}

- (void)setColumnHeaderText:(NSArray *)columnHeaderText
{
    for (SpreadSheetViewCell *cell in _columnHeaderView.subviews)
    {
        if ([cell isKindOfClass:SpreadSheetViewCell.class] && cell.column <= columnHeaderText.count)
            cell.text = columnHeaderText[cell.column - 1];
    }
}

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column
{
    for (SpreadSheetViewCell *cell in _contentView.subviews)
    {
        if ([cell isKindOfClass:SpreadSheetViewCell.class] && cell.row == row && cell.column == column)
            cell.text = text;
    }
}

- (void)ssvTapped:(UITapGestureRecognizer *)gesture
{
    if ([_columnHeaderView.subviews containsObject:_textField] ||
        [_rowHeaderView.subviews containsObject:_textField] ||
        [_contentView.subviews containsObject:_textField])
    {
        [_textField resignFirstResponder];
        return;
    }
    
    CGPoint point = [gesture locationInView:gesture.view];
    NSString *selection = @"";
    
    int xID = (point.x / _columnWidth);
    int yID = (point.y / _rowHeight);
    
    if (gesture.view == _contentView)
    {
        selection = [NSString stringWithFormat:@"%@%i", _alphabet[xID], (yID + 1)];
        
        for (SpreadSheetViewCell *cell in _contentView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection])
            {
                NSLog(@"Cell %@:\"%@\"", cell.identifier, cell.text);
            }
        }
    }
    
    else if (gesture.view == _rowHeaderView)
    {
        selection = [NSString stringWithFormat:@"%i", (yID + 1)];
        
        for (SpreadSheetViewCell *cell in _rowHeaderView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection])
            {
                NSLog(@"Row Header %@:\"%@\"", cell.identifier, cell.text);
            }
        }
    }
    
    else if (gesture.view == _columnHeaderView)
    {
        selection = [NSString stringWithFormat:@"%@", _alphabet[xID]];
        
        for (SpreadSheetViewCell *cell in _columnHeaderView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection])
            {
                NSLog(@"Column Header %@:\"%@\"", cell.identifier, cell.text);
            }
        }
    }
}

- (void)ssvLongPressed:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    NSString *selection = @"";
    
    int xID = (point.x / _columnWidth);
    int yID = (point.y / _rowHeight);
    
    if (gesture.view == _contentView)
    {
        selection = [NSString stringWithFormat:@"%@%i", _alphabet[xID], (yID + 1)];
        
        for (SpreadSheetViewCell *cell in _contentView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection])
            {
                [self editCell:cell
                        inView:_contentView];
            }
        }
    }
    
    else if (gesture.view == _rowHeaderView)
    {
        selection = [NSString stringWithFormat:@"%i", (yID + 1)];
        
        for (SpreadSheetViewCell *cell in _rowHeaderView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection])
            {
                [self editCell:cell
                        inView:_rowHeaderView];
            }
        }
    }
    
    else if (gesture.view == _columnHeaderView)
    {
        selection = [NSString stringWithFormat:@"%@", _alphabet[xID]];
        
        for (SpreadSheetViewCell *cell in _columnHeaderView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection])
            {
                [self editCell:cell
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
        _rowHeaderView.contentOffset = CGPointMake(0.0, offset.y);
        _columnHeaderView.contentOffset = CGPointMake(offset.x, 0.0);
        
        _rowHeaderOverlap.hidden = (offset.x < 1.0);
        _columnHeaderOverlap.hidden = (offset.y < 1.0);
    }
    
    else if (scrollView == _rowHeaderView)
        _contentView.contentOffset = CGPointMake(_contentView.contentOffset.x, offset.y);
    
    else if (scrollView == _columnHeaderView)
        _contentView.contentOffset = CGPointMake(offset.x, _contentView.contentOffset.y);
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight
{
    CGPoint origin = self.frame.origin;
    CGRect superviewFrame = self.superview.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.frame = CGRectMake(origin.x, origin.y,
                                                 ((superviewFrame.size.height + tabBarHeight) - origin.x),
                                                 ((superviewFrame.size.width - tabBarHeight) - origin.y));
                         
                         _rowHeaderView.frame = CGRectMake(_rowHeaderView.frame.origin.x,
                                                           _rowHeaderView.frame.origin.y,
                                                           _columnWidth, (self.frame.size.height - _rowHeight));
                         
                         _columnHeaderView.frame = CGRectMake(_columnHeaderView.frame.origin.x,
                                                              _columnHeaderView.frame.origin.y,
                                                              (self.frame.size.width - _columnWidth), _rowHeight);
                         
                         _contentView.frame = CGRectMake(_contentView.frame.origin.x,
                                                         _contentView.frame.origin.y,
                                                         (self.frame.size.width - _columnWidth),
                                                         (self.frame.size.height - _rowHeight));
                     }];
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
    _cellForEditing.text = _textField.text;
    [_textField removeFromSuperview];
    
    if (_cellForEditing.superview == _columnHeaderView && _delegate)
        [_delegate ssvDidEditColumnHeaderAtIndex:(_cellForEditing.column - 1)];
}

@end