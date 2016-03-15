//
//  PointInAreas.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 1/1/16.
//  Copyright © 2016 GSSi. All rights reserved.
//


#import "CRAPI.h"
#import "MathUtil.h"

#import "PointInAreas.h"
#import "PointInArea.h"
#import "CensusData.h"

@interface AreaData : NSObject
@property NSString * areaID;
@property CGFloat colorDef;
@property int color;
@property double count;
@property double areaInPixels;
@property CGColorRef displayColor;
@end

@implementation AreaData
@end

@implementation PointInAreas

- (void) releaseMem
{
    for (AreaData *ad in _areaInfo)
    {
        CGColorRelease(ad.displayColor);
    }
    if (_bitmapData)
        free (_bitmapData);
    
    if (_context)
        CGContextRelease(_context);
    
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
- (void) areasLoaded
{
    void *bmData = NULL;

    switch (_loadPass)
    {
        case 0:
        {
            CGRect rect;
            _iArea = 0;
            [self releaseMem];
            _colorSpace = CGColorSpaceCreateDeviceGray();
            if (!_maxDimension)
                _maxDimension = 2048;
            _width = _maxDimension;
            _height = _maxDimension;
            CGFloat wb = BoundsWidth (&_fullBounds);
            CGFloat hb = BoundsHeight (&_fullBounds);
            
            if (wb > 0 && wb > hb)
                _height *= hb / wb;
            else if (hb > 0)
                _width *= wb / hb;
            _height += _height % 4;
            _width += _width % 4;
            _context = createBitmapContext(_width, _height, _colorSpace, &bmData);
            _bitmapData = bmData;
            CGContextSetAllowsAntialiasing(_context, NO);
            CGContextSetShouldAntialias(_context, NO);
            rect = CGRectMake(0, 0,  _width,_height);
            for (AreaData *ad in _areaInfo)
            {
                ad.colorDef = ++_iArea/(CGFloat)(_numAreas+1);
                CGFloat color[2] = {ad.colorDef, 1};
                CGColorRef colorRef = CGColorCreate(_colorSpace, color);
                CGContextSetFillColorWithColor(_context, colorRef);
                CGContextFillRect(_context,rect);
                CGColorRelease(colorRef);
                int bitmapValue = (unsigned int)_bitmapData[4 * _width + 4];
                ad.color = bitmapValue;
            }
            CGFloat border[2] = {1, 1};
            CGColorRef borderRef = CGColorCreate(_colorSpace, border);
            CGContextSetFillColorWithColor(_context, borderRef);
            rect = CGRectMake(0, 0, _width,_height);
            CGContextFillRect(_context,rect);
            CGColorRelease(borderRef);
            _borderColor = (unsigned int)_bitmapData[4 * _width + 4];
            CGFloat black[2] = {0, 1};
            CGColorRef blackRef = CGColorCreate(_colorSpace, black);
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

-(void) adjustCounts
{
    if (_adjustValue)
    {
        CensusData *cend = [[CensusData alloc]init];
        for (AreaData *ad in _areaInfo)
        {
            NSString * value = [cend value:_adjustValue
                               forAreaType:_areaType
                                   withKey:ad.areaID];
        }
    }
}

- (void)createDisplayColors
{
    
    NSInteger maxCount = 0;
    
    [self adjustCounts];
    for (AreaData *ad in _areaInfo)
    {
        maxCount = max (maxCount,ad.count);
    }
    for (AreaData *ad in _areaInfo)
    {
        CGFloat clr = 0;
        if (maxCount)
            clr = 1.0 - ad.count/maxCount;
        CGFloat color[2] = {clr, 0.7};
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
        case 0:
        {
            if (!_numAreas)
                _areaInfo = [[NSMutableArray alloc]init];
            dbounds bounds = getAreaBounds (nPoints,pPoints);
            AddMinMaxD (&_fullBounds,&bounds);
            AreaData *ad = [[AreaData alloc]init];
            ad.areaID = areaID;
            [_areaInfo addObject:ad];
            _numAreas++;
        }
            break;
            
        case 1:
        {
            CGPoint	BeginPoint, LastPoint;
            double	Area=0,Perim=0;
            AreaData *ad = [self findByAreaID:areaID];
            if (!ad)
                break;
            CGContextBeginPath(_context);
            for (int i = 0; i < nPoints; i++)
            {
                CGPoint pt = [self projectPointToContext:&pPoints[i] from:0];
                
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
                CGFloat color[2] = {ad.colorDef, 1};
                CGColorRef colorRef = CGColorCreate(_colorSpace, color);
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
    return rtn;
    
}

- (CGPoint)projectPointToContext:(LPDPOINT)Point
                            from:(int)from
{
    CGPoint pt = CGPointZero;
    
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
    CGPoint pt = [self projectPointToContext:dPoint
                                        from:ii];
    
    if (pt.x > -0.5 && pt.x < _width - 0.5 &&
        pt.y > -0.5 && pt.y < _height - 0.5)
    {
        row = (pt.y + 0.5);
        col = (pt.x + 0.5);
        bitmapValue = (unsigned int)_bitmapData[row * _width + col];
        
        if (bitmapValue)
        {
           if (bitmapValue == _borderColor)
           {
               
           }
           else
               for (AreaData *ad in _areaInfo)
               {
                   if (bitmapValue == ad.color)
                   {
                       ad.count++;
                       numAreasIn++;
                       break;
                   }
               }
            return numAreasIn;
        }
        else
            _numOutside++;
    }
    
    return numAreasIn;
}

- (double)countForArea:(NSString*)areaID
{
    double rtn = -1;
    for (AreaData *ad in _areaInfo)
    {
        if ([ad.areaID isEqualToString:areaID])
        {
            rtn = ad.count;
            if (_adjustValue)
            {
                
            }
            break;
        }
    }
    return rtn;
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