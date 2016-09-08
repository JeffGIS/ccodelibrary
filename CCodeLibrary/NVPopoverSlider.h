//  NVPopoverSlider.h
//  CCodeLibrary

@import UIKit;

@class NVPopoverSlider;

@protocol NVPopoverSliderDelegate <NSObject>

- (void)popoverSlider:(NVPopoverSlider *)sliderView
       didReturnValue:(double)value
                  tag:(NSInteger)tag;

- (void)popoverSliderDidCancel:(NVPopoverSlider *)sliderView;

@end

@interface NVPopoverSlider : UIView

+ (instancetype)showPopoverSliderInView:(UIView *)view
                               minValue:(double)minValue
                               maxValue:(double)maxValue
                             startValue:(double)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag;

- (void)hidePopoverSliderView:(BOOL)animated;

@end