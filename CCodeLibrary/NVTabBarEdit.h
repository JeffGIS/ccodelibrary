//  NVTabBarEdit.h
//  CCodeLibrary

@import UIKit;

@interface NVTabBarEdit : NSObject

+ (void)tabBarController:(UITabBarController *)tabBarController
removeViewControllerWithID:(NSString *)ID;

+ (void)tabBarController:(UITabBarController *)tabBarController
replaceViewControllerWithID:(NSString *)ID
      withViewController:(UIViewController *)viewController;

+ (void)tabBarController:(UITabBarController *)tabBarController
    insertViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index;

+ (void)tabBarController:(UITabBarController *)tabBarController
                 setText:(NSString *)text
 forViewControllerWithID:(NSString *)ID;

+ (void)tabBarController:(UITabBarController *)tabBarController
                setImage:(UIImage *)image
 forViewControllerWithID:(NSString *)ID;

+ (UIViewController *)viewControllerWithID:(NSString *)ID
                        inTabBarController:(UITabBarController *)tabBarController;

+ (UIViewController *)viewControllerWithID:(NSString *)ID
                        inTabBarController:(UITabBarController *)tabBarController
                                     index:(NSUInteger *)index;

+ (NSInteger)indexOfViewControllerWithID:(NSString *)ID
                      inTabBarController:(UITabBarController *)tabBarController;

@end
