//  SidewalkData.h
//  CCodeLibrary

@import Foundation;
#import "RampStruct.h"

@interface NVSidewalkPoint : NSObject

@property int pointID, timeComplete, condition;
@property float slopeFront, slopeSide, slopeHeading, crackWidth, width, levelChange;
@property enum obstructions obstruction;
@property (nonatomic, copy) NSString *note;
@property CLLocationCoordinate2D location;

@end

@interface SidewalkData : NSObject

@end
