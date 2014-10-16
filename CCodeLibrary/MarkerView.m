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

- (void)drawRect:(CGRect)rect
{
    GMSProjection *projection = self.mapView.projection;
    CGRect pointRect;
    int numComplete = 0;
    int numComplex;
    int totRamps = 0;
    int notAssigned = 0;
    
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
            
            if (!info.assignedTo)
                CGContextSetFillColorWithColor(context, UserDefaults.defaults.appleBlue.CGColor);
            
            else if (!info.status)
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
        [self.delegate setupProgressLabelTextForTotalIntersections:(int)pointsArray.count
                                                         completed:(int)numComplete
                                                           complex:numComplex
                                                          numRamps:totRamps
                                                       notAssigned:notAssigned];
    }
    
    return;
}

- (void)dealloc
{
    int ii=1;
    ii++;
}

@end