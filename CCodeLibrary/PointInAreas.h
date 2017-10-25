//  PointInAreas.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"
#import "PointInArea.h"
#import "SQLiteLib.h"
#import "GSSiEnums.h"
#import "DisplayCharacteristics.h"

#pragma pack(1)
typedef struct {CGFloat c1,c2,c3,c4;} COLORDEF;
#pragma pack()

@interface AreaData : NSObject
@property int areaNumber;
@property NSString * areaID;
@property COLORDEF colordef;
@property int icolor;
@property double count, count1, count2;
@property int nCounts;
@property double areaInPixels;
@property int pixelsInMask;
@property float pctInMask;
@property double value;
@property double valuePerPixel;
@property int maxTime;
@property double aveHoursBetweenIncident;
@property CGColorRef displayColor;
@property double * yearCounts;
@property double * monthCounts;
@property double * dowCounts;
@property double * hourCounts;

@end

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
    displayCharacteristics:(DisplayCharacteristics *)dc
            andRefno:(int)refno
         whichCount:(int) icount
              value:(double)val;
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
@property int processingID;
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
@property int numYears;

@end
