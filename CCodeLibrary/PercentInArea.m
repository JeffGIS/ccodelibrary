//
//  PercentInArea.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 4/3/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#define MINAREAPCT 0.0

#import "PercentInArea.h"
#import "CRAPI.h"
#import "shr.h"
#import "MathUtil.h"

#import "CensusData.h"

typedef struct {CGFloat c1,c2,c3,c4;} COLORDEF;

@interface PctInAreaData : NSObject
@property NSString * areaID;
@property COLORDEF colordef;
@property int icolor;
@property double count;
@property double areaInPixels;
@property int pixelsInMask;
@property float pctInMask;
@property double value;
@property double valuePerPixel;
@property CGColorRef displayColor;
@end

@implementation PctInAreaData
@end

@implementation PercentInArea

static int ii;

- (void) releaseMem
{
    for (PctInAreaData *ad in _areaInfo)
    {
        CGColorRelease(ad.displayColor);
    }
    if (_bitmapData)
        free (_bitmapData);
    
    if (_context)
        CGContextRelease(_context);
    CloseTRANS2P(&_pTranContextToWorld);
    
    if (_colorSpace)
        CGColorSpaceRelease(_colorSpace);
    
}
- (id)init
{
    self = [super init];
    
    if (self)
    {
        InitDBounds (&_fullBounds);
    }
    
    return self;
}

- (void)dealloc
{
    [self releaseMem];
}

- (void)setColor:(int)iColor
        areaData:(PctInAreaData *)ad
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
        
        LPLONG pInt = (LPLONG)&bcolor;
        *pInt = iColor;
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
    
    _pTranContextToWorld = STRANBoundsToBoundsP(&outb, &llBounds);
}

- (void) areasLoaded:(PercentInArea*)boundsPias
         convertToLL:(LPTRANDATA)pTranViewToLL
{
    void *bmData = NULL;
    COLORDEF cd;
    
    switch (_loadPass)
    {
        case 0:
        {
            CGRect rect;
            _iArea = 0;
            [self releaseMem];
            _colorSpace = CGColorSpaceCreateDeviceRGB();
            if (!_maxDimension)
                _maxDimension = 2048;
            _width = _maxDimension;
            _height = _maxDimension;
            if (boundsPias)
                _fullBounds = boundsPias.fullBounds;
            CGFloat wb = BoundsWidth (&_fullBounds);
            CGFloat hb = BoundsHeight (&_fullBounds);
            
            if (wb > 0 && wb > hb)
                _height *= hb / wb;
            else if (hb > 0)
                _width *= wb / hb;
            _height += _height % 4;
            _width += _width % 4;
            [self setContextTran:pTranViewToLL];
            _context = createBitmapContext(-_width, _height, _colorSpace, &bmData);
            _bytesPerRow = (int)CGBitmapContextGetBytesPerRow(_context);
            _nColorComponents = (int)CGColorSpaceGetNumberOfComponents(_colorSpace);
            if (_nColorComponents == 3)
                _nColorBytes = 4;
            else
                _nColorBytes = 1;
            _bitmapData = bmData;
            CGContextSetAllowsAntialiasing(_context, NO);
            CGContextSetShouldAntialias(_context, NO);
            rect = CGRectMake(0, 0,  _width,_height);
            for (PctInAreaData *ad in _areaInfo)
            {
                [self setColor:++_iArea
                      areaData:ad];
                cd = ad.colordef;
                CGColorRef colorRef = CGColorCreate(_colorSpace, (CGFloat*)&cd);
                CGContextSetFillColorWithColor(_context, colorRef);
                CGContextFillRect(_context,rect);
                CGColorRelease(colorRef);
                unsigned int bitmapValue;
                if (_nColorBytes > 1)
                {
                    _bitmapData[(4 * _width + 4)*_nColorBytes+3] = 0;
                    bitmapValue = *(unsigned int*)&_bitmapData[(4 * _width + 4)*_nColorBytes];
                    unsigned int bitmapValue1 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes];
                    unsigned int bitmapValue2 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes+1];
                    unsigned int bitmapValue3 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes+2];
                    unsigned int bitmapValue4 = (unsigned int)_bitmapData[(4 * _width + 4)*_nColorBytes+3];
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
        }
            break;
        case 1:
        {
        }
            break;
        case 2:
            break;
    }
    _loadPass++;
}

-(PctInAreaData *) getAreaAtLoc:(int)loc
{
    PctInAreaData * ad = nil;
    int iArea;
    if (_nColorBytes > 1)
    {
        loc *= 4;
        _bitmapData[loc+3] = 0;
        iArea = *(unsigned int*)&_bitmapData[loc];
        unsigned int bitmapValue1 = (unsigned int)_bitmapData[loc];
        unsigned int bitmapValue2 = (unsigned int)_bitmapData[loc+1];
        unsigned int bitmapValue3 = (unsigned int)_bitmapData[loc+2];
        unsigned int bitmapValue4 = (unsigned int)_bitmapData[loc+3];
        ii=1;
    }
    else
        iArea = (unsigned int)_bitmapData[loc];
    if (iArea && iArea <= [_areaInfo count])
        ad = _areaInfo[iArea-1];
    return ad;
}

-(void) adjustCounts:(PercentInArea *)piaTarget
{
    if (_adjustValue)
    {
        CensusData *cend = [[CensusData alloc]init];
        BOOL opened = [cend open];
        for (PctInAreaData *ad in _areaInfo)
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
                PctInAreaData *adTarget = [piaTarget getAreaAtLoc:loc];
                PctInAreaData *adAdjust = [self getAreaAtLoc:loc];
                if (adTarget && adAdjust)
                {
                    adTarget.value += adAdjust.valuePerPixel;
                }
                
            }
        }
    }
}

- (void)createDisplayColors:(PercentInArea*)piasAdjust
                       mask:(PointInArea*)piaMask
{
    
    CGFloat maxCount = 0;
    CGFloat maxValue = 0;
    
    if (piasAdjust)
        [piasAdjust adjustCounts:self];
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
                PctInAreaData *adTarget = [self getAreaAtLoc:loc];
                if (adTarget)
                    adTarget.pixelsInMask++;
            }
        }
    }
    for (PctInAreaData *ad in _areaInfo)
    {
        if (ad.value)
            ad.count /= ad.value;
        else
            ii=1;
        ad.pctInMask = 100.0 * ad.pixelsInMask / ad.areaInPixels;
        if (ad.pctInMask >= MINAREAPCT)
        {
            maxCount = max (maxCount,ad.count);
            maxValue = max (maxValue,ad.value);
        }
    }
    for (PctInAreaData *ad in _areaInfo)
    {
        CGFloat clr = 1;
        CGFloat alpha = 0.7;
        if (ad.pctInMask >= MINAREAPCT)
        {
            if (maxCount)
                clr = 1.0 - ad.count/maxCount;
        }
        else
            alpha = 0;
        CGFloat color[4] = {clr,clr,clr, alpha};
        ad.displayColor = CGColorCreate(_colorSpace, color);
    }
    
}

- (BOOL) loadArea:(NSString*)areaID
        numPoints:(int)nPoints
         numLoops:(int)nLoops
      polyPartLen:(int*)pnPointsInLoop
           points:(LPDPOINT)pPoints
{
    BOOL rtn = NO;
    
    switch (_loadPass)
    {
        case 0:{
            if (!_numAreas)
                _areaInfo = [[NSMutableArray alloc]init];
            dbounds bounds = getAreaBounds (nPoints,pPoints);
            AddMinMaxD (&_fullBounds,&bounds);
            PctInAreaData *ad = [[PctInAreaData alloc]init];
            ad.areaID = areaID;
            [_areaInfo addObject:ad];
            _numAreas++;
            break;}
        case 1:{
            DPOINT beginPoint = {0}, lastPoint = {0};
            double area = 0.0;
            //double perim = 0.0;
            PctInAreaData *ad = [self findByAreaID:areaID];
            
            if (!ad)
                break;
            
            CGContextBeginPath(_context);
            
            for (int i = 0; i < nPoints; i++)
            {
                DPOINT pt = [self projectPointToContext:&pPoints[i] from:0];
                
                if (i == 0)
                {
                    beginPoint = pt;
                    CGContextMoveToPoint(_context, pt.x, pt.y);
                }
                
                else
                {
                    CGContextAddLineToPoint(_context, pt.x, pt.y);
                    //perim += ldistp(lastPoint,*lpDpoints);
                    area += (lastPoint.y - pt.y) * (pt.x + lastPoint.x) / 2;
                }
                
                lastPoint = pt;
            }
            
            //perim += ldistp(lastPoint, beginPoint);
            area += (lastPoint.y - beginPoint.y) * (beginPoint.x + lastPoint.x) / 2;
            ad.areaInPixels = fabs (area);
            
            if (!CGContextIsPathEmpty(_context))
            {
                COLORDEF cd = ad.colordef;
                CGColorRef colorRef = CGColorCreate(_colorSpace, (CGFloat*)&cd);
                CGContextSetFillColorWithColor(_context, colorRef);
                CGContextDrawPath(_context, kCGPathFill);
                CGColorRelease(colorRef);
                rtn = YES;
            }
            
            _iArea++;
            break;}
        case 2:{
            break;}
        default:break;
    }
    
    return rtn;
}

- (DPOINT)projectPointToContext:(LPDPOINT)Point
                           from:(int)from
{
    DPOINT pt;
    
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


- (int)DPointInArea:(DPOINT *)dPoint
{
    int numAreasIn = 0;
    int row=-999;
    int col;
    int bitmapValue;
    static int ii=1;
    DPOINT pt = [self projectPointToContext:dPoint
                                       from:ii];
    
    if (pt.x > -0.5 && pt.x < _width - 0.5 &&
        pt.y > -0.5 && pt.y < _height - 0.5)
    {
        row = (pt.y + 0.5);
        col = (pt.x + 0.5);
        
        PctInAreaData *ad = [self getAreaAtLoc:row * _width + col];
        if (ad)
        {
            ad.count++;
            numAreasIn++;
        }
    }
    else
        _numOutside++;
    
    return numAreasIn;
}

- (double)countForArea:(NSString*)areaID
{
    double rtn = -1;
    for (PctInAreaData *ad in _areaInfo)
    {
        if ([ad.areaID isEqualToString:areaID])
        {
            rtn = ad.count;
            break;
        }
    }
    return rtn;
}
- (CGColorRef)colorForArea:(NSString*)areaID
{
    CGColorRef cref = 0;
    for (PctInAreaData *ad in _areaInfo)
    {
        if ([ad.areaID isEqualToString:areaID])
        {
            cref = ad.displayColor;
            break;
        }
    }
    return cref;
}
-(PctInAreaData *) findByAreaID:(NSString*)areaID
{
    for (PctInAreaData *ad in _areaInfo)
    {
        if ([ad.areaID isEqualToString:areaID])
        {
            return ad;
        }
    }
    return 0;
}

@end
