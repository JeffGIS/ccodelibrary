//  PointInAreas.m
//  CCodeLibrary
static int MAXDIM=4096;
static int COLORFAC=1;
#define MINAREAPCT 2.0

#import "PointInAreas.h"
#import "TimeLine.h"
#import "CRAPI.h"
#import "shr.h"
#import "MathUtil.h"
#import "CensusData.h"

#pragma pack(1)
typedef struct {CGFloat c1,c2,c3,c4;} COLORDEF;
#pragma pack()

@interface AreaData : NSObject
@property int areaNumber;
@property NSString * areaID;
@property COLORDEF colordef;
@property int icolor;
@property double count, count1, count2;
@property int nCounts;
@property double areaInPixels;
@property int pixelsInMask;
@property float pctInMask;
@property double value;
@property double valuePerPixel;
@property int maxTime;
@property double aveHoursBetweenIncident;
@property CGColorRef displayColor;
@end

@implementation AreaData

@end

@implementation PointInAreas

static int ii;

- (void) writeImageToPhotos
{
    if (COLORFAC <= 1)
        return;
    NSString * file = CRAPI.sharedInstance.extractFile;
    
    BOOL rtn = WriteBitmapDataToFile ((LPSTR)file.UTF8String,_width, _height, _colorSpace, _bitmapData);
    if (rtn)
        NSLog(@"Image written");
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    UIImageWriteToSavedPhotosAlbum(image,
                                   nil,
                                   nil,
                                   nil);
    
}
- (void)releaseMem
{
    for (AreaData *ad in _areaInfo)
        CGColorRelease(ad.displayColor);
 
    if (_bitmapData)
        free (_bitmapData);
    
    if (_context)
        CGContextRelease(_context);
    
    CloseTRANS2P(&_pTranContextToWorld);
    CloseTRANS2P(&_pTranWorldToContext);
    CGColorSpaceRelease(_colorSpace);
    
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        InitDBounds (&_fullBounds);
        self.minTime = INT_MAX;
        self.currentTime = NSDate.date.timeIntervalSince1970;
        self.compareFactor = 1;
    }
    
    return self;
}

- (void)dealloc
{
    [self writeImageToPhotos];
    [self releaseMem];
    [self close:YES];
}
- (BOOL)open
{
    if (!_isOpen)
    {
        //int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:self.path error:nil].fileSize;
        
        _isOpen = !SQLOK(__FILE__,__LINE__,sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"PointInAreas Database open");
        
        return TRUE;
    }
    return FALSE;
}

- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        if (_haveTimeLineDB)
            [self commitTransaction];
        
        SQLOK(__FILE__,__LINE__,sqlite3_close(_database),_database);
        NSLog(@"PointInAreas Database close");
        _isOpen = NO;
        
        /*int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:self.path error:nil].fileSize;
        if (fileSize)
            fileSize = 1;*/
    }
}

- (BOOL)executeCmd:(char *)cmd
{
    BOOL rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (BOOL)startTransaction
{
    BOOL rtn = [self open];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN", 0, 0, 0), _database);
    return rtn;
}

- (void)commitTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT", 0, 0, 0),_database);
}

- (void)createTimeLineTable
{
    NSString *cmd = @"DROP TABLE IF EXISTS TimeLine;"
                    "CREATE TABLE TimeLine (id INTEGER PRIMARY KEY, AreaNumber INT, Time INT, WhichCount INT, Refno INT);"
                    "CREATE INDEX TimeLine_index ON TimeLine (AreaNumber,Time);"
                    "DROP TABLE IF EXISTS AreaNames;"
                    "CREATE TABLE AreaNames (AreaName CHAR(128), AreaNumber INT);";
    
    [self executeCmd:(LPSTR)cmd.UTF8String];
}

- (NSString *)path
{
    NSString * documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString * fileName = @"PointInAreaData.slt";
    NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    return path;
}

- (BOOL)initTimeLine:(sqlite3 *)db
{
    //_database = db;
    BOOL rtn = [self open];
    [self createTimeLineTable];
    _haveTimeLineDB = YES;
    _timeLineID = 1;
    [self startTransaction];
    
    for (AreaData *ad in _areaInfo)
    {
        NSString *areaID = [ad.areaID stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *cmd = [NSString stringWithFormat:@"INSERT INTO AreaNames VALUES ('%@',%i);",areaID,ad.areaNumber];
        [self executeCmd:(LPSTR)cmd.UTF8String];
    }
    
    return rtn;
}

- (void)addToTimeLine:(int)areaNum
               atTime:(int)itime
             andRefno:(int)refno
             forCount:(int)iCount
{
    if (_haveTimeLineDB)
    {
        NSString *cmd = [NSString stringWithFormat:@"INSERT INTO TimeLine VALUES (%i,%i,%i,%i,%i);",_timeLineID++,areaNum,itime,iCount,refno];
        [self executeCmd:(LPSTR)cmd.UTF8String];
    }
}

- (NSArray *) getAreaPointRefs:(NSString *)areaName
{
    NSMutableArray<NSNumber *> *array = NSMutableArray.array;
    BOOL opened = [self open];
    sqlite3_stmt *statement = NULL;
    
    NSString *areaID = [areaName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *query = [NSString stringWithFormat:@"SELECT AreaNumber FROM AreaNames WHERE AreaName = '%@'",areaID];
    int areaNum = -1;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), self.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        areaNum = sqlite3_column_int(statement,0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.database);
    
    query = [NSString stringWithFormat:@"SELECT Time, Refno FROM TimeLine WHERE AreaNumber = %i",areaNum];
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), self.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int itime = sqlite3_column_int(statement,0);
        int refno = sqlite3_column_int(statement,1);
        NSNumber *num = [NSNumber numberWithInt:refno];
        [array addObject:num];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.database);
    [self close:opened];
    return array.copy;
}

- (NSArray<TimeLine *> *)getAreaTimeline:(NSString *)areaName
{
    NSMutableArray<TimeLine *> *array = NSMutableArray.array;
    BOOL opened = [self open];
    sqlite3_stmt *statement = NULL;

    NSString *areaID = [areaName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *query = [NSString stringWithFormat:@"SELECT AreaNumber FROM AreaNames WHERE AreaName = '%@'",areaID];
    int areaNum = -1;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), self.database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        areaNum = sqlite3_column_int(statement,0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.database);
    
    query = [NSString stringWithFormat:@"SELECT Time, Refno FROM TimeLine WHERE AreaNumber = %i",areaNum];
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), self.database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        TimeLine *tl = TimeLine.new;
        int itime = sqlite3_column_int(statement,0);
        int refno = sqlite3_column_int(statement,1);
        tl.time = itime;
        tl.refno = refno;
        tl.value = 1+[NSCalendar.currentCalendar component:NSCalendarUnitHour fromDate:[NSDate dateWithTimeIntervalSince1970:itime]];
        [array addObject:tl];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), self.database);
    TimeLine *tl = TimeLine.new;
    tl.time = NSDate.date.timeIntervalSince1970;
    tl.value = 0.1;
    tl.refno = -1;
    [array addObject:tl];
    [self close:opened];
    return array.copy;
}

- (void) setColor:(int)iColor
         areaData:(AreaData*)ad
{
    COLORDEF cd = {0};
    
    if (_nColorComponents == 1)
    {
        cd.c1 = iColor / 255.0;
        cd.c2 = 1.0;
    }
    
    else
    {
        BYTE bcolor[4] = {0};
        LPINT pInt = (LPINT)&bcolor;
        *pInt = iColor * COLORFAC;
        cd.c1 = bcolor[0] / 255.0;
        cd.c2 = bcolor[1] / 255.0;
        cd.c3 = bcolor[2] / 255.0;
        cd.c4 = 1.0;
    }
    
    ad.colordef = cd;
}

-(void) setContextTran:(LPTRANDATA)pTranViewToLL
{
    CloseTRANS2P(&_pTranContextToWorld);
    CloseTRANS2P(&_pTranWorldToContext);
    
    LPMNMXCORD in = &_fullBounds;
    MNMXCORD llBounds;
    dbounds outb;
    InitDBounds(&outb);
    InitDBounds(&llBounds);
    
    DPOINT ptv = {in->xmn,in->ymn};
    DPOINT pt = [self projectPointToContext:&ptv
                                          from:0];
    AddPointToDBounds(&outb, &pt);
    DPOINT ptw = TranDPOINTP(&ptv, pTranViewToLL);
    AddPointToDBounds(&llBounds, &ptw);

    ptv.x = in->xmn; ptv.y = in->ymx;
    pt = [self projectPointToContext:&ptv
                                       from:0];
    AddPointToDBounds(&outb, &pt);
    ptw = TranDPOINTP(&ptv, pTranViewToLL);
    AddPointToDBounds(&llBounds, &ptw);
    
    ptv.x = in->xmx; ptv.y = in->ymx;
    pt = [self projectPointToContext:&ptv
                                from:0];
    AddPointToDBounds(&outb, &pt);
    ptw = TranDPOINTP(&ptv, pTranViewToLL);
    AddPointToDBounds(&llBounds, &ptw);
    
    ptv.x = in->xmx; ptv.y = in->ymn;
    pt = [self projectPointToContext:&ptv
                                from:0];
    AddPointToDBounds(&outb, &pt);
    ptw = TranDPOINTP(&ptv, pTranViewToLL);
    AddPointToDBounds(&llBounds, &ptw);
   
    dbounds flipBounds = outb;
    //flipBounds.ymn = outb.ymx;
    //flipBounds.ymx = outb.ymn;
    _pTranContextToWorld = STRANBoundsToBoundsP(&flipBounds, &llBounds);
    _pTranWorldToContext = STRANBoundsToBoundsP(&llBounds, &flipBounds);
}

- (int) pointIndex:(int)row column:(int)col
{
    int indx = row * _pointGridSize + col;
    
    return indx;
}

- (void) setPointSize:(double)pointSize
{
    int numGridsSet = 0;
    _pointGridSize = ceil (pointSize * _imageFactor) * 2;
    if (!(_pointGridSize % 2))
        _pointGridSize++;
    _pointGrid = calloc (_pointGridSize*_pointGridSize,sizeof(float));
    _pointSize = pointSize;
    _midxy = _pointGridSize / 2;
    for (int row = 0;row < _pointGridSize; row++)
    {
        for (int col = 0; col < _pointGridSize; col++)
        {
            int indx = [self pointIndex:row column:col];
            float val = _midxy - LDIST(col,row,_midxy,_midxy);
            if (val > 0)
            {
                numGridsSet++;
                _pointGrid[indx] = val;
            }
        }
    }
    if (numGridsSet)
    {
        float setVal = 1.0 / numGridsSet;
        for (int row = 0;row < _pointGridSize; row++)
        {
            for (int col = 0; col < _pointGridSize; col++)
            {
                int indx = [self pointIndex:row column:col];
                if (_pointGrid[indx])
                    _pointGrid[indx] = setVal;
            }
        }
    }
}

- (MNMXCORD) bitmapBounds:(MNMXCORD*) viewBounds
{
    dbounds bounds = *viewBounds;
    double wb = BoundsWidth(viewBounds);
    double hb = BoundsHeight(viewBounds);
    _width = wb;
    _height = hb;
    _fullBounds = bounds;
    
    if (!_maxDimension)
        _maxDimension = MAXDIM;
    
    _width = _maxDimension;
    _height = _maxDimension;
    
    if (wb > 0 && wb > hb)
        _height *= hb / wb;
    
    else if (hb > 0)
        _width *= wb / hb;
    
    _height += _height % 4;
    _width += _width % 4;
    
    bounds.xmn = bounds.ymn = 0;
    bounds.xmx = _width;
    bounds.ymx = _height;
    _fullBounds = bounds;
    _imageFactor = _width / wb;
    
    return bounds;
}

- (void)areasLoaded:(PointInAreas *)boundsPias
        convertToLL:(LPTRANDATA)pTranViewToLL
{
    void *bmData = NULL;
    COLORDEF cd = {0};

    switch (_loadPass)
    {
        case 0:{
            CGRect rect;
            _iArea = 0;
            [self releaseMem];
            _colorSpace = CGColorSpaceCreateDeviceRGB();
            
            if (!_width)
                [self bitmapBounds:&_fullBounds];
            
            [self setContextTran:pTranViewToLL];
            _context = createBitmapContext(_width, _height, _colorSpace, &bmData);
            _bytesPerRow = (int)CGBitmapContextGetBytesPerRow(_context);
            _nColorComponents = (int)CGColorSpaceGetNumberOfComponents(_colorSpace);
            
            if (_nColorComponents == 3)
                _nColorBytes = 4;
            else
                _nColorBytes = 1;
            
            _bitmapData = bmData;
            CGContextSetAllowsAntialiasing(_context, NO);
            CGContextSetShouldAntialias(_context, NO);
            CGContextTranslateCTM(_context, 0, _height);
            CGContextScaleCTM(_context, 1,-1);
            rect = CGRectMake(0, 0,  _width,_height);
            
            for (AreaData *ad in _areaInfo)
            {
                [self setColor:++_iArea areaData:ad];
                cd = ad.colordef;
                CGColorRef colorRef = CGColorCreate(_colorSpace, (CGFloat*)&cd);
                CGContextSetFillColorWithColor(_context, colorRef);
                CGContextFillRect(_context,rect);
                CGColorRelease(colorRef);
                unsigned int bitmapValue = 0;
                
                if (_nColorBytes > 1)
                {
                    _bitmapData[(4 * _width + 4)*_nColorBytes+3] = 0;
                    bitmapValue = *(unsigned int *)&_bitmapData[(4 * _width + 4)*_nColorBytes];
                    //unsigned int bitmapValue1 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes];
                    //unsigned int bitmapValue2 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes+1];
                    //unsigned int bitmapValue3 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes+2];
                    //unsigned int bitmapValue4 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes+3];
                    ii=1;
                }
                
                else
                    bitmapValue = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes];

                ad.icolor = bitmapValue;
                
                if (bitmapValue != _iArea)
                    ii=1;
            }
            
            CGFloat border[4] = {1, 1, 1, 1};
            CGColorRef borderRef = CGColorCreate(_colorSpace, border);
            CGContextSetFillColorWithColor(_context, borderRef);
            rect = CGRectMake(0, 0, _width,_height);
            CGContextFillRect(_context,rect);
            CGColorRelease(borderRef);
            _borderColor = (unsigned int)_bitmapData[4 * _width + 4];
            CGColorRef blackRef;
            
            if (_nColorBytes > 1)
            {
                CGFloat black[4] = {0, 0, 0, 1};
                blackRef = CGColorCreate(_colorSpace, black);
            }
            
            else
            {
                CGFloat black[2] = {0, 1};
                blackRef = CGColorCreate(_colorSpace, black);
            }
            
            CGContextSetFillColorWithColor(_context, blackRef);
            rect = CGRectMake(0, 0, _width,_height);
            CGContextFillRect(_context,rect);
            CGColorRelease(blackRef);
            _iArea = 0;
            break;}
        case 1:
            break;
        case 2:
            break;
        default:break;
    }
    
    _loadPass++;
}

- (AreaData *)getAreaAtLoc:(int)loc
{
    AreaData *ad = nil;
    int iArea = 0;
    
    if (_nColorBytes > 1)
    {
        loc *= 4;
        _bitmapData[loc+3] = 0;
        iArea = *(unsigned int*)&_bitmapData[loc];
        //unsigned int bitmapValue1 = (unsigned int)_bitmapData[loc];
        //unsigned int bitmapValue2 = (unsigned int)_bitmapData[loc+1];
        //unsigned int bitmapValue3 = (unsigned int)_bitmapData[loc+2];
        //unsigned int bitmapValue4 = (unsigned int)_bitmapData[loc+3];
        ii=1;
    }
    
    else
        iArea = (unsigned int)_bitmapData[loc];
    if (iArea && iArea <= [_areaInfo count])
        ad = _areaInfo[iArea-1];
    return ad;
}

- (void)adjustCounts:(PointInAreas *)piaTarget
{
    if (_adjustValue)
    {
        CensusData *cend = [[CensusData alloc]init];
        BOOL opened = [cend open];
        for (AreaData *ad in _areaInfo)
        {
            NSString * cvalue = [cend value:_adjustValue
                               forAreaType:_areaType
                                   withKey:ad.areaID];
            ad.value = [cvalue doubleValue];
            if (ad.areaInPixels)
                ad.valuePerPixel = ad.value/ad.areaInPixels;
            
        }
        [cend close:opened];
        for (int irow = 0;irow < _height;irow++)
        {
            for (int icol = 0;icol < _width;icol++)
            {
                int loc = irow * _width + icol;
                AreaData *adTarget = [piaTarget getAreaAtLoc:loc];
                AreaData *adAdjust = [self getAreaAtLoc:loc];
                if (adTarget && adAdjust)
                {
                    adTarget.value += adAdjust.valuePerPixel;
                }

            }
        }
    }
}

- (void)createDisplayColors:(PointInAreas*)piasAdjust
                       mask:(PointInArea*)piaMask
                wantOverdue:(AdjustCrimeOptions)wantOverdue
{
    
    CGFloat maxCount = 0;
    CGFloat maxValue = 0;

    _overdueOption = wantOverdue;
    _timeRange = _currentTime - _minTime;
    if (piasAdjust && _totPoints)
    {
        [piasAdjust adjustCounts:self];
    }
    for (int irow = 0;irow < _height;irow++)
    {
        for (int icol = 0;icol < _width;icol++)
        {
            DPOINT pt = {icol,irow};
            if (piaMask)
            {
                pt = TranDPOINTP(&pt, _pTranContextToWorld);
            }
            if (!piaMask || [piaMask DPointInArea:&pt])
            {
                int loc = irow * _width + icol;
                AreaData *adTarget = [self getAreaAtLoc:loc];
                if (adTarget)
                    adTarget.pixelsInMask++;
            }
        }
    }
    
    for (AreaData *ad in _areaInfo)
    {
        if (wantOverdue)
        {
            ad.count = ad.count1;
            if (ad.count)
            {
                double secondsPerIncident = _timeRange / ad.count;
                ad.aveHoursBetweenIncident = secondsPerIncident / 3600;
                ad.count = (100 * (_currentTime - ad.maxTime) / secondsPerIncident) - 100;
            }
            
        }
        else
        {
            if (ad.nCounts)
                ad.count = ad.count2 - ad.count1;
            else
                ad.count = ad.count1;
            if (ad.value)
            {
                ad.count /= ad.value;
            }
            else
                ii=1;
        }
        ad.pctInMask = 100.0 * ad.pixelsInMask / ad.areaInPixels;
        if (ad.pctInMask >= MINAREAPCT)
        {
            maxCount = max (maxCount,fabs(ad.count));
            maxValue = max (maxValue,ad.value);
        }
    }
    for (AreaData *ad in _areaInfo)
    {
        CGFloat clr = 1;
        CGFloat alpha = 0.7;
        if (ad.pctInMask >= MINAREAPCT)
        {
            if (maxCount)
                clr = 1.0 - fabs(ad.count)/maxCount;
        }
        else
            alpha = 0;
        CGFloat redColor[4] =  {1.0,clr,clr, alpha};
        CGFloat blueColor[4] = {clr,clr,1.0, alpha};
        if (ad.count < 0)
            ad.displayColor = CGColorCreate(_colorSpace, blueColor);
        else
            ad.displayColor = CGColorCreate(_colorSpace, redColor);
    }
}

- (BOOL) loadArea:(NSString*)areaID
        numPoints:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)pnPointsInLoop
           points:(LPDPOINT)pPoints
          nCounts:(int)nCount
{
    BOOL rtn = NO;

    if (nPoints > 0)
    {
        _nCounts = nCount;
        switch (_loadPass)
        {
            case 0:
            {
                if (!_numAreas)
                    _areaInfo = [[NSMutableArray alloc]init];
                dbounds bounds = getAreaBounds (nPoints,pPoints);
                AddMinMaxD (&_fullBounds,&bounds);
                AreaData *ad = [[AreaData alloc]init];
                ad.areaNumber = _numAreas;
                ad.nCounts = nCount;
                ad.areaID = areaID;
                [_areaInfo addObject:ad];
                _numAreas++;
            }
                break;
                
            case 1:
            {
                DPOINT	BeginPoint, LastPoint;
                double	Area=0,Perim=0;
                AreaData *ad = [self findByAreaID:areaID];
                if (!ad)
                    break;
                CGContextBeginPath(_context);
                for (int i = 0; i < nPoints; i++)
                {
                    DPOINT pt = [self projectPointToContext:&pPoints[i] from:0];
                    
                    if (i == 0)
                    {
                        BeginPoint = pt;
                        CGContextMoveToPoint(_context, pt.x, pt.y);
                    }
                    else
                    {
                        CGContextAddLineToPoint(_context, pt.x, pt.y);
                        //Perim += ldistp(LastPoint,*lpDpoints);
                        Area += ( LastPoint.y - pt.y) * (pt.x + LastPoint.x) / 2;
                    }
                    LastPoint = pt;
                }
                //Perim += ldistp(LastPoint,BeginPoint);
                Area += (LastPoint.y - BeginPoint.y) * (BeginPoint.x + LastPoint.x) / 2;
                ad.areaInPixels = fabs (Area);
                
                if (!CGContextIsPathEmpty(_context))
                {
                    COLORDEF cd = ad.colordef;
                    CGColorRef colorRef = CGColorCreate(_colorSpace, (CGFloat*)&cd);
                    //debugMessage ([NSString stringWithFormat:@"colors for %@:%f %f %f %f",ad.areaID,cd.c1,cd.c2,cd.c3,cd.c4].UTF8String);
                    CGContextSetFillColorWithColor(_context, colorRef);
                    CGContextDrawPath(_context, kCGPathFill);
                    CGColorRelease(colorRef);
                    rtn = YES;
                }
                _iArea++;
            }
            case 2:
            {
                
            }
        }
    }
    return rtn;
    
}

- (DPOINT)projectPointToContext:(LPDPOINT)Point
                            from:(int)from
{
    DPOINT pt=*Point;
    return pt;
    
    pt.x = Point->x - _fullBounds.xmn;
    pt.x /= (_fullBounds.xmx - _fullBounds.xmn);
    
    if (from)
        pt.y = Point->y - _fullBounds.ymn;
    
    else
        pt.y = _fullBounds.ymx - Point->y;
    
    pt.y /= (_fullBounds.ymx - _fullBounds.ymn);
    pt.x *= _width;
    pt.y *= _height;
    return pt;
}


- (int)DPointInArea:(DPOINT *)dPointLL
             atTime:(int)itime
           andRefno:(int)refno
         whichCount:(int) icount
              value:(double)val
{
    int rtn = 0;
    
    _totPoints++;
    DPOINT dPoint = TranDPOINTP(dPointLL, _pTranWorldToContext);

    if (!_pointGridSize)
    {
        rtn = [self DPointInArea2:&dPoint
                          atTime:itime
                        andRefno:refno
                      whichCount:icount
                           value:1];
    }
    else
    {
        dPoint.x -= _midxy;
        dPoint.y -= _midxy;
        for (int row = 0;row < _pointGridSize; row++)
        {
            for (int col = 0;col < _pointGridSize; col++)
            {
                int indx = [self pointIndex:row column:col];
                if (_pointGrid[indx])
                {
                    DPOINT dPoint2 = dPoint;
                    dPoint2.x += col;
                    dPoint2.y += row;
                    rtn = [self DPointInArea2:&dPoint2
                                      atTime:itime
                                    andRefno:refno
                                  whichCount:icount
                                        value:_pointGrid[indx]*val];
                    
                }
                
            }
            
        }

    }
    return rtn;
}

- (int)DPointInArea2:(DPOINT *)dPoint
              atTime:(int)itime
            andRefno:(int)refno
          whichCount:(int) icount
               value:(float)val
{
    int numAreasIn = 0;
    int row=-999;
    int col;
    static int ii=1;
    DPOINT pt = *dPoint;
    
    if (pt.x > -0.5 && pt.x < _width - 0.5 &&
        pt.y > -0.5 && pt.y < _height - 0.5)
    {
        row = (pt.y + 0.5);
        col = (pt.x + 0.5);
        
        AreaData *ad = [self getAreaAtLoc:row * _width + col];
        if (ad)
        {
            if (icount)
                ad.count2 = ad.count2 + _compareFactor * val;
            else
                ad.count1 += val;
            ad.maxTime = max (ad.maxTime,itime);
            [self addToTimeLine:ad.areaNumber
                         atTime:itime
                       andRefno:refno
                       forCount:icount];
            numAreasIn++;
        }
    }
    else
        _numOutside++;
    _minTime = min (_minTime,itime);
    return numAreasIn;
}

- (AreaData *)getAreaDataFromID:(NSString *)areaID
{
    NSString * mes = [NSString stringWithFormat:@"Area Info count:%lu search for %@",(unsigned long)_areaInfo.count,areaID];
    //debugMessage (mes.UTF8String);
    for (AreaData *ad in _areaInfo)
    {
        mes = [NSString stringWithFormat:@"%@ count:%f %f %f",ad.areaID,ad.count,ad.count1,ad.count2];
        //debugMessage (mes.UTF8String);
        if ([ad.areaID isEqualToString:areaID])
            return ad;
    }
    
    return nil;
}

- (double)countForArea:(NSString*)areaID
            whichCount:(int) icount
{
    double rtn = -1;
    AreaData *ad = [self getAreaDataFromID:areaID];
    if (ad)
    {
        switch (icount)
        {
            case 0:
                rtn = ad.count;
                break;
            case 1:
                rtn = ad.count1;
                break;
            case 2:
                rtn = ad.count2;
                break;
        }
    }
    //else
        //debugMessage (areaID.UTF8String);
    return rtn;
}

- (NSString *) overdueTextForArea:(NSString *)areaID
{
    NSString * text = @"";
    AreaData *ad = [self getAreaDataFromID:areaID];
    if (ad && ad.count)
    {
        double hoursSinceLast = (_currentTime - ad.maxTime) / 3600.0;
        text = [NSString stringWithFormat:@"%.0f\n%.1f ave days\n%.1f days since last\n%.1f incidents",ad.count,ad.aveHoursBetweenIncident/24, hoursSinceLast/24,ad.count1];
    }
    return text;
}

- (CGColorRef)colorForArea:(NSString*)areaID
{
    CGColorRef cref = 0;
    for (AreaData *ad in _areaInfo)
    {
        if ([ad.areaID isEqualToString:areaID])
        {
            cref = ad.displayColor;
            break;
        }
    }
    return cref;
}
-(AreaData *) findByAreaID:(NSString*)areaID
{
    for (AreaData *ad in _areaInfo)
    {
        if ([ad.areaID isEqualToString:areaID])
        {
            return ad;
        }
    }
    return 0;
}

@end
