//  NVPopoverSlider.h
//  CCodeLibrary

@import UIKit;
#import "NVAlertView.h"

@class NVPopoverSlider;

@protocol NVPopoverSliderDelegate <NSObject>

- (void)popoverSlider:(NVPopoverSlider *)popoverSlider
       didReturnValue:(double)value
                  tag:(NSInteger)tag;

- (void)popoverSliderDidCancel:(NVPopoverSlider *)popoverSlider;

@end

@interface NVPopoverSlider : UIView <NVAlertViewDelegate>

@property (nonatomic) BOOL roundToTenths;
@property (nonatomic, copy) NSString *units;
@property BOOL allowBosch;
@property NSString * title;

+ (instancetype)showPopoverSliderInView:(UIView *)view
                               minValue:(float)minValue
                               maxValue:(float)maxValue
                             startValue:(float)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag
                                  title:(NSString *)title
                             allowBosch:(BOOL)allowBosch;

- (void)hidePopoverSliderView:(BOOL)animated;
- (void)showStepper;
- (void)showRelativeModeSwitch;
- (void)setMeasurementValues;


@end
