//  SidewalkData.m
//  CCodeLibrary

#import "SidewalkData.h"
#import "UserDefaults.h"
#import "SQLiteLib.h"
#import "CRAPI.h"
#import "UIApplication+VersionBuild.h"

#define CURRENT_SIDEWALK_VERSION "1.2"

@implementation  NVSidewalkPoint

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _note = @"";
    }
    
    return self;
}

@end

@interface SidewalkData ()

@property (nonatomic, copy) NSString *path;
@property sqlite3 *database;
@property BOOL isOpen, sendToServer;
@property unsigned long long fileSize;

@end

@implementation SidewalkData

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _path = [NSString stringWithFormat:@"%@/SidewalkDatabase.sqlite3", UserDefaults.defaults.sharedFilePath];
        _sendToServer = YES;
        BOOL opened = self.open;
        
        NSString *cmd = @"CREATE TABLE IF NOT EXISTS SidewalkPoints (id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "note CHAR(255), latitude REAL, longitude REAL, slope_front REAL, slope_side REAL, slope_heading REAL,"
        "crack_width REAL, width REAL, level_change REAL, time_complete INT, condition INT, obstruction INT);";
        
        [self executeCmd:(char *)cmd.UTF8String
            sendToServer:_sendToServer
                fromFile:__FILE__ fromLine:__LINE__];
        
        [self close:opened];
    }
    
    return self;
}

- (BOOL)open
{
    BOOL rtn = NO;
    
    if (!_isOpen)
    {
        _isOpen = !SQLOK(__FILE__,__LINE__,sqlite3_open(_path.UTF8String, &_database), _database);
        NSLog(@"SidewalkPoints Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        
        if (_fileSize)
        {
            [self createNextUpdateTable];
            [self createPictureDatabase];
            
            BOOL tableOK = NO;
            sqlite3_stmt *stmt = NULL;
            int rc = SQLitePrepare(_database, "pragma table_info ('SidewalkPointsUpdates')", -1, &stmt, NULL);
            
            if (rc == SQLITE_OK)
            {
                while (sqlite3_step(stmt) == SQLITE_ROW)
                {
                    LPSTR colName = (LPSTR)sqlite3_column_text(stmt, 1);
                    
                    if (!strcmp (colName,"iPad"))
                        tableOK = YES;
                }
            }
            
            SQLOK(__FILE__,__LINE__,SQLiteFinalize(stmt), _database);
            
            if (!tableOK)
            {
                NSString *cmd = @"DROP TABLE SidewalkPointsUpdates;";
                
                rtn = [self executeCmd:(char *)cmd.UTF8String
                          sendToServer:NO
                              fromFile:__FILE__ fromLine:__LINE__];
                
                [self createNextUpdateTable];
            }
        }
        
        rtn = YES;
    }
    
    return rtn;
}

- (BOOL)createNextUpdateTable
{
    BOOL rtn = YES;
    NSString *cmd = @"CREATE TABLE IF NOT EXISTS SidewalkPointsUpdates (iPad INTEGER PRIMARY KEY, LastDataUpdate INT, LastPictUpdate INT)";
    rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    return rtn;
}

- (BOOL)createPictureDatabase
{
    BOOL rtn = YES;
    
    NSString *cmd = @"CREATE TABLE IF NOT EXISTS SidewalkPointsPictures (id INTEGER PRIMARY KEY,"
    "iPadNum INT, pictNum INT, pointID INT, type INT, heading INT, latitude REAL, longitude REAL, time INT)";
    
    rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE INDEX IF NOT EXISTS SidewalkPointsPictures_index ON SidewalkPointsPictures (pointID)";
    rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(__FILE__,__LINE__, sqlite3_close(_database), _database);
        NSLog(@"SidewalkPoint Database close");
        _isOpen = NO;
    }
}

- (void)dealloc
{
    [self close:_isOpen];
}

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
          fromFile:(LPSTR)fromFile
          fromLine:(int)fromLine
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    
    if (!iPad)
        sendToServer = YES;
    
    BOOL rtn = !SQLOK(fromFile,fromLine,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    
    if (rtn && sendToServer)
    {
        NSString *sendToServerFile = [self getSendToServerFile:iPad];
        
        int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:sendToServerFile
                                                                           error:nil].fileSize;
        
        if (!fileSize)
        {
            NSString *versions = [NSString stringWithFormat:@"/*ApVer %@ DBVer %s Time %i*/",
                                  UIApplication.appVersionBuild, CURRENT_SIDEWALK_VERSION,
                                  (int)NSDate.timeIntervalSinceReferenceDate];
            
            rtn = appendStringToFile(versions, sendToServerFile);
        }
        
        rtn = appendStringToFile([NSString stringWithUTF8String:cmd], sendToServerFile);
    }
    
    return rtn;
}

- (NSString *)getSendToServerFile:(int)iPad
{
    int pictNum;
    
    int currentFileNum = [self getLastDataUpdateNumber:iPad
                                           lastPictNum:&pictNum];
    
    NSString *file = [self outputDataFile:currentFileNum iPad:iPad];
    
    return file;
}

- (int)getLastDataUpdateNumber:(int)iPad
                   lastPictNum:(int *)pictNum
{
    int lastNum  = 0;
    int lastPictNum = 0;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT LastDataUpdate, LastPictUpdate FROM SidewalkPointsUpdates WHERE iPad=%i",iPad];
    sqlite3_stmt *statement = nil;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, cmd.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        lastNum = sqlite3_column_int(statement, 0);
        lastPictNum = sqlite3_column_int(statement, 1);
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    if (!lastNum)
    {
        lastNum = 1;
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SidewalkPointsUpdates VALUES(%i,1,0);", iPad];
        
        [self executeCmd:(LPSTR)cmd.UTF8String
            sendToServer:NO
                fromFile:__FILE__ fromLine:__LINE__];
    }
    
    [self close:opened];
    *pictNum = lastPictNum;
    return lastNum;
}

- (NSString *)outputDataFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString *file = [NSString stringWithFormat:@"%@/%i_%i.sql",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"SidewalkPoints"], iPad, fileNum];
    
    return file;
}

@end
