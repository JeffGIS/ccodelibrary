//  IntersectionsDatabase.h
//  CCodeLibrary

#import "IntersectionsDatabase.h"
#import "IntersectionPoint.h"
#import "MPIntersection.h"
#import "FTPDataPull.h"
#import <sqlite3.h>
#import "CurbRampData.h"

@class IntersectionsDatabase;

@protocol IntersectionsDatabaseDelegate <NSObject>

- (void)intersectionsDatabase:(NSString *)databasePath
                      didLoad:(NSString *)message
                   withStatus:(int)status;
@end

@interface IntersectionsDatabase : NSObject <FTPDataPullDelegate>

@property (nonatomic, weak) id <IntersectionsDatabaseDelegate> delegate;
@property (nonatomic) int geoid;
@property BOOL gettingUploaded;
@property CurbRampData *curbRampData;
@property FTPDataPull *pull;
@property sqlite3_stmt *statement1;
@property sqlite3_stmt *statement2;

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

- (BOOL)storeIntersection:(MPIntersection*)currentIntersection
               withStatus:(IntersectionStatus)status;

- (BOOL)storeMPIntersectionToDB:(MPIntersection *)mpint
                     withStatus:(IntersectionStatus)status;

- (MPIntersection *) getMPIntersectionFromDB:(int)intID
                                  withRamps:(BOOL)wantRamps;

- (IntersectionPoint *)getFirstIntersectionPointAssignedTo:(int)user
                                                withStatus:(IntersectionStatus)status;

- (BOOL)setIntersectionStatusTo:(IntersectionStatus)status
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
- (void)close:(BOOL)opened;

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
- (int) addNewIntersectionAt:(LLPOINT)pt
                    withName:(NSString*)name;
- (void) setStreetNamesForIntersection:(int)intID
                                   to:(NSString*)newNames;
- (void) deleteIntersection:(int)intID;

@end