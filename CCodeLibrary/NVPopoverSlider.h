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
                               minValue:(float)minValue
                               maxValue:(float)maxValue
                             startValue:(float)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag
                                  title:(NSString *)title;

- (void)hidePopoverSliderView:(BOOL)animated;
- (void)showStepper;
- (void)showRelativeModeSwitch;

@end
