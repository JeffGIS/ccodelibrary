//
//  GeoMasterServer.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 8/29/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import "GeoMasterServer.h"

@implementation GeoMasterServer

static GeoMasterServer *_pull;

+ (GeoMasterServer *)pull
{
    if (_pull == nil)
    {
        _pull = [[GeoMasterServer alloc] init];
    }
    
    return _pull;
}

@end
