//
//  PointInArea.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/1/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"

CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh, CGColorSpaceRef colorSpace, void **bmData);
dbounds getAreaBounds (int nPoints,LPDPOINT pPoints);


@interface PointInArea : NSObject

- (BOOL) loadArea:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)polyPartLen
           points:(LPDPOINT)points
    boundaryWidth:(CGFloat)lineWidth;

- (int)DPointInArea:(DPOINT *)dPoint;

@property int maxDimension;
@property int width;
@property int height;
@property CGColorSpaceRef colorSpace;
@property CGContextRef context;
@property dbounds bounds;
@property LPBYTE bitmapData;


@end
