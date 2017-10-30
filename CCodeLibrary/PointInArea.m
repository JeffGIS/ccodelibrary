//  PointInArea.m
//  CCodeLibrary

#import "PointInArea.h"
#import "MathUtil.h"

CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh, CGColorSpaceRef colorSpace, void **bmData)
{
    CGContextRef context = NULL;
    int bitmapByteCount = 0, bitmapBytesPerRow = 0;
    int nc = (int)CGColorSpaceGetNumberOfComponents(colorSpace);
    uint32_t flags = kCGImageAlphaNone;
    BOOL fromPIA = FALSE;
    if (pixelsWide < 0)
    {
        pixelsWide = -pixelsWide;
        fromPIA = TRUE;
    }
    if (nc > 2)
    {
        nc++;
        flags = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        if (fromPIA)
            flags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big;
        else
            //flags = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little;
            flags = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
    }
    bitmapBytesPerRow = nc * pixelsWide;
    bitmapByteCount = (bitmapBytesPerRow *pixelsHigh);
    
    if (bmData)
    {
        *bmData = calloc(bitmapByteCount,1); //3
    
        context = CGBitmapContextCreate(*bmData, pixelsWide, pixelsHigh, 8,
                                    bitmapBytesPerRow, colorSpace,flags);
    }
    else
        context = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8,
                                        bitmapBytesPerRow, colorSpace,flags);

    if (!context && bmData)
    {
        free(*bmData);
    }
    else
    {
        int bi = (int)CGBitmapContextGetBytesPerRow(context);
        if (bi != bitmapBytesPerRow)
            bi=1;
        
        CGContextSetShouldAntialias(context, NO);
    }
    
    
    return context;
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
      polyPartLen:(int*)pPartLen
           points:(LPDPOINT)pPoints
    boundaryWidth:(CGFloat)lineWidth

{
    BOOL rtn = NO;
    void *bmData = NULL;
    
    [self releaseMem];
    if (!pPoints)
        return FALSE;
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
    _height = max (1,_height);
    _width = max (1,_width);
    
    _context = createBitmapContext(-_width, _height, _colorSpace, &bmData);
    _bitmapData = bmData;
    const CGFloat white[2] = {1, 1};
    const CGFloat gray[2] = {0.5, 1};
    CGContextSetAllowsAntialiasing(_context, NO);
    CGContextSetShouldAntialias(_context,NO);
    for (int i = 0; i < nPoints; i++)
    {
        CGPoint pt = [self projectPointToContext:&pPoints[i] from:0];
        
        if (i == 0)
            CGContextMoveToPoint(_context, pt.x, pt.y);
        
        else
            CGContextAddLineToPoint(_context, pt.x, pt.y);
    }
    CGColorRef whiteRef = CGColorCreate(_colorSpace, white);
    CGColorRef grayRef  = CGColorCreate(_colorSpace, gray);
    CGContextSetFillColorWithColor(_context, whiteRef);
    CGContextSetStrokeColorWithColor(_context, grayRef);
    if (!CGContextIsPathEmpty(_context))
    {
        if (lineWidth > 0 && nLoops == 1)
        {
            CGContextSetLineWidth(_context,lineWidth);
            CGContextDrawPath(_context, kCGPathFillStroke);
        }
        else
            CGContextDrawPath(_context, kCGPathFill);
        rtn = YES;
    }
    if (nLoops > 1 && lineWidth > 0)
    {
        int ip = 0;
        //int ii;
        
        for (int loop = 0; loop < nLoops; loop++)
        {
            CGPoint pt = [self projectPointToContext:&pPoints[ip] from:0];
            
            CGContextMoveToPoint(_context, pt.x, pt.y);
            ip++;
            //ii = pPartLen[loop];
            
            for (int i = 1; i < pPartLen[loop]; i++)
            {
                pt = [self projectPointToContext:&pPoints[ip] from:0];
                CGContextAddLineToPoint(_context,  pt.x, pt.y);
                ip++;
            }
            
            if (loop)
                ip++;
            
            if (!CGContextIsPathEmpty(_context))
            {
                CGContextDrawPath(_context, kCGPathStroke);
            }
        }
        
        //ii = ip;
    }
    CGColorRelease(whiteRef);
    CGColorRelease(grayRef);
    
    return rtn;

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


- (int)DPointInArea:(DPOINT *)dPoint
{
    int row=-999;
    int col;
    int bitmapValue;
    static int ii=1;
    CGPoint pt = [self projectPointToContext:dPoint
                                        from:ii];
    
    if (pt.x > -0.5 && pt.x < _width - 0.5 &&
        pt.y > -0.5 && pt.y < _height - 0.5)
    {
        row = (pt.y + 0.5);
        col = (pt.x + 0.5);
        bitmapValue = (unsigned int)_bitmapData[row * _width + col];
        
        if (bitmapValue == 255) //inside
            return 1;
        if (bitmapValue == 128) //on boundary
            return 2;
        if (bitmapValue)
            return 4;
    }
    
    return 0;
}

- (int)screenPointInArea:(DPOINT *)pt
{
    int row=-999;
    int col;
    int bitmapValue;
    
    if (pt->x > -0.5 && pt->x < _width - 0.5 &&
        pt->y > -0.5 && pt->y < _height - 0.5)
    {
        row = (pt->y + 0.5);
        col = (pt->x + 0.5);
        bitmapValue = (unsigned int)_bitmapData[row * _width + col];
        
        if (bitmapValue == 255)
            return 1;
        if (bitmapValue == 128)
            return 2;
        if (bitmapValue)
            return 4;
    }
    
    return 0;
}

@end
