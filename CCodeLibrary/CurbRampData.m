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
    
    BOOL st = [NSFileManager.defaultManager removeItemAtPath:_path
    error:nil];
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

- (BOOL)createIntersectionsTable
{
    BOOL rtn = NO;
    
    [self open];
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;"];
    
    SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, NULL), _database);
//create intersection table
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE Intersections (\
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
                       CREATE VIRTUAL TABLE Intersections_index USING rtree(id,minX, maxX, minY, maxY);"];
    
    rtn = !SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL), _database);
//create ramp table
    /*
     (nonatomic) int rampNum;
     (nonatomic, copy) NSString *rampID;
     (nonatomic) int timeComplete;
     BOOL rampExists;
     BOOL isComplete;
     (nonatomic) CGFloat approximateHeading;
     (nonatomic) int adjustedRot;
     BOOL rampInXWalk;
     BOOL xWalkisComplete;
     BOOL signalisComplete;
     (nonatomic) enum textures texture;
     (nonatomic) enum obstructions upperLandingObstruction;
     (nonatomic) enum obstructions lowerLandingObstruction;
     (nonatomic) enum obstructions rampObstruction;
     BOOL hasRampCracks;
     BOOL hasUpperLandingCracks;
     BOOL hasStreetLandingCracks;
     (nonatomic) int rampWidth, rampDepth;
     (nonatomic) CGFloat rampSlopeFront;
     (nonatomic) CGFloat rampSlopeSide;
     (nonatomic) CGFloat rampSlopeHeading;
     (nonatomic) CGFloat upperLandingSlopeFront;
     (nonatomic) CGFloat upperLandingSlopeSide;
     (nonatomic) CGFloat upperLandingSlopeHeading;
     (nonatomic) CGFloat streetLandingSlopeFront;
     (nonatomic) CGFloat streetLandingSlopeSide;
     (nonatomic) CGFloat streetLandingSlopeHeading;
     (nonatomic) CGFloat flareLeftSlopeFront;
     (nonatomic) CGFloat flareLeftSlopeSide;
     (nonatomic) CGFloat flareLeftSlopeHeading;
     (nonatomic) CGFloat flareRightSlopeFront;
     (nonatomic) CGFloat flareRightSlopeSide;
     (nonatomic) CGFloat flareRightSlopeHeading;
     (nonatomic) CGFloat swkLeftSlopeFront;
     (nonatomic) CGFloat swkLeftSlopeSide;
     (nonatomic) CGFloat swkLeftSlopeHeading;
     (nonatomic) CGFloat swkRightSlopeFront;
     (nonatomic) CGFloat swkRightSlopeSide;
     (nonatomic) CGFloat swkRightSlopeHeading;
     BOOL hasPEDSignal, hasPEDButton;
     (nonatomic) int PEDButtonHeight, PEDButtonDist;
     (nonatomic) CGFloat SteepTopOfCurb;
     (nonatomic) CGFloat PedRampLip;
     (nonatomic) int lev21x, lev21y;
     RampType rampType;
    */

    [self close];
    return rtn;
    
}
@end
