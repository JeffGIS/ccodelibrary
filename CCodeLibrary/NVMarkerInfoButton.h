//  NVMarkerInfoButton.h
//  CCodeLibrary

@import UIKit;
@import MapKit;

typedef NS_ENUM(NSInteger, NVMarkerInfoButtonType)
{
    NVMarkerInfoButtonTypeDefault,
    NVMarkerInfoButtonTypePropList,
    NVMarkerInfoButtonTypeDestinationsIndividual,
    NVMarkerInfoButtonTypeDestinationsGroup,
};

@class NVMarkerInfoButton;

@protocol NVMarkerInfoButtonDelegate <NSObject>

- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;
- (CGFloat)statusBarHeight:(UIInterfaceOrientation)orientation;

@end

@interface NVMarkerInfoButton : UIButton

@property NVMarkerInfoButtonType type;
@property (nonatomic) CLLocationCoordinate2D position;

+ (instancetype)markerWithPosition:(CLLocationCoordinate2D)position
                             title:(NSString *)title
                              type:(NVMarkerInfoButtonType)type
                              view:(UIView *)view
                          delegate:(id)delegate;

@end