//  NVTabBarEdit.h
//  CCodeLibrary

@import UIKit;

@interface NVTabBarEdit : NSObject

+ (void)tabBarController:(UITabBarController *)tabBarController
       removeItemAtIndex:(NSUInteger)index
                animated:(BOOL)animated;

+ (void)tabBarController:(UITabBarController *)tabBarController
replaceViewControllerAtIndex:(NSUInteger)index
      withViewController:(UIViewController *)viewController;

@end