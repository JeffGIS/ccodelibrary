//  HelpWebView.h
//  CCodeLibrary

@import UIKit;
//#import "YTPlayerView.h"

@interface HelpWebView : UIView //<YTPlayerViewDelegate>

+ (HelpWebView *)showHelpWebView:(UIView *)view
                     presenterID:(NSString *)presenterID
                          tabBar:(UITabBar *)tabBar;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight;

@end