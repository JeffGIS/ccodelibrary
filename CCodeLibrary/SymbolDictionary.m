//  SymbolDictionary.m
//  GMMobile

#import "SymbolDictionary.h"
#import "shr.h"
#import "MathUtil.h"

static double Adjust (double sym,double loc, double size)
{
    double adjusted = sym * size + loc;
    return adjusted;
}

@implementation SymbolDictionary

static DPOINT Cross[]={-2.5,1,-5,4,-4,5,-1,2.5,1,2.5,4,5,5,4,2.5,1,2.5,-1,5,-4,4,-5,1,-2.5,-1,-2.5,-4,-5,-5,-4,-2.5,-1,-2.5,1};
static DPOINT Plus[]={-2,2,-2,5,2,5,2,2,5,2,5,-2,2,-2,2,-5,-2,-5,-2,-2,-5,-2,-5,2,-2,2};
static DPOINT Diamond[]={-5,0,0,5,5,0,0,-5,-5,0};
static DPOINT Triangle[]={-5,-5,0,5,5,-5,-5,-5};
static DPOINT Star1[]={-5,0,-1.5,1.5,0,5,1.5,1.5,5,0,1.5,-1.5,0,-5,-1.5,-1.5,-5,0};
static DPOINT Star2[]={0,5,1.1,1.3,5,1.3,1.9,-1.1,3,-5,0,-2.6,-3,-5,-2,-1.1,-5,1.3,-1.1,1.3,0,5};
static DPOINT Square[]={-5,5,5,5,5,-5,-5,-5,-5,5};
static DPOINT Splash[]={-4.4,-1.6,-1.4,.7,-2.1,3.3,-.3,1.4,1.3,4.4,.9,.8,4.0,.7,.7,-.7,1.2,-4.0,-.4,-1.5,-2.0,-3.4,-1.6,-.9,-4.4,-1.6};

+ (NSArray<DPoint *> *)symbolDefForType:(PointSymbols)type
{
    NSMutableArray<DPoint *> *symbolDef = NSMutableArray.array;
    
    switch (type)
    {
        case CrossSym:
            for (int i = 0; i < (sizeof(Cross) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Cross[i]];
                [symbolDef addObject:point];
            }
            break;
        case PlusSym:
            for (int i = 0; i < (sizeof(Plus) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Plus[i]];
                [symbolDef addObject:point];
            }
            break;
        case DiamondSym:
            for (int i = 0; i < (sizeof(Diamond) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Diamond[i]];
                [symbolDef addObject:point];
            }
            break;
        case TriangleSym:
            for (int i = 0; i < (sizeof(Triangle) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Triangle[i]];
                [symbolDef addObject:point];
            }
            break;
        default:
        case SquareSym:
            for (int i = 0; i < (sizeof(Square) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Square[i]];
                [symbolDef addObject:point];
            }
            break;
        case Star1Sym:
            for (int i = 0; i < (sizeof(Star1) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Star1[i]];;
                [symbolDef addObject:point];
            }
            break;
        case Star2Sym:
            for (int i = 0; i < (sizeof(Star2) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Star2[i]];
                [symbolDef addObject:point];
            }
            break;
        case ArsonSym:
            for (int i = 0; i < (sizeof(Splash) / sizeof(DPOINT)); i++)
            {
                DPoint *point = [DPoint fromDPOINT:&Splash[i]];
                [symbolDef addObject:point];
            }
            break;
    }
    
    return symbolDef.copy;
}

+ (void)drawPointWithSymbol:(CGContextRef)context
                         at:(LPDPOINT)pt
                usingSymbol:(PointSymbols)sym
                       Size:(CGFloat)size
                  fillColor:(CGColorRef)fcolor
                  lineColor:(CGColorRef)lcolor
                  lineWidth:(CGFloat)lwidth
{
    BOOL dispersed = FALSE;
    static int ii=1;
    CGFloat screenScale = 1;//[[UIScreen mainScreen] scale];
    UIImage * symImage=nil;
    CGRect imageRect;
    
    size *= screenScale;
    CGFloat origSize = size;
    if (lwidth < 0)
    {
        dispersed = TRUE;
        lwidth = -lwidth;
    }
    if (size < 30)
        dispersed = FALSE;
    if (size < 60)
        lwidth = 1;
    
    switch (sym)
    {
        BusSym:
            imageRect = CGRectMake(pt->x, pt->y, size, size);
            symImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"BusSymbol"
                                                                                      ofType:@"png"]];
            CGContextDrawImage(context, imageRect, symImage.CGImage);

            break;
        default:
            break;
    }
   CGContextSetFillColorWithColor(context,fcolor);
    
    if (sym == CircleSym)
    {
        size *= 0.75;
        CGRect pointRect = CGRectMake((pt->x - size / 2.0),
                                      (pt->y - size / 2.0), size, size);

        CGContextFillEllipseInRect(context, pointRect);
        /*if (dispersed)
        {
            CGContextSetLineWidth(context, lwidth*4);
            CGContextSetStrokeColorWithColor(context,UIColor.whiteColor.CGColor);
            CGContextStrokeEllipseInRect(context, pointRect);
        }*/
        CGContextSetLineWidth(context, lwidth);
        CGContextSetStrokeColorWithColor(context,lcolor);
        CGContextStrokeEllipseInRect(context, pointRect);
    }
    else
    {
        LPDPOINT pPoints;
        int nPt;
        size *= 0.1;
        CGFloat yinc = 0;
        
        switch (sym)
        {
            case CrossSym:
                pPoints = Cross;
                nPt = sizeof (Cross)/sizeof(DPOINT);
                break;
            case PlusSym:
                pPoints = Plus;
                nPt = sizeof (Plus)/sizeof(DPOINT);
                break;
            case DiamondSym:
                pPoints = Diamond;
                nPt = sizeof (Diamond)/sizeof(DPOINT);
                size *= 0.8;
                break;
            case TriangleSym:
                //yinc = 14;
                pPoints = Triangle;
                nPt = sizeof (Triangle)/sizeof(DPOINT);
                size *= 0.8;
                break;
            default:
            case SquareSym:
                pPoints = Square;
                nPt = sizeof (Square)/sizeof(DPOINT);
                size *= 0.7;
                break;
            case Star1Sym:
                pPoints = Star1;
                nPt = sizeof (Star1)/sizeof(DPOINT);
                break;
            case Star2Sym:
                //yinc = 7;
                pPoints = Star2;
                nPt = sizeof (Star2)/sizeof(DPOINT);
                break;
            case ArsonSym:
                size *= 1.2;
                pPoints = Splash;
                nPt = sizeof (Splash)/sizeof(DPOINT);
                break;
        }
        
        CGContextMoveToPoint(context, Adjust(pPoints[0].x,pt->x,size), Adjust(pPoints[0].y,pt->y+yinc*ii,size));
        
        for (int i = 1; i < nPt; i++)
        {
            CGContextAddLineToPoint(context, Adjust(pPoints[i].x,pt->x,size),Adjust(pPoints[i].y,pt->y+yinc*ii,size));
            
        }
        
        if (!CGContextIsPathEmpty(context))
        {
            /*if (dispersed)
            {
                CGPathRef path = CGContextCopyPath(context);
                CGContextFillPath(context);
                CGContextAddPath(context, path);
                CGContextSetLineWidth(context, lwidth*4);
                CGContextSetStrokeColorWithColor(context,UIColor.whiteColor.CGColor);
                CGContextStrokePath(context);
                CGContextAddPath(context, path);
                CGContextSetLineWidth(context, lwidth);
                CGContextSetStrokeColorWithColor(context,lcolor);
                CGContextStrokePath(context);
            }
            else*/
            {
                CGContextSetLineWidth(context, lwidth);
                CGContextSetStrokeColorWithColor(context,lcolor);
                CGContextDrawPath(context, kCGPathEOFillStroke);
            }
        }
    }
    if (dispersed)
    {
        size = origSize * 0.25;
        CGRect pointRect = CGRectMake((pt->x - size),
                                      (pt->y - size), size*2, size*2);
        CGFloat az = getazdp(pt, &pt[1]);
        DPOINT ptOnCircle = dnewpoint(pt,az,size);
        CGPoint points[2];
        points[0].x = pt->x;
        points[0].y = pt->y;
        points[1].x = ptOnCircle.x;
        points[1].y = ptOnCircle.y;
        size *= 0.06;
        CGContextSetLineWidth(context, 3*size);
        CGContextSetStrokeColorWithColor(context,UIColor.whiteColor.CGColor);
        CGContextStrokeEllipseInRect(context, pointRect);
        CGContextStrokeLineSegments(context, points,2);
        CGContextSetLineWidth(context, size);
        CGContextSetStrokeColorWithColor(context,UIColor.blackColor.CGColor);
        CGContextStrokeEllipseInRect(context, pointRect);
        CGContextStrokeLineSegments(context, points,2);
    }
}

UIImage *imageFromSymbol(PointSymbols sym, CGFloat size, UIColor *symColor)
{
    UIImage *image = nil;
    
    CGRect rect = CGRectMake(0.0, 0.0, size, size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context,symColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context,UIColor.blackColor.CGColor);
    
    size -= 4.0;
    
    if (sym == CircleSym)
    {
        CGContextFillEllipseInRect(context, CGRectMake(2.0, 2.0, size, size));
        CGContextStrokeEllipseInRect(context, CGRectMake(2.0, 2.0, size, size));
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    else
    {
        LPDPOINT pPoints = NULL;
        int nPt = 0;
        size *= 0.1;
        
        switch (sym)
        {
            case CrossSym:
                pPoints = Cross;
                nPt = (sizeof(Cross) / sizeof(DPOINT));
                break;
            case PlusSym:
                pPoints = Plus;
                nPt = (sizeof(Plus) / sizeof(DPOINT));
                break;
            case DiamondSym:
                pPoints = Diamond;
                nPt = (sizeof(Diamond) / sizeof(DPOINT));
                break;
            case TriangleSym:
                pPoints = Triangle;
                nPt = (sizeof(Triangle) / sizeof(DPOINT));
                break;
            default:
            case SquareSym:
                pPoints = Square;
                nPt = (sizeof(Square) / sizeof(DPOINT));
                break;
            case Star1Sym:
                pPoints = Star1;
                nPt = (sizeof(Star1) / sizeof(DPOINT));
                break;
            case Star2Sym:
                pPoints = Star2;
                nPt = (sizeof(Star2) / sizeof(DPOINT));
                break;
            case ArsonSym:
                pPoints = Splash;
                nPt = (sizeof(Splash) / sizeof(DPOINT));
                break;
        }
        
        CGContextMoveToPoint(context, Adjust(-pPoints[0].x, ((size * 5.0) + 2.0), size),
                             Adjust(-pPoints[0].y, ((size * 5.0) + 2.0), size));
        
        for (int i = 1; i < nPt; i++)
        {
            CGContextAddLineToPoint(context, Adjust(-pPoints[i].x, ((size * 5.0) + 2.0), size),
                                    Adjust(-pPoints[i].y, ((size * 5.0) + 2.0), size));
        }
        
        if (!CGContextIsPathEmpty(context))
        {
            CGContextDrawPath(context, kCGPathEOFillStroke);
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
    }
    
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)polygonSymbolFillColor:(PolygonSymbols)symbol
{
    UIColor *rtn = UIColor.whiteColor;
    
    switch (symbol)
    {
        case Red50PCTPolygon:
            rtn = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
            break;
        case Green50PCTPolygon:
            rtn = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
            break;
        case Blue50PCTPolygon:
            rtn = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
            break;
        case Yellow50PCTPolygon:
            rtn = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5];
            break;
        case Grey50PCTPolygon:
            rtn = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
            break;
        default:break;
    }
    
    return rtn;
}

+ (UIColor *)polylineStrokeColor:(PolylineSymbols)symbol
                       lineWidth:(CGFloat *)lineWidth
{
    UIColor *rtn = UIColor.whiteColor;
    
    switch (symbol)
    {
        case NoPolylineSym:
            rtn = [UIColor colorWithWhite:0.0 alpha:0.5];
            *lineWidth = 3.0;
            break;
        case BlueWidth3Polyline:
            rtn = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
            *lineWidth = 3.0;
            break;
        case RedWidth3Polyline:
            rtn = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
            *lineWidth = 3.0;
            break;
        case GreenWidth3Polyline:
            rtn = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
            *lineWidth = 3.0;
            break;
        default:break;
    }
    
    return rtn;
}

+ (UIColor *)polygonSymbolBorderColor:(PolygonSymbols)symbol
{
    return [SymbolDictionary polygonSymbolFillColor:symbol];
}

+ (int)polygonSymbolBorderWidth:(PolygonSymbols)symbol
{
    return 0;
}

@end
