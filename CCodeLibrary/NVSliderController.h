//  NVSliderController.h
//  CCodeLibrary

@import UIKit;
#import "GSSiEnums.h"

typedef NS_ENUM(NSInteger, NVSliderConfiguration)
{
    NVSliderConfigurationDefault,
    NVSliderConfigurationDefaultNoRange,
    NVSliderConfigurationManualSlope,
    NVSliderConfigurationCalibrationRunningSlope,
    NVSliderConfigurationCalibrationDegrees,
    NVSliderConfigurationCalibrationRiseRun,
    NVSliderConfigurationFacilities,
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
    didReturnValue:(double)value;

- (void)sliderViewDidCancel:(NVSliderController *)sliderView;

@optional
- (void)sliderViewDidTapButton:(UIButton *)button;

@end

@interface NVSliderController : UIView

@property NVSliderMeasurementType type;
@property CGFloat usedTopSpace;

- (id)initWithCenter:(CGPoint)center
               width:(double)width
          startValue:(double)startValue
            minValue:(double)minValue
            maxValue:(double)maxValue
            delegate:(id)delegate
       configuration:(NVSliderConfiguration)configuration
                type:(NVSliderMeasurementType)type
                unit:(NSString *)unit;

- (void)showSliderControllerInView:(UIView *)view
                          animated:(BOOL)animated
                           overlay:(BOOL)overlay;

- (void)hideSliderController:(BOOL)animated;
- (void)removeRequiredFromLabel;
- (void)setNumDecimals:(int)numDecimals;

- (void)addTitle:(NSString *)title
          prompt:(NSString *)prompt
            help:(BOOL)help
       reference:(BOOL)reference
            link:(BOOL)link
         comment:(BOOL)comment;

@end
