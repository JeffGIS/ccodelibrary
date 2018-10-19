//  CityOrOrganizationData.h
//  CCodeLibrary

@import UIKit;

@interface CityOrOrganizationData : NSObject

@property (nonatomic, copy) NSString *fullDescription;
@property (nonatomic, copy) NSString *name;
@property NSInteger number;
@property NSInteger managerNumber;
@property NSInteger withinManager;
@property NSInteger totWithinManager;
@property NSInteger GSSiPadNumber;
@property bool controlledInterface;
@property bool allowSidewalk;

- (bool) inArray:(NSArray*)array;
- (NSComparisonResult)compareName:(CityOrOrganizationData *)c;

@end
