//  DPoint.m
//  CCodeLibrary

#import "DPoint.h"

@implementation DPoint

+ (DPoint *)fromDPOINT:(LPDPOINT)dpt
{
    DPoint * dp = DPoint.new;
    dp.x = dpt->x;
    dp.y = dpt->y;
    return dp;
}
+ (DPoint *)fromXY:(double)x y:(double)y
{
    DPoint * dp = DPoint.new;
    dp.x = x;
    dp.y = y;
    return dp;
}
- (DPOINT) toDPOINT
{
    DPOINT dp;
    dp.x = _x;
    dp.y = _y;
    return dp;
}
@end
