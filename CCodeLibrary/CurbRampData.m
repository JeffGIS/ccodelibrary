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
- (void) setDBFile:(int)geoid
            create:(BOOL)create
{
    _documentsDirectory = UserDefaults.defaults.sharedFilePath;
    _fileName = @"CurbRamps.sqlite";
    _path = [self databasePath:geoid];
    if (!_fileSize || create)
        [self createIntersectionsTable:YES];
}

- (id)init
{
    self = [super init];
    [self setDBFile:CRAPI.sharedInstance.currentGeoid create:NO];
    return self;
}
- (id)initWithGeoid:(int)geoid
             create:(BOOL)create
{
    if ((self = [super init]))
        [self setDBFile:geoid create:create];
    
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
- (NSString*) getSendToServerFile:(int)iPad
{
    int currentFileNum = [self getLastDataUpdateNumber:iPad];
    
    NSString * file = [NSString stringWithFormat:@"%@/%i_%i.sql",
                         [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"],iPad,currentFileNum];
    return file;
}

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
{

    BOOL rtn = !SQLOK(sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    if (rtn && sendToServer)
    {
        int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
        NSString * sendToServerFile = [self getSendToServerFile:iPad];
        int fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:sendToServerFile
                                                                              error:nil].fileSize;
        if (!fileSize)
        {
            int iTime = NSDate.timeIntervalSinceReferenceDate;
            NSString * versions = [NSString stringWithFormat:@"/*ApVer %@ DBVer %s Time %i*/",UIApplication.appVersionBuild,CURRENT_INTERSECTION_VERSION,iTime];
           rtn = appendStringToFile (versions ,sendToServerFile);

        }
        rtn = appendStringToFile ([NSString stringWithUTF8String:cmd] ,sendToServerFile);

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
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;DROP TABLE IF EXISTS Ramps; DROP TABLE IF EXISTS VERSION;DROP TABLE IF EXISTS CURBRAMP_UPDATES;DROP TABLE IF EXISTS CURBRAMP_PICTURES; DROP TABLE IF EXISTS CURBRAMP_NOTES"];
    
    if (dropExistingTables)
        SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, NULL), _database);
//create intersection table
    NSString *cmd =
    [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS VERSION (vid INTEGER PRIMARY KEY,VersionID CHAR(6));\
 INSERT INTO VERSION VALUES(1,'%s');\
 CREATE TABLE IF NOT EXISTS Intersections (\
 intID INTEGER PRIMARY KEY,\
 lastUpdateTime INTEGER,\
 status INTEGER,\
 assignedToPrelim INTEGER,\
 assignedToDetail INTEGER,\
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
    
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
//create ramp table
    cmd = [NSString stringWithUTF8String:"CREATE TABLE IF NOT EXISTS Ramps (\
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
   
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_UPDATES ('iPad' INTEGER PRIMARY KEY,'LastDataUpdate' INT,'LastPictUpdate' INT)";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_PICTURES ('id' INTEGER PRIMARY KEY,'iPadNum' INT,'pictNum' INT,'intID' INT,'rampNum' INT, 'type' INT, 'heading' INT, 'latitude' REAL, 'longitude' REAL)";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_NOTES ('intID' INTEGER PRIMARY KEY,'rampID' INT,'type' INT, 'note' CHAR(4096))";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_STANDARD_NOTES ('noteID' INTEGER PRIMARY KEY,'type' INT,'note' CHAR(4096))";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);

    [self commitTransaction];
    [self close:opened];
    return rtn;
    
}

- (NSString*) outputDataFile:(int)fileNum
{
    NSString* file = [NSString stringWithFormat:@"%@/%i.sql",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"],fileNum];
    return file;
}
- (NSString*) outputPictFile:(int)fileNum
{
    NSString* file = [NSString stringWithFormat:@"%@/%i_%i.jpg",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"],CRAPI.sharedInstance.currentiPadWithinManager,fileNum];
    return file;
}


- (int) getLastDataUpdateNumber:(int)iPad
{
    int lastNum  = 1;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastDataUpdate FROM CURBRAMP_UPDATES WHERE iPad=%i",iPad];
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
- (BOOL) setLastDataUpdateNum:(int)lastNum
                      foriPad:(int)iPad
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"UPDATE CURBRAMP_UPDATES SET LastDataUpdate = %i WHERE iPad=%i",lastNum,iPad];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO];
    [self close:opened];
    return rtn;
}

- (BOOL) setLastPictUpdateNum:(int)lastNum
                      foriPad:(int)iPad
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"UPDATE CURBRAMP_UPDATES SET LastPictUpdate = %i WHERE iPad=%i",lastNum,iPad];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO];
    [self close:opened];
    return rtn;
}

- (int) getLastPictUpdateNumber:(int)iPad
{
    int LastNum  = 0;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastPictUpdate FROM CURBRAMP_UPDATES WHERE iPad=%i",iPad];
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

- (int) incrementLastDataFileNum
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastDataUpdateNumber:iPad];
    if ([NSFileManager.defaultManager fileExistsAtPath:[self outputDataFile:lastNum]])
    {
        [self setLastDataUpdateNum:++lastNum foriPad:iPad];
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
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastPictUpdateNumber:iPad];
    if ([NSFileManager.defaultManager fileExistsAtPath:[self outputPictFile:lastNum]])
    {
        [self setLastPictUpdateNum:++lastNum foriPad:iPad];
    }
    return lastNum;
}
- (BOOL) savePictureData:(int)pictNum
                   intID:(int)intID
                 rampNum:(int)ramp
                    type:(int)type
                  latLon:(LLPOINT)ll
                 heading:(int)heading
{
    BOOL opened = [self open];
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    uint pictID = [self getNextPictID];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_PICTURES VALUES(%i,%i,%i,%i,%i,%i,%i,%f,%f);",
                     pictID,CRAPI.sharedInstance.currentiPadWithinManager,pictNum,intID,ramp,type,heading,ll.lat,ll.lon];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:YES];
    [self close:opened];
    return rtn;
    
}
- (uint) getNextPictID
{
    uint nextID = 1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM CURBRAMP_PICTURES"];
    BOOL opened = [self open];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nextID = sqlite3_column_int(statement, 0);
    }
    nextID = [CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    return nextID;
}
@end
