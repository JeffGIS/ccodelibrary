//  IntersectionsDatabase.m
//  CCodeLibrary

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
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Intersections (\
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
                       streetAZMs CHAR(128));"];
    
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX xindex ON Intersections (intX);"];
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
    
    query =[NSString stringWithFormat:@"CREATE INDEX yindex ON Intersections (intY);"];
    SQLOK(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error));
    sqlite3_free(error);
    /*
     intID INTEGER PRIMARY KEY,\    0
     lastUpdateTime INTEGER,\       1
     status INTEGER,\               2
     assignedTo INTEGER,\           3
     intX INTEGER,\                 4
     intY INTEGER,\                 5
     rotation INTEGER,\             6
     ramp1 INTEGER,\                7
     ramp2 INTEGER,\                8
     ramp3 INTEGER,\                9
     ramp4 INTEGER,\                10
     ramp5 INTEGER,\                11
     ramp6 INTEGER,\                12
     ramp7 INTEGER,\                13
     ramp8 INTEGER,\                14
     ramp81 INTEGER,\               15
     ramp23 INTEGER,\               16
     ramp45 INTEGER,\               17
     ramp67 INTEGER,\               18
     xWalkA INTEGER,\               19
     xWalkB INTEGER,\               20
     xWalkC INTEGER,\               21
     xWalkD INTEGER,\               22
     signal81 INTEGER,\             23
     signal23 INTEGER,\             24
     signal45 INTEGER,\             25
     signal67 INTEGER,\             26
     nStreets INTEGER,\             27
     streetNames CHAR(512),\        28
     */

}

- (int)getOffsetCoord:(MPIntersection *)mpint
                    x:(int)x
                    y:(int)y
{
    int offCoord = 0;
    short offx, offy;
    
    offx = (x - mpint.lev21x);
    offy = (y - mpint.lev21y);
    
    offCoord = (int)MAKELONG(offx, offy);
    return offCoord;
}

- (int)getRampCoord:(MPIntersection *)mpint
               ramp:(int)r
{
    int icoord = 0;
    MPRamp *ramp = mpint.ramps[r];
    
    if (ramp.rampExists)
        icoord = [self getOffsetCoord:mpint
                                    x:ramp.lev21x
                                    y:ramp.lev21y];
    return icoord;
    
}
- (void) setRampCoord:(MPIntersection*)mpint
                 ramp:(int)r
                 from:(sqlite3_stmt*)statement
{
    int icol = 7 + (r - 1);
    int icoord = sqlite3_column_int(statement, icol);
    
    short offsetx = LOWORD(icoord);
    short offsety = HIWORD(icoord);
    MPRamp *ramp = mpint.ramps[r];
    int lev21x = mpint.lev21x + offsetx;
    int lev21y = mpint.lev21y + offsety;
    
    if (icoord)
    {
        ramp.lev21x = lev21x;
        ramp.lev21y = lev21y;
        ramp.rampExists = YES;
    }
    
    else
        ramp.rampExists = NO;
}


- (int)getXWalkCoord:(MPIntersection *)mpint
               xWalk:(char)xw
{
    int icoord = 0;
    
    switch (xw)
    {
        case 'A':
            if (mpint.xWalkAExists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.xWalkAlev21x
                                            y:mpint.xWalkAlev21y];
            }
            
            break;
            
        case 'B':
            if (mpint.xWalkBExists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.xWalkBlev21x
                                            y:mpint.xWalkBlev21y];
            }
            
            break;
            
        case 'C':
            if (mpint.xWalkCExists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.xWalkClev21x
                                            y:mpint.xWalkClev21y];
            }
            
            break;
            
        case 'D':
            if (mpint.xWalkDExists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.xWalkDlev21x
                                            y:mpint.xWalkDlev21y];
            }
            
            break;
    }
    
    return icoord;
}
- (void)setXWalkCoord:(MPIntersection *)mpint
                xWalk:(char)xw
                 from:(sqlite3_stmt *)statement
{
    int icol = (19 + (xw - 'A'));
    int icoord = sqlite3_column_int(statement, icol);
    
    short offsetx = LOWORD(icoord);
    short offsety = HIWORD(icoord);
    
    switch (xw)
    {
        case 'A':
            if (icoord)
            {
                mpint.xWalkAlev21x = mpint.lev21x + offsetx;
                mpint.xWalkAlev21y = mpint.lev21y + offsety;
                mpint.xWalkAExists = YES;
            }
            
            else
                mpint.xWalkAExists = NO;
            
            break;
            
        case 'B':
            if (icoord)
            {
                mpint.xWalkBlev21x = mpint.lev21x + offsetx;
                mpint.xWalkBlev21y = mpint.lev21y + offsety;
                mpint.xWalkBExists = YES;
            }
            
            else
                mpint.xWalkBExists = NO;
            
            break;
            
        case 'C':
            if (icoord)
            {
                mpint.xWalkClev21x = mpint.lev21x + offsetx;
                mpint.xWalkClev21y = mpint.lev21y + offsety;
                mpint.xWalkCExists = YES;
            }
            
            else
                mpint.xWalkCExists = NO;
            
            break;
            
        case 'D':
            if (icoord)
            {
                mpint.xWalkDlev21x = mpint.lev21x + offsetx;
                mpint.xWalkDlev21y = mpint.lev21y + offsety;
                mpint.xWalkDExists = YES;
            }
            
            else
                
                mpint.xWalkDExists = NO;
            break;
    }
}

- (int)getSignalCoord:(MPIntersection*)mpint
               signal:(int)sig
{
    int icoord = 0;
    
    switch (sig)
    {
        case 81:
            if (mpint.signal81Exists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.signal81lev21x
                                            y:mpint.signal81lev21y];
            }
            
            break;
            
        case 23:
            if (mpint.signal23Exists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.signal23lev21x
                                            y:mpint.signal23lev21y];
            }
            
            break;
            
        case 45:
            if (mpint.signal45Exists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.signal45lev21x
                                            y:mpint.signal45lev21y];
            }
            
            break;
            
        case 67:
            if (mpint.signal67Exists)
            {
                icoord = [self getOffsetCoord:mpint
                                            x:mpint.signal67lev21x
                                            y:mpint.signal67lev21y];
            }
            
            break;
    }
    
    return icoord;
}
- (void)setSignalCoord:(MPIntersection *)mpint
                signal:(int)s
                  from:(sqlite3_stmt *)statement
{
    int icol = 23;
    switch (s)
    {
        case 81:
            break;
            
        case 23:
            icol++;
            break;
            
        case 45:
            icol += 2;
            break;
            
        case 67:
            icol += 3;
            break;
    }
    
    int icoord = sqlite3_column_int(statement, icol);
    
    short offsetx = LOWORD(icoord);
    short offsety = HIWORD(icoord);
    
    switch (s)
    {
        case 81:
            if (icoord)
            {
                mpint.signal81lev21x = mpint.lev21x + offsetx;
                mpint.signal81lev21y = mpint.lev21y + offsety;
                mpint.signal81Exists = YES;
            }
            
            else
                mpint.signal81Exists = NO;
            
            break;
            
        case 23:
            if (icoord)
            {
                mpint.signal23lev21x = mpint.lev21x + offsetx;
                mpint.signal23lev21y = mpint.lev21y + offsety;
                mpint.signal23Exists = YES;
            }
            
            else
                mpint.signal23Exists = NO;
            
            break;
            
        case 45:
            if (icoord)
            {
                mpint.signal45lev21x = mpint.lev21x + offsetx;
                mpint.signal45lev21y = mpint.lev21y + offsety;
                mpint.signal45Exists = YES;
            }
            
            else
                mpint.signal45Exists = NO;
            
            break;
            
        case 67:
            if (icoord)
            {
                mpint.signal67lev21x = mpint.lev21x + offsetx;
                mpint.signal67lev21y = mpint.lev21y + offsety;
                mpint.signal67Exists = YES;
            }
            
            else
                mpint.signal67Exists = NO;
            
            break;
    }
}


- (BOOL)storeMPIntersectionToDB:(MPIntersection*)mpint
                     withStatus:(int)status
{
    BOOL rtn;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%i,\
                       intX=%i,\
                       intY=%i,\
                       ramp1=%i,\
                       ramp2=%i,\
                       ramp3=%i,\
                       ramp4=%i,\
                       ramp5=%i,\
                       ramp6=%i,\
                       ramp7=%i,\
                       ramp8=%i,\
                       ramp81=%i,\
                       ramp23=%i,\
                       ramp45=%i,\
                       ramp67=%i,\
                       xWalkA=%i,\
                       xWalkB=%i,\
                       xWalkC=%i,\
                       xWalkD=%i,\
                       signal81=%i,\
                       signal23=%i,\
                       signal45=%i,\
                       signal67=%i \
                       WHERE intID=%i",
                       iTime, status,
                       mpint.lev21x,
                       mpint.lev21y,
                       [self getRampCoord:mpint ramp:1],
                       [self getRampCoord:mpint ramp:2],
                       [self getRampCoord:mpint ramp:3],
                       [self getRampCoord:mpint ramp:4],
                       [self getRampCoord:mpint ramp:5],
                       [self getRampCoord:mpint ramp:6],
                       [self getRampCoord:mpint ramp:7],
                       [self getRampCoord:mpint ramp:8],
                       [self getRampCoord:mpint ramp:9],
                       [self getRampCoord:mpint ramp:10],
                       [self getRampCoord:mpint ramp:11],
                       [self getRampCoord:mpint ramp:12],
                       [self getXWalkCoord:mpint xWalk:'A'],
                       [self getXWalkCoord:mpint xWalk:'B'],
                       [self getXWalkCoord:mpint xWalk:'C'],
                       [self getXWalkCoord:mpint xWalk:'D'],
                       [self getSignalCoord:mpint signal:81],
                       [self getSignalCoord:mpint signal:23],
                       [self getSignalCoord:mpint signal:45],
                       [self getSignalCoord:mpint signal:67],
                       mpint.intID];
    
    char *error;
    rtn = sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (MPIntersection*)getMPIntersectionFromDB:(int)intID
                                 withRamps:(BOOL)wantRamps
{
    MPIntersection *mpint = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        mpint = [[MPIntersection alloc]init];
        [CRAPI.sharedInstance intersectionInit:mpint];
        mpint.intID = intID;
        mpint.lev21x = sqlite3_column_int(statement, 4);
        mpint.lev21y = sqlite3_column_int(statement, 5);
        [self setRampCoord:mpint ramp:1 from:statement];
        [self setRampCoord:mpint ramp:2 from:statement];
        [self setRampCoord:mpint ramp:3 from:statement];
        [self setRampCoord:mpint ramp:4 from:statement];
        [self setRampCoord:mpint ramp:5 from:statement];
        [self setRampCoord:mpint ramp:6 from:statement];
        [self setRampCoord:mpint ramp:7 from:statement];
        [self setRampCoord:mpint ramp:8 from:statement];
        [self setRampCoord:mpint ramp:9 from:statement];
        [self setRampCoord:mpint ramp:10 from:statement];
        [self setRampCoord:mpint ramp:11 from:statement];
        [self setRampCoord:mpint ramp:12 from:statement];
        [self setXWalkCoord:mpint xWalk:'A' from:statement];
        [self setXWalkCoord:mpint xWalk:'B' from:statement];
        [self setXWalkCoord:mpint xWalk:'C' from:statement];
        [self setXWalkCoord:mpint xWalk:'D' from:statement];
        [self setSignalCoord:mpint signal:81 from:statement];
        [self setSignalCoord:mpint signal:23 from:statement];
        [self setSignalCoord:mpint signal:45 from:statement];
        [self setSignalCoord:mpint signal:67 from:statement];
    }
    
    SQLOK(sqlite3_finalize(statement));
    return mpint;
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
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, status, intX, intY,\
                       ramp1,ramp2,ramp3,ramp4,ramp5,ramp6,ramp7,ramp8,ramp81,ramp23,ramp45,ramp67 \
                       FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn, (int)bounds.xmx, (int)bounds.ymn, (int)bounds.ymx];
    
    sqlite3_stmt *statement;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int status = sqlite3_column_int(statement, 1);
        int intX = sqlite3_column_int(statement, 2);
        int intY = sqlite3_column_int(statement, 3);
        int nRamps = 0;
        
        for (int i = 4; i < 16; i++)
        {
            if (sqlite3_column_int(statement, i) != 0)
                nRamps++;
        }
        
        double lat,lon;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.status = status;
        intpt.nramps = nRamps;
        
        if (status)
            status++;
        
        intpt.intID = intID;
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement));
    return dataArray;
}

- (NSMutableArray *)getIntersectionElementsFromDatabaseinBounds:(IBOUNDS)bounds
                                                      skipIntID:(int)skipID
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, status, intX, intY,\
                       ramp1,ramp2,ramp3,ramp4,ramp5,ramp6,ramp7,ramp8,ramp81,ramp23,ramp45,ramp67,\
                       xWalkA,xWalkB,xWalkC,xWalkD,\
                       signal81,signal23,signal45,signal67 \
                       FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn, (int)bounds.xmx, (int)bounds.ymn, (int)bounds.ymx];
    
    sqlite3_stmt *statement;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int intX = sqlite3_column_int(statement, 2);
        int intY = sqlite3_column_int(statement, 3);
        IntersectionElement *intEl = [[IntersectionElement alloc] init];
        intEl.type = INT_ELEMENT_TYPE_INTERSECTION;
        intEl.lev21x = intX;
        intEl.lev21y = intY;
        
        if (intID != skipID)
        {
            [dataArray addObject:intEl];
            
            for (int i = 4; i < 16; i++)
            {
                int icoord = sqlite3_column_int(statement, i);
                
                if (icoord != 0)
                {
                    short offsetx = LOWORD(icoord);
                    short offsety = HIWORD(icoord);
                    IntersectionElement *intEl = [[IntersectionElement alloc] init];
                    intEl.intID = intID;
                    intEl.elementID = (i - 3);
                    intEl.type = INT_ELEMENT_TYPE_RAMP;
                    intEl.lev21x = intX + offsetx;
                    intEl.lev21y = intY + offsety;
                    [dataArray addObject:intEl];
                }
            }
            
            for (int i = 16; i < 20; i++)
            {
                int icoord = sqlite3_column_int(statement, i);
                
                if (icoord != 0)
                {
                    short offsetx = LOWORD(icoord);
                    short offsety = HIWORD(icoord);
                    IntersectionElement *intEl = [[IntersectionElement alloc] init];
                    intEl.intID = intID;
                    intEl.elementID = (i - 15);
                    intEl.type = INT_ELEMENT_TYPE_XWALK;
                    intEl.lev21x = intX + offsetx;
                    intEl.lev21y = intY + offsety;
                    [dataArray addObject:intEl];
                }
            }
            
            for (int i = 20; i < 24; i++)
            {
                int icoord = sqlite3_column_int(statement, i);
                
                if (icoord != 0)
                {
                    short offsetx = LOWORD(icoord);
                    short offsety = HIWORD(icoord);
                    IntersectionElement *intEl = [[IntersectionElement alloc] init];
                    intEl.intID = intID;
                    intEl.elementID = (i - 19);
                    intEl.type = INT_ELEMENT_TYPE_SIGNAL;
                    intEl.lev21x = intX + offsetx;
                    intEl.lev21y = intY + offsety;
                    [dataArray addObject:intEl];
                }
            }
        }
    }
    
    SQLOK(sqlite3_finalize(statement));
    return dataArray;
}

- (NSMutableArray *)getIntersectionPointsWithinDistance:(int)meters
                                                ofPoint:(LLPOINT)latlon
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    IPOINT pt;
    int dist = (meters / GroundResolution(latlon.lat, 21));
    LatLongToPixelXY(latlon.lat, latlon.lon, 21, &pt.x, &pt.y);
    IBOUNDS bounds = IBoundsFromPointAndDist (pt, dist);
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, intX, intY FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn,(int)bounds.xmx,(int)bounds.ymn,(int)bounds.ymx];
    
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

- (BOOL) findIntersectionFromID:(int)intID
             intersectionText:(char *)intText
             intersectionAZMs:(char *)intAZMs
                   numStreets:(int *)pNumStreets
                     numRamps:(int *)pNumRamps
                         intX:(int *)plev21x
                         intY:(int *)plev21y

{
    BOOL rtn = FALSE;
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY, nStreets, streetNames, streetAZMs FROM Intersections WHERE intID = %i",intID];
    sqlite3_stmt *statement;
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        int nStreets = sqlite3_column_int(statement,2);
        LPSTR pStreets = (LPSTR)sqlite3_column_text(statement, 3);
        LPSTR pAZMS = (LPSTR)sqlite3_column_text(statement, 4);
        *plev21x = intX;
        *plev21y = intY;
        *pNumStreets = nStreets;
        strcpy(intText,pStreets);
        strcpy(intAZMs,pAZMS);
        rtn = TRUE;
    }
    
    SQLOK(sqlite3_finalize(statement));
    return rtn;
}

- (int) findIntersection:(int)lev21x
                       y:(int)lev21y
        intersectionText:(char *)intText
                whichInt:(int)iWant
        intersectionAZMs:(char *)intAZMs
              numStreets:(int *)pNumStreets
                numRamps:(int *)pNumRamps
                    intX:(int *)plev21x
                    intY:(int *)plev21y
{
    int rtn = 0;
    LLPOINT latlon;
    PixelXYToLatLong(lev21x, lev21y, 21, &latlon.lat, &latlon.lon);
    
    NSMutableArray * nearInts = [self getIntersectionPointsWithinDistance:500
                                                                  ofPoint:latlon];
    
    if (nearInts.count >= iWant)
    {
        IntersectionPoint * intpt = nearInts[iWant-1];
        
        NSString *query = [NSString stringWithFormat:@"SELECT intX, intY, nStreets, streetNames, streetAZMs FROM Intersections WHERE intID = %i",intpt.intID];
        
        sqlite3_stmt *statement;
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            int intX = sqlite3_column_int(statement, 0);
            int intY = sqlite3_column_int(statement, 1);
            int nStreets = sqlite3_column_int(statement,2);
            LPSTR pStreets = (LPSTR)sqlite3_column_text(statement, 3);
            LPSTR pAZMS = (LPSTR)sqlite3_column_text(statement, 4);
            *plev21x = intX;
            *plev21y = intY;
            *pNumStreets = nStreets;
            strcpy(intText,pStreets);
            strcpy(intAZMs,pAZMS);
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

- (NSString *)getCurrentIntersectionAZMs:(int)intID
                                nStreets:(int *)pnStreets
{
    NSString * rtn = [[NSString alloc]init];
    NSString *query = [NSString stringWithFormat:@"SELECT nStreets, streetAZMs FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement;
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL));
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nStreets = sqlite3_column_int(statement, 0);
        *pnStreets = nStreets;
        LPSTR pAZMs = (LPSTR)sqlite3_column_text(statement, 1);
        rtn = [NSString stringWithUTF8String:pAZMs];
    }
    
    SQLOK(sqlite3_finalize(statement));
    return rtn;
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
- (BOOL)setIntersectionStatusTo:(int)status
                forIntersection:(int)intID
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
    
    NSString *query = [NSString stringWithFormat:@"SELECT intID, intX, intY FROM Intersections WHERE status=0 ORDER BY intID ASC"];
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
    
    strcpy(indexFile, dataFile);
    strcat(indexFile, "/intersection_index.bin");
    strcat(dataFile, "/intersection_data.bin");
    fidData = fopen(dataFile, "rb");
    fidIndex = fopen(indexFile, "rb");
    
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
        intStruct.assignedTo = 0;
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
    
    else if (status == FTP_CONNECTION_FAILED)
    {
        [self.delegate intersectionsDatabase:nil
                                     didLoad:@"Internet Connection Not Available"
                                  withStatus:INT_NO_NETWORK_CONNECTION];
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