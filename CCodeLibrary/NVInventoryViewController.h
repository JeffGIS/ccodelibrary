//  NVInventoryViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "MPIntersection.h"
#import "NVLargeAlertView.h"

@class NVInventoryViewController;

@protocol NVInventoryViewControllerDelegate <NSObject>

- (void)inventoryViewController:(NVInventoryViewController *)controller
                didSetInventory:(MPIntersection *)intersection;

@end

@interface NVInventoryViewController : UIViewController <NVLargeAlertViewDelegate>

@property (nonatomic, weak) id <NVInventoryViewControllerDelegate> delegate;
@property (nonatomic) MPIntersection *currentIntersection;
@property NSInteger from;

+ (NVInventoryViewController *)showInventoryViewControllerForIntersection:(MPIntersection *)intersection
                                                                 delegate:(id)delegate
                                                                     from:(NSInteger)from;

@end