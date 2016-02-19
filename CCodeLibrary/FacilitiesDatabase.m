//  FacilitiesDatabase.m
//  CCodeLibrary

#import "FacilitiesDatabase.h"
#import "IntersectionsDatabase.h"
#import "TileGraphics.h"
#import "MathTypes.h"
#import "MathUtil.h"
#import "CRAPI.h"
#import "compress.h"

int SQLOK(int sqlReturn, sqlite3 *database);

@implementation FacilitiesDatabase

static FacilitiesDatabase *_statdatabase = nil;

+ (FacilitiesDatabase *)databaseForGeoid:(int)geoid
{
    if (!_statdatabase || _statdatabase.geoid != geoid)
        _statdatabase = [[FacilitiesDatabase alloc] initWithGeoid:geoid];
    
    return _statdatabase;
}

- (id)initWithGeoid:(int)geoid
{
    if ((self = [super init]))
    {
        self.geoid = geoid;
        self.path = [self databasePath:geoid];
        SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
    }
    
    return self;
}

- (NSString *)databasePath:(int)geoid
{
    NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    //NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *subDir = [NSString stringWithFormat:@"%@/%i", documentsDirectory, geoid];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    [fileManager createDirectoryAtPath:subDir
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%i/Facilities.sqlite3", documentsDirectory, geoid];
    return dbPath;
}

- (void)createFacilitiesTable
{
    char *error = NULL;
    
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Facilities;"];
    
    SQLOK(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Facilities (\
                       facID INTEGER PRIMARY KEY,\
                       lastUpdateTime INTEGER,\
                       status INTEGER,\
                       assignedTo INTEGER,\
                       facX INTEGER,\
                       facY INTEGER,\
                       rotation INTEGER,\
                       nStreets INTEGER,\
                       streetNames CHAR(512),\
                       streetAZMs CHAR(128));"];
    
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX xindex ON Facilities (facX);"];
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX yindex ON Facilities (facY);"];
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
}

- (int)getOffsetCoord:(Facility *)fac
                    x:(int)x
                    y:(int)y
{
    int offCoord = 0;
    short offx, offy;
    
    offx = (x - fac.lev21x);
    offy = (y - fac.lev21y);
    
    offCoord = (int)MAKELONG(offx, offy);
    return offCoord;
}

- (void)getPlaceFacilityFile:(GSSiPopoverView *)popover
                    forGeoid:(int)geoid
{
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%7.7i_Facilities.gcf", geoid];
    
    self.gettingUploaded = NO;
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = self;
    pull.popover = popover;
    pull.useOnlyPrimaryFTP = NO;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/PlaceFacilities"
           toFile:fileName
      toDirectory:documentsDirectory
    refreshOption:FTPDataPullRefreshOptionCheckFileSize];
}

- (void)getFacilitiesDatabase:(GSSiPopoverView *)popover
{
    NSString *dbPath = [self databasePath:self.geoid];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                                 error:nil].fileSize;
    
    BOOL forceReload = NO;
    
    if (fileSize > 0 && !forceReload)
    {
        if (self.delegate)
        {
            [self.delegate facilitiesDatabase:dbPath
                                      didLoad:@""
                                   withStatus:INTDBStatusOK];
        }
    }
    
    else
    {
        [self getPlaceFacilityFile:popover
                          forGeoid:self.geoid];
    }
}

- (NSMutableArray *)getFacilityPointsFromDatabase
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT facX, facY FROM Facilities"];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int facX = sqlite3_column_int(statement, 0);
        int facY = sqlite3_column_int(statement, 1);
        double lat,lon;
        PixelXYToLatLong(facX, facY, 21, &lat, &lon);
        FacilityPoint *facpt = [[FacilityPoint alloc] init];
        facpt.latitude = lat;
        facpt.longitude = lon;
        [dataArray addObject:facpt];
    }
    
    SQLOK(sqlite3_finalize(statement),_database);
    return dataArray;
}

- (NSMutableArray *)getFacilityPointsFromDatabaseinBounds:(IBOUNDS)bounds
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT facID, assignedTo, status, facX, facY,\
                       FROM Facilities WHERE facX >= %i AND facX <= %i AND facY >= %i AND facY <= %i",
                       (int)bounds.xmn, (int)bounds.xmx, (int)bounds.ymn, (int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int facID = sqlite3_column_int(statement, 0);
        int assignedTo = sqlite3_column_int(statement, 1);
        int status = sqlite3_column_int(statement, 2);
        int facX = sqlite3_column_int(statement, 3);
        int facY = sqlite3_column_int(statement, 4);
        int nRamps = 0;
        
        for (int i = 5; i < 17; i++)
        {
            if (sqlite3_column_int(statement, i) != 0)
                nRamps++;
        }
        
        double lat,lon;
        PixelXYToLatLong(facX, facY, 21, &lat, &lon);
        FacilityPoint *facpt = [[FacilityPoint alloc] init];
        facpt.latitude = lat;
        facpt.longitude = lon;
        facpt.assignedTo = assignedTo;
        facpt.status = status;
        facpt.nramps = nRamps;
        
        if (status)
            status++;
        
        facpt.facID = facID;
        [dataArray addObject:facpt];
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    return dataArray;
}

- (NSMutableArray *)getFacilityPointsWithinDistance:(int)meters
                                            ofPoint:(LLPOINT)latlon
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    IPOINT pt;
    int dist = (meters / GroundResolution(latlon.lat, 21));
    LatLongToPixelXY(latlon.lat, latlon.lon, 21, &pt.x, &pt.y);
    IBOUNDS bounds = IBoundsFromPointAndDist(pt, dist);
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT facID, assignedTo, facX, facY FROM Facilities WHERE facX >= %i AND facX <= %i AND facY >= %i AND facY <= %i",
                       (int)bounds.xmn,(int)bounds.xmx,(int)bounds.ymn,(int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int facID = sqlite3_column_int(statement, 0);
        int assignedTo = sqlite3_column_int(statement, 1);
        int facX = sqlite3_column_int(statement, 2);
        int facY = sqlite3_column_int(statement, 3);
        double lat,lon;
        PixelXYToLatLong(facX, facY, 21, &lat, &lon);
        FacilityPoint *facpt = [[FacilityPoint alloc] init];
        facpt.facID = facID;
        facpt.assignedTo = assignedTo;
        facpt.latitude = lat;
        facpt.longitude = lon;
        facpt.dist = LDIST(facX, facY, pt.x, pt.y);
        [dataArray addObject:facpt];
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    [self sortFacilitiesByDistance:dataArray];
    return dataArray;
}

- (void)sortFacilitiesByDistance:(NSMutableArray *)facilities
{
    [facilities sortUsingComparator: ^(id obj1, id obj2)
     {
         FacilityPoint *pt1 = obj1;
         FacilityPoint *pt2 = obj2;
         
         if (pt1.dist > pt2.dist)
             return (NSComparisonResult)NSOrderedDescending;
         
         if (pt1.dist < pt2.dist)
             return (NSComparisonResult)NSOrderedAscending;
         
         return (NSComparisonResult)NSOrderedSame;
     }];
}

- (FacilityPoint *)getCurrentFacilityPoint:(int)facID
{
    NSString *query = [NSString stringWithFormat:@"SELECT facX, facY FROM Facilities WHERE facID=%i", facID];
    sqlite3_stmt *statement = NULL;
    CGPoint facilityPoint;
    FacilityPoint *facpt;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int facX = sqlite3_column_int(statement, 0);
        int facY = sqlite3_column_int(statement, 1);
        double lat,lon;
        facpt = [[FacilityPoint alloc] init];
        PixelXYToLatLong(facX, facY, 21, &lat, &lon);
        facpt.latitude = facilityPoint.y = lat;
        facpt.longitude = facilityPoint.x = lon;
        facpt.facID = facID;
    }
    
    SQLOK(sqlite3_finalize(statement),_database);
    return facpt;
}

- (NSString *)getCurrentFacilityAZMs:(int)facID
                            nStreets:(int *)pnStreets
{
    NSString * rtn = [[NSString alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT nStreets, streetAZMs FROM Facilities WHERE facID=%i", facID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nStreets = sqlite3_column_int(statement, 0);
        *pnStreets = nStreets;
        LPSTR pAZMs = (LPSTR)sqlite3_column_text(statement, 1);
        rtn = [NSString stringWithUTF8String:pAZMs];
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    return rtn;
}

- (BOOL)setCurrentFacilityPoint:(FacilityPoint *)facpt
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    int lev21x, lev21y;
    LatLongToPixelXY(facpt.latitude, facpt.longitude, 21, &lev21x, &lev21y);
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Facilities SET lastUpdateTime=%i, facX=%i, facY=%i WHERE facID=%i",
                       iTime, lev21x, lev21y, facpt.facID];
    char *error = NULL;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (BOOL)storeFacilityToDB:(Facility *)fac
               withStatus:(int)status
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Facilities SET lastUpdateTime=%i, status=%i,\
                       facX=%i,\
                       facY=%i,\
                       WHERE facID=%i",
                       iTime, status,
                       fac.lev21x,
                       fac.lev21y,
                       fac.facID];
    
    char *error = NULL;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (Facility *)getFacilityFromDB:(int)facID
                      withRamps:(BOOL)wantRamps
{
    Facility *fac;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Facilities WHERE facID=%i", facID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        fac = [[Facility alloc] init];
        [CRAPI.sharedInstance facilityInit:fac];
        fac.facID = facID;
        fac.lev21x = sqlite3_column_int(statement, 4);
        fac.lev21y = sqlite3_column_int(statement, 5);
    }
    
    SQLOK(sqlite3_finalize(statement), _database);
    return fac;
}

- (FacilityPoint *)getFirstAssignedFacilityPointWithStatus0
{
    {
        FacilityPoint *facpt;
        
        NSString *query = [NSString stringWithFormat:@"SELECT facID, facX, facY FROM Facilities WHERE status=0 ORDER BY facID ASC"];
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL),_database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            int facID = sqlite3_column_int(statement, 0);
            int facX = sqlite3_column_int(statement, 1);
            int facY = sqlite3_column_int(statement, 2);
            double lat,lon;
            facpt = [[FacilityPoint alloc] init];
            PixelXYToLatLong(facX, facY, 21, &lat, &lon);
            facpt.latitude = lat;
            facpt.longitude = lon;
            facpt.facID = facID;
        }
        
        SQLOK(sqlite3_finalize(statement), _database);
        return facpt;
    }
}

- (BOOL)setFacilityStatusTo:(int)status
                forFacility:(int)facID
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Facilities SET lastUpdateTime=%i, status=%i WHERE facID=%i",
                       iTime, status, facID];
    
    char *error = NULL;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (BOOL)assignFacility:(int)facID
                    to:(int)user
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Facilities SET lastUpdateTime=%i, assignedTo=%i WHERE facID=%i",
                       iTime, user, facID];
    char *error = NULL;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (NSString *)facilityTextPath:(int)type
{
    NSString *path;
    
    NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    //NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    if (type == FAC_TEXT_DATA)
        path = [NSString stringWithFormat:@"%@/%i/facility_data.bin", documentsDirectory, self.geoid];
    
    else
        path = [NSString stringWithFormat:@"%@/%i/facility_index.bin", documentsDirectory, self.geoid];
    
    return path;
}

- (int)loadFacilityTextToDatabase:(NSString *)path
{
    BOOL rtn = FACDB_FAILED;
    char dataFile[PATH_MAX], indexFile[PATH_MAX];
    LPSTR pUB;
    FILE *fidData, *fidIndex;
    char data[258], index[256];
    int maxData = 256;
    int maxIndex = 100;
    int nLoaded = 0;
    char buffer[] = "INSERT INTO Facilities VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt *statement = NULL;
    char *error = NULL;
    FACILITY_STRUCT facStruct = {0};
    int *pInt, i;
    
    strcpy(dataFile,path.UTF8String);
    
    if ((pUB = strrchr (dataFile, '_')))
        *pUB = 0;
    
    else
        goto Exit;
    
    strcpy(indexFile, dataFile);
    strcat(indexFile, "/facility_index.bin");
    strcat(dataFile, "/facility_data.bin");
    fidData = fopen(dataFile, "rb");
    fidIndex = fopen(indexFile, "rb");
    
    NSLog (@"loadFacilityTextToDatabase fopen file: %s", indexFile);
    
    if (!fidData || !fidIndex)
        goto Exit;
    
    [self createFacilitiesTable];
    
    SQLOK(sqlite3_prepare_v2(_database, buffer, -1, &statement, NULL),_database);
    SQLOK(sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    fgetstring(index, maxIndex, fidIndex);
    
    while (fgetstring(data, maxData, fidData))
    {
        LPSTR pTab = strchr(data,'\t');
        LPSTR pTabIndex, pAzms, pEnd;
        fgetstring(index, maxIndex, fidIndex);
        pTabIndex = strchr(index,'\t');
        *pTab++ = 0;
        *pTabIndex = 0;
        pTabIndex = strchr(index,' ');
        *pTabIndex++ = 0;
        facStruct.facID = atoi(data);
        facStruct.lev21Y = atoi(index);
        facStruct.lev21X = atoi(pTabIndex);
        facStruct.assignedTo = 0;
        facStruct.status = 0;
        facStruct.nStreets = atoi(pTab);
        pTab = strchr(pTab,'\t') + 1;
        pAzms = strchr(pTab,'\t');
        *pAzms++ = 0;
        pEnd = strchr(pAzms,'\t');
        *pEnd = 0;
        strncpy(facStruct.streetNames, pTab, sizeof(facStruct.streetNames) - 1);
        strncpy(facStruct.streetAzms, pAzms, sizeof(facStruct.streetAzms) - 1);
        
        for (i = 1, pInt = &facStruct.facID; i < 29; i++, pInt++)
            SQLOK(sqlite3_bind_int(statement, i, *pInt), _database);
        
        SQLOK(sqlite3_bind_text(statement, 29, facStruct.streetNames, -1, SQLITE_STATIC), _database);
        SQLOK(sqlite3_bind_text(statement, 30, facStruct.streetAzms, -1, SQLITE_STATIC),_database);
        
        if (sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Error inserting facility. '%s'", sqlite3_errmsg(_database));
        
        nLoaded++;
        SQLOK(sqlite3_reset(statement), _database);
    }
    
    SQLOK(sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &error), _database);
    sqlite3_free(error);
    SQLOK(sqlite3_finalize(self.statement),_database);
    
    fclose(fidIndex);
    fclose(fidData);
    rtn = INTDBStatusOK;
    
Exit:
    return rtn;
}

- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(int)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    if (status == FTPStatusOK || status == FTPStatusFileExists)
    {
        NSString *toDirectory = [CRAPI.sharedInstance directoryFromPath:path
                                                                andName:[NSString stringWithFormat:@"/%i",self.geoid] create:YES];
        if (self.gettingUploaded)
            SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        
        else
        {
            DecompressGMZipFile((LPSTR)path.UTF8String, (LPSTR)toDirectory.UTF8String);
            status = [self loadFacilityTextToDatabase:path];
        }
        
        if (self.delegate)
        {
            [self.delegate facilitiesDatabase:[self databasePath:self.geoid]
                                      didLoad:@""
                                   withStatus:status];
        }
    }
    
    else if (status == FTPStatusConnectionFailed)
    {
        if (self.gettingUploaded)
            [self.delegate facilitiesDatabase:nil
                                      didLoad:@"File not found"
                                   withStatus:FAC_NO_UPLOADED_FILE];
        else
            [self.delegate facilitiesDatabase:nil
                                      didLoad:@"File not found"
                                   withStatus:FAC_NO_NETWORK_CONNECTION];
    }
    
    else if (status != FTPStatusStop)
    {
        [self.delegate facilitiesDatabase:nil
                                  didLoad:@"FTP failure"
                               withStatus:FACDB_FAILED];
    }
}

- (int)getCountOfFacilities
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Facilities"];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(sqlite3_finalize(statement), _database);
    return count;
}

- (void)close
{
    sqlite3_close(_database);
}

- (void)dealloc
{
    sqlite3_close(_database);
    _statdatabase = nil;
}

- (void)logError:(int)sqlReturn
          method:(char *)method
{
    NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i in %s = %i:%s",
                  sqlReturn, method, sqlite3_errcode(_database), sqlite3_errmsg(_database)]);
}

@end