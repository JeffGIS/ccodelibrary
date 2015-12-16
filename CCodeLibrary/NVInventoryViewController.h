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

#define FROM_HOME   1
#define FROM_CORNER 2

#import <UIKit/UIKit.h>
#import "MPIntersection.h"
#import "NVAlertView.h"
#import <CoreLocation/CoreLocation.h>
#import "NVTileCompiler.h"

@class NVInventoryViewController;

@protocol NVInventoryViewControllerDelegate <NSObject>

- (void)inventoryViewController:(NVInventoryViewController *)controller
                didSetInventory:(MPIntersection *)intersection;

@end

@interface NVInventoryViewController : UIViewController <NVAlertViewDelegate,CLLocationManagerDelegate, NVTileCompilerDelegate>

@property (nonatomic, weak) id <NVInventoryViewControllerDelegate> delegate;
@property (nonatomic) MPIntersection *currentIntersection;
@property NSInteger from;

+ (NVInventoryViewController *)showInventoryViewControllerForIntersection:(MPIntersection *)intersection
                                                                 delegate:(id)delegate
                                                                     from:(NSInteger)from
                                                          draggableTarget:(BOOL)draggableTarget;

@end