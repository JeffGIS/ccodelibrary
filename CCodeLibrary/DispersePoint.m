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
    
    [db executeCmd:"DROP TABLE IF EXISTS DISPERSE;CREATE TABLE DISPERSE (id INT,ControlNbr INT,Sequence INT, X INT, Y INT, Symbol INT, Size INT, Color INT);CREATE VIRTUAL TABLE IF NOT EXISTS DISPERSE_index USING rtree(id,minX, maxX, minY, maxY);"];
    dp.nextID = 1;
    return dp;
}

- (BOOL) addPoint:(DPOINT *)pPoint
       controlNbr:(int)cnbr
      usingSymbol:(PointSymbols)sym
        withColor:(CGColorRef)color
          andSize:(CGFloat)size

{
    int indx = [self gridIndex:pPoint->y column:pPoint->x];
    if (indx < 0)
        return FALSE;
    int seq = _grid[indx]++;
    NSString * cmd = [NSString stringWithFormat:@"INSERT INTO DISPERSE VALUES(%i,%i,%i,%i,%i,%i,%f,%lli);INSERT INTO DISPERSE_index VALUES(%i,%f,%f,%f,%f);",_nextID,cnbr,seq,IDNINT(pPoint->x),IDNINT(pPoint->y),(int)sym,size,(long long)color,_nextID,pPoint->x-1,pPoint->x+1,pPoint->y-1,pPoint->y+1];
    [_cd executeCmd:(LPSTR)cmd.UTF8String];
    _nextID++;
    return TRUE;
}


@end
