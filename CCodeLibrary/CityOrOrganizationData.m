//
//  CityOrOrganizationData.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 4/12/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "CityOrOrganizationData.h"
#import "StringFunctions.h"

@implementation CityOrOrganizationData

- (NSComparisonResult)compareName:(CityOrOrganizationData *)c
{
    return [self.name compare:c.name];
}



@end
