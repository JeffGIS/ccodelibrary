//  CircleView.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "GoogleMaps/GoogleMaps.h"
#import "IntersectionsDatabase.h"

@interface CircleView : UIView

- (id)initWithMapView:(GMSMapView *)mapView
     forCityWithGeoid:(int)geoid;

@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property GMSMapView *mapView;
@property IntersectionsDatabase *database;
@property int geoid;

@end