//  MarkerView.m
//  CCodeLibrary

#import "MarkerView.h"

@implementation MarkerView

- (id)initWithMapView:(GMSMapView *)mapView
{
    CGRect frame = mapView.frame;
    frame.origin.x = frame.origin.y = 0;
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.mapView = mapView;
    }
    
    return self;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat comps[] = {r, g, b, a};
	CGColorRef color = CGColorCreate(rgb, comps);
	CGColorSpaceRelease(rgb);
	return color;
}

CGColorRef graphYColor()
{
	static CGColorRef c = NULL;
    
	if(c == NULL)
        c = CreateDeviceRGBColor(0.0, 1.0, 0.0, 1.0);
    
	return c;
}

- (BOOL)demoComplete:(IntersectionPoint *)pt
{
    if (_tempDemoArray)
    {
        int nSkip = (int)(_tempDemoArray.count / 5);
        double minDist=DBL_MAX;
        
        for (int i = 0; i < _tempDemoArray.count; i += nSkip)
        {
            IntersectionPoint *buildingPt = [_tempDemoArray objectAtIndex:i];
            double dist = LDIST(pt.longitude, pt.latitude, buildingPt.longitude, buildingPt.latitude);
            
            if (dist < minDist)
                minDist = dist;
        }
        
        if (minDist < 0.015)
            return YES;
    }
    
    return NO;
}

- (void)drawRect:(CGRect)rect
{
    GMSProjection *projection = self.mapView.projection;
    CGRect pointRect;
    int numComplete = 0;
    int numComplex;
    int totRamps = 0;
    
    CGFloat zoom = self.mapView.camera.zoom;
    CGFloat maxZoom = self.mapView.maxZoom;
    CGFloat maxSize = 60.0;
    CGFloat size;
    CGContextRef context = UIGraphicsGetCurrentContext();
    size =  maxSize / (1.0 + maxZoom - zoom);
    
    IBOUNDS bounds21 = [CRAPI.sharedInstance boundsFromRect:self.bounds
                                                     atZoom:21
                                            usingProjection:projection];
    
    NSArray *pointsArray = [_database getIntersectionPointsFromDatabaseinBounds:bounds21];
    
    for (int i = 0; i < pointsArray.count; i++)
    {
        IntersectionPoint *info = (IntersectionPoint *)pointsArray[i];
        CLLocationCoordinate2D latlon;
        latlon.latitude = info.latitude;
        latlon.longitude = info.longitude;
        CGPoint pt = [projection pointForCoordinate:latlon];
        
        if ((pt.x > - size) && (pt.x < (self.mapView.frame.size.width + size) &&
                                        (pt.y > - size) && (pt.y < self.mapView.frame.size.height + size)))
        {
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
            totRamps += info.nramps;
            
            if (!info.status)
                CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
            
            else if (info.status == INT_STATUS_PRELIMCOMPLETE)
            {
                numComplete++;
                CGContextSetFillColorWithColor(context, UserDefaults.defaults.darkGreen.CGColor);
            }
            
            else if (info.status == INT_STATUS_COMPLEX)
            {
                numComplex++;
                CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
            }
            
            pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
            CGContextSetLineWidth(context, (size / 12.0));
            CGContextFillEllipseInRect(context, pointRect);
            CGContextStrokeEllipseInRect(context, pointRect);
            CGContextFillPath(context);
        }
    }
    
    if (self.delegate)
    {
        [self.delegate setupProgressLabelTextForTotalIntersections:(int)pointsArray.count
                                                         completed:(int)numComplete
                                                        complex:numComplex
                                                          numRamps:totRamps
                                                       notAssigned:0];
    }
    
    return;
}

@end