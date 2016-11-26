//  CurbRampData.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "SQLiteLib.h"
#import "MathUtil.h"

@interface CurbRampData : NSObject
@property sqlite3 *database;
@property (atomic) BOOL isOpen;
@property int geoid;
@property (atomic) int processingID;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property NSInteger fileSize;
@property (nonatomic) int datasetVersion;
@property BOOL transactionActive;

+ (CurbRampData *)databaseForGeoid:(int)geoid
                            create:(BOOL)create;
- (BOOL)open;
- (void)close:(BOOL)opened;
- (void)clear;
- (BOOL)createPriorityLocationsTable:(BOOL)dropExistingTable;
- (BOOL)createIntersectionsTable:(BOOL)dropExistingTables;
- (NSString *)databasePath:(int)geoid;
- (NSString *)databasePath;

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
              from:(int)from;

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

@end
