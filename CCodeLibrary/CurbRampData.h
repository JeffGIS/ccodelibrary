//  CurbRampData.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "SQLiteLib.h"
#import "MathUtil.h"
#import "RampStruct.h"

@interface NVSidewalkPoint : NSObject

@property int lastUpdate, condition, houseNum;
@property int fromIntersection, toIntersection;
@property SideOfStreet sideOfStreet;
@property int steps;
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


@interface CurbRampData : NSObject
@property sqlite3nv *database;
@property (atomic) BOOL isOpen;
@property int geoid;
@property (atomic) int processingID;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property NSInteger fileSize;
@property (nonatomic) int datasetVersion;
@property BOOL transactionActive;

+ (BOOL)saveCalibration;

+ (CurbRampData *)databaseForGeoid:(int)geoid
                            create:(BOOL)create;
+ (BOOL)deleteAllPhotos;
- (BOOL)open;
- (void)close:(BOOL)opened;
- (void)clear;
- (BOOL)createPriorityLocationsTable:(BOOL)dropExistingTable;
- (BOOL)createIntersectionsTable:(BOOL)dropExistingTables;
- (NSString *)databasePath:(int)geoid;
- (NSString *)databasePath;

- (BOOL)executeCmd:(LPCSTR)cmd
      sendToServer:(BOOL)sendToServer
          fromFile:(LPSTR)fromFile
          fromLine:(int)fromLine;

- (BOOL)startTransaction;
- (void)commitTransaction;
- (BOOL)isCurrentVersion;

- (int)getLastDataUpdateNumber:(int)iPad
                   lastPictNum:(int *)pictNum;

- (NSString *)outputDataFile:(int)fileNum
                        iPad:(int)iPad;

+ (BOOL)setLastDataUpdateNum:(int)nextNum;
+ (int)getLastDataUpdateNum;

- (BOOL)setLastPictUpdateNum:(int)lastNum
                     foriPad:(int)iPad;

- (int)getLastPictUpdateNumber:(int)iPad;

- (NSString *)outputPictFile:(int)fileNum
                        iPad:(int)iPad;

- (int)incrementLastDataFileNum;
+ (int)incrementLastDataFileNumber;
- (int)incrementLastPictFileNum;
+ (int)incrementLastPictFileNumber;

- (BOOL)savePictureData:(int)pictNum
                  intID:(int)wallID
                rampNum:(int)ramp
                   type:(int)type
                 latLon:(LLPOINT)ll
                heading:(int)heading;

- (NSString *)getNote:(int)intID
               corner:(int)corner
                 ramp:(int)ramp
                 type:(int)type;

- (BOOL)addNote:(NSString *)note
   intersection:(int)intID
         corner:(int)corner
           ramp:(int)ramp
           type:(int)type;

- (NSMutableArray *)loadStandardText:(int)type;

- (BOOL)addStandardText:(NSString *)text
                    type:(int)type;

- (BOOL)updateFromFile:(NSString *)file;

- (BOOL)setLastDataUpdateNum:(int)lastNum
                     foriPad:(int)iPad;

- (BOOL) setLastDataUpdateNum:(int)lastNum
                      pictNum:(int)pictNum
                      foriPad:(int)iPad;

- (int)createNewSdwkPointAtLocation:(CLLocationCoordinate2D)location
                             onSide:(SideOfStreet)sideOfStreet
                         withHouse:(NSString *)house
                          andStreet:(NSString *)street;

- (BOOL)deleteSdwkPoint:(NSInteger)refno;
- (BOOL)removeSdwkPoint:(NSInteger)refno;

- (void)updateSdwkPoint:(NVSidewalkPoint *)sdwkPoint;
- (NVSidewalkPoint *)getSdwkPointForRefno:(uint)refno;
- (BOOL)moveSdwkPoint:(NSInteger)refno
           toLocation:(CLLocationCoordinate2D)location
            withHouse:(NSString *)house
            andStreet:(NSString *)street;
- (BOOL) createSidewalkTables:(BOOL)forceDelete;
+ (BOOL) clearSidewalkTables;
- (BOOL) setSidewalkToIntersection:(int) intID
                      beginingWith:(long) sideWalkID;


@end
