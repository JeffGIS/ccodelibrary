//  MaskCityBounds.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "GoogleMaps/GoogleMaps.h"

@interface MaskCityBounds : NSObject

- (void)drawCityBounds:(NSString *)fromFile
             inMapView:(GMSMapView *)mapView;

- (void)maskCityBounds:(NSString *)fromFile
             inMapView:(GMSMapView *)mapView;

@end