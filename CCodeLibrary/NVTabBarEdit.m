//  NVTabBarEdit.m
//  CCodeLibrary

#import "NVTabBarEdit.h"

@implementation NVTabBarEdit

+ (void)tabBarController:(UITabBarController *)tabBarController
       removeItemAtIndex:(NSUInteger)index
                animated:(BOOL)animated
{
    NSArray *tabBarVCs = tabBarController.viewControllers;
    NSMutableArray *newTabBarVCs = tabBarVCs.mutableCopy;
    [newTabBarVCs removeObjectAtIndex:index];
    
    [tabBarController setViewControllers:newTabBarVCs
                                animated:animated];
}

+ (void)tabBarController:(UITabBarController *)tabBarController
replaceViewControllerAtIndex:(NSUInteger)index
      withViewController:(UIViewController *)viewController;
{
    NSArray *tabBarVCs = tabBarController.viewControllers;
    NSMutableArray *newTabBarVCs = tabBarVCs.mutableCopy;
    
    [newTabBarVCs replaceObjectAtIndex:index
                            withObject:viewController];
    
    tabBarController.viewControllers = newTabBarVCs;
}

@end