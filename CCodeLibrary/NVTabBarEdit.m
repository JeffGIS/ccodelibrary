//  NVTabBarEdit.m
//  CCodeLibrary

#import "NVTabBarEdit.h"

@implementation NVTabBarEdit

+ (void)tabBarController:(UITabBarController *)tabBarController
removeViewControllerWithID:(NSString *)ID
{
    if (!tabBarController || !ID)
        return;
    
    NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
    for (UIViewController *vcs in newTabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:ID])
        {
            [newTabBarVCs removeObject:vcs];
            break;
        }
    }
    
    [tabBarController setViewControllers:newTabBarVCs.copy
                                animated:NO];
}

+ (void)tabBarController:(UITabBarController *)tabBarController
replaceViewControllerWithID:(NSString *)ID
      withViewController:(UIViewController *)viewController
{
    if (!tabBarController || !ID || !viewController)
        return;
    
    NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
        
    for (UIViewController *vcs in newTabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:ID])
        {
            [newTabBarVCs replaceObjectAtIndex:[newTabBarVCs indexOfObject:vcs]
                                    withObject:viewController];
            
            break;
        }
    }
    
        tabBarController.viewControllers = newTabBarVCs.copy;
}

+ (void)tabBarController:(UITabBarController *)tabBarController
    insertViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index
{
    if (!tabBarController || !viewController ||
        (index > tabBarController.viewControllers.count))
        return;
    
    NSMutableArray *newTabBarVCs = tabBarController.viewControllers.mutableCopy;
    
    for (UIViewController *vcs in newTabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:viewController.restorationIdentifier])
            return;
    }
    
    [newTabBarVCs insertObject:viewController
                       atIndex:index];
    
    [tabBarController setViewControllers:newTabBarVCs.copy
                                animated:NO];
}

+ (void)tabBarController:(UITabBarController *)tabBarController
                 setText:(NSString *)text
 forViewControllerWithID:(NSString *)ID
{
    if (!tabBarController || !text || !ID)
        return;
    
    NSArray *tabBarVCs = tabBarController.viewControllers;
    
    for (UIViewController *vcs in tabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:ID])
        {
            NSUInteger index = [tabBarVCs indexOfObject:vcs];
            tabBarController.tabBar.items[index].title = text;
            break;
        }
    }
}

+ (void)tabBarController:(UITabBarController *)tabBarController
                setImage:(UIImage *)image
 forViewControllerWithID:(NSString *)ID
{
    if (!tabBarController || !image || !ID)
        return;
    
    NSArray *tabBarVCs = tabBarController.viewControllers;
    
    for (UIViewController *vcs in tabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:ID])
        {
            NSUInteger index = [tabBarVCs indexOfObject:vcs];
            tabBarController.tabBar.items[index].image = image;
            break;
        }
    }
}

+ (UIViewController *)viewControllerWithID:(NSString *)ID
                        inTabBarController:(UITabBarController *)tabBarController
                                     index:(NSUInteger *)index
{
    UIViewController *viewController = nil;
    
    if (!tabBarController || !ID)
        return nil;
    
    NSArray *tabBarVCs = tabBarController.viewControllers;
    
    for (UIViewController *vcs in tabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:ID])
        {
            viewController = vcs;
            *index = [tabBarVCs indexOfObject:vcs];
            break;
        }
    }
    
    return viewController;
}

+ (NSInteger)indexOfViewControllerWithID:(NSString *)ID
                      inTabBarController:(UITabBarController *)tabBarController
{
    NSInteger index = -1;
    
    if (!tabBarController || !ID)
        return -1;
    
    NSArray *tabBarVCs = tabBarController.viewControllers;
    
    for (UIViewController *vcs in tabBarVCs)
    {
        if ([vcs.restorationIdentifier isEqualToString:ID])
        {
            index = [tabBarVCs indexOfObject:vcs];
            break;
        }
    }
    
    return index;
}

@end