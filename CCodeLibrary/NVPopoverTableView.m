//  NVPopoverTableView.m
//  CCodeLibrary

#import "NVPopoverTableView.h"
#import "UserDefaults.h"

@interface NVPopoverTableView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id <NVPopoverTableViewDelegate> delegate;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *textArray;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIFont *font;
@property BOOL includeCancel;

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
    
    if (![delegate respondsToSelector:@selector(popoverTableView:didSelectRowWithText:)] ||
        ![delegate respondsToSelector:@selector(popoverTableViewDidCancel:)])
    {
        NSLog(@"NVPopoverTableView ERROR:Delegate must respond to all selectors in protocol");
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
    nvptv.alpha = 0.0;
    nvptv.delegate = delegate;
    nvptv.title = title;
    nvptv.textArray = textArray;
    nvptv.includeCancel = includeCancel;
    
    nvptv.overlayView = UIView.new;
    nvptv.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.overlayView.backgroundColor = UIColor.blackColor;
    nvptv.overlayView.alpha = 0.0;
    
    [view addSubview:nvptv.overlayView];
    
    [nvptv.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    nvptv.tabBar = view.parentViewController.tabBarController.tabBar;
    nvptv.tabBar.userInteractionEnabled = NO;
    
    CGFloat margin = 100.0, cornerRadius = 16.0, rowHeight = 52.0;
    nvptv.font = [UIFont boldSystemFontOfSize:28.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        margin = 40.0, cornerRadius = 8.0, rowHeight = 44.0;
        nvptv.font = [UIFont boldSystemFontOfSize:20.0];
    }
    
    [view addSubview:nvptv];
    
    [nvptv constrainToView:view leading:margin trailing:-margin top:margin
                    bottom:(-margin + (nvptv.tabBar.frame.size.height / 2.0))];
    
    nvptv.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                   style:UITableViewStylePlain];
    
    nvptv.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.tableView.layer.cornerRadius = 10.0;
    nvptv.tableView.dataSource = nvptv;
    nvptv.tableView.delegate = nvptv;
    nvptv.tableView.rowHeight = rowHeight;
    nvptv.tableView.sectionHeaderHeight = rowHeight;
    nvptv.tableView.backgroundColor = UIColor.whiteColor;
    nvptv.tableView.delaysContentTouches = NO;
    
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
                             _tabBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [_overlayView removeFromSuperview];
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
    return MAX(_textArray.count, 1);
}

-(UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = UILabel.new;
    label.text= _title;
    label.backgroundColor = UserDefaults.defaults.appleGray;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = _font;
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = UIColor.blackColor;
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = _textArray[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = _font;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (_includeCancel && indexPath.row == 0)
        cell.textLabel.textColor = UIColor.redColor;
    
    else
        cell.textLabel.textColor = UserDefaults.defaults.appleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate)
    {
        if (_includeCancel && indexPath.row == 0)
            [_delegate popoverTableViewDidCancel:self];
        
        else
        {
            NSString *text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            
            [_delegate popoverTableView:self
                   didSelectRowWithText:text];
        }
    }
}

@end