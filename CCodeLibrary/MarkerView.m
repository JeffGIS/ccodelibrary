//  MarkerView.m
//  CCodeLibrary

#import "MarkerView.h"
#import "MathUtil.h"
#import "UserDefaults.h"

#define COORDINATE_MULTIPLIER 10000000.0
#define MAX_AREA_POINTS 85000

@implementation MarkerView
{
    UIColor *_blue;
}

- (id)initWithMapView:(GMSMapView *)mapView
             areaFile:(NSString *)areaFile
{
    CGRect frame = mapView.frame;
    frame.origin.x = frame.origin.y = 0;
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.opaque = NO;
        self.backgroundColor = UIColor.clearColor;
        self.mapView = mapView;
        self.projection = mapView.projection;
        self.areaFile = areaFile;
        _blue = UserDefaults.defaults.appleBlue;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect pointRect;
    int numComplete = 0, numComplex = 0, totRamps = 0, totIntersections = 0, notAssigned = 0;
    int module = CRAPI.sharedInstance.currentModule;

    CGFloat zoom = self.mapView.camera.zoom;
    CGFloat maxZoom = self.mapView.maxZoom;
    CGFloat maxSize = 60.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self maskCityBoundsInContext:context];
    
    CGFloat size =  maxSize / (1.0 + maxZoom - zoom);
    
    IBOUNDS bounds21;
    
    /*= [CRAPI.sharedInstance boundsFromRect:self.bounds
                                                     atZoom:21
                                            usingProjection:_projection];*/
    
    if (_database)
    {
        NSArray *pointsArray = [_database getIntersectionPointsFromDatabaseinBounds:bounds21];
        
        for (int i = 0; i < pointsArray.count; i++)
        {
            IntersectionPoint *info = (IntersectionPoint *)pointsArray[i];
            CLLocationCoordinate2D latlon;
            latlon.latitude = info.latitude;
            latlon.longitude = info.longitude;
            CGPoint pt = [_projection pointForCoordinate:latlon];
            
            if ((pt.x > - size) && (pt.x < (self.mapView.frame.size.width + size) &&
                                            (pt.y > - size) && (pt.y < self.mapView.frame.size.height + size)))
            {
                if (!info.nramps && self.showOnlyIntersectionsWithRamps)
                    continue;
                
                totIntersections++;
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
                CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
                totRamps += info.nramps;
                
                if (!info.assignedTo)
                    CGContextSetFillColorWithColor(context, UserDefaults.defaults.appleBlue.CGColor);
                
                else if ((module == PRELIM_MODULE && !info.status) || (module == MANAGEMENT_MODULE) ||
                         (module == DETAIL_MODULE && info.status == IntStatusPrelimComplete))
                {
                    CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                }
                
                else if ((module == PRELIM_MODULE && info.status == IntStatusPrelimComplete) ||
                         (module == DETAIL_MODULE && info.status == IntStatusDetailComplete))
                {
                    numComplete++;
                    CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
                }
                
                else if (info.status == IntStatusComplex)
                {
                    numComplex++;
                    CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
                }
                
                if (!info.assignedTo)
                    notAssigned++;
                
                pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
                CGContextSetLineWidth(context, (size / 12.0));
                CGContextFillEllipseInRect(context, pointRect);
                CGContextStrokeEllipseInRect(context, pointRect);
                CGContextFillPath(context);
            }
        }
        
        if (self.delegate)
        {
            [self.delegate setupProgressLabelTextForTotalIntersections:(int)totIntersections
                                                             completed:(int)numComplete
                                                               complex:numComplex
                                                              numRamps:totRamps
                                                           notAssigned:notAssigned];
        }
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
                    CLLocationCoordinate2D llPoint;
                    llPoint.latitude = pPoints[i].y;
                    llPoint.longitude = pPoints[i].x;
                    CGPoint pt = [self.projection pointForCoordinate:llPoint];
                    
                    if (j == 0)
                        CGContextMoveToPoint(context, pt.x, pt.y);
                    
                    else
                        CGContextAddLineToPoint(context, pt.x, pt.y);
                }
                
                if (!CGContextIsPathEmpty(context))
                {
                    CGContextSetLineWidth(context, 3.0);
                    CGContextSetStrokeColorWithColor(context, _blue.CGColor);
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
    CGRect pointRect;
    CGFloat size = 8;
    PointInAreaClass *pia = [[PointInAreaClass alloc] init];
    CLLocationCoordinate2D llPoint;
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
                CGPoint pt = [self.projection pointForCoordinate:llPoint];
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
    FILE *fid = fopen(self.areaFile.UTF8String, "rb");
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    bounds bnds;
    LPDPOINT pPoints;
    
    InitBounds(&bnds);
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
                CGPoint pt = [self.projection pointForCoordinate:llPoint];
                
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

@end