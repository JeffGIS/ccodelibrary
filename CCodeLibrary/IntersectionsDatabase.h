//  IntersectionsDatabase.h
//  CCodeLibrary

#import "IntersectionsDatabase.h"
#import "IntersectionPoint.h"
#import "MPIntersection.h"
#import "FTPDataPull.h"
#import "UIApplication+VersionBuild.h"
#import "SQLiteLib.h"
#import "CurbRampData.h"

@class IntersectionsDatabase;

@protocol IntersectionsDatabaseDelegate <NSObject>

- (void)intersectionsDatabase:(NSString *)databasePath
                      didLoad:(NSString *)message
                   withStatus:(INTDBStatus)status;
@end

@interface IntersectionsDatabase : NSObject <FTPDataPullDelegate>

@property (nonatomic, weak) id <IntersectionsDatabaseDelegate> delegate;
@property (nonatomic) int geoid;
@property BOOL gettingUploaded;
@property (nonatomic) CurbRampData *curbRampData;
@property (nonatomic) FTPDataPull *pull;

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid;

- (BOOL)startTransaction;
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
- (BOOL)storeIntersection:(MPIntersection *)currentIntersection;
- (BOOL)storeMPIntersectionToDB:(MPIntersection *)mpint;

- (MPIntersection *)getMPIntersectionFromDB:(int)intID
                                  withRamps:(BOOL)wantRamps;

- (IntersectionPoint *)getFirstIntersectionPointAssignedTo:(int)user
                                                      type:(NSString *)type
                                                withStatus:(IntersectionStatus)status;

- (BOOL)setIntersectionStatusTo:(IntersectionStatus)status
                forIntersection:(int)intID;

- (BOOL)assignIntersection:(int)intID
                        to:(int)user
                      type:(NSString *)type;

- (BOOL)assignIntersectionsFrom:(int)intID
                             to:(int)endID
                         toUser:(int)user
                           type:(NSString *)type
                         status:(IntersectionStatus)status;


- (BOOL)assignAllIntersectionTo:(int)user
                           type:(NSString *)type;
;
- (BOOL)assignRemainingIntersectionsTo:(int)user
                                  type:(NSString *)type;

- (NSArray *)getAssignments:(NSString*)type;
- (NSArray *)getIntersectionsAssignedTo:(int)iPad
                                 ofType:(NSString*)type
                              andStatus:(IntersectionStatus)status;

- (NSString *)intersectionTextPath:(int)type;
- (int)getCountOfIntersections;
- (void)close:(BOOL)opened;

- (int)loadIntersectionTextToDatabase:(NSString *)path
                         progressView:(GSSiPopoverView *)popover;

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

- (int)addNewIntersectionAt:(LLPOINT)pt
                   withName:(NSString *)name;

- (NSString *)getStreetNamesForIntersection:(int)intID;

- (void)setStreetNamesForIntersection:(int)intID
                                   to:(NSString *)newNames;

- (void)deleteIntersection:(int)intID;
- (int)incrementLastDataFileNum;

@end