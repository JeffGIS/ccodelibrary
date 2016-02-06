//
//  HotSpot.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/2/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotSpot : NSObject
@property int width;
@property int height;
@property int nGrids;
@property int * grid1;
@property int * grid2;
@property int pointGridSize;
@property int * pointGrid;
@property int pointSize;
@property CGFloat maxGridVal;

+ (HotSpot *)initWithWidth:(int)width
                    Height:(int)height
                  NumGrids:(int)nGrids
                 PointSize:(int)pointSize;
- (void) addPointAtX:(int)x andY:(int)y;
- (void) display:(CGContextRef)context;
- (void) dump:(NSString*)outFile;

@end
