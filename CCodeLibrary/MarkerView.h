//  MarkerView.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "IntersectionsDatabase.h"

@class MarkerView;

@protocol MarkerViewDelegate<NSObject>
- (void)setupProgressLabelTextforTotalIntersections:(int)totalIntersections
                                          completed:(int)completed
                                        notAssigned:(int)notAssigned;

@end

@interface MarkerView : UIView

- (id)initWithMapView:(GMSMapView *)mapView;

@property (nonatomic, weak) id <MarkerViewDelegate> delegate;
@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property GMSMapView *mapView;
@property IntersectionsDatabase *database;
@property NSArray *tempDemoArray;

@end