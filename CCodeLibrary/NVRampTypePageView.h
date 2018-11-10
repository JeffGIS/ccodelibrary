//  NVRampTypePageView.h
//  CCodeLibrary

@import UIKit;
#import "NVRampTypePageController.h"

@class NVRampTypePageView;

@protocol NVRampTypePageViewDelegate <NSObject>

- (void)rampTypePageView:(NVRampTypePageView *)rampTypePageView
       didReturnRampType:(RampType)rampType;

- (void)rampTypePageViewDidZoom:(BOOL)didZoom;

@end

@interface NVRampTypePageView : UIViewController

@property BOOL isZoomed;

+ (instancetype)pageViewWithRampTypes:(NSArray <NVRampType *> *)rampTypes
                        startingIndex:(NSUInteger)startingIndex
                         selectedType:(RampType)selectedType
                             delegate:(id)delegate;

@end
