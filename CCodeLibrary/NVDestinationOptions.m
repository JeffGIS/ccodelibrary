//  NVDestinationOptions.m
//  CCodeLibrary

#import "NVDestinationOptions.h"
#import "UserDefaults.h"

@interface NVDestinationOptions ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) NSInteger frequency, timeDepart, timeReturn, destinationID;

@end

@implementation NVDestinationOptions

+ (NVDestinationOptions *)showDestinationOptionsInView:(UIView *)view
                                              delegate:(id)delegate
                                             frequency:(NSInteger)frequency
                                            timeDepart:(NSInteger)timeDepart
                                            timeReturn:(NSInteger)timeReturn
                                         destinationID:(NSInteger)destinationID
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    CGFloat minBounds = (MIN(bounds.size.width, bounds.size.height) * 0.9);
    
    NVDestinationOptions *destOpt =
    [[NVDestinationOptions alloc] initWithFrame:CGRectMake(0.0, 0.0, minBounds, minBounds)];
    
    destOpt.center = CGPointMake((bounds.size.width / 2.0),
                                 (bounds.size.height / 2.0));
    
    destOpt.delegate = delegate;
    destOpt.frequency = frequency;
    destOpt.timeReturn = timeReturn;
    destOpt.timeDepart = timeDepart;
    destOpt.destinationID = destinationID;
    destOpt.alpha = 0.0;
    destOpt.backgroundColor = UserDefaults.defaults.defaultColors.backgroundColor;
    destOpt.layer.cornerRadius = (minBounds / 60.0);
    
    if ([destOpt.delegate isKindOfClass:UIViewController.class])
    {
        UIViewController *vc = (UIViewController *)destOpt.delegate;
        destOpt.tabBar = vc.tabBarController.tabBar;
    }
    
    destOpt.overlayView = [[UIView alloc] initWithFrame:bounds];
    destOpt.overlayView.backgroundColor = UIColor.blackColor;
    destOpt.overlayView.alpha = 0.0;
    
    [view addSubview:destOpt.overlayView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.02), (minBounds * 0.02),
                                                                        (minBounds * 0.23), (minBounds * 0.08))];
    
    returnButton.backgroundColor = UIColor.blackColor;
    
    [returnButton setTitle:@"< Return"
                  forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.grayColor
                       forState:UIControlStateHighlighted];
    
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    returnButton.layer.cornerRadius = (minBounds / 60.0);
    
    [returnButton addTarget:destOpt
                     action:@selector(returnButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [destOpt addSubview:returnButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.25), (minBounds * 0.02),
                                                                    (minBounds * 0.5), (minBounds * 0.13))];
    
    titleLabel.backgroundColor = UIColor.clearColor;
    titleLabel.text = @"Destinations\nOptions Controller";
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColor.blackColor;
    
    [destOpt addSubview:titleLabel];
    
    [view addSubview:destOpt];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         destOpt.overlayView.alpha = 0.7;
                         destOpt.alpha = 1.0;
                         
                         if (destOpt.tabBar)
                         {
                             destOpt.tabBar.alpha = 0.2;
                             destOpt.tabBar.userInteractionEnabled = NO;
                         }
                     }];
    
    return destOpt;
}

- (void)hideDestinationOptions:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                             _overlayView.alpha = 0.0;
                             
                             if (_tabBar)
                             {
                                 _tabBar.alpha = 1.0;
                                 _tabBar.userInteractionEnabled = YES;
                             }
                         } completion:^(BOOL finished) {
                             [_overlayView removeFromSuperview];
                             [self removeFromSuperview];
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

- (void)returnButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate destinationOptions:self
                   didReturnFrequency:_frequency
                           timeDepart:_timeDepart
                           timeReturn:_timeReturn
                        destinationID:_destinationID];
    }
}

@end