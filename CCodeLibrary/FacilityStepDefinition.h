//  FacilityStepDefinition.h
//  CCodeLibrary

#import "SQLiteLib.h"
#import "GSSiEnums.h"

@interface FacilityStepDefinition : NSObject

@property NSString * stepID;
@property NSString * sectionID;
@property NSString * title;
@property NSString * header;
@property NSString * link;
@property NSArray * reference;
@property Bool photoRequired;
@property FacilityMeasurementType measurementType;
@property int symbol;
@property NSString * prompt;
@property NSString * test;
@property NSString * variables;
@property NSString * command;
@property NSString * fieldIndex;
@property NSArray * choiceList;
@property double minValue, maxValue;

@property sqlite3nv *database;

@property (atomic) BOOL isOpen;
@property (atomic) BOOL allowUpdates;

- (BOOL)open;
- (void)close:(BOOL)opened;
- (NSString *)databasePath;
- (Bool) load;
- (Bool) getStepDefinition:(NSString *)stepID;
+ (NSString *) getStepCommand:(NSString *)stepID;
+ (NSString *) getStepHeader:(NSString *)stepID;
+ (NSString *) getStepVariables:(NSString *)stepID;
+ (NSString *) getStepPrompt:(NSString *)stepID;

@end
