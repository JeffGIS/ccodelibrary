  //  IntersectionsDatabase.m
//  PedRampInv_Prelim

#import "IntersectionsDatabase.h"

@implementation IntersectionsDatabase

static IntersectionsDatabase *_database;

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid
{
    if (_database == nil || _database.geoid != geoid)
        _database = [[IntersectionsDatabase alloc] initWithGeoid:geoid];
    
    return _database;
}

- (id)initWithGeoid:(int)geoid
{
    if ((self = [super init]))
    {
        self.geoid = geoid;
        SQLOK(sqlite3_open([self databasePath:geoid].UTF8String, &_database));
    }
    
    return self;
}

- (void)close
{
   sqlite3_close(_database);
}

- (void)dealloc
{
    sqlite3_close(_database);
}

- (NSString *)databasePath:(int)geoid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *subDir = [NSString stringWithFormat:@"%@/%i",documentsDirectory,geoid];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    [fileManager createDirectoryAtPath:subDir
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%i/Intersections.sqlite3", documentsDirectory, geoid];
    return dbPath;
}

- (void)createIntersectionsTable
{
    char *error;
    
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;"];
    
    SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Intersections (intID INTEGER PRIMARY KEY, lastUpdateTime INTEGER, status INTEGER, assignedToMe INTEGER, intX INTEGER, intY INTEGER, rotation INTEGER, ramp1 INTEGER, ramp2 INTEGER, ramp3 INTEGER, ramp4 INTEGER, ramp5 INTEGER, ramp6 INTEGER, ramp7 INTEGER, ramp8 INTEGER, ramp81 INTEGER, ramp23 INTEGER, ramp45 INTEGER, ramp67 INTEGER, xWalkA INTEGER, xWalkB INTEGER, xWalkC INTEGER, xWalkD INTEGER, signal81 INTEGER, signal23 INTEGER, signal45 INTEGER, signal67 INTEGER, nStreets INTEGER, streetNames CHAR(512), streetAZMs CHAR(128));"];
    
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX xindex ON Intersections (intX);"];
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX yindex ON Intersections (intY);"];
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
}

- (NSMutableArray *)getIntersectionPointsFromDatabase
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections"];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        double lat,lon;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.latitude = lat;
        intpt.longitude = lon;
        [dataArray addObject:intpt];
    }
        
    SQLOK(sqlite3_finalize(statement));
    return dataArray;
}

- (NSMutableArray *)getIntersectionPointsFromDatabaseinBounds:(IBOUNDS)bounds
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",bounds.xmn,bounds.xmx,bounds.ymn,bounds.ymx];
    sqlite3_stmt *statement;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        double lat,lon;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.latitude = lat;
        intpt.longitude = lon;
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement));
    return dataArray;
}

- (NSMutableArray *)getIntersectionPointsWithinDistance:(int)meters ofPoint:(LLPOINT)latlon
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    IPOINT pt;
    int dist = meters / GroundResolution(latlon.lat, 21);
    LatLongToPixelXY(latlon.lat, latlon.lon, 21, &pt.x, &pt.y);
    IBOUNDS bounds = IBoundsFromPointAndDist (pt,dist);
    NSString *query = [NSString stringWithFormat:@"SELECT intID, intX, intY FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",bounds.xmn,bounds.xmx,bounds.ymn,bounds.ymx];
    sqlite3_stmt *statement;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int intX = sqlite3_column_int(statement, 1);
        int intY = sqlite3_column_int(statement, 2);
        double lat,lon;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.intID = intID;
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.dist = LDIST(intX, intY, pt.x, pt.y);
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement));
    [self sortIntersectionsByDistance:dataArray];
    return dataArray;
}
-(void)sortIntersectionsByDistance:(NSMutableArray *)intersections
{
    [intersections sortUsingComparator: ^(id obj1, id obj2)
     {
         IntersectionPoint *pt1 = obj1;
         IntersectionPoint *pt2 = obj2;
         
         if (pt1.dist > pt2.dist)
             return (NSComparisonResult)NSOrderedDescending;
         
         if (pt1.dist < pt2.dist)
             return (NSComparisonResult)NSOrderedAscending;
         
         return (NSComparisonResult)NSOrderedSame;
     }];
}
- (int) findIntersection:(int) lev21x y: (int) lev21y
        intersectionText:(char *)intText
                whichInt:(int) iWant
        intersectionAZMs:(char *)intAZMs
              numStreets:(int *)pNumStreets
                numRamps:(int *)pNumRamps
                    intX:(int *)plev21x
                    intY:(int *)plev21y
{
    int rtn = 0;
    LLPOINT latlon;
    PixelXYToLatLong(lev21x, lev21y, 21, &latlon.lat, &latlon.lon);
    NSMutableArray * nearInts = [self getIntersectionPointsWithinDistance:500 ofPoint:latlon];
    if (nearInts.count >= iWant)
    {
        IntersectionPoint * intpt = nearInts[iWant-1];
        NSString *query = [NSString stringWithFormat:@"SELECT intX, intY, nStreets, streetNames, streetAZMs FROM Intersections WHERE intID = %i",intpt.intID];
        sqlite3_stmt *statement;
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int intX = sqlite3_column_int(statement, 0);
            int intY = sqlite3_column_int(statement, 1);
            int nStreets = sqlite3_column_int(statement,2);
            LPSTR pStreets = (LPSTR)sqlite3_column_text(statement, 3);
            LPSTR pAZMS = (LPSTR)sqlite3_column_text(statement, 4);
            *plev21x = intX;
            *plev21y = intY;
            *pNumStreets = nStreets;
            strcpy (intText,pStreets);
            strcpy (intAZMs,pAZMS);
        }
        
        SQLOK(sqlite3_finalize(statement));
        return intpt.intID;
    }
    return rtn;
}

- (BOOL)setCurrentIntersectionPoint:(IntersectionPoint *)intpt
{
    BOOL rtn;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    int lev21x, lev21y;
    LatLongToPixelXY (intpt.latitude, intpt.longitude, 21, &lev21x, &lev21y);
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, intX=%i, intY=%i WHERE intID=%i",
                       iTime, lev21x, lev21y, intpt.intID];
    char *error;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (IntersectionPoint *)getCurrentIntersectionPoint:(int)intID
{
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement;
    CGPoint intersectionPoint;
    IntersectionPoint *intpt = nil;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        double lat,lon;
        intpt = [[IntersectionPoint alloc] init];
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        intpt.latitude = intersectionPoint.y = lat;
        intpt.longitude = intersectionPoint.x = lon;
        intpt.intID = intID;
    }
    
    SQLOK(sqlite3_finalize(statement));
    return intpt;
}

- (int)getCountOfIntersections
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Intersections"];
    sqlite3_stmt *statement;
    int count = 0;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(sqlite3_finalize(statement));
    return count;
}
- (BOOL)setIntersectionStatusTo:(int)status forIntersection:(int)intID
{
    BOOL rtn;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%i WHERE intID=%i",
                       iTime, status, intID];
    char *error;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (IntersectionPoint *)getFirstAssignedIntersectionPointWithStatus0
{
    IntersectionPoint *intpt = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT intID, intX, intY FROM Intersections WHERE status = 0"];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int intX = sqlite3_column_int(statement, 1);
        int intY = sqlite3_column_int(statement, 2);
        double lat,lon;
        intpt = [[IntersectionPoint alloc] init];
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.intID = intID;
    }
    
    SQLOK(sqlite3_finalize(statement));
    return intpt;
}

- (NSString *)intersectionTextPath:(int)type
{
    NSString *path;
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    if (type == INT_TEXT_DATA)
        path = [NSString stringWithFormat:@"%@/%i/intersection_data.bin", docsDir, self.geoid];
    
    else
        path = [NSString stringWithFormat:@"%@/%i/intersection_index.bin", docsDir, self.geoid];
    
    return path;
}

- (int)loadIntersectionTextToDatabase:(NSString *)path
{
    BOOL rtn = INTDB_FAILED;
    char dataFile[PATH_MAX], indexFile[PATH_MAX];
    LPSTR pUB;
    FILE *fidData, *fidIndex;
    char data[258], index[256];
    int maxData = 256;
    int maxIndex = 100;
    int nLoaded = 0;
    char buffer[] = "INSERT INTO Intersections VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt *statement;
    char *error;
    INTERSECTION_STRUCT intStruct = {0};
    int *pInt, i;
    
    strcpy(dataFile,path.UTF8String);
    
    if ((pUB = strrchr (dataFile, '_')))
        *pUB = 0;
    
    else
        goto Exit;
    
    strcpy (indexFile, dataFile);
    strcat (indexFile, "/intersection_index.bin");
    strcat (dataFile, "/intersection_data.bin");
    fidData = fopen (dataFile, "rb");
    fidIndex = fopen (indexFile, "rb");
    
    NSLog (@"loadIntersectionTextToDatabase fopen file: %s", indexFile);
    
    if (fidData == nil || fidIndex == nil)
        goto Exit;
    
    [self createIntersectionsTable];
    
    SQLOK(sqlite3_prepare_v2(_database, buffer, -1, &statement, NULL));
    SQLOK(sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &error));
    sqlite3_free(error);
    
    fgetstring(index, maxIndex, fidIndex);
    
    while (fgetstring(data, maxData, fidData))
    {
        LPSTR pTab = strchr(data, '\t');
        LPSTR pTabIndex, pAzms,pEnd;
        fgetstring (index,maxIndex,fidIndex);
        pTabIndex = strchr(index, '\t');
        *pTab++ = 0;
        *pTabIndex = 0;
        pTabIndex = strchr(index,' ');
        *pTabIndex++ = 0;
        intStruct.intID = atoi(data);
        intStruct.lev21Y = atoi(index);
        intStruct.lev21X = atoi(pTabIndex);
        intStruct.assignedTo = 1;
        intStruct.status = 0;
        intStruct.nStreets = atoi (pTab);
        pTab = strchr (pTab,'\t')+1;
        pAzms = strchr (pTab,'\t');
        *pAzms++ = 0;
        pEnd = strchr (pAzms,'\t');
        *pEnd = 0;
        strncpy (intStruct.streetNames,pTab,sizeof(intStruct.streetNames)-1);
        strncpy (intStruct.streetAzms,pAzms,sizeof(intStruct.streetAzms)-1);
        
        for (i = 1, pInt = &intStruct.intID; i < 29; i++, pInt++)
            SQLOK(sqlite3_bind_int(statement, i, *pInt));
        SQLOK(sqlite3_bind_text(statement, 29, intStruct.streetNames,-1,SQLITE_STATIC));
        SQLOK(sqlite3_bind_text(statement, 30, intStruct.streetAzms,-1,SQLITE_STATIC));

        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSLog(@"Error inserting intersection. '%s'", sqlite3_errmsg(_database));
            rtn = NO;
        }
        
        nLoaded++;
        SQLOK(sqlite3_reset(statement));
    }
    
    SQLOK(sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &error));
    sqlite3_free(error);
    SQLOK(sqlite3_finalize(self.statement));
    
    fclose(fidIndex);
    fclose(fidData);
    rtn = INTDB_OK;
    
Exit:
    return rtn;
}

- (void)FTPdidComplete:(int)status
              filePath:(NSString *)path
{
    if (status == FTP_OK)
    {
        NSString *toDirectory = [CRAPI.sharedInstance directoryFromPath:path
                                                                andName:[NSString stringWithFormat:@"/%i",self.geoid]];
        
        DecompressGMZipFile ((LPSTR)path.UTF8String,(LPSTR)toDirectory.UTF8String);
        status = [self loadIntersectionTextToDatabase:path];
        
        if (self.delegate != nil)
        {
            [self.delegate intersectionsDatabase:[self databasePath:self.geoid]
                                         didLoad:@""
                                      withStatus:status];
        }
    }
    
    else if (status != FTP_STOP)
    {
       
        [self.delegate intersectionsDatabase:nil
                                     didLoad:@"FTP failure"
                                  withStatus:INTDB_FAILED];
    }
    
    return;
}

- (void)getPlaceIntersectionFile:(GSSiPopoverView*)popover
                        forGeoid:(int)geoid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%7.7i_Intersections.gcf", geoid];
    
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = self;
    pull.popover = popover;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/PlaceIntersections"
      toDirectory:documentsDirectory
     forceRefresh:NO];
}

- (void)getPlaceIntersectionDatabase:(GSSiPopoverView*)popover
{
    NSString * dbPath = [self databasePath:self.geoid];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                                 error:nil].fileSize;
    BOOL forceReload = FALSE;
    if (fileSize > 0 && !forceReload)
    {
        if (self.delegate != nil)
        {
            [self.delegate intersectionsDatabase:dbPath
                                         didLoad:@""
                                      withStatus:INTDB_OK];
        }
    }
    
    else
    {
        [self getPlaceIntersectionFile:popover
                              forGeoid:self.geoid];
    }
    
}

- (void)logError
{
    int ierr = sqlite3_errcode(_database);
    const char *errmess = sqlite3_errmsg(_database);
    NSString *logMess = [NSString stringWithFormat:@"Error in SQLite = %i:%s", ierr, errmess];
    NSLog(@"%@", logMess);
}

int SQLOK (int sqlReturn)
{
    if (sqlReturn != SQLITE_OK)
        [_database logError];
    
    return sqlReturn;
}

@end