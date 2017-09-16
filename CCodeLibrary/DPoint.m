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

@end
