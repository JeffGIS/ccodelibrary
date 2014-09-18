//  MarkerView.h
//  CCodeLibrary

#import "CCodeLibrary.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MarkerView : UIView

- (id)initWithMapView:(GMSMapView *)mapView;

@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property NSArray *pointsArray;
@property GMSMapView *mapView;

@end