//  NVImagePickerController.m
//  CCodeLibrary

#import "NVImagePickerController.h"
#import "CRAPI.h"

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

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (CRAPI.sharedInstance.presentUpsideDown)
        return UIInterfaceOrientationPortraitUpsideDown;
    
    else
        return UIInterfaceOrientationLandscapeRight;//UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (CRAPI.sharedInstance.presentUpsideDown)
        return UIInterfaceOrientationMaskPortraitUpsideDown;
    
    else
        return UIInterfaceOrientationMaskLandscape;//UIInterfaceOrientationMaskPortrait;
}

@end
