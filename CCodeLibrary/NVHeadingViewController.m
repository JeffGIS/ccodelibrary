//  NVHeadingViewController.m
//  CCodeLibrary

#import "NVHeadingViewController.h"
#import "UserDefaults.h"

@interface NVHeadingViewController ()

@end

@implementation NVHeadingViewController

+ (NVHeadingViewController *)showHeadingViewController:(id)delegate
{
    NVHeadingViewController *headingVC = [[NVHeadingViewController alloc] init];
    headingVC.delegate = delegate;
    
    if ([delegate isKindOfClass:UIViewController.class])
    {
        [delegate presentViewController:headingVC
                               animated:YES
                             completion:nil];
    }
    
    return headingVC;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UserDefaults.defaults.appleBlue;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end