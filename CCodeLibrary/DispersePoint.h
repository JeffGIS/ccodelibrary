//
//  DispersePoint.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/3/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathUtil.h"
#import "SymbolDictionary.h"
#import "CrimeData.h"

@interface DispersePoint : NSObject
@property CrimeData* cd;
@property int width;
@property int height;
@property unsigned short * grid;

+ (DispersePoint *)initWithWidth:(int)width
                          Height:(int)height
                     andDatabase:(CrimeData*)db;
- (BOOL) addPoint:(DPOINT *)pPoint
       controlNbr:(int)cnbr
      usingSymbol:(PointSymbols)sym
        withColor:(CGColorRef)color
          andSize:(CGFloat)size;

@end
