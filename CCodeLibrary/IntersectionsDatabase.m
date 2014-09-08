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
        //NSFileManager *fileManager = NSFileManager.defaultManager;
        //BOOL success = [fileManager fileExistsAtPath:[self databasePath:geoid]];
        
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
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Intersections (intID INTEGER, intX INTEGER, intY INTEGER, rotation INTEGER, ramp1 INTEGER, ramp2 INTEGER, ramp3 INTEGER, ramp4 INTEGER, ramp5 INTEGER, ramp6 INTEGER, ramp7 INTEGER, ramp8 INTEGER, ramp81 INTEGER, ramp23 INTEGER, ramp45 INTEGER, ramp67 INTEGER, xWalkA INTEGER, xWalkB INTEGER, xWalkC INTEGER, xWalkD INTEGER, signal81 INTEGER, signal23 INTEGER, signal45 INTEGER, signal67 INTEGER);"];
    
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
}

- (BOOL)insertRecordIntoIntersectionTable:(IntersectionRecord *)iRec
{
    BOOL rtn = YES;
    char *error;
    sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &error);
    
    char buffer[] = "INSERT INTO Intersections VALUES (?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23)";
    
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, buffer, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        sqlite3_bind_int(statement, 0, iRec.intID);
        sqlite3_bind_int(statement, 1, iRec.lev21X);
        sqlite3_bind_int(statement, 2, iRec.lev21Y);
        sqlite3_bind_int(statement, 3, iRec.rotation);
        sqlite3_bind_int(statement, 4, iRec.ramp1);
        sqlite3_bind_int(statement, 5, iRec.ramp2);
        sqlite3_bind_int(statement, 6, iRec.ramp3);
        sqlite3_bind_int(statement, 7, iRec.ramp4);
        sqlite3_bind_int(statement, 8, iRec.ramp5);
        sqlite3_bind_int(statement, 9, iRec.ramp6);
        sqlite3_bind_int(statement, 10, iRec.ramp7);
        sqlite3_bind_int(statement, 11, iRec.ramp8);
        sqlite3_bind_int(statement, 12, iRec.ramp81);
        sqlite3_bind_int(statement, 13, iRec.ramp23);
        sqlite3_bind_int(statement, 14, iRec.ramp45);
        sqlite3_bind_int(statement, 15, iRec.ramp67);
        sqlite3_bind_int(statement, 16, iRec.xWalkA);
        sqlite3_bind_int(statement, 17, iRec.xWalkB);
        sqlite3_bind_int(statement, 18, iRec.xWalkC);
        sqlite3_bind_int(statement, 19, iRec.xWalkD);
        sqlite3_bind_int(statement, 20, iRec.signal81);
        sqlite3_bind_int(statement, 21, iRec.signal23);
        sqlite3_bind_int(statement, 22, iRec.signal45);
        sqlite3_bind_int(statement, 23, iRec.signal67);
        
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table");
            rtn = NO;
        }
        
        sqlite3_reset(statement);
    }
    
    SQLOK(sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &error));
    sqlite3_finalize(statement);
    return rtn;
}

- (NSArray *)getRecordsFromTable:(NSString *)tableName
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int intX = sqlite3_column_int(statement, 1);
        int intY = sqlite3_column_int(statement, 2);
        int rotation = sqlite3_column_int(statement, 3);
        int ramp1 = sqlite3_column_int(statement, 4);
        int ramp2 = sqlite3_column_int(statement, 5);
        int ramp3 = sqlite3_column_int(statement, 6);
        int ramp4 = sqlite3_column_int(statement, 7);
        int ramp5 = sqlite3_column_int(statement, 8);
        int ramp6 = sqlite3_column_int(statement, 9);
        int ramp7 = sqlite3_column_int(statement, 10);
        int ramp8 = sqlite3_column_int(statement, 11);
        int ramp81 = sqlite3_column_int(statement, 12);
        int ramp23 = sqlite3_column_int(statement, 13);
        int ramp45 = sqlite3_column_int(statement, 14);
        int ramp67 = sqlite3_column_int(statement, 15);
        int xWalkA = sqlite3_column_int(statement, 16);
        int xWalkB = sqlite3_column_int(statement, 17);
        int xWalkC = sqlite3_column_int(statement, 18);
        int xWalkD = sqlite3_column_int(statement, 19);
        int signal81 = sqlite3_column_int(statement, 20);
        int signal23 = sqlite3_column_int(statement, 21);
        int signal45 = sqlite3_column_int(statement, 22);
        int signal67 = sqlite3_column_int(statement, 23);
            
        PlacesInfo *info = [[PlacesInfo alloc]initWithIntID:intID
                                                       intX:intX
                                                       intY:intY
                                                   rotation:rotation
                                                      ramp1:ramp1
                                                      ramp2:ramp2
                                                      ramp3:ramp3
                                                      ramp4:ramp4
                                                      ramp5:ramp5
                                                      ramp6:ramp6
                                                      ramp7:ramp7
                                                      ramp8:ramp8
                                                     ramp81:ramp81
                                                     ramp23:ramp23
                                                     ramp45:ramp45
                                                     ramp67:ramp67
                                                     xWalkA:xWalkA
                                                     xWalkB:xWalkB
                                                     xWalkC:xWalkC
                                                     xWalkD:xWalkD
                                                   signal81:signal81
                                                   signal23:signal23
                                                   signal45:signal45
                                                   signal67:signal67];
            
        [dataArray addObject:info];
    }
        
    sqlite3_finalize(statement);
    return dataArray;
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
    
    strcpy (dataFile,path.UTF8String);
    
    if ((pUB = strrchr (dataFile,'_')))
        *pUB = 0;
    
    else
        goto Exit;
    
    strcpy (indexFile, dataFile);
    strcat (indexFile, "/intersection_index.bin");
    strcat (dataFile, "/intersection_data.bin");
    fidData = fopen (dataFile, "rb");
    fidIndex = fopen (indexFile, "rb");
    
    if (fidData == nil || fidIndex == nil)
        goto Exit;
    
    [self createIntersectionsTable];
    
    fgetstring (index, maxIndex, fidIndex);
    
    while (fgetstring (data, maxData, fidData))
    {
        LPSTR pTab = strchr (data,'\t');
        LPSTR pTabIndex;
        fgetstring (index,maxIndex,fidIndex);
        pTabIndex = strchr (index,'\t');
        IntersectionRecord *iRec = [[IntersectionRecord alloc] init];
        *pTab++ = 0;
        *pTabIndex = 0;
        pTabIndex = strchr (index,' ');
        *pTabIndex++ = 0;
        iRec.intID = atoi (data);
        iRec.lev21Y = atoi (index);
        iRec.lev21X = atoi (pTabIndex);
        
        [self insertRecordIntoIntersectionTable:iRec];
        nLoaded++;
    }
    
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
    
    else
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
    BOOL forceReload = TRUE;
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

- (void)createTableNamed:(NSString *)tableName
{
    
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