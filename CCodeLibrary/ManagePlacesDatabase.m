//  ManagePlacesDatabase.m
//  CCodeLibrary

#import "ManagePlacesDatabase.h"

@implementation ManagePlacesDatabase

static ManagePlacesDatabase *_database;

+ (ManagePlacesDatabase *)database
{
    if (!_database)
        _database = [[ManagePlacesDatabase alloc] init];
    
    return _database;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.path = [NSBundle.mainBundle pathForResource:@"places"
                                                  ofType:@"sqlite3"];
        
        self.isOpen = SQLOK(sqlite3_open(self.path.UTF8String, &_database), "init(Places)");
        NSLog(@"Places Database init");
    }
    
    return self;
}

- (void)dealloc
{
    sqlite3_close(_database);
    NSLog(@"Places Database dealloc");
}

- (void)open
{
    if (!self.isOpen)
    {
        self.isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), "open(Places)");
        NSLog(@"Places Database open");
    }
}

- (void)close
{
    if (self.isOpen)
    {
        sqlite3_close(_database);
        NSLog(@"Places Database close");
        self.isOpen = NO;
    }
}

- (NSArray *)getCityList:(int)code
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT name, geoid FROM places WHERE statefp=%i", code];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getCityList");
    
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *nameChar = (char *)sqlite3_column_text(statement, 0);
            NSString *geoid = [NSString stringWithFormat:@"%i", sqlite3_column_int(statement, 1)];
            NSString *name = [[NSString alloc] initWithUTF8String:nameChar];
            name = [UserDefaults.defaults removeEndingReturn:name];
            name = [UserDefaults.defaults removeTextInsideParentheses:name];
            
            PlacesInfo *info = [[PlacesInfo alloc] initWithName:name
                                                          geoid:geoid];
            
            [dataArray addObject:info];
        }
    
    sqlite3_finalize(statement);
    [self close];
    return dataArray;
}

- (NSArray *)getPlaceBounds:(int)geoid
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT bounds_w, bounds_s, bounds_e, bounds_n FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getPlaceBounds");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        CGFloat bounds_w = sqlite3_column_double(statement, 0);
        CGFloat bounds_s = sqlite3_column_double(statement, 1);
        CGFloat bounds_e = sqlite3_column_double(statement, 2);
        CGFloat bounds_n = sqlite3_column_double(statement, 3);
            
        PlacesInfo *info = [[PlacesInfo alloc] initWithBounds_w:bounds_w
                                                       bounds_s:bounds_s
                                                       bounds_e:bounds_e
                                                       bounds_n:bounds_n];
            
        [dataArray addObject:info];
    }
        
    sqlite3_finalize(statement);
    [self close];
    return dataArray;
}

- (NSString *)getPlaceName:(int)geoid
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT name FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    NSString *placeName = @"";
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getPlaceName");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *placeNameChar = (char *)sqlite3_column_text(statement, 0);
        placeName = [[NSString alloc] initWithUTF8String:placeNameChar];
        placeName = [UserDefaults.defaults removeEndingReturn:placeName];
        placeName = [UserDefaults.defaults removeTextInsideParentheses:placeName];
    }
        
    sqlite3_finalize(statement);
    [self close];
    return placeName;
}

- (int)getPlaceStatefp:(int)geoid
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT statefp FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    int statefp = -1;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getPlaceStatefp");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
        statefp = (int)sqlite3_column_int(statement, 0);
    
    sqlite3_finalize(statement);
    [self close];
    return statefp;
}

- (NSArray *)getPlaceInfo:(int)geoid
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT name, statefp, bounds_w, bounds_s, bounds_e, bounds_n FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getPlaceInfo");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *nameChar = (char *)sqlite3_column_text(statement, 0);
        int statefp = (int)sqlite3_column_int(statement, 1);
        CGFloat bounds_w = sqlite3_column_double(statement, 2);
        CGFloat bounds_s = sqlite3_column_double(statement, 3);
        CGFloat bounds_e = sqlite3_column_double(statement, 4);
        CGFloat bounds_n = sqlite3_column_double(statement, 5);
        NSString *name = [[NSString alloc] initWithUTF8String:nameChar];
        name = [UserDefaults.defaults removeEndingReturn:name];
        name = [UserDefaults.defaults removeTextInsideParentheses:name];
        
        NSString *stateCode = [[NSString alloc] initWithString:[self getStateCodeForStatefp:statefp]];
        
        PlacesInfo *info = [[PlacesInfo alloc] initWithName:name
                                                  stateCode:stateCode
                                                   bounds_w:bounds_w
                                                   bounds_s:bounds_s
                                                   bounds_e:bounds_e
                                                   bounds_n:bounds_n];
        
        [dataArray addObject:info];
    }
    
    sqlite3_finalize(statement);
    [self close];
    return dataArray;
}

- (void)addLocationToList:(int)geoid
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT name, statefp, bounds_w, bounds_s, bounds_e, bounds_n FROM places WHERE geoid=%i", geoid];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "addLocationToList");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *nameChar = (char *)sqlite3_column_text(statement, 0);
        int statefp = (int)sqlite3_column_int(statement, 1);
        CGFloat bounds_w = sqlite3_column_double(statement, 2);
        CGFloat bounds_s = sqlite3_column_double(statement, 3);
        CGFloat bounds_e = sqlite3_column_double(statement, 4);
        CGFloat bounds_n = sqlite3_column_double(statement, 5);
        NSString *name = [[NSString alloc] initWithUTF8String:nameChar];
        name = [UserDefaults.defaults removeEndingReturn:name];
        name = [UserDefaults.defaults removeTextInsideParentheses:name];

        [UserDefaults.defaults addLocationToListWithName:name
                                                   state:[self getStateCodeForStatefp:statefp]
                                                   geoid:geoid
                                                bounds_w:bounds_w
                                                bounds_s:bounds_s
                                                bounds_e:bounds_e
                                                bounds_n:bounds_n];
    }
        
    sqlite3_finalize(statement);
    [self close];
}

- (NSString *)getStateCodeForStatefp:(int)statefp
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT statecode FROM states WHERE statefp=%i", statefp];
    sqlite3_stmt *statement;
    NSString *stateCode = @"";
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getStateCodeForStatefp");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *stateCodeChar = (char *)sqlite3_column_text(statement, 0);
        stateCode = [[NSString alloc] initWithUTF8String:stateCodeChar];
        stateCode = [UserDefaults.defaults removeEndingReturn:stateCode];
    }
        
    sqlite3_finalize(statement);
    [self close];
    return stateCode;
}

- (NSString *)getStateNameForStatefp:(int)statefp
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT statename FROM states WHERE statefp=%i", statefp];
    sqlite3_stmt *statement;
    NSString *stateName = @"";
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getStateNameForStatefp");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *stateCodeChar = (char *)sqlite3_column_text(statement, 0);
        stateName = [[NSString alloc] initWithUTF8String:stateCodeChar];
        stateName = [UserDefaults.defaults removeEndingReturn:stateName];
    }

    sqlite3_finalize(statement);
    [self close];
    return stateName;
}

- (int)getStatefpForStateName:(NSString *)stateName
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT statefp FROM states WHERE statename='%@'", stateName];
    sqlite3_stmt *statement;
    int statefp = -1;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getStatefpForStateName");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
        statefp = (int)sqlite3_column_int(statement, 0);
        
    sqlite3_finalize(statement);
    [self close];
    return statefp;
}

- (int)getStatefpForStateCode:(NSString *)stateCode
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT statefp FROM states WHERE statecode='%@'", stateCode];
    sqlite3_stmt *statement;
    int statefp = -1;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "getStatefpForStateCode");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
        statefp = (int)sqlite3_column_int(statement, 0);
        
    sqlite3_finalize(statement);
    [self close];
    return statefp;
}

- (NSArray *)stateList
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT statename FROM states"];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), "stateList");
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char *stateCodeChar = (char *)sqlite3_column_text(statement, 0);
        NSString *stateName = [[NSString alloc] initWithUTF8String:stateCodeChar];
        stateName = [UserDefaults.defaults removeEndingReturn:stateName];
        [dataArray addObject:stateName];
    }
        
    sqlite3_finalize(statement);
    [self close];
    return dataArray;
}

@end