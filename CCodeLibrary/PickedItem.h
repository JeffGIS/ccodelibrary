//  PickedItem.h
//  GMMobile

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"

typedef NS_ENUM(NSInteger, PickItemTypes) {
    PTPid,
    PTStormSewerLine,
    PTStormSewerPoint,
    PTStormSewerPlat,
    PTAlleyWallPt,
    PTAlleyLine,
    PTCRIntersectionPt,
};

@interface PickedItem : NSObject
@property int itemType;
@property int refno;
@property double distance;
@property NSString *identifier;
@property NSString *symbolName;
@property DPOINT pickedPoint;

+ (PickedItem *) nearestPickedItem:(NSMutableArray *)highlightList;

@end