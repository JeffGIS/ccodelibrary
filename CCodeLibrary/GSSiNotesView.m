//  GSSiNotesView.m
//  CCodeLibrary

#import "GSSiNotesView.h"

@interface GSSiNotesView ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIButton *cancelButton, *saveButton, *addToListButton;
@property (nonatomic) CGFloat cornerRadius, buttonFontSize;
@property (nonatomic) UILabel *notesLabel;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UITableView *tableView;

@end

@implementation GSSiNotesView

+ (GSSiNotesView *)showNotesViewWithView:(UIView *)view
                                delegate:(id)delegate
                            titleSubject:(NSString *)titleSubject
{
    CGSize buttonSize;
    CGFloat cornerRadius, buttonFontSize, viewMargin, margin;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        viewMargin = 16.0;
        margin = 12.0;
        buttonSize = CGSizeMake(100.0, 40.0);
        cornerRadius = 6.0;
        buttonFontSize = 24.0;
    }
    
    else
    {
        viewMargin = 40.0;
        margin = 16.0;
        buttonSize = CGSizeMake(180.0, 60.0);
        cornerRadius = 10.0;
        buttonFontSize = 36.0;
    }
    
    CGRect frame = CGRectMake(viewMargin, viewMargin, (view.frame.size.width - (viewMargin * 2.0)),
                              (view.frame.size.height - (viewMargin * 2.0)));
    
    GSSiNotesView *notesView = [[GSSiNotesView alloc] initWithFrame:frame];
    notesView.delegate = delegate;
    notesView.cornerRadius = cornerRadius;
    notesView.buttonFontSize = buttonFontSize;
    
    notesView.center = CGPointMake((view.frame.size.width / 2.0),
                                    (view.frame.size.height / 2.0));
    
    notesView.backgroundColor = [UIColor colorWithRed:(240.0 / 255.0)
                                                green:(255.0 / 255.0)
                                                 blue:(200.0 / 255.0)
                                                alpha:1.0];
    
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
    
    notesView.notesLabel.backgroundColor = UIColor.clearColor;
    notesView.notesLabel.textColor = UIColor.blackColor;
    notesView.notesLabel.font = [UIFont boldSystemFontOfSize:notesView.buttonFontSize];
    notesView.notesLabel.text = [NSString stringWithFormat:@"Notes for Pipe #%@", titleSubject];
    notesView.notesLabel.textAlignment = NSTextAlignmentCenter;
    notesView.notesLabel.adjustsFontSizeToFitWidth = YES;
    
    [notesView addSubview:notesView.notesLabel];
    
    notesView.textView = [[UITextView alloc] initWithFrame:
                          CGRectMake(margin, ((buttonSize.height * 2.0) + margin),
                                     (frame.size.width - (margin * 2.0)), (frame.size.height * 0.3))];
    
    notesView.textView.layer.cornerRadius = notesView.cornerRadius;
    notesView.textView.backgroundColor = UIColor.whiteColor;
    notesView.textView.layer.borderColor = UIColor.blackColor.CGColor;
    notesView.textView.layer.borderWidth = (buttonFontSize / 8.0);
    notesView.textView.delegate = notesView;
    notesView.textView.textAlignment = NSTextAlignmentCenter;
    notesView.textView.textColor = UIColor.blackColor;
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
    notesView.tableView.backgroundColor = UIColor.whiteColor;
    notesView.tableView.layer.borderColor = UIColor.blackColor.CGColor;
    notesView.tableView.layer.borderWidth = (buttonFontSize / 8.0);
    notesView.tableView.delegate = notesView;
    notesView.tableView.rowHeight = buttonSize.height;
    
    [notesView addSubview:notesView.tableView];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         notesView.overlayView.alpha = 0.6;
                         notesView.alpha = 1.0;
                     }];
    
    return notesView;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.backgroundColor = UIColor.blackColor;
    button.layer.cornerRadius = _cornerRadius;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:_buttonFontSize];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
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
                  tabBarHeight:(CGFloat)tabBarHeight
{
    CGRect superviewFrame = self.superview.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _overlayView.frame = CGRectMake(superviewFrame.origin.y, superviewFrame.origin.x,
                                                         (superviewFrame.size.height + tabBarHeight),
                                                         (superviewFrame.size.width - tabBarHeight));
                         
                         self.center = CGPointMake(((superviewFrame.size.height + tabBarHeight) / 2.0),
                                                   ((superviewFrame.size.width - tabBarHeight) / 2.0));
                     }];
}

- (void)saveNotes:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate notesView:self
                didSaveNotes:nil
                        list:nil];
    }
}

- (void)cancelNotes:(UIButton *)button
{
    if (_delegate)
        [_delegate notesViewdidCancel:self];
}

- (void)addToList:(UIButton *)button
{
    
}

@end