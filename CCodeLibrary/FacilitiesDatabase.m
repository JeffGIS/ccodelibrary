//  FacilitiesDatabase.m
//  CCodeLibrary

#import "FacilitiesDatabase.h"
#import "IntersectionsDatabase.h"
#import "TileGraphics.h"
#import "MathTypes.h"
#import "MathUtil.h"
#import "CRAPI.h"
#import "compress.h"
#import "shr.h"
#import "FacilityRecord.h"
#import "FacilitiesStepValue.h"
#import "FacilityStepDefinition.h"

@implementation FacilitiesDatabase

static FacilitiesDatabase *_statdatabase = nil;
static char lastDBPath[PATH_MAX]={0};

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
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%i/Facilities.slt", documentsDirectory, geoid];
    strcpy (lastDBPath,dbPath.UTF8String);
    return dbPath;
}

- (void)createFacilitiesTable
{
    char *error = NULL;
    
    Bool opened = [self open];
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS FacilityValues;"];
    
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, dropQuery.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS FacilityValues (\
                       facilityNumber INT,\
                       stepValueID CHAR(64),\
                       lastUpdateTime INTEGER,\
                       stepDefinitionID CHAR(64),\
                       header CHAR(256),\
                       prompt CHAR(256),\
                       value CHAR(256),\
                       needPhoto INT, numPhotos INT,\
                       complete INT,\
                       comment CHAR(1024), PRIMARY KEY (facilityNumber ASC, stepValueID ASC));"];
    
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, query.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
    
/*    query =[NSString stringWithFormat:@"CREATE INDEX xindex ON Facilities (facX);"];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, query.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX yindex ON Facilities (facY);"];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, query.UTF8String, NULL, NULL, &error), _database);
    sqlite3_free(error);*/
    [self close:opened];
}

- (int)getOffsetCoord:(Facility *)fac
                    x:(int)x
                    y:(int)y
{
    int offCoord = 0;
    short offx=0, offy=0;
    
    //offx = (x - fac.lev21x);
    //offy = (y - fac.lev21y);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
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
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
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
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
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
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    return facpt;
}

- (NSString *)getCurrentFacilityAZMs:(int)facID
                            nStreets:(int *)pnStreets
{
    NSString * rtn = [[NSString alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT nStreets, streetAZMs FROM Facilities WHERE facID=%i", facID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nStreets = sqlite3_column_int(statement, 0);
        *pnStreets = nStreets;
        LPSTR pAZMs = (LPSTR)sqlite3_column_text(statement, 1);
        rtn = [NSString stringWithUTF8String:pAZMs];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
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
    rtn = SQLiteExec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (BOOL)storeFacilityToDB:(Facility *)fac
               withStatus:(int)status
{
    BOOL rtn = NO;
/*    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Facilities SET lastUpdateTime=%i, status=%i,\
                       facX=%i,\
                       facY=%i,\
                       WHERE facID=%i",
                       iTime, status,
                       fac.lev21x,
                       fac.lev21y,
                       fac.facID];
    
    char *error = NULL;
    rtn = SQLiteExec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);*/
    return !rtn;
}

- (Facility *)getFacilityFromDB:(int)facID
                      withRamps:(BOOL)wantRamps
{
    Facility *fac=0;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Facilities WHERE facID=%i", facID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        fac = [[Facility alloc] init];
//        [CRAPI.sharedInstance facilityInit:fac];
        fac.facID = facID;
//        fac.lev21x = sqlite3_column_int(statement, 4);
//        fac.lev21y = sqlite3_column_int(statement, 5);
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    return fac;
}

- (FacilityPoint *)getFirstAssignedFacilityPointWithStatus0
{
    {
        FacilityPoint *facpt;
        
        NSString *query = [NSString stringWithFormat:@"SELECT facID, facX, facY FROM Facilities WHERE status=0 ORDER BY facID ASC"];
        sqlite3_stmt *statement = NULL;
        
        SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL),_database);
        
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
        
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
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
    rtn = SQLiteExec(_database, query.UTF8String, NULL, NULL, &error);
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
    rtn = SQLiteExec(_database, query.UTF8String, NULL, NULL, &error);
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
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, buffer, -1, &statement, NULL),_database);
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN TRANSACTION", NULL, NULL, &error), _database);
    sqlite3_free(error);
    
    fgetstringF(index, maxIndex, fidIndex);
    
    while (fgetstringF(data, maxData, fidData))
    {
        LPSTR pTab = strchr(data,'\t');
        LPSTR pTabIndex, pAzms, pEnd;
        fgetstringF(index, maxIndex, fidIndex);
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
            SQLOK(__FILE__,__LINE__,sqlite3_bind_int(statement, i, *pInt), _database);
        
        SQLOK(__FILE__,__LINE__,sqlite3_bind_text(statement, 29, facStruct.streetNames, -1, SQLITE_STATIC), _database);
        SQLOK(__FILE__,__LINE__,sqlite3_bind_text(statement, 30, facStruct.streetAzms, -1, SQLITE_STATIC),_database);
        
        if (sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Error inserting facility. '%s'", sqlite3_errmsg(_database));
        
        nLoaded++;
        SQLOK(__FILE__,__LINE__,sqlite3_reset(statement), _database);
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT TRANSACTION", NULL, NULL, &error), _database);
    sqlite3_free(error);
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(self.statement),_database);
    
    fclose(fidIndex);
    fclose(fidData);
    rtn = INTDBStatusOK;
    
Exit:
    return rtn;
}

- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    if (status == FTPStatusOK || status == FTPStatusFileExists)
    {
        NSString *toDirectory = [CRAPI.sharedInstance directoryFromPath:path
                                                                andName:[NSString stringWithFormat:@"/%i",self.geoid] create:YES];
        if (self.gettingUploaded)
            SQLOK(__FILE__,__LINE__,sqlite3_open(self.path.UTF8String, &_database), _database);
        
        else
        {
            DecompressGMZipFile((LPSTR)path.UTF8String, (LPSTR)toDirectory.UTF8String,0,0,0);
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
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    return count;
}
- (NSArray *) getValuesForFacility:(int) faciltyNumber
{
    NSMutableArray * array = NSMutableArray.new;
    NSString *query = [NSString stringWithFormat:@"SELECT stepValueID, stepDefinitionID, header, prompt, value, needPhoto, complete FROM FacilityValues WHERE facilityNumber = %i",faciltyNumber];
    sqlite3_stmt *statement = NULL;
    Bool opened = [self open];
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int i = 0;
        FacilitiesStepValue *fsv = FacilitiesStepValue.new;
        
        LPSTR value = (LPSTR)sqlite3_column_text(statement, i++);
        fsv.stepValueID = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        fsv.stepDefinitionID = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        fsv.header = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        fsv.prompt = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, i++);
        fsv.value = [NSString stringWithUTF8String:value];
        fsv.needPhoto = sqlite3_column_int(statement, i++);
        fsv.completionStatus = sqlite3_column_int(statement, i++);
        
        [array addObject:fsv];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return array;
}

- (BOOL)open
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        self.isOpen = !SQLOK(__FILE__,__LINE__,sqlite3_open(_path.UTF8String, &_database), _database);
        NSLog(@"Facilities Database open");
        
        rtn = TRUE;
    }
    
    return rtn;
}

- (BOOL)open:(LPCSTR)path
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        self.isOpen = !SQLOK(__FILE__,__LINE__,sqlite3_open(path, &_database), _database);
        NSLog(@"Facilities Database open");
        
        rtn = TRUE;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        SQLOK(__FILE__,__LINE__,sqlite3_close(_database),_database);
        NSLog(@"Facilities Database close");
        self.isOpen = NO;
    }
}

- (BOOL)executeCmd:(LPCSTR)cmd
{
    BOOL rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    return rtn;
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

- (void) loadTestData:(int)facID
{
    Bool opened = [self open];
    NSString * stepValueID = @"1";
    NSString * stepDefID = @"NumFloors";
    NSString * prompt = @"";
    NSString * value = @"";
    NSString * header = @"Eagan City Hall";
    NSString * comment = @"";
    int lastUpdate = 0;
    int needPhoto = 0, numPhotos = 0;
    int completionStatus = 0;
    NSString * cmd = [NSString stringWithFormat:@"INSERT INTO FacilityValues VALUES (%i,'%@',%i,'%@','%@','%@','%@',%i,%i,%i,'%@')",facID,stepValueID,lastUpdate,stepDefID,header,prompt,value,needPhoto,numPhotos,completionStatus,comment];
    [self executeCmd:cmd.UTF8String];
    [self close:opened];
}

+ (Bool) setValueForStep:(NSString *)stepID to:(NSString *)value
{
    Bool rtn = FALSE;
    int facID = CRAPI.sharedInstance.currentFacility.facID;
    FacilitiesDatabase * fd = FacilitiesDatabase.new;
    Bool opened = [fd open:lastDBPath];
    NSString * cmd = [NSString stringWithFormat:@"UPDATE FacilityValues SET Value = '%@', Complete=1 WHERE facilityNumber=%i AND stepValueID='%@'",value, facID, stepID];
    rtn = [fd executeCmd:cmd.UTF8String];
    [fd close:opened];
    return rtn;
}

+ (Bool) setHeaderForStep:(NSString *)stepID to:(NSString *)value
{
    Bool rtn = FALSE;
    if (![stepID isEqualToString:@""])
    {
        int facID = CRAPI.sharedInstance.currentFacility.facID;
        FacilitiesDatabase * fd = FacilitiesDatabase.new;
        Bool opened = [fd open:lastDBPath];
        NSString * cmd = [NSString stringWithFormat:@"UPDATE FacilityValues SET Header = '%@' WHERE facilityNumber=%i AND stepValueID='%@'",value, facID, stepID];
        rtn = [fd executeCmd:cmd.UTF8String];
        [fd close:opened];
    }
    return rtn;
}

+ (Bool) setPriorHeaderForStep:(NSString *)stepID to:(NSString *)value
{
    Bool rtn = FALSE;
    if ([stepID containsString:@"."])
    {
        int facID = CRAPI.sharedInstance.currentFacility.facID;
        FacilitiesDatabase * fd = FacilitiesDatabase.new;
        Bool opened = [fd open:lastDBPath];
        NSString * priorStepID = [stepID stringByDeletingPathExtension];
        NSString * cmd = [NSString stringWithFormat:@"UPDATE FacilityValues SET Header = '%@' WHERE facilityNumber=%i AND stepValueID='%@'",value, facID, priorStepID];
        rtn = [fd executeCmd:cmd.UTF8String];
        [fd close:opened];
    }
    return rtn;
}

- (NSString *) getHeaderForStep:(NSString *)stepID
{
    NSString * header = @"";
    int facID = CRAPI.sharedInstance.currentFacility.facID;
    NSString *query = [NSString stringWithFormat:@"SELECT header, value FROM FacilityValues WHERE facilityNumber = %i AND stepValueID = '%@'",facID,stepID];
    sqlite3_stmt *statement = NULL;
    Bool opened = [self open];
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, NULL), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        
        LPSTR value = (LPSTR)sqlite3_column_text(statement, 0);
        header = [NSString stringWithUTF8String:value];
        value = (LPSTR)sqlite3_column_text(statement, 1);
        HANDLE hSaveValue = SaveValue ();
        SetValue (value);
        header = ExpandString (header);
        RestoreValue (hSaveValue);
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return header;
}
+ (NSString *) removeLastStep:(NSString *)stepID
{
    NSString * newStepID = stepID;
    if ([newStepID containsString:@"."])
        newStepID = [newStepID stringByDeletingPathExtension];
    else
        newStepID = @"";
    return newStepID;
}
+ (NSString *) getCompositeHeaderForStep:(NSString *)stepID
{
    int nLines = 0;
    NSString * compHeader = @"";
    NSString * newStepID = stepID;
    FacilitiesDatabase * fd = FacilitiesDatabase.new;
    Bool opened = [fd open:lastDBPath];
    do{
        NSString * header = [fd getHeaderForStep:newStepID];
        if (![header isEqualToString:@""])
        {
            compHeader = [NSString stringWithFormat:@"%@\n%@",header,compHeader];
            nLines++;
        }
        newStepID = [FacilitiesDatabase removeLastStep:newStepID];
    }while (![newStepID isEqualToString:@""] && nLines < 5);
    [fd close:opened];
    return compHeader;
}
Bool AddStep (LPSTR stepValueID,LPCSTR stepDefID,LPCSTR prompt,LPCSTR value,LPCSTR header,int needPhoto)
{
    Bool rtn = FALSE;
    FacilitiesDatabase * fd = FacilitiesDatabase.new;
    Bool opened = [fd open:lastDBPath];
    char comment[2] = {0};
    int lastUpdate = 0;
    int numPhotos = 0;
    int completionStatus = 0;
    int facID = CRAPI.sharedInstance.currentFacility.facID;
    NSString * headerValue;
    if (header && *header)
        headerValue = [NSString stringWithUTF8String:header];
    else
        headerValue = [FacilityStepDefinition getStepHeader:[NSString stringWithUTF8String:stepDefID]];
    NSString * cmd = [NSString stringWithFormat:@"INSERT INTO FacilityValues VALUES (%i,'%s',%i,'%s','%s','%s','%s',%i,%i,%i,'%s')",facID,stepValueID,lastUpdate,stepDefID,headerValue.UTF8String,prompt,value,needPhoto,numPhotos,completionStatus,comment];
    rtn = [fd executeCmd:cmd.UTF8String];
    
    [fd close:opened];
    return rtn;
}

@end
