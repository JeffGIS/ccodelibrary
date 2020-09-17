//  GSSiNotesView.m
//  CCodeLibrary

#import "GSSiNotesView.h"
#import "UserDefaults.h"
#import "Colors.h"

typedef NS_ENUM(NSInteger, GSSiNotesViewOption)
{
    GSSiNotesViewOptionCancel,
    GSSiNotesViewOptionReplace,
    GSSiNotesViewOptionAddToList,
};

@interface GSSiNotesView ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIButton *cancelButton, *saveButton, *addToListButton;
@property (nonatomic) UIButton *viewClearButton, *overlayClearButton;
@property (nonatomic) CGFloat cornerRadius, buttonFontSize;
@property (nonatomic) UILabel *notesLabel;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *notesArray;
@property BOOL listUpdated;
@property (nonatomic) Colors *colors;

@end

@implementation GSSiNotesView
{
    NSString *_alertItems[2];
}

+ (GSSiNotesView *)showNotesViewWithView:(UIView *)view
                                delegate:(id)delegate
                                   title:(NSString *)title
                            currentValue:(NSString *)value
                        allowAutoCorrect:(BOOL)autoCorrect;

{
    CGSize buttonSize = CGSizeZero;
    CGFloat cornerRadius = 0.0, buttonFontSize = 0.0, viewMargin = 0.0, margin = 0.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        viewMargin = 16.0;
        cornerRadius = 6.0;
        buttonFontSize = 24.0;
        
        if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
            UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            margin = 8.0;
            buttonSize = CGSizeMake(100.0, 32.0);
        }
        
        else
        {
            margin = 12.0;
            buttonSize = CGSizeMake(100.0, 40.0);
        }
    }
    
    else
    {
        viewMargin = 40.0;
        cornerRadius = 10.0;
        buttonFontSize = 36.0;
        
        if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
            UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            margin = 12.0;
            buttonSize = CGSizeMake(180.0, 52.0);
        }
        
        else
        {
            margin = 16.0;
            buttonSize = CGSizeMake(180.0, 60.0);
        }
    }
    
    CGRect frame = CGRectMake(viewMargin, viewMargin, (view.frame.size.width - (viewMargin * 2.0)),
                              (view.frame.size.height - (viewMargin * 2.0)));
    
    GSSiNotesView *notesView = [[GSSiNotesView alloc] initWithFrame:frame];
    notesView.delegate = delegate;
    notesView.listUpdated = NO;
    notesView.cornerRadius = cornerRadius;
    notesView.buttonFontSize = buttonFontSize;
    notesView.colors = UserDefaults.defaults.defaultColors;
    
    notesView.center = CGPointMake((view.frame.size.width / 2.0),
                                   (view.frame.size.height / 2.0));
    
    notesView.backgroundColor = notesView.colors.backgroundColor;
    notesView.layer.cornerRadius = notesView.cornerRadius;
    notesView.alpha = 0.0;
    
    notesView.overlayView = [[UIView alloc] initWithFrame:view.frame];
    notesView.overlayView.backgroundColor = UIColor.blackColor;
    notesView.overlayView.alpha = 0.0;
    [view addSubview:notesView.overlayView];
    [view addSubview:notesView];
    
    notesView.saveButton = [[UIButton alloc] initWithFrame:
                            CGRectMake(margin, margin, buttonSize.width, buttonSize.height)];
    
    notesView.cancelButton = [[UIButton alloc] initWithFrame:
                              CGRectMake(((frame.size.width - margin) - buttonSize.width),
                                         margin, buttonSize.width, buttonSize.height)];
    
    [notesView setupButton:notesView.saveButton
                    target:notesView
                  selector:@selector(saveNotes:)
                     title:@"Save"];
    
    [notesView setupButton:notesView.cancelButton
                    target:notesView
                  selector:@selector(cancelNotes:)
                     title:@"Cancel"];
    
    [notesView addSubview:notesView.saveButton];
    [notesView addSubview:notesView.cancelButton];
    
    notesView.notesLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(margin, (buttonSize.height + margin),
                                       (frame.size.width - (margin * 2.0)), buttonSize.height)];
    
    if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
        UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        notesView.notesLabel.frame = CGRectMake(notesView.saveButton.frame.size.width + (margin * 2.0), margin,
                                                (frame.size.width - (margin * 4.0) - (buttonSize.width * 2.0)),
                                                buttonSize.height);
    }
    
    notesView.notesLabel.backgroundColor = UIColor.clearColor;
    notesView.notesLabel.textColor = notesView.colors.textColor;
    notesView.notesLabel.font = [UIFont boldSystemFontOfSize:notesView.buttonFontSize];
    notesView.notesLabel.text = title;
    notesView.notesLabel.textAlignment = NSTextAlignmentCenter;
    notesView.notesLabel.adjustsFontSizeToFitWidth = YES;
    
    [notesView addSubview:notesView.notesLabel];
    
    notesView.textView = [[UITextView alloc] initWithFrame:
                          CGRectMake(margin, ((buttonSize.height * 2.0) + margin),
                                     (frame.size.width - (margin * 2.0)), (frame.size.height * 0.3))];
    
    if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
        UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        notesView.textView.frame = CGRectMake(margin, (buttonSize.height + (margin * 2.0)),
                                              (frame.size.width - (margin * 2.0)), (frame.size.height * 0.3));
    }
    
    if (!value)
        value = @"";
    
    notesView.textView.text = value;
    notesView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    if (autoCorrect)
        notesView.textView.autocorrectionType = UITextAutocorrectionTypeYes;
    notesView.textView.layer.cornerRadius = notesView.cornerRadius;
    notesView.textView.backgroundColor = notesView.colors.titleColor;
    notesView.textView.layer.borderColor = notesView.colors.enabledColor.CGColor;
    notesView.textView.layer.borderWidth = (buttonFontSize / 8.0);
    notesView.textView.delegate = notesView;
    notesView.textView.textAlignment = NSTextAlignmentCenter;
    notesView.textView.textColor = notesView.colors.textColor;
    notesView.textView.font = [UIFont boldSystemFontOfSize:notesView.buttonFontSize];
    
    [notesView addSubview:notesView.textView];
    
    notesView.addToListButton = [[UIButton alloc] initWithFrame:
                                 CGRectMake(((frame.size.width / 2.0) - buttonSize.width),
                                            ((notesView.textView.frame.origin.y + notesView.textView.frame.size.height) + margin),
                                            (buttonSize.width * 2.0), buttonSize.height)];
    
    [notesView setupButton:notesView.addToListButton
                    target:notesView
                  selector:@selector(addToList:)
                     title:@"Add To List"];
    
    [notesView addSubview:notesView.addToListButton];
    
    CGFloat tableViewOriginY = ((notesView.addToListButton.frame.origin.y +
                                 notesView.addToListButton.frame.size.height) + margin);
    
    notesView.tableView = [[UITableView alloc] initWithFrame:
                           CGRectMake(margin, tableViewOriginY, (frame.size.width - (margin * 2.0)),
                                      frame.size.height - tableViewOriginY - margin)];
    
    notesView.tableView.layer.cornerRadius = notesView.cornerRadius;
    notesView.tableView.backgroundColor = notesView.colors.titleColor;
    notesView.tableView.layer.borderColor = notesView.colors.enabledColor.CGColor;
    notesView.tableView.layer.borderWidth = (buttonFontSize / 8.0);
    notesView.tableView.delegate = notesView;
    notesView.tableView.dataSource = notesView;
    notesView.tableView.rowHeight = buttonSize.height;
    
    [notesView.tableView registerClass:UITableViewCell.class
                forCellReuseIdentifier:@"Cell"];
    
    [notesView addSubview:notesView.tableView];
    
    notesView.overlayClearButton = [[UIButton alloc] initWithFrame:notesView.overlayView.frame];
    notesView.overlayClearButton.enabled = NO;
    
    [notesView setupClearButton:notesView.overlayClearButton
                         target:notesView
                       selector:@selector(dismissKeyboard:)];
    
    [notesView.overlayView addSubview:notesView.overlayClearButton];
    
    notesView.viewClearButton = [[UIButton alloc] initWithFrame:notesView.frame];
    notesView.viewClearButton.enabled = NO;
    
    [notesView setupClearButton:notesView.viewClearButton
                         target:notesView
                       selector:@selector(dismissKeyboard:)];
    
    [notesView addSubview:notesView.viewClearButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         notesView.overlayView.alpha = 0.6;
                         notesView.alpha = 1.0;
                     }];
    
    notesView.notesArray = [[NSMutableArray alloc] init];
    
    if (notesView.delegate)
    {
        [notesView.notesArray addObjectsFromArray:
         [notesView.delegate arrayOfPickableNotesItemsForNotesView:notesView]];
    }
    
    return notesView;
}

- (void)setupClearButton:(UIButton *)button
                  target:(id)target
                selector:(SEL)selector
{
    button.backgroundColor = UIColor.clearColor;
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.backgroundColor = _colors.enabledColor;
    button.layer.cornerRadius = _cornerRadius;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:_buttonFontSize];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:_colors.titleColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:_colors.highlightedColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideNotesView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _overlayView.alpha = 0.0;
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [_overlayView removeFromSuperview];
                         }];
    }
    
    else
    {
        [self removeFromSuperview];
        [_overlayView removeFromSuperview];
    }
}

- (void)bringToFrontOfView:(UIView *)view
{
    [view bringSubviewToFront:_overlayView];
    [view bringSubviewToFront:self];
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight
{
    CGPoint origin = self.frame.origin;
    CGRect superviewFrame = self.superview.frame;
    
    CGSize buttonSize;
    CGFloat margin;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            margin = 8.0;
            buttonSize = CGSizeMake(100.0, 32.0);
        }
        
        else
        {
            margin = 12.0;
            buttonSize = CGSizeMake(100.0, 40.0);
        }
    }
    
    else
    {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            margin = 12.0;
            buttonSize = CGSizeMake(180.0, 52.0);
        }
        
        else
        {
            margin = 16.0;
            buttonSize = CGSizeMake(180.0, 60.0);
        }
    }
    
    _tableView.rowHeight = buttonSize.height;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _overlayView.frame = CGRectMake(superviewFrame.origin.y, superviewFrame.origin.x,
                                                         (superviewFrame.size.height + tabBarHeight),
                                                         (superviewFrame.size.width - tabBarHeight));
                         
                         self.frame = CGRectMake(origin.y, origin.x,
                                                 ((superviewFrame.size.height + tabBarHeight) - (origin.y * 2.0)),
                                                 ((superviewFrame.size.width - tabBarHeight) - (origin.x * 2.0)));
                         
                         _saveButton.frame = CGRectMake(margin, margin, buttonSize.width, buttonSize.height);
                         
                         _cancelButton.frame = CGRectMake(((self.frame.size.width - margin) - buttonSize.width),
                                                          margin, buttonSize.width, buttonSize.height);
                     }];
    
    switch (toInterfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 _notesLabel.frame = CGRectMake(_saveButton.frame.size.width + (margin * 2.0), margin,
                                                                (self.frame.size.width - (margin * 4.0) - (buttonSize.width * 2.0)),
                                                                buttonSize.height);
                                 
                                 _textView.frame = CGRectMake(margin, (buttonSize.height + (margin * 2.0)),
                                                              (self.frame.size.width - (margin * 2.0)),
                                                              (self.frame.size.height * 0.3));
                             }];
        }
            break;
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 _notesLabel.frame = CGRectMake(margin, (buttonSize.height + margin),
                                                                (self.frame.size.width - (margin * 2.0)),
                                                                buttonSize.height);
                                 
                                 _textView.frame = CGRectMake(margin, ((buttonSize.height * 2.0) + margin),
                                                              (self.frame.size.width - (margin * 2.0)),
                                                              (self.frame.size.height * 0.3));
                             }];
        }
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _addToListButton.frame =
                         CGRectMake(((self.frame.size.width / 2.0) - buttonSize.width),
                                    ((_textView.frame.origin.y + _textView.frame.size.height) + margin),
                                    (buttonSize.width * 2.0), buttonSize.height);
                         
                         _tableView.frame =
                         CGRectMake(margin, ((_addToListButton.frame.origin.y +
                                              _addToListButton.frame.size.height) + margin),
                                    (self.frame.size.width - (margin * 2.0)),
                                    self.frame.size.height - ((_addToListButton.frame.origin.y +
                                                               _addToListButton.frame.size.height) + margin) - margin);
                     }];
}

- (void)saveNotes:(UIButton *)button
{
    if ([_textView isFirstResponder])
        [_textView resignFirstResponder];
    
    if (_delegate)
    {
        if (_listUpdated)
        {
            [_delegate notesView:self
                    didSaveNotes:_textView.text
                            list:_notesArray.copy];
        }
        else
        {
            [_delegate notesView:self
                    didSaveNotes:_textView.text
                            list:nil];
            
        }
    }
}

- (void)cancelNotes:(UIButton *)button
{
    if ([_textView isFirstResponder])
        [_textView resignFirstResponder];
    
    if (_delegate)
        [_delegate notesViewDidCancel:self];
}

- (void)addToList:(UIButton *)button
{
    if ([_textView isFirstResponder])
        [_textView resignFirstResponder];
    
    NSString *note = _textView.text;
    
    if ([note isEqualToString:@""])
        return;
    
    if ([note containsString:@"\n"])
    {
        NSArray *tempArray = [note componentsSeparatedByString:@"\n"];
        NSInteger l = tempArray.count;
        
        do
        {
            l--;
            note = tempArray[l];
        }
        
        while (l && [note isEqualToString:@""]);
    }
    
    if ([_notesArray containsObject:note])
        return;
    
    for (NSString *listItem in _notesArray)
    {
        if([listItem caseInsensitiveCompare:note] == NSOrderedSame)
        {
                if (_delegate && [_delegate respondsToSelector:@selector(notesView:didFindMatchBetweenNote:andItemInList:)])
            {
                [_delegate notesView:self
             didFindMatchBetweenNote:note
                       andItemInList:listItem];
                
                _alertItems[0] = note;
                _alertItems[1] = listItem;
            }
            
            return;
        }
    }
    
    [self addNoteToArray:note];
    [_tableView reloadData];
}

- (void)addNoteToArray:(NSString *)note
{
    if (_delegate && [_delegate respondsToSelector:@selector(notesView:addNoteToList:)])
        [_delegate notesView:self
               addNoteToList:note];
    [_notesArray addObject:note];
    
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:nil
                                                                ascending:YES];
    
    NSArray *tempArray = [_notesArray sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortOrder]];
    _notesArray = [NSMutableArray arrayWithArray:tempArray];
    _listUpdated = YES;
    [_tableView reloadData];
}

- (void)dismissKeyboard:(UIButton *)button
{
    if ([_textView isFirstResponder])
        [_textView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _overlayClearButton.enabled = YES;
    _viewClearButton.enabled = YES;
    [self bringSubviewToFront:_addToListButton];
    [self bringSubviewToFront:_saveButton];
    [self bringSubviewToFront:_cancelButton];
    
    if (![_textView.text isEqualToString:@""])
        _textView.text = [NSString stringWithFormat:@"%@\n", _textView.text];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _overlayClearButton.enabled = NO;
    _viewClearButton.enabled = NO;
    
    NSString *note = _textView.text;
    
    if ([note containsString:@"\n"])
    {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[note componentsSeparatedByString:@"\n"]];
        
        for (int i = (int)(tempArray.count - 1); i > 0; i--)
        {
            if ([tempArray[i] isEqualToString:@""])
                [tempArray removeObjectAtIndex:i];
        }
        
        _textView.text = [[tempArray valueForKey:@"description"] componentsJoinedByString:@"\n"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _notesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.textColor = _colors.textColor;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:_buttonFontSize];
    cell.textLabel.text = _notesArray[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    NSString *note = _textView.text;
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if ([note isEqualToString:@""])
    {
        _textView.text = cellText;
        return;
    }
    
    if (![note containsString:@"\n"])
    {
        if (![note isEqualToString:cellText])
        {
            _textView.text = [_textView.text stringByAppendingString:
                              [NSString stringWithFormat:@"\n%@", cellText]];
        }
        
        return;
    }
    
    NSArray *tempArray = [note componentsSeparatedByString:@"\n"];
    
    if (![tempArray containsObject:cellText])
    {
        _textView.text = [_textView.text stringByAppendingString:
                          [NSString stringWithFormat:@"\n%@", cellText]];
    }
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_notesArray removeObjectAtIndex:indexPath.row];
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
              withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger index = 0;
    
    [alertView hideLargeAlertView:YES];
    
    switch (buttonIndex)
    {
        case GSSiNotesViewOptionReplace:
            index = [_notesArray indexOfObject:_alertItems[1]];
            [_notesArray removeObject:_alertItems[1]];
            
        case GSSiNotesViewOptionAddToList:
            [_notesArray insertObject:_alertItems[0]
                              atIndex:index];
            
            [_tableView reloadData];
            break;
            
        default:
            break;
    }
}

@end
