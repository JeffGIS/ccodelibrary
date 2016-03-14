//
//  PointInAreas.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 1/1/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"

@interface PointInAreas : NSObject

- (BOOL) loadArea:(NSString*)areaID
        numPoints:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)polyPartLen
           points:(LPDPOINT)points;
- (void) areasLoaded;
- (void)createDisplayColors;
- (int)DPointInArea:(DPOINT *)dPoint;
- (CGColorRef)colorForArea:(NSString*)areaID;
- (double)countForArea:(NSString*)areaID;

@property NSString * areaType;
@property NSString * adjustValue;
@property int loadPass;
@property int numAreas;
@property NSMutableArray* areaInfo;
@property int maxDimension;
@property int width;
@property int height;
@property CGColorSpaceRef colorSpace;
@property CGContextRef context;
@property dbounds fullBounds;
@property LPBYTE bitmapData;
@property int borderColor;
@property int iArea;
@property NSInteger numOutside;
@end
