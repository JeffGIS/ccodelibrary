//  NVSliderView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVSliderView;

@protocol NVSliderViewDelegate <NSObject>

- (void)sliderView:(NVSliderView *)sliderView
    didReturnValue:(CGFloat)value
    forViewWithTag:(NSInteger)tag;

- (void)sliderViewDidCancel:(NVSliderView *)sliderView;

@end

@interface NVSliderView : UIView


@property (nonatomic, weak) id <NVSliderViewDelegate> delegate;

+ (NVSliderView *)showSliderWithView:(UIView *)view
                          startValue:(CGFloat)startValue
                            minValue:(CGFloat)minValue
                            maxValue:(CGFloat)maxValue
                            delegate:(id)delegate
                              tabBar:(UITabBar *)tabBar
                                 tag:(NSInteger)tag;

- (void)hideSliderView:(BOOL)animated;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end