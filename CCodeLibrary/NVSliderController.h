//  NVSliderController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NVSliderConfiguration)
{
    NVSliderConfigurationDefault,
    NVSliderConfigurationDefaultNoRange,
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

typedef NS_ENUM(NSInteger, NVSliderButton)
{
    NVSliderButtonHelp=1,
    NVSliderButtonReference=2,
    NVSliderButtonLink=3,
    NVSliderButtonComment=4,
};

@class NVSliderController;

@protocol NVSliderControllerDelegate <NSObject>

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(double)value;

- (void)sliderViewDidCancel:(NVSliderController *)sliderView;

@optional
- (void)sliderViewDidTapButtonWithType:(NVSliderButton)type;

@end

@interface NVSliderController : UIView

@property (nonatomic, weak) id <NVSliderControllerDelegate> delegate;
@property NVSliderMeasurementType type;

- (id)initWithCenter:(CGPoint)center
               width:(double)width
          startValue:(double)startValue
            minValue:(double)minValue
            maxValue:(double)maxValue
            delegate:(id)delegate
       configuration:(NVSliderConfiguration)configuration
                type:(NVSliderMeasurementType)type
                unit:(NSString *)unit;

- (void)addTitle:(NSString *)title;

- (void)showSliderControllerInView:(UIView *)view
                          animated:(BOOL)animated
                           overlay:(BOOL)overlay;

- (void)hideSliderController:(BOOL)animated;

- (void)addHelp:(BOOL)help
      reference:(BOOL)reference
           link:(BOOL)link
        comment:(BOOL)comment;

@end
