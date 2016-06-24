//
//  AlleyWallData.m
//  GMMobile
//
//  Created by JEFFREY E SMITH on 4/26/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//
static int fileSequence = 0;
#define COORDINATE_FACTOR 10000000.0

#import "AlleyWallData.h"
#import "CRAPI.h"
#import "UIApplication+VersionBuild.h"

@implementation AlleyWallData

- (void)logError:(int)sqlReturn
          method:(sqlite3*)database
{
    NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i = %i:%s",
                  sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database)]);
}

- (BOOL) continue
{
    if (self.processingID == CRAPI.sharedInstance.keepProcessing)
        return YES;
    return NO;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _fileName = @"AlleyWalls.sqlite";
        _path = [NSString stringWithFormat:@"%@/%@", _documentsDirectory, _fileName];
        
    }
    
    return self;
}

- (void)dealloc
{
    sqlite3_close(_database);
    NSLog(@"AlleyWall Database dealloc");
}
- (BOOL)open
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        self.isOpen = YES;
        self.isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"AlleyWall Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        if (_fileSize)
        {
            [self createNextUpdateTable];
            [self createPictureDatabase];

            BOOL tableOK = NO;
            sqlite3_stmt *stmt = NULL;
            int rc = sqlite3_prepare_v2(_database, "pragma table_info ('ALLEYWALL_UPDATES')", -1, &stmt, NULL);
            
            if (rc==SQLITE_OK)
            {
                //will continue to go down the rows (columns in your table) till there are no more
                while(sqlite3_step(stmt) == SQLITE_ROW)
                {
                    LPSTR colName = (LPSTR)sqlite3_column_text(stmt, 1);
                    LPSTR colType = (LPSTR)sqlite3_column_text(stmt, 2);
                    if (!strcmp (colName,"iPad"))
                        tableOK = YES;
                }
            }
            SQLOK(sqlite3_finalize(stmt), _database);
            if (!tableOK)
            {
                NSString * cmd = @"DROP TABLE ALLEYWALL_UPDATES;";
                
                rtn = [self executeCmd:(char *)cmd.UTF8String
                          sendToServer:NO];
                [self createNextUpdateTable];
            }
        }
        rtn = TRUE;
    }
    
    return rtn;
}

- (void)fileSuccessfullyUploaded:(int)fileNum
{
    
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(sqlite3_close(_database),_database);
        NSLog(@"AlleyWall Database close");
        self.isOpen = NO;
    }
}

- (BOOL)clear
{
    [self close:TRUE];
    
    BOOL st = [NSFileManager.defaultManager removeItemAtPath:_path
                                                       error:nil];
    return st;
}

- (int)datasetVersion
{
    int rtn = -1;
    BOOL opened = [self open];
    
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT max(Version) FROM ALLEYWALLS_VERSION"];
        
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
    return rtn;
}
- (NSString*) getSendToServerFile:(int)iPad
{
    int pictNum;
    int currentFileNum = [self getLastDataUpdateNumber:iPad
                                           lastPictNum:&pictNum];
    
    NSString * file = [self outputDataFile:currentFileNum iPad:iPad];
    
    return file;
}


- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer;
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    if (!iPad)
        sendToServer = YES;
    BOOL rtn = !SQLOK(sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    if (rtn && sendToServer)
    {
        NSString * sendToServerFile = [self getSendToServerFile:iPad];
        int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:sendToServerFile
                                                                           error:nil].fileSize;
        if (!fileSize)
        {
            int iTime = NSDate.timeIntervalSinceReferenceDate;
            NSString * versions = [NSString stringWithFormat:@"/*ApVer %@ DBVer %s Time %i*/",UIApplication.appVersionBuild,CURRENT_ALLEYWALL_VERSION,iTime];
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

- (void)cancelTransaction
{
    SQLOK(sqlite3_exec(_database, "ROLLBACK", 0, 0, 0), _database);
}

- (int)getAlleyLineStatus:(NSInteger)refno
{
    int status = 0;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT ALLEY_LINE.CHECKED FROM ALLEY_LINE WHERE  ALLEY_LINE.id=%li",(long)refno];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement,0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int checked = sqlite3_column_int(statement, 0);
        status = checked;
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    
    return status;
}

- (int)getAlleyLineSeg:(NSInteger)refno
{
    int segid = 0;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT ALLEY_LINE.SEGID FROM ALLEY_LINE WHERE  ALLEY_LINE.id=%li",(long)refno];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement,0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        segid = sqlite3_column_int(statement, 0);
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    
    return segid;
}

- (void)setAlleyLineStatus:(NSInteger)refno
                        to:(int)status
{
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    int segid = [self getAlleyLineSeg:refno];
    NSString *outputDataPath = [NSString stringWithFormat:@"%@/AlleyWallInventory_Alley_%i_%i.txt",
                                CRAPI.sharedInstance.outputDirectory, segid,iTime];
    NSMutableString *outData = [[NSMutableString alloc]init];
    [outData appendString:[NSString stringWithFormat:@"$GMDUPDATE([ALLEYSEGFILE],SEGID=%i,Status=%i;LastUpdate=%i,",segid,status,iTime]];
    [outData appendString:@");"];
    [outData writeToFile:outputDataPath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"UPDATE ALLEY_LINE SET CHECKED = %i, LastUpdate = %i WHERE id=%ld",status,iTime,(long)refno];
    [self executeCmd:(LPSTR)cmd.UTF8String
        sendToServer:YES];
    [self close:opened];
}

- (BOOL)deleteAlleyWallPoint:(NSInteger)refno;
{
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    BOOL rtn = NO;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE ALLEYWALLS_NEW SET Current = 0, Deleted = 1, LastUpdate = %i WHERE id=%ld",
                     iTime, (long)refno];
    
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES];
    
    [self close:opened];
    return rtn;
}

+ (BOOL)moveAlleyWallPoint:(NSInteger)refno
                        to:(CLLocationCoordinate2D)point
{
    BOOL rtn = FALSE;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    AlleyWallData *awd = [[AlleyWallData alloc] init];
    BOOL opened = [awd open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE ALLEYWALLS_NEW SET LATITUDE = %f,LONGITUDE = %f,LastUpdate = %i WHERE id=%ld",
                       point.latitude,point.longitude, iTime,(long)refno];
    
    rtn = sqlite3_exec(awd.database, query.UTF8String, NULL, NULL, NULL);
    
    if (!rtn)
    {
        query = [NSString stringWithFormat:@"UPDATE ALLEYWALLS_NEW_index SET minY=%f,minX=%f,maxY=%f,maxX=%f WHERE ALLEYWALLS_NEW_index.id=%ld",
                 point.latitude,point.longitude, point.latitude,point.longitude, (long)refno];
        
        rtn = sqlite3_exec(awd.database, query.UTF8String, NULL, NULL, NULL);
    }
    
    [awd close:opened];
    return !rtn;
}

- (BOOL)createNewWall:(NSString *)wallID
              atPoint:(CLLocationCoordinate2D)position
            withHouse:(NSString *)house
            andStreet:(NSString *)street
{
/*    INSERT INTO ALLEYWALLS VALUES(1,'6119.1',3536,'10TH AVE S','Yes',100.000000,2.000000,6.500000,'',' $20,000.00 ','CONCBLOCK  POURED','1/27/1987','MB','7','GOOD.  MINOR CRACKS.  ',-93.260388,44.938210,1,0)
    INSERT INTO ALLEYWALLS_index VALUES(2,-93.260613,-93.260613,44.936725,44.936725);
SELECT max(_id) FROM MyTable*/
    BOOL rtn=FALSE;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    NSInteger refno=0;
    NSInteger iHouse = [house integerValue];
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM ALLEYWALLS_NEW"];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        refno = sqlite3_column_int(statement, 0);
        refno = [CRAPI.sharedInstance adjustNextRefno:refno];
    }
    SQLOK(sqlite3_finalize(statement), _database);
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[[NSDate alloc] init]];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO ALLEYWALLS_NEW([id],[Wall ID],[Hse No],[STREET],[InspDate],[Current],[LONGITUDE],[LATITUDE],[LastUpdate]) VALUES(%ld,'%@',%ld,'%@','%@',1,%f,%f,%i);",(long)refno,wallID,(long)iHouse,street,today,position.longitude,position.latitude,iTime];
    [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES];
    cmd = [NSString stringWithFormat:@"INSERT INTO ALLEYWALLS_NEW_index VALUES(%ld,%f,%f,%f,%f)",(long)refno,position.longitude,position.longitude,position.latitude,position.latitude];
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:YES];
    [self close:opened];
    return rtn;
}

-(NSString*)nearestAlleyLine:(CLLocationCoordinate2D*)pt
{
    int nPicked = 0;
    double mind = DBL_MAX;
    DPOINT p1, pickedPoint, minpt, BasePt;
    NSString *minFid = @"";
    int numPoints;
    
    p1.x = pt->longitude;
    p1.y = pt->latitude;
    minpt = p1;
    dbounds bnds = [CRAPI.sharedInstance getBoundsAtPoint:pt andDist:20];
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT ALLEY_LINE.id, ALLEY_LINE.ALLEYSEG, BasePointX, BasePointY,NumPoints,NumLoops,PolyPartLen,Points  FROM ALLEY_LINE,ALLEY_LINE_index WHERE  ALLEY_LINE.id=ALLEY_LINE_index.id AND maxX>=%f AND minX<=%f AND maxY>=%f AND minY<=%f",
                       bnds.xmn, bnds.xmx, bnds.ymn, bnds.ymx];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        //int refno = sqlite3_column_int(statement, 0);
        LPSTR ALLEYSEG = (LPSTR)sqlite3_column_text(statement, 1);
        //NSInteger iALLEYSEG = sqlite3_column_int(statement, 1);
        BasePt.x = sqlite3_column_double(statement, 2);
        BasePt.y = sqlite3_column_double(statement, 3);
        numPoints = sqlite3_column_int(statement,4);
        LPIPOINT offsetPoints = (LPIPOINT)sqlite3_column_blob(statement,7);
        
        LPDPOINT llpoints = malloc(abs(numPoints) * sizeof(DPOINT) + 4);
        
        if (numPoints < 0)
        {
            numPoints = -numPoints;
            LPSPOINT offsetPoints16 = (LPSPOINT)offsetPoints;
            
            for (int i = 0; i < numPoints; i++)
            {
                llpoints[i].x = (BasePt.x + offsetPoints16[i].x / COORDINATE_FACTOR);
                llpoints[i].y = (BasePt.y + offsetPoints16[i].y / COORDINATE_FACTOR);
            }
        }
        
        else for (int i = 0; i < numPoints; i++)
        {
            llpoints[i].x = (BasePt.x + offsetPoints[i].x / COORDINATE_FACTOR);
            llpoints[i].y = (BasePt.y + offsetPoints[i].y / COORDINATE_FACTOR);
        }
        
        if (PICK_POINT_ON_LINE(p1, bnds, &pickedPoint, numPoints, llpoints))
        {
            if (findClosestPoint (&pickedPoint, &minpt, &mind, &p1))
            {
                nPicked++;
                minFid = [NSString stringWithUTF8String:ALLEYSEG];
            }
        }
        free (llpoints);
    }
    
    SQLOK(sqlite3_finalize(statement),_database);
    [self close:opened];
    pt->longitude = minpt.x;
    pt->latitude = minpt.y;

    return minFid;
}

- (NSString *)getNextWallForAlley:(NSString *)nearestAlley
{
    NSString *nextWall = @"";
    CGFloat maxWall = 0;
    BOOL opened = [self open];
    
    if ([nearestAlley isEqualToString:@""])
        return @"";
    
    NSString *minID = [[nearestAlley substringToIndex:4] stringByAppendingString:@".0"];
    NSString *maxID = [[nearestAlley substringToIndex:4] stringByAppendingString:@".99"];
    NSString *query = [NSString stringWithFormat:@"SELECT [Wall ID] FROM ALLEYWALLS_NEW WHERE  [Wall ID] >= %@ AND [Wall ID] <= %@",minID,maxID];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR wallID = (LPSTR)sqlite3_column_text(statement, 0);
        CGFloat fWall = atof (wallID);
        NSInteger iWall = fWall;
        
        if (strlen (wallID)<7)
            fWall = iWall + (fWall - iWall)/10.0;
        
        maxWall = max (fWall,maxWall);
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    
    if (maxWall < 1)
        nextWall = [[nearestAlley substringToIndex:4] stringByAppendingString:@".01"];
    
    else
        nextWall = [NSString stringWithFormat:@"%.2f",maxWall + 0.01];
    
    return nextWall;
}
- (BOOL)createNewTable:(BOOL)sendToServer
{
    BOOL rtn = TRUE;
    NSString * cmd = @"\
    DROP TABLE IF EXISTS ALLEYWALLS_VERSION;\
    CREATE TABLE ALLEYWALLS_VERSION ('Version' CHAR(16));\
    INSERT INTO ALLEYWALLS_VERSION ([VERSION]) VALUES ('1.0');\
    DROP TABLE IF EXISTS ALLEYWALLS_NEW;\
    DROP TABLE IF EXISTS ALLEYWALLS_NEW_index;\
    CREATE VIRTUAL TABLE ALLEYWALLS_NEW_index USING rtree(id,minX, maxX, minY, maxY);\
    DROP TABLE IF EXISTS ALLEYWALL_SEGS;\
    CREATE TABLE IF NOT EXISTS ALLEYWALLS_NEW (\
        'id' INT,\
        'Wall ID' CHAR(8),\
        'InspDate' CHAR(12),\
        'InspBy' CHAR(16),\
        'Current' INT,\
        'LastUpdate' INT,\
        'Deleted' INT,\
        'Complete' INT,\
        'Version' CHAR(16),\
        'Hse No' INT,\
        'STREET' CHAR(64),\
        'CityStamp' CHAR(32),\
        'Photos' INT,\
        'BEARING' REAL,\
        'GroundCoverBehindWall' CHAR(255),\
        'VisibleWeepHoles' CHAR(4),\
        'HistAndConstYear' CHAR(255),\
        'StructuresInWall' CHAR(255),\
        'ItemsBehindWall' CHAR(255),\
        'SoilSurcharge' REAL,\
        'Deficiency' CHAR(255),\
        'Rating' INT,\
        'NumSegments' INT,\
        'Comments' CHAR(255),\
        'LONGITUDE' REAL,\
        'LATITUDE' REAL,\
        PRIMARY KEY('Wall ID','InspDate'));\
    CREATE TABLE IF NOT EXISTS ALLEYWALL_SEGS(\
        'Wall ID' CHAR(8),\
        'InspDate' CHAR(12),\
        'SEGMENT' INT,\
        'SegmentLength' REAL,\
        'SegmentMaxHeight' REAL,\
        'SegmentOffset' REAL,\
        'TypeConst' CHAR(32),\
        'SegmentPlumbness' REAL,\
        'PlumbnessDistance' REAL,\
        PRIMARY KEY('Wall ID','InspDate','SEGMENT'));";
//    if (sendToServer)
//        [CRAPI.sharedInstance clearOutputDirectory];
    [self executeCmd:(char *)cmd.UTF8String
        sendToServer:sendToServer];
    return rtn;
}
-(BOOL)transferExistingTableIntoNewTable:(BOOL)sendToServer
{
    BOOL rtn=FALSE;

    [self startTransaction];
    NSString *query = @"SELECT * FROM ALLEYWALLS;";
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        NSString * newNames = @"";
        NSString * newVals = @"";
        NSString * delim = @"";
        NSString * newSegNames = @"";
        NSString * newSegVals = @"";
        NSString * segdelim = @"";
        int iref=0;
        double longitude=0,latitude=0;
        
        int ncol = sqlite3_column_count(statement);
        for (int icol = 0;icol<ncol;icol++)
        {
            int isSegField = 0;
            LPSTR pFieldName = (LPSTR)sqlite3_column_name(statement,icol);
            LPSTR pVal = (LPSTR)sqlite3_column_text(statement, icol);
            NSString * val = [NSString stringWithUTF8String:pVal];
            val = [val stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            if (!strcmp (pFieldName,"Gar/Struc") || !strcmp(pFieldName," COST"))
                continue;
            NSString * fname = [NSString stringWithUTF8String:pFieldName];
            if (!strcmp (pFieldName,"Wall ID"))
            {
                isSegField = 2;
            }
            if (!strcmp (pFieldName,"InspDate"))
            {
                isSegField = 2;
                NSArray *array = [val componentsSeparatedByString:@"/"];
                if ([array count] == 3)
                    val = [NSString stringWithFormat:@"%@-%2.2li-%2.2li",array[2],(long)[array[0] integerValue],(long)[array[1] integerValue]];
                else
                    val = @"1970-01-01";
            }
            if (!strcmp (pFieldName,"id"))
            {
                iref = atoi (pVal);
            }
            if (!strcmp (pFieldName,"LONGITUDE"))
            {
                longitude = atof (pVal);
            }
            if (!strcmp (pFieldName,"LATITUDE"))
            {
                latitude = atof (pVal);
            }
            if (!strcmp (pFieldName,"City"))
            {
                fname = @"CityStamp";
            }
            if (!strcmp (pFieldName,"Length"))
            {
                fname = @"SegmentLength";
                isSegField = 1;
            }
            if (!strcmp (pFieldName,"Max Hght"))
            {
                fname = @"SegmentMaxHeight";
                isSegField = 1;
            }
            if (!strcmp (pFieldName,"Offset"))
            {
                fname = @"SegmentOffset";
                isSegField = 1;
            }
            if (!strcmp (pFieldName,"Type Const"))
            {
                fname = @"TypeConst";
                isSegField = 1;
            }
            if (isSegField)
            {
                NSString * newSegName = [NSString stringWithFormat:@"%@[%@]",segdelim,fname];
                newSegNames = [newSegNames stringByAppendingString:newSegName];
                newSegVals = [newSegVals stringByAppendingString:[NSString stringWithFormat:@"%@'%@'",segdelim,val]];
                segdelim = @",";
            }
            if (!isSegField || isSegField == 2)
            {
                NSString * newName = [NSString stringWithFormat:@"%@[%@]",delim,fname];
                newNames = [newNames stringByAppendingString:newName];
                newVals = [newVals stringByAppendingString:[NSString stringWithFormat:@"%@'%@'",delim,val]];
                delim = @",";
            }
        }
        NSString* cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALLS_NEW([Current],%@) VALUES(1,%@)",newNames,newVals];
        [self executeCmd:(LPSTR)cmd.UTF8String
            sendToServer:sendToServer];
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALL_SEGS([SEGMENT],%@) VALUES(1,%@)",newSegNames,newSegVals];
        [self executeCmd:(LPSTR)cmd.UTF8String
            sendToServer:sendToServer];
        cmd = [NSString stringWithFormat:@"INSERT INTO ALLEYWALLS_NEW_index VALUES(%i,%f,%f,%f,%f);",iref,longitude,longitude,latitude,latitude];
        [self executeCmd:(LPSTR)cmd.UTF8String
            sendToServer:sendToServer];

    }
    SQLOK(sqlite3_finalize(statement),_database);
/*    INSERT INTO ALLEYWALLS_index VALUES(14,-93.260717,-93.260717,44.910437,44.910437);
    CREATE TABLE ALLEYWALLS ('id' INT,'Wall ID' CHAR(8),'Hse No' INT,'STREET' CHAR(64),'City' CHAR(4),'Length' REAL,'Max Hght' REAL,'Offset' REAL,'Gar/Struc' CHAR(12),' COST' CHAR(12),'Type Const' CHAR(32),'InspDate' CHAR(12),'InspBy' CHAR(8),'Rating' CHAR(16),'Comments' CHAR(255),'LONGITUDE' REAL,'LATITUDE' REAL,'NUMSEGMENTS' INT,'LASTUPDATE' INT,PRIMARY KEY('id' ASC))
 */
    [self commitTransaction];
    return rtn;
}

-(NSString*)getLastInspDateForWall:(NSString*)wallID
{
    sqlite3_stmt *statement;
    NSString * value = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT MAX([InspDate]) FROM ALLEYWALLS_NEW WHERE [Wall ID]=%@",wallID];
    bool found=false;
    
    BOOL opened = [self open];
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
        if (val)
        {
            value = [NSString stringWithUTF8String:val];
            found = true;
        }
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    /*    if (!found)
     {
     
     query = [NSString stringWithFormat:@"SELECT MAX([InspDate]) FROM ALLEYWALLS WHERE [Wall ID]=%@",wallID];
     bool found=false;
     
     [self open];
     SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), "");
     
     if (sqlite3_step(statement) == SQLITE_ROW)
     {
     LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
     if (val)
     {
     value = [NSString stringWithUTF8String:val];
     found = true;
     }
     }
     
     SQLOK(sqlite3_finalize(statement), "");
     }*/
    [self close:opened];
    return value;
}

- (NSString *)getCurrentWallData:(NSString *)wallID
                         forDate:(NSString *)date
                       fieldName:(NSString *)fieldName
{
    NSString *query = @"";
    NSString *value = @"";
    sqlite3_stmt *statement;
    bool found=false;
    //NSArray *dateParts = [date componentsSeparatedByString:@"-"];
    //NSString *origDate = [NSString stringWithFormat:@"%li/%li/%@",(long)[dateParts[1] integerValue],(long)[dateParts[2] integerValue],dateParts[0]];
    
    BOOL opened = [self open];
    //CREATE TABLE ALLEYWALLS ('id' INT,'Wall ID' CHAR(8),'Hse No' INT,'STREET' CHAR(64),'City' CHAR(4),'Length' REAL,'Max Hght' REAL,'Offset' REAL,'Gar/Struc' CHAR(12),' COST' CHAR(12),'Type Const' CHAR(32),'InspDate' CHAR(12),'InspBy' CHAR(8),'Rating' CHAR(16),'Comments' CHAR(255),'LONGITUDE' REAL,'LATITUDE' REAL,PRIMARY KEY('id' ASC))
    NSRange segRange = [fieldName rangeOfString:@"("];
    if (segRange.location == NSNotFound)
    {
        query = [NSString stringWithFormat:@"SELECT [%@] FROM ALLEYWALLS_NEW WHERE [Wall ID]=%@ AND Current = 1",fieldName,wallID];
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
            if (val)
            {
                value = [NSString stringWithUTF8String:val];
                found = true;
            }
        }
        
        SQLOK(sqlite3_finalize(statement), _database);
        
        /*       if (!found)
         {
         query = [NSString stringWithFormat:@"SELECT [%@] FROM ALLEYWALLS WHERE [Wall ID]=%@ AND [InspDate]='%@'",fieldName,wallID,origDate];
         
         SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), "");
         
         if (sqlite3_step(statement) == SQLITE_ROW)
         {
         LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
         if (val)
         value = [NSString stringWithUTF8String:val];
         }
         
         SQLOK(sqlite3_finalize(statement), "");
         }*/
    }
    else
    {
        NSString * fname = [fieldName substringToIndex:segRange.location];
        int iseg = (int)[[fieldName substringFromIndex:segRange.location+1] integerValue];
        query = [NSString stringWithFormat:@"SELECT [%@] FROM ALLEYWALL_SEGS WHERE [Wall ID]=%@ AND [InspDate]='%@' AND [SEGMENT]=%i",fname,wallID,date,iseg];
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
            if (val)
            {
                value = [NSString stringWithUTF8String:val];
                found = true;
            }
        }
        
        SQLOK(sqlite3_finalize(statement),_database);
        /*        if (!found && iseg == 1)
         {
         if ([fname isEqualToString:@"SegmentLength"])
         fname = @"Length";
         else if ([fname isEqualToString:@"SegmentOffset"])
         fname = @"Offset";
         else if ([fname isEqualToString:@"TypeConst"])
         fname = @"Type Const";
         query = [NSString stringWithFormat:@"SELECT [%@] FROM ALLEYWALLS WHERE [Wall ID]=%@ AND [InspDate]='%@'",fname,wallID,origDate];
         
         SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), "");
         
         if (sqlite3_step(statement) == SQLITE_ROW)
         {
         LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
         if (val)
         value = [NSString stringWithUTF8String:val];
         }
         
         SQLOK(sqlite3_finalize(statement), "");
         
         }*/
        
    }
    [self close:opened];
    return value;
    
}
- (BOOL)beginNewSurveyForWall:(NSString *)wallID
                     fromDate:(NSString *)fromDate
                      newDate:(NSString *)newDate
{
    BOOL rtn = FALSE;
    sqlite3_stmt *statement;
    NSString * house;
    NSString * street;
    NSString * latitude;
    NSString * longitude;
    NSInteger refno = 0;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM ALLEYWALLS_NEW"];
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        refno = sqlite3_column_int(statement, 0);
        refno = [CRAPI.sharedInstance adjustNextRefno:refno];
    }
    SQLOK(sqlite3_finalize(statement), _database);
    
    
    query = [NSString stringWithFormat:@"SELECT [Hse No],[STREET],[LONGITUDE],[LATITUDE] FROM ALLEYWALLS_NEW WHERE [Wall ID]='%@' AND [Current]=1",wallID];
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR val = (LPSTR)sqlite3_column_text(statement, 0);
        house = [NSString stringWithUTF8String:val];
        val = (LPSTR)sqlite3_column_text(statement, 1);
        street = [NSString stringWithUTF8String:val];
        val = (LPSTR)sqlite3_column_text(statement, 2);
        longitude = [NSString stringWithUTF8String:val];
        val = (LPSTR)sqlite3_column_text(statement, 3);
        latitude = [NSString stringWithUTF8String:val];
        rtn = TRUE;
    }
    SQLOK(sqlite3_finalize(statement),_database);
    if (rtn)
    {
        query = [NSString stringWithFormat:@"UPDATE ALLEYWALLS_NEW SET Current = 0, [LastUpdate]=%i WHERE [Wall ID]='%@' AND [InspDate]='%@'",iTime,wallID,fromDate];
        [self executeCmd:(LPSTR)query.UTF8String
            sendToServer:YES];
    }
    if (rtn)
    {
        query = [NSString stringWithFormat:@"INSERT INTO ALLEYWALLS_NEW ([id],[Wall ID],[InspDate],[Current],[Hse No],[STREET],[LATITUDE],[LONGITUDE],[LastUpdate]) VALUES (%li,'%@','%@',1,'%@','%@','%@','%@',%i)",(long)refno,wallID,newDate,house,street,latitude,longitude,iTime];
        [self executeCmd:(LPSTR)query.UTF8String
            sendToServer:YES];
        query = [NSString stringWithFormat:@"INSERT INTO ALLEYWALLS_NEW_index VALUES(%ld,%f,%f,%f,%f)",(long)refno,longitude.floatValue,longitude.floatValue,latitude.floatValue,latitude.floatValue];
        [self executeCmd:(LPSTR)query.UTF8String
            sendToServer:YES];
        
    }
    [self close:opened];
    return rtn;
}

- (BOOL)createNewTable
{
    BOOL rtn = TRUE;
    BOOL opened = [self open];
    NSString * cmd = @"\
    DROP TABLE IF EXISTS ALLEYWALLS_VERSION;\
    CREATE TABLE ALLEYWALLS_VERSION ('Version' CHAR(16));\
    INSERT INTO ALLEYWALLS_VERSION ([VERSION]) VALUES ('1.0');\
    DROP TABLE IF EXISTS ALLEYWALLS_NEW;\
    DROP TABLE IF EXISTS ALLEYWALLS_NEW_index;\
    CREATE VIRTUAL TABLE ALLEYWALLS_NEW_index USING rtree(id,minX, maxX, minY, maxY);\
    DROP TABLE IF EXISTS ALLEYWALL_SEGS;\
    CREATE TABLE IF NOT EXISTS ALLEYWALLS_NEW (\
    'id' INT,\
    'Wall ID' CHAR(8),\
    'InspDate' CHAR(12),\
    'InspBy' CHAR(16),\
    'Current' INT,\
    'LastUpdate' INT,\
    'Deleted' INT,\
    'Complete' INT,\
    'Version' CHAR(16),\
    'Hse No' INT,\
    'STREET' CHAR(64),\
    'CityStamp' CHAR(32),\
    'Photos' INT,\
    'BEARING' REAL,\
    'GroundCoverBehindWall' CHAR(255),\
    'VisibleWeepHoles' CHAR(4),\
    'HistAndConstYear' CHAR(255),\
    'StructuresInWall' CHAR(255),\
    'ItemsBehindWall' CHAR(255),\
    'SoilSurcharge' REAL,\
    'Deficiency' CHAR(255),\
    'Rating' INT,\
    'NumSegments' INT,\
    'Comments' CHAR(255),\
    'LONGITUDE' REAL,\
    'LATITUDE' REAL,\
    PRIMARY KEY('Wall ID','InspDate'));\
    CREATE TABLE IF NOT EXISTS ALLEYWALL_SEGS(\
    'Wall ID' CHAR(8),\
    'InspDate' CHAR(12),\
    'SEGMENT' INT,\
    'SegmentLength' REAL,\
    'SegmentMaxHeight' REAL,\
    'SegmentOffset' REAL,\
    'TypeConst' CHAR(32),\
    'SegmentPlumbness' REAL,\
    'PlumbnessDistance' REAL,\
    PRIMARY KEY('Wall ID','InspDate','SEGMENT'));";
    //DROP TABLE IF EXISTS ALLEYWALL_SEGS;
    [self executeCmd:(char *)cmd.UTF8String
        sendToServer:NO];
    [self close:opened];
    return rtn;
}
/*
 $GMDUPDATE([ALLEYWALLFILE],Wall ID=7397.3;InspDate=1987-03-13,InspBy=jes;
 Hse No=3621;
 Street=PORTLAND AVE;
 CityStamp=;
 Photos=;
 Bearing=19.5;
 GroundCoverBehindWall=Pervious;
 VisibleWeepHoles=;
 HistAndConstYear=;
 StructuresInWall=;
 ItemsBehindWall=;
 SoilSurcharge=;
 Deficiency=;
 Rating=7;
 NumSegments=1;
 Comments=GOOD.  ;
 );$GMDUPDATE([ALLEYWALLSEGFILE],Wall ID=7397.3;InspDate=1987-03-13;SEGMENT=1,SegmentLength=;
 SegmentMaxHeight=;
 SegmentOffset=;
 TypeConst=;
 SegmentPlumbness=;
 PlumbnessDistance=;
 );*/

- (NSString*) outputDataFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString* file = [NSString stringWithFormat:@"%@/%i_%i.sql",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"AlleyWalls"],iPad,fileNum];
    return file;
}
- (NSString*) outputPictFile:(int)fileNum
                        iPad:(int)iPad
{
    NSString* file = [NSString stringWithFormat:@"%@/%i_%i.jpg",
                      [CRAPI.sharedInstance sharedOutputDirectory:@"AlleyWalls"],iPad,fileNum];
    return file;
}


- (int) getLastDataUpdateNumber:(int)iPad
                    lastPictNum:(int*)pictNum
{
    if (!iPad)
        return 0;
    int lastNum  = 0;
    int lastPictNum = 0;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT LastDataUpdate,LastPictUpdate FROM ALLEYWALL_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, cmd.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        lastNum = sqlite3_column_int(statement, 0);
        lastPictNum = sqlite3_column_int(statement, 1);
    }
    SQLOK(sqlite3_finalize(statement), _database);
    if (!lastNum)
    {
        lastNum = 1;
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALL_UPDATES VALUES(%i,1,0);",iPad];
        [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:NO];
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
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALL_UPDATES VALUES(%i,%i,%i);",iPad,lastNum,pictNum];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:NO];
    [self close:opened];
    return rtn;
}
- (BOOL) setLastDataUpdateNum:(int)lastNum
                      foriPad:(int)iPad
{
    BOOL rtn= FALSE;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT * FROM ALLEYWALL_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, cmd.UTF8String, -1, &statement, 0), _database);
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    SQLOK(sqlite3_finalize(statement), _database);
    
    if (!haveRecord)
    {
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALL_UPDATES VALUES(%i,1,0);",iPad];
        rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:NO];
    }
    cmd = [NSString stringWithFormat:@"UPDATE ALLEYWALL_UPDATES SET LastDataUpdate = %i WHERE iPad=%i",lastNum,iPad];
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:NO];
    [self close:opened];
    return rtn;
}

- (BOOL) setLastPictUpdateNum:(int)lastNum
                      foriPad:(int)iPad
{
    BOOL rtn= FALSE;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"SELECT * FROM ALLEYWALL_UPDATES WHERE iPad=%i",iPad];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, cmd.UTF8String, -1, &statement, 0), _database);
    BOOL haveRecord = (sqlite3_step(statement) == SQLITE_ROW);
    SQLOK(sqlite3_finalize(statement), _database);
    
    if (!haveRecord)
    {
        cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALL_UPDATES VALUES(%i,1,0);",iPad];
        rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                  sendToServer:NO];
    }
    cmd = [NSString stringWithFormat:@"UPDATE ALLEYWALL_UPDATES SET LastPictUpdate = %i WHERE iPad=%i",lastNum,iPad];
    rtn = [self executeCmd:(LPSTR)cmd.UTF8String
              sendToServer:NO];
    [self close:opened];
    return rtn;
}
- (int) getLastPictUpdateNumber:(int)iPad
{
    int LastNum  = 0;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT LastPictUpdate FROM ALLEYWALL_UPDATES WHERE iPad=%i",iPad];
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
    NSString * cmd = @"CREATE TABLE IF NOT EXISTS ALLEYWALL_UPDATES ('iPad' INTEGER PRIMARY KEY,'LastDataUpdate' INT,'LastPictUpdate' INT)";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE TABLE IF NOT EXISTS ALLEYWALL_NOTES ('id' INTEGER PRIMARY KEY,'intID' INT,'corner' INT,'rampID' INT,'type' INT, 'note' CHAR(4096))";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    cmd = @"CREATE TABLE IF NOT EXISTS ALLEYWALL_STANDARD_TEXT ('textID' INTEGER PRIMARY KEY,'type' INT,'text' CHAR(4096))";
    rtn = !SQLOK(sqlite3_exec(_database, cmd.UTF8String, NULL, NULL, NULL), _database);
    return rtn;
}
- (int) incrementLastDataFileNum
{
    int pictNum;
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastDataUpdateNumber:iPad
                                    lastPictNum:&pictNum];
    NSString* file = [self outputDataFile:lastNum iPad:CRAPI.sharedInstance.currentiPadWithinManager];
    
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:file
                                                                       error:nil].fileSize;
    if (fileSize > 0)
    {
        [self setLastDataUpdateNum:++lastNum pictNum:pictNum foriPad:iPad];
    }
    return lastNum;
}

+ (int) incrementLastDataFileNumber
{
    AlleyWallData *awd = AlleyWallData.new;
    return [awd incrementLastDataFileNum];
}
+ (int) incrementLastPictFileNumber
{
    AlleyWallData *awd = AlleyWallData.new;
    return [awd incrementLastPictFileNum];
}
- (int) incrementLastPictFileNum
{
    int iPad = CRAPI.sharedInstance.currentiPadWithinManager;
    int lastNum = [self getLastPictUpdateNumber:iPad];
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:[self outputPictFile:lastNum
                                                                                             iPad:CRAPI.sharedInstance.currentiPadWithinManager]
                                                                       error:nil].fileSize;
    if (fileSize > 0)
    {
        [self setLastPictUpdateNum:++lastNum foriPad:iPad];
    }
    return lastNum;
}
- (BOOL)createPictureDatabase
{
    BOOL rtn = TRUE;
    NSString *cmd = @"CREATE TABLE IF NOT EXISTS ALLEYWALL_PICTURES ('id' INTEGER PRIMARY KEY,'iPadNum' INT,'pictNum' INT,'wallID' CHAR(8), 'type' INT, 'heading' INT, 'latitude' REAL, 'longitude' REAL, 'time' INT)";
    rtn = [self executeCmd:(char *)cmd.UTF8String
              sendToServer:NO];
    return rtn;
}
- (uint) getNextPictID
{
    uint nextID = 1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM ALLEYWALL_PICTURES"];
    BOOL opened = [self open];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nextID = sqlite3_column_int(statement, 0);
    }
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];
    SQLOK(sqlite3_finalize(statement), _database);
    [self close:opened];
    return nextID;
}

- (BOOL) savePictureData:(int)pictNum
                 wallID:(NSString*)wallID
                    type:(int)type
                 latLon:(LLPOINT)ll
                heading:(int)heading
{
    BOOL opened = [self open];
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    uint pictID = [self getNextPictID];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLEYWALL_PICTURES VALUES(%i,%i,%i,%@,%i,%i,%f,%f,%i);",
                     pictID,CRAPI.sharedInstance.currentiPadWithinManager,pictNum,wallID,type,heading,ll.lat,ll.lon,iTime];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String
                   sendToServer:YES];
    [self close:opened];
    return rtn;
    
}

- (BOOL) updateFromFile:(NSString*)file
{
    BOOL rtn = TRUE;
    BOOL opened = [self open];
    
    FILE *fid = fopen(file.UTF8String, "rb");
    int totLen = (int)FileLength(fid);
    int maxLineLen = totLen+2;
    LPSTR str = malloc(totLen+4);
    [self startTransaction];
    while (rtn && fgetstring(str, maxLineLen, fid))
    {
        rtn = [self executeCmd:str
                       sendToServer:NO];
    }
    fclose(fid);
    if (!rtn)
    {
        [self cancelTransaction];
        rtn = YES;
    }
    else
        [self commitTransaction];
    free(str);
    [self close:opened];
    return rtn;
}


@end
