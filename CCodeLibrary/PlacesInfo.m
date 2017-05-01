//  PlacesInfo.m
//  CCodeLibrary

#import "PlacesInfo.h"

@implementation PlacesInfo

- (id)initWithBounds_w:(CLLocationDegrees)bounds_w
              bounds_s:(CLLocationDegrees)bounds_s
              bounds_e:(CLLocationDegrees)bounds_e
              bounds_n:(CLLocationDegrees)bounds_n;
{
    if ((self = super.init))
    {
        _bounds_w = bounds_w;
        _bounds_s = bounds_s;
        _bounds_e = bounds_e;
        _bounds_n = bounds_n;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name
         stateCode:(NSString *)stateCode
          bounds_w:(CLLocationDegrees)bounds_w
          bounds_s:(CLLocationDegrees)bounds_s
          bounds_e:(CLLocationDegrees)bounds_e
          bounds_n:(CLLocationDegrees)bounds_n
{
    if ((self = super.init))
    {
        _name = name;
        _stateCode = stateCode;
        _bounds_w = bounds_w;
        _bounds_s = bounds_s;
        _bounds_e = bounds_e;
        _bounds_n = bounds_n;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name
             geoid:(NSString *)geoid
{
    if ((self = super.init))
    {
        _name = name;
        _geoid = geoid;
    }
    
    return self;
}

- (id)initWithLatitude:(NSNumber *)latitude
             longitude:(NSNumber *)longitude
{
    if ((self = super.init))
    {
        _latitude = latitude;
        _longitude = longitude;
    }
    
    return self;
}

- (void) dealloc
{
    _name = nil;
}

@end
