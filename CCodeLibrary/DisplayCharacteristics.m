//
//  DisplayCharacteristics.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 11/3/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import "DisplayCharacteristics.h"

@implementation DisplayCharacteristics

-(id) copyWithZone: (NSZone *) zone
{
    DisplayCharacteristics *another = [[DisplayCharacteristics allocWithZone: zone] init];
    
    another.refno = self.refno;
    another.elementType = self.elementType;
    another.dPoint = self.dPoint;
    another.itemBeginTime = self.itemBeginTime;
    another.itemEndTime = self.itemEndTime;
    another.UCR = self.UCR;
    another.sunAngle = self.sunAngle;
    another.pointSymbol = self.pointSymbol;
    another.color = self.color;
    another.size = self.size;
    another.width = self.width;
    another.string1 = self.string1.copy;
    another.string2 = self.string2.copy;
    
    return another;
}


@end
