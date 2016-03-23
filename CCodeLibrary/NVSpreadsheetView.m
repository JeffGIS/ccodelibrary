//  NVSpreadsheetView.m
//  CCodeLibrary

#import "NVSpreadsheetView.h"
#import "SpreadSheetViewCell.h"
#import "UserDefaults.h"

@interface NVSpreadsheetView ()

@property (nonatomic) UIScrollView *contentView, *rowHeaderView, *columnHeaderView;
@property (nonatomic) NSDate *touchDown, *touchUp;
@property (nonatomic) NSArray *alphabet;
@property (nonatomic) CGFloat headerFontSize, borderWidth;
@property (nonatomic) UIView *rowHeaderOverlap, *columnHeaderOverlap;
@property (nonatomic) UIButton *returnToOrigin;
@property (nonatomic) SpreadSheetViewCell *cellForEditing;
@property (nonatomic) UITextField *textField, *titleTextField;
@property BOOL inEditMode;

@end

@implementation NVSpreadsheetView

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                      editable:(BOOL)editable
                                    selectable:(BOOL)selectable
                                      delegate:(id)delegate
{
    NVSpreadsheetView *ssv = NVSpreadsheetView.new;
    ssv.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.backgroundColor = UIColor.grayColor;
    ssv.rows = rows;
    ssv.columns = columns;
    ssv.editable = editable;
    ssv.selectable = selectable;
    ssv.delegate = delegate;
    ssv.inEditMode = NO;
    ssv.activeColumns = ssv.activeRows = 0;
    ssv.borderWidth = 1.5;
    
    ssv.textField = [[UITextField alloc] init];
    ssv.textField.delegate = ssv;
    ssv.textField.layer.borderColor = UIColor.redColor.CGColor;
    ssv.textField.layer.borderWidth = 6.0;
    ssv.textField.textAlignment = NSTextAlignmentCenter;
    ssv.textField.clearButtonMode = UITextFieldViewModeAlways;
    
    CGFloat borderWidth = 1.5;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ssv.rowHeight = 28.0;
        ssv.columnWidth = 108.0;
        ssv.headerFontSize = 12.0;
    }
    
    else
    {
        ssv.rowHeight = 48.0;
        ssv.columnWidth = 216.0;
        ssv.headerFontSize = 24.0;
    }
    
    [view addSubview:ssv];
    
    [ssv constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    ssv.titleTextField = UITextField.new;
    ssv.titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.titleTextField.delegate = ssv;
    ssv.titleTextField.textAlignment = NSTextAlignmentCenter;
    ssv.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    ssv.titleTextField.placeholder = @"Tap to Enter Title Here";
    ssv.titleTextField.font = [UIFont boldSystemFontOfSize:(ssv.headerFontSize * 1.5)];
    ssv.titleTextField.textColor = UIColor.whiteColor;
    
    [ssv addSubview:ssv.titleTextField];
    
    [ssv.titleTextField.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor].active = YES;
    [ssv.titleTextField.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor].active = YES;
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
    
    ssv.returnToOrigin.imageEdgeInsets = UIEdgeInsetsMake((ssv.rowHeight * 0.1), (ssv.columnWidth * 0.1),
                                                          (ssv.rowHeight * 0.1), (ssv.columnWidth * 0.1));
    
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
    
    [ssv.returnToOrigin.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor].active = YES;
    [ssv.returnToOrigin.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor].active = YES;
    [ssv.returnToOrigin.widthAnchor constraintEqualToConstant:(ssv.columnWidth * 0.4)].active = YES;
    [ssv.returnToOrigin.heightAnchor constraintEqualToConstant:(ssv.rowHeight * 0.8)].active = YES;
    
    ssv.rowHeaderView = UIScrollView.new;
    ssv.rowHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.rowHeaderView.bounces = NO;
    ssv.rowHeaderView.contentSize = CGSizeMake(ssv.columnWidth, (ssv.rowHeight * ssv.rows));
    ssv.rowHeaderView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.rowHeaderView.layer.borderWidth = borderWidth;
    ssv.rowHeaderView.delegate = ssv;
    
    [ssv addSubview:ssv.rowHeaderView];
    
    [ssv.rowHeaderView.leadingAnchor constraintEqualToAnchor:ssv.leadingAnchor constant:-borderWidth].active = YES;
    [ssv.rowHeaderView.topAnchor constraintEqualToAnchor:cell.bottomAnchor].active = YES;
    [ssv.rowHeaderView.widthAnchor constraintEqualToConstant:(ssv.columnWidth + borderWidth)].active = YES;
    [ssv.rowHeaderView.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    
    UITapGestureRecognizer *rowHeaderTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                   action:@selector(ssvTapped:)];
    
    [ssv.rowHeaderView addGestureRecognizer:rowHeaderTap];
    
    for (int r = 0; r < ssv.rows; r++)
    {
        SpreadSheetViewCell *cell = [[SpreadSheetViewCell alloc] initWithFrame:CGRectMake(0.0, (r * ssv.rowHeight),
                                                                                          (ssv.columnWidth + ssv.borderWidth),
                                                                                          ssv.rowHeight)];
        
        cell.row = (NSUInteger)(r + 1);
        cell.column = 0;
        cell.font = [UIFont boldSystemFontOfSize:ssv.headerFontSize];
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
    ssv.columnHeaderView.contentSize = CGSizeMake((ssv.columnWidth * ssv.columns), ssv.rowHeight);
    ssv.columnHeaderView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.columnHeaderView.layer.borderWidth = borderWidth;
    ssv.columnHeaderView.delegate = ssv;
    
    [ssv addSubview:ssv.columnHeaderView];
    
    [ssv.columnHeaderView.leadingAnchor constraintEqualToAnchor:cell.trailingAnchor].active = YES;
    [ssv.columnHeaderView.topAnchor constraintEqualToAnchor:ssv.titleTextField.bottomAnchor].active = YES;
    [ssv.columnHeaderView.heightAnchor constraintEqualToConstant:ssv.rowHeight].active = YES;
    [ssv.columnHeaderView.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor constant:borderWidth].active = YES;
    
    UITapGestureRecognizer *columnHeaderTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                      action:@selector(ssvTapped:)];
    
    [ssv.columnHeaderView addGestureRecognizer:columnHeaderTap];
    
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
    
    ssv.contentView = UIScrollView.new;
    ssv.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.contentView.bounces = NO;
    ssv.contentView.contentSize = CGSizeMake((ssv.columnWidth * ssv.columns), (ssv.rowHeight * ssv.rows));
    ssv.contentView.layer.borderColor = UIColor.blackColor.CGColor;
    ssv.contentView.layer.borderWidth = borderWidth;
    ssv.contentView.delegate = ssv;
    
    [ssv addSubview:ssv.contentView];
    
    [ssv.contentView.leadingAnchor constraintEqualToAnchor:ssv.rowHeaderView.trailingAnchor].active = YES;
    [ssv.contentView.topAnchor constraintEqualToAnchor:ssv.columnHeaderView.bottomAnchor].active = YES;
    [ssv.contentView.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    [ssv.contentView.trailingAnchor constraintEqualToAnchor:ssv.trailingAnchor constant:borderWidth].active = YES;
    
    UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget:ssv
                                                                                 action:@selector(ssvTapped:)];
    
    [ssv.contentView addGestureRecognizer:contentTap];
    
    UILongPressGestureRecognizer *contentLP = [[UILongPressGestureRecognizer alloc] initWithTarget:ssv
                                                                                            action:@selector(ssvLongPressed:)];
    
    [ssv.contentView addGestureRecognizer:contentLP];
    
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
    
    CGFloat headerOverlapWidth = 4.0;
    
    ssv.rowHeaderOverlap = UIView.new;
    ssv.rowHeaderOverlap.translatesAutoresizingMaskIntoConstraints = NO;
    ssv.rowHeaderOverlap.backgroundColor = UIColor.yellowColor;
    ssv.rowHeaderOverlap.alpha = 0.5;
    ssv.rowHeaderOverlap.hidden = YES;
    
    [ssv addSubview:ssv.rowHeaderOverlap];
    
    [ssv.rowHeaderOverlap.leadingAnchor constraintEqualToAnchor:ssv.contentView.leadingAnchor constant:borderWidth].active = YES;
    [ssv.rowHeaderOverlap.topAnchor constraintEqualToAnchor:ssv.columnHeaderView.topAnchor].active = YES;
    [ssv.rowHeaderOverlap.bottomAnchor constraintEqualToAnchor:ssv.bottomAnchor].active = YES;
    [ssv.rowHeaderOverlap.widthAnchor constraintEqualToConstant:headerOverlapWidth].active = YES;
    
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
    
    NSUInteger xID = (point.x / _columnWidth);
    NSUInteger yID = (point.y / _rowHeight);
    
    if (gesture.view == _contentView)
    {
        selection = [NSString stringWithFormat:@"%@%ld", _alphabet[xID], (long)(yID + 1)];
        
        for (SpreadSheetViewCell *cell in _contentView.subviews)
        {
            if ([cell isKindOfClass:SpreadSheetViewCell.class] &&
                [cell.identifier isEqualToString:selection] &&
                cell.column <= _activeColumns && cell.row <= _activeRows && _delegate)
            {
                [_delegate ssvCellWasTappedAtRowIndex:(yID + 1)
                                          columnIndex:(xID + 1)];
            }
        }
    }
    
    else if (gesture.view == _rowHeaderView)
    {
        selection = [NSString stringWithFormat:@"%ld", (long)(yID + 1)];
        
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
                [cell.identifier isEqualToString:selection] &&
                cell.row == 1 && cell.column <= _activeColumns)
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
    if (textField == _textField)
    {
        _cellForEditing.text = textField.text;
        [textField removeFromSuperview];
        
        if (_delegate)
        {
            if (_cellForEditing.superview == _columnHeaderView)
            {
                [_delegate ssvDidEditColumnHeaderText:textField.text
                                              atIndex:(_cellForEditing.column - 1)];
            }
            
            else if (_cellForEditing.superview == _rowHeaderView)
            {
                [_delegate ssvDidEditRowHeaderText:textField.text
                                           atIndex:(_cellForEditing.row - 1)];
            }
            
            else if (_cellForEditing.superview == _contentView)
            {
                [_delegate ssvDidEditText:textField.text
                             forCellAtRow:_cellForEditing.row
                                   column:_cellForEditing.column];
            }
        }
    }
}

- (void)clearContents
{
    for (int r = 1; r <= _rows; r++)
    {
        for (int c = 1; c <= _columns; c++)
        {
            [self setText:@""
             forCellAtRow:(NSUInteger)r
                   column:(NSUInteger)c];
        }
    }
}

@end