//  RHList.m
//  CCodeLibrary

#import "RHList.h"
#import "NVSpreadsheetVC.h"

@interface RHList ()

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic, copy) NSArray<RHClip *> *clips;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIImageView *imageView;
@property int propNum;

@end

@implementation RHList

+ (instancetype)listWithPropNum:(int)propNum
                       delegate:(id)delegate
{
    RHList *list = RHList.new;
    list.propNum = propNum;
    list.delegate = delegate;
    return list;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
