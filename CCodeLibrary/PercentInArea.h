//
//  PercentInArea.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 4/3/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"
#import "PointInArea.h"

@interface PercentInArea : NSObject

- (BOOL) loadArea:(NSString*)areaID
        numPoints:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)polyPartLen
           points:(LPDPOINT)points;
- (void) areasLoaded:(PercentInArea*)boundsPias
         convertToLL:(LPTRANDATA)pTran;
- (void)createDisplayColors:(PercentInArea*)piasAdjust
                       mask:(PointInArea*)piaMask;
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
