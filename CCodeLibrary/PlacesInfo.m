//  PlacesInfo.m
//  CCodeLibrary

#import "PlacesInfo.h"

@implementation PlacesInfo

@synthesize name = _name;
@synthesize statefp = _statefp;
@synthesize stateCode = _stateCode;
@synthesize bounds_w = _bounds_w;
@synthesize bounds_s = _bounds_s;
@synthesize bounds_e = _bounds_e;
@synthesize bounds_n = _bounds_n;
@synthesize geoid = _geoid;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)initWithBounds_w:(CGFloat)bounds_w
              bounds_s:(CGFloat)bounds_s
              bounds_e:(CGFloat)bounds_e
              bounds_n:(CGFloat)bounds_n;
{
    if ((self = super.init))
    {
        self.bounds_w = bounds_w;
        self.bounds_s = bounds_s;
        self.bounds_e = bounds_e;
        self.bounds_n = bounds_n;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name
         stateCode:(NSString *)stateCode
          bounds_w:(CGFloat)bounds_w
          bounds_s:(CGFloat)bounds_s
          bounds_e:(CGFloat)bounds_e
          bounds_n:(CGFloat)bounds_n
{
    if ((self = super.init))
    {
        self.name = name;
        self.stateCode = stateCode;
        self.bounds_w = bounds_w;
        self.bounds_s = bounds_s;
        self.bounds_e = bounds_e;
        self.bounds_n = bounds_n;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name
             geoid:(NSString *)geoid
{
    if ((self = super.init))
    {
        self.name = name;
        self.geoid = geoid;
    }
    
    return self;
}

- (id)initWithLatitude:(NSNumber *)latitude
             longitude:(NSNumber *)longitude
{
    if ((self = super.init))
    {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
    return self;
}

- (void) dealloc
{
    self.name = nil;
}

@end