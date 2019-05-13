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
@property NSString *data;
@property NSInteger time;
@property NSInteger nLinks;
@property DPOINT pickedPoint;
@property DPOINT screenPoint;
@property MNMXCORD llbounds;

+ (PickedItem *) nearestPickedItem:(NSMutableArray *)highlightList;

@end
