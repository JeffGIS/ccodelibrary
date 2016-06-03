//  AlleyWallData.h
//  GMMobile

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SQLiteLib.h"
#import "MathUtil.h"

#define CURRENT_ALLEYWALL_VERSION "1.1"

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
- (BOOL)clear;

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
- (int) getLastDataUpdateNumber:(int)iPad
                    lastPictNum:(int*)pictNum;
- (NSString*) outputDataFile:(int)fileNum
                        iPad:(int)iPad;
+ (BOOL) setLastDataUpdateNum:(int)nextNum;
+ (int)  getLastDataUpdateNum;
- (BOOL) setLastPictUpdateNum:(int)lastNum
                      foriPad:(int)iPad;
- (int) getLastPictUpdateNumber:(int)iPad;
- (NSString*) outputPictFile:(int)fileNum
                        iPad:(int)iPad;
- (int) incrementLastDataFileNum;
+ (int) incrementLastDataFileNumber;
- (int) incrementLastPictFileNum;
+ (int) incrementLastPictFileNumber;
- (BOOL) savePictureData:(int)pictNum
                   wallID:(NSString *)wallID
                    type:(int)type
                  latLon:(LLPOINT)ll
                 heading:(int)heading;

- (NSString *) getNote:(NSString *)wallID
                  type:(int)type;
- (BOOL) addNote:(NSString *)note
    wallID:(NSString *)wallID
            type:(int)type;
- (NSMutableArray*) loadStandardText:(int)type;
- (BOOL) addStandardText:(NSString*)text
                    type:(int)type;
- (BOOL) updateFromFile:(NSString*)file;
- (BOOL) setLastDataUpdateNum:(int)lastNum
                      foriPad:(int)iPad;


@end