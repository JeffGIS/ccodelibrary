//  NVTabBarEdit.m
//  CCodeLibrary

#import "NVTabBarEdit.h"

@implementation NVTabBarEdit

+ (void)tabBarController:(UITabBarController *)tabBarController
       removeItemAtIndex:(NSUInteger)index
{
    if (index < tabBarController.viewControllers.count)
    {
        NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
        [newTabBarVCs removeObjectAtIndex:index];
        
        tabBarController.viewControllers = newTabBarVCs.copy;
    }
}

+ (void)tabBarController:(UITabBarController *)tabBarController
replaceViewControllerAtIndex:(NSUInteger)index
      withViewController:(UIViewController *)viewController
{
    if (index < tabBarController.viewControllers.count)
    {
        NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
        
        [newTabBarVCs replaceObjectAtIndex:index
                                withObject:viewController];
        
        tabBarController.viewControllers = newTabBarVCs.copy;
    }
}

+ (void)tabBarController:(UITabBarController *)tabBarController
    insertViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index
{
    if (index <= tabBarController.viewControllers.count)
    {
        NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
        
        [newTabBarVCs insertObject:viewController
                           atIndex:index];
        
        tabBarController.viewControllers = newTabBarVCs.copy;
    }
}

+ (void)tabBarController:(UITabBarController *)tabBarController
                 setText:(NSString *)text
          forItemAtIndex:(NSUInteger)index
{
    if (index < tabBarController.tabBar.items.count)
        tabBarController.tabBar.items[index].title = text;
}

+ (void)tabBarController:(UITabBarController *)tabBarController
                setImage:(UIImage *)image
          forItemAtIndex:(NSUInteger)index
{
    if (index < tabBarController.tabBar.items.count)
        tabBarController.tabBar.items[index].image = image;
}

@end