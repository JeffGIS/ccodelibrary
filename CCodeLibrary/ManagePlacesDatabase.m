//  ManagePlacesDatabase.m
//  PedRampInv_Management

#import "ManagePlacesDatabase.h"

@implementation ManagePlacesDatabase

static ManagePlacesDatabase *_database;

+ (ManagePlacesDatabase *)database
{
    if (_database == nil)
    {
        _database = [[ManagePlacesDatabase alloc] init];
    }
    
    return _database;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSString *sqLiteDb = [NSBundle.mainBundle pathForResource:@"places"
                                                           ofType:@"sqlite3"];
        
        SQLOK(sqlite3_open(sqLiteDb.UTF8String, &_database));
    }
    
    return self;
}

- (void)dealloc
{
    sqlite3_close(_database);
}

- (NSArray *)getCityList:(int)code
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT name, geoid FROM places WHERE statefp=%i", code];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *nameChar = (char *)sqlite3_column_text(statement, 0);
            NSString *geoid = [NSString stringWithFormat:@"%i", sqlite3_column_int(statement, 1)];
            NSString *name = [[NSString alloc] initWithUTF8String:nameChar];
            name = [self removeEndingReturn:name];
            name = [self removeTextInsideParentheses:name];
            
            PlacesInfo *info = [[PlacesInfo alloc]initWithName:name
                                                         geoid:geoid];
            
            [dataArray addObject:info];
        }
        
        sqlite3_finalize(statement);
    
    return dataArray;
}

- (NSArray *)getPlaceBounds:(int)geoid
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT bounds_w, bounds_s, bounds_e, bounds_n FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        CGFloat bounds_w = sqlite3_column_double(statement, 0);
        CGFloat bounds_s = sqlite3_column_double(statement, 1);
        CGFloat bounds_e = sqlite3_column_double(statement, 2);
        CGFloat bounds_n = sqlite3_column_double(statement, 3);
            
        PlacesInfo *info = [[PlacesInfo alloc]initWithBounds_w:bounds_w
                                                      bounds_s:bounds_s
                                                      bounds_e:bounds_e
                                                      bounds_n:bounds_n];
            
        [dataArray addObject:info];
    }
        
    sqlite3_finalize(statement);
    return dataArray;
}

- (NSString *)getPlaceName:(int)geoid
{
    NSString *query = [NSString stringWithFormat:@"SELECT name FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    NSString *placeName = @"";
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *placeNameChar = (char *)sqlite3_column_text(statement, 0);
        placeName = [[NSString alloc] initWithUTF8String:placeNameChar];
        placeName = [self removeEndingReturn:placeName];
        placeName = [self removeTextInsideParentheses:placeName];
    }
        
    sqlite3_finalize(statement);
    return placeName;
}

- (int)getPlaceStatefp:(int)geoid
{
    NSString *query = [NSString stringWithFormat:@"SELECT statefp FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    int statefp = -1;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
        statefp = (int)sqlite3_column_int(statement, 0);
    
    sqlite3_finalize(statement);
    return statefp;
}

- (NSArray *)getPlaceInfo:(int)geoid
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT name, statefp, bounds_w, bounds_s, bounds_e, bounds_n FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *nameChar = (char *)sqlite3_column_text(statement, 0);
        int statefp = (int)sqlite3_column_int(statement, 1);
        CGFloat bounds_w = sqlite3_column_double(statement, 2);
        CGFloat bounds_s = sqlite3_column_double(statement, 3);
        CGFloat bounds_e = sqlite3_column_double(statement, 4);
        CGFloat bounds_n = sqlite3_column_double(statement, 5);
        NSString *name = [[NSString alloc] initWithUTF8String:nameChar];
        name = [self removeEndingReturn:name];
        name = [self removeTextInsideParentheses:name];
        
        NSString *stateCode = [[NSString alloc] initWithString:[self getStateCodeForStatefp:statefp]];
        
        PlacesInfo *info = [[PlacesInfo alloc]initWithName:name
                                                 stateCode:stateCode
                                                  bounds_w:bounds_w
                                                  bounds_s:bounds_s
                                                  bounds_e:bounds_e
                                                  bounds_n:bounds_n];
        
        [dataArray addObject:info];
    }
    
    sqlite3_finalize(statement);
    return dataArray;
}

- (void)addLocationToList:(int)geoid
{
    NSString *query = [NSString stringWithFormat:@"SELECT name, statefp, bounds_w, bounds_s, bounds_e, bounds_n FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *nameChar = (char *)sqlite3_column_text(statement, 0);
        int statefp = (int)sqlite3_column_int(statement, 1);
        CGFloat bounds_w = sqlite3_column_double(statement, 2);
        CGFloat bounds_s = sqlite3_column_double(statement, 3);
        CGFloat bounds_e = sqlite3_column_double(statement, 4);
        CGFloat bounds_n = sqlite3_column_double(statement, 5);
        NSString *name = [[NSString alloc] initWithUTF8String:nameChar];
        name = [self removeEndingReturn:name];
        name = [self removeTextInsideParentheses:name];

        [UserDefaults.defaults addLocationToListWithName:name
                                                   state:[self getStateCodeForStatefp:statefp]
                                                   geoid:geoid
                                                bounds_w:bounds_w
                                                bounds_s:bounds_s
                                                bounds_e:bounds_e
                                                bounds_n:bounds_n
                                                  status:0];
    }
        
    sqlite3_finalize(statement);
}

- (NSString *)getStateCodeForStatefp:(int)statefp
{
    NSString *query = [NSString stringWithFormat:@"SELECT statecode FROM states WHERE statefp=%i", statefp];
    sqlite3_stmt *statement;
    NSString *stateCode = @"";
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *stateCodeChar = (char *)sqlite3_column_text(statement, 0);
        stateCode = [[NSString alloc] initWithUTF8String:stateCodeChar];
        stateCode = [self removeEndingReturn:stateCode];
    }
        
    sqlite3_finalize(statement);
    return stateCode;
}

- (NSString *)getStateNameForStatefp:(int)statefp
{
    NSString *query = [NSString stringWithFormat:@"SELECT statename FROM states WHERE statefp=%i", statefp];
    sqlite3_stmt *statement;
    NSString *stateName = @"";
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *stateCodeChar = (char *)sqlite3_column_text(statement, 0);
        stateName = [[NSString alloc] initWithUTF8String:stateCodeChar];
        stateName = [self removeEndingReturn:stateName];
    }

    sqlite3_finalize(statement);
    return stateName;
}

- (int)getStatefpForStateName:(NSString *)stateName
{
    NSString *query = [NSString stringWithFormat:@"SELECT statefp FROM states WHERE statename='%@'", stateName];
    sqlite3_stmt *statement;
    int statefp = -1;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
        statefp = (int)sqlite3_column_int(statement, 0);
        
    sqlite3_finalize(statement);
    return statefp;
}

- (int)getStatefpForStateCode:(NSString *)stateCode
{
    NSString *query = [NSString stringWithFormat:@"SELECT statefp FROM states WHERE statecode='%@'", stateCode];
    sqlite3_stmt *statement;
    int statefp = -1;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
        statefp = (int)sqlite3_column_int(statement, 0);
        
    sqlite3_finalize(statement);
    return statefp;
}

- (NSArray *)stateList
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT statename FROM states"];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *stateCodeChar = (char *)sqlite3_column_text(statement, 0);
        NSString *stateName = [[NSString alloc] initWithUTF8String:stateCodeChar];
        stateName = [self removeEndingReturn:stateName];
        [dataArray addObject:stateName];
    }
        
    sqlite3_finalize(statement);
    return dataArray;
}

- (NSString *)removeEndingReturn:(NSString *)string
{
    NSString *end = [NSString stringWithFormat:@"%@", [string substringFromIndex:(string.length - 1)]];
    
    if ([end  isEqual:@"\r"])
        string = [NSString stringWithFormat:@"%@", [string substringToIndex:(string.length - 1)]];
    
    return string;
}

- (NSString *)includeTextAfterHyphen:(NSString *)string
{
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
    
    return string;
}

- (NSString *)includeTextBeforeHyphen:(NSString *)string
{
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
    
    return string;
}

- (NSString *)removeTextInsideParentheses:(NSString *)string
{
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    NSRange start = [mutableString rangeOfString:@"("];
    NSRange end = [mutableString rangeOfString:@")"];
    
    if ((start.location != NSNotFound) && (end.location != NSNotFound))
        [mutableString deleteCharactersInRange:(NSRange){(start.location - 1), (end.location - start.location + 2)}];
    
    return mutableString;
}

@end