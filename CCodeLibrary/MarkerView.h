//  MarkerView.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "GoogleMaps/GoogleMaps.h"
#import "IntersectionsDatabase.h"

@class MarkerView;

@protocol MarkerViewDelegate <NSObject>

- (void)setupProgressLabelTextForTotalIntersections:(int)totalIntersections
                                          completed:(int)completed
                                            complex:(int)numComplex
                                           numRamps:(int)numRamps
                                        notAssigned:(int)notAssigned;

@end

@interface MarkerView : UIView

- (id)initWithMapView:(GMSMapView *)mapView
             areaFile:(NSString *)areaFile;

@property (nonatomic, weak) id <MarkerViewDelegate> delegate;
@property (nonatomic) LPTRANDATA pTranWToBMP, pTranBMPToW;
@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSProjection *projection;
@property (nonatomic) IntersectionsDatabase *database;
@property (nonatomic) BOOL showOnlyIntersectionsWithRamps;
@property (nonatomic, copy) NSString *areaFile;

@end