//  HelpWebView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface HelpWebView : UIView

+ (HelpWebView *)showHelpWebView:(UIView *)view
                     presenterID:(NSString *)presenterID
                          tabBar:(UITabBar *)tabBar;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight;

@end