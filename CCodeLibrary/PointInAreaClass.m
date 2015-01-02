//
//  PointInAreaClass.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 1/1/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import "PointInAreaClass.h"

@implementation PointInAreaClass

- (id)init
{
    self = [super init];
    if (self)
    {
        void * bmData;
        self.context = MyCreateBitmapContext (1024,1024,&bmData);
        self.bitmapData = bmData;
    }
    return self;
}

- (void)dealloc
{
    if (self.bitmapData)
        free (self.bitmapData);
    if (self.context)
        CGContextRelease(self.context);
}

CGContextRef MyCreateBitmapContext (int pixelsWide,
                                    int pixelsHigh, void**bmData)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void * bitmapData=NULL;
    
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide);// 1
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceGray();
    bitmapData = malloc( bitmapByteCount );// 3
    if (bitmapData != NULL)
    {
        context = CGBitmapContextCreate (bitmapData,// 4
                                         pixelsWide,
                                         pixelsHigh,
                                         8,      // bits per component
                                         bitmapBytesPerRow,
                                         colorSpace,0);
        if (context== NULL)
        {
            free (bitmapData);// 5
        }
        CGColorSpaceRelease( colorSpace );// 6
    }
    *bmData = bitmapData;
    return context;// 7
}

- (bool) DPointInArea:(DPOINT *)dPoint
{
    return true;
}
@end
