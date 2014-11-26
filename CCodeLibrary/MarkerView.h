//  MarkerView.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "GoogleMaps/GoogleMaps.h"
#import "IntersectionsDatabase.h"

@class MarkerView;

@protocol MarkerViewDelegate<NSObject>

- (void)setupProgressLabelTextForTotalIntersections:(int)totalIntersections
                                          completed:(int)completed
                                            complex:(int)numComplex
                                           numRamps:(int)numRamps
                                        notAssigned:(int)notAssigned;

@end

@interface MarkerView : UIView

- (id)initWithMapView:(GMSMapView *)mapView;

@property (nonatomic, weak) id <MarkerViewDelegate> delegate;
@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property GMSMapView *mapView;
@property IntersectionsDatabase *database;
@property NSArray *tempDemoArray;
@property BOOL showOnlyIntersectionsWithRamps;

@end