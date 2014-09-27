//
//  MaskCityBounds.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/26/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MaskCityBounds : NSObject
- (void)drawCityBounds:(NSString *)fromFile inMapView:(GMSMapView *)mapView;
- (void)maskCityBounds:(NSString *)fromFile inMapView:(GMSMapView *)mapView;


@end
