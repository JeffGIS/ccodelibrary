//
//  CurbRampData.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import "CurbRampData.h"
#import "UserDefaults.h"
#import "CRAPI.h"
int SQLOK(int sqlReturn, sqlite3 *database);

static int fileSequence = 0;

@implementation CurbRampData

static CurbRampData *_statdatabase = nil;

+ (CurbRampData *)databaseForGeoid:(int)geoid
{
    if (!_statdatabase || _statdatabase.geoid != geoid)
        _statdatabase = [[CurbRampData alloc] initWithGeoid:geoid];
    
    return _statdatabase;
}
- (id)init
{
    self = [super init];
    return self;
}
- (id)initWithGeoid:(int)geoid
{
    if ((self = [super init]))
    {
        _documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _fileName = @"CurbRamps.sqlite";
        _path = [self databasePath:geoid];
        [self createIntersectionsTable:NO];
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
- (void)open
{
    if (!_isOpen)
    {
        self.isOpen = YES;
        self.isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"CurbRamp Database open");
        
        _fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
    }
}

- (void)close
{
    SQLOK(sqlite3_close(_database),_database);
    NSLog(@"CurbRamp Database close");
    self.isOpen = NO;
}

- (void)clear
{
    [self close];
    
    //BOOL st = [NSFileManager.defaultManager removeItemAtPath:_path
                                                       //error:nil];
}

- (int)datasetVersion
{
    int rtn = -1;
    [self open];
    
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
    
    [self close];
    //return -1;
    return rtn;
}

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
     useUniqueFile:(BOOL)uniqueFile
{
    BOOL rtn = !SQLOK(sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    if (rtn && sendToServer)
    {
        if (uniqueFile || !_sendToServerFile)
        {
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

- (void)startTransaction
{
    [self open];
    SQLOK(sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
}

- (void)commitTransaction
{
    SQLOK(sqlite3_exec(_database, "COMMIT", 0, 0, 0), _database);
}

- (BOOL)createIntersectionsTable:(BOOL)dropExistingTables
{
    BOOL rtn = NO;
    
    [self open];
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;DROP TABLE IF EXISTS Ramps;"];
    
    if (dropExistingTables)
        SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, NULL), _database);
//create intersection table
    NSString *query =
    [NSString stringWithUTF8String:"CREATE TABLE IF NOT EXISTS Intersections (\
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
                       longitude REAL);\
                       CREATE VIRTUAL TABLE IF NOT EXISTS Intersections_index USING rtree(id,minX, maxX, minY, maxY);"];
    
    rtn = !SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL), _database);
//create ramp table
    query = [NSString stringWithUTF8String:"CREATE TABLE IF NOT EXISTS Ramps (\
             intID INT,\
             rampNum INT,\
             rampID CHAR(16),\
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
             PRIMARY KEY (intID,rampNum ASC));"];
   
    rtn = !SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL), _database);

    [self close];
    return rtn;
    
}
@end
