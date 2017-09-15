//
//  DPoint.h
//  CCodeLibrary
//
//  Created by Bill Munson on 9/15/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCodeTypes.h"
@interface DPoint : NSObject

+ (DPoint *) fromDPOINT:(LPDPOINT) dpt;

@property double x;
@property double y;

@end
