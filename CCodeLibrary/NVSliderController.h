//  NVSliderController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NVSliderConfiguration)
{
    NVSliderConfigurationDefault,
    NVSliderConfigurationManualSlope,
    NVSliderConfigurationCalibrationRunningSlope,
    NVSliderConfigurationCalibrationDegrees,
    NVSliderConfigurationCalibrationRiseRun,
};

typedef NS_ENUM(NSInteger, NVSliderMeasurementType)
{
    NVSliderMeasurementTypeDefault,
    NVSliderMeasurementTypeFrontSlope,
    NVSliderMeasurementTypeSideSlope,
};

@class NVSliderController;

@protocol NVSliderControllerDelegate <NSObject>

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(CGFloat)value;

- (void)sliderViewDidCancel:(NVSliderController *)sliderView;

@end

@interface NVSliderController : UIView

@property (nonatomic, weak) id <NVSliderControllerDelegate> delegate;
@property NVSliderMeasurementType type;

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate
       configuration:(NVSliderConfiguration)configuration
                type:(NVSliderMeasurementType)type;

- (void)showSliderControllerInView:(UIView *)view
                          animated:(BOOL)animated
                           overlay:(BOOL)overlay;

- (void)hideSliderController:(BOOL)animated;

@end