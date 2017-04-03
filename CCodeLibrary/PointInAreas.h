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
#import "PointInArea.h"

@interface PointInAreas : NSObject

- (BOOL) loadArea:(NSString*)areaID
        numPoints:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)polyPartLen
           points:(LPDPOINT)points
          nCounts:(int)nCount;

- (void) areasLoaded:(PointInAreas*)boundsPias
         convertToLL:(LPTRANDATA)pTran;
- (void)createDisplayColors:(PointInAreas*)piasAdjust
                       mask:(PointInArea*)piaMask;
- (int)DPointInArea:(DPOINT *)dPoint
         whichCount:(int) icount;
- (CGColorRef)colorForArea:(NSString*)areaID;
- (double)countForArea:(NSString*)areaID
            whichCount:(int) icount;

@property NSString * areaType;
@property NSString * adjustValue;
@property int loadPass;
@property int numAreas;
@property int nCounts;
@property NSMutableArray* areaInfo;
@property int maxDimension;
@property int width;
@property int height;
@property int bytesPerRow;
@property int nColorComponents;
@property int nColorBytes;
@property CGColorSpaceRef colorSpace;
@property CGContextRef context;
@property dbounds fullBounds;
@property LPBYTE bitmapData;
@property int borderColor;
@property int iArea;
@property NSInteger numOutside;
@property LPTRANDATA pTranContextToWorld;

@end
