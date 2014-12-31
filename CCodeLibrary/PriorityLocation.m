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
        _coordinate.latitude = [aDecoder decodeFloatForKey:@"PriorityLatitude"];
        _coordinate.longitude = [aDecoder decodeFloatForKey:@"PriorityLongitude"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name
                  forKey:@"PriorityName"];
    
    [aCoder encodeObject:_type
                  forKey:@"PriorityType"];
    
    [aCoder encodeFloat:_coordinate.latitude
                 forKey:@"PriorityLatitude"];
    
    [aCoder encodeFloat:_coordinate.longitude
                 forKey:@"PriorityLongitude"];
}

@end