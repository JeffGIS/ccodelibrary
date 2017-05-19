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
#import "SQLiteLib.h"
#import "GSSiEnums.h"

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
                       mask:(PointInArea*)piaMask
                wantOverdue:(AdjustCrimeOptions)wantOverdue;

- (int)DPointInArea:(DPOINT *)dPoint
             atTime:(int)itime
           andRefno:(int)refno
         whichCount:(int) icount;
- (CGColorRef)colorForArea:(NSString*)areaID;
- (double)countForArea:(NSString*)areaID
            whichCount:(int) icount;
- (NSString *) overdueTextForArea:(NSString *)areaID;
- (BOOL) initTimeLine:(sqlite3 *) db;
- (NSArray *) getAreaTimeline:(NSString*) areaName;
- (NSArray *) getAreaPointRefs:(NSString *)areaName;
- (MNMXCORD) bitmapBounds:(MNMXCORD*) viewBounds;

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
@property LPTRANDATA pTranContextToWorld, pTranWorldToContext;
@property BOOL haveTimeLineDB;
@property int timeLineID;
@property sqlite3 *database;
@property (nonatomic) NSString * path;
@property BOOL isOpen;
@property int minTime;
@property AdjustCrimeOptions overdueOption;
@property int currentTime, timeRange;
@property double compareFactor;
@property int pointGridSize;
@property float * pointGrid;
@property double midxy;
@property double imageFactor;
@property (nonatomic) double pointSize;
@property int totPoints;

@end
