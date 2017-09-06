//
//  FacilityStepDefinition.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 8/29/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import "FacilityStepDefinition.h"

@implementation FacilityStepDefinition
- (id)init
{
    self = [super init];
    self.allowUpdates = TRUE;
    return self;
}

- (void)dealloc
{
    sqlite3_close(_database);
    NSLog(@"Step Definitions Closed");
}

- (NSString *)databasePath
{
//    NSString * bundleDbPath = [NSBundle.mainBundle pathForResource:@"facdef"
//                                                            ofType:@"slt"];
//    if (!_allowUpdates)
//        return bundleDbPath;
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@", UserDefaults.defaults.localFilePath, @"stepdef.slt"];
    
/*    if (![NSFileManager.defaultManager fileExistsAtPath:dbPath])
    {
        NSError *error = nil;
        
        [NSFileManager.defaultManager copyItemAtPath:bundleDbPath toPath:dbPath error:&error];
        
        if (error)
            NSLog(@"Copy facdef.slt ERROR: %@", error.localizedDescription);
    }*/
    
    return dbPath;
}

- (BOOL)open
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        self.isOpen = YES;
        NSString * path = [self databasePath];
        self.isOpen = !SQLOK(__FILE__,__LINE__,sqlite3_open(path.UTF8String, &_database), _database);
        NSLog(@"Step Definitions Database open");
        
        rtn = TRUE;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        SQLOK(__FILE__,__LINE__,sqlite3_close(_database),_database);
        NSLog(@"Step Definitions Database close");
        self.isOpen = NO;
    }
}

- (BOOL)executeCmd:(LPCSTR)cmd
{
    BOOL rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (FacilityMeasurementType) measurementTypeFromText:(NSString *)type
{
    FacilityMeasurementType ft = FMTInvalidType;
    
    if ([type isEqualToString:@"YesNo"])
        ft = FMTYesNo;
    if ([type isEqualToString:@"ImageList"])
        ft = FMTImageList;
    if ([type isEqualToString:@"ChoiceList"])
        ft = FMTChoiceList;
    if ([type isEqualToString:@"Slope"])
        ft = FMTSlope;
    if ([type isEqualToString:@"Inches"])
        ft = FMTInches;
    if ([type isEqualToString:@"Feet"])
        ft = FMTFeet;
    if ([type isEqualToString:@"Count"])
        ft = FMTCount;
    if ([type isEqualToString:@"DoorCloseSeconds"])
        ft = FMTDoorCloseSeconds;
    return ft;
}
 - (Bool) load
{
    Bool rtn = FALSE;
    Bool opened = [self open];
    NSString * bundlePath = [NSBundle.mainBundle pathForResource:@"StepDefinitions"
                                                          ofType:@"txt"];
    NSString * cmd = @"DROP TABLE IF EXISTS STEPDEF";
    rtn = [self executeCmd:cmd.UTF8String];
    NSError *error = nil;
    cmd = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:&error];
    rtn = [self executeCmd:cmd.UTF8String];
    [self close:opened];
    return rtn;
}
- (Bool) getStepDefinition:(NSString *)stepID
{
    Bool rtn = FALSE;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT Title,Prompt,Type,PhotoRequired,Reference,Link,Test,Variables,Command,ChoiceList,MinValue,MaxValue FROM STEPDEF WHERE SectionID = '%@'",stepID];
    
    sqlite3_stmt *statement = NULL;
    _sectionID = stepID;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int i = 0;
        rtn = TRUE;
        LPSTR value = (LPSTR)sqlite3_column_text(statement, i++);
        _title = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _prompt = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _measurementType = [self measurementTypeFromText:[NSString stringWithUTF8String:value]];
        _photoRequired = sqlite3_column_int(statement, i++);
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _reference = [[NSString stringWithUTF8String:value]componentsSeparatedByString:@";"];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _link = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _test = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _variables = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _command = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _choiceList = [[NSString stringWithUTF8String:value]componentsSeparatedByString:@";"];
        _minValue = sqlite3_column_double(statement, i++);
        _maxValue = sqlite3_column_double(statement, i++);

    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return rtn;
}

@end
