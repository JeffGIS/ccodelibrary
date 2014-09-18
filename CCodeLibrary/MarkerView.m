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

- (void)drawRect:(CGRect)rect
{
    GMSProjection *projection = self.mapView.projection;
    CGPoint points[2];
    CGRect pointRect;
    
    //UIColor *green = UserDefaults.defaults.darkGreen;
    
    points[0].x = 100;
    points[0].y = 100;
    points[1].x = 300;
    points[1].y = 300;
    
    CGFloat zoom = self.mapView.camera.zoom;
    CGFloat maxSize = 64.0;
    CGFloat size;

    for (int i = 0; i < _pointsArray.count; i++)
    {
        
        IntersectionPoint *info = (IntersectionPoint *)_pointsArray[i];
        CLLocationCoordinate2D latlon;
        latlon.latitude = info.latitude;
        latlon.longitude = info.longitude;
        CGPoint pt = [projection pointForCoordinate:latlon];
        
        if ((pt.x > (0.0 - maxSize)) && (pt.x < (self.mapView.frame.size.width + maxSize) &&
                                         (pt.y > 0.0 - maxSize) && (pt.y < self.mapView.frame.size.height + maxSize)))
        {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
            CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
            
            if (zoom < 13.0)
                size = (maxSize / 16.0);
            
            else if (zoom < 14.0)
                size = (maxSize / 8.0);
            
            else if (zoom < 15.25)
                size = (maxSize / 4.0);
            
            else if (zoom < 16.5)
                size = (maxSize / 2.0);
            
            else
                size = maxSize;
            
            pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
            
            CGContextSetLineWidth(context, (size / 12.0));
            CGContextFillEllipseInRect(context, pointRect);
            CGContextStrokeEllipseInRect(context, pointRect);
            CGContextFillPath(context);
        }
    }
    
    return;
}

@end