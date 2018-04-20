//  FacilityStepDefinition.m
//  CCodeLibrary

#import "FacilityStepDefinition.h"
#import "UserDefaults.h"

@implementation FacilityStepDefinition
- (id)init
{
    self = [super init];
    self.allowUpdates = TRUE;
    return self;
}

- (void)dealloc
{
    SQLite_Close(&_database);
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
        self.isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(path.UTF8String, &_database), _database);
        NSLog(@"Step Definitions Database open");
        
        rtn = TRUE;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        SQLOK(__FILE__,__LINE__,SQLite_Close(&_database),_database);
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
    if ([type isEqualToString:@"Pounds"])
        ft = FMTPounds;
    if ([type isEqualToString:@"Inches"])
        ft = FMTInches;
    if ([type isEqualToString:@"Feet"])
        ft = FMTFeet;
    if ([type isEqualToString:@"Text"])
        ft = FMTText;
    if ([type isEqualToString:@"HeaderOnly"])
        ft = FMTHeaderOnly;
    if ([type isEqualToString:@"FieldCount"])
        ft = FMTFieldCount;
    if ([type isEqualToString:@"Count"])
        ft = FMTCount;
    if ([type isEqualToString:@"LocatePoint"])
        ft = FMTLocatePoint;
    if ([type isEqualToString:@"LocatePolyline"])
        ft = FMTLocatePolyline;
    if ([type isEqualToString:@"LocatePolygon"])
        ft = FMTLocatePolygon;
    if ([type isEqualToString:@"DoorCloseSeconds"])
        ft = FMTDoorCloseSeconds;
    return ft;
}
- (FacPointSymbols) pointSymbolFromText:(NSString *)type
{
    FacPointSymbols ft = 0;
    
    if ([type isEqualToString:@"DrinkingFountain"])
        ft = FPSDrinkingFountain;
    if ([type isEqualToString:@"ToiletRoom"])
        ft = FPSToiletRoom;
    if ([type isEqualToString:@"Elevator"])
        ft = FPSElevator;
    if ([type isEqualToString:@"Entrance"])
        ft = FPSEntrance;
    if ([type isEqualToString:@"Door"])
        ft = FPSDoor;
    if (!ft)
        showAlert ([NSString stringWithFormat:@"Point symbol %@ not found",type]);
    return ft;
}

- (FacPolylineSymbols) polylineSymbolFromText:(NSString *)type
{
    FacPolylineSymbols ft = 0;
    
    if ([type isEqualToString:@"CirculationPath"])
        ft = FPSCirculationPath;
    if ([type isEqualToString:@"AccessibleRoute"])
        ft = FPSAccessibleRoute;
    if ([type isEqualToString:@"Ramp"])
        ft = FPSRamp;
    return ft;
}

- (FacPolygonSymbols) polygonSymbolFromText:(NSString *)type
{
    FacPolygonSymbols ft = 0;
    
    if ([type isEqualToString:@"PublicArea"])
        ft = FPSPublicArea;
    if ([type isEqualToString:@"WorkArea"])
        ft = FPSWorkArea;
    return ft;
}

- (int) symbolFromType:(FacilityMeasurementType)type
               andText:(NSString*)text
{
    int rtn = 0;
    
    if (type == FMTLocatePoint)
    {
        rtn = (int)[self pointSymbolFromText:text];
    }
    if (type == FMTLocatePolyline)
    {
        rtn = (int)[self polylineSymbolFromText:text];
    }
    if (type == FMTLocatePolygon)
    {
        rtn = (int)[self polygonSymbolFromText:text];
    }
    return rtn;
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
    
    bundlePath = [NSBundle.mainBundle pathForResource:@"BuildingBlocks"
                                               ofType:@"txt"];
    cmd = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:&error];
    rtn = [self executeCmd:cmd.UTF8String];
    
    [self close:opened];
    return rtn;
}
- (Bool) getStepDefinition:(NSString *)stepID
{
    Bool rtn = FALSE;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT Title,Prompt,Header,Type,PhotoRequired,Reference,Link,Test,Variables,Command,ChoiceList,MinValue,MaxValue,Symbol,HighlightDef FROM STEPDEF WHERE SectionID = '%@'",stepID];
    
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
        _header = [NSString stringWithUTF8String:value];
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
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _symbol = [self symbolFromType:_measurementType
                               andText:[NSString stringWithUTF8String:value]];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        _highlights = [NSString stringWithUTF8String:value];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return rtn;
}
+ (NSString *) getStepCommand:(NSString *)stepID
{
    NSString * rtn = @"";
    FacilityStepDefinition *fsd = FacilityStepDefinition.new;
    Bool opened = [fsd open];
    if ([fsd getStepDefinition:stepID])
    {
        rtn = fsd.command;
    }
    [fsd close:opened];
    return rtn;
}
+ (NSString *) getStepHighlights:(NSString *)stepID
{
    NSString * rtn = @"";
    FacilityStepDefinition *fsd = FacilityStepDefinition.new;
    Bool opened = [fsd open];
    if ([fsd getStepDefinition:stepID])
    {
        rtn = fsd.highlights;
    }
    [fsd close:opened];
    return rtn;
}
+ (NSString *) getStepHeader:(NSString *)stepID
{
    NSString * rtn = @"";
    FacilityStepDefinition *fsd = FacilityStepDefinition.new;
    Bool opened = [fsd open];
    if ([fsd getStepDefinition:stepID])
    {
        rtn = fsd.header;
    }
    [fsd close:opened];
    return rtn;
}
+ (NSString *) getStepVariables:(NSString *)stepID
{
    NSString * rtn = @"";
    FacilityStepDefinition *fsd = FacilityStepDefinition.new;
    Bool opened = [fsd open];
    if ([fsd getStepDefinition:stepID])
    {
        rtn = fsd.variables;
    }
    [fsd close:opened];
    return rtn;
}
+ (NSString *) getStepPrompt:(NSString *)stepID
{
    NSString * rtn = @"";
    FacilityStepDefinition *fsd = FacilityStepDefinition.new;
    Bool opened = [fsd open];
    if ([fsd getStepDefinition:stepID])
    {
        rtn = fsd.prompt;
    }
    [fsd close:opened];
    return rtn;
}
@end
