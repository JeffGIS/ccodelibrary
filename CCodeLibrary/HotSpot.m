//
//  HotSpot.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/2/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "HotSpot.h"
#import "MathUtil.h"
#import "CRAPI.h"

@implementation HotSpot
- (void) releaseMem
{
    if (_grid1)
        free (_grid1);
    if (_grid2)
        free (_grid2);
    if (_pointGrid)
        free (_pointGrid);
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
                 PointSize:(int)pointSize
{
    HotSpot * hs = [[HotSpot alloc]init];
    if (pointSize % 2)
        pointSize++;
    hs.nGrids = nGrids;
    hs.width = width;
    hs.height = height;
    hs.grid1 = calloc (width*height,sizeof(int));
    if (nGrids == 2)
        hs.grid2 = calloc (width*height,sizeof(int));
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

- (void) addPointAtX:(int)x andY:(int)y
{
    x -= _pointSize + 1;
    y -= _pointSize + 1;
    for (int row = 0;row < _pointGridSize; row++)
    {
        for (int col = 0;col < _pointGridSize; col++)
        {
            int indx = [self gridIndex:row + y column:col + x];
            if (indx >= 0)
            {
                int pindex = [self pointIndex:row column:col];
                _grid1[indx] += _pointGrid[pindex];
                _maxGridVal = max (_maxGridVal,_grid1[indx]);
            }
        }
       
    }
}

- (void) display:(CGContextRef)context
{
    CGRect rect;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[4] = {1,1,1,1};
    
    colors[3] = 0.75;
    rect.size.width = 1;
    rect.size.height = 1;
    for (int row = 0;row < _height; row++)
    {
        rect.origin.y = row;
        for (int col = 0; col < _width; col++)
        {
            rect.origin.x = col;
            int indx = [self gridIndex:row column:col];
            if (_grid1[indx])
            {
                colors[3] = pow((CGFloat)_grid1[indx],0.5) / pow(_maxGridVal,0.5);
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
- (BOOL) dump:(NSString*)outFile
{
    if (!_maxGridVal)
        return FALSE;
    NSString * filepath = [NSString stringWithFormat:@"%@/%@.bin",CRAPI.sharedInstance.sharedFilePath,outFile];
    FILE *Fid = fopen(filepath.UTF8String,"wb");
    if (Fid == NULL)
        return FALSE;
    BYTE *pgrid = malloc (_width*_height*sizeof(BYTE)+4);
    
    for (int row = 0;row < _height; row++)
    {
        for (int col = 0; col < _width; col++)
        {
            int indx = [self gridIndex:row column:col];
            pgrid[indx] = 32 * _grid1[indx] / _maxGridVal;
        }
    }
    BigWrite(Fid ,&_height ,sizeof(int), -1);
    BigWrite(Fid ,&_width ,sizeof(int), -1);
    BigWrite(Fid ,pgrid ,_width*_height*sizeof(BYTE), -1);
    fclose(Fid);
    //[CRAPI.sharedInstance.docManager exportDocumentFromFilepath:filepath delegate:nil];
    return TRUE;
}
@end
