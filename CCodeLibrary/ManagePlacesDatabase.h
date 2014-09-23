//  ManagePlacesDatabase.h
//  CCodeLibrary

#import <sqlite3.h>
#import "CCodeLibrary.h"

@interface ManagePlacesDatabase : NSObject
{
    sqlite3 *_database;
}

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