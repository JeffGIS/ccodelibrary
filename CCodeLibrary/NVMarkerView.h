//  NVMarkerView.h
//  CCodeLibrary

@import UIKit;
#import "IntersectionsDatabase.h"

@class NVMarkerView;

@protocol NVMarkerViewDelegate <NSObject>

- (void)setupProgressLabelTextForTotalIntersections:(int)totalIntersections
                                          completed:(int)completed
                                            complex:(int)numComplex
                                           numRamps:(int)numRamps
                                        notAssigned:(int)notAssigned
                                         totPeriPad:(NSArray *)totPeriPad;

- (CGRect)mapViewFrame;
- (CGFloat)currentZoom;
- (CGFloat)maxZoom;
- (CGPoint)getPointForCoordinate:(CLLocationCoordinate2D)coordinate;
- (CLLocationCoordinate2D)getCoordinateForPoint:(CGPoint)point;

@end

@interface NVMarkerView : UIView

+ (instancetype)markerViewWithAreaFile:(NSString *)areaFile
                              delegate:(id)delegate;

@property MMLMFrom from;
@property MMMapType mapType;
@property BOOL showOnlyIntersectionsWithRamps;
@property (nonatomic, copy) NSString *areaFile;
@property (nonatomic) IntersectionsDatabase *database;
@property (nonatomic, copy) NSArray *colorsArray; //fill with UIColors to use for assigned intersections

@end