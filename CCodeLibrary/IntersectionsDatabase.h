//  IntersectionsDatabase.h
//  CCodeLibrary

#import "IntersectionsDatabase.h"
#import "IntersectionPoint.h"
#import "MPIntersection.h"
#import "FTPDataPull.h"
#import <sqlite3.h>

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

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid;

- (void)startTransaction;
- (void)commitTransaction;
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

- (IntersectionPoint *)getFirstIntersectionPointAssignedTo:(int)user
                                                withStatus:(int)status;

- (BOOL)setIntersectionStatusTo:(int)status
                forIntersection:(int)intID;

- (BOOL)assignIntersection:(int)intID
                        to:(int)user;

- (BOOL)assignIntersectionsFrom:(int)intID
                             to:(int)endID
                         toUser:(int)user;

- (BOOL)assignAllIntersectionTo:(int)user;
- (BOOL)assignRemainingIntersectionsTo:(int)user;

- (NSArray *)getAssignments;

- (NSString *)intersectionTextPath:(int)type;
- (int)getCountOfIntersections;
- (void)close;

- (void)logError:(int)sqlReturn
          method:(char *)method;

int SQLOK(int sqlReturn, char *method);

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