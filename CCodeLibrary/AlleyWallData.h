//  AlleyWallData.h
//  GMMobile

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SQLiteLib.h"
#import "MathUtil.h"

@interface AlleyWallData : NSObject

@property sqlite3 *database;
@property NSString *sendToServerFile;
@property (atomic) BOOL isOpen;
@property (atomic) int processingID;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property unsigned long long fileSize;
@property (nonatomic) int datasetVersion;

- (BOOL)open;
- (void)close:(BOOL)opened;
- (void)clear;

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer;

- (BOOL)startTransaction;
- (void)commitTransaction;
- (int)getAlleyLineStatus:(NSInteger)refno;

- (void)setAlleyLineStatus:(NSInteger)refno
                        to:(int)status;

- (BOOL)deleteAlleyWallPoint:(NSInteger)refno;

- (BOOL)createNewWall:(NSString*)wallID
             atPoint:(CLLocationCoordinate2D)position
           withHouse:(NSString*)house
           andStreet:(NSString*)street;

- (NSString *)nearestAlleyLine:(CLLocationCoordinate2D *)pt;
- (NSString *)getNextWallForAlley:(NSString *)nearestAlley;
- (BOOL)createNewTable:(BOOL)sendToServer;
- (BOOL)transferExistingTableIntoNewTable:(BOOL)sendToServer;

+ (BOOL)moveAlleyWallPoint:(NSInteger)refno
                        to:(CLLocationCoordinate2D)point;

-(NSString*)getLastInspDateForWall:(NSString*)wallID;

- (NSString *)getCurrentWallData:(NSString *)wallID
forDate:(NSString *)date
                       fieldName:(NSString *)fieldName;
- (BOOL)beginNewSurveyForWall:(NSString *)wallID
fromDate:(NSString *)fromDate
                      newDate:(NSString *)newDate;
+ (BOOL) setLastDataUpdateNum:(int)nextNum;
+ (int)  getLastDataUpdateNum;
+ (BOOL) setLastPictUpdateNum:(int)nextNum;
- (int) getLastPictUpdateNumber;
- (NSString*) outputPictFile:(int)fileNum;
- (int) incrementLastDataFileNum;
+ (int) incrementLastDataFileNumber;
- (int) incrementLastPictFileNum;
+ (int) incrementLastPictFileNumber;
- (BOOL) savePictureData:(int)pictNum
                 wallID:(int)wallID
                 latLon:(LLPOINT)ll
                heading:(int)heading;


@end