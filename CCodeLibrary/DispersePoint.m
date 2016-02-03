//
//  DispersePoint.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/3/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "DispersePoint.h"

@implementation DispersePoint

- (void) releaseMem
{
    if (_grid)
        free (_grid);
}
- (void)dealloc
{
    [self releaseMem];
}

- (int) gridIndex:(int)row column:(int)col
{
    if (row < 0 || col < 0 || row >= _height || col >= _width)
        return -1;
    int indx = row * _width + col;
    
    return indx;
}

+ (DispersePoint *)initWithWidth:(int)width
                          Height:(int)height
                     andDatabase:(CrimeData*)db
{
    DispersePoint * dp = [[DispersePoint alloc]init];
    dp.cd = db;
    dp.width = width;
    dp.height = height;
    dp.grid = calloc (width*height,sizeof(unsigned short));
    
    [db executeCmd:"CREATE TEMP TABLE DISPERSE (id INT PRIMARY KEY,'ControlNbr' ,SEQUENCE INT, X INT, Y INT, SYMBOL INT);"];
    
    return dp;
}

- (void) addPoint:(DPOINT *)pPoint
      usingSymbol:(PointSymbols)sym
        withColor:(CGColorRef)color
          andSize:(CGFloat)size

{
    int indx = [self gridIndex:pPoint->y column:pPoint->x];
    int seq = _grid[indx]++;
    
}


@end
