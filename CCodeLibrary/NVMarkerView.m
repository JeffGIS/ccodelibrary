//  NVMarkerView.m
//  CCodeLibrary

#import "NVMarkerView.h"
#import "MathUtil.h"
#import "CRAPI.h"
#import "PointInAreaClass.h"
#import "TileGraphics.h"
#import "RampCompliance.h"

#define COORDINATE_MULTIPLIER 10000000.0
#define MAX_AREA_POINTS 85000

@interface NVMarkerView ()

@property (nonatomic) LPTRANDATA pTranWToBMP, pTranBMPToW;
@property (nonatomic, weak) id <NVMarkerViewDelegate> delegate;

@end

@implementation NVMarkerView

+ (instancetype)markerViewWithAreaFile:(NSString *)areaFile
                              delegate:(id)delegate
{
    NVMarkerView *nvmv = NVMarkerView.new;
    nvmv.delegate = delegate;
    
    CGRect frame = [nvmv.delegate mapViewFrame];
    frame.origin.x = frame.origin.y = 0.0;
    nvmv.frame = frame;
    
    nvmv.opaque = NO;
    nvmv.backgroundColor = UIColor.clearColor;
    nvmv.areaFile = areaFile;
    
    return nvmv;
}
- (id)init
{
    self = [super init];
    
    return self;
}

- (void)dealloc
{
    return;
}

- (void)drawRect:(CGRect)rect
{
#define TYPECIRCLE  1
#define TYPERECTANGLE 2
#define TYPETRIANGLE 3
    CGRect pointRect = CGRectZero;
    int numComplete = 0, numComplex = 0, totRamps = 0, totIntersections = 0, notAssigned = 0, noRamps = 0;
    int module = CRAPI.sharedInstance.currentModule;
    NSMutableArray *totPeriPad = NSMutableArray.new;
    CGFloat zoom = [_delegate currentZoom];
    CGFloat maxZoom = [_delegate maxZoom];
    CGFloat maxSize = 60.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    int *nPeriPad = 0;
    [self maskCityBoundsInContext:context];
    
    CGFloat size =  maxSize / (1.0 + maxZoom - zoom);
    
    IBOUNDS bounds21 = [self boundsFromRect:self.bounds
                                     atZoom:21];
    
    if (_colorsArray && _colorsArray.count > 0)
        nPeriPad = calloc (sizeof(int),_colorsArray.count);
    
    if (_database)
    {
        NSArray *pointsArray = [_database getIntersectionPointsFromDatabaseinBounds:bounds21];
        
        ToleranceValues *tolerances = (ToleranceValues *)malloc(sizeof(ToleranceValues));
        setStandardToleranceValues(tolerances);
        
        for (IntersectionPoint *info in pointsArray)
        {
            int type = TYPECIRCLE;
            CLLocationCoordinate2D latlon = {0};
            latlon.latitude = info.latitude;
            latlon.longitude = info.longitude;
            CGPoint pt = [_delegate getPointForCoordinate:latlon];
            CGRect frame = [_delegate mapViewFrame];
            
            if ((pt.x > - size) && (pt.x < (frame.size.width + size) &&
                                    (pt.y > - size) && (pt.y < frame.size.height + size)))
            {
                if (!info.nramps && _showOnlyIntersectionsWithRamps)
                    continue;
                
                totIntersections++;
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
                CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
                totRamps += info.nramps;
                
                switch (module)
                {
                    case MANAGEMENT_MODULE:
                        switch (_from)
                    {
                        case MMLMFromAssignInt:
                            switch (_mapType)
                        {
                            case MMMapTypePrelim:
                                if (_colorsArray && info.assignedToPrelim < _colorsArray.count)
                                {
                                    int i = info.assignedToPrelim;
                                    UIColor *color = _colorsArray[i];
                                    CGContextSetFillColorWithColor(context, color.CGColor);
                                    nPeriPad[i]++;
                                    
                                    if (!i)
                                        notAssigned++;
                                }
                                
                                break;
                                
                            case MMMapTypeDetail:
                                if (_colorsArray && info.assignedToDetail < _colorsArray.count)
                                {
                                    int i = info.assignedToDetail;
                                    UIColor *color = _colorsArray[i];
                                    CGContextSetFillColorWithColor(context, color.CGColor);
                                    nPeriPad[i]++;
                                    
                                    if (!i)
                                        notAssigned++;
                                }
                                
                                break;
                                
                            default:
                                break;
                        }
                            break;
                            
                        case MMLMFromStatusMap:
                            switch (_mapType)
                        {
                            case MMMapTypePrelim:
                                if (info.status == PreliminarySurveyComplete || info.status == OriginalSurveyComplete)
                                {
                                    numComplete++;
                                    CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                                }
                                
                                else if (!info.assignedToPrelim)
                                {
                                    notAssigned++;
                                    CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                }
                                
                                else
                                    CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                                
                                break;
                                
                            case MMMapTypeDetail:
                                if (info.status == OriginalSurveyComplete)
                                {
                                    numComplete++;
                                    CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                                }
                                
                                else if (!info.assignedToDetail)
                                {
                                    notAssigned++;
                                    CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                }
                                
                                else
                                    CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                                
                                break;
                                
                            case MMMapTypeRampIssues:
                            {
                                if (info.status == OriginalSurveyComplete)
                                {
                                    numComplete++;
                                    
                                    int numProblemRamps = [_database numProblemRamps:info.intID
                                                                          tolerances:tolerances];
                                    
                                    if (numProblemRamps)
                                    {
                                        notAssigned++;
                                        CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                                    }
                                    else
                                        CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                                }
                                
                                else
                                    CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                
                                break;
                            }
                                
                            default:
                                break;
                        }
                            break;
                        case MMLMFromRetrieveData:
                        {
                            if (info.status == OriginalSurveyComplete)
                            {
                                numComplete += info.nPaid;
                                if (info.nramps > info.nPaid)
                                {
                                    CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                                    numComplex += info.nramps - info.nPaid;
                                }
                                else
                                    CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                            }
                            else
                            {
                                CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                notAssigned += info.nramps;
                            }
                            if (info.status == PreliminarySurveyComplete)
                            {
                                type = TYPERECTANGLE;
                                if (!info.nramps)
                                {
                                    CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
                                    noRamps++;
                                }
                            }

                        }
                            
                            break;
                    }
                        break;
                        
                    case PRELIM_MODULE:
                        switch (info.status)
                    {
                        case InitialStatus:
                        case AddedInDetail:
                            if (!info.assignedToPrelim)
                            {
                                CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                notAssigned++;
                            }
                            
                            else if (info.assignedToPrelim == CRAPI.sharedInstance.currentiPadWithinManager)
                                CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                            
                            else
                            {
                                CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                notAssigned++;
                            }
                            
                            break;
                            
                        case PreliminarySurveyComplete:
                        case OriginalSurveyComplete:
                            CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                            numComplete++;
                            break;
                            
                        case ComplexStatus:
                            CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
                            numComplex++;
                            break;
                            
                        default:
                            break;
                    }
                        break;
                        
                    case DETAIL_MODULE:
                        switch (info.status)
                    {
                        case InitialStatus:
                        case AddedInDetail:
                            if (!info.assignedToDetail)
                            {
                                CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                notAssigned++;
                            }
                            
                            else if (info.assignedToDetail == CRAPI.sharedInstance.currentiPadWithinManager)
                                CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                            
                            else
                            {
                                CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                notAssigned++;
                            }
                            
                            break;
                            
                        case PreliminarySurveyComplete:
                            type = TYPERECTANGLE;
                            if (!info.nramps)
                                type = TYPETRIANGLE;
                            if (info.assignedToPrelim == CRAPI.sharedInstance.currentiPadWithinManager)
                                CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                            else
                            {
                                CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
                                notAssigned++;
                            }
                                
                            break;
                            
                        case OriginalSurveyComplete:
                            CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                            numComplete++;
                            break;
                            
                          
                        case IntersectionRebuilt:
                            CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                            break;
                            
                        case ComplexStatus:
                            CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
                            numComplex++;
                            break;
                            
                        default:
                            break;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
                CGContextSetLineWidth(context, (size / 12.0));
                if (type == TYPERECTANGLE)
                {
                    CGContextFillRect(context, pointRect);
                    CGContextStrokeRect(context, pointRect);
                }
                else if (type == TYPETRIANGLE)
                {
                    CGPoint points[3];
                    points[0].x = pointRect.origin.x;
                    points[0].y = pointRect.origin.y + pointRect.size.height;
                    points[1].x = pointRect.origin.x + pointRect.size.width/2;
                    points[1].y = pointRect.origin.y;
                    points[2].x = pointRect.origin.x + pointRect.size.width;
                    points[2].y = pointRect.origin.y + pointRect.size.height;
                    CGContextBeginPath(context);
                    CGContextAddLines(context, points, 3);
                    CGContextClosePath(context);
                    CGContextFillPath(context);
                    CGContextStrokePath(context);
                }
                else
                {
                    CGContextFillEllipseInRect(context, pointRect);
                    CGContextStrokeEllipseInRect(context, pointRect);
                }
                CGContextFillPath(context);
            }
        }
        
        if (_colorsArray && _colorsArray.count > 0)
        {
            for (int i = 0; i< _colorsArray.count; i++)
            {
                NSNumber *num = [NSNumber numberWithInteger:nPeriPad[i]];
                [totPeriPad addObject:num];
            }
        }
        
        [_delegate setupProgressLabelTextForTotalIntersections:(int)totIntersections
                                                     completed:(int)numComplete
                                                       complex:numComplex
                                                intWithNoRamps:(int)noRamps
                                                      numRamps:totRamps
                                                   notAssigned:notAssigned
                                                    totPeriPad:totPeriPad];
        if (nPeriPad)
            free(nPeriPad);
        
        if (tolerances)
            free(tolerances);
    }
    
    return;
}

- (void)drawCityBoundsInContext:(CGContextRef)context
{
    FILE *fid = fopen(self.areaFile.UTF8String,"rb");
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    bounds bnds;
    LPDPOINT pPoints;
    
    InitBounds(&bnds);
    bnds.xmn = -180.0;
    bnds.ymn = 0.0;
    bnds.xmx = 0.0;
    bnds.ymx = 80.0;
    
    if (fid && fread(&nPoints, sizeof(int), 1, fid))
    {
        if (nPoints > 2 && fread(&nLoops, sizeof(int), 1, fid))
        {
            pnPointsInLoop = malloc(nLoops * sizeof(int));
            
            if (nLoops > 1)
                fread(pnPointsInLoop, sizeof(int), nLoops, fid);
            
            else
                *pnPointsInLoop = nPoints;
            
            pPoints = (LPDPOINT)malloc(sizeof(DPOINT)*nPoints);
            
            for (int i = 0; i < nPoints ; i++)
            {
                fread(&ix, sizeof(int), 1, fid);
                fread(&iy, sizeof(int), 1, fid);
                pPoints[i].y = (CGFloat)(iy) / COORDINATE_MULTIPLIER;
                pPoints[i].x = (CGFloat)(ix) / COORDINATE_MULTIPLIER;
            }
            
            int i = 0;
            
            for (int iloop = 0; iloop < nLoops; iloop++)
            {
                for (int j = 0; j < pnPointsInLoop[iloop]; j++ ,i++)
                {
                    if (i < nPoints)
                    {
                        CLLocationCoordinate2D llPoint = {0};
                        llPoint.latitude = pPoints[i].y;
                        llPoint.longitude = pPoints[i].x;
                        CGPoint pt = [_delegate getPointForCoordinate:llPoint];
                        
                        if (j == 0)
                            CGContextMoveToPoint(context, pt.x, pt.y);
                        
                        else
                            CGContextAddLineToPoint(context, pt.x, pt.y);
                    }
                }
                
                if (!CGContextIsPathEmpty(context))
                {
                    CGContextSetLineWidth(context, 3.0);
                    CGContextSetStrokeColorWithColor(context, UserDefaults.defaults.appleBlue.CGColor);
                    CGContextDrawPath(context, kCGPathStroke);
                }
                
                if (iloop)
                    i++;
            }
            
            free(pPoints);
        }
    }
    
    fclose(fid);
    
    if (pnPointsInLoop)
        free(pnPointsInLoop);
    //[self testPIA:context];
}

- (void)testPIA:(CGContextRef)context
{
    CGRect pointRect = CGRectZero;
    CGFloat size = 8.0;
    PointInAreaClass *pia = PointInAreaClass.new;
    CLLocationCoordinate2D llPoint = {0};
    DPOINT p1, p2;
    
    p1.x = pia.bounds.xmn;
    p1.y = pia.bounds.ymn;
    p2.x = pia.bounds.xmx;
    p2.y = pia.bounds.ymx;
    //double d = ArcDistance(p1,p2);
    
    llPoint.latitude = pia.bounds.ymn;
    
    while (llPoint.latitude < pia.bounds.ymx)
    {
        llPoint.longitude = pia.bounds.xmn;
        while (llPoint.longitude <  pia.bounds.xmx)
        {
            DPOINT pt;
            pt.x = llPoint.longitude;
            pt.y = llPoint.latitude;
            
            if ([pia DPointInArea:&pt])
            {
                CGPoint pt = [_delegate getPointForCoordinate:llPoint];
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
                CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
                CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
                CGContextSetLineWidth(context, (size / 12.0));
                CGContextFillEllipseInRect(context, pointRect);
                CGContextStrokeEllipseInRect(context, pointRect);
                CGContextFillPath(context);
            }
            
            llPoint.longitude += (pia.bounds.xmx - pia.bounds.xmn)/100.0;
        }
        
        llPoint.latitude += (pia.bounds.ymx - pia.bounds.ymn)/100.0;
    }
    
}
- (void)maskCityBoundsInContext:(CGContextRef)context
{
    FILE *fid = fopen(_areaFile.UTF8String, "rb");
    int nLoops = 0, nPoints = 0, ix = 0, iy = 0;
    int *pnPointsInLoop = 0;
    MNMXCORD bnds = {0};
    LPDPOINT pPoints = NULL;
    
    InitDBounds(&bnds);
    bnds.xmn = -180.0;
    bnds.ymn = 0.0;
    bnds.xmx = 0.0;
    bnds.ymx = 80.0;
    
    if (fid && fread (&nPoints, sizeof(int), 1, fid))
    {
        if (nPoints > MAX_AREA_POINTS)
        {
            fclose(fid);
            [self drawCityBoundsInContext:context];
            
            return;
        }
        
        if (nPoints > 2 && fread(&nLoops, sizeof(int), 1, fid))
        {
            pnPointsInLoop = malloc(nLoops * sizeof(int));
            
            if (nLoops > 1)
                fread(pnPointsInLoop, sizeof(int), nLoops, fid);
            
            else
                *pnPointsInLoop = nPoints;
            
            pPoints = (LPDPOINT)malloc(sizeof(DPOINT)*nPoints);
            
            for (int i = 0; i < nPoints; i++)
            {
                fread(&ix, sizeof(int), 1, fid);
                fread(&iy, sizeof(int), 1, fid);
                pPoints[i].y = ((CGFloat)(iy) / COORDINATE_MULTIPLIER);
                pPoints[i].x = ((CGFloat)(ix) / COORDINATE_MULTIPLIER);
            }
            
            CreateMask(&pPoints, &nPoints, &bnds);
            CLLocationCoordinate2D llPoint;
            
            for (int i = 0; i < nPoints; i++)
            {
                llPoint.latitude = pPoints[i].y;
                llPoint.longitude = pPoints[i].x;
                CGPoint pt = [_delegate getPointForCoordinate:llPoint];
                
                if (i == 0)
                    CGContextMoveToPoint(context, pt.x, pt.y);
                
                else
                    CGContextAddLineToPoint(context, pt.x, pt.y);
            }
            
            free(pnPointsInLoop);
            free(pPoints);
        }
    }
    
    fclose(fid);
    
    if (!CGContextIsPathEmpty(context))
    {
        CGContextSetFillColorWithColor(context, UserDefaults.defaults.polygonFillColor.CGColor);
        CGContextDrawPath(context, kCGPathFill);
        [self drawCityBoundsInContext:context];
    }
}

- (IPOINT)PointAtZoom:(int)zoom
        fromViewPoint:(CGPoint)pt
{
    IPOINT zoomPt = {0};
    CLLocationCoordinate2D latlon = [_delegate getCoordinateForPoint:pt];
    LatLongToPixelXY(latlon.latitude, latlon.longitude, zoom, &zoomPt.x, &zoomPt.y);
    return zoomPt;
}

- (IBOUNDS)boundsFromRect:(CGRect)rect
                   atZoom:(int)zoom
{
    IBOUNDS iBounds = {0};
    CGPoint pt = CGPointZero;
    IPOINT pt21 = {0};
    
    InitIBounds(&iBounds);
    pt.x = rect.origin.x;
    pt.y = rect.origin.y;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt];
    
    AddPointToIBounds(&iBounds, &pt21);
    pt.x += rect.size.width;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt];
    
    AddPointToIBounds(&iBounds, &pt21);
    pt.y += rect.size.height;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt];
    
    AddPointToIBounds(&iBounds, &pt21);
    pt.x = rect.origin.x;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt];
    
    AddPointToIBounds(&iBounds, &pt21);
    return iBounds;
}

@end
