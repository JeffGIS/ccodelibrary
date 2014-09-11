//  ManagePlacesDatabase.h
//  PedRampInv_Management

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
- (NSString *)removeEndingReturn:(NSString *)string;
- (NSString *)removeTextInsideParentheses:(NSString *)string;
- (NSString *)includeTextAfterHyphen:(NSString *)string;
- (NSString *)includeTextBeforeHyphen:(NSString *)string;
- (int)getStatefpForStateName:(NSString *)stateName;
- (int)getStatefpForStateCode:(NSString *)stateCode;
- (NSString *)getStateCodeForStatefp:(int)statefp;
- (NSString *)getStateNameForStatefp:(int)statefp;
- (NSArray *)stateList;

@end