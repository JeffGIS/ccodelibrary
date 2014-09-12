//  IntersectionsDatabase.h
//  PedRampInv_Prelim

#import <sqlite3.h>
#import "CCodeLibrary.h"

#define INTDB_OK 0
#define INTDB_FAILED 1
#define INT_TEXT_INDEX 1
#define INT_TEXT_DATA 2

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
- (NSMutableArray *)getIntersectionPointsFromDatabase;
- (NSMutableArray *)getCurrentIntersectionPoint:(int)intID;
- (NSString *)intersectionTextPath:(int)type;
- (void)logError;
void SQLOK (int sqlReturn);

- (int)loadIntersectionTextToDatabase:(NSString *)path;

@end