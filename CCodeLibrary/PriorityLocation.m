//  PriorityLocation.m
//  CCodeLibrary

#import "PriorityLocation.h"

@implementation PriorityLocation

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self)
    {
        _name = [aDecoder decodeObjectForKey:@"PriorityName"];
        _type = [aDecoder decodeObjectForKey:@"PriorityType"];
        _coordinate.latitude = [aDecoder decodeDoubleForKey:@"PriorityLatitude"];
        _coordinate.longitude = [aDecoder decodeDoubleForKey:@"PriorityLongitude"];
        _upperLeft.latitude = [aDecoder decodeDoubleForKey:@"PriorityULLatitude"];
        _upperLeft.longitude = [aDecoder decodeDoubleForKey:@"PriorityULLongitude"];
        _lowerRight.latitude = [aDecoder decodeDoubleForKey:@"PriorityLRLatitude"];
        _lowerRight.longitude = [aDecoder decodeDoubleForKey:@"PriorityLRLongitude"];
        _radius = [aDecoder decodeFloatForKey:@"PriorityRadius"];
        _offset = [aDecoder decodeIntegerForKey:@"PriorityOffset"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"PriorityName"];
    [aCoder encodeObject:_type forKey:@"PriorityType"];
    [aCoder encodeDouble:_coordinate.latitude forKey:@"PriorityLatitude"];
    [aCoder encodeDouble:_coordinate.longitude forKey:@"PriorityLongitude"];
    [aCoder encodeDouble:_upperLeft.latitude forKey:@"PriorityULLatitude"];
    [aCoder encodeDouble:_upperLeft.longitude forKey:@"PriorityULLongitude"];
    [aCoder encodeDouble:_lowerRight.latitude forKey:@"PriorityLRLatitude"];
    [aCoder encodeDouble:_lowerRight.longitude forKey:@"PriorityLRLongitude"];
    [aCoder encodeDouble:_radius forKey:@"PriorityRadius"];
    [aCoder encodeInteger:_offset forKey:@"PriorityOffset"];
}

@end
