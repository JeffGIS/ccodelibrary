//  NVSliderController.m
//  CCodeLibrary

#import "NVSliderController.h"
#import "UserDefaults.h"

typedef NS_ENUM(NSInteger, NVSliderControllerRange)
{
    NVSliderControllerRangeDefault,
    NVSliderControllerRangeMax,
    NVSliderControllerRangeTen,
    NVSliderControllerRangeTwo,
};

@interface NVSliderController ()

@property (nonatomic) UISlider *slider;
@property (nonatomic) UILabel *sliderLabel, *lowTic, *highTic, *midTic, *midLowTic, *midHighTic, *promptLabel;
@property (nonatomic) UIButton *saveButton, *cancelButton, *rangeButton;
@property (nonatomic) UIView *ticView, *overlayView;
@property (nonatomic) CGFloat minValue, maxValue;
@property NVSliderControllerRange range;
@property NVSliderConfiguration configuration;
@property (nonatomic, copy) NSString *unit;

@end

@implementation NVSliderController

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate
       configuration:(NVSliderConfiguration)configuration
                type:(NVSliderMeasurementType)type
                unit:(NSString *)unit
{
    CGFloat height = 260.0;
    
    self = [super initWithFrame:CGRectMake((center.x - (width / 2.0)),
                                           (center.y - (height / 2.0)), width, height)];
    
    if (self)
    {
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 4.0;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = UIColor.whiteColor;
        _configuration = configuration;
        _delegate = delegate;
        _range = NVSliderControllerRangeMax;
        _minValue = minValue;
        _maxValue = maxValue;
        _type = type;
        _unit = unit;
        
        CGFloat ticMargin = ((UserDefaults.defaults.redSliderThumb.size.width / 2.0) - 10.0);
        
        UIView *ticView = [[UIView alloc] initWithFrame:CGRectMake(ticMargin, 58.0,
                                                                   (width - (ticMargin * 2.0)), 64.0)];
        
        [self addSubview:ticView];
        
        CGSize ticLabelSize = CGSizeMake(40.0, ticView.frame.size.height);
        
        _midTic = [[UILabel alloc] initWithFrame:CGRectMake(((ticView.frame.size.width * 0.5) - (ticLabelSize.width / 2.0)),
                                                            0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:_midTic
                   value:((maxValue + minValue) / 2.0)];
        
        [ticView addSubview:_midTic];
        
        _lowTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:_lowTic
                   value:minValue];
        
        [ticView addSubview:_lowTic];
        
        _highTic = [[UILabel alloc] initWithFrame:CGRectMake((ticView.frame.size.width - ticLabelSize.width),
                                                             0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:_highTic
                   value:maxValue];
        
        [ticView addSubview:_highTic];
        
        _midLowTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        
        _midLowTic.center = CGPointMake(((_midTic.center.x + _lowTic.center.x) / 2.0), _midLowTic.center.y);
        
        [self setupLabel:_midLowTic
                   value:(((minValue * 3.0) + maxValue) / 4.0)];
        
        [ticView addSubview:_midLowTic];
        
        _midHighTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        
        _midHighTic.center = CGPointMake(((_midTic.center.x + _highTic.center.x) / 2.0), _midTic.center.y);
        
        [self setupLabel:_midHighTic
                   value:(((maxValue * 3.0) + minValue) / 4.0)];
        
        [ticView addSubview:_midHighTic];
        
        CGFloat capHeight = 29.0;
        CGFloat capWidth = (capHeight / 2.0);
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, ((height / 2.0) - (capHeight / 2.0)),
                                                             (width - 20.0), capHeight)];
        
        [_slider setThumbImage:UserDefaults.defaults.redSliderThumb
                      forState:UIControlStateNormal];
        
        UIImage *sliderLeft = [UserDefaults.defaults.metalSliderLeft stretchableImageWithLeftCapWidth:capWidth
                                                                                         topCapHeight:capHeight];
        
        UIImage *sliderRight = [UserDefaults.defaults.metalSliderRight stretchableImageWithLeftCapWidth:capWidth
                                                                                           topCapHeight:capHeight];
        
        [_slider setMinimumTrackImage:sliderLeft
                             forState:UIControlStateNormal];
        
        [_slider setMaximumTrackImage:sliderRight
                             forState:UIControlStateNormal];
        
        _slider.minimumValue = _minValue;
        _slider.maximumValue = _maxValue;
        _slider.value = startValue;
        
        [_slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_slider];
        
        _sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 6.0, width, 52.0)];
        
        _sliderLabel.backgroundColor = UIColor.clearColor;
        
        switch (_configuration)
        {
            case NVSliderConfigurationManualSlope:
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                break;
                
            case NVSliderConfigurationDefault:
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                break;
                
            case NVSliderConfigurationCalibrationRunningSlope:
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f%%", _slider.value];
                break;
                
            case NVSliderConfigurationCalibrationDegrees:
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f\u00B0", _slider.value];
                break;
                
            case NVSliderConfigurationCalibrationRiseRun:
                _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", _slider.value];
                break;
                
            default:
                break;
        }
        
        _sliderLabel.text = [NSString stringWithFormat:@"%@ %@", _sliderLabel.text, _unit];
        _sliderLabel.textColor = UIColor.blackColor;
        _sliderLabel.font = [UIFont boldSystemFontOfSize:56.0];
        _sliderLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_sliderLabel];
        
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.05), (height - 72.0),
                                                                 (width * 0.3), 56.0)];
        
        [self setupButton:_saveButton
                   target:self
                 selector:@selector(saveButtonTapped:)
                    title:@"Save"];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.65), (height - 72.0),
                                                                   (width * 0.3), 56.0)];
        
        [self setupButton:_cancelButton
                   target:self
                 selector:@selector(cancelButtonTapped:)
                    title:@"Cancel"];
        
        _rangeButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.4), (height - 72.0),
                                                                  (width * 0.2), 56.0)];
        
        [self setupButton:_rangeButton
                   target:self
                 selector:@selector(rangeButtonTapped:)
                    title:@"Range"];
    }
    
    return self;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    button.backgroundColor = UIColor.blackColor;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (void)setupLabel:(UILabel *)label
             value:(CGFloat)value
{
    label.numberOfLines = 2;
    
    if (_configuration == NVSliderConfigurationManualSlope)
        label.text = [NSString stringWithFormat:@"%.1f\n|", value];
    
    else
        label.text = [NSString stringWithFormat:@"%.0f\n|", value];
    
    label.font = [UIFont systemFontOfSize:20.0];
    label.textColor = UIColor.redColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [_ticView addSubview:label];
}

- (void)updateTicLabelText
{
    switch (_configuration)
    {
        case NVSliderConfigurationManualSlope:
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                {
                    _lowTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                    _minValue];
                    
                    _midLowTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                       (((_minValue * 3.0) + _maxValue) / 4.0)];
                    
                    _midTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                    ((_maxValue + _minValue) / 2.0)];
                    
                    _midHighTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                        (((_maxValue * 3.0) + _minValue) / 4.0)];
                    
                    _highTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                     _maxValue];
                }
                    break;
                    
                case NVSliderControllerRangeTen:
                {
                    _lowTic.text = @"-1.0\n|";
                    _midLowTic.text = @"-0.5\n|";
                    _midTic.text = @"0.0\n|";
                    _midHighTic.text = @"+0.5\n|";
                    _highTic.text = @"+1.0\n|";
                }
                    break;
                    
                case NVSliderControllerRangeTwo:
                {
                    _lowTic.text = @"-.50\n|";
                    _midLowTic.text = @"-.25\n|";
                    _midTic.text = @".00\n|";
                    _midHighTic.text = @"+.25\n|";
                    _highTic.text = @"+.50\n|";
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case NVSliderConfigurationDefault:
        case NVSliderConfigurationCalibrationRunningSlope:
        case NVSliderConfigurationCalibrationDegrees:
        case NVSliderConfigurationCalibrationRiseRun:
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                {
                    _lowTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                    _minValue];
                    
                    _midLowTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                       (((_minValue * 3.0) + _maxValue) / 4.0)];
                    
                    _midTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                    ((_maxValue + _minValue) / 2.0)];
                    
                    _midHighTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                        (((_maxValue * 3.0) + _minValue) / 4.0)];
                    
                    _highTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                     _maxValue];
                }
                    break;
                    
                case NVSliderControllerRangeTen:
                {
                    _lowTic.text = @"-5\n|";
                    _midLowTic.text = @"-2.5\n|";
                    _midTic.text = @"0\n|";
                    _midHighTic.text = @"+2.5\n|";
                    _highTic.text = @"+5\n|";
                }
                    break;
                    
                case NVSliderControllerRangeTwo:
                {
                    _lowTic.text = @"-1.0\n|";
                    _midLowTic.text = @"-0.5\n|";
                    _midTic.text = @"0.0\n|";
                    _midHighTic.text = @"+0.5\n|";
                    _highTic.text = @"+1.0\n|";
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
       
    }
}

- (void)sliderValueChanged:(NVSliderController *)slider
{
    switch (_configuration)
    {
        case NVSliderConfigurationManualSlope:
        {
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
        }
            
            break;
            
        case NVSliderConfigurationDefault:
        {
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
        }
            
            break;
            
        case NVSliderConfigurationCalibrationRunningSlope:
        {
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f%%", _slider.value];
            
            else if (_range == NVSliderControllerRangeTen)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f%%", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f%%", _slider.value];
        }
            
            break;
            
        case NVSliderConfigurationCalibrationDegrees:
        {
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f\u00B0", _slider.value];
            
            else if (_range == NVSliderControllerRangeTen)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f\u00B0", _slider.value];
        }
            
            break;
            
        case NVSliderConfigurationCalibrationRiseRun:
            _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", _slider.value];
            break;
            
        default:
            break;
    }
    
    _sliderLabel.text = [NSString stringWithFormat:@"%@ %@", _sliderLabel.text, _unit];
}

- (void)saveButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        CGFloat value = [_sliderLabel.text floatValue];
        [_delegate sliderView:self
               didReturnValue:value];
    }
}

- (void)cancelButtonTapped:(UIButton *)button
{
    if (_delegate)
        [_delegate sliderViewDidCancel:self];
}

- (void)rangeButtonTapped:(UIButton *)button
{
    switch (_configuration)
    {
        case NVSliderConfigurationManualSlope:
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                    _slider.minimumValue = (_slider.value - 1.0);
                    _slider.maximumValue = (_slider.value + 1.0);
                    _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                    _range = NVSliderControllerRangeTen;
                    break;
                    
                case NVSliderControllerRangeTen:
                    _slider.minimumValue = (_slider.value - 0.5);
                    _slider.maximumValue = (_slider.value + 0.5);
                    _sliderLabel.text = [NSString stringWithFormat:@"%.2f", _slider.value];
                    _range = NVSliderControllerRangeTwo;
                    break;
                    
                case NVSliderControllerRangeTwo:
                    _slider.minimumValue = _minValue;
                    _slider.maximumValue = _maxValue;
                    _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                    _range = NVSliderControllerRangeMax;
                    break;
                    
                default:
                    break;
            }
        }
            
            break;
            
        case NVSliderConfigurationDefault:
        case NVSliderConfigurationCalibrationRunningSlope:
        case NVSliderConfigurationCalibrationDegrees:
        case NVSliderConfigurationCalibrationRiseRun:
            
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                    _slider.value = roundf(_slider.value);
                    _slider.minimumValue = (_slider.value - 5.0);
                    _slider.maximumValue = (_slider.value + 5.0);
                    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                    
                    if (_configuration == NVSliderConfigurationCalibrationRunningSlope)
                        _sliderLabel.text = [NSString stringWithFormat:@"%.1f%%", _slider.value];
                    
                    else if (_configuration == NVSliderConfigurationCalibrationDegrees)
                        _sliderLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", _slider.value];
                    
                    else if (_configuration == NVSliderConfigurationCalibrationRiseRun)
                        _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", _slider.value];
                    
                    _range = NVSliderControllerRangeTen;
                    break;
                    
                case NVSliderControllerRangeTen:
                    _slider.value = ((roundf(_slider.value * 10.0)) / 10.0);
                    _slider.minimumValue = (_slider.value - 1.0);
                    _slider.maximumValue = (_slider.value + 1.0);
                    _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                    
                    if (_configuration == NVSliderConfigurationCalibrationRunningSlope)
                        _sliderLabel.text = [NSString stringWithFormat:@"%.2f%%", _slider.value];
                    
                    else if (_configuration == NVSliderConfigurationCalibrationDegrees)
                        _sliderLabel.text = [NSString stringWithFormat:@"%.2f\u00B0", _slider.value];
                    
                    else if (_configuration == NVSliderConfigurationCalibrationRiseRun)
                        _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", _slider.value];
                    
                    _range = NVSliderControllerRangeTwo;
                    break;
                    
                case NVSliderControllerRangeTwo:
                    _slider.value = roundf(_slider.value);
                    _slider.minimumValue = _minValue;
                    _slider.maximumValue = _maxValue;
                    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                    
                    if (_configuration == NVSliderConfigurationCalibrationRunningSlope)
                        _sliderLabel.text = [NSString stringWithFormat:@"%.0f%%", _slider.value];
                    
                    else if (_configuration == NVSliderConfigurationCalibrationDegrees)
                        _sliderLabel.text = [NSString stringWithFormat:@"%.0f\u00B0", _slider.value];
                    
                    else if (_configuration == NVSliderConfigurationCalibrationRiseRun)
                        _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", _slider.value];
                    
                    _range = NVSliderControllerRangeMax;
                    break;
                    
                default:
                    break;
            }
        }
            
            break;
            
        default:
            break;
    }
    
    _sliderLabel.text = [NSString stringWithFormat:@"%@ %@", _sliderLabel.text, _unit];
    [self updateTicLabelText];
}

- (void)showSliderControllerInView:(UIView *)view
                          animated:(BOOL)animated
                           overlay:(BOOL)overlay
{
    if (overlay)
    {
        CGRect bounds = UIScreen.mainScreen.bounds;
        _overlayView = [[UIView alloc] initWithFrame:bounds];
        _overlayView.backgroundColor = UIColor.blackColor;
        _overlayView.alpha = 0.0;
        [view addSubview:_overlayView];
        self.layer.borderWidth = 0.0;
    }
    
    if (_type != NVSliderMeasurementTypeDefault)
    {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, (self.frame.origin.y - 120.0),
                                                              self.frame.size.width, 80.0)];
        
        _promptLabel.backgroundColor = UIColor.whiteColor;
        _promptLabel.layer.cornerRadius = 6.0;
        _promptLabel.layer.masksToBounds = YES;
        _promptLabel.textColor = _sliderLabel.textColor;
        _promptLabel.textAlignment = _sliderLabel.textAlignment;
        _promptLabel.font = _sliderLabel.font;
        _promptLabel.adjustsFontSizeToFitWidth = YES;
        
        if (_type == NVSliderMeasurementTypeFrontSlope)
            _promptLabel.text = @"Manual Front Slope Measurement Required";
        
        else if (_type == NVSliderMeasurementTypeSideSlope)
            _promptLabel.text = @"Manual Side Slope Measurement Required";
        
        if (animated)
            _promptLabel.alpha = 0.0;
        
        [view addSubview:_promptLabel];
    }
    
    if (animated)
        self.alpha = 0.0;
    
    [view addSubview:self];
    
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _overlayView.alpha = 0.7;
                             _promptLabel.alpha = 1.0;
                             self.alpha = 1.0;
                         }];
    }
}

- (void)hideSliderController:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _overlayView.alpha = 0.0;
                             _promptLabel.alpha = 0.0;
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [_overlayView removeFromSuperview];
                             [_promptLabel removeFromSuperview];
                             [self removeFromSuperview];
                         }];
    }
    
    else
    {
        [_overlayView removeFromSuperview];
        [self removeFromSuperview];
    }
}

@end