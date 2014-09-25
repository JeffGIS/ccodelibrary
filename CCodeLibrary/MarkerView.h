//  MarkerView.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "IntersectionsDatabase.h"

@interface MarkerView : UIView

- (id)initWithMapView:(GMSMapView *)mapView;

@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property GMSMapView *mapView;
@property IntersectionsDatabase *database;

@end