//  ManagePlacesDatabase.h
//  CCodeLibrary

#import <sqlite3.h>

int SQLOK(int sqlReturn, sqlite3 *database);

@interface ManagePlacesDatabase : NSObject

@property BOOL isOpen;
@property (nonatomic, copy) NSString *path;
@property sqlite3 *database;

+ (ManagePlacesDatabase *)database;

- (NSArray *)getPlaceBounds:(int)geoid;
- (NSString *)getPlaceName:(int)geoid;
- (int)getPlaceStatefp:(int)geoid;
- (NSArray *)getPlaceInfo:(int)geoid;
- (void)addLocationToList:(int)geoid;
- (NSArray *)getCityList:(int)code;
- (int)getStatefpForStateName:(NSString *)stateName;
- (int)getStatefpForStateCode:(NSString *)stateCode;
- (NSString *)getStateCodeForStatefp:(int)statefp;
- (NSString *)getStateNameForStatefp:(int)statefp;
- (NSArray *)stateList;

@end