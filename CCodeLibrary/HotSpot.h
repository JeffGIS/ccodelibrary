//
//  HotSpot.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/2/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathUtil.h"
#import "GSSiEnums.h"

@interface HotSpot : NSObject
@property int width;
@property int height;
@property int nGrids;
@property int ** grids;
@property int * times;
@property int * counts;
@property int nTimes;
@property int pointGridSize;
@property int * pointGrid;
@property int pointSize;
@property CGFloat maxGridVal;

+ (HotSpot *)initWithWidth:(int)width
                    Height:(int)height
                  NumGrids:(int)nGrids
                 timeArray:(NSArray*)times
                 PointSize:(int)pointSize
                      tran:(LPTRANDATA)pTranLLtoView;
- (void) addPointAtX:(int)x andY:(int)y
             andTime:(int)time
           whichGrid:(int)igrid;

- (void) display:(CGContextRef)context
   compareFactor:(double*)compareFactor;
- (BOOL) dump:(NSString*)outFile;

@end
