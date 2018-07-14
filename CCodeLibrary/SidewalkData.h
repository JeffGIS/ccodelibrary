/*//  SidewalkData.h
//  CCodeLibrary

@import Foundation;
#import "RampStruct.h"

@interface NVSidewalkPoint : NSObject

@property int lastUpdate, condition, houseNum;
@property uint pointID;
@property double slopeFront, slopeSide, slopeHeading, crackWidth, width, levelChange;
@property double flare1Slope, flare2Slope;
@property enum obstructions obstruction;
@property SPType type;
@property DCType driveCrossType;
@property SdwkMaterial material;
@property (nonatomic, copy) NSString *note, *street;
@property CLLocationCoordinate2D location;

@end

@interface SidewalkData : NSObject

@property CGFloat zoom;
@property int processingID;

- (BOOL)open;
- (void)close:(BOOL)opened;
- (BOOL)createNextUpdateTable;
- (BOOL)createPictureDatabase;

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
          fromFile:(LPSTR)fromFile
          fromLine:(int)fromLine;

- (BOOL)startTransaction;
- (void)commitTransaction;
- (void)cancelTransaction;
- (NSString *)getSendToServerFile:(int)iPad;

- (int)getLastDataUpdateNumber:(int)iPad
                   lastPictNum:(int *)pictNum;

- (BOOL)setLastDataUpdateNum:(int)lastNum
                     pictNum:(int)pictNum
                     foriPad:(int)iPad;

- (int)getLastPictUpdateNumber:(int)iPad;

- (BOOL)setLastPictUpdateNum:(int)lastNum
                     foriPad:(int)iPad;

- (NSString *)outputDataFile:(int)fileNum
                        iPad:(int)iPad;

- (NSString *)outputPictFile:(int)fileNum
                        iPad:(int)iPad;

+ (int)incrementLastDataFileNumber;
+ (int)incrementLastPictFileNumber;
- (int)incrementLastDataFileNum;
- (int)incrementLastPictFileNum;

- (BOOL)savePictureData:(int)pictNum
               sdwkPtID:(int)sdwkPtID
                   type:(int)type
                 latLon:(LLPOINT)ll
                heading:(int)heading;

- (uint)getNextPictID;
- (BOOL)updateFromFile:(NSString *)file;

- (int)createNewSdwkPointAtLocation:(CLLocationCoordinate2D)location
                          withHouse:(NSString *)house
                          andStreet:(NSString *)street;

- (BOOL)deleteSdwkPoint:(NSInteger)refno;

- (BOOL)moveSdwkPoint:(NSInteger)refno
           toLocation:(CLLocationCoordinate2D)location
            withHouse:(NSString *)house
            andStreet:(NSString *)street;

- (void)updateSdwkPoint:(NVSidewalkPoint *)sdwkPoint;
- (NVSidewalkPoint *)getSdwkPointForRefno:(uint)refno;

- (void)displaySdwkPoint:(CGContextRef)context
               llCorners:(CORNERPOINTS *)latlonCornerPoints
                llBounds:(MNMXCORD *)platlonBounds
              viewBounds:(MNMXCORD *)pvbounds;

- (int)pickSdwkPoint:(LLPOINT)point
       highlightList:(NSMutableArray *)hlist;

@end
*/
