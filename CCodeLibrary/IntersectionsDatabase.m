//  IntersectionsDatabase.m
//  CCodeLibrary

#import "IntersectionsDatabase.h"
#import "IntersectionRecord.h"
#import "CRAPI.h"
#import "TileGraphics.h"
#import "MathUtil.h"
#import "compress.h"
#import "RampCompliance.h"
#include "shr.h"

static int ii;

@interface IntersectionsDatabase ()

@property (nonatomic) GSSiPopoverView *popover;

@end

@implementation IntersectionsDatabase

- (id) init
{
    self = [super init];
    return self;
}

+ (IntersectionsDatabase *)databaseForGeoid:(int)geoid
{
    static int lastGeoid = 0;
    IntersectionsDatabase *db = [[IntersectionsDatabase alloc] initWithGeoid:geoid];
    
    if (geoid != lastGeoid)
        [db incrementLastDataFileNum]; //prevents files of mixed versions
    lastGeoid = geoid;
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
        //NSLog(@"Intersections Database close");
    }
}


/*- (BOOL)createIntersectionsTable_old
{
    char *error = NULL;
    BOOL rtn = NO;
    
    [self open];
    NSString *dropQuery = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Intersections;DROP TABLE IF EXISTS Intersections_index;"];
    
    SQLOKint(SQLiteExec(_database, dropQuery.UTF8String, NULL, NULL, NULL), "createIntersectionsTable1");
    
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
    
    rtn = SQLOKint(SQLiteExec(_database, query.UTF8String, NULL, NULL, &error), "createIntersectionsTable2");
    sqlite3_free(error);
    
    if (rtn != SQLITE_OK)
        return rtn;
    
    query =[NSString stringWithFormat:@"CREATE INDEX xindex ON Intersections (intX);"];
    rtn = SQLOKint(SQLiteExec(_database, query.UTF8String, NULL, NULL, &error), "createIntersectionsTable3");
    sqlite3_free(error);
    
    if (rtn != SQLITE_OK)
        return rtn;
    
    query =[NSString stringWithFormat:@"CREATE INDEX yindex ON Intersections (intY);"];
    rtn = SQLOKint(SQLiteExec(_database, query.UTF8String, NULL, NULL, &error), "createIntersectionsTable4");
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
    int icol = (20 + (xw - 'A'));
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
    int icol = 24;
    
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
- (BOOL)storeIntersection:(MPIntersection *)currentIntersection
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
    
    rtn = [self storeMPIntersectionToDB:currentIntersection];
    
    return rtn;
}

- (int) incrementLastDataFileNum
{
    BOOL opened = [self open];
    int rtn = [self.curbRampData incrementLastDataFileNum];
    [self close:opened];
    return rtn;
}

- (NSArray*) setCurrentRamps:(int)intID
{
    NSMutableArray * array = [NSMutableArray new];
    
    for (int i = 0;i<13; i++)
    {
        NSNumber * num = [[NSNumber alloc]initWithBool:NO];
        [array addObject:num];
    }
    
    BOOL opened = [self open];
    sqlite3_stmt *statement = NULL;
    
    NSString *cmd = [NSString stringWithFormat:@"SELECT rampNum FROM ramps WHERE intID = %i",intID];
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, cmd.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int rampNum = sqlite3_column_int(statement, 0);
        if (rampNum && rampNum < 13)
        {
            NSNumber * num = [[NSNumber alloc]initWithBool:YES];
            [array replaceObjectAtIndex:rampNum withObject:num];
        }
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),self.curbRampData.database);
    [self close:opened];
    return array;
}

- (BOOL)storeMPIntersectionToDB:(MPIntersection *)mpint
{
    BOOL rtn = NO;
    double lat = 0.0, lon = 0.0;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    NSArray * currentRamps = [self setCurrentRamps:mpint.intID];
    BOOL opened = [self open];
    //BOOL newFile = YES;
    
    
    for (int i = 1; i < 13; i++)
    {
        MPRamp *ramp = [mpint.ramps objectAtIndex:i];
        NSNumber * boolVal = currentRamps[i];
        BOOL haveCurrentRamp = boolVal.boolValue;
        char rampID[32];
        
        if (ramp.rampExists || ramp.PEDButtonType != NVButtonTypeNone || ramp.PEDSignalType != NVSignalTypeNone)
        {
            strcpy(rampID, ramp.rampID.UTF8String);
            
            if (ramp.isComplete == 1 && CRAPI.sharedInstance.isRentaliPad)
                ramp.isComplete = 2;
            NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Ramps VALUES(\
%i,%i,'%s',%i,%i,%i,%i,%f,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,\
%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\
%i,%i,%i,%i,%f,%f,%i,%i,%i,'%@',\
%i,%i,%i,%i,%i,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f);",
                             (int)mpint.intID,
                             (int)ramp.rampNum,
                             rampID,
                             (int)ramp.yearRebuilt,
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
                             (int)ramp.PEDSignalType,
                             (int)ramp.PEDButtonType,
                             (int)ramp.PEDButtonHeight,
                             (int)ramp.PEDButtonDist,
                             (float)ramp.SteepTopOfCurb,
                             (float)ramp.PedRampLip,
                             (int)ramp.lev21x,
                             (int)ramp.lev21y,
                             (int)ramp.rampType,
                             ramp.rampComment,
                             ramp.awi,
                             ramp.hasLocatorTone,
                             ramp.hasInfoSign,
                             ramp.hasBraille,
                             ramp.hasTactileArrow,
                             ramp.locatorToneVolume,
                             ramp.audibleWalkIndicationVolume,
                             ramp.crackWidth.rampCrackWidth,
                             ramp.crackWidth.upperLandingCrackWidth,
                             ramp.crackWidth.streetLandingCrackWidth,
                             ramp.crackWidth.leftSidewalkCrackWidth,
                             ramp.crackWidth.rightSidewalkCrackWidth,
                             ramp.curbCutDistance,
                             ramp.bumpWidth,
                             ramp.bumpHeight
                    ];
            
            rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String
                                   sendToServer:YES
                                       fromFile:__FILE__ fromLine:__LINE__];
        }
        else if (haveCurrentRamp)
        {
            NSString * cmd = [NSString stringWithFormat:@"Delete FROM ramps WHERE intID=%i AND rampNum = %i",(int)mpint.intID,i];
            rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String
                                   sendToServer:YES
                                       fromFile:__FILE__ fromLine:__LINE__];
            
        }
    }

    PixelXYToLatLong(mpint.lev21x, mpint.lev21y, 21, &lat, &lon);
   
    NSString *cmd = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, status=%li,\
                     assignedToPrelim=%i,\
                     assignedToDetail=%i,\
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
                     doLater=%i,\
                     intersectionComment='%s' \
                     WHERE intID=%i;",
                     iTime, (long)mpint.status,
                       mpint.assignedPrelim,
                       mpint.assignedDetail,
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
                       mpint.doLater,
                       mpint.intersectionComment.UTF8String,
                       mpint.intID];
    
    rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
    
    cmd = [NSString stringWithFormat:@"UPDATE Intersections_index SET minY=%f,minX=%f,maxY=%f,maxX=%f WHERE Intersections_index.id=%ld",
           lat, lon, lat, lon, (long)mpint.intID];
    
    rtn = [self.curbRampData executeCmd:(char *)cmd.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];

    [self close:opened];

    return rtn;
}

- (int) fixRampNum:(int)rampNum
{
    if (rampNum == 23)
        return 9;
    if (rampNum == 45)
        return 10;
    if (rampNum == 67)
        return 11;
    if (rampNum == 81)
        return 12;
    return rampNum;
}
-(BOOL) saveComplianceCode:(LPSTR)ccode forInt:(int)intID ramp:(int)rampID
{
    BOOL rtn;
    static BOOL first = TRUE;
    BOOL opened = [self open];
    NSString * cmd = [NSString stringWithFormat:@"DROP TABLE IF EXISTS Compliance;CREATE TABLE IF NOT EXISTS Compliance (intID INT,rampNum INT,code CHAR(8), PRIMARY KEY (intID,rampNum ASC));"];
    if (first)
    rtn = [self.curbRampData executeCmd:cmd.UTF8String
                           sendToServer:NO
                               fromFile:__FILE__ fromLine:__LINE__];
    first = FALSE;
    cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Compliance VALUES(%i,%i,'%s');",intID,rampID,ccode];
    rtn = [self.curbRampData executeCmd:cmd.UTF8String
                           sendToServer:NO
                               fromFile:__FILE__ fromLine:__LINE__];
    [self close:opened];
    return rtn;
    
}

- (int)numProblemRamps:(int)intID
            tolerances:(ToleranceValues *)tolerances
{
    int numProblems = 0;
    MPIntersection * mpint = [self getMPIntersectionFromDB:intID withRamps:YES];
    
    for (MPRamp *ramp in mpint.ramps)
    {
        RampStruct rstruct;
        
        if (ramp.rampExists)
        {
            rampToRampStruct (ramp,&rstruct);
            LPSTR detailCode;
            
            LPSTR ccode = rampComplianceCode(&rstruct, &detailCode, tolerances);
           // [self saveComplianceCode:ccode forInt:intID ramp:ramp.rampNum];
            
            //show all non-compliant intersections
            if (strcmp (ccode,"A"))
                numProblems++;
            
            //show only intersections that are outside of the slope tolerance (major fails)
            /*if (strstr(ccode, "E"))
                numProblems++;*/
            
            //free (ccode);
            //free (detailCode);
        }
    }
    
    return numProblems;
}

void rampToRampStruct (MPRamp *ramp,RampStruct *rstruct)
{
    rstruct->rampNum = ramp.rampNum;
    strncpy (rstruct->rampID,ramp.rampID.UTF8String,15);
    rstruct->rampID[15] = 0;
    rstruct->timeComplete = ramp.timeComplete;
    rstruct->yearRebuilt = ramp.yearRebuilt;
    rstruct->rampExists = ramp.rampExists;
    rstruct->isComplete = ramp.isComplete;
    rstruct->approximateHeading = ramp.approximateHeading;
    rstruct->adjustedRot = ramp.adjustedRot;
    rstruct->rampInXWalk = ramp.rampInXWalk;
    rstruct->xWalkisComplete = ramp.xWalkisComplete;
    rstruct->signalisComplete = ramp.signalisComplete;
    rstruct->hasRampCracks = ramp.hasRampCracks;
    rstruct->hasUpperLandingCracks = ramp.hasUpperLandingCracks;
    rstruct->hasStreetLandingCracks = ramp.hasStreetLandingCracks;
    rstruct->hasLeftSidewalkCracks = ramp.hasLeftSidewalkCracks;
    rstruct->hasRightSidewalkCracks = ramp.hasRightSidewalkCracks;
    rstruct->rampWidth = ramp.rampWidth;
    rstruct->rampDepth = ramp.rampDepth;
    rstruct->texture = ramp.texture;
    rstruct->upperLandingObstruction = ramp.upperLandingObstruction;
    rstruct->lowerLandingObstruction = ramp.lowerLandingObstruction;
    rstruct->rampObstruction = ramp.rampObstruction;
    rstruct->rampSlopeSide = ramp.rampSlopeSide;
    rstruct->rampSlopeFront = ramp.rampSlopeFront;
    rstruct->rampSlopeHeading = ramp.rampSlopeHeading;
    rstruct->upperLandingSlopeSide = ramp.upperLandingSlopeSide;
    rstruct->upperLandingSlopeFront = ramp.upperLandingSlopeFront;
    rstruct->upperLandingSlopeHeading = ramp.upperLandingSlopeHeading;
    rstruct->streetLandingSlopeSide = ramp.streetLandingSlopeSide;
    rstruct->streetLandingSlopeFront = ramp.streetLandingSlopeFront;
    rstruct->streetLandingSlopeHeading = ramp.streetLandingSlopeHeading;
    rstruct->flareLeftSlopeSide = ramp.flareLeftSlopeSide;
    rstruct->flareLeftSlopeFront = ramp.flareLeftSlopeFront;
    rstruct->flareLeftSlopeHeading = ramp.flareLeftSlopeHeading;
    rstruct->flareRightSlopeSide = ramp.flareRightSlopeSide;
    rstruct->flareRightSlopeFront = ramp.flareRightSlopeFront;
    rstruct->flareRightSlopeHeading = ramp.flareRightSlopeHeading;
    rstruct->swkLeftSlopeSide = ramp.swkLeftSlopeSide;
    rstruct->swkLeftSlopeFront = ramp.swkLeftSlopeFront;
    rstruct->swkLeftSlopeHeading = ramp.swkLeftSlopeHeading;
    rstruct->swkRightSlopeSide = ramp.swkRightSlopeSide;
    rstruct->swkRightSlopeFront = ramp.swkRightSlopeFront;
    rstruct->swkRightSlopeHeading = ramp.swkRightSlopeHeading;
    rstruct->PEDButtonDist = ramp.PEDButtonDist;
    rstruct->PEDButtonHeight = ramp.PEDButtonHeight;
    rstruct->SteepTopOfCurb = ramp.SteepTopOfCurb;
    rstruct->PedRampLip = ramp.PedRampLip;
    rstruct->lev21x = ramp.lev21x;
    rstruct->lev21y = ramp.lev21y;
    rstruct->PEDSignalType = ramp.PEDSignalType;
    rstruct->PEDButtonType = ramp.PEDButtonType;
    rstruct->awi = ramp.awi;
    rstruct->hasLocatorTone = ramp.hasLocatorTone;
    rstruct->hasInfoSign = ramp.hasInfoSign;
    rstruct->hasBraille = ramp.hasBraille;
    rstruct->hasTactileArrow = ramp.hasTactileArrow;
    rstruct->locatorToneVolume = ramp.locatorToneVolume;
    rstruct->audibleWalkIndicationVolume = ramp.audibleWalkIndicationVolume;
    rstruct->crackWidth = ramp.crackWidth;
    rstruct->curbCutDistance = ramp.curbCutDistance;
    rstruct->bumpWidth = ramp.bumpWidth;
    rstruct->bumpHeight = ramp.bumpHeight;
    
}

- (MPIntersection *)getMPIntersectionFromDB:(int)intID
                                  withRamps:(BOOL)wantRamps
{
    MPIntersection *mpint = [[MPIntersection alloc] init];
    [mpint intersectionInit];
    double lat = 0.0;
    double lon = 0.0;
    BOOL opened = [self open];
    BOOL haveIntersection = FALSE;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        haveIntersection = TRUE;
        mpint.intID = intID;
        int recID = sqlite3_column_int(statement, 0);
        mpint.lastUpdate = sqlite3_column_int(statement, 1);
        mpint.status = sqlite3_column_int(statement, 2);
        mpint.assignedPrelim = sqlite3_column_int(statement, 3);
        mpint.assignedDetail = sqlite3_column_int(statement, 4);
        mpint.lev21x = sqlite3_column_int(statement, 5);
        mpint.lev21y = sqlite3_column_int(statement, 6);
        mpint.intRotation = sqlite3_column_int(statement, 7);
        PixelXYToLatLong(mpint.lev21x, mpint.lev21y, 21, &lat, &lon);
        mpint.lat = lat;
        mpint.lon = lon;
        //int nStreets = sqlite3_column_int(statement, 27);
        LPSTR streets = (LPSTR)sqlite3_column_text(statement, 29);
        NSString *streetString = @"";
        if (streets)
            streetString = [NSString stringWithUTF8String:streets];
        mpint.name1 = [streetString stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
        LPSTR comment = (LPSTR)sqlite3_column_text(statement, 33);
        if (comment)
            mpint.intersectionComment = [NSString stringWithUTF8String:comment];
        else
            mpint.intersectionComment = @"";
        mpint.doLater = sqlite3_column_int(statement, 34);
        mpint.zoomLevel = sqlite3_column_int(statement, 35);
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    if (wantRamps && haveIntersection)
    {
        query = [NSString stringWithFormat:@"SELECT * FROM Ramps WHERE intID=%i", intID];
        SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int i = 1;
            int rampNum = sqlite3_column_int(statement, i++);
            rampNum = [self fixRampNum:rampNum];
            MPRamp *ramp = [mpint.ramps objectAtIndex:rampNum];

            LPSTR rampID = (LPSTR)sqlite3_column_text(statement, i++);
            ramp.yearRebuilt = sqlite3_column_int(statement, i++);
            ramp.timeComplete  = sqlite3_column_int(statement, i++);
            ramp.rampExists  = sqlite3_column_int(statement, i++);
            ramp.isComplete  = sqlite3_column_int(statement, i++);
            ramp.approximateHeading = sqlite3_column_double(statement, i++);
            ramp.adjustedRot  = sqlite3_column_int(statement,i++);
            ramp.rampInXWalk  = sqlite3_column_int(statement, i++);
            ramp.xWalkisComplete  = sqlite3_column_int(statement,i++);
            ramp.signalisComplete  = sqlite3_column_int(statement, i++);
            ramp.texture  = sqlite3_column_int(statement, i++);
            ramp.upperLandingObstruction  = sqlite3_column_int(statement, i++);
            ramp.lowerLandingObstruction  = sqlite3_column_int(statement, i++);
            ramp.rampObstruction  = sqlite3_column_int(statement, i++);
            ramp.hasRampCracks  = sqlite3_column_int(statement, i++);
            ramp.hasUpperLandingCracks  = sqlite3_column_int(statement,i++);
            ramp.hasStreetLandingCracks  = sqlite3_column_int(statement,i++);
            ramp.rampWidth  = sqlite3_column_int(statement,i++);
            ramp.rampDepth  = sqlite3_column_int(statement,i++);
            ramp.rampSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.rampSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.rampSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.upperLandingSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.upperLandingSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.upperLandingSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.streetLandingSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.streetLandingSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.streetLandingSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.flareLeftSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.flareLeftSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.flareLeftSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.flareRightSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.flareRightSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.flareRightSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.swkLeftSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.swkLeftSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.swkLeftSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.swkRightSlopeFront  = sqlite3_column_double(statement, i++);
            ramp.swkRightSlopeSide  = sqlite3_column_double(statement, i++);
            ramp.swkRightSlopeHeading  = sqlite3_column_double(statement, i++);
            ramp.PEDSignalType  = sqlite3_column_int(statement, i++);
            ramp.PEDButtonType  = sqlite3_column_int(statement, i++);
            ramp.PEDButtonHeight  = sqlite3_column_int(statement,i++);
            ramp.PEDButtonDist  = sqlite3_column_int(statement, i++);
            ramp.SteepTopOfCurb  = sqlite3_column_double(statement, i++);
            ramp.PedRampLip  = sqlite3_column_double(statement, i++);
            ramp.lev21x  = sqlite3_column_int(statement,i++);
            ramp.lev21y  = sqlite3_column_int(statement,i++);
            ramp.rampType  = sqlite3_column_int(statement,i++);
            LPSTR comment = (LPSTR)sqlite3_column_text(statement,i++);
            if (comment)
                ramp.rampComment = [NSString stringWithCString:comment encoding:NSUTF8StringEncoding];
            else
                ramp.rampComment = @"";
            ramp.awi = sqlite3_column_int(statement,i++);
            ramp.hasLocatorTone = sqlite3_column_int(statement,i++);
            ramp.hasInfoSign = sqlite3_column_int(statement,i++);
            ramp.hasBraille = sqlite3_column_int(statement,i++);
            ramp.hasTactileArrow = sqlite3_column_int(statement,i++);
            ramp.locatorToneVolume = sqlite3_column_int(statement,i++);
            ramp.audibleWalkIndicationVolume = sqlite3_column_int(statement,i++);
            CrackWidth cw;
            cw.rampCrackWidth = sqlite3_column_double(statement, i++);
            cw.upperLandingCrackWidth = sqlite3_column_double(statement, i++);
            cw.streetLandingCrackWidth = sqlite3_column_double(statement, i++);
            cw.leftSidewalkCrackWidth = sqlite3_column_double(statement, i++);
            cw.rightSidewalkCrackWidth = sqlite3_column_double(statement, i++);
            ramp.crackWidth = cw;
            ramp.curbCutDistance = sqlite3_column_double(statement, i++);
            ramp.bumpWidth = sqlite3_column_double(statement, i++);
            ramp.bumpHeight = sqlite3_column_double(statement, i++);
            if (ramp.bumpWidth > 0 || ramp.bumpHeight > 0)
                ii=1;
        }
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
   }
    [self close:opened];

    return mpint;
}

- (NSMutableArray *)getIntersectionPointsFromDatabase
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    BOOL opened = [self open];
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
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
        
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    [self close:opened];
    return dataArray;
}

- (int) getNumRampsForInt:(int)intID
                  numPaid:(int*) pnPaid
{
    int nRamps = 0;
    int numPaid = 0;
    NSString *query = [NSString stringWithFormat:
                       @"SELECT isComplete, rampType, rampNum FROM ramps WHERE intID = %i and rampExists != 0",intID];
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int isComplete = sqlite3_column_int(statement, 0);
        int rampType = sqlite3_column_int(statement, 1);
        int rampNum = sqlite3_column_int(statement, 2);
        if (rampType != RampTypeCombPerpWalk && rampType != RampTypeCombPerpNonWalk)
            nRamps++;
        if (isComplete == 2)
            numPaid++;
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    
    *pnPaid = numPaid;
    return nRamps;
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
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedToPrelim = sqlite3_column_int(statement, 1);
        int assignedToDetail = sqlite3_column_int(statement, 2);
        IntersectionStatus status = sqlite3_column_int(statement, 3);
        int intX = sqlite3_column_int(statement, 4);
        int intY = sqlite3_column_int(statement, 5);
        int nPaid;
        int nRamps = [self getNumRampsForInt:intID numPaid:&nPaid];
        
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
        intpt.nPaid = nPaid;
        
        if (status)
            status++;
        
        intpt.intID = intID;
        [dataArray addObject:intpt];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
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
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),self.curbRampData.database);
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
                       @"SELECT intID, assignedToPrelim, assignedToDetail, intX, intY, status FROM Intersections WHERE intX >= %i AND intX <= %i AND intY >= %i AND intY <= %i",
                       (int)bounds.xmn,(int)bounds.xmx,(int)bounds.ymn,(int)bounds.ymx];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int intID = sqlite3_column_int(statement, 0);
        int assignedToPrelim = sqlite3_column_int(statement, 1);
        int assignedToDetail = sqlite3_column_int(statement, 2);
        int intX = sqlite3_column_int(statement, 3);
        int intY = sqlite3_column_int(statement, 4);
        int status = sqlite3_column_int(statement, 5);
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
        intpt.status = status;
        int nPaid;
        intpt.nramps = [self getNumRampsForInt:intID numPaid:&nPaid];
        intpt.nPaid = nPaid;
        [dataArray addObject:intpt];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
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
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
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
        SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
        
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
        
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
        [self close:opened];
        return intpt.intID;
    }
    
    return rtn;
}

- (BOOL)setCurrentIntersectionPoint:(IntersectionPoint *)intpt
{
    NSLog(@"\nSET POINT\nIntID %i LAT:%f, LON:%f", intpt.intID, intpt.latitude, intpt.longitude);
    
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    int lev21x = 0;
    int lev21y = 0;
    LatLongToPixelXY(intpt.latitude, intpt.longitude, 21, &lev21x, &lev21y);
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, intX=%i, intY=%i, latitude=%f, longitude=%f WHERE intID=%i",
                       iTime, lev21x, lev21y, intpt.latitude, intpt.longitude, intpt.intID];
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
    
    query = [NSString stringWithFormat:@"UPDATE Intersections_index SET minY=%f,minX=%f,maxY=%f,maxX=%f WHERE Intersections_index.id=%ld",
             intpt.latitude, intpt.longitude, intpt.latitude, intpt.longitude, (long)intpt.intID];
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];

    return !rtn;
}

- (IntersectionPoint *)getCurrentIntersectionPoint:(int)intID
{
    BOOL opened = [self open];
    int nRamps = -1;
    NSString *query = [NSString stringWithFormat:@"SELECT intX, intY, status, assignedToPrelim, assignedToDetail FROM Intersections WHERE intID=%i", intID];
    sqlite3_stmt *statement = NULL;
    IntersectionPoint *intpt = nil;
    intpt.latitude = 0.0, intpt.longitude = 0.0;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        nRamps = 0;
        int intX = sqlite3_column_int(statement, 0);
        int intY = sqlite3_column_int(statement, 1);
        double lat = 0.0;
        double lon = 0.0;
        intpt = [[IntersectionPoint alloc] init];
        PixelXYToLatLong(intX, intY, 21, &lat, &lon);
        intpt.latitude = lat;
        intpt.longitude = lon;
        intpt.status = sqlite3_column_int(statement, 2);
        intpt.assignedToPrelim = sqlite3_column_int(statement, 3);
        intpt.assignedToDetail = sqlite3_column_int(statement, 4);
        intpt.intID = intID;
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),self.curbRampData.database);
    if (!nRamps)
    {
        query = [NSString stringWithFormat:@"SELECT * FROM ramps WHERE intID = %i", intID];
        SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            nRamps++;
        }
        intpt.nramps = nRamps;
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),self.curbRampData.database);
    }
    
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
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nStreets = sqlite3_column_int(statement, 0);
        *pnStreets = nStreets;
        LPSTR pAZMs = (LPSTR)sqlite3_column_text(statement, 1);
        rtn = [NSString stringWithUTF8String:pAZMs];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    [self close:opened];

    return rtn;
}

- (int) markRampsAtIntersectionPaid:(int) intID maxToPay:(int) maxPay
{
    int nPaid = 0;
    BOOL opened = [self open];
    NSMutableString * updateQuery = [NSMutableString stringWithFormat:@"UPDATE ramps SET isComplete = 2 WHERE intID = %i AND rampNum IN (",intID];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT isComplete, rampType, rampNum FROM ramps WHERE intID = %i and rampExists != 0",intID];
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int isComplete = sqlite3_column_int(statement, 0);
        int rampType = sqlite3_column_int(statement, 1);
        int rampNum = sqlite3_column_int(statement, 2);
        if (maxPay && rampType != RampTypeCombPerpWalk && rampType != RampTypeCombPerpNonWalk && isComplete == 1)
        {
            if (nPaid)
                [updateQuery appendString:@","];
            [updateQuery appendFormat:@"%i",rampNum];
            nPaid++;
            maxPay--;
        }
    }
    [updateQuery appendString:@")"];
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    
    int rtn = [self.curbRampData executeCmd:updateQuery.UTF8String
                               sendToServer:YES
                                   fromFile:__FILE__ fromLine:__LINE__];
    [self close:opened];
    
    return nPaid;
}

- (int) autoMarkRampsPaid:(int) maxToPay
{
    int numMarked = 0;
    if (maxToPay > 0)
    {
        struct {int intID, rampNum;}rampKey;
        BOOL opened = [self open];
        NSString *query = [NSString stringWithFormat:@"SELECT intID,rampNum FROM Ramps WHERE rampExists != 0 AND isComplete = 1 ORDER BY timeComplete"];
        sqlite3_stmt *statement = NULL;
        int count = 0;
        SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
        NSString *tempPath = NSTemporaryDirectory();
        NSString *tempFile = [tempPath stringByAppendingPathComponent:@"tempRampFile.bin"];
        
        FILE *Fid = fopen(tempFile.UTF8String,"wb");
        
        if (Fid != NULL)
        {
            while (sqlite3_step(statement) == SQLITE_ROW && maxToPay--)
            {
                rampKey.intID = sqlite3_column_int(statement, 0);
                rampKey.rampNum = sqlite3_column_int(statement, 1);
                BigWriteF(Fid, (LPCSTR)&rampKey,sizeof(rampKey), -1);
            }
            SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
            fclose(Fid);
            Fid = fopen(tempFile.UTF8String,"rb");

            while (BigReadF (Fid,&rampKey,sizeof(rampKey)) == sizeof(rampKey))
            {
                query = [NSString stringWithFormat:@"UPDATE ramps SET isComplete = 2 WHERE intID = %i AND rampNum = %i",rampKey.intID,rampKey.rampNum];
                int rtn = [self.curbRampData executeCmd:query.UTF8String
                                       sendToServer:YES
                                               fromFile:__FILE__ fromLine:__LINE__];
                numMarked++;
            }
            fclose(Fid);
            [NSFileManager.defaultManager removeItemAtPath:tempFile
                                                     error:nil];
        }
        [self close:opened];
    }
    return numMarked;
}

- (int)getCountOfIntersections
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    
    [self close:opened];
    return count;
}

- (int)getCountOfRamps:(int)type
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Ramps WHERE rampExists != 0 AND isComplete = %i",type];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    
    [self close:opened];
    return count;
}

- (int)getRampCounts
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Ramps"];
    sqlite3_stmt *statement = NULL;
    int count = 0;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    
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
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
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
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
    [self close:opened];
    return !rtn;
}

- (BOOL)assignIntersectionsFrom:(int)intID
                             to:(int)endID
                         toUser:(int)user
                           type:(NSString *)type
                         status:(IntersectionStatus)status
{
    BOOL rtn = NO;
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo%@=%i WHERE intID>=%i AND intID <=%i",
                       iTime, type, user, intID, endID];
    if (status)
        query = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, assignedTo%@=%i, status=%li WHERE intID>=%i AND intID <=%i",
                 iTime, type, user, (long)status, intID, endID];
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];

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
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
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
    
    rtn = [self.curbRampData executeCmd:query.UTF8String
                           sendToServer:YES
                               fromFile:__FILE__ fromLine:__LINE__];
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
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    [self close:opened];
    return intpt;
}

- (NSArray<IntersectionPoint *> *)getAssignments:(NSString *)type
{
    NSMutableArray <IntersectionPoint *> *assignments = NSMutableArray.array;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT intID, assignedToPrelim, assignedToDetail FROM Intersections WHERE assignedTo%@ != 0 ORDER BY assignedTo%@,intID ASC",type,type];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
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
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    [self close:opened];
    return assignments.copy;
}

- (NSArray<IntersectionPoint *> *)getIntersectionsAssignedTo:(int)iPad
                                 ofType:(NSString *)type
{
    NSMutableArray <IntersectionPoint *> *assignments = NSMutableArray.array;
    BOOL opened = [self open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT intID, assignedToPrelim, assignedToDetail, zoomLevel FROM Intersections WHERE assignedTo%@ != 0 ORDER BY assignedTo%@,intID ASC",type,type];
    
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL), self.curbRampData.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        IntersectionPoint *intpt = [[IntersectionPoint alloc] init];
        int intID = sqlite3_column_int(statement, 0);
        int assignedToPrelim = sqlite3_column_int(statement, 1);
        int assignedToDetail = sqlite3_column_int(statement, 2);
        intpt.zoomLevel = sqlite3_column_int(statement, 3);
        intpt.intID = intID;
        intpt.assignedToPrelim = assignedToPrelim;
        intpt.assignedToDetail = assignedToDetail;
        [assignments addObject:intpt];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
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


-(NSString*) intStructToCmd:(INTERSECTION_STRUCT*)pInt
{
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO Intersections (intID,lastUpdateTime,status, assignedToPrelim,assignedToDetail,intX,intY,rotation,nStreets,streetNames,latitude,longitude) VALUES (%i,%i,%i,%i,%i,%i,%i,%i,%i,'%s',%f,%f);INSERT INTO Intersections_index VALUES (%i,%f,%f,%f,%f);",
                     pInt->intID,
                     pInt->lastUpdateTime,
                     pInt->status,
                     pInt->assignedToPrelim,
                     pInt->assignedToDetail,
                     pInt->lev21X,
                     pInt->lev21Y,
                     pInt->rotation,
                     pInt->nStreets,
                     pInt->streetNames,
                     pInt->lat,
                     pInt->lon,
                     pInt->intID,
                     pInt->lon,
                     pInt->lon,
                     pInt->lat,
                     pInt->lat];
    return cmd;
}
- (int)loadIntersectionTextToDatabase:(NSString *)path
                         progressView:(GSSiPopoverView *)popover
{
    BOOL rtn = INTDBStatusFailed;
    char dataFile[PATH_MAX], indexFile[PATH_MAX];
    //LPSTR pUB;
    FILE *fidData = NULL;
    FILE *fidIndex = NULL;
    int maxData = 256;
    int maxIndex = 100;
    int i = 0;
    
    
    strcpy(indexFile, path.UTF8String);
    strcpy(dataFile, indexFile);
    strcat(indexFile, "/intersection_index.bin");
    strcat(dataFile, "/intersection_data.bin");
    fidData = fopen(dataFile, "rb");
    fidIndex = fopen(indexFile, "rb");
    
    NSLog (@"loadIntersectionTextToDatabase fopen file: %s", indexFile);
    
    if (fidData)
    {
        double fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:[NSString stringWithCString:dataFile encoding:NSUTF8StringEncoding]                                                                                         error:nil].fileSize;
        rtn = INTDBStatusOK;
        
        dispatch_queue_t overallQueue = dispatch_queue_create("overallQueue",NULL);
        if (popover)
            [popover show];
        dispatch_async(overallQueue,
                       ^{
                           char data[512], index[512];
                           double currentLoc;
                           int nLoaded = 0;
                           INTERSECTION_STRUCT intStruct = {0};
                           BOOL opened = [self open];
                           [self startTransaction];
                           if ([self.curbRampData createIntersectionsTable:YES])
                           {
                               
                               fgetstringF(index, maxIndex, fidIndex);
                               if (!strncmp (index,"*EMPTY*",7))
                               {
                                   goto Exit;
                               }
                               if (popover)
                                   dispatch_async(dispatch_get_main_queue(),
                                                  ^{
                                                      [popover updateProgress:0];
                                                      [popover setTitle:@"Loading Intersections"];
                                                  });
                               
                               while (fgetstringF(data, maxData, fidData))
                               {
                                   memset (&intStruct,0,sizeof(INTERSECTION_STRUCT));
                                   LPSTR pTab = strchr(data,'\t');
                                   LPSTR pTabIndex, pAzms, pEnd;
                                   pTabIndex = pAzms = pEnd = NULL;
                                   fgetstringF(index, maxIndex, fidIndex);
                                   pTabIndex = strchr(index,'\t');
                                   *pTab++ = 0;
                                   *pTabIndex = 0;
                                   pTabIndex = strchr(index,' ');
                                   *pTabIndex++ = 0;
                                   intStruct.intID = atoi(data);
                                   intStruct.lev21Y = atoi(index);
                                   intStruct.lev21X = atoi(pTabIndex);
                                   PixelXYToLatLong(intStruct.lev21X, intStruct.lev21Y, 21, &intStruct.lat, &intStruct.lon);
                                   intStruct.assignedToPrelim = 0;
                                   intStruct.assignedToDetail = 0;
                                   intStruct.nStreets = atoi(pTab);
                                   pTab = strchr(pTab,'\t') + 1;
                                   pAzms = strchr(pTab,'\t');
                                   *pAzms++ = 0;
                                   pEnd = strchr(pAzms,'\t');
                                   *pEnd = 0;
                                   strncpy(intStruct.streetNames, pTab, sizeof(intStruct.streetNames) - 1);
                                   REPLAC(intStruct.streetNames,"'","''",sizeof(intStruct.streetNames) - 1);
                                   strncpy(intStruct.streetAzms, pAzms, sizeof(intStruct.streetAzms) - 1);
                                   
                                   NSString *cmd = [self intStructToCmd:&intStruct];
                                   [self.curbRampData executeCmd:(char *)cmd.UTF8String
                                                    sendToServer:YES
                                                        fromFile:__FILE__ fromLine:__LINE__];
                                   
                                   nLoaded++;
                                   currentLoc = ftell(fidData);
                                   
                                   if (popover && !(nLoaded % 10))
                                       dispatch_async(dispatch_get_main_queue(),
                                                      ^{
                                                          [popover updateProgress:currentLoc/fileSize];
                                                      });
                               }
                           Exit:
                               if (opened)
                                   [self commitTransaction];
                               if (popover)
                                   dispatch_async(dispatch_get_main_queue(),
                                                  ^{
                                                      [popover updateProgress:1];
                                                      [popover hide];
                                                  });
                               
                           }
                           [self close:opened];
                           fclose(fidIndex);
                           fclose(fidData);
                           if (self.delegate)
                           {
                               [self.delegate intersectionsDatabase:[self.curbRampData databasePath:self.geoid]
                                                            didLoad:@""
                                                         withStatus:INTDBStatusOK];
                           }
                           
                       });
    }
    return rtn;
}

- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    INTDBStatus intdbStatus = INTDBStatusDefault;
    
    if (status == FTPStatusOK || status == FTPStatusFileExists)
    {
        NSString *toDirectory = [CRAPI.sharedInstance directoryFromPath:path
                                                                andName:[NSString stringWithFormat:@"/%i",self.geoid]
                                                                 create:YES];
        
        if (self.gettingUploaded)
            [self open];
        
        else
        {
            if (DecompressGMZipFile((LPSTR)path.UTF8String, (LPSTR)toDirectory.UTF8String,0,0,0))
            {
                intdbStatus = (INTDBStatus)[self loadIntersectionTextToDatabase:toDirectory
                                                                   progressView:_popover];
            }
            
            else
            {
                [NSFileManager.defaultManager removeItemAtPath:path
                                                         error:nil];
                intdbStatus = INTDBStatusFailedToUnzip;
                
                if (self.delegate)
                {
                    [self.delegate intersectionsDatabase:[self.curbRampData databasePath:self.geoid]
                                                 didLoad:@"Failed to Unzip"
                                              withStatus:intdbStatus];
                }
            }
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
    _popover = popover;
    geoid = geoid % 100000000;
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%7.7i_Intersections.gcf", geoid];
    
    self.gettingUploaded = NO;
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
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
    int nRamps = [self getCountOfRamps:0];
    
    if (fileSize > 0 && !forceReload && nIntersections > 0 && [_curbRampData isCurrentVersion])
    {
        if (_delegate)
        {
            [popover hide];
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

- (void)dealloc
{
    NSLog(@"Intersections Database dealloc");
}

- (BOOL)startTransaction
{
    return [self.curbRampData startTransaction];

}
- (void)commitTransaction
{
    [self.curbRampData commitTransaction];
}

- (int) getNewIntID
{
    int nextID = 0;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT MAX(intID) FROM Intersections"];
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        nextID = sqlite3_column_int(statement, 0);
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    [self close:opened];
    
    nextID = (int)[CRAPI.sharedInstance adjustNextRefno:nextID];

    return nextID;
}

- (int)addNewIntersectionAt:(LLPOINT)pt
                   withName:(NSString *)name
{
    INTERSECTION_STRUCT intRec;
    memset (&intRec,0,sizeof(INTERSECTION_STRUCT));
    intRec.intID = [self getNewIntID];
    
    if (CRAPI.sharedInstance.currentModule == DETAIL_MODULE)
    {
        intRec.status = AddedInDetail;
        intRec.assignedToDetail = CRAPI.sharedInstance.currentiPadWithinManager;
    }
    
    else
    {
        intRec.status = InitialStatus;
        intRec.assignedToPrelim = CRAPI.sharedInstance.currentiPadWithinManager;
    }
    
    LatLongToPixelXY(pt.lat, pt.lon, 21, &intRec.lev21X, &intRec.lev21Y);
    intRec.lat = pt.lat;
    intRec.lon = pt.lon;
    intRec.nStreets = 1;
    strncpy(intRec.streetNames, name.UTF8String, sizeof(intRec.streetNames) - 1);
    
    BOOL opened = [self open];
    
    SQLOK(__FILE__,__LINE__,SQLiteExec(self.curbRampData.database, "BEGIN TRANSACTION", NULL, NULL, NULL),self.curbRampData.database);
    NSString *cmd = [self intStructToCmd:&intRec];
    [self.curbRampData executeCmd:(char *)cmd.UTF8String
                     sendToServer:YES
                         fromFile:__FILE__ fromLine:__LINE__];

    SQLOK(__FILE__,__LINE__,SQLiteExec(self.curbRampData.database, "COMMIT TRANSACTION", NULL, NULL, NULL), self.curbRampData.database);
    [self close:opened];

    return intRec.intID;

}

-(NSString*) getStreetNamesForIntersection:(int)intID
{
    NSString* names=@"";
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT nStreets, streetNames FROM Intersections WHERE intID = %i",intID];
    sqlite3_stmt *statement = NULL;
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.curbRampData.database, query.UTF8String, -1, &statement, NULL),self.curbRampData.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int nNames = sqlite3_column_int (statement, 0);
        LPSTR pnames = (LPSTR)sqlite3_column_text (statement, 1);
        names = [NSString stringWithUTF8String:pnames];
        names = [names stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.curbRampData.database);
    [self close:opened];
    
   return names;

}

-(NSString*) fixStreetNames:(LPCSTR)name
{
    while (*name == '|')
        name++;
    LPSTR end = strrchr (name,0);
    end--;
    while (end != name)
    {
        if (*end != '|')
            break;
        *end-- = 0;
    }
    NSString * fixedName = [NSString stringWithUTF8String:name];
    fixedName = [fixedName stringByReplacingOccurrencesOfString:@"||" withString:@"|"];
    return fixedName;
}

-(int) nNamesIn:(LPCSTR)names
{
    int n = 0;
    while (*names)
    {
        if (*names == '|')
        {
            if (n)
                n++;
        }
        else
            if (!n)
                n++;
        names++;
    }
    return n;
}
- (void)setStreetNamesForIntersection:(int)intID
                                   to:(NSString *)newNames
{
    BOOL opened = [self open];
    int iTime = NSDate.timeIntervalSinceReferenceDate;
    newNames = [newNames stringByReplacingOccurrencesOfString:@"\n" withString:@"|"];
    newNames = [self fixStreetNames:newNames.UTF8String];
    int nStreets = [self nNamesIn:newNames.UTF8String];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE Intersections SET lastUpdateTime=%i, nStreets=%i, streetNames='%s' WHERE intID=%i",
                     iTime, nStreets,newNames.UTF8String, intID];
    
    [self.curbRampData executeCmd:(char *)cmd.UTF8String
                     sendToServer:YES
                         fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
}

- (void)deleteIntersection:(int)intID
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM Intersections WHERE intID = %i;DELETE FROM Intersections_index WHERE id = %i",intID,intID];
    
    [self.curbRampData executeCmd:(char *)cmd.UTF8String
                     sendToServer:YES
                         fromFile:__FILE__ fromLine:__LINE__];
    
    [self close:opened];
}

@end
