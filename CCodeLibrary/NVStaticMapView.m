//  NVStaticMapView.m
//  CCodeLibrary

#import "NVStaticMapView.h"
#import "GSSiDefs.h"

@interface NVStaticMapView ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation NVStaticMapView

+ (NVStaticMapView *)showStaticMapInView:(UIView *)view
                          withCoordinate:(LLPOINT)coordinate
                                    zoom:(CGFloat)zoom
                                  tabBar:(UITabBar *)tabBar
                                   label:(NSString *)label
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat minBounds = (MIN(bounds.size.width, bounds.size.height) * 0.9);
    
    NVStaticMapView *staticMap = [[NVStaticMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, minBounds, minBounds)];
    
    staticMap.center = CGPointMake((bounds.size.width / 2.0),
                                   (bounds.size.height / 2.0));
    
    staticMap.alpha = 0.0;
    staticMap.tabBar = tabBar;
    
    staticMap.overlayView = [[UIView alloc] initWithFrame:bounds];
    staticMap.overlayView.backgroundColor = UIColor.blackColor;
    staticMap.overlayView.alpha = 0.0;
    staticMap.userInteractionEnabled = YES;
    
    [view addSubview:staticMap.overlayView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.02), (minBounds * 0.02),
                                                                        (minBounds * 0.21), (minBounds * 0.07))];
    
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
    
    [returnButton addTarget:staticMap
                     action:@selector(returnButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [staticMap addSubview:returnButton];
    
    NSString *staticMapUrl = [NSString stringWithFormat:
@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%f&size=640x640&scale=2&maptype=roadmap&markers=color:red|%f,%f&key=%@",
     coordinate.lat, coordinate.lon, zoom, coordinate.lat, coordinate.lon, GOOGLE_API_KEY];
    
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    staticMap.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    
    [view addSubview:staticMap];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         staticMap.overlayView.alpha = 0.7;
                         staticMap.alpha = 1.0;
                         
                         if (staticMap.tabBar)
                         {
                             staticMap.tabBar.alpha = 0.2;
                             staticMap.tabBar.userInteractionEnabled = NO;
                         }
                     }];
    
    return staticMap;
}

- (void)returnButtonTapped:(UIButton *)button
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

@end