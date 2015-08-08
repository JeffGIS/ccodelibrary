//  NVInventoryViewController.h
//  CCodeLibrary

typedef NS_ENUM(NSInteger, NVUpdateOption)
{
    NVUpdateOptionNone,
    NVUpdateOptionEdit,
    NVUpdateOptionAddRamp,
    NVUpdateOptionAddXWalk,
    NVUpdateOptionAddSignal,
    NVUpdateOptionMove,
};

#import <UIKit/UIKit.h>
#import "MPIntersection.h"
#import "NVLargeAlertView.h"
#import <CoreLocation/CoreLocation.h>

@class NVInventoryViewController;

@protocol NVInventoryViewControllerDelegate <NSObject>

- (void)inventoryViewController:(NVInventoryViewController *)controller
                didSetInventory:(MPIntersection *)intersection;

@end

@interface NVInventoryViewController : UIViewController <NVLargeAlertViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak) id <NVInventoryViewControllerDelegate> delegate;
@property (nonatomic) MPIntersection *currentIntersection;
@property NSInteger from;

+ (NVInventoryViewController *)showInventoryViewControllerForIntersection:(MPIntersection *)intersection
                                                                 delegate:(id)delegate
                                                                     from:(NSInteger)from;

@end