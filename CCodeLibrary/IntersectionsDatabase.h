//  IntersectionsDatabase.h
//  CCodeLibrary

#import "CCodeLibrary.h"
#import <sqlite3.h>

#define INTDB_OK 0
#define INTDB_FAILED 1

#define INT_TEXT_INDEX 1
#define INT_TEXT_DATA 2

#define INT_STATUS_PRELIMCOMPLETE 1
#define INT_STATUS_COMPLEX 2

#define INT_NO_NETWORK_CONNECTION 3
#define INT_NO_UPLOADED_FILE    4

@class IntersectionsDatabase;

@protocol IntersectionsDatabaseDelegate <NSObject>

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
@property BOOL gettingUploaded;
@property BOOL isOpen;
@property NSString *path;
@property sqlite3_stmt *statement;

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid;

- (void)getUploadedIntersectionDatabase:(GSSiPopoverView *)popover;
- (void)getPlaceIntersectionDatabase:(GSSiPopoverView *)popover;
- (NSMutableArray *)getIntersectionPointsFromDatabase;
- (NSMutableArray *)getIntersectionPointsFromDatabaseinBounds:(IBOUNDS)bounds;

- (NSMutableArray *)getIntersectionElementsFromDatabaseinBounds:(IBOUNDS)bounds
                                                      skipIntID:(int)skipID;

- (NSMutableArray *)getIntersectionPointsWithinDistance:(int)meters
                                                ofPoint:(LLPOINT)latlon;

- (IntersectionPoint *)getCurrentIntersectionPoint:(int)intID;

- (NSString *)getCurrentIntersectionAZMs:(int)intID
                                nStreets:(int *)pnStreets;

- (BOOL)setCurrentIntersectionPoint:(IntersectionPoint *)intpt;

- (BOOL)storeMPIntersectionToDB:(MPIntersection *)mpint
                     withStatus:(int)status;

- (MPIntersection*) getMPIntersectionFromDB:(int)intID
                                  withRamps:(BOOL)wantRamps;

- (IntersectionPoint *)getFirstIntersectionPointAssignedTo:(int)user WithStatus:(int)status;

- (BOOL)setIntersectionStatusTo:(int)status
                forIntersection:(int)intID;

- (BOOL)assignIntersection:(int)intID To:(int)user;
- (BOOL)assignAllIntersectionTo:(int)user;
- (NSArray *)getAssignments;

- (NSString *)intersectionTextPath:(int)type;
- (int)getCountOfIntersections;
- (void)close;
- (void)logError;
int SQLOK(int sqlReturn);

- (int)loadIntersectionTextToDatabase:(NSString *)path;

- (int)findIntersection:(int)x
                      y:(int)y
       intersectionText:(char *)intText
               whichInt:(int)iWant
       intersectionAZMs:(char *)intAZMs
             numStreets:(int *)pNumStreets
               numRamps:(int *)pNumRamps
                   intX:(int *)plev21x
                   intY:(int *)plev21y;

- (int)findIntersectionFromID:(int)intID
             intersectionText:(char *)intText
             intersectionAZMs:(char *)intAZMs
                   numStreets:(int *)pNumStreets
                     numRamps:(int *)pNumRamps
                         intX:(int *)plev21x
                         intY:(int *)plev21y;

@end