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
    
    [db executeCmd:"DROP TABLE IF EXISTS DISPERSE;CREATE TEMP TABLE DISPERSE (ControlNbr INT,Sequence INT, X INT, Y INT, Symbol INT, Size INT, Color INT);"];
    
    return dp;
}

- (void) addPoint:(DPOINT *)pPoint
       controlNbr:(int)cnbr
      usingSymbol:(PointSymbols)sym
        withColor:(CGColorRef)color
          andSize:(CGFloat)size

{
    int indx = [self gridIndex:pPoint->y column:pPoint->x];
    int seq = _grid[indx]++;
    NSString * cmd = [NSString stringWithFormat:@"INSERT INTO DISPERSE VALUES(%i,%i,%i,%i,%i,%f,%lli);",cnbr,seq,IDNINT(pPoint->x),IDNINT(pPoint->y),(int)sym,size,(long long)color];
    [_cd executeCmd:(LPSTR)cmd.UTF8String];
}


@end
