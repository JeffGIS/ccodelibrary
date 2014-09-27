//  IntersectionsDatabase.h
//  PedRampInv_Prelim

#import "CCodeLibrary.h"
#import <sqlite3.h>

#define INTDB_OK 0
#define INTDB_FAILED 1
#define INT_TEXT_INDEX 1
#define INT_TEXT_DATA 2
#define INT_STATUS_PRELIMCOMPLETE 1

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

- (void)getPlaceIntersectionDatabase:(GSSiPopoverView*)popover;
- (NSMutableArray *)getIntersectionPointsFromDatabase;
- (NSMutableArray *)getIntersectionPointsFromDatabaseinBounds:(IBOUNDS)bounds;
- (IntersectionPoint *)getCurrentIntersectionPoint:(int)intID;
- (BOOL)setCurrentIntersectionPoint:(IntersectionPoint *)intpt;
- (IntersectionPoint *)getFirstAssignedIntersectionPointWithStatus0;
- (BOOL)setIntersectionStatusTo:(int)status forIntersection:(int)intID;
- (NSString *)intersectionTextPath:(int)type;
- (int)getCountOfIntersections;
- (void)close;
- (void)logError;
void SQLOK (int sqlReturn);

- (int)loadIntersectionTextToDatabase:(NSString *)path;

@end