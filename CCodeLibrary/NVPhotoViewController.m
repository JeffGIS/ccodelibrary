//
//  NVPhotoViewController.m
//  CCodeLibrary

#import "NVPhotoViewController.h"

@interface NVPhotoViewController ()

@end

@implementation NVPhotoViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.blackColor;
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