//  NVPopoverTableView.m
//  CCodeLibrary

#import "NVPopoverTableView.h"

@interface NVPopoverTableView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id <NVPopoverTableViewDelegate> delegate;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *textArray;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIView *overlayView;

@end

@implementation NVPopoverTableView

+ (instancetype)showPopoverTableViewInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                                 textArray:(NSArray *)textArray
{
    if (!delegate || !view || !title || !textArray)
    {
        NSLog(@"NVPopoverTableView ERROR:Cannot set delegate, view, title or textArray to nil");
        return nil;
    }
    
    NVPopoverTableView *nvptv = NVPopoverTableView.new;
    nvptv.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.backgroundColor = UIColor.clearColor;
    nvptv.alpha = 0.0;
    nvptv.delegate = delegate;
    nvptv.title = title;
    nvptv.textArray = textArray;
    
    nvptv.overlayView = UIView.new;
    nvptv.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.overlayView.backgroundColor = UIColor.blackColor;
    nvptv.overlayView.alpha = 0.0;
    
    [view addSubview:nvptv.overlayView];
    
    [nvptv.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    nvptv.tabBar = view.parentViewController.tabBarController.tabBar;
    nvptv.tabBar.userInteractionEnabled = NO;
    
    CGFloat margin = 100.0, cornerRadius = 16.0, rowHeight = 52.0;
    UIFont *font = [UIFont boldSystemFontOfSize:28.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        margin = 40.0, cornerRadius = 8.0, rowHeight = 44.0;
        font = [UIFont boldSystemFontOfSize:20.0];
    }
    
    [view addSubview:nvptv];
    
    [nvptv constrainToView:view leading:margin trailing:-margin top:margin
                    bottom:(-margin + (nvptv.tabBar.frame.size.height / 2.0))];
    
    nvptv.tableView = UITableView.new;
    nvptv.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    nvptv.tableView.layer.cornerRadius = 10.0;
    nvptv.tableView.dataSource = nvptv;
    nvptv.tableView.delegate = nvptv;
    nvptv.tableView.rowHeight = rowHeight;
    nvptv.tableView.sectionHeaderHeight = rowHeight;
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return MAX(_textArray.count, 1);
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
    
    return cell;
}

@end