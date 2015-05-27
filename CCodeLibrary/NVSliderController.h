//  NVSliderController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVSliderController;

@protocol NVSliderControllerDelegate <NSObject>

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(CGFloat)value;

- (void)sliderViewDidCancel:(NVSliderController *)sliderView;

@end

@interface NVSliderController : UIView

@property (nonatomic, weak) id <NVSliderControllerDelegate> delegate;

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate;

- (void)showSliderControllerInView:(UIView *)view
                          animated:(BOOL)animated
                           overlay:(BOOL)overlay;

- (void)hideSliderController:(BOOL)animated;

@end