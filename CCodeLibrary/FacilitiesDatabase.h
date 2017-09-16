//  FacilitiesDatabase.h
//  CCodeLibrary

#import "Facility.h"
#import "FacilityPoint.h"
#import "SQLiteLib.h"
#import "FTPDataPull.h"
#import "DPoint.h"

@import Foundation;

#define FACDB_OK 0
#define FACDB_FAILED 1

#define FAC_TEXT_INDEX 1
#define FAC_TEXT_DATA 2

#define FAC_STATUS_PRELIMCOMPLETE 1
#define FAC_STATUS_COMPLEX 2

#define FAC_NO_NETWORK_CONNECTION 3
#define FAC_NO_UPLOADED_FILE 4

@class FacilitiesDatabase;

@protocol FacilitiesDatabaseDelegate <NSObject>

- (void)facilitiesDatabase:(NSString *)databasePath
                   didLoad:(NSString *)message
                withStatus:(int)status;

@end

@interface FacilitiesDatabase : NSObject<FTPDataPullDelegate>

@property (nonatomic, weak) id <FacilitiesDatabaseDelegate> delegate;
@property int geoid;
@property BOOL gettingUploaded;
@property BOOL isOpen;
@property NSString *path;
@property sqlite3_stmt *statement;
@property sqlite3 * database;

+ (FacilitiesDatabase *)databaseForGeoid:(int)geoid;

- (void)getFacilitiesDatabase:(GSSiPopoverView *)popover;
- (NSMutableArray *)getFacilityPointsFromDatabase;
- (NSMutableArray *)getFacilityPointsFromDatabaseinBounds:(IBOUNDS)bounds;
- (void)createFacilitiesTable;

- (NSMutableArray *)getFacilityPointsWithinDistance:(int)meters
                                            ofPoint:(LLPOINT)latlon;

- (FacilityPoint *)getCurrentFacilityPoint:(int)intID;

- (NSString *)getCurrentFacilityAZMs:(int)intID
                            nStreets:(int *)pnStreets;

- (BOOL)setCurrentFacilityPoint:(FacilityPoint *)intpt;

- (BOOL)storeFacilityToDB:(Facility *)fac
               withStatus:(int)status;

- (Facility *)getFacilityFromDB:(int)intID
                      withRamps:(BOOL)wantRamps;

- (FacilityPoint *)getFirstAssignedFacilityPointWithStatus0;

- (BOOL)setFacilityStatusTo:(int)status
                forFacility:(int)facID;

- (BOOL)assignFacility:(int)facID
                    to:(int)user;

- (NSString *)facilityTextPath:(int)type;
- (int)loadFacilityTextToDatabase:(NSString *)path;
- (int)getCountOfFacilities;

- (NSArray *) getValuesForFacility:(int) faciltyNumber;

- (BOOL)open;
- (void)close:(BOOL)opened;
- (BOOL)executeCmd:(LPCSTR)cmd;

- (void) loadTestData:(int)facID;

- (void)logError:(int)sqlReturn
          method:(char *)method;
- (NSString *) getHeaderForStep:(NSString *)stepID;

Bool AddStep (LPSTR StepValueID,LPCSTR stepDefID,LPCSTR Prompt,LPCSTR value,LPCSTR header,int needPhoto);
+ (Bool) setValueForStep:(NSString *)stepID to:(NSString *)value
              withStatus:(int)istat;
+ (Bool) setHeaderForStep:(NSString *)stepID to:(NSString *)value;
+ (Bool) setPriorHeaderForStep:(NSString *)stepID to:(NSString *)value;
+ (void) setVariablesForStep:(NSString *)stepID;
+ (NSString *) getCompositeHeaderForStep:(NSString *)stepID;

+(Bool) addPointElementToStep:(NSString *)stepID
                  usingSymbol:(PointSymbols)symbol
                      atPoint:(DPOINT) point
                       onPage:(int)page
              inReferenceFile:(NSString *)refFile
                       ofType:(NSString *)type;

+(Bool) addPolygonElementToStep:(NSString *)stepID
                    usingSymbol:(PolygonSymbols)symbol
                  withNumPoints:(int)nPoints
                         points:(DPOINT*) points
                         onPage:(int)page
                inReferenceFile:(NSString *)refFile
                         ofType:(NSString *)type;
+ (void) getExistingGraphicDataTypes:(NSMutableArray *)types
                        usingSymbols:(NSMutableArray *)symbols
                   havingCoordinates:(NSMutableArray *)coordinates
                             forPage:(int)page
                              inFile:(NSString *)file;


@end
