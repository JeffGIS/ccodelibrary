//
//  CrimeData.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/10/15.
//  Copyright © 2015 GSSi. All rights reserved.
//
/*
CREATE TABLE OFFENSEXY (id INT PRIMARY KEY,'ControlNbr' INT,'OffenseOrder' INT,'Offense' CHAR(6),'CityCode' CHAR(2),'CaseYear' INT,'CaseNbr' CHAR(6),'ControlType' CHAR(1),'Attempt' CHAR(1),'BeginDate2' CHAR(19),'Precinct' CHAR(2),'UCRCode' CHAR(2),'NIBRSCode' CHAR(3),'CrimeCategory' CHAR(1),'CrimeClass' CHAR(1),'LastChangedID2' CHAR(11),'LastChanged2' CHAR(19),'OriginalCaseYear' INT,'OriginalCaseNbr' CHAR(6),'HouseNbr' CHAR(6),'HouseModifier' CHAR(1),'StreetName' CHAR(22),'StreetType' CHAR(2),'StreetDirection' CHAR(2),'IntersectionStreetName' CHAR(22),'IntersectionStreetType' CHAR(2),'IntersectionStreetDirection' CHAR(2),'Apartment' CHAR(5),'City2' CHAR(30),'State' CHAR(2),'VictimBusiness' CHAR(1),'Zipcode2' CHAR(9),'EndDate' CHAR(19),'ReportedDate' CHAR(19),'BeginDate' CHAR(19),'DispatchedTime' CHAR(4),'ArrivedTime' CHAR(4),'Location' CHAR(30),'ClearedTime' CHAR(4),'PrimaryOffense' CHAR(6),'SupervisorID' CHAR(11),'AssistingOfficerID' CHAR(11),'NotPublicInformation' CHAR(1),'UnitNbr' CHAR(4),'ReportingID' CHAR(11),'CallNbr' CHAR(11),'EnteredID' CHAR(11),'EnteredDate' CHAR(19),'LastChanged' CHAR(19),'AdultStatus' INT,'JuvenileStatus' INT,'Solvable' INT,'NotPublicAddressInformation' CHAR(1),'LastChangedID' CHAR(11),'ForceSupervisorReviewRequired' INT,'ForceSupervisorReviewCompeted' INT,'ForceIAUReviewCompleted' INT,'MatchCode' INT,'LocationCode' INT,'StreetNum' INT,'HouseNum' INT,'IntID' INT,'StreetNum1' INT,'StreetNum2' INT,'Street1MP' REAL,'Street2MP' REAL,'MunicNum' INT,'ZIP' INT,'X' REAL,'Y' REAL,'NumPartsRemoved' INT,'AddressTAGPrefix' CHAR(8),'AddressTAGUDI' CHAR(64),'Street' CHAR(80),'House' CHAR(12),'City' CHAR(32),'ZIPCODE' CHAR(12),'Symbol' CHAR(64),'FromDate' INT,'ToDate' INT,'Note' CHAR(100),'UCR' INT)
*/

extern int keepProcessing;

#import "CrimeData.h"
#import "UserDefaults.h"
#import "CRAPI.h"

@interface CrimeData ()
@property (nonatomic) UIColor *red;
@end

@implementation CrimeData

- (BOOL)continue
{
    if (self.processingID == keepProcessing)
        return YES;
    
    return NO;
}


static int SQLOK(int sqlReturn,sqlite3 *database)
{
    if (sqlReturn != SQLITE_OK)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i = %i:%s",
                      sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database)]);
    }
    
    return sqlReturn;
}


- (id)init
{
    self = [super init];
    
    if (self)
    {
        _documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _fileName = @"Crimes.sqlite";
        _path = [NSString stringWithFormat:@"%@/%@", _documentsDirectory, _fileName];
        _minUCR = 1;
        _maxUCR = 10;
        _red = [[UIColor alloc] initWithRed:1.0
                                      green:0.0
                                       blue:0.0
                                      alpha:1.0];
    }
    
    return self;
}

- (void)dealloc
{
    [self close];
    CloseTRANS2 (&_pTranLLtoView);
    CloseTRANS2 (&_pTranViewtoLL);
    NSLog(@"Sewer Database dealloc");
}

- (void)open
{
    if (!_isOpen)
    {
        _isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"Sewer Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
    }
}

- (void)close
{
    if (_isOpen)
    {
        SQLOK(sqlite3_close(_database),_database);
        NSLog(@"Sewer Database close");
    }
    _isOpen = NO;
}

- (void)clear
{
    [self close];
    
    //BOOL st = [NSFileManager.defaultManager removeItemAtPath:_path
    //error:nil];
}

- (int) datasetVersion
{
    int rtn = -1;
    [self open];
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM OFFENSEXY"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            int maxID = sqlite3_column_int(statement, 0);
            if (maxID > 0)
                rtn = 0;
        }
        SQLOK(sqlite3_finalize(statement), _database);
    }
    [self close];
    return rtn;
}

- (BOOL)executeCmd:(char *)cmd
{
    BOOL rtn = !SQLOK(sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (void)startTransaction
{
    [self open];
    SQLOK(sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
}

- (void)commitTransaction
{
    SQLOK(sqlite3_exec(_database, "COMMIT", 0, 0, 0),_database);
}

- (void)setTrans:(CORNERPOINTS *)corners
      viewBounds:(MNMXCORD *)pvbounds
{
    
    CloseTRANS2(&_pTranLLtoView);
    CloseTRANS2(&_pTranViewtoLL);
    _pTranLLtoView = STRANCornersToBounds(corners, pvbounds);
}



- (void)displayCrimePoints:(CGContextRef)context
                 llCorners:(CORNERPOINTS *) latlonCornerPoints
                  LLBounds:(MNMXCORD *)platlonBounds
                viewBounds:(MNMXCORD *)pvbounds
{
    NSString *query;
    sqlite3_stmt *statement = NULL;
    DPOINT BasePt;
    int UCR;
    int controlNbr;
    int fromTime=(int)CRAPI.sharedInstance.fromDate, toTime=(int)CRAPI.sharedInstance.toDate;
    int fromDate, toDate;
    int nFound=0;
    LPSTR offense;
    CGFloat size;
    CGColorRef color;
    CGFloat sizeFactor = 5;
    
    if (_zoom > 18)
        sizeFactor *= (2.0 *(_zoom - 18.0));
    
    else if (_zoom < 18)
        sizeFactor /= (2.0 * (18.0 - _zoom));
    
    if (![self continue])
        return;
    
    [self setTrans:latlonCornerPoints viewBounds:pvbounds];
    
    [self open];
    
    switch (CRAPI.sharedInstance.project)
    {
        case PROJECT_METROGIS:
            query = [NSString stringWithFormat:@"SELECT ControlNbr,X,Y,Offense,UCR,FromDate,ToDate FROM OFFENSEXY,OFFENSEXY_index WHERE OFFENSEXY.id=OFFENSEXY_index.id AND maxX>=%f AND minX<=%f AND maxY>=%f AND minY<=%f AND MinUCR>=%f AND MaxUCR<=%f AND minTime>=%f AND maxTime <= %f",
                     platlonBounds->xmn, platlonBounds->xmx, platlonBounds->ymn, platlonBounds->ymx,_minUCR*10.0-1,_maxUCR*10.0+1,fromTime/1000.0-1,toTime/1000.0+1];
    }
    
    SQLOK(sqlite3_prepare_v2(self.database, query.UTF8String, -1, &statement, 0), _database);
    
    while ([self continue] && sqlite3_step(statement) == SQLITE_ROW)
    {
        nFound++;
        controlNbr = sqlite3_column_int(statement,0);
        BasePt.x = sqlite3_column_double(statement,1);
        BasePt.y = sqlite3_column_double(statement,2);
        offense = (LPSTR)sqlite3_column_text(statement,3);
        UCR = sqlite3_column_int(statement,4);
        fromDate = sqlite3_column_int(statement,5);
        toDate = sqlite3_column_int(statement,6);
       
        DPOINT llpoint = TranDPOINT(&BasePt, _pTranLLtoView);
        
        if (UCR < 6)
        {
            color = _red.CGColor;
            size = 20.0;
        }
        else
        {
            color = UIColor.brownColor.CGColor;
            size = 16.0;
        }
        [self drawCrimePoint:context
                     atPoint:&llpoint
                   withColor:color
                     andSize:(size * sizeFactor)];
    }
    SQLOK(sqlite3_finalize(statement), _database);
    [self close];
}

- (void)drawCrimePoint:(CGContextRef)context
               atPoint:(DPOINT *)pPoint
             withColor:(CGColorRef)color
               andSize:(CGFloat)size

{
    CGRect pointRect = CGRectMake((pPoint->x - size / 2.0),
                                  (pPoint->y - size / 2.0), size, size);
    
    //CGContextSetStrokeColorWithColor(context,color);
    CGContextSetFillColorWithColor(context,color);
    CGContextFillEllipseInRect(context, pointRect);
    //CGContextStrokeEllipseInRect(context, pointRect);
    //CGContextFillPath(context);
}

@end
