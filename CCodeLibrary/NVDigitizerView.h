//  NVDigitizerView.h
//  CCodeLibrary

@import UIKit;
@import MapKit;

@class NVDigitizerView;

@protocol NVDigitizerViewDelegate <NSObject>

- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point;
- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)digitizerViewDidComplete:(NVDigitizerView *)digitizerView;

@end

@interface NVDigitizerView : UIView

+ (instancetype)showDigitizerInView:(UIView *)view
                  constrainedToView:(UIView *)constrainedView
                           delegate:(id)delegate;

- (void)clearDigitizerView;
- (void)placeTargetInCenter;

@end