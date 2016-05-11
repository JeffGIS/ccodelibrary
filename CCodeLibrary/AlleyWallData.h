//  AlleyWallData.h
//  GMMobile

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CCodeLibrary/SQLiteLib.h"

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
      sendToServer:(BOOL)sendToServer
     useUniqueFile:(BOOL)uniqueFile;

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

@end