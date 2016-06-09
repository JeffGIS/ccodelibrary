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

- (id) init
{
    self = [super init];
    return self;
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
        self.geoid = geoid % 100000000;
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

- (void) setGeoid:(int)geoid
{
    _geoid = geoid % 100000000;
}
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
    int icol = (8 + (r - 1));
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
- (BOOL)storeIntersection:(MPIntersection*)currentIntersection
               withStatus:(IntersectionStatus)status
{
    BOOL rtn = FALSE;
    
    for (int i = 1; i < 13; i++)
    {
        MPRamp *ramp = [currentIntersection.ramps objectAtIndex:i];
        
        switch (i)
        {
            case 1:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkAExists : YES;
                ramp.signalisComplete = !currentIntersection.signal23Exists;
                break;
                
            case 2:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkAExists : YES;
                ramp.signalisComplete = !currentIntersection.signal81Exists;
                break;
                
            case 3:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkBExists : YES;
                ramp.signalisComplete = !currentIntersection.signal45Exists;
                break;
                
            case 4:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkBExists : YES;
                ramp.signalisComplete = !currentIntersection.signal23Exists;
                break;
                
            case 5:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkCExists : YES;
                ramp.signalisComplete = !currentIntersection.signal67Exists;
                break;
                
            case 6:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkCExists : YES;
                ramp.signalisComplete = !currentIntersection.signal45Exists;
                break;
                
            case 7:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkDExists : YES;
                ramp.signalisComplete = !currentIntersection.signal81Exists;
                break;
                
            case 8:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkDExists : YES;
                ramp.signalisComplete = !currentIntersection.signal67Exists;
                break;
                
            default:
                ramp.xWalkisComplete = YES;
                ramp.signalisComplete = YES;
                break;
        }
    }
    
    
    rtn = [self storeMPIntersectionToDB:currentIntersection
                                 withStatus:status];
    
    return rtn;
}
- (int) incrementLastDataFileNum
{
    BOOL opened = [self.curbRampData open];
    int rtn = [self.curbRampData incrementLastDataFileNum];
    [self.curbRampData close:opened];
    return rtn;
}

- (BOOL)storeMPIntersectionToDB:(MPIntersection*)mpint
                     withStatus:(IntersectionStatus)status
{
    BOOL rtn = NO;
    double lat,lon;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    BOOL opened = [self.curbRampData open];
    BOOL newFile = YES;
    for (int i = 1; i < 13; i++)
    {
        MPRamp *ramp = [mpint.ramps objectAtIndex:i];
        char rampID[32];
        
        mpint.currentRamp = ramp;
        
        if (mpint.currentRamp.rampExists || ramp.hasPEDButton || ramp.hasPEDSignal)
        {
            strcpy(rampID, mpint.currentRamp.rampID.UTF8String);
            NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Ramps VALUES(\
%i,%i,'%s',0,%i,%i,%i,%f,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,\
%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\
%i,%i,%i,%i,%i,%i,%i,%i,%i,'%@');",
                    (int)mpint.intID,
                    (int)ramp.rampNum,
                    rampID,
                    (int)ramp.timeComplete,
                    (int)ramp.rampExists,
                    (int)ramp.isComplete,
                    ramp.approximateHeading,
                    (int)ramp.adjustedRot,
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
                    (int)ramp.rampWidth,
                    (int)ramp.rampDepth,
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
                    ramp.swkLeftSlopeFront,
                    ramp.swkLeftSlopeSide,
                    ramp.swkLeftSlopeHeading,
                    ramp.swkRightSlopeFront,
                    ramp.swkRightSlopeSide,
                    ramp.swkRightSlopeHeading,
                    (int)ramp.hasPEDSignal,
                    (int)ramp.hasPEDButton,
                    (int)ramp.PEDButtonHeight,
                    (int)ramp.PEDButtonDist,
                    (int)ramp.SteepTopOfCurb,
                    (int)ramp.PedRampLip,
                    (int)ramp.lev21x,
                    (int)ramp.lev21y,
                    (int)ramp.rampType,
                    ramp.rampComment];
            rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String sendToServer:YES];
        }
    }

    PixelXYToLatLong(mpint.lev21x, mpint.lev21y, 21, &lat, &lon);
   
    NSString *cmd = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%li,\
doLater=%i,\
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
longitude=%f,\
zoomLevel=%i,\
intersectionComment='%s' \
WHERE intID=%i;",
                     iTime, (long)status,
                       mpint.doLater,
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
                       mpint.zoomLevel,
                       mpint.intersectionComment.UTF8String,
                       mpint.intID];
    
    rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String sendToServer:YES];
    cmd = [NSString stringWithFormat:@"UPDATE Intersections_index SET minY=%f,minX=%f,maxY=%f,maxX=%f WHERE Intersections_index.id=%ld",
             lat,lon,lat,lon, (long)mpint.intID];
    rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String sendToServer:YES];

    [self.curbRampData close:opened];

    return !rtn;
}

- (MPIntersection *)getMPIntersectionFromDB:(int)intID
                                  withRamps:(BOOL)wantRamps
{
    MPIntersection *mpint = [[MPIntersection alloc] init];
    [mpint intersectionInit];
    double lat = 0.0;
    double lon = 0.0;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        mpint.intID = intID;
        mpint.lev21x = sqlite3_column_int(statement, 5);
        mpint.lev21y = sqlite3_column_int(statement, 6);
        mpint.intRotation = sqlite3_column_int(statement, 7);
        PixelXYToLatLong(mpint.lev21x, mpint.lev21y, 21, &lat, &lon);
        mpint.lat = lat;
        mpint.lon = lon;
        //int nStreets = sqlite3_column_int(statement, 27);
        LPSTR streets = (LPSTR)sqlite3_column_text(statement, 29);
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
    [self close:opened];

    return mpint;
}

- (NSMutableArray *)getIntersectionPointsFromDatabase
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    BOOL opened = [self open];
    
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
    [self close:opened];
    return dataArray;
}

- (NSMutableArray *)getIntersectionPointsFromDatabaseinBounds:(IBOUNDS)bounds
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    BOOL opened = [self open];

    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, assignedToPrelim, assignedToDetail, status, intX, intY,\
                       ramp1,ramp2,ramp3,ramp4,ramp5,ramp6,ramp7,ramp8,ramp81,ramp23,ramp45,ramp67 \
                       FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn, (int)bounds.xmx, (int)bounds.ymn, (int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedToPrelim = sqlite3_column_int(statement, 1);
        int assignedToDetail = sqlite3_column_int(statement, 2);
        int status = sqlite3_column_int(statement, 3);
        int intX = sqlite3_column_int(statement, 4);
        int intY = sqlite3_column_int(statement, 5);
        int nRamps = 0;
        
        for (int i = 6; i < 18; i++)
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
        if (assignedToPrelim)
            intpt.assignedToPrelim = assignedToPrelim;
        if (assignedToDetail)
            intpt.assignedToDetail = assignedToDetail;
        intpt.status = status;
        intpt.nramps = nRamps;
        
        if (status)
            status++;
        
        intpt.intID = intID;
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    [self close:opened];
    return dataArray;
}

- (NSMutableArray *)getIntersectionElementsFromDatabaseinBounds:(IBOUNDS)bounds
                                                      skipIntID:(int)skipID
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    BOOL opened = [self open];
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
    [self close:opened];
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
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT intID, assignedToPrelim, assignedToDetail, intX, intY FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn,(int)bounds.xmx,(int)bounds.ymn,(int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedToPrelim = sqlite3_column_int(statement, 1);
        int assignedToDetail = sqlite3_column_int(statement, 2);
        int intX = sqlite3_column_int(statement, 3);
        int intY = sqlite3_column_int(statement, 4);
        double lat = 0.0;
        double lon = 0.0;
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.intID = intID;
        intpt.assignedToPrelim = assignedToPrelim;
        intpt.assignedToDetail = assignedToDetail;
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.dist = LDIST(intX, intY, pt.x, pt.y);
        [dataArray addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    [self sortIntersectionsByDistance:dataArray];
    [self close:opened];
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
    BOOL opened = [self open];
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
    [self close:opened];
    return rtn;
}

void ComputeAZMsFromRotation (LPSTR pRot,LPSTR intAZMs)
{
    double deg = pRot ? atof (pRot):0.0;
    double az = LTWOPI(deg * DEGtoRAD * HALFPI);    double azms[4];
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
        
        BOOL opened = [self open];
        
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
        [self close:opened];
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
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, intX=%i, intY=%i WHERE intID=%i",
                       iTime, lev21x, lev21y, intpt.intID];
    
    char *error = NULL;
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, &error);
    sqlite3_free(error);
    [self close:opened];

    return !rtn;
}

- (IntersectionPoint *)getCurrentIntersectionPoint:(int)intID
{
    BOOL opened = [self open];
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
    [self close:opened];

    return intpt;
}

- (NSString *)getCurrentIntersectionAZMs:(int)intID
                                nStreets:(int *)pnStreets
{
    NSString *rtn = @"";
    BOOL opened = [self open];
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
    [self close:opened];

    return rtn;
}

- (int)getCountOfIntersections
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    
    [self close:opened];
    return count;
}

- (int)getCountOfRamps
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Ramps"];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    
    [self close:opened];
    return count;
}

- (BOOL)setIntersectionStatusTo:(IntersectionStatus)status
                forIntersection:(int)intID
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%i WHERE intID=%i",
                       iTime, (int)status, intID];
    
    rtn = SQLOK(sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL), self.curbRampData.database);
    [self close:opened];
    return !rtn;
}

- (BOOL)assignIntersection:(int)intID
                        to:(int)user
                      type:(NSString *)type
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo%@=%i WHERE intID=%i",
                       iTime, type, user, intID];
    
    rtn = SQLOK(sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL), self.curbRampData.database);
    [self close:opened];
    return !rtn;
}

- (BOOL)assignIntersectionsFrom:(int)intID
                             to:(int)endID
                         toUser:(int)user
                           type:(NSString *)type
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo%@=%i WHERE intID>=%i AND intID <=%i",
                       iTime, type, user, intID, endID];
    
    rtn = SQLOK(sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL), self.curbRampData.database);

    [self close:opened];
    return !rtn;
}

- (BOOL)assignAllIntersectionTo:(int)user
                           type:(NSString *)type

{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo%@=%i",
                       iTime, type, user];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    [self close:opened];
    return !rtn;
}

- (BOOL)assignRemainingIntersectionsTo:(int)user
                                  type:(NSString *)type

{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo%@=%i WHERE assignedTo=0",
                       iTime, type, user];
    
    rtn = sqlite3_exec(self.curbRampData.database, query.UTF8String, NULL, NULL, NULL);
    [self close:opened];
    return !rtn;
}

- (IntersectionPoint *)getFirstIntersectionPointAssignedTo:(int)user
                                                      type:(NSString *)type
                                                withStatus:(IntersectionStatus)status
{
    IntersectionPoint *intpt = nil;
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT intID, intX, intY FROM Intersections WHERE status=%li AND assignedTo%@=%i ORDER BY intID ASC",
                       (long)status, type, user];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        intpt = [[IntersectionPoint alloc] init];
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
    [self close:opened];
    return intpt;
}

- (NSArray *)getAssignments:(NSString*)type
{
    NSMutableArray *assignments = [[NSMutableArray alloc] init];
    
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT intID, assignedToPrelim, assignedToDetail FROM Intersections WHERE assignedTo%@ != 0 ORDER BY assignedTo%@,intID ASC",type,type];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedToPrelim = sqlite3_column_int(statement, 1);
        int assignedToDetail = sqlite3_column_int(statement, 2);
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        intpt.intID = intID;
        intpt.assignedToPrelim = assignedToPrelim;
        intpt.assignedToDetail = assignedToDetail;
        [assignments addObject:intpt];
    }
    
    SQLOK(sqlite3_finalize(statement),self.curbRampData.database);
    [self close:opened];
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

- (void) prepareInsert
{
    char buffer1[] = "INSERT INTO Intersections VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    char buffer2[] = "INSERT INTO Intersections_index VALUES (?,?,?,?,?);";
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, buffer1, -1, &_statement1, NULL), self.curbRampData.database);
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, buffer2, -1, &_statement2, NULL), self.curbRampData.database);

}
- (void) bindStatementsToStruct:(INTERSECTION_STRUCT*) intStruct
{
    int *pInt;
    int i;
    
    for (i = 1, pInt = &intStruct->intID; i < 30; i++, pInt++)
        SQLOK(sqlite3_bind_int(_statement1, i, *pInt), self.curbRampData.database);
    
    SQLOK(sqlite3_bind_text(_statement1, 30, intStruct->streetNames, -1, SQLITE_STATIC), self.curbRampData.database);
    SQLOK(sqlite3_bind_text(_statement1, 31, intStruct->streetAzms, -1, SQLITE_STATIC),self.curbRampData.database);
    SQLOK(sqlite3_bind_double(_statement1, 32,intStruct->lat), self.curbRampData.database);
    SQLOK(sqlite3_bind_double(_statement1, 33,intStruct->lon), self.curbRampData.database);
    SQLOK(sqlite3_bind_text(_statement1, 34, intStruct->comment, -1, SQLITE_STATIC), self.curbRampData.database);
    SQLOK(sqlite3_bind_int(_statement1, 35, intStruct->doLater), self.curbRampData.database);
    SQLOK(sqlite3_bind_int(_statement1, 36, intStruct->zoomLevel), self.curbRampData.database);
    
    SQLOK(sqlite3_bind_int(_statement2, 1, intStruct->intID), self.curbRampData.database);
    SQLOK(sqlite3_bind_double(_statement2, 2, intStruct->lon), self.curbRampData.database);
    SQLOK(sqlite3_bind_double(_statement2, 3, intStruct->lon), self.curbRampData.database);
    SQLOK(sqlite3_bind_double(_statement2, 4, intStruct->lat), self.curbRampData.database);
    SQLOK(sqlite3_bind_double(_statement2, 5, intStruct->lat), self.curbRampData.database);

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
    INTERSECTION_STRUCT intStruct = {0};
    int i = 0;
    
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
    
    [self prepareInsert];
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
        PixelXYToLatLong(intStruct.lev21X, intStruct.lev21Y, 21, &intStruct.lat, &intStruct.lon);
        intStruct.assignedTo = 0;
        intStruct.statusPrelim = 0;
        intStruct.statusDetail = 0;
        intStruct.nStreets = atoi(pTab);
        pTab = strchr(pTab,'\t') + 1;
        pAzms = strchr(pTab,'\t');
        *pAzms++ = 0;
        pEnd = strchr(pAzms,'\t');
        *pEnd = 0;
        strncpy(intStruct.streetNames, pTab, sizeof(intStruct.streetNames) - 1);
        strncpy(intStruct.streetAzms, pAzms, sizeof(intStruct.streetAzms) - 1);
        
        [self bindStatementsToStruct:&intStruct];
        
        if (sqlite3_step(_statement1) != SQLITE_DONE)
            NSLog(@"Error inserting intersection. '%s'", sqlite3_errmsg(self.curbRampData.database));
        if (sqlite3_step(_statement2) != SQLITE_DONE)
            NSLog(@"Error inserting intersection index. '%s'", sqlite3_errmsg(self.curbRampData.database));
        
        nLoaded++;
        SQLOK(sqlite3_reset(_statement1), self.curbRampData.database);
        SQLOK(sqlite3_reset(_statement2), self.curbRampData.database);
    }
    
    SQLOK(sqlite3_exec(self.curbRampData.database, "COMMIT TRANSACTION", NULL, NULL, NULL), self.curbRampData.database);
    SQLOK(sqlite3_finalize(_statement1), self.curbRampData.database);
    SQLOK(sqlite3_finalize(_statement2), self.curbRampData.database);
    rtn = INTDBStatusOK;
    
Exit2:
    fclose(fidIndex);
    fclose(fidData);

Exit:
    [self close:opened];
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
                                                                andName:[NSString stringWithFormat:@"/%i",self.geoid]
                                                                 create:YES];
        
        if (self.gettingUploaded)
            [self.curbRampData open];
        else
        {
            if (DecompressGMZipFile((LPSTR)path.UTF8String, (LPSTR)toDirectory.UTF8String,0,0))
                status = [self loadIntersectionTextToDatabase:toDirectory];
            
            else
            {
                [NSFileManager.defaultManager removeItemAtPath:path
                                                         error:nil];
                status = (FTPStatus)INTDBStatusFailedToUnzip;
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
    geoid = geoid % 100000000;
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
    fromDirectory:@"NVCRIS/IntersectionFiles"
           toFile:fileName
      toDirectory:documentsDirectory
     refreshOption:FTPDataPullRefreshOptionCheckFileSize];
}

- (void)getUploadedIntersectionFile:(GSSiPopoverView *)popover
                           forGeoid:(int)geoid
{
    geoid = geoid % 100000000;
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
    NSString *dbPath = [_curbRampData databasePath:_geoid];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                                 error:nil].fileSize;
    
    BOOL forceReload = NO;
    int nIntersections = [self getCountOfIntersections];
    int nRamps = [self getCountOfRamps];
    
    if (fileSize > 0 && !forceReload && nIntersections > 0 && [_curbRampData isCurrentVersion])
    {
        if (_delegate)
        {
            [_delegate intersectionsDatabase:dbPath
                                     didLoad:@""
                                  withStatus:INTDBStatusOK];
        }
    }
    
    else
    {
        _popover = popover;
        
        [NSTimer scheduledTimerWithTimeInterval:0.1
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

- (BOOL)startTransaction
{
    BOOL opened = [self open];
    SQLOK(sqlite3_exec(self.curbRampData.database, "BEGIN", 0, 0, 0),self.curbRampData.database);
    return opened;
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

- (int) getNewIntID
{
    int nextID = 0;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT MAX(intID) FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        nextID = sqlite3_column_int(statement, 0);
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    [self close:opened];
    
    int inc = nextID % CRAPI.sharedInstance.totiPadWithinManager;
    int base = nextID - inc;
    int myNumber = CRAPI.sharedInstance.currentiPadWithinManager - 1;
    if (base + myNumber > nextID)
        nextID = base + myNumber;
    else
        nextID = base + CRAPI.sharedInstance.totiPadWithinManager + myNumber;
    return nextID;
}

- (int)addNewIntersectionAt:(LLPOINT)pt
                   withName:(NSString *)name
{
    INTERSECTION_STRUCT newInt={0};
    
    newInt.intID = [self getNewIntID];
    LatLongToPixelXY(pt.lat, pt.lon, 21, &newInt.lev21X, &newInt.lev21Y);
    newInt.assignedTo = CRAPI.sharedInstance.currentiPadWithinManager;
    newInt.nStreets = 1;
    strncpy(newInt.streetNames, name.UTF8String, sizeof(newInt.streetNames) - 1);
    
    BOOL opened = [self open];
    
    [self prepareInsert];
    SQLOK(sqlite3_exec(self.curbRampData.database, "BEGIN TRANSACTION", NULL, NULL, NULL),self.curbRampData.database);
    [self bindStatementsToStruct:&newInt];
    
    if (sqlite3_step(_statement1) != SQLITE_DONE)
        NSLog(@"Error inserting intersection. '%s'", sqlite3_errmsg(self.curbRampData.database));
    if (sqlite3_step(_statement2) != SQLITE_DONE)
        NSLog(@"Error inserting intersection index. '%s'", sqlite3_errmsg(self.curbRampData.database));
    

    SQLOK(sqlite3_exec(self.curbRampData.database, "COMMIT TRANSACTION", NULL, NULL, NULL), self.curbRampData.database);
    SQLOK(sqlite3_finalize(_statement1), self.curbRampData.database);
    SQLOK(sqlite3_finalize(_statement2), self.curbRampData.database);
    [self close:opened];

    return newInt.intID;
}

-(NSString*) getStreetNamesForIntersection:(int)intID
{
    NSString* names=@"";
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT nStreets, streetNames FROM Intersections WHERE intID = %i",intID];
    sqlite3_stmt *statement = NULL;
    SQLOK(sqlite3_prepare_v2(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nNames = sqlite3_column_int (statement, 0);
        LPSTR pnames = (LPSTR)sqlite3_column_text (statement, 1);
        names = [NSString stringWithUTF8String:pnames];
        names = [names stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
    }
    SQLOK(sqlite3_finalize(statement), self.curbRampData.database);
    [self close:opened];
    
   return names;

}

-(void) setStreetNamesForIntersection:(int)intID
                                   to:(NSString*)newNames
{
    return;
}

- (void) deleteIntersection:(int)intID
{
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM Intersections WHERE intID = %i;DELETE FROM Intersections_index WHERE intID = %i",intID,intID];
    [self.curbRampData executeCmd:(char *)cmd.UTF8String sendToServer:YES];
    
}
@end