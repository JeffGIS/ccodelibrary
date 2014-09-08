//  IntersectionsDatabase.h
//  PedRampInv_Prelim

#import <sqlite3.h>
#import "../../CCodeLibrary/CCodeLibrary/CCodeLibrary.h"

#define INTDB_OK 0
#define INTDB_FAILED 1

@class IntersectionsDatabase;

@protocol IntersectionsDatabaseDelegate  <NSObject>

- (void) intersectionsDatabase:(NSString *)databasePath
                       didLoad:(NSString *)message
                    withStatus:(int)status;

@end

@interface IntersectionsDatabase : NSObject<FTPDataPullDelegate>
{
    sqlite3 *_database;
}

@property (nonatomic, weak) id <IntersectionsDatabaseDelegate> delegate;
@property int geoid;
@property sqlite3_stmt *statement;

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid;

- (void)getPlaceIntersectionDatabase;
- (void)createTableNamed:(NSString *)tableName;
- (NSArray *)getRecordsFromTable:(NSString *)tableName;
- (NSArray *)getIntersectionPointsFromDatabase;

@end