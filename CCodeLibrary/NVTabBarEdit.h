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

+ (void)tabBarController:(UITabBarController *)tabBarController
                 setText:(NSString *)text
          forItemAtIndex:(NSUInteger)index;

+ (void)tabBarController:(UITabBarController *)tabBarController
                setImage:(UIImage *)image
          forItemAtIndex:(NSUInteger)index;

@end