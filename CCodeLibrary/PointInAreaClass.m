//  PointInAreaClass.m
//  CCodeLibrary

#import "PointInAreaClass.h"

@implementation PointInAreaClass

- (id)init
{
    self = [super init];
    
    if (self)
    {
        void *bmData;
        _context = MyCreateBitmapContext(1024, 1024, &bmData);
        _bitmapData = bmData;
    }
    
    return self;
}

- (void)dealloc
{
    if (_bitmapData)
        free (_bitmapData);
    
    if (_context)
        CGContextRelease(_context);
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh, void **bmData)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData = NULL;
    int bitmapByteCount, bitmapBytesPerRow;
    
    bitmapBytesPerRow = (pixelsWide); //1
    bitmapByteCount = (bitmapBytesPerRow *pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceGray();
    bitmapData = malloc(bitmapByteCount); //3
    
    if (bitmapData)
    {
        context = CGBitmapContextCreate(bitmapData, //4
                                        pixelsWide,
                                        pixelsHigh,
                                        8, //bits per component
                                        bitmapBytesPerRow,
                                        colorSpace,0);
        if (!context)
            free (bitmapData); //5
        
        CGColorSpaceRelease(colorSpace); //6
    }
    
    *bmData = bitmapData;
    return context; //7
}

- (BOOL)DPointInArea:(DPOINT *)dPoint
{
    return YES;
}

@end