//  NVPopoverSlider.h
//  CCodeLibrary

@import UIKit;

@class NVPopoverSlider;

@protocol NVPopoverSliderDelegate <NSObject>

- (void)popoverSlider:(NVPopoverSlider *)popoverSlider
       didReturnValue:(double)value
                  tag:(NSInteger)tag;

- (void)popoverSliderDidCancel:(NVPopoverSlider *)popoverSlider;

@end

@interface NVPopoverSlider : UIView

+ (instancetype)showPopoverSliderInView:(UIView *)view
                               minValue:(double)minValue
                               maxValue:(double)maxValue
                             startValue:(double)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag
                                  title:(NSString *)title;

- (void)hidePopoverSliderView:(BOOL)animated;

@end