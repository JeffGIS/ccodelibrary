//  CircleView.m
//  CCodeLibrary

#import "CircleView.h"
#import "GSSiDefs.h"
#import "PriorityLocation.h"

@implementation CircleView

- (id)initWithMapView:(GMSMapView *)mapView
     forCityWithGeoid:(int)geoid
{
    CGRect frame = mapView.frame;
    frame.origin.x = frame.origin.y = 0;
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.opaque = NO;
        _geoid = geoid;
        _mapView = mapView;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSData *data = [UserDefaults.defaults NSDataForKey:[NSString stringWithFormat:@"PriorityLocationsFor%i",
                                                        _geoid]];
    
    if (data)
    {
        NSArray *contents = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        GMSProjection *projection = _mapView.projection;
        CGRect pointRect;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        for (int i = 0; i < contents.count; i++)
        {
            PriorityLocation *pLoc = contents[i];
            CLLocationCoordinate2D coordinate = pLoc.coordinate;
            CGPoint pt = [projection pointForCoordinate:coordinate];
            CGFloat radius = min(pLoc.radius, 150.0);
            CGFloat offset = (pLoc.offset * METERS_PER_FOOT);
            
            CGFloat size = [projection pointsForMeters:(radius + offset)
                                          atCoordinate:_mapView.camera.target];
            
            if ((pt.x > - size) && (pt.x < (_mapView.frame.size.width + size) &&
                                    (pt.y > - size) && (pt.y < _mapView.frame.size.height + size)))
            {
                CGContextSetFillColorWithColor(context, UIColor.orangeColor.CGColor);
                pointRect = CGRectMake((pt.x - size), (pt.y - size), (size * 2.0), (size * 2.0));
                CGContextFillEllipseInRect(context, pointRect);
                CGContextFillPath(context);
            }
        }
    }
}

@end