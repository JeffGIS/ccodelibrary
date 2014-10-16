//  CircleView.m
//  CCodeLibrary

#import "CircleView.h"

@implementation CircleView

- (id)initWithMapView:(GMSMapView *)mapView
     forCityWithGeoid:(int)geoid
{
    CGRect frame = mapView.frame;
    frame.origin.x = frame.origin.y = 0;
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.geoid = geoid;
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
    CGRect pointRect;
    NSString *path = @"";
    
    CGFloat size = [projection pointsForMeters:300.0
                                  atCoordinate:self.mapView.camera.target];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.geoid == ROCHESTER_MN)
    {
        path = [NSBundle.mainBundle pathForResource:@"RochesterPublicPlaces"
                                             ofType:@"txt"];
    }
    
    else if (self.geoid == MINNEAPOLIS_MN)
    {
        path = [NSBundle.mainBundle pathForResource:@"MinneapolisPublicPlaces"
                                             ofType:@"txt"];
    }
    
    else if (self.geoid == CRYSTAL_LAKE_IL)
    {
        path = [NSBundle.mainBundle pathForResource:@"CrystalLakePublicPlaces"
                                             ofType:@"txt"];
    }
    
    else if (self.geoid == EAGAN_MN)
    {
        path = [NSBundle.mainBundle pathForResource:@"EaganPublicPlaces"
                                             ofType:@"txt"];
    }
    
    if ([path isEqual:@""])
        return;
    
    NSString *contents = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    
    NSArray *pointsArray = [contents componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < pointsArray.count; i++)
    {
        CLLocationCoordinate2D latlon;
        latlon.latitude = [UserDefaults.defaults includeTextBeforeTab:[pointsArray objectAtIndex:i]].floatValue;
        
        latlon.longitude = [UserDefaults.defaults includeTextBeforeTab:
                            [UserDefaults.defaults includeTextAfterTab:[pointsArray objectAtIndex:i]]].floatValue;
        
        CGPoint pt = [projection pointForCoordinate:latlon];
        
        if ((pt.x > - size) && (pt.x < (self.mapView.frame.size.width + size) &&
                                (pt.y > - size) && (pt.y < self.mapView.frame.size.height + size)))
        {
            CGContextSetFillColorWithColor(context, UIColor.orangeColor.CGColor);
            pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
            CGContextFillEllipseInRect(context, pointRect);
            CGContextFillPath(context);
        }
    }
    
    return;
}

@end