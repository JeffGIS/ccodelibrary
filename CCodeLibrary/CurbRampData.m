//
//  CurbRampData.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//
#define CURRENT_INTERSECTION_VERSION "4.0"

#import "CurbRampData.h"
#import "UserDefaults.h"
#import "SharedDefaults.h"
#import "CRAPI.h"
#import "UIApplication+VersionBuild.h"
#import "SQLiteLib.h"
#include "shr.h"

static int fileSequence = 0;

@implementation  NVSidewalkPoint

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _note = @"";
        _street = @"";
    }
    
    return self;
}

@end

@implementation CurbRampData

static int nInit=0;

+ (CurbRampData *)databaseForGeoid:(int)geoid
                            create:(BOOL)create
{
    CurbRampData *crd = [[CurbRampData alloc] initWithGeoid:geoid
                                                     create:create];
    return crd;
}

+ (BOOL)deleteAllPhotos
{
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *error = nil;
    
    NSString *dir = [NSString stringWithFormat:@"%@",
                     [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"]];
    
    for (NSString *file in [fm contentsOfDirectoryAtPath:dir error:&error])
    {
        if (!error)
        {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", dir, file]
                                          error:&error];
            if (!success || error)
            {
                NSLog(@"ERROR: File %@ couldn't be removed!", file);
                return NO;
            }
        }
        
        else
        {
            NSLog(@"ERROR: Directory %@ couldn't be accessed!", dir);
            return NO;
        }
    }
    
    return YES;
}

- (void) setDBFile:(int)geoid
            create:(BOOL)create
{
    _documentsDirectory = UserDefaults.defaults.sharedFilePath;
    _fileName = @"CurbRamps.sqlite";
    _path = [self databasePath:geoid];
    if (!_fileSize || create)
    {
        [self createIntersectionsTable:create];
    }
}
- (id)init
{
    self = [super init];
    [self setDBFile:CRAPI.sharedInstance.currentGeoid create:NO];
    nInit++;
    return self;
}
- (id)initWithGeoid:(int)geoid
             create:(BOOL)create
{
    if ((self = [super init]))
        [self setDBFile:geoid create:create];
    self.geoid = geoid;
    
    nInit++;
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

- (NSString *)databasePath
{
    return [self databasePath:CRAPI.sharedInstance.currentGeoid];
}

- (void)dealloc
{
    nInit--;

    [self close:YES];
    NSLog(@"CurbRamp Database dealloc");
}
- (BOOL)open
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        _transactionActive = NO;
        _isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(self.path.UTF8String, &_database), _database);
        //NSLog(@"CurbRamp Database open");
        
        _fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        
        if (_fileSize)
        {
            [self createSidewalkTables:FALSE];
            [self adjustToLatestVersion];
        }
        rtn = TRUE;
    }
    return rtn;
}

- (BOOL) createSidewalkTables:(BOOL)forceDelete
{
    BOOL rtn = TRUE;
    if (CRAPI.sharedInstance.canUseSdwk)
    {
        if (!doesSQLiteTableExist("SidewalkPoints",_database) || forceDelete)
        {
            NSString *cmd = @"DROP TABLE IF EXISTS SidewalkPoints;DROP TABLE IF EXISTS SidewalkPoints_index;CREATE TABLE IF NOT EXISTS SidewalkPoints (id INTEGER PRIMARY KEY, note CHAR(512), street CHAR(64), latitude REAL, longitude REAL, fromIntersection INT,steps INT, slope_front REAL, slope_side REAL, slope_heading REAL, crack_width REAL, width REAL, level_change REAL, last_update INT, condition INT, obstruction INT, house_num INT, type INT, deleted INT); CREATE VIRTUAL TABLE IF NOT EXISTS SidewalkPoints_index USING rtree (id, minX, maxX, minY, maxY);";
            rtn = [self executeCmd:(char *)cmd.UTF8String
                      sendToServer:YES
                              from:1662];
        }
    }
    return rtn;
}
+ (BOOL) clearSidewalkTables
{
    BOOL rtn = FALSE;
    CurbRampData *crd = CurbRampData.new;
    BOOL opened = [crd open];
    rtn = [crd createSidewalkTables:TRUE];
    [crd close:opened];
    return rtn;
}

- (BOOL)createNextUpdateTable
{
    BOOL rtn = TRUE;
    NSString * cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_UPDATES ('iPad' INTEGER PRIMARY KEY,'LastDataUpdate' INT,'LastPictUpdate' INT)";
    
    rtn = [self executeCmd:(char *)cmd.UTF8String
              sendToServer:NO
                      from:1662];
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        SQLOK(__FILE__,__LINE__,SQLite_Close(&_database),_database);
        //NSLog(@"CurbRamp Database close");
        _isOpen = NO;
    }
}

- (void)clear
{
    [self close:TRUE];
    
    NSError *error = nil;
    
    BOOL success = [NSFileManager.defaultManager removeItemAtPath:_path
                                                            error:&error];
    
    if (success)
        NSLog(@"Deleted %@ from device", _path);
    
    else
        NSLog(@"Could not delete %@:%@ ", _path, error.localizedDescription);
}

- (int)datasetVersion
{
    int rtn = -1;
    BOOL opened = [self open];
    
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT max(VersionID) FROM VERSION"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            
            if (version)
                rtn = atoi(version);
        }
        
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    }
    
    [self close:opened];
    //return -1;
    return rtn;
}
- (NSString*) getSendToServerFile:(int)iPad
{
    int pictNum;
    int currentFileNum = [self getLastDataUpdateNumber:iPad
                          lastPictNum:&pictNum];
    
    NSString * file = [NSString stringWithFormat:@"%@/%i_%i.sql",
                         [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"],iPad,currentFileNum];
    return file;
}

- (BOOL)executeCmd:(LPCSTR)cmd
      sendToServer:(BOOL)sendToServer
              from:(int)from
{
    BOOL rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    
    if (rtn && sendToServer)
    {
        int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
        NSString * sendToServerFile = [self getSendToServerFile:iPad];
        
        int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:sendToServerFile
                                                                              error:nil].fileSize;
        
        if (!fileSize)
        {
            int iTime = NSDate.timeIntervalSinceReferenceDate;
            
            NSString *versions = [NSString stringWithFormat:@"/*ApVer %@ DBVer %s Time %i*/",
                                  UIApplication.appVersionBuild,CURRENT_INTERSECTION_VERSION,iTime];
            
            rtn = appendStringToFile (versions, sendToServerFile);
        }
        
        rtn = appendStringToFile([NSString stringWithUTF8String:cmd], sendToServerFile);
    }
    else if (sendToServer)
    {
        [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"COMMAND:%s",cmd]];
    }

    
    return rtn;
}
- (BOOL)executeCmd:(LPCSTR)cmd
      sendToServer:(BOOL)sendToServer
          fromFile:(LPSTR)fromFile
          fromLine:(int)fromLine
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    BOOL rtn = !SQLOK(fromFile,fromLine,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    if (rtn && sendToServer)
    {
        NSString * sendToServerFile = [self getSendToServerFile:iPad];
        int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:sendToServerFile
                                                                           error:nil].fileSize;
        if (!fileSize)
        {
            int iTime = NSDate.timeIntervalSinceReferenceDate;
            NSString * versions = [NSString stringWithFormat:@"/*ApVer %@ DBVer %s Time %i*/",
                                   UIApplication.appVersionBuild,CURRENT_INTERSECTION_VERSION,iTime];
            rtn = appendStringToFile (versions ,sendToServerFile);
        }
        rtn = appendStringToFile ([NSString stringWithUTF8String:cmd] ,sendToServerFile);
    }
    return rtn;
}


- (BOOL)startTransaction
{
    BOOL opened = [self open];
    if (!_transactionActive)
        SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN", 0, 0, 0), _database);
    _transactionActive = YES;
    return opened;
}

- (void)commitTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT", 0, 0, 0), _database);
    _transactionActive = NO;
}

- (void)cancelTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "ROLLBACK", 0, 0, 0), _database);
    _transactionActive = NO;
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
    NSString *rtn = @"";
    BOOL opened = [self open];
    int dbVersion = 0, currentVersion = 0;
    
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT VersionID FROM VERSION WHERE vid=1"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            
            if (version)
            {
                rtn = [NSString stringWithUTF8String:version];
            }
        }
        
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    }
    
    [self close:opened];
    return rtn;
}
- (BOOL)createPriorityLocationsTable:(BOOL)dropExistingTable
{
    BOOL rtn = NO;
    NSString *dropQuery = @"DROP TABLE IF EXISTS PriorityLocations;DROP TABLE IF EXISTS PriorityLocations_index;";
    
    if (dropExistingTable)
    {
        rtn = [self executeCmd:(LPSTR)dropQuery.UTF8String
                  sendToServer:YES
                          from:1675];
        
    }

    NSString *cmd = @"CREATE TABLE IF NOT EXISTS PriorityLocations ('locationID' INTEGER PRIMARY KEY,'Name' CHAR(256),'Type' INT, 'Category' CHAR(32),'Latitude' DOUBLE, 'Longitude' DOUBLE, 'Radius' DOUBLE, 'Offset' INT)";
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1677];
    return rtn;
}
- (BOOL)createIntersectionsTable:(BOOL)dropExistingTables
{
    BOOL rtn = NO;
    BOOL opened = [self startTransaction];
    
    NSString *dropQuery = @"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;DROP TABLE IF EXISTS Ramps;DROP TABLE IF EXISTS VERSION;DROP TABLE IF EXISTS CURBRAMP_UPDATES;DROP TABLE IF EXISTS CURBRAMP_PICTURES;DROP TABLE IF EXISTS CURBRAMP_NOTES;DROP TABLE IF EXISTS CURBRAMP_STANDARD_TEXT";
    
    if (dropExistingTables)
    {
        rtn = [self executeCmd:(LPSTR)dropQuery.UTF8String
                  sendToServer:NO
                          from:1675];

    }
    NSString *cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_UPDATES ('iPad' INTEGER PRIMARY KEY,'LastDataUpdate' INT,'LastPictUpdate' INT)";
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1677];
    
//create intersection table
 cmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS VERSION (vid INTEGER PRIMARY KEY,VersionID CHAR(6));\
 INSERT OR REPLACE INTO VERSION VALUES(1,'%s');\
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
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1676];
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
 PEDSignalType INT,\
 PEDButtonType INT,\
 PEDButtonHeight INT,\
 PEDButtonDist INT,\
 SteepTopOfCurb REAL,\
 PedRampLip REAL,\
 lev21x INT, lev21y INT,\
 rampType INT,\
 rampComment CHAR(256),\
 pedButtonAudibleWalkIndicationType INT,\
 pedButtonHasLocatorTone INT,\
 pedButtonHasInfoSign INT,\
 pedButtonHasBraille INT,\
 pedButtonHasTactileArrow INT,\
 pedButtonLocatorToneVolume INT,\
 pedButtonAudibleWalkIndicationVolume INT,\
 rampCrackWidth REAL,\
 upperLandingCrackWidth REAL,\
 streetLandingCrackWidth REAL,\
 leftSidewalkCrackWidth REAL,\
 rightSidewalkCrackWidth REAL,\
 curbCutDist REAL,\
 bumpWidth REAL,\
 bumpHeight REAL,\
 detectableWidth INT,\
 detectableDepth INT,\
 FromFileID CHAR(12),PRIMARY KEY (intID,rampNum ASC));"];
   
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1677];
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_PICTURES ('id' INTEGER PRIMARY KEY,'iPadNum' INT,'pictNum' INT,'intID' INT,'rampNum' INT, 'type' INT, 'heading' INT, 'latitude' REAL, 'longitude' REAL, 'time' INT)";
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1678];
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_NOTES ('id' INTEGER PRIMARY KEY,'intID' INT,'corner' INT,'rampID' INT,'type' INT, 'note' CHAR(4096))";
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1679];
    cmd = @"CREATE TABLE IF NOT EXISTS CURBRAMP_STANDARD_TEXT ('textID' INTEGER PRIMARY KEY,'type' INT,'text' CHAR(4096))";
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                      from:1680];

    if (opened)
        [self commitTransaction];
    [self close:opened];
    return rtn;
}

- (BOOL) adjustToLatestVersion
{
    BOOL rtn = TRUE;
    
    int currentVersion = [self datasetVersion];
    int latestVersion = atoi (CURRENT_INTERSECTION_VERSION);
    
    for (int version = currentVersion; version < latestVersion;version++)
    {
        switch (version)
        {
            case 3://convert version 3 to version 4
            {
                BOOL st = TRUE;
                rtn = FALSE;
                [self startTransaction];
                NSString * cmd = @"";
                cmd = @"ALTER TABLE Ramps ADD COLUMN FromFileID CHAR(12);";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN CornerID INT;";
                st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN Retired INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = [NSString stringWithFormat:@"UPDATE Version SET VersionID = '%s' WHERE vid = 1;",CURRENT_INTERSECTION_VERSION];
                st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                if (st)
                {
                    [self commitTransaction];
                    rtn = TRUE;
                }
                else
                [self cancelTransaction];
            }
            break;
            case 2://convert version 2 to version 3
            {
                BOOL st = TRUE;
                rtn = FALSE;
                [self startTransaction];
                NSString * cmd = @"";
                cmd = @"ALTER TABLE Ramps ADD COLUMN detectableWidth INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN detectableDepth INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = [NSString stringWithFormat:@"UPDATE Version SET VersionID = '%s' WHERE vid = 1;",CURRENT_INTERSECTION_VERSION];
                st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                if (st)
                {
                    [self commitTransaction];
                    rtn = TRUE;
                }
                else
                [self cancelTransaction];
            }
            break;
           case 1://convert version 1 to version 2
            {
                BOOL st = TRUE;
                rtn = FALSE;
                [self startTransaction];
                NSString * cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonAudibleWalkIndicationType INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonHasLocatorTone INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonHasInfoSign INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonHasBraille INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonHasTactileArrow INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonLocatorToneVolume INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN pedButtonAudibleWalkIndicationVolume INT;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN rampCrackWidth REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN upperLandingCrackWidth REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN streetLandingCrackWidth REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN leftSidewalkCrackWidth REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN rightSidewalkCrackWidth REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN curbCutDist REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN bumpWidth REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = @"ALTER TABLE Ramps ADD COLUMN bumpHeight REAL;";
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                cmd = [NSString stringWithFormat:@"UPDATE Version SET VersionID = '%s' WHERE vid = 1;",CURRENT_INTERSECTION_VERSION];
                st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
                if (st)
                {
                    [self commitTransaction];
                    rtn = TRUE;
                }
                else
                    [self cancelTransaction];
            }
                break;
        }
    }
    return rtn;
}

- (NSString *)getNote:(int)intID
               corner:(int)corner
                 ramp:(int)ramp
                 type:(int)type
{
    NSString *note = NSString.new;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT note FROM CURBRAMP_NOTES WHERE intID = %i AND corner = %i AND rampID = %i AND type=%i",
                       intID, corner, ramp, type];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 0);
        note = [NSString stringWithUTF8String:text];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    note = [note stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
    
    return note;
}

- (BOOL)addNote:(NSString *)note
   intersection:(int)intID
         corner:(int)corner
           ramp:(int)ramp
           type:(int)type
{
    BOOL rtn = NO;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT id,note FROM CURBRAMP_NOTES WHERE intID = %i AND corner = %i AND rampID = %i AND type=%i",
                       intID, corner, ramp, type];
    
    sqlite3_stmt *statement;
    int noteid = -1;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        noteid = (int)sqlite3_column_int(statement, 0);
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 1);
        
        if (!strcmp (text,note.UTF8String))
            noteid = -2;
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    if (noteid == -1)
        noteid = [self getNextNoteID];
    
    if (noteid > -1)
    {
        note = [note stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        note = [note stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        note = [note stringByReplacingOccurrencesOfString:@"\n" withString:@"|"];
        query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_NOTES VALUES(%i,%i,%i,%i,%i,'%@');",
                 noteid, intID, corner, ramp, type, note];
        
        rtn = [self executeCmd:(LPSTR)query.UTF8String
                  sendToServer:YES
                          from:1663];
    }
    
    [self close:opened];
    
    return rtn;
}

- (NSMutableArray *)loadStandardText:(int)type
{
    NSMutableArray *standardTextArray = [[NSMutableArray alloc] init];
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT text FROM CURBRAMP_STANDARD_TEXT WHERE type=%i",type];
    sqlite3_stmt *statement;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 0);
        NSString *str = [NSString stringWithUTF8String:text];
        [standardTextArray addObject:str];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return standardTextArray;
}

- (BOOL) addStandardText:(NSString*)newText
                    type:(int)newType
{
    BOOL rtn = TRUE;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM CURBRAMP_STANDARD_TEXT"];
    sqlite3_stmt *statement;
    int maxID = 0;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int textID = sqlite3_column_int(statement, 0);
        int type = sqlite3_column_int(statement, 1);
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 2);
        if (type == newType && !strcasecmp(text, newText.UTF8String))
            rtn = FALSE;
        maxID = max (maxID,textID);
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    if (rtn)
    {
        newText = [newText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_STANDARD_TEXT VALUES(%i,%i,'%@');",maxID+1,newType,newText];
        [self executeCmd:(LPSTR)query.UTF8String
            sendToServer:YES
                    from:1665];
    }
    [self close:opened];
    return rtn;
}

- (NSString*) outputDataFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString* file = [NSString stringWithFormat:@"%@/%i_%i.sql",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"],iPad,fileNum];
    return file;
}

- (NSString *)outputPictFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString* file = [NSString stringWithFormat:@"%@/%i_%i.jpg",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"CurbRamps"],iPad,fileNum];
    return file;
}

- (int) getLastDataUpdateNumber:(int)iPad
                    lastPictNum:(int*)pictNum
{
    int lastNum  = 0;
    int lastPictNum = 0;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT LastDataUpdate,LastPictUpdate FROM CURBRAMP_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
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
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_UPDATES VALUES(%i,1,0);",iPad];
        [self executeCmd:(LPSTR)cmd.UTF8String
            sendToServer:NO
                    from:1664];
    }
    [self close:opened];
    *pictNum = lastPictNum;
    return lastNum;
}
- (BOOL) setLastDataUpdateNum:(int)lastNum
                      pictNum:(int)pictNum
                      foriPad:(int)iPad
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_UPDATES VALUES(%i,%i,%i);",iPad,lastNum,pictNum];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO
                           from:1666];
    [self close:opened];
    return rtn;
}
- (BOOL) setLastDataUpdateNum:(int)lastNum
                      foriPad:(int)iPad
{
    BOOL rtn= FALSE;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT * FROM CURBRAMP_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, cmd.UTF8String, -1, &statement, 0), _database);
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    if (!haveRecord)
    {
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_UPDATES VALUES(%i,1,0);",iPad];
        rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:NO
                          from:1667];
    }
    cmd = [NSString stringWithFormat:@"UPDATE CURBRAMP_UPDATES SET LastDataUpdate = %i WHERE iPad=%i",lastNum,iPad];
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:NO
                      from:1668];
    [self close:opened];
    return rtn;
}

- (BOOL) setLastPictUpdateNum:(int)lastNum
                      foriPad:(int)iPad
{
    BOOL rtn= FALSE;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT * FROM CURBRAMP_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, cmd.UTF8String, -1, &statement, 0), _database);
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    if (!haveRecord)
    {
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_UPDATES VALUES(%i,1,0);",iPad];
        rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:NO
                          from:1669];
    }
    cmd = [NSString stringWithFormat:@"UPDATE CURBRAMP_UPDATES SET LastPictUpdate = %i WHERE iPad=%i",lastNum,iPad];
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:NO
                      from:1670];
    [self close:opened];
    return rtn;
}

- (int) getLastPictUpdateNumber:(int)iPad
{
    int LastNum  = 0;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastPictUpdate FROM CURBRAMP_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LastNum = sqlite3_column_int(statement, 0);
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return LastNum;
}

- (int) incrementLastDataFileNum
{
    int pictNum;
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastDataUpdateNumber:iPad
                                    lastPictNum:&pictNum];
    int nextNum = max(1,lastNum);
    NSString* file = [self outputDataFile:nextNum iPad:iPad];
    
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    while (fileSize > 0)
    {
        nextNum++;
        file = [self outputDataFile:nextNum iPad:iPad];
        fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    }
    if (nextNum > lastNum)
        [self setLastDataUpdateNum:nextNum pictNum:pictNum foriPad:iPad];
    if (nextNum - lastNum > 1)
    {
        NSString *logmess = @"Curbramp data file num error";
        [CRAPI.sharedInstance logToErrorFile:logmess];
    }
    return nextNum;
}


+ (int) incrementLastDataFileNumber
{
    CurbRampData *crd = CurbRampData.new;
    return [crd incrementLastDataFileNum];
}
+ (int) incrementLastPictFileNumber
{
    CurbRampData *crd = CurbRampData.new;
    return [crd incrementLastPictFileNum];
}
- (int) incrementLastPictFileNum
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastPictUpdateNumber:iPad];
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:[self outputDataFile:lastNum
                                                                                             iPad:CRAPI.sharedInstance.currentiPadWithinManager]
                                                                       error:nil].fileSize;
    if (fileSize > 0)
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
 
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CURBRAMP_PICTURES VALUES(%i,%i,%i,%i,%i,%i,%i,%f,%f,%i);",
                     pictID,CRAPI.sharedInstance.currentiPadWithinManager,pictNum,intID,ramp,type,heading,ll.lat,ll.lon,iTime];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:YES
                           from:1671];
    [self close:opened];
    return rtn;
    
}
- (uint) getNextPictID
{
    uint nextID = 1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM CURBRAMP_PICTURES"];
    BOOL opened = [self open];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nextID = sqlite3_column_int(statement, 0);
    }
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return nextID;
}
- (uint) getNextNoteID
{
    uint nextID = 1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM CURBRAMP_NOTES"];
    BOOL opened = [self open];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nextID = sqlite3_column_int(statement, 0);
    }
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return nextID;
}

- (BOOL) updateFromFile:(NSString*)file
{
    BOOL rtn = TRUE;
    BOOL opened = [self open];
    int line = 0;
    FILE *fid = fopen(file.UTF8String, "rb");
    int totLen = (int)FileLengthF(fid);
    int maxLineLen = totLen+2;
    LPSTR str = malloc(totLen+4096);
    [self startTransaction];
    if (fgetstringF(str, maxLineLen, fid))
    {
        int fromVer = atoi (CURRENT_INTERSECTION_VERSION);
        int toVer = atoi (CURRENT_INTERSECTION_VERSION);
        LPSTR vloc = strstr (str,"DBVer ");
        if (vloc)
            fromVer = atoi (vloc+6);
        while (rtn && fgetstringF(str, maxLineLen, fid))
        {
            convertVersion (str,fromVer,toVer);
            rtn = [self executeCmd:str
                      sendToServer:NO
                              from:1672];
            line++;
        }
    }
    fclose(fid);
    if (!rtn) //file has to be edited on server (by GSSi) before more data can be loaded
    {
        [self cancelTransaction];
        NSString * cmd = [NSString stringWithUTF8String:str];
        NSString * header = [NSString stringWithFormat:@"Data load failure in file %@ at line %i",[file lastPathComponent],line];
        [CRAPI.sharedInstance logToErrorFile:cmd withHeader:header];
    }
    else
        [self commitTransaction];
    free(str);
    [self close:opened];
    return rtn;
}

void convertVersion (LPSTR str,int fromVer,int toVer)
{
    int version = fromVer;
    
    while (version < toVer)
    {
        switch (version++)
        {
            case 1:
                convertVersion_1_to_2 (str);
                break;
            case 2:
                convertVersion_2_to_3 (str);
                break;
        }
    }
    return;
}
void convertVersion_1_to_2 (LPSTR str)
{
    LPSTR ploc = strstr (str,"INSERT OR REPLACE INTO Ramps VALUES(");
    if (ploc)
    {
        LPSTR pEnd = strrchr (ploc,')');
        sprintf (pEnd,",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);");
    }
}

void convertVersion_2_to_3 (LPSTR str)
{
    LPSTR ploc = strstr (str,"INSERT OR REPLACE INTO Ramps VALUES(");
    if (ploc)
    {
        LPSTR pEnd = strrchr (ploc,')');
        sprintf (pEnd,",0,0);");
    }
}

+ (BOOL)saveCalibration
{
    double _deviceVals[9][4]={0};
    double _targetValues[5]={0};
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSArray *calibrationValues = SharedDefaults.defaults.calibrationValueArray;
    NSArray *targetValues = [calibrationValues[NVCalibrationArrayIndexValue] copy];
    int nCalibrationPoints = (int)targetValues.count;
    int currentType = (NVCalibrationType)[calibrationValues[NVCalibrationArrayIndexType][0] intValue];
    BOOL displayDegrees = (currentType == NVCalibrationTypeDegrees);
    
    if (nCalibrationPoints > 1 && nCalibrationPoints < 6)
    {
        _targetValues[0] = 0.0;
        NSArray *deviceValuesArray = [calibrationValues[NVCalibrationArrayDeviceValues] copy];
        NSNumber *num = deviceValuesArray[0];
        _deviceVals[0][0] = num.doubleValue;
        _deviceVals[0][1] = [(NSNumber *)deviceValuesArray[1] doubleValue];
        int dvIndex = 2;
        
        for (int i = 1; i < nCalibrationPoints; i++)
        {
            num = targetValues[i];
            _targetValues[i] = num.doubleValue;
            int currentType = (NVCalibrationType)[calibrationValues[NVCalibrationArrayIndexType][i] intValue];
            
            for (int j = 0; j < 4; j++)
            {
                if (dvIndex < deviceValuesArray.count)
                {
                    num = deviceValuesArray[dvIndex++];
                    _deviceVals[i][j] = num.doubleValue;
                }
            }
        }
        
        rtn = YES;
    }
    if (rtn)
    {
        int iPadNumber = CRAPI.sharedInstance.GSSiPadNumber;
        LPSTR targetValsC=malloc(4096);
        LPSTR deviceValsC=malloc(4096);
        sprintf (targetValsC,"%f",_targetValues[0]);
        sprintf (deviceValsC,"%f %f",_deviceVals[0][0],_deviceVals[0][1]);
        for (int i=1;i<nCalibrationPoints;i++)
        {
            sprintf (strchr(targetValsC,0)," %f",_targetValues[i]);
            sprintf (strchr(deviceValsC,0)," %f %f %f %f",_deviceVals[i][0],_deviceVals[i][1],_deviceVals[i][2],_deviceVals[i][3]);
        }
        NSString * cmd = [NSString stringWithFormat:@"$GMDUPDATE([CALIBRATIONDB],iPad=%i;Time=%i,Type=%i;NumPoints=%i;TargetVals='%s';DeviceVals='%s';);",
                          iPadNumber,iTime,currentType,nCalibrationPoints,targetValsC,deviceValsC];
        NSString * header = [NSString stringWithFormat:@"Calibration Data"];
        [CRAPI.sharedInstance logToErrorFile:cmd withHeader:header];
        free (targetValsC);
        free (deviceValsC);
    }
    return rtn;
}
- (int)createNewSdwkPointAtLocation:(CLLocationCoordinate2D)location
                          withHouse:(NSString *)house
                          andStreet:(NSString *)street
{
    BOOL rtn = NO;
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
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO SidewalkPoints (id, fromIntersection, house_num, street, latitude, longitude, deleted) VALUES (%ld,%d,%ld,'%@',%f,%f,0);", (long)refno, CRAPI.sharedInstance.currentIntersection, (long)iHouse, street, location.latitude, location.longitude];
    
    [self executeCmd:(LPSTR)cmd.UTF8String
        sendToServer:YES
            fromFile:__FILE__ fromLine:__LINE__];
    
    cmd = [NSString stringWithFormat:@"INSERT INTO SidewalkPoints_index VALUES (%ld,%f,%f,%f,%f)",
           (long)refno, location.longitude, location.longitude, location.latitude, location.latitude];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                  fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    CRAPI.sharedInstance.currentSidewalkPointID = refno;
    return (int)refno;
}

- (BOOL)deleteSdwkPoint:(NSInteger)refno
{
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    BOOL rtn = NO;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints SET deleted=1, last_update=%i WHERE id=%ld", iTime, (long)refno];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                  fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
    return rtn;
}

- (BOOL)moveSdwkPoint:(NSInteger)refno
           toLocation:(CLLocationCoordinate2D)location
            withHouse:(NSString *)house
            andStreet:(NSString *)street
{
    BOOL rtn = NO;
    NSInteger iHouse = house.integerValue;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints SET house_num=%ld, street='%@', latitude=%f, longitude=%f WHERE id=%ld", (long)iHouse, street, location.latitude, location.longitude, (long)refno];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES
                  fromFile:__FILE__ fromLine:__LINE__];
    
    if (rtn)
    {
        cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints_index SET minY=%f, minX=%f, maxY=%f, maxX=%f WHERE SidewalkPoints_index.id=%ld", location.latitude, location.longitude, location.latitude, location.longitude, (long)refno];
        
        rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:YES
                      fromFile:__FILE__ fromLine:__LINE__];
    }
    
    [self close:opened];
    CRAPI.sharedInstance.currentSidewalkPointID = refno;

    return rtn;
}

- (void)updateSdwkPoint:(NVSidewalkPoint *)sdwkPoint
{
    BOOL opened = [self open];
    
    sdwkPoint.lastUpdate = NSDate.date.timeIntervalSinceReferenceDate;

    NSString *cmd = [NSString stringWithFormat:@"UPDATE SidewalkPoints SET steps=%i, note='%@',fromIntersection=%i, slope_front=%f, slope_side=%f, slope_heading=%f, crack_width=%f, width=%f, level_change=%f, last_update=%i, condition=%d, obstruction=%d, type=%ld WHERE id=%u", sdwkPoint.steps, sdwkPoint.note, sdwkPoint.fromIntersection, sdwkPoint.slopeFront, sdwkPoint.slopeSide, sdwkPoint.slopeHeading, sdwkPoint.crackWidth, sdwkPoint.width, sdwkPoint.levelChange,sdwkPoint.lastUpdate, sdwkPoint.condition, sdwkPoint.obstruction, (long)sdwkPoint.type, sdwkPoint.pointID];
    
    [self executeCmd:(LPSTR)cmd.UTF8String
        sendToServer:YES
            fromFile:__FILE__ fromLine:__LINE__];
    CRAPI.sharedInstance.currentSidewalkPointID = sdwkPoint.pointID;

    [self close:opened];
}

- (NVSidewalkPoint *)getSdwkPointForRefno:(uint)refno
{
    BOOL opened = [self open];
    sqlite3_stmt *statement = NULL;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM SidewalkPoints WHERE id=%u;", refno];
    NVSidewalkPoint *sdwkPoint = NVSidewalkPoint.new;
    int iCol = 1;
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR note = (LPSTR)sqlite3_column_text(statement, iCol++);
        LPSTR street = (LPSTR)sqlite3_column_text(statement, iCol++);
        double latitude = sqlite3_column_double(statement, iCol++);
        double longitude = sqlite3_column_double(statement, iCol++);
        int fromIntersection = sqlite3_column_int(statement, iCol++);
        double slopeFront = sqlite3_column_double(statement, iCol++);
        double slopeSide = sqlite3_column_double(statement, iCol++);
        double slopeHeading = sqlite3_column_double(statement, iCol++);
        double crackWidth = sqlite3_column_double(statement, iCol++);
        double width = sqlite3_column_double(statement, iCol++);
        double levelChange = sqlite3_column_double(statement, iCol++);
        int lastUpdate = sqlite3_column_int(statement, iCol++);
        int condition = sqlite3_column_int(statement, iCol++);
        int obstruction = sqlite3_column_int(statement, iCol++);
        int houseNum = sqlite3_column_int(statement, iCol++);
        int type = sqlite3_column_int(statement, iCol);
        sdwkPoint.pointID = refno;
        
        if (note)
            sdwkPoint.note = [NSString stringWithUTF8String:note];
        
        if (street)
            sdwkPoint.street = [NSString stringWithUTF8String:street];
        
        sdwkPoint.location = CLLocationCoordinate2DMake(latitude, longitude);
        sdwkPoint.fromIntersection = fromIntersection;
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
        sdwkPoint.type = type;
    }
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    [self close:opened];
    CRAPI.sharedInstance.currentSidewalkPointID = refno;
    
    return sdwkPoint;
}

@end
