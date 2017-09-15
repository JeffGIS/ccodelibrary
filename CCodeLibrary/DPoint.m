//
//  DPoint.m
//  CCodeLibrary
//
//  Created by Bill Munson on 9/15/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import "DPoint.h"

@implementation DPoint

+ (DPoint *) fromDPOINT:(LPDPOINT) dpt
{
    DPoint * dp = DPoint.new;
    dp.x = dpt->x;
    dp.y = dpt->y;
    return dp;
}
@end
