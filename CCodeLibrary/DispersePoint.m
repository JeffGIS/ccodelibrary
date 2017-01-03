//  DispersePoint.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/3/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "DispersePoint.h"
#import "UserDefaults.h"
#import "PickedItem.h"
#import "CRAPI.h"

@implementation DispersePoint

- (void) releaseMem
{
    if (_grid)
        free (_grid);
}
- (void)dealloc
{
    [self close];
    [self releaseMem];
}

- (int) gridIndex:(int)row column:(int)col
{
    if (row < 0 || col < 0 || row >= _height || col >= _width)
        return -1;
    int indx = row * _width + col;
    
    return indx;
}
- (id)init
{
    self = [super init];
    
    if (self)
    {
        _documentsDirectory = UserDefaults.defaults.localFilePath;
        _fileName = @"DispersedPoints.sqlite";
        _path = [NSString stringWithFormat:@"%@/%@", _documentsDirectory, _fileName];
    }
    
    return self;
}
- (BOOL)open
{
    if (!_isOpen)
    {
        _isOpen = !SQLOK(197,sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"Dispersed Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        return TRUE;
    }
    return FALSE;
}

- (void)close
{
    if (_isOpen)
    {
        SQLOK(198,sqlite3_close(_database),_database);
        NSLog(@"Dispersed Database close");
        _isOpen = NO;
    }
}

- (BOOL)executeCmd:(char *)cmd
{
    BOOL rtn = !SQLOK(199,sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (void)startTransaction
{
    [self open];
    SQLOK(200,sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
}

- (void)commitTransaction
{
    SQLOK(201,sqlite3_exec(_database, "COMMIT", 0, 0, 0),_database);
}

+ (DispersePoint *)initWithWidth:(int)width
                          Height:(int)height
                           tran1:(LPTRANDATA)pTranLLtoView
                           tran2:(LPTRANDATA)pTranViewtoLL

{
    DispersePoint * dp = [[DispersePoint alloc]init];
    dp.width = width;
    dp.height = height;
    dp.grid = calloc (width*height,sizeof(unsigned short));
    
    [dp startTransaction];
    [dp executeCmd:"DROP TABLE IF EXISTS TRANSFORM;DROP TABLE IF EXISTS DISPERSE;DROP TABLE IF EXISTS DISPERSE_index;\
     CREATE TABLE TRANSFORM (id INT,NSETPT INT, A1 double, A2 double, B1 double, B2 double, C1 double, C2 double, BASX double, BASY double);\
     CREATE TABLE DISPERSE (id INT,ControlNbr INT,Sequence INT, X INT, Y INT, DispersedX, DispersedY, Symbol INT, Size INT, Color INT, Time INT,Offense CHAR(64));\
     CREATE VIRTUAL TABLE IF NOT EXISTS DISPERSE_index USING rtree(id,minX, maxX, minY, maxY);"];
    char txt[1024];
    [dp executeCmd:(LPSTR)[NSString stringWithFormat:@"INSERT INTO TRANSFORM VALUES(%i,%i,%.16G,%.16G,%.16G,%.16G,%.16G,%.16G,%.16G,%.16G);",1,
                           pTranLLtoView->NSETPT,
                           pTranLLtoView->A1,
                           pTranLLtoView->A2,
                           pTranLLtoView->B1,
                           pTranLLtoView->B2,
                           pTranLLtoView->C1,
                           pTranLLtoView->C2,
                           pTranLLtoView->BASX,
                           pTranLLtoView->BASY].UTF8String];
    [dp executeCmd:(LPSTR)[NSString stringWithFormat:@"INSERT INTO TRANSFORM VALUES(%i,%i,%.16G,%.16G,%.16G,%.16G,%.16G,%.16G,%.16G,%.16G);",2,
                           pTranViewtoLL->NSETPT,
                           pTranViewtoLL->A1,
                           pTranViewtoLL->A2,
                           pTranViewtoLL->B1,
                           pTranViewtoLL->B2,
                           pTranViewtoLL->C1,
                           pTranViewtoLL->C2,
                           pTranViewtoLL->BASX,
                           pTranViewtoLL->BASY].UTF8String];
    dp.nextID = 1;
    return dp;
}

- (BOOL) restoreTran
{
    BOOL rtn = FALSE;
    NSString *query = @"SELECT * FROM TRANSFORM;";
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(202,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPTRANDATA pTran = malloc (sizeof(TRANDATA));
        int type = sqlite3_column_int(statement, 0);
        pTran->NSETPT = sqlite3_column_int(statement, 1);
        pTran->A1 = sqlite3_column_double(statement, 2);
        pTran->A2 = sqlite3_column_double(statement, 3);
        pTran->B1 = sqlite3_column_double(statement, 4);
        pTran->B2 = sqlite3_column_double(statement, 5);
        pTran->C1 = sqlite3_column_double(statement, 6);
        pTran->C2 = sqlite3_column_double(statement, 7);
        pTran->BASX = sqlite3_column_double(statement, 8);
        pTran->BASY = sqlite3_column_double(statement, 9);
        if (type == 1)
            _pTranLLtoView = pTran;
        else
            _pTranViewtoLL = pTran;
        rtn = TRUE;
    }
    
    SQLOK(203,sqlite3_finalize(statement), _database);
    return rtn;
}
- (BOOL) addPoint:(DPOINT *)pPoint
       controlNbr:(int)cnbr
             time:(NSInteger)time
          offense:(NSString*)offense
      usingSymbol:(PointSymbols)sym
        withColor:(CGColorRef)color
          andSize:(CGFloat)size

{
    int indx = [self gridIndex:pPoint->y column:pPoint->x];
    if (indx < 0)
        return FALSE;
    int seq = _grid[indx]++;
    POINT point = DPointToPoint (pPoint);
    POINT dispersedPoint = AddjustPointLoc (point,size,seq+1);

    NSString * cmd = [NSString stringWithFormat:@"INSERT INTO DISPERSE VALUES(%i,%i,%i,%i,%i,%i,%i,%i,%f,%lli,%li,'%s');INSERT INTO DISPERSE_index VALUES(%i,%f,%f,%f,%f);",_nextID,cnbr,seq,point.x,point.y,dispersedPoint.x,dispersedPoint.y,(int)sym,size,(long long)color,time,offense.UTF8String, _nextID,(float)dispersedPoint.x-1,(float)dispersedPoint.x+1,(float)dispersedPoint.y-1,(float)dispersedPoint.y+1];
    [self executeCmd:(LPSTR)cmd.UTF8String];
    _nextID++;
    return TRUE;
}

- (int)pickDispersedPoint:(LLPOINT *)llpt
            highlightList:(NSMutableArray*)hlist
{
    sqlite3_stmt *statement = NULL;
    CGFloat d, mind = DBL_MAX;
    DPOINT p1, p2, minpt;
    int minref = 0;
    int npicked = 0;
    int minsym = 0;
    NSString * minID=@"";
    NSInteger time = 0;
    NSInteger minTime = 0;
    
    
    BOOL opened = [self open];
    if (![self restoreTran])
    {
        if (opened)
            [self close];
        return 0;
    }
    p1.x = llpt->lon;
    p1.y = llpt->lat;
    DPOINT screenPoint = TranDPOINT(&p1, _pTranLLtoView);
    minpt = p1;
    dbounds bnds = [CRAPI.sharedInstance getPixelPickApBoundsAtPoint:&screenPoint];
    
    NSString *query = [NSString stringWithFormat:@"SELECT ControlNbr, DispersedX, DispersedY,Time,Offense,Symbol FROM DISPERSE,DISPERSE_index WHERE DISPERSE.id=DISPERSE_index.id AND maxX>=%f AND minX<=%f AND maxY>=%f AND minY<=%f",
                       bnds.xmn, bnds.xmx, bnds.ymn, bnds.ymx];
    
    
    SQLOK(204,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int refno = sqlite3_column_int(statement, 0);
        p2.x = sqlite3_column_double(statement, 1);
        p2.y = sqlite3_column_double(statement, 2);
        time = sqlite3_column_int(statement, 3);
        LPSTR offense = (LPSTR)sqlite3_column_text(statement, 4);
        int symbol = sqlite3_column_int(statement, 5);
        d = ldistpp(&p1, &p2);
        
        if (d < mind)
        {
            npicked++;
            minref = refno;
            minsym = symbol;
            mind = d;
            minpt = p2;
            minID = [NSString stringWithUTF8String:offense];
            minTime = time;
        }
    }
    
    SQLOK(2042,sqlite3_finalize(statement), _database);
    if (npicked)
    {
        PickedItem *pi = [[PickedItem alloc]init];
        pi.itemType = CrimePoint;
        pi.symbol = minsym;
        pi.distance = mind;
        pi.pickedPoint = TranDPOINT(&minpt, _pTranViewtoLL);
        pi.symbolName = @"CRIME";
        pi.refno = minref;
        pi.time  = minTime;
        pi.identifier = minID;
        [hlist addObject:pi];
    }
    free (_pTranLLtoView);
    free (_pTranViewtoLL);
    
    if (opened)
        [self close];
    return npicked;
}

POINT AddjustPointLoc (POINT Point,float Size,int Sequence)
#if ENABLETRACE
{GSSiEnterProg (1331);
#endif
    {
        short	xmove, ymove, shift=0;
        float	shiftdist;
        
        if (Sequence <= 1)
        {
#if ENABLETRACE
            GSSiExitProg (1331);
#endif
            return Point;
        }
    Top:
        if (Sequence == 1)
        {
            xmove = 0;
            ymove = 0;
        }
        else if (Sequence < 4)
        {
            xmove = -1;
            ymove = Sequence - 2;
        }
        else if (Sequence < 6)
        {
            ymove = 1;
            xmove = Sequence - 4;
        }
        else if (Sequence < 8)
        {
            xmove = 1;
            ymove = -(Sequence - 6);
        }
        else if (Sequence < 10)
        {
            ymove = -1;
            xmove = -(Sequence - 8);
        }
        else if (Sequence < 14)
        {
            xmove = -2;
            ymove = Sequence - 11;
        }
        else if (Sequence < 18)
        {
            ymove = 2;
            xmove = Sequence - 15;
        }
        else if (Sequence < 22)
        {
            xmove = 2;
            ymove = -(Sequence - 19);
        }
        else if (Sequence < 27)
        {
            ymove = -2;
            xmove = -(Sequence - 23);
        }
        else if (Sequence < 32)
        {
            xmove = -3;
            ymove = Sequence - 28;
        }
        else if (Sequence < 38)
        {
            ymove = 3;
            xmove = Sequence - 34;
        }
        else if (Sequence < 44)
        {
            xmove = 3;
            ymove = -(Sequence - 40);
        }
        else if (Sequence < 51)
        {
            ymove = -3;
            xmove = -(Sequence - 46);
        }
        else if (Sequence < 58)
        {
            xmove = -4;
            ymove = Sequence - 53;
        }
        else if (Sequence < 66)
        {
            ymove = 4;
            xmove = Sequence - 61;
        }
        else if (Sequence < 74)
        {
            xmove = 4;
            ymove = -(Sequence - 69);
        }
        else if (Sequence < 83)
        {
            ymove = -4;
            xmove = -(Sequence - 77);
        }
        else if (Sequence < 92)
        {
            xmove = -5;
            ymove = Sequence - 86;
        }
        else if (Sequence < 102)
        {
            ymove = 5;
            xmove = Sequence - 96;
        }
        else if (Sequence < 112)
        {
            xmove = 5;
            ymove = -(Sequence - 106);
        }
        else if (Sequence < 122)
        {
            ymove = -5;
            xmove = -(Sequence - 116);
        }
        else
        {
            shift++;
            Sequence -= 121;
            goto Top;
        }
        shiftdist = shift * 0.25 * Size;
        Point.x += IDNINT (xmove * Size + shiftdist);
        Point.y += IDNINT (ymove * Size + shiftdist);
        {
#if ENABLETRACE
            GSSiExitProg (1331);
#endif
            return Point;
        }
#if ENABLETRACE
    }
#endif
}

+ (NSArray *)getDispersedPoints
{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    sqlite3_stmt *statement = NULL;
    DPOINT p2;
    int minsym = 0;
    NSInteger time = 0;
    DispersePoint *dp=[[DispersePoint alloc]init];
    
    BOOL opened = [dp open];
    if (![dp restoreTran])
    {
        if (opened)
            [dp close];
        return 0;
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT ControlNbr, DispersedX, DispersedY,Time,Offense,Symbol FROM DISPERSE"];
    
    
    SQLOK(205,sqlite3_prepare_v2(dp.database, query.UTF8String, -1, &statement, 0), dp.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int refno = sqlite3_column_int(statement, 0);
        p2.x = sqlite3_column_double(statement, 1);
        p2.y = sqlite3_column_double(statement, 2);
        time = sqlite3_column_int(statement, 3);
        LPSTR offense = (LPSTR)sqlite3_column_text(statement, 4);
        int symbol = sqlite3_column_int(statement, 5);
        PickedItem *pi = [[PickedItem alloc]init];
        pi.itemType = CrimePoint;
        pi.symbol = minsym;
        pi.screenPoint = p2;
        pi.pickedPoint = TranDPOINT(&p2, dp.pTranViewtoLL);
        pi.symbolName = @"CRIME";
        pi.refno = refno;
        pi.time  = time;
        pi.identifier = [NSString stringWithUTF8String:offense];
        [array addObject:pi];
       
    }
    
    SQLOK(206,sqlite3_finalize(statement), dp.database);
    
    if (opened)
        [dp close];
    return array;
}



@end
