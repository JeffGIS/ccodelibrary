//  NVTabBarEdit.m
//  CCodeLibrary

#import "NVTabBarEdit.h"

@implementation NVTabBarEdit

+ (void)tabBarController:(UITabBarController *)tabBarController
       removeItemAtIndex:(NSUInteger)index
                animated:(BOOL)animated
{
    if (index < tabBarController.viewControllers.count)
    {
        NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
        [newTabBarVCs removeObjectAtIndex:index];
        
        [tabBarController setViewControllers:newTabBarVCs
                                    animated:animated];
    }
}

+ (void)tabBarController:(UITabBarController *)tabBarController
replaceViewControllerAtIndex:(NSUInteger)index
      withViewController:(UIViewController *)viewController;
{
    if (index < tabBarController.viewControllers.count)
    {
        NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
        
        [newTabBarVCs replaceObjectAtIndex:index
                                withObject:viewController];
        
        tabBarController.viewControllers = newTabBarVCs;
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