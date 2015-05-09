//  NVImagePickerController.m
//  CCodeLibrary

#import "NVImagePickerController.h"

@interface NVImagePickerController ()

@end

@implementation NVImagePickerController

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    
    if (self)
        super.delegate = delegate;
    
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end