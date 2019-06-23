//  DPoint.h
//  CCodeLibrary
#ifndef DPoint_h
#define DPoint_h

@import Foundation;
#import "CCodeTypes.h"

@interface DPoint : NSObject

+ (DPoint *)fromDPOINT:(LPDPOINT)dpt;
+ (DPoint *)fromXY:(double)x y:(double)y;
- (DPOINT) toDPOINT;

@property double x;
@property double y;

@end
#endif
