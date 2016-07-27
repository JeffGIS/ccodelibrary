//
//  CurbRampData.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//
#define CURRENT_INTERSECTION_VERSION "2.0"

#import "CurbRampData.h"
#import "UserDefaults.h"
#import "CRAPI.h"
#import "UIApplication+VersionBuild.h"
#import "SQLiteLib.h"

static int fileSequence = 0;

@implementation CurbRampData

static int nInit=0;

+ (CurbRampData *)databaseForGeoid:(int)geoid
                            create:(BOOL)create
{
    CurbRampData *crd = [[CurbRampData alloc] initWithGeoid:geoid
                                                     create:create];
    return crd;
}
- (void) setDBFile:(int)geoid
            create:(BOOL)create
{
    _documentsDirectory = UserDefaults.defaults.sharedFilePath;
    _fileName = @"CurbRamps.sqlite";
    _path = [self databasePath:geoid];
    if (!_fileSize || create)
        [self createIntersectionsTable:create];
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
        _isOpen = !SQLOK(161,sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"CurbRamp Database open");
        
        _fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        
        [self adjustToLatestVersion];
        rtn = TRUE;
    }
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
        SQLOK(162,sqlite3_close(_database),_database);
        NSLog(@"CurbRamp Database close");
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
        
        SQLOK(163,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            
            if (version)
                rtn = atoi(version);
        }
        
        SQLOK(164,sqlite3_finalize(statement), _database);
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

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
              from:(int)from
{
    BOOL rtn = !SQLOK(from,sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    
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

- (BOOL)startTransaction
{
    BOOL opened = [self open];
    SQLOK(166,sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
    return opened;
}

- (void)commitTransaction
{
    SQLOK(167,sqlite3_exec(_database, "COMMIT", 0, 0, 0), _database);
}

- (void)cancelTransaction
{
    SQLOK(168,sqlite3_exec(_database, "ROLLBACK", 0, 0, 0), _database);
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
        
        SQLOK(169,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            
            if (version)
            {
                rtn = [NSString stringWithUTF8String:version];
            }
        }
        
        SQLOK(170,sqlite3_finalize(statement), _database);
    }
    
    [self close:opened];
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
 SteepTopOfCurb REAL,\\changed from INT in version 2\
 PedRampLip REAL,\\changed from INT in version 2\
 lev21x INT, lev21y INT,\
 rampType INT,\
 rampComment CHAR(256),\
 //\
 //added in version 2.0*\
 //\
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
 PRIMARY KEY (intID,rampNum ASC));"];
   
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
                if (st) st = [self executeCmd:cmd.UTF8String sendToServer:NO from:0];
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
    
    sqlite3_stmt *statement = nil;
    
    SQLOK(178,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 0);
        note = [NSString stringWithUTF8String:text];
    }
    
    SQLOK(179,sqlite3_finalize(statement), _database);
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
    SQLOK(180,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        noteid = (int)sqlite3_column_int(statement, 0);
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 1);
        
        if (!strcmp (text,note.UTF8String))
            noteid = -2;
    }
    
    SQLOK(181,sqlite3_finalize(statement), _database);
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
    
    SQLOK(181,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 0);
        NSString *str = [NSString stringWithUTF8String:text];
        [standardTextArray addObject:str];
    }
    
    SQLOK(182,sqlite3_finalize(statement), _database);
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
    
    SQLOK(183,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int textID = sqlite3_column_int(statement, 0);
        int type = sqlite3_column_int(statement, 1);
        LPSTR text = (LPSTR)sqlite3_column_text(statement, 2);
        if (type == newType && !strcasecmp(text, newText.UTF8String))
            rtn = FALSE;
        maxID = max (maxID,textID);
    }
    SQLOK(184,sqlite3_finalize(statement), _database);
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
- (NSString*) outputPictFile:(int)fileNum
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
    
    SQLOK(185,sqlite3_prepare_v2(_database, cmd.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        lastNum = sqlite3_column_int(statement, 0);
        lastPictNum = sqlite3_column_int(statement, 1);
    }
    SQLOK(186,sqlite3_finalize(statement), _database);
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
    
    SQLOK(187,sqlite3_prepare_v2(_database, cmd.UTF8String, -1, &statement, 0), _database);
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    SQLOK(188,sqlite3_finalize(statement), _database);
    
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
    
    SQLOK(189,sqlite3_prepare_v2(_database, cmd.UTF8String, -1, &statement, 0), _database);
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    SQLOK(190,sqlite3_finalize(statement), _database);
    
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
    
    SQLOK(191,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LastNum = sqlite3_column_int(statement, 0);
    }
    SQLOK(192,sqlite3_finalize(statement), _database);
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
        NSString * logmess = [NSString stringWithFormat:@"Curbramp data file num error",lastNum,nextNum];
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
    
    SQLOK(193,sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nextID = sqlite3_column_int(statement, 0);
    }
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(194,sqlite3_finalize(statement), _database);
    [self close:opened];
    return nextID;
}
- (uint) getNextNoteID
{
    uint nextID = 1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM CURBRAMP_NOTES"];
    BOOL opened = [self open];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(195,sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nextID = sqlite3_column_int(statement, 0);
    }
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(196,sqlite3_finalize(statement), _database);
    [self close:opened];
    return nextID;
}

- (BOOL) updateFromFile:(NSString*)file
{
    BOOL rtn = TRUE;
    BOOL opened = [self open];
    int line = 0;
    FILE *fid = fopen(file.UTF8String, "rb");
    int totLen = (int)FileLength(fid);
    int maxLineLen = totLen+2;
    LPSTR str = malloc(totLen+4);
    [self startTransaction];
    while (rtn && fgetstring(str, maxLineLen, fid))
    {
        rtn = [self executeCmd:str
                  sendToServer:NO
                          from:1672];
        line++;
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


@end
