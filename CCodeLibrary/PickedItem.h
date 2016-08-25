//  PickedItem.h
//  GMMobile

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"
#import "DisplayCharacteristics.h"

/*typedef NS_ENUM(NSInteger, PickItemTypes) {
    PTPid,
    PTStormSewerLine,
    PTStormSewerPoint,
    PTStormSewerPlat,
    PTAlleyWallPt,
    PTAlleyLine,
    PTCRIntersectionPt,
    PTCrime,
};*/

@interface PickedItem : NSObject
@property GraphicElementTypes itemType;
@property int symbol;
@property NSInteger refno;
@property double distance;
@property NSString *identifier;
@property NSString *symbolName;
@property NSInteger time;
@property DPOINT pickedPoint;
@property DPOINT screenPoint;

+ (PickedItem *) nearestPickedItem:(NSMutableArray *)highlightList;

@end