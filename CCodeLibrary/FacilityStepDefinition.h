//
//  FacilityStepDefinition.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 8/29/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCodeLibrary/SQLiteLib.h"
#import "CCodeLibrary/UserDefaults.h"

typedef NS_ENUM(NSInteger, FacilityMeasurementType)
{
    FMTInvalidType,
    FMTYesNo,
    FMTImageList,
    FMTChoiceList,
    FMTSlope,
    FMTInches,
    FMTFeet,
    FMTLocatePoint,
    FMTLocatePolyline,
    FMTLocatePolygon,
    FMTDoorCloseSeconds,
    FMTFieldCount,
    FMTText,
    FMTHeader,
    FMTHeaderOnly,
    FMTCount,
};

@interface FacilityStepDefinition : NSObject

@property NSString * stepID;
@property NSString * sectionID;
@property NSString * title;
@property NSString * header;
@property NSString * link;
@property NSArray * reference;
@property Bool photoRequired;
@property FacilityMeasurementType measurementType;
@property NSString * prompt;
@property NSString * test;
@property NSString * variables;
@property NSString * command;
@property NSArray * choiceList;
@property double minValue, maxValue;

@property sqlite3 *database;

@property (atomic) BOOL isOpen;
@property (atomic) BOOL allowUpdates;

- (BOOL)open;
- (void)close:(BOOL)opened;
- (NSString *)databasePath;
- (Bool) load;
- (Bool) getStepDefinition:(NSString *)stepID;
+ (NSString *) getStepCommand:(NSString *)stepID;
+ (NSString *) getStepHeader:(NSString *)stepID;

@end
