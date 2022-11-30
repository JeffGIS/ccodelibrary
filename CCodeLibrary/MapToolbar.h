//  MapToolbar.h
//  GMMobile

#import "GSSiEnums.h"

typedef NS_ENUM(NSInteger, MapToolbarProperty)
{
    MapToolbarPropertyWantPlat,
    MapToolbarPropertyWantDigitize,
    MapToolbarPropertyWantMapType,
    MapToolbarPropertyWantMapTypeButton,
    MapToolbarPropertyWantUserLocation,
    MapToolbarPropertyWantExtents,
    MapToolbarPropertyWantLegends,
    MapToolbarPropertyWantGrayscale,
    MapToolbarPropertyWantClearMarkers,
    MapToolbarPropertyWantEmailPDF,
    MapToolbarPropertyWantProgressBar,
    MapToolbarPropertyWantHelpButton,
    MapToolbarPropertyWantReturnButton,
NUMMapToolbarProperty};

typedef NS_ENUM(NSInteger, MapToolbarOrientation)
{
    MapToolbarOrientationDefault,
    MapToolbarOrientationTop,
    MapToolbarOrientationBottom,
    MapToolbarOrientationLeft,
    MapToolbarOrientationRight,
    MapToolbarOrientationMinimized,
};

@class MapToolbar;

@protocol MapToolbarDelegate <NSObject>

- (void)mapToolbarDidSelectUserLocation:(BOOL)enabled;
- (void)mapToolbarDidSelectZoomExtent;
- (void)mapToolbarDidSelectMapType:(NSInteger)mapType;
- (void)mapToolbarDidToggleMapType;
- (void)mapToolbarDidSelectSplitScreenSetting:(NSInteger)setting;
- (void)mapToolbarDidSelectGrayscale;
- (void)mapToolbarDidSelectClearMarkers;
- (void)mapToolbarDidSelectEmailPDF;
- (void)mapToolbarDidSelectHelpButton;
- (void)mapToolbarDidSelectDigitize;
- (void)mapToolbarDidSelectLegends;
- (void)mapToolbarDidSelectReturnButton;
- (void)mapToolbarDidFinishDrag:(CGPoint)locationInSuperview
                      superView:(UIView *)view;
- (void)mapToolbarDidWantExpand;

@end

@interface MapToolbar : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <MapToolbarDelegate> delegate;
@property (nonatomic) MapToolbarOrientation orientation, previousOrientation;
@property (readonly) BOOL wantPlat, wantDigitize, wantMapType, wantMapTypeButton, wantUserLocation;
@property (readonly) BOOL wantExtents, wantLegends, wantGrayscale, wantClearMarkers;
@property (readonly) BOOL wantEmailPDF, wantProgressBar, wantHelpButton, wantReturnButton;
@property (nonatomic) CGFloat progress, legendOffset;
@property BOOL helpLongPressed, isOffset, applyRotation;
@property (nonatomic) BOOL showIndicator;
@property (nonatomic) CGRect previousFrame;

+ (MapToolbar *)showMapToolbarWithCenter:(CGPoint)center
                                   view:(UIView *)view
                                delegate:(id)delegate;
- (void)selectMyLocationButton:(BOOL)amCreatingTrackRoute;
- (void)deselectMyLocationButton;
- (void)animateToVerticalOrientation;
- (void)animateToHorizontalOrientation;
- (void)splitScreenSelectedSegmentIndex:(NSInteger)index;
- (void)normalMode:(MapViewScreenSetting)screenSetting;
- (void)platViewMode:(MapViewScreenSetting)screenSetting;
- (void)hide;
- (void)show;

- (void)setConfigurationProperty:(MapToolbarProperty)property
                           value:(BOOL)value;

- (void)configure:(MapViewScreenSetting)screenSetting;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight
               statusBarHeight:(CGFloat)statusBarHeight;

- (void)didRotateWithTabBarHeight:(CGFloat)tabBarHeight
                  statusBarHeight:(CGFloat)statusBarHeight;

- (void)adjustFrameToScrollView;
- (void)addExpandButton;
- (void)bringToFrontOfView;

@end
