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
        
        NSString *cmd = @"CREATE TABLE IF NOT EXISTS SidewalkPoints (id INTEGER PRIMARY KEY, note CHAR(512), street CHAR(64), "
        "latitude REAL, longitude REAL, slope_front REAL, slope_side REAL, slope_heading REAL, crack_width REAL, "
        "width REAL, level_change REAL, last_update INT, condition INT, obstruction INT, house_num INT, deleted INT); "
        "CREATE VIRTUAL TABLE IF NOT EXISTS SidewalkPoints_index USING rtree (id, minX, maxX, minY, maxY);";
        
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
    
    NSString *cmd = @"CREATE TABLE IF NOT EXISTS SidewalkPointsPictures (id INTEGER PRIMARY KEY, "
    "iPadNum INT, pictNum INT, pointID INT, type INT, heading INT, latitude REAL, longitude REAL, time INT)";
    
    rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE INDEX IF NOT EXISTS SidewalkPointsPictures_index ON SidewalkPointsPictures (pointID)";
    rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    
    return rtn;
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

- (BOOL)startTransaction
{
    BOOL opened = [self open];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN", 0, 0, 0), _database);
    return opened;
}

- (void)commitTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT", 0, 0, 0), _database);
}

- (void)cancelTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "ROLLBACK", 0, 0, 0), _database);
}

- (NSString *)getSendToServerFile:(int)iPad
{
    int pictNum = 0;
    
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
    NSString *cmd = [NSString stringWithFormat:@"SELECT LastDataUpdate, LastPictUpdate FROM SidewalkPointsUpdates WHERE iPad=%i", iPad];
    sqlite3_stmt *statement = NULL;
    
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

- (BOOL)setLastDataUpdateNum:(int)lastNum
                     pictNum:(int)pictNum
                     foriPad:(int)iPad
{
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SidewalkPointsUpdates VALUES(%i,%i,%i);",
                     iPad, lastNum, pictNum];
    
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO
                       fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    return rtn;
}

- (int)getLastPictUpdateNumber:(int)iPad
{
    int lastNum = 0;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastPictUpdate FROM SidewalkPointsUpdates WHERE iPad=%i", iPad];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        lastNum = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    [self close:opened];
    return lastNum;
}

- (BOOL)setLastPictUpdateNum:(int)lastNum
                     foriPad:(int)iPad
{
    BOOL rtn = NO;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT * FROM SidewalkPointsUpdates WHERE iPad=%i", iPad];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, cmd.UTF8String, -1, &statement, 0), _database);
    
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    if (!haveRecord)
    {
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SidewalkPointsUpdates VALUES(%i,1,0);", iPad];
        
        rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:NO
                      fromFile:__FILE__ fromLine:__LINE__];
    }
    
    cmd = [NSString stringWithFormat:@"UPDATE SidewalkPointsUpdates SET LastPictUpdate = %i WHERE iPad=%i", lastNum, iPad];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:NO
                  fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    return rtn;
}

- (NSString *)outputDataFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString *file = [NSString stringWithFormat:@"%@/%i_%i.sql",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"SidewalkPoints"], iPad, fileNum];
    
    return file;
}

- (NSString *)outputPictFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString *file = [NSString stringWithFormat:@"%@/%i_%i.jpg",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"SidewalkPoints"],iPad,fileNum];
    
    return file;
}

+ (int)incrementLastDataFileNumber
{
    return SidewalkData.new.incrementLastDataFileNum;
}

+ (int)incrementLastPictFileNumber
{
    return SidewalkData.new.incrementLastPictFileNum;
}

- (int)incrementLastDataFileNum
{
    int pictNum = 0;
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastDataUpdateNumber:iPad lastPictNum:&pictNum];
    int nextNum = max(1, lastNum);
    NSString *file = [self outputDataFile:nextNum iPad:iPad];
    
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    while (fileSize > 0)
    {
        nextNum++;
        file = [self outputDataFile:nextNum iPad:CRAPI.sharedInstance.currentiPadWithinManager];
        
        fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    }
    if (nextNum > lastNum)
        [self setLastDataUpdateNum:nextNum pictNum:pictNum foriPad:iPad];
    
    if (nextNum - lastNum > 1)
    {
        NSString *logmess = @"Sidewalk Data file num error";
        [CRAPI.sharedInstance logToErrorFile:logmess];
    }
    
    return nextNum;
}

- (int)incrementLastPictFileNum
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastPictUpdateNumber:iPad];
    int nextNum = lastNum-1;
    int lastFile = 0;
    NSString *file = [self outputPictFile:nextNum iPad:iPad];
    
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    while (fileSize > 0)
    {
        lastFile = nextNum++;
        file = [self outputPictFile:nextNum iPad:iPad];
        
        fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    }
    if (lastFile && lastFile != lastNum)
    {
        [self setLastPictUpdateNum:lastFile foriPad:iPad];
        
        NSString *logmess = [NSString stringWithFormat:@"Sidewalk Data pict file num error,%i - %i",
                             lastNum, lastFile];
        
        [CRAPI.sharedInstance logToErrorFile:logmess];
    }
    
    else
        lastFile = lastNum;
    
    return (lastFile + 1);
}

- (BOOL)savePictureData:(int)pictNum
               sdwkPtID:(NSString *)sdwkPtID
                   type:(int)type
                 latLon:(LLPOINT)ll
                heading:(int)heading
{
    BOOL opened = [self open];
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    uint pictID = [self getNextPictID];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SidewalkPointsPictures VALUES (%i,%i,%i,%@,%i,%i,%f,%f,%i);",
                     pictID, CRAPI.sharedInstance.currentiPadWithinManager, pictNum, sdwkPtID, type, heading, ll.lat, ll.lon, iTime];
    
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:YES
                       fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    return rtn;
}

- (uint)getNextPictID
{
    uint nextID = 1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM SidewalkPointsPictures"];
    BOOL opened = [self open];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        nextID = sqlite3_column_int(statement, 0);
    
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return nextID;
}

- (BOOL)updateFromFile:(NSString *)file
{
    BOOL rtn = YES;
    int line = 0;
    BOOL opened = [self open];
    
    FILE *fid = fopen(file.UTF8String, "rb");
    int totLen = (int)FileLength(fid);
    int maxLineLen = (totLen + 2);
    LPSTR str = malloc(totLen + 4);
    [self startTransaction];
    
    while (rtn && fgetstring(str, maxLineLen, fid))
    {
        rtn = [self executeCmd:str
                  sendToServer:NO
                      fromFile:__FILE__ fromLine:__LINE__];
        
        line++;
    }
    
    fclose(fid);
    
    if (!rtn)
    {
        [self cancelTransaction];
        NSString *cmd = [NSString stringWithUTF8String:str];
        
        NSString *header = [NSString stringWithFormat:@"Data load failure in file %@ at line %i",
                            file.lastPathComponent, line];
        
        [CRAPI.sharedInstance logToErrorFile:cmd withHeader:header];
    }
    
    else
        [self commitTransaction];
    
    free(str);
    [self close:opened];
    return rtn;
}

- (BOOL)createNewSdwkPoint:(NSString *)wallID
                atLocation:(CLLocationCoordinate2D)location
                 withHouse:(NSString *)house
                 andStreet:(NSString *)street
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    NSInteger refno = 0;
    NSInteger iHouse = house.integerValue;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM SidewalkPoints"];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        refno = sqlite3_column_int(statement, 0);
        refno = [CRAPI.sharedInstance adjustNextRefno:refno];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO SidewalkPoints (id, house_num, street, latitude, "
                     "longitude, last_update) VALUES (%ld,%ld,'%@',%f,%f,%i);",
                     (long)refno, (long)iHouse, street, location.latitude, location.longitude, iTime];
    
    [self executeCmd:(LPSTR)cmd.UTF8String
        sendToServer:YES
            fromFile:__FILE__ fromLine:__LINE__];
    
    cmd = [NSString stringWithFormat:@"INSERT INTO SidewalkPoints_index VALUES (%ld,%f,%f,%f,%f)",
           (long)refno, location.latitude, location.latitude, location.longitude, location.longitude];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                  fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    return rtn;
}

- (BOOL)deleteSdwkPoint:(NSInteger)refno;
{
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    BOOL rtn = NO;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints SET deleted=1, last_update=%i WHERE id=%ld",
                     iTime, (long)refno];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                  fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    return rtn;
}

+ (BOOL)moveSdwkPoint:(NSInteger)refno
           toLocation:(CLLocationCoordinate2D)location
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    SidewalkData *sdwkd = SidewalkData.new;
    BOOL opened = [sdwkd open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints SET latitude=%f, longitude=%f, last_update=%i WHERE id=%ld",
                     location.latitude, location.longitude, iTime, (long)refno];
    
    rtn = [sdwkd executeCmd:(LPSTR)cmd.UTF8String
               sendToServer:YES
                   fromFile:__FILE__ fromLine:__LINE__];
    
    if (rtn)
    {
        cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints_index SET minY=%f, minX=%f, maxY=%f, "
               "maxX=%f WHERE SidewalkPoints_index.id=%ld",
               location.latitude, location.longitude, location.latitude, location.longitude, (long)refno];
        
        rtn = [sdwkd executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:YES
                       fromFile:__FILE__ fromLine:__LINE__];
    }
    
    [sdwkd close:opened];
    return !rtn;
}

- (void)updateSdwkPoint:(NVSidewalkPoint *)sdwkPoint
{
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints SET note='%@', latitude=%f, longitude=%f, "
                     "slope_front=%f, slope_side=%f, slope_heading=%f, crack_width=%f, width=%f, level_change=%f, "
                     "last_update=%i, condition=%i, obstruction=%i WHERE id=%u",
                     sdwkPoint.note, sdwkPoint.location.latitude, sdwkPoint.location.longitude, sdwkPoint.slopeFront,
                     sdwkPoint.slopeSide, sdwkPoint.slopeHeading, sdwkPoint.crackWidth, sdwkPoint.width, sdwkPoint.levelChange,
                     sdwkPoint.lastUpdate, sdwkPoint.condition, sdwkPoint.obstruction, sdwkPoint.pointID];
    
    [self executeCmd:(LPSTR)cmd.UTF8String
        sendToServer:YES
            fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
}

- (NVSidewalkPoint *)getSdwkPointForRefno:(uint)refno
{
    BOOL opened = [self open];
    sqlite3_stmt *statement = NULL;
    NSString *query = @"SELECT * FROM SidewalkPoints;";
    NVSidewalkPoint *sdwkPoint = NVSidewalkPoint.new;
    int iCol = 1;
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR note = (LPSTR)sqlite3_column_text(statement, iCol++);
        LPSTR street = (LPSTR)sqlite3_column_text(statement, iCol++);
        double latitude = sqlite3_column_double(statement, iCol++);
        double longitude = sqlite3_column_double(statement, iCol++);
        double slopeFront = sqlite3_column_double(statement, iCol++);
        double slopeSide = sqlite3_column_double(statement, iCol++);
        double slopeHeading = sqlite3_column_double(statement, iCol++);
        double crackWidth = sqlite3_column_double(statement, iCol++);
        double width = sqlite3_column_double(statement, iCol++);
        double levelChange = sqlite3_column_double(statement, iCol++);
        int lastUpdate = sqlite3_column_int(statement, iCol++);
        int condition = sqlite3_column_int(statement, iCol++);
        int obstruction = sqlite3_column_int(statement, iCol++);
        int houseNum = sqlite3_column_int(statement, iCol);
        sdwkPoint.pointID = refno;
        sdwkPoint.note = [NSString stringWithUTF8String:note];
        sdwkPoint.street = [NSString stringWithUTF8String:street];
        sdwkPoint.location = CLLocationCoordinate2DMake(latitude, longitude);
        sdwkPoint.slopeFront = slopeFront;
        sdwkPoint.slopeSide = slopeSide;
        sdwkPoint.slopeHeading = slopeHeading;
        sdwkPoint.crackWidth = crackWidth;
        sdwkPoint.width = width;
        sdwkPoint.levelChange = levelChange;
        sdwkPoint.lastUpdate = lastUpdate;
        sdwkPoint.condition = condition;
        sdwkPoint.obstruction = obstruction;
        sdwkPoint.houseNum = houseNum;
    }
    
    [self close:opened];
    return sdwkPoint;
}

@end
