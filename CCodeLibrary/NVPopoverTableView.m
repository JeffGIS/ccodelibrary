//  NVPopoverTableView.m
//  CCodeLibrary

#import "NVPopoverTableView.h"
#import "UserDefaults.h"

#define YT_TAG 111
#define PDF_TAG 222

@interface NVPopoverTableView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id <NVPopoverTableViewDelegate> delegate;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray *textArray, *groupColors;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIFont *font;
@property BOOL includeCancel;
@property CGFloat cellWidth, cornerRadius;
@property (nonatomic) UIButton *returnButton, *clearButton;
@property int lastRowTapped;
@property (nonatomic) NSMutableArray *groupArray;
@property (nonatomic) UIImage *ytImage, *pdfImage;

@end

@implementation NVPopoverTableView

+ (instancetype)showPopoverTableViewInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                                 textArray:(NSArray *)textArray
                             includeCancel:(BOOL)includeCancel
{
    if (!delegate || !view || !title || !textArray)
    {
        NSLog(@"NVPopoverTableView ERROR:Cannot set delegate, view, title or textArray to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(popoverTableView:didSelectRowWithText:atIndex:)])
    {
        NSLog(@"NVPopoverTableView ERROR:Delegate must respond to [popoverTableView:didSelectRowWithText:atIndex:]");
        return nil;
    }
    
    if (includeCancel)
    {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:textArray];
        
        [tempArray insertObject:@"Cancel"
                        atIndex:0];
        
        textArray = tempArray.copy;
    }
    
    NVPopoverTableView *nvptv = NVPopoverTableView.new;
    nvptv.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.backgroundColor = UIColor.clearColor;
    nvptv.layer.borderColor = UserDefaults.defaults.appleBlue.CGColor;
    nvptv.layer.borderWidth = 0.0;
    nvptv.alpha = 0.0;
    nvptv.delegate = delegate;
    nvptv.title = title;
    nvptv.textArray = textArray;
    nvptv.includeCancel = includeCancel;
    nvptv.allowsMultipleSelection = NO;
    nvptv.parseTextToButtons = NO;
    nvptv.lastRowTapped = 0;
    
    nvptv.groupColors = @[([UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:1.0]),//red
                          ([UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:1.0]),//green
                          ([UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:1.0]),//blue
                          ([UIColor colorWithRed:1.0 green:0.9 blue:0.8 alpha:1.0]),//orange
                          ([UIColor colorWithRed:0.9 green:0.8 blue:1.0 alpha:1.0]),//purple
                          ([UIColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0]),//yellow
                          ([UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:1.0]),//cyan
                          ([UIColor colorWithRed:1.0 green:0.85 blue:0.95 alpha:1.0]),//pink
                          ([UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:1.0]),//lime
                          ([UIColor colorWithRed:0.95 green:0.95 blue:0.85 alpha:1.0])];//khaki

    nvptv.overlayView = UIView.new;
    nvptv.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.overlayView.backgroundColor = UIColor.blackColor;
    nvptv.overlayView.alpha = 0.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nvptv
                                                                          action:@selector(overlayTapped:)];
    
    [nvptv.overlayView addGestureRecognizer:tap];
    
    [view addSubview:nvptv.overlayView];
    [nvptv.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    nvptv.tabBar = view.parentViewController.tabBarController.tabBar;
    nvptv.tabBar.userInteractionEnabled = NO;
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat shortestSide = MIN(bounds.size.height, bounds.size.width);
    CGFloat margin = 80.0;
    nvptv.cornerRadius = 16.0;
    nvptv.font = [UIFont boldSystemFontOfSize:28.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        margin = 40.0, nvptv.cornerRadius = 8.0;
        nvptv.font = [UIFont boldSystemFontOfSize:20.0];
    }
    
    nvptv.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nvptv.returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.returnButton.backgroundColor = UIColor.whiteColor;
    nvptv.returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    nvptv.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    nvptv.returnButton.layer.borderColor = UserDefaults.defaults.appleBlue.CGColor;
    nvptv.returnButton.layer.borderWidth = 4.0;
    nvptv.returnButton.alpha = 0.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        nvptv.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:26.0];
    
    [nvptv.returnButton setTitle:@" < Return  " forState:UIControlStateNormal];
    [nvptv.returnButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [nvptv.returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    [view addSubview:nvptv.returnButton];
    [nvptv.returnButton constrainLeadingToAnchor:view.leadingAnchor constant:20.0];
    [nvptv.returnButton constrainTopToAnchor:view.topAnchor constant:(margin / 4.0)];
    
    [nvptv.returnButton addTarget:nvptv
                           action:@selector(rtnButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    nvptv.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nvptv.clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.clearButton.backgroundColor = UIColor.whiteColor;
    nvptv.clearButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    nvptv.clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    nvptv.clearButton.layer.borderColor = UserDefaults.defaults.appleBlue.CGColor;
    nvptv.clearButton.layer.borderWidth = 4.0;
    nvptv.clearButton.alpha = 0.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        nvptv.clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:26.0];
    
    [nvptv.clearButton setTitle:@" Clear  " forState:UIControlStateNormal];
    [nvptv.clearButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [nvptv.clearButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    [view addSubview:nvptv.clearButton];
    [nvptv.clearButton constrainTrailingToAnchor:view.trailingAnchor constant:-20.0];
    [nvptv.clearButton constrainTopToAnchor:view.topAnchor constant:(margin / 4.0)];
    
    [nvptv.clearButton addTarget:nvptv
                          action:@selector(clearButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    nvptv.cellWidth = (shortestSide - (margin * 2.0) - 30.0);
    
    [view addSubview:nvptv];
    
    [nvptv constrainToView:view leading:margin trailing:-margin top:(margin * 1.5)
                    bottom:(nvptv.tabBar.frame.size.height - (margin * 1.5))];
    
    nvptv.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                   style:UITableViewStylePlain];
    
    nvptv.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.tableView.layer.cornerRadius = 10.0;
    nvptv.tableView.dataSource = nvptv;
    nvptv.tableView.delegate = nvptv;
    nvptv.tableView.backgroundColor = UIColor.whiteColor;
    nvptv.tableView.delaysContentTouches = NO;
    nvptv.tableView.bounces = NO;
    nvptv.tableView.bouncesZoom = NO;
    
    [nvptv addSubview:nvptv.tableView];
    [nvptv.tableView constrainToView:nvptv leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvptv.overlayView.alpha = 0.7;
                         nvptv.alpha = 1.0;
                         nvptv.tabBar.alpha = 0.3;
                     }];
    
    return nvptv;
}

- (void)hide:(BOOL)animated;
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                             _overlayView.alpha = 0.0;
                             _returnButton.alpha = 0.0;
                             _clearButton.alpha = 0.0;
                             _tabBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [_overlayView removeFromSuperview];
                             [_returnButton removeFromSuperview];
                             [_clearButton removeFromSuperview];
                             [self removeFromSuperview];
                             _tabBar.userInteractionEnabled = YES;
                         }];
    }
    
    else
    {
        [_overlayView removeFromSuperview];
        [self removeFromSuperview];
        _tabBar.alpha = 1.0;
        _tabBar.userInteractionEnabled = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (_tableView.allowsMultipleSelection)
        return MAX(_groupArray.count, 1);
    
    else
        return MAX(_textArray.count, 1);
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return [self getHeightForText:_title
                             font:_font
                            width:_cellWidth];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_parseTextToButtons)
    {
        return ([self getHeightForText:textBeforeTab(_textArray[indexPath.row])
                                 font:_font
                                width:_cellWidth] + 20.0);
    }
    
    else
    {
        if (_tableView.allowsMultipleSelection)
        {
            return [self getHeightForText:textBefore(_groupArray[indexPath.row], @"\x03")
                                     font:_font
                                    width:_cellWidth];
        }
        
        else
        {
            return [self getHeightForText:textBefore(_textArray[indexPath.row], @"\x03")
                                     font:_font
                                    width:_cellWidth];
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = UILabel.new;
    label.text= _title;
    label.backgroundColor = UserDefaults.defaults.appleGray;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = _font;
    label.textColor = UIColor.blackColor;
    label.numberOfLines = 0;
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier1 = @"CustomCell1";
    static NSString *cellIdentifier2 = @"CustomCell2";

    NSString *cellID = cellIdentifier1;
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    NSString *cellText = _textArray[indexPath.row];
    NSString *subtitle = textAfter(_textArray[indexPath.row], @"\n");
    
    if (_allowsSubtitle && subtitle.length)
    {
        cellID = cellIdentifier2;
        style = UITableViewCellStyleSubtitle;
        cellText = textBefore(cellText, @"\n");
    }
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:style
                reuseIdentifier:cellID];
    }
    
    cell.textLabel.font = _font;
    cell.tag = indexPath.row;
    
    if (_parseTextToButtons)
    {
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.text = textBeforeTab(_textArray[indexPath.row]);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.numberOfLines = 1;
        
        if (_includeCancel && indexPath.row == 0)
        {
            cell.textLabel.textColor = UIColor.redColor;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        else
        {
            for (UIView *subviews in cell.subviews)
            {
                if ((subviews.tag == (cell.tag * YT_TAG)) || (subviews.tag == (cell.tag * PDF_TAG)))
                    [subviews removeFromSuperview];
            }
            
            cell.textLabel.textColor = UIColor.blackColor;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([_textArray[indexPath.row] length])
            {
                UIButton *ytButton = [UIButton buttonWithType:UIButtonTypeCustom];
                ytButton.translatesAutoresizingMaskIntoConstraints = NO;
                [ytButton setImage:_ytImage forState:UIControlStateNormal];
                ytButton.contentMode = UIViewContentModeScaleAspectFit;
                ytButton.tag = (cell.tag * YT_TAG);
                [cell addSubview:ytButton];
                [ytButton constrainTrailingToAnchor:cell.trailingAnchor constant:-10.0];
                [ytButton constrainCenterYToAnchor:cell.centerYAnchor];
                [ytButton constrainHeightToAnchor:cell.heightAnchor multiplier:0.8];
                [ytButton constrainWidthToAnchor:ytButton.heightAnchor multiplier:1.2];
                
                [ytButton addTarget:self
                             action:@selector(ytButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
                
                UIButton *pdfButton = [UIButton buttonWithType:UIButtonTypeCustom];
                pdfButton.translatesAutoresizingMaskIntoConstraints = NO;
                [pdfButton setImage:_pdfImage forState:UIControlStateNormal];
                pdfButton.contentMode = UIViewContentModeScaleAspectFit;
                pdfButton.tag = (cell.tag * PDF_TAG);
                [cell addSubview:pdfButton];
                [pdfButton constrainTrailingToAnchor:ytButton.leadingAnchor constant:-10.0];
                [pdfButton constrainCenterYToAnchor:cell.centerYAnchor];
                [pdfButton constrainHeightToAnchor:cell.heightAnchor multiplier:0.8];
                [pdfButton constrainWidthToAnchor:ytButton.heightAnchor multiplier:0.8];
                
                [pdfButton addTarget:self
                              action:@selector(pdfButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    else
    {
        NSString *group = @"";
        
        if (_allowsSubtitle && subtitle.length)
        {
            cell.detailTextLabel.text = subtitle;
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.detailTextLabel.textColor = UIColor.darkTextColor;
        }

        if (_tableView.allowsMultipleSelection)
        {
            cell.textLabel.text = textBefore(_groupArray[indexPath.row], @"\x03");
            group = textBefore(textAfter(_groupArray[indexPath.row], @"\x05"), @"\x04");
        }
        
        else
        {
            cell.textLabel.text = textBefore(cellText, @"\x03");
            group = textBefore(textAfter(cellText, @"\x05"), @"\x04");
        }
        
        if (!group)
            group = @"0";
        
        NSInteger groupIndex = group.integerValue;
        
        if (groupIndex > 0)
        {
            groupIndex--;
            groupIndex %= _groupColors.count;
            cell.backgroundColor = _groupColors[groupIndex];
        }
        
        else
            cell.backgroundColor = UIColor.whiteColor;
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        
        if (_includeCancel && indexPath.row == 0)
            cell.textLabel.textColor = UIColor.redColor;
        
        else
        {
            cell.textLabel.textColor = UserDefaults.defaults.appleBlue;
            
            if (_allowsMultipleSelection)
            {
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                        action:@selector(cellLongPressed:)];
                
                [cell addGestureRecognizer:longPress];
            }
        }
        
        if (_imageArray.count)
            cell.imageView.image = (UIImage *)_imageArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_includeCancel && indexPath.row == 0 && [_delegate respondsToSelector:@selector(popoverTableViewDidCancel:)])
        [_delegate popoverTableViewDidCancel:self];
    
    else if (!_parseTextToButtons)
    {
        if (_tableView.allowsMultipleSelection)
            _lastRowTapped = (int)indexPath.row;
        
        else
        {
            NSString *text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            NSInteger index = 0;
            
            if (_includeCancel)
                index = (indexPath.row - 1);
            
            else
                index = indexPath.row;
            
            [_delegate popoverTableView:self
                   didSelectRowWithText:text
                                atIndex:index];
        }
    }
}

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _lastRowTapped = (int)indexPath.row;
}

- (void)overlayTapped:(UITapGestureRecognizer *)gesture
{
    if (_includeCancel)
        [_delegate popoverTableViewDidCancel:self];
}

- (void)setImageArray:(NSArray *)imageArray
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        _tableView.rowHeight = 132.0;
    
    else
        _tableView.rowHeight = 156.0;
    
    _imageArray = imageArray;
    [_tableView reloadData];
}

- (CGFloat)getHeightForText:(NSString *)text
                       font:(UIFont *)font
                      width:(CGFloat)width
{
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width , 20000.0)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil].size;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return (ceil(titleSize.height) + 16.0);
    
    else
        return (ceil(titleSize.height) + 20.0);
}

- (void)cellLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        UITableViewCell *cell = (UITableViewCell *)gesture.view;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
        
        if (_tableView.allowsMultipleSelection)
        {
            int start = (int)MIN(indexPath.row, _lastRowTapped);
            int stop  = (int)MAX(indexPath.row, _lastRowTapped);
            NSArray<NSIndexPath *> *selectedRows = _tableView.indexPathsForSelectedRows;
            
            for (int i = start; i <= stop; i++)
            {
                if (i == _lastRowTapped)
                    continue;
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                
                if ([selectedRows containsObject:indexPath])
                    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
                
                else
                    [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            _lastRowTapped = 0;
        }
        
        else
        {
            _tableView.allowsMultipleSelection = YES;
            self.layer.cornerRadius = 0.0;
            self.layer.borderColor = UserDefaults.defaults.appleBlue.CGColor;
            self.layer.borderWidth = 4.0;
            _groupArray = NSMutableArray.array;
            NSString *groupID = textBefore(textAfter(_textArray[indexPath.row], @"\x05"), @"\x04");
            NSString *cellText = cell.textLabel.text;
            NSInteger cellToSelect = -1;
            
            if (!groupID)
                groupID = @"0";
            
            for (NSString *text in _textArray)
            {
                if (_includeCancel && [_textArray indexOfObject:text] == 0)
                {
                    [_groupArray addObject:text];
                    continue;
                }
                
                NSString *group = textBefore(textAfter(text, @"\x05"), @"\x04");
                
                if (!group)
                    group = @"0";
                
                if ([group isEqualToString:groupID])
                {
                    [_groupArray addObject:text];
                    
                    if ([textBefore(text, @"\x03") isEqualToString:cellText])
                        _lastRowTapped = cellToSelect = (int)[_groupArray indexOfObject:text];
                }
            }
            
            [_tableView reloadData];
            
            if (cellToSelect >= 0)
            {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:cellToSelect inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
            }
            
            [UIView animateWithDuration:0.25
                             animations:^{
                                 _returnButton.alpha = 1.0;
                                 _clearButton.alpha = 1.0;
                             }];
        }
    }
}

- (void)rtnButtonTapped:(UIButton *)button
{
    NSMutableArray<NSNumber *> *selectedRows = NSMutableArray.array;
    NSMutableArray *selectedTextArray = NSMutableArray.array;
    
    if (!_tableView.indexPathsForSelectedRows.count)
    {
        if ([_delegate respondsToSelector:@selector(popoverTableViewDidCancel:)])
        {
            [_delegate popoverTableViewDidCancel:self];
            return;
        }
    }
    
    else if (_tableView.indexPathsForSelectedRows.count == 1)
    {
        NSIndexPath *indexPath = _tableView.indexPathsForSelectedRows[0];
        NSString *text = textBefore(_groupArray[indexPath.row], @"\x03");
        NSInteger index = [_textArray indexOfObject:_groupArray[indexPath.row]];
        
        if (_includeCancel)
            index -= 1;
        
        [_delegate popoverTableView:self
               didSelectRowWithText:text
                            atIndex:index];
        
        return;
    }
    
    else for (NSIndexPath *paths in _tableView.indexPathsForSelectedRows)
    {
        if (_includeCancel)
        {
            NSInteger index = [_textArray indexOfObject:_groupArray[paths.row - 1]];
            [selectedRows addObject:[NSNumber numberWithInt:(int)index]];
            [selectedTextArray addObject:_groupArray[paths.row]];
        }
        
        else
        {
            NSInteger index = [_textArray indexOfObject:_groupArray[paths.row]];
            [selectedRows addObject:[NSNumber numberWithInt:(int)index]];
            [selectedTextArray addObject:_groupArray[paths.row]];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(popoverTableView:didReturnWithSelectedRows:textArray:)])
    {
        [_delegate popoverTableView:self
          didReturnWithSelectedRows:selectedRows.copy
                          textArray:selectedTextArray.copy];
    }
}

- (void)clearButtonTapped:(UIButton *)button
{
    for (NSIndexPath *paths in _tableView.indexPathsForSelectedRows)
        [_tableView deselectRowAtIndexPath:paths animated:NO];
    
    _tableView.allowsMultipleSelection = NO;
    self.layer.borderWidth = 0.0;
    self.layer.cornerRadius = _cornerRadius;
    [_tableView reloadData];
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:YES];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _returnButton.alpha = 0.0;
                         _clearButton.alpha = 0.0;
                     }];
}

- (void)setParseTextToButtons:(BOOL)parseTextToButtons
{
    _parseTextToButtons = parseTextToButtons;
    
    _ytImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"ytIcon"
                                                                              ofType:@"png"]];
    
    _pdfImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"pdfIcon"
                                                                               ofType:@"png"]];
    
    [_tableView reloadData];
}

- (void)ytButtonTapped:(UIButton *)button
{
    NSInteger index = (button.tag / YT_TAG);
    NSString *text = textAfterLastTab(_textArray[index]);
    
    if ([_delegate respondsToSelector:@selector(popoverTableView:didSelectYTButtonWithText:atIndex:)])
        [_delegate popoverTableView:self didSelectYTButtonWithText:text atIndex:index];
}

- (void)pdfButtonTapped:(UIButton *)button
{
    NSInteger index = (button.tag / PDF_TAG);
    NSString *text = textBeforeTab(textAfterTab(_textArray[index]));
    
    if ([_delegate respondsToSelector:@selector(popoverTableView:didSelectPDFButtonWithText:atIndex:)])
        [_delegate popoverTableView:self didSelectPDFButtonWithText:text atIndex:index];
}

@end
