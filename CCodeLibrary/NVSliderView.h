//  NVSliderView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVSliderView;

@protocol NVSliderViewDelegate <NSObject>

- (void)sliderView:(NVSliderView *)sliderView
    didReturnValue:(double)value
    forViewWithTag:(NSInteger)tag;

- (void)sliderViewDidCancel:(NVSliderView *)sliderView;

@optional
- (void)sliderViewDidWantPhoto:(NVSliderView *)sliderView;

@end

@interface NVSliderView : UIView


@property (nonatomic, weak) id <NVSliderViewDelegate> delegate;
@property (nonatomic) NSString *units, *titleText;
@property (nonatomic) BOOL roundToTenths;

+ (NVSliderView *)showSliderWithView:(UIView *)view
                          startValue:(double)startValue
                            minValue:(double)minValue
                            maxValue:(double)maxValue
                            delegate:(id)delegate
                              tabBar:(UITabBar *)tabBar
                                 tag:(NSInteger)tag;

- (void)hideSliderView:(BOOL)animated;
- (void)showPhotoButton;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
