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
#define FROM_PRELIM 3
#define FROM_PRELIM_MAP 4

@import UIKit;
@import CoreLocation;
#import "MPIntersection.h"
#import "NVAlertView.h"
#import "NVTileCompiler.h"

@class NVInventoryViewController;

@protocol NVInventoryViewControllerDelegate <NSObject>

@optional
- (void)inventoryViewController:(NVInventoryViewController *)controller
           didCompleteInventory:(MPIntersection *)intersection;

- (void)inventoryViewController:(NVInventoryViewController *)controller
           didCancelChanges:(MPIntersection *)intersection;

- (MPIntersection *)inventoryViewController:(NVInventoryViewController *)controller
                            didSetInventory:(MPIntersection *)intersection;

- (MPIntersection *)inventoryViewController:(NVInventoryViewController *)controller
                              didSetComplex:(MPIntersection *)intersection;

- (void)inventoryViewController:(NVInventoryViewController *)controller
     showStreetViewAtCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)inventoryViewController:(NVInventoryViewController *)controller
     showStreetViewAtCoordinate:(CLLocationCoordinate2D)coordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate;

@end

@interface NVInventoryViewController : UIViewController <NVAlertViewDelegate,CLLocationManagerDelegate,NVTileCompilerDelegate>

@property (nonatomic, weak) id <NVInventoryViewControllerDelegate> delegate;
@property NSInteger from;

+ (NVInventoryViewController *)showInventoryViewControllerForIntersection:(MPIntersection *)intersection
                                                                 delegate:(id)delegate
                                                                     from:(NSInteger)from
                                                          draggableTarget:(BOOL)draggableTarget;

@end
