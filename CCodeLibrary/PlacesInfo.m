//  PlacesInfo.m
//  CCodeLibrary

#import "PlacesInfo.h"

@implementation PlacesInfo

@synthesize name = _name;
@synthesize bounds_w = _bounds_w;
@synthesize bounds_s = _bounds_s;
@synthesize bounds_e = _bounds_e;
@synthesize bounds_n = _bounds_n;
@synthesize geoid = _geoid;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize intID = _intID;
@synthesize intX = _intX;
@synthesize intY = _intY;
@synthesize rotation = _rotation;
@synthesize ramp1 = _ramp1;
@synthesize ramp2 = _ramp2;
@synthesize ramp3 = _ramp3;
@synthesize ramp4 = _ramp4;
@synthesize ramp5 = _ramp5;
@synthesize ramp6 = _ramp6;
@synthesize ramp7 = _ramp7;
@synthesize ramp8 = _ramp8;
@synthesize ramp81 = _ramp81;
@synthesize ramp23 = _ramp23;
@synthesize ramp45 = _ramp45;
@synthesize ramp67 = _ramp67;
@synthesize xWalkA = _xWalkA;
@synthesize xWalkB = _xWalkB;
@synthesize xWalkC = _xWalkC;
@synthesize xWalkD = _xWalkD;
@synthesize signal81 = _signal81;
@synthesize signal23 = _signal23;
@synthesize signal45 = _signal45;
@synthesize signal67 = _signal67;

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

- (id)initWithIntID:(int)intID
               intX:(int)intX
               intY:(int)intY
           rotation:(int)rotation
              ramp1:(int)ramp1
              ramp2:(int)ramp2
              ramp3:(int)ramp3
              ramp4:(int)ramp4
              ramp5:(int)ramp5
              ramp6:(int)ramp6
              ramp7:(int)ramp7
              ramp8:(int)ramp8
             ramp81:(int)ramp81
             ramp23:(int)ramp23
             ramp45:(int)ramp45
             ramp67:(int)ramp67
             xWalkA:(int)xWalkA
             xWalkB:(int)xWalkB
             xWalkC:(int)xWalkC
             xWalkD:(int)xWalkD
           signal81:(int)signal81
           signal23:(int)signal23
           signal45:(int)signal45
           signal67:(int)signal67
{
    if ((self = super.init))
    {
        self.intID = intID;
        self.intX = intX;
        self.intY = intY;
        self.rotation = rotation;
        self.ramp1 = ramp1;
        self.ramp2 = ramp2;
        self.ramp3 = ramp3;
        self.ramp4 = ramp4;
        self.ramp5 = ramp5;
        self.ramp6 = ramp6;
        self.ramp7 = ramp7;
        self.ramp8 = ramp8;
        self.ramp81 = ramp81;
        self.ramp23 = ramp23;
        self.ramp45 = ramp45;
        self.ramp67 = ramp67;
        self.xWalkA = xWalkA;
        self.xWalkB = xWalkB;
        self.xWalkC = xWalkC;
        self.xWalkD = xWalkD;
        self.signal81 = signal81;
        self.signal23 = signal23;
        self.signal45 = signal45;
        self.signal67 = signal67;
    }
    
    return self;
}

- (void) dealloc
{
    self.name = nil;
}

@end