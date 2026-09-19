//  NVDigitizerView.h
//  CCodeLibrary

@import UIKit;
@import MapKit;

@class NVDigitizerView;

@protocol NVDigitizerViewDelegate <NSObject>

- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point;
- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)digitizerViewDidComplete:(NVDigitizerView *)digitizerView;

- (void)zoomMapToNearLeft:(CLLocationCoordinate2D)nearLeft
                 farRight:(CLLocationCoordinate2D)farRight;
@optional
- (void)digitizerViewDidAddPoint:(CLLocationCoordinate2D)point;

@end

@interface NVDigitizerView : UIView

+ (instancetype)showDigitizerInView:(UIView *)view
                  constrainedToView:(UIView *)constrainedView
                           delegate:(id)delegate;

- (void)clearDigitizerView;
- (void)placeTargetInCenter;

@end
