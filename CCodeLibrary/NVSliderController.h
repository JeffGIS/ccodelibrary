//  NVSliderController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVSliderController;

@protocol NVSliderControllerDelegate <NSObject>

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(CGFloat)value;

@end

@interface NVSliderController : UIView

@property (nonatomic, weak) id <NVSliderControllerDelegate> delegate;

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate;

@end