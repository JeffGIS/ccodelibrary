//
//  HotSpot.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/2/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "HotSpot.h"
#import "CRAPI.h"
#import "shr.h"

@implementation HotSpot
- (void) releaseMem
{
    for (int igrid = 0;igrid < _nGrids;igrid++)
    {
        int * grid = _grids[igrid];
        free (grid);
    }
    if (_pointGrid)
        free (_pointGrid);
    if (_times)
        free (_times);
    if (_counts)
        free (_counts);
}
- (void)dealloc
{
    [self releaseMem];
}

- (int) pointIndex:(int)row column:(int)col
{
    int indx = row * _pointGridSize + col;
    
    return indx;
}

- (int) gridIndex:(int)row column:(int)col
{
    if (row < 0 || col < 0 || row >= _height || col >= _width)
        return -1;
    int indx = row * _width + col;
    
    return indx;
}

+ (HotSpot *)initWithWidth:(int)width
                    Height:(int)height
                  NumGrids:(int)nGrids
                 timeArray:(NSArray<NSNumber *>* )times
                 PointSize:(int)pointSize
                      tran:(LPTRANDATA)pTranLLtoView
{
    HotSpot * hs = [[HotSpot alloc]init];
    if (pointSize % 2)
        pointSize++;
    hs.nGrids = nGrids;
    hs.width = width;
    hs.height = height;
    hs.counts = calloc (nGrids,sizeof (int));
    hs.grids = malloc (nGrids * sizeof (int *));
    for (int igrid = 0; igrid < nGrids;igrid++)
    {
        unsigned long len = (long)width * (long)height;
        hs.grids[igrid] = calloc((unsigned long)len,sizeof(int));
    }
    if (times)
    {
        hs.nTimes = (int)times.count;
        hs.times = malloc (hs.nTimes * sizeof(int));
        for (int i = 0;i<hs.nTimes;i++)
            hs.times[i] = (int)times[i].integerValue;
    }
    hs.pointGridSize = pointSize + 1;
    hs.pointGrid = calloc (hs.pointGridSize*hs.pointGridSize,sizeof(int));
    hs.pointSize = pointSize;
    int midxy = pointSize / 2;
    for (int row = 0;row < hs.pointGridSize; row++)
    {
        for (int col = 0; col < hs.pointGridSize; col++)
        {
            int indx = [hs pointIndex:row column:col];
            int ival = midxy - iDist(col,row,midxy,midxy);
            if (ival > 0)
                hs.pointGrid[indx] = ival;
        }
    }
    return hs;
}

-(int) selectGridFromTime:(int)time
{
    if (_nGrids < 2)
        return 0;
    for (int iGrid = 0; iGrid<_nGrids;iGrid++)
    {
        if (time >= _times[iGrid] && time < _times[iGrid+1])
            return iGrid;
    }
    return -1;
}

- (void) addPointAtX:(int)x andY:(int)y
             andTime:(int)time
          whichGrid:(int)igrid

{
//    int igrid = [self selectGridFromTime:time];
    if (igrid < 0 || igrid >= _nGrids)
        return;
    int * grid = _grids[igrid];
    _counts[igrid]++;
    x -= _pointSize/2 + 1;
    y -= _pointSize/2 + 1;
    for (int row = 0;row < _pointGridSize; row++)
    {
        for (int col = 0;col < _pointGridSize; col++)
        {
            int indx = [self gridIndex:row + y column:col + x];
            if (indx >= 0)
            {
                int pindex = [self pointIndex:row column:col];
                grid[indx] += _pointGrid[pindex];
                _maxGridVal = max (_maxGridVal,grid[indx]);
            }
        }
       
    }
}

- (void) display:(CGContextRef)context
   compareFactor:(double*)compareFactor
{
    CGRect rect;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[4] = {1,1,1,1};
    
    colors[0] = 1;
    rect.size.width = 1;
    rect.size.height = 1;
    if (_nGrids == 1 || !_counts[1])
    {
        int * grid = _grids[0];
        for (int row = 0;row < _height; row++)
        {
            rect.origin.y = row;
            for (int col = 0; col < _width; col++)
            {
                rect.origin.x = col;
                int indx = [self gridIndex:row column:col];
                if (grid[indx])
                {
                    colors[3] = pow((CGFloat)grid[indx],0.5) / pow(_maxGridVal,0.5);
                    //                colors[3] = log10((CGFloat)_grid1[indx]) / log10(_maxGridVal);
                    //                colors[3] = log((CGFloat)_grid1[indx]) / log(_maxGridVal);
                    colors[1] = colors[2] = 1.0 - colors[3];
                    CGColorRef color = CGColorCreate(colorspace,colors);
                    CGContextSetFillColorWithColor(context,color);
                    CGContextFillRect (context,rect);
                    CGColorRelease (color);
                }
            }
        }
    }
    else
    {
        double maxValue = 0;
        double factor = (double)_counts[0]/(double)_counts[1];
        if (compareFactor)
        {
            factor = *compareFactor;
        }
        int * grid1 = _grids[0];
        int * grid2 = _grids[1];
        for (int row = 0;row < _height; row++)
        {
            for (int col = 0; col < _width; col++)
            {
                int indx = [self gridIndex:row column:col];
                double value = (double)(grid2[indx] * factor) - (double)grid1[indx];
                maxValue = max (maxValue,fabs(value));
            }
        }
        for (int row = 0;row < _height; row++)
        {
            rect.origin.y = row;
            for (int col = 0; col < _width; col++)
            {
                rect.origin.x = col;
                int indx = [self gridIndex:row column:col];
                double value = (double)(grid2[indx] * factor) - (double)grid1[indx];
                if (value > 0)
                {
                    colors[0] = 1;
                    colors[3] = pow(value,0.5) / pow(maxValue,0.5);
                    colors[1] = colors[2] = 1.0 - colors[3];
                    CGColorRef color = CGColorCreate(colorspace,colors);
                    CGContextSetFillColorWithColor(context,color);
                    CGContextFillRect (context,rect);
                    CGColorRelease (color);
                }
                else if (value < 0)
                {
                    colors[2] = 1;
                    colors[3] = pow(-value,0.5) / pow(maxValue,0.5);
                    colors[0] = colors[1] = 1.0 - colors[3];
                    CGColorRef color = CGColorCreate(colorspace,colors);
                    CGContextSetFillColorWithColor(context,color);
                    CGContextFillRect (context,rect);
                    CGColorRelease (color);
                }
            }
        }
        
    }
    CGColorSpaceRelease(colorspace);
}

- (Bool)dump:(NSString *)outFile
{
    int igrid = 0;
    int * grid = _grids[igrid];
    if (!_maxGridVal)
        return FALSE;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.bin",
                          CRAPI.sharedInstance.sharedFilePath, outFile];
    
    FILE *Fid = fopen(filePath.UTF8String,"wb");
    
    if (Fid == NULL)
        return FALSE;
    
    BYTE *pgrid = malloc ((_width * _height) * sizeof(BYTE) + 4);
    
    for (int row = 0; row < _height; row++)
    {
        for (int col = 0; col < _width; col++)
        {
            int indx = [self gridIndex:row
                                column:col];
            
            pgrid[indx] = (32 * grid[indx] / _maxGridVal);
        }
    }
    
    BigWriteF(Fid, (LPBYTE)&_height, sizeof(int), -1);
    BigWriteF(Fid, (LPBYTE)&_width, sizeof(int), -1);
    BigWriteF(Fid, pgrid, (_width * _height) * sizeof(BYTE), -1);
    fclose(Fid);
    
    /*[CRAPI.sharedInstance.docManager exportDocumentFromFilePath:filePath
                                                       delegate:nil
                                                 deleteWhenDone:NO];*/
    
    return TRUE;
}

@end
