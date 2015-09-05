//
//  PointInArea.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/1/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import "PointInArea.h"
#import "MathUtil.h"

CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh, CGColorSpaceRef colorSpace, void **bmData);

@implementation PointInArea

- (void) releaseMem
{
    if (_bitmapData)
        free (_bitmapData);
    
    if (_context)
        CGContextRelease(_context);
    
    CGColorSpaceRelease(_colorSpace);

}
- (void)dealloc
{
    [self releaseMem];
}

- (BOOL) loadArea:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)pnPointsInLoop
           points:(LPDPOINT)pPoints
{
    BOOL rtn = NO;
    void *bmData = NULL;
    
    [self releaseMem];

    _bounds = getAreaBounds (nPoints,pPoints);
    _colorSpace = CGColorSpaceCreateDeviceGray();
    if (!_maxDimension)
        _maxDimension = 2048;
    _width = _maxDimension;
    _height = _maxDimension;
    CGFloat wb = BoundsWidth (&_bounds);
    CGFloat hb = BoundsHeight (&_bounds);
    
    if (wb > 0 && wb > hb)
        _height *= hb / wb;
    else if (hb > 0)
        _width *= wb / hb;
    _height += _height % 4;
    _width += _width % 4;
    _context = createBitmapContext(_width, _height, _colorSpace, &bmData);
    _bitmapData = bmData;
    CGContextSetAllowsAntialiasing(_context, NO);
    
    for (int i = 0; i < nPoints; i++)
    {
        CGPoint pt = [self projectPointToContext:&pPoints[i] from:0];
        
        if (i == 0)
            CGContextMoveToPoint(_context, pt.x, pt.y);
        
        else
            CGContextAddLineToPoint(_context, pt.x, pt.y);
    }
    
    if (!CGContextIsPathEmpty(_context))
    {
        const CGFloat white[2] = {1, 1};
        
        CGColorRef whiteRef = CGColorCreate(_colorSpace, white);
        CGContextSetFillColorWithColor(_context, whiteRef);
        CGContextDrawPath(_context, kCGPathFill);
        CGColorRelease(whiteRef);
        rtn = YES;
    }
    
    return rtn;

}

dbounds getAreaBounds (int nPoints,LPDPOINT pPoints)
{
    dbounds bounds;
    
    InitDBounds(&bounds);
    for (int i=0;i<nPoints;i++)
    {
        AddDPointToBounds(&bounds, &pPoints[i]);
    }
    return bounds;
}

- (CGPoint)projectPointToContext:(LPDPOINT)Point
                            from:(int)from
{
    CGPoint pt = CGPointZero;
    
    pt.x = Point->x - _bounds.xmn;
    pt.x /= (_bounds.xmx - _bounds.xmn);
    
    if (from)
        pt.y = Point->y - _bounds.ymn;
    
    else
        pt.y = _bounds.ymx - Point->y;
    
    pt.y /= (_bounds.ymx - _bounds.ymn);
    pt.x *= _width;
    pt.y *= _height;
    return pt;
}


- (BOOL)DPointInArea:(DPOINT *)dPoint
{
    
    CGPoint pt = [self projectPointToContext:dPoint
                                        from:1];
    
    if (pt.x > -0.5 && pt.x < _width - 0.5 &&
        pt.y > -0.5 && pt.y < _height - 0.5)
    {
        int row = (pt.y + 0.5);
        int col = (pt.x + 0.5);
        BYTE bitmapValue = _bitmapData[row * _width + col];
        
        if (bitmapValue)
            return true;
    }
    
    return NO;
}

@end
