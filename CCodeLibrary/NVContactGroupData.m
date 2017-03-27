//  NVContactGroupData.m
//  CCodeLibrary

#import "NVContactGroupData.h"
#import "UserDefaults.h"
#import "SQLiteLib.h"

@interface NVContactGroupData ()

@property (nonatomic, copy) NSString *path;
@property sqlite3 *database;
@property BOOL isOpen;

@end

@implementation NVContactGroupData

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _path = [NSString stringWithFormat:@"%@/ContactGroupDatabase.sqlite3", UserDefaults.defaults.sharedFilePath];
        BOOL opened = [self open];
        
        NSString *cmd =  @"CREATE TABLE IF NOT EXISTS ContactGroups (ID INT PRIMARY KEY,Name TEXT);\
        CREATE TABLE IF NOT EXISTS Routes (RouteNum INT,PropertyNum INT,DestinationNum INT,Direction INT,Distance REAL,Time REAL);\
        CREATE INDEX IF NOT EXISTS PropNum_index ON Routes (PropertyNum ASC);";
        
        BOOL rtn = !SQLOK(0,sqlite3_exec(_database, cmd.UTF8String, 0, 0, 0), _database);
        
        [self close:opened];
            
    }
    
    return self;
}

- (BOOL)open
{
    BOOL rtn = NO;
    
    if (!_isOpen)
    {
        _isOpen = !SQLOK(0, sqlite3_open(_path.UTF8String, &_database), _database);
        rtn = YES;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(0, sqlite3_close(_database), _database);
        _isOpen = NO;
    }
}

- (void)dealloc
{
    sqlite3_close(_database);
}

@end
