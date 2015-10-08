//  NVDestinationOptions.m
//  CCodeLibrary

#import "NVDestinationOptions.h"

@interface NVDestinationOptions ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation NVDestinationOptions

+ (NVDestinationOptions *)showDestinationOptionsInView:(UIView *)view
                                              delegate:(id)delegate
                                             frequency:(CGFloat)frequency
                                            timeDepart:(NSInteger)timeDepart
                                            timeReturn:(NSInteger)timeReturn
                                         destinationID:(NSInteger)destinationID
{
    NVDestinationOptions *destOpt = [[NVDestinationOptions alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    destOpt.overlayView = [[UIView alloc] initWithFrame:bounds];
    destOpt.overlayView.backgroundColor = UIColor.blackColor;
    destOpt.overlayView.alpha = 0.0;
    destOpt.delegate = delegate;
    
    if ([destOpt.delegate isKindOfClass:UIViewController.class])
    {
        UIViewController *vc = (UIViewController *)destOpt.delegate;
        destOpt.tabBar = vc.tabBarController.tabBar;
    }
    
    [view addSubview:destOpt.overlayView];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         destOpt.overlayView.alpha = 0.7;
                         destOpt.alpha = 1.0;
                         
                         if (destOpt.tabBar)
                             destOpt.tabBar.alpha = 0.2;
                     }];
    
    return destOpt;
}

- (void)hideDestinationOptions:(BOOL)animated
{
    
}

@end