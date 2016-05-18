//
//  CurbRampData.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//
#define CURRENT_INTERSECTION_VERSION "1.1"

#import "CurbRampData.h"
#import "UserDefaults.h"
#import "CRAPI.h"
#import "UIApplication+VersionBuild.h"
int SQLOK(int sqlReturn, sqlite3 *database);

static int fileSequence = 0;

@implementation CurbRampData

static CurbRampData *_statdatabase = nil;

+ (CurbRampData *)databaseForGeoid:(int)geoid
                            create:(BOOL)create
{
    if (!_statdatabase || _statdatabase.geoid != geoid)
        _statdatabase = [[CurbRampData alloc] initWithGeoid:geoid
                                                     create:create];
    
    return _statdatabase;
}
- (id)init
{
    self = [super init];
    return self;
}
- (id)initWithGeoid:(int)geoid
             create:(BOOL)create
{
    if ((self = [super init]))
    {
        _documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _fileName = @"CurbRamps.sqlite";
        _path = [self databasePath:geoid];
        if (!_fileSize || create)
            [self createIntersectionsTable:YES];
    }
    
    return self;
}
- (NSString *)databasePath:(int)geoid
{
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *subDir = [NSString stringWithFormat:@"%@/%i", documentsDirectory, geoid];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    [fileManager createDirectoryAtPath:subDir
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%i/CurbRamps.sqlite3", documentsDirectory, geoid];
    _fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                          error:nil].fileSize;
   
    return dbPath;
}

- (void)dealloc
{
    sqlite3_close(_database);
    NSLog(@"CurbRamp Database dealloc");
}
- (BOOL)open
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        self.isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"CurbRamp Database open");
        
        _fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        rtn = TRUE;
    }
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(sqlite3_close(_database),_database);
        NSLog(@"CurbRamp Database close");
        self.isOpen = NO;
    }
}

- (void)clear
{
    [self close:TRUE];
    
    //BOOL st = [NSFileManager.defaultManager removeItemAtPath:_path
                                                       //error:nil];
}

- (int)datasetVersion
{
    int rtn = -1;
    BOOL opened = [self open];
    
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT max(Version) FROM CURBRAMP_VERSION"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            
            if (version)
                rtn = atoi(version);
        }
        
        SQLOK(sqlite3_finalize(statement), _database);
    }
    
    [self close:opened];
    //return -1;
    return rtn;
}
- (int) getNextUploadFileNum:(int)iPad
{
    int rtn = 1;
    BOOL opened = [self open];
    
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT lastUpdateFileNum FROM Updates WHERE iPadID = %i",iPad];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            rtn = sqlite3_column_int(statement, 0);
        }
        
        SQLOK(sqlite3_finalize(statement), _database);
        query = [NSString stringWithFormat:@"UPDATE Updates SET lastUpdateFileNum=%i  WHERE iPadID = %i",rtn+1,iPad];
        SQLOK(sqlite3_exec(_database, query.UTF8String, 0, 0, 0), _database);
    }
    
    [self close:opened];
    return rtn;
}
- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
{

    BOOL rtn = !SQLOK(sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    if (rtn && sendToServer)
    {
        int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
        int nextFileNum = [self getNextUploadFileNum:iPad];
        if (!_sendToServerFile)
        {
            NSString * softwareVersion = UIApplication.appVersionBuild;
            int iTime = NSDate.timeIntervalSinceReferenceDate;
            _sendToServerFile = [NSString stringWithFormat:@"%@/CurbRampInventory_%i-%i.sql",
                                 CRAPI.sharedInstance.sharedOutputDirectory,iTime,fileSequence++];
            rtn = [[NSString stringWithUTF8String:cmd] writeToFile:_sendToServerFile
                                                        atomically:YES
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
        }
        else
        {
            [CRAPI.sharedInstance appendString:[NSString stringWithUTF8String:cmd] toFile:_sendToServerFile];
        }
    }
    return rtn;
}

- (BOOL)startTransaction
{
    BOOL opened = [self open];
    SQLOK(sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
    return opened;
}

- (void)commitTransaction
{
    SQLOK(sqlite3_exec(_database, "COMMIT", 0, 0, 0), _database);
}

- (BOOL)isCurrentVersion
{
    BOOL rtn = FALSE;
    int dbVersion, currentVersion;
    
    NSString * version = [self dbVersion];
    dbVersion = atoi(version.UTF8String);
    currentVersion = atoi(CURRENT_INTERSECTION_VERSION);
    if (dbVersion == currentVersion)
        rtn = TRUE;
    
    return rtn;
}

- (NSString*)dbVersion
{
    NSString *rtn=@"";
    BOOL opened = [self open];
    int dbVersion, currentVersion;
    
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT VersionID FROM VERSION WHERE vid=1"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            
            if (version)
            {
                rtn = [NSString stringWithUTF8String:version];
            }
        }
        
        SQLOK(sqlite3_finalize(statement), _database);
    }
    
    [self close:opened];
    return rtn;
}

- (BOOL)createIntersectionsTable:(BOOL)dropExistingTables
{
    BOOL rtn = NO;
    
    BOOL opened = [self startTransaction];
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;DROP TABLE IF EXISTS Ramps; DROP TABLE IF EXISTS VERSION;"];
    
    if (dropExistingTables)
        SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, NULL), _database);
//create intersection table
    NSString *query =
    [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS VERSION (vid INTEGER PRIMARY KEY,VersionID CHAR(6));\
 INSERT INTO VERSION VALUES(1,'%s');\
 CREATE TABLE IF NOT EXISTS Intersections (\
 intID INTEGER PRIMARY KEY,\
 lastUpdateTime INTEGER,\
 status INTEGER,\
 assignedTo INTEGER,\
 intX INTEGER,\
 intY INTEGER,\
 rotation INTEGER,\
 ramp1 INTEGER,\
 ramp2 INTEGER,\
 ramp3 INTEGER,\
 ramp4 INTEGER,\
 ramp5 INTEGER,\
 ramp6 INTEGER,\
 ramp7 INTEGER,\
 ramp8 INTEGER,\
 ramp81 INTEGER,\
 ramp23 INTEGER,\
 ramp45 INTEGER,\
 ramp67 INTEGER,\
 xWalkA INTEGER,\
 xWalkB INTEGER,\
 xWalkC INTEGER,\
 xWalkD INTEGER,\
 signal81 INTEGER,\
 signal23 INTEGER,\
 signal45 INTEGER,\
 signal67 INTEGER,\
 nStreets INTEGER,\
 streetNames CHAR(512),\
 streetAZMs CHAR(128),\
 latitude REAL,\
 longitude REAL,\
 intersectionComment CHAR(256),\
 doLater INTEGER,\
 zoomLevel INTEGER);\
 CREATE VIRTUAL TABLE IF NOT EXISTS Intersections_index USING rtree(id,minX, maxX, minY, maxY);",CURRENT_INTERSECTION_VERSION];
    
    rtn = !SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL), _database);
//create ramp table
    query = [NSString stringWithUTF8String:"CREATE TABLE IF NOT EXISTS Ramps (\
 intID INT,\
 rampNum INT,\
 rampID CHAR(16),\
 yearRebuilt INT,\
 timeComplete INT,\
 rampExists INT,\
 isComplete INT,\
 approximateHeading REAL,\
 adjustedRot INT,\
 rampInXWalk INT,\
 xWalkisComplete INT,\
 signalisComplete INT,\
 texture INT,\
 upperLandingObstruction INT,\
 lowerLandingObstruction INT,\
 rampObstruction INT,\
 hasRampCracks INT,\
 hasUpperLandingCracks INT,\
 hasStreetLandingCracks INT,\
 rampWidth INT,\
 rampDepth INT,\
 rampSlopeFront REAL,\
 rampSlopeSide REAL,\
 rampSlopeHeading REAL,\
 upperLandingSlopeFront REAL,\
 upperLandingSlopeSide REAL,\
 upperLandingSlopeHeading REAL,\
 streetLandingSlopeFront REAL,\
 streetLandingSlopeSide REAL,\
 streetLandingSlopeHeading REAL,\
 flareLeftSlopeFront REAL,\
 flareLeftSlopeSide REAL,\
 flareLeftSlopeHeading REAL,\
 flareRightSlopeFront REAL,\
 flareRightSlopeSide REAL,\
 flareRightSlopeHeading REAL,\
 swkLeftSlopeFront REAL,\
 swkLeftSlopeSide REAL,\
 swkLeftSlopeHeading REAL,\
 swkRightSlopeFront REAL,\
 swkRightSlopeSide REAL,\
 swkRightSlopeHeading REAL,\
 hasPEDSignal INT,\
 hasPEDButton INT,\
 PEDButtonHeight INT,\
 PEDButtonDist INT,\
 SteepTopOfCurb INT,\
 PedRampLip INT,\
 lev21x INT, lev21y INT,\
 rampType INT,\
 rampComment CHAR(256),\
 PRIMARY KEY (intID,rampNum ASC));"];
   
    rtn = !SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL), _database);
    query = [NSString stringWithUTF8String:"CREATE TABLE IF NOT EXISTS Updates (\
             iPadID INT,\
             lastUpdateFileNum INT);"];
    rtn = !SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL), _database);
    [self commitTransaction];
    [self close:opened];
    return rtn;
    
}


- (NSString*) outputDataFile:(int)fileNum
{
    NSString* file = [NSString stringWithFormat:@"%@/%i.sql",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"AlleyWalls"],fileNum];
    return file;
}
- (NSString*) outputPictFile:(int)fileNum
{
    NSString* file = [NSString stringWithFormat:@"%@/%i.jpg",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"AlleyWalls"],fileNum];
    return file;
}


- (int) getLastDataUpdateNumber
{
    int lastNum  = 1;
    [self createNextUpdateTable];
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastDataUpdate FROM ALLEYWALL_UPDATES WHERE id=1"];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        lastNum = sqlite3_column_int(statement, 0);
    }
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    return lastNum;
}
+ (int) getLastDataUpdateNum
{
    CurbRampData *awd = CurbRampData.new;
    return [awd getLastDataUpdateNumber];
}
- (BOOL) setLastDataUpdateNum:(int)lastNum
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"UPDATE ALLEYWALL_UPDATES SET LastDataUpdate = %i WHERE id=1",lastNum];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO];
    [self close:opened];
    return rtn;
}

- (BOOL) setLastPictUpdateNum:(int)nextNum
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"UPDATE ALLEYWALL_UPDATES SET LastDataUpdate = %i WHERE id=1",nextNum];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO];
    [self close:opened];
    return rtn;
}

- (int) getLastPictUpdateNumber
{
    int LastNum  = 1;
    [self createNextUpdateTable];
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastPictUpdate FROM ALLEYWALL_UPDATES WHERE id=1"];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LastNum = sqlite3_column_int(statement, 0);
    }
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    return LastNum;
}

- (BOOL)createNextUpdateTable
{
    BOOL rtn = TRUE;
    NSString * cmd = @"CREATE TABLE IF NOT EXISTS ALLEYWALL_UPDATES ('id' INTEGER PRIMARY KEY,'LastDataUpdate' INT,'LastPictUpdate' INT)";
    rtn = [self executeCmd:(char *)cmd.UTF8String
              sendToServer:NO];
    return rtn;
}

- (int) incrementLastDataFileNum
{
    int lastNum = [self getLastDataUpdateNumber];
    if ([NSFileManager.defaultManager fileExistsAtPath:[self outputDataFile:lastNum]])
    {
        [self setLastDataUpdateNum:++lastNum];
    }
    return lastNum;
}
+ (int) incrementLastDataFileNumber
{
    CurbRampData *awd = CurbRampData.new;
    return [awd incrementLastDataFileNum];
}
+ (int) incrementLastPictFileNumber
{
    CurbRampData *awd = CurbRampData.new;
    return [awd incrementLastPictFileNum];
}
- (int) incrementLastPictFileNum
{
    CurbRampData *awd = CurbRampData.new;
    int lastNum = [awd getLastPictUpdateNumber];
    if ([NSFileManager.defaultManager fileExistsAtPath:[awd outputPictFile:lastNum]])
    {
        [awd setLastPictUpdateNum:++lastNum];
    }
    return lastNum;
}
- (BOOL)createPictureDatabase
{
    BOOL rtn = TRUE;
    NSString * cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_PICTURES ('id' INTEGER PRIMARY KEY,'LastDataUpdate' INT,'LastPictUpdate' INT)";
    rtn = [self executeCmd:(char *)cmd.UTF8String
              sendToServer:NO];
    return rtn;
}

- (BOOL) savePictureData:(int)pictNum
                   intID:(int)wallID
                 rampNum:(int)ramp
                    type:(int)type
                  latLon:(LLPOINT)ll
                 heading:(int)heading
{
    CurbRampData *awd = CurbRampData.new;
    [awd createPictureDatabase];
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    return YES;
    
}

@end
