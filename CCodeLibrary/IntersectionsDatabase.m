  //  IntersectionsDatabase.m
//  PedRampInv_Prelim

#import "IntersectionsDatabase.h"

@implementation IntersectionsDatabase

static IntersectionsDatabase *_database;

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid
{
    if (_database == nil)
        _database = [[IntersectionsDatabase alloc] initWithGeoid:geoid];
    
    else if (_database.geoid != geoid)
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
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%i/Intersections.sqlite3",documentsDirectory,geoid];
    return dbPath;
}

- (void)createIntersectionsTable
{
    char *error;
    
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;"];
    
    SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, &error));
    sqlite3_free (error);
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Intersections (intID INTEGER PRIMARY KEY, lastUpdateTime INTEGER, status INTEGER, assignedToMe INTEGER, intX INTEGER, intY INTEGER, rotation INTEGER, ramp1 INTEGER, ramp2 INTEGER, ramp3 INTEGER, ramp4 INTEGER, ramp5 INTEGER, ramp6 INTEGER, ramp7 INTEGER, ramp8 INTEGER, ramp81 INTEGER, ramp23 INTEGER, ramp45 INTEGER, ramp67 INTEGER, xWalkA INTEGER, xWalkB INTEGER, xWalkC INTEGER, xWalkD INTEGER, signal81 INTEGER, signal23 INTEGER, signal45 INTEGER, signal67 INTEGER);"];
    
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free (error);
}

- (NSMutableArray *)getIntersectionPointsFromDatabase
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections ORDER BY intID"];
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
    sqlite3_free (error);
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
- (BOOL)setIntersectionStatusTo:(int)status forIntersection:(int)intID
{
    BOOL rtn;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%i WHERE intID=%i",
                       iTime, status, intID];
    char *error;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free (error);
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
    char buffer[] = "INSERT INTO Intersections VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt *statement;
    char *error;
    INTERSECTION_STRUCT intStruct = {0};
    int *pInt, i;
    
    strcpy (dataFile,path.UTF8String);
    
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
    sqlite3_free (error);
    
    fgetstring (index, maxIndex, fidIndex);
    
    while (fgetstring (data, maxData, fidData))
    {
        LPSTR pTab = strchr (data,'\t');
        LPSTR pTabIndex;
        fgetstring (index,maxIndex,fidIndex);
        pTabIndex = strchr (index,'\t');
        *pTab++ = 0;
        *pTabIndex = 0;
        pTabIndex = strchr (index,' ');
        *pTabIndex++ = 0;
        intStruct.intID = atoi (data);
        intStruct.lev21Y = atoi (index);
        intStruct.lev21X = atoi (pTabIndex);
        intStruct.assignedTo = 1;
        intStruct.status = 0;
        
        for (i = 1, pInt = &intStruct.intID; i < 27; i++, pInt++)
            SQLOK(sqlite3_bind_int(statement, i, *pInt));
        
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSLog(@"Error inserting intersection. '%s'", sqlite3_errmsg(_database));
            rtn = NO;
        }
        
        nLoaded++;
        SQLOK(sqlite3_reset(statement));
    }
    
    SQLOK(sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &error));
    sqlite3_free (error);
    SQLOK(sqlite3_finalize(self.statement));
    
    fclose (fidIndex);
    fclose (fidData);
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

- (void)getPlaceIntersectionFile:(int)geoid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%7.7i_Intersections.gcf", geoid];
    
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = self;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/PlaceIntersections"
      toDirectory:documentsDirectory
     forceRefresh:NO];
}

- (void)getPlaceIntersectionDatabase
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
        [self getPlaceIntersectionFile:self.geoid];
    }
    
}

- (void)logError
{
    int ierr = sqlite3_errcode(_database);
    const char *errmess = sqlite3_errmsg(_database);
    NSString *logMess = [NSString stringWithFormat:@"Error in SQLite = %i:%s", ierr, errmess];
    NSLog(@"%@", logMess);
}

void SQLOK (int sqlReturn)
{
    if (sqlReturn != SQLITE_OK)
        [_database logError];
}

@end