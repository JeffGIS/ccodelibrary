//  CityOrOrganizationData.m
//  CCodeLibrary

#import "CityOrOrganizationData.h"
#import "StringFunctions.h"

@implementation CityOrOrganizationData

- (NSComparisonResult)compareName:(CityOrOrganizationData *)c
{
    return [self.name compare:c.name];
}
- (bool) inArray:(NSArray*)array
{
    if (array)
    for (CityOrOrganizationData * c in array)
    {
        if (c.number == self.number)
            return TRUE;
    }
    return FALSE;
}

@end
