//  IntersectionsDatabase.m
//  CCodeLibrary

#import "IntersectionsDatabase.h"
#import "IntersectionRecord.h"
#import "CRAPI.h"
#import "TileGraphics.h"
#import "MathUtil.h"
#import "compress.h"

@interface IntersectionsDatabase ()

@property (nonatomic) GSSiPopoverView *popover;

@end

@implementation IntersectionsDatabase

static int SQLOK(int sqlReturn,sqlite3 *database)
{
    if (sqlReturn != SQLITE_OK)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i = %i:%s",
                      sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database)]);
    }
    
    return sqlReturn;
}

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid
{
    IntersectionsDatabase *db = [[IntersectionsDatabase alloc] initWithGeoid:geoid];
    
    return db;
}

- (id)initWithGeoid:(int)geoid
{
    if ((self = [super init]))
    {
        self.geoid = geoid;
        self.curbRampData = [CurbRampData databaseForGeoid:geoid
                                                    create:NO];
        NSLog(@"Intersections Database init");
    }
    
    return self;
}

/*- (BOOL)createIntersectionsTable_old
{
    char *error = NULL;
    BOOL rtn = NO;
    
    [self open];
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;"];
    
    SQLOKint(sqlite3_exec(_database, dropQuery.UTF8String, NULL, NULL, NULL), "createIntersectionsTable1");
    
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Intersections (\
                       intID INTEGER PRIMARY KEY,\
                       lastUpdateTime INTEGER,\
                       status INTEGER,\
                       assignedTo INTEGER,\
                       latitude double,\
                       longitude double,\
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
                       streetAZMs CHAR(128));\
                       CREATE VIRTUAL TABLE Intersections_index IF NOT EXISTS USING rtree(id,minX, maxX, minY, maxY);"];
    
    rtn = SQLOKint(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error), "createIntersectionsTable2");
    sqlite3_free(error);
    
    if (rtn != SQLITE_OK)
        return rtn;
    
    query =[NSString stringWithFormat:@"CREATE INDEX xindex ON Intersections (intX);"];
    rtn = SQLOKint(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error), "createIntersectionsTable3");
    sqlite3_free(error);
    
    if (rtn != SQLITE_OK)
        return rtn;
    
    query =[NSString stringWithFormat:@"CREATE INDEX yindex ON Intersections (intY);"];
    rtn = SQLOKint(sqlite3_exec(_database, query.UTF8String, NULL, NULL, &error), "createIntersectionsTable4");
    sqlite3_free(error);
    
    if (rtn == SQLITE_OK)
        rtn = YES;
    
    return rtn;
}*/

- (int)getOffsetCoord:(MPIntersection *)mpint
                    x:(int)x
                    y:(int)y
{
    int offCoord = 0;
    
    short offx = (x - mpint.lev21x);
    short offy = (y - mpint.lev21y);
    
    offCoord = (int)MAKELONG(offx, offy);
    return offCoord;
}

- (int)getRampCoord:(MPIntersection *)mpint
               ramp:(int)r
{
    int icoord = 0;
    MPRamp *ramp = mpint.ramps[r];
    
    if (ramp.rampExists)
    {
        icoord = [self getOffsetCoord:mpint
                                    x:ramp.lev21x
                                    y:ramp.lev21y];
    }
    
    return icoord;
    
}

- (void) setRampCoord:(MPIntersection *)mpint
                 ramp:(int)r
                 from:(sqlite3_stmt *)statement
{
    int icol = (9 + (r - 1));
    int icoord = sqlite3_column_int(statement, icol);
    
    short offsetx = LOWORD(icoord);
    short offsety = HIWORD(icoord);
    MPRamp *ramp = mpint.ramps[r];
    int lev21x = (mpint.lev21x + offsetx);
    int lev21y = (mpint.lev21y + offsety);
    
    if (icoord)
    {
        ramp.lev21x = lev21x;
        ramp.lev21y = lev21y;
        ramp.rampExists = YES;
        ramp.isComplete = NO;
    }
    
    else
    {
        ramp.rampExists = NO;
        ramp.isComplete = YES;
    }
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
    BOOL rtn = NO;
    NSString *cmd;
    double lat,lon;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    BOOL opened = [self.curbRampData open];
    for (int i = 1; i < 13; i++)
    {
        MPRamp *ramp = [mpint.ramps objectAtIndex:i];
        char rampID[32];
        
        mpint.currentRamp = ramp;
        
        if (mpint.currentRamp.rampExists || ramp.hasPEDButton || ramp.hasPEDSignal)
        {
            strcpy(rampID, mpint.currentRamp.rampID.UTF8String);
            
            /*cmd = [NSString stringWithFormat:@"UPDATE Ramps SET \
                    intID=%i;rampNum=%i,\r\n\
                    rampID=\"%s\";\r\n\
                    rampExists=%i;\r\n\
                    timeComplete=%i;\r\n\
                    approximateHeading=%f;\r\n\
                    rampInXWalk=%i;\r\n\
                    xWalkisComplete=%i;\r\n\
                    signalisComplete=%i;\r\n\
                    texture=%i;\r\n\
                    upperLandingObstruction=%i;\r\n\
                    lowerLandingObstruction=%i;\r\n\
                    rampObstruction=%i;\r\n\
                    hasRampCracks=%i;\r\n\
                    hasUpperLandingCracks=%i;\r\n\
                    hasStreetLandingCracks=%i;\r\n\
                    rampWidth=%i;\r\n\
                    rampDepth=%i;\r\n\
                    rampSlopeFront=%f;\r\n\
                    rampSlopeSide=%f;\r\n\
                    rampSlopeHeading=%f;\r\n\
                    upperLandingSlopeFront=%f;\r\n\
                    upperLandingSlopeSide=%f;\r\n\
                    upperLandingSlopeHeading=%f;\r\n\
                    streetLandingSlopeFront=%f;\r\n\
                    streetLandingSlopeSide=%f;\r\n\
                    streetLandingSlopeHeading=%f;\r\n\
                    flareLeftSlopeFront=%f;\r\n\
                    flareLeftSlopeSide=%f;\r\n\
                    flareLeftSlopeHeading=%f;\r\n\
                    flareRightSlopeFront=%f;\r\n\
                    flareRightSlopeSide=%f;\r\n\
                    flareRightSlopeHeading=%f;\r\n\
                    hasPEDSignal=%i;\r\n\
                    hasPEDButton=%i;\r\n\
                    PEDButtonHeight=%i;\r\n\
                    PEDButtonDist=%i;\r\n\
                    SteepTopOfCurb=%f;\r\n\
                    lev21x=%i;\r\n\
                    lev21y=%i;\r\n\
                    PedRampLip=%f);\r\n",
                    (int)mpint.intID,
                    (int)ramp.rampNum,
                    rampID,
                    ramp.rampExists,
                    ramp.timeComplete,
                    ramp.approximateHeading,
                    (int)ramp.rampInXWalk,
                    (int)ramp.xWalkisComplete,
                    (int)ramp.signalisComplete,
                    (int)ramp.texture,
                    (int)ramp.upperLandingObstruction,
                    (int)ramp.lowerLandingObstruction,
                    (int)ramp.rampObstruction,
                    (int)ramp.hasRampCracks,
                    (int)ramp.hasUpperLandingCracks,
                    (int)ramp.hasStreetLandingCracks,
                    ramp.rampWidth,
                    ramp.rampDepth,
                    ramp.rampSlopeFront,
                    ramp.rampSlopeSide,
                    ramp.rampSlopeHeading,
                    ramp.upperLandingSlopeFront,
                    ramp.upperLandingSlopeSide,
                    ramp.upperLandingSlopeHeading,
                    ramp.streetLandingSlopeFront,
                    ramp.streetLandingSlopeSide,
                    ramp.streetLandingSlopeHeading,
                    ramp.flareLeftSlopeFront,
                    ramp.flareLeftSlopeSide,
                    ramp.flareLeftSlopeHeading,
                    ramp.flareRightSlopeFront,
                    ramp.flareRightSlopeSide,
                    ramp.flareRightSlopeHeading,
                    (int)ramp.hasPEDSignal,
                    (int)ramp.hasPEDButton,
                    ramp.PEDButtonHeight,
                    ramp.PEDButtonDist,
                    ramp.SteepTopOfCurb,
                    ramp.lev21x,
                    ramp.lev21y,
                    ramp.PedRampLip];*/
        }
    }
    PixelXYToLatLong(mpint.lev21x, mpint.lev21y, 21, &lat, &lon);
   
    cmd = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%i,\
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
                       signal67=%i,\
                       latitude=%f,\
                       longitude=%f \
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
                       lat,lon,
                       mpint.intID];
    
    rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String sendToServer:YES useUniqueFile:NO];
    cmd = [NSString stringWithFormat:@"UPDATE Intersections_index SET minY=%f,minX=%f,maxY=%f,maxX=%f WHERE Intersections_index.id=%ld",
             lat,lon,lat,lon, (long)mpint.intID];
    rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String sendToServer:YES useUniqueFile:NO];

    [self.curbRampData close:opened];

    return !rtn;
}

- (MPIntersection *)getMPIntersectionFromDB:(int)intID
                                  withRamps:(BOOL)wantRamps
{
    MPIntersection *mpint = [[MPIntersection alloc] init];
    double lat = 0.0;
    double lon = 0.0;
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        [CRAPI.sharedInstance intersectionInit:mpint];
        mpint.intID = intID;
        mpint.lev21x = sqlite3_column_int(statement, 4);
        mpint.lev21y = sqlite3_column_int(statement, 5);
        mpint.intRotation = sqlite3_column_int(statement, 6);
        PixelXYToLatLong(mpint.lev21x, mpint.lev21y, 21, &lat, &lon);
        mpint.lat = lat;
        mpint.lon = lon;
        //int nStreets = sqlite3_column_int(statement, 27);
        LPSTR streets = (LPSTR)sqlite3_column_text(statement, 28);
        NSString *streetString = [NSString stringWithUTF8String:streets];
        mpint.name1 = [streetString stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
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
        [mpint setRampsXWalkAndSignal];
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return mpint;
}

- (NSMutableArray *)getIntersectionPointsFromDatabase
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    [self open];
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        double lat = 0.0;
        double lon = 0.0;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.latitude = lat;
        intpt.longitude = lon;
        [dataArray addObject:intpt];
    }
        
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return dataArray;
}

- (NSMutableArray *)getIntersectionPointsFromDatabaseinBounds:(IBOUNDS)bounds
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [self open];

    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, assignedTo, status, intX, intY,\
                       ramp1,ramp2,ramp3,ramp4,ramp5,ramp6,ramp7,ramp8,ramp81,ramp23,ramp45,ramp67 \
                       FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn, (int)bounds.xmx, (int)bounds.ymn, (int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedTo = sqlite3_column_int(statement, 1);
        int status = sqlite3_column_int(statement, 2);
        int intX = sqlite3_column_int(statement, 3);
        int intY = sqlite3_column_int(statement, 4);
        int nRamps = 0;
        
        for (int i = 5; i < 17; i++)
        {
            if (sqlite3_column_int(statement, i) != 0)
                nRamps++;
        }
        
        double lat = 0.0;
        double lon = 0.0;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.assignedTo = assignedTo;
        intpt.status = status;
        intpt.nramps = nRamps;
        
        if (status)
            status++;
        
        intpt.intID = intID;
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return dataArray;
}

- (NSMutableArray *)getIntersectionElementsFromDatabaseinBounds:(IBOUNDS)bounds
                                                      skipIntID:(int)skipID
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    [self open];
    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, status, intX, intY,\
                       ramp1,ramp2,ramp3,ramp4,ramp5,ramp6,ramp7,ramp8,ramp81,ramp23,ramp45,ramp67,\
                       xWalkA,xWalkB,xWalkC,xWalkD,\
                       signal81,signal23,signal45,signal67 \
                       FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn, (int)bounds.xmx, (int)bounds.ymn, (int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int intX = sqlite3_column_int(statement, 2);
        int intY = sqlite3_column_int(statement, 3);
        IntersectionElement *intEl = [[IntersectionElement alloc] init];
        intEl.type = IntElementTypeIntersection;
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
                    intEl.type = IntElementTypeRamp;
                    intEl.lev21x = (intX + offsetx);
                    intEl.lev21y = (intY + offsety);
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
                    intEl.type = IntElementTypeXWalk;
                    intEl.lev21x = (intX + offsetx);
                    intEl.lev21y = (intY + offsety);
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
                    intEl.type = IntElementTypeSignal;
                    intEl.lev21x = (intX + offsetx);
                    intEl.lev21y = (intY + offsety);
                    [dataArray addObject:intEl];
                }
            }
        }
    }
    
    SQLOK(sqlite3_finalize(statement),self.curbRampData.database);
    return dataArray;
}

- (NSMutableArray *)getIntersectionPointsWithinDistance:(int)meters
                                                ofPoint:(LLPOINT)latlon
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    IPOINT pt;
    pt.x = 0, pt.y = 0;
    int dist = (meters / GroundResolution(latlon.lat, 21));
    LatLongToPixelXY(latlon.lat, latlon.lon, 21, &pt.x, &pt.y);
    IBOUNDS bounds = IBoundsFromPointAndDist(pt, dist);
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, assignedTo, intX, intY FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn,(int)bounds.xmx,(int)bounds.ymn,(int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedTo = sqlite3_column_int(statement, 1);
        int intX = sqlite3_column_int(statement, 2);
        int intY = sqlite3_column_int(statement, 3);
        double lat = 0.0;
        double lon = 0.0;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.intID = intID;
        intpt.assignedTo = assignedTo;
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.dist = LDIST(intX, intY, pt.x, pt.y);
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    [self sortIntersectionsByDistance:dataArray];
    return dataArray;
}

- (void)sortIntersectionsByDistance:(NSMutableArray *)intersections
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

- (int) findIntersectionFromID:(int)intID
             intersectionText:(char *)intText
             intersectionAZMs:(char *)intAZMs
                   numStreets:(int *)pNumStreets
                     numRamps:(int *)pNumRamps
                         intX:(int *)plev21x
                         intY:(int *)plev21y

{
    int rtn = 0;
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY, nStreets, streetNames, streetAZMs, rotation FROM Intersections WHERE intID = %i",intID];
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        int nStreets = sqlite3_column_int(statement,2);
        LPSTR pStreets = (LPSTR)sqlite3_column_text(statement, 3);
        LPSTR pAZMS = (LPSTR)sqlite3_column_text(statement, 4);
        LPSTR pRot = (LPSTR)sqlite3_column_text(statement, 5);
        *plev21x = intX;
        *plev21y = intY;
        *pNumStreets = nStreets;
        strcpy(intText, pStreets);
        if (pAZMS)
            strcpy(intAZMs, pAZMS);
        else
            ComputeAZMsFromRotation (pRot,intAZMs);
        rtn = intID;
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return rtn;
}

void ComputeAZMsFromRotation (LPSTR pRot,LPSTR intAZMs)
{
    double deg = pRot ? atof (pRot):0.0;
    double az = LTWOPI(deg * DEGtoRAD * HALFPI);
    double azms[4];
    for (int i=0;i<4;i++)
    {
        azms[i] = LTWOPI(az + HALFPI * i);
    }
    sprintf (intAZMs,"%.4f|%.4f|%.4f|%.4f",azms[0],azms[1],azms[2],azms[3]);
    return;
}

- (int)findIntersection:(int)lev21x
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
    latlon.lat = 0.0, latlon.lon = 0.0;
    PixelXYToLatLong(lev21x, lev21y, 21, &latlon.lat, &latlon.lon);
    
    NSMutableArray *nearInts = [self getIntersectionPointsWithinDistance:500
                                                                 ofPoint:latlon];
    
    if (nearInts.count >= iWant)
    {
        IntersectionPoint *intpt = nearInts[iWant - 1];
        
        [self open];
        
        NSString *query = [NSString stringWithFormat:@"SELECT intX, intY, nStreets, streetNames, streetAZMs, rotation FROM Intersections WHERE intID = %i",
                           intpt.intID];
        
        sqlite3_stmt *statement = NULL;
        SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            int intX = sqlite3_column_int(statement, 0);
            int intY = sqlite3_column_int(statement, 1);
            int nStreets = sqlite3_column_int(statement,2);
            LPSTR pStreets = (LPSTR)sqlite3_column_text(statement, 3);
            LPSTR pAZMS = (LPSTR)sqlite3_column_text(statement, 4);
            LPSTR pRot = (LPSTR)sqlite3_column_text(statement, 5);
            *plev21x = intX;
            *plev21y = intY;
            *pNumStreets = nStreets;
            strcpy(intText, pStreets);
            if (pAZMS)
                strcpy(intAZMs, pAZMS);
            else
                ComputeAZMsFromRotation (pRot,intAZMs);
        }
        
        SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
        return intpt.intID;
    }
    
    return rtn;
}

- (BOOL)setCurrentIntersectionPoint:(IntersectionPoint *)intpt
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    int lev21x = 0;
    int lev21y = 0;
    LatLongToPixelXY(intpt.latitude, intpt.longitude, 21, &lev21x, &lev21y);
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, intX=%i, intY=%i WHERE intID=%i",
                       iTime, lev21x, lev21y, intpt.intID];
    
    char *error = NULL;
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    return !rtn;
}

- (IntersectionPoint *)getCurrentIntersectionPoint:(int)intID
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement = NULL;
    CGPoint intersectionPoint;
    IntersectionPoint *intpt;
    intpt.latitude = 0.0, intpt.longitude = 0.0;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        double lat = 0.0;
        double lon = 0.0;
        intpt = [[IntersectionPoint alloc] init];
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        intpt.latitude = intersectionPoint.y = lat;
        intpt.longitude = intersectionPoint.x = lon;
        intpt.intID = intID;
    }
    
    SQLOK(sqlite3_finalize(statement),self.curbRampData.database);
    return intpt;
}

- (NSString *)getCurrentIntersectionAZMs:(int)intID
                                nStreets:(int *)pnStreets
{
    NSString *rtn = @"";
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT nStreets, streetAZMs FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nStreets = sqlite3_column_int(statement, 0);
        *pnStreets = nStreets;
        LPSTR pAZMs = (LPSTR)sqlite3_column_text(statement, 1);
        rtn = [NSString stringWithUTF8String:pAZMs];
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return rtn;
}

- (int)getCountOfIntersections
{
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return count;
}

- (BOOL)setIntersectionStatusTo:(int)status
                forIntersection:(int)intID
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%i WHERE intID=%i",
                       iTime, status, intID];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    return !rtn;
}

- (BOOL)assignIntersection:(int)intID
                        to:(int)user
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo=%i WHERE intID=%i",
                       iTime, user, intID];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    return !rtn;
}

- (BOOL)assignIntersectionsFrom:(int)intID
                             to:(int)endID
                         toUser:(int)user
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo=%i WHERE intID>=%i AND intID <=%i",
                       iTime, user, intID, endID];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    return !rtn;
}

- (BOOL)assignAllIntersectionTo:(int)user
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo=%i",
                       iTime, user];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    return !rtn;
}

- (BOOL)assignRemainingIntersectionsTo:(int)user
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    [self open];
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo=%i WHERE assignedTo=0",
                       iTime, user];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    return !rtn;
}

- (IntersectionPoint *)getFirstIntersectionPointAssignedTo:(int)user
                                                withStatus:(int)status
{
    IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
    
    [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT intID, intX, intY FROM Intersections WHERE status=%i AND assignedTo=%i ORDER BY intID ASC",
                       status, user];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int intX = sqlite3_column_int(statement, 1);
        int intY = sqlite3_column_int(statement, 2);
        double lat = 0.0;
        double lon = 0.0;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.intID = intID;
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    return intpt;
}

- (NSArray *)getAssignments
{
    NSMutableArray *assignments = [[NSMutableArray alloc] init];
    
    [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT intID, assignedTo FROM Intersections WHERE assignedTo != 0 ORDER BY assignedTo,intID ASC"];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedTo = sqlite3_column_int(statement, 1);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.intID = intID;
        intpt.assignedTo = assignedTo;
        [assignments addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement),self.curbRampData.database);
    return assignments;
}

- (NSString *)intersectionTextPath:(int)type
{
    NSString *path = @"";
    
    NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    //NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    if (type == IntTextTypeData)
        path = [NSString stringWithFormat:@"%@/%i/intersection_data.bin", documentsDirectory, _geoid];
    
    else
        path = [NSString stringWithFormat:@"%@/%i/intersection_index.bin", documentsDirectory, _geoid];
    
    return path;
}

- (int)loadIntersectionTextToDatabase:(NSString *)path
{
    BOOL rtn = INTDBStatusFailed;
    char dataFile[PATH_MAX], indexFile[PATH_MAX];
    //LPSTR pUB;
    FILE *fidData = NULL;
    FILE *fidIndex = NULL;
    char data[512], index[512];
    int maxData = 256;
    int maxIndex = 100;
    int nLoaded = 0;
    char buffer[] = "INSERT INTO Intersections VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);\
    INSERT INTO Intersections_index VALUES (?,?,?,?,?);";
    sqlite3_stmt *statement = NULL;
    INTERSECTION_STRUCT intStruct = {0};
    int *pInt = 0;
    int i = 0;
    double lat,lon;
    
    BOOL opened = [self open];

    strcpy(indexFile, path.UTF8String);
    strcpy(dataFile, indexFile);
    strcat(indexFile, "/intersection_index.bin");
    strcat(dataFile, "/intersection_data.bin");
    fidData = fopen(dataFile, "rb");
    fidIndex = fopen(indexFile, "rb");
    
    NSLog (@"loadIntersectionTextToDatabase fopen file: %s", indexFile);
    
    if (!fidData || !fidIndex)
        goto Exit;
    
    if (![self.curbRampData createIntersectionsTable:YES])
        goto Exit2;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, buffer, -1, &statement, NULL), self.curbRampData.database);
    SQLOK(sqlite3_exec(self.curbRampData.database, "BEGIN TRANSACTION", NULL, NULL, NULL),self.curbRampData.database);
    
    fgetstring(index, maxIndex, fidIndex);
    
    while (fgetstring(data, maxData, fidData))
    {
        LPSTR pTab = strchr(data,'\t');
        LPSTR pTabIndex, pAzms, pEnd;
        pTabIndex = pAzms = pEnd = NULL;
        fgetstring(index, maxIndex, fidIndex);
        pTabIndex = strchr(index,'\t');
        *pTab++ = 0;
        *pTabIndex = 0;
        pTabIndex = strchr(index,' ');
        *pTabIndex++ = 0;
        intStruct.intID = atoi(data);
        intStruct.lev21Y = atoi(index);
        intStruct.lev21X = atoi(pTabIndex);
        PixelXYToLatLong(intStruct.lev21X, intStruct.lev21Y, 21, &lat, &lon);
        intStruct.assignedTo = 0;
        intStruct.status = 0;
        intStruct.nStreets = atoi(pTab);
        pTab = strchr(pTab,'\t') + 1;
        pAzms = strchr(pTab,'\t');
        *pAzms++ = 0;
        pEnd = strchr(pAzms,'\t');
        *pEnd = 0;
        strncpy(intStruct.streetNames, pTab, sizeof(intStruct.streetNames) - 1);
        strncpy(intStruct.streetAzms, pAzms, sizeof(intStruct.streetAzms) - 1);
        
        for (i = 1, pInt = &intStruct.intID; i < 29; i++, pInt++)
            SQLOK(sqlite3_bind_int(statement, i, *pInt), self.curbRampData.database);
        
        SQLOK(sqlite3_bind_text(statement, 29, intStruct.streetNames, -1, SQLITE_STATIC), self.curbRampData.database);
        SQLOK(sqlite3_bind_text(statement, 30, intStruct.streetAzms, -1, SQLITE_STATIC),self.curbRampData.database);
        SQLOK(sqlite3_bind_double(statement, 31,lat), self.curbRampData.database);
        SQLOK(sqlite3_bind_double(statement, 32,lon), self.curbRampData.database);
        SQLOK(sqlite3_bind_int(statement, 33,intStruct.intID), self.curbRampData.database);
        SQLOK(sqlite3_bind_double(statement, 34,lon), self.curbRampData.database);
        SQLOK(sqlite3_bind_double(statement, 35,lat), self.curbRampData.database);
        SQLOK(sqlite3_bind_double(statement, 36,lon), self.curbRampData.database);
        SQLOK(sqlite3_bind_double(statement, 37,lat), self.curbRampData.database);

        if (sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Error inserting intersection. '%s'", sqlite3_errmsg(self.curbRampData.database));
        
        nLoaded++;
        SQLOK(sqlite3_reset(statement), self.curbRampData.database);
    }
    
    SQLOK(sqlite3_exec(self.curbRampData.database, "COMMIT TRANSACTION", NULL, NULL, NULL), self.curbRampData.database);
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    rtn = INTDBStatusOK;
    
Exit2:
    fclose(fidIndex);
    fclose(fidData);

Exit:
    [self close:opened];
    return rtn;
}

- (void)FTPdidComplete:(int)option
            withStatus:(int)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    if (status == FTPStatusOK || status == FTPStatusFileExists)
    {
        NSString *toDirectory = [CRAPI.sharedInstance directoryFromPath:path
                                                                andName:[NSString stringWithFormat:@"/%i",self.geoid]
                                                                 create:YES];
        
        if (self.gettingUploaded)
            [self.curbRampData open];
        else
        {
            if (DecompressGMZipFile((LPSTR)path.UTF8String, (LPSTR)toDirectory.UTF8String))
                status = [self loadIntersectionTextToDatabase:toDirectory];
            
            else
            {
                [NSFileManager.defaultManager removeItemAtPath:path
                                                         error:nil];
                status = INTDBStatusFailedToUnzip;
            }
        }
        if (self.delegate)
        {
            [self.delegate intersectionsDatabase:[self.curbRampData databasePath:self.geoid]
                                         didLoad:@""
                                      withStatus:INTDBStatusOK];
        }
    }
    
    else if (status == FTPStatusConnectionFailed)
    {
        if (self.gettingUploaded)
        {
            [self.delegate intersectionsDatabase:nil
                                         didLoad:@"File not found"
                                      withStatus:INTDBStatusNoUploadedFile];
        }
        
        else
        {
            [self.delegate intersectionsDatabase:nil
                                         didLoad:@"File not found"
                                      withStatus:INTDBStatusNoNetworkConnection];
        }
    }
    
    else if (status == FTPStatusConnectionFailedTryingSecondary)
    {
        
    }
    
    else if (status != FTPStatusStop)
    {
        [self.delegate intersectionsDatabase:nil
                                     didLoad:@"FTP failure"
                                  withStatus:INTDBStatusFailed];
    }
}

- (void)getPlaceIntersectionFile:(GSSiPopoverView *)popover
                        forGeoid:(int)geoid
{
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%7.7i_Intersections.gcf", geoid];
    
    self.gettingUploaded = NO;
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
    _pull.useOnlyPrimaryFTP = NO;
    _pull.createDirectory = YES;
    
    [_pull getFile:fileName
    fromDirectory:@"Bill/PlaceIntersections"
           toFile:fileName
      toDirectory:documentsDirectory
     refreshOption:FTPDataPullRefreshOptionCheckFileSize];
}

- (void)getUploadedIntersectionFile:(GSSiPopoverView *)popover
                           forGeoid:(int)geoid
{
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%i.sqlite3", geoid];
    
    NSString *toDirectory = [CRAPI.sharedInstance directoryFromPath:documentsDirectory
                                                            andName:[NSString stringWithFormat:@"/%i",self.geoid]
                                                             create:YES];
    
    [self close:YES];
    
    self.gettingUploaded = YES;
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = self;
    pull.popover = popover;
    pull.useOnlyPrimaryFTP = YES;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/UploadedIntersections"
           toFile:@"CurbRamps.sqlite3"
      toDirectory:toDirectory
    refreshOption:FTPDataPullRefreshOptionCheckFileSize];
}

- (void)getInitialIntersectionFile:(NSTimer *)timer
{
    [self getPlaceIntersectionFile:_popover
                          forGeoid:self.geoid];
}

- (void)getPlaceIntersectionDatabase:(GSSiPopoverView *)popover
{
    NSString *dbPath = [self.curbRampData databasePath:self.geoid];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                                 error:nil].fileSize;
    
    BOOL forceReload = YES;
    
    if (fileSize > 0 && !forceReload)
    {
        if (self.delegate)
        {
            [self.delegate intersectionsDatabase:dbPath
                                         didLoad:@""
                                      withStatus:INTDBStatusOK];
        }
    }
    
    else
    {
        _popover = popover;
        
        [NSTimer scheduledTimerWithTimeInterval:1
                                         target:self
                                       selector:@selector(getInitialIntersectionFile:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)getUploadedIntersectionDatabase:(GSSiPopoverView *)popover
{
    NSString *dbPath = [self.curbRampData databasePath:self.geoid];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                                 error:nil].fileSize;
    BOOL forceReload = NO;
    
    if (fileSize > 0 && !forceReload)
    {
        if (self.delegate)
        {
            [self.delegate intersectionsDatabase:dbPath
                                         didLoad:@""
                                      withStatus:INTDBStatusOK];
        }
    }
    
    else
    {
        [self getUploadedIntersectionFile:popover
                                 forGeoid:self.geoid];
    }
    
}

- (BOOL)open
{
    BOOL rtn = [self.curbRampData open];
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        [self.curbRampData close:opened];
        NSLog(@"Intersections Database close");
    }
}

- (void)dealloc
{
    NSLog(@"Intersections Database dealloc");
}

- (void)startTransaction
{
    [self open];
    SQLOK(sqlite3_exec(self.curbRampData.database, "BEGIN", 0, 0, 0),self.curbRampData.database);
}
- (void)commitTransaction
{
    SQLOK(sqlite3_exec(self.curbRampData.database, "COMMIT", 0, 0, 0),self.curbRampData.database);
}

- (void)logError:(int)sqlReturn
          method:(char *)method
{
    NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i in %s = %i:%s",
                  sqlReturn, method, sqlite3_errcode(self.curbRampData.database), sqlite3_errmsg(self.curbRampData.database)]);
}

@end