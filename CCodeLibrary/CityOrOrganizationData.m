//  CityOrOrganizationData.m
//  CCodeLibrary

#import "CityOrOrganizationData.h"
#import "StringFunctions.h"

@implementation CityOrOrganizationData

- (NSComparisonResult)compareName:(CityOrOrganizationData *)c
{
    return [self.name compare:c.name];
}

@end