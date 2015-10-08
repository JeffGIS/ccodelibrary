//  NVDestinationOptions.m
//  CCodeLibrary

#import "NVDestinationOptions.h"

@interface NVDestinationOptions ()

@property (nonatomic) UIView *overlayView;

@end

@implementation NVDestinationOptions

+ (NVDestinationOptions *)showDestinationOptionsInView:(UIView *)view
                                              delegate:(id)delegate
                                             frequency:(CGFloat)frequency
                                            timeDepart:(NSInteger)timeDepart
                                            timeReturn:(NSInteger)timeReturn
                                         destinationID:(NSInteger)destinationID
{
    if ([delegate isKindOfClass:UIViewController.class])
    {
        UIViewController *vc = (UIViewController *)delegate;
        vc.tabBarController.tabBar.hidden = YES;
    }
    
    NVDestinationOptions *destOpt = [[NVDestinationOptions alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    destOpt.overlayView = [[UIView alloc] initWithFrame:bounds];
    destOpt.overlayView.backgroundColor = UIColor.blackColor;
    destOpt.overlayView.alpha = 0.0;
    destOpt.delegate = delegate;
    
    [view addSubview:destOpt.overlayView];
    
    return destOpt;
}

- (void)hideDestinationOptions:(BOOL)animated
{
    
}

@end