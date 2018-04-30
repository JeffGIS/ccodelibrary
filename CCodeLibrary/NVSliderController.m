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

@property (nonatomic, weak) id <NVSliderControllerDelegate>delegate;
@property (nonatomic) UISlider *slider;
@property (nonatomic) UILabel *sliderLabel, *lowTic, *highTic, *midTic, *midLowTic, *midHighTic, *promptLabel;
@property (nonatomic) UIButton *saveButton, *cancelButton, *rangeButton;
@property (nonatomic) UIView *ticView, *overlayView;
@property (nonatomic) double minValue, maxValue;
@property NVSliderControllerRange range;
@property NVSliderConfiguration configuration;
@property (nonatomic, copy) NSString *unit, *formatString;
@property CGFloat buttonHeight;

@end

@implementation NVSliderController

- (id)initWithCenter:(CGPoint)center
               width:(double)width
          startValue:(double)startValue
            minValue:(double)minValue
            maxValue:(double)maxValue
            delegate:(id)delegate
       configuration:(NVSliderConfiguration)configuration
                type:(NVSliderMeasurementType)type
                unit:(NSString *)unit
{
    double height = 260.0;
    
    self = [super initWithFrame:CGRectMake((center.x - (width / 2.0)),
                                           (center.y - (height / 2.0)), width, height)];
    
    if (self)
    {
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 4.0;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = UIColor.whiteColor;
        _buttonHeight = 56.0;
        _configuration = configuration;
        _delegate = delegate;
        _range = NVSliderControllerRangeMax;
        _minValue = minValue;
        _maxValue = maxValue;
        _type = type;
        _unit = unit;
        
        double capHeight = 29.0;
        double capWidth = (capHeight / 2.0);
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, ((height / 2.0) - (capHeight / 2.0)),
                                                             (width - 20.0), capHeight)];
        
        [_slider setThumbImage:UserDefaults.defaults.redSliderThumb forState:UIControlStateNormal];
        
        UIImage *sliderLeft = [UserDefaults.defaults.metalSliderLeft stretchableImageWithLeftCapWidth:capWidth
                                                                                         topCapHeight:capHeight];
        
        UIImage *sliderRight = [UserDefaults.defaults.metalSliderRight stretchableImageWithLeftCapWidth:capWidth
                                                                                           topCapHeight:capHeight];
        
        [_slider setMinimumTrackImage:sliderLeft forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:sliderRight forState:UIControlStateNormal];
        _slider.minimumValue = _minValue;
        _slider.maximumValue = _maxValue;
        _slider.value = startValue;
        
        [_slider addTarget:self
                    action:@selector(sliderValueChanged)
          forControlEvents:UIControlEventValueChanged];
        
        UIView *ticView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 58.0, width, 64.0)];
        [self addSubview:ticView];
        
        CGSize ticLabelSize = CGSizeMake(80.0, ticView.frame.size.height);
        
        _midTic = [[UILabel alloc] initWithFrame:CGRectMake(((ticView.frame.size.width * 0.5) - (ticLabelSize.width / 2.0)),
                                                            0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:_midTic value:((maxValue + minValue) / 2.0)];
        [ticView addSubview:_midTic];
        
        _lowTic = [[UILabel alloc] initWithFrame:CGRectMake(capWidth, 0.0, ticLabelSize.width, ticLabelSize.height)];
        [self setupLabel:_lowTic value:minValue];
        [ticView addSubview:_lowTic];
        
        _highTic = [[UILabel alloc] initWithFrame:CGRectMake((ticView.frame.size.width - ticLabelSize.width - capWidth),
                                                             0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:_highTic value:maxValue];
        [ticView addSubview:_highTic];
        
        _midLowTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        _midLowTic.center = CGPointMake(((_midTic.center.x + _lowTic.center.x) / 2.0), _midLowTic.center.y);
        [self setupLabel:_midLowTic value:(((minValue * 3.0) + maxValue) / 4.0)];
        [ticView addSubview:_midLowTic];
        
        _midHighTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        _midHighTic.center = CGPointMake(((_midTic.center.x + _highTic.center.x) / 2.0), _midTic.center.y);
        [self setupLabel:_midHighTic value:(((maxValue * 3.0) + minValue) / 4.0)];
        [ticView addSubview:_midHighTic];
        
        [self addSubview:_slider];
        
        _sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 6.0, width, 52.0)];
        _sliderLabel.backgroundColor = UIColor.clearColor;
        
        switch (_configuration)
        {
            case NVSliderConfigurationManualSlope:
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                break;
            case NVSliderConfigurationFacilities:
                if (_slider.maximumValue - _slider.minimumValue > 10.0)
                    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                
                else
                    _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                break;
            case NVSliderConfigurationDefault:
            case NVSliderConfigurationDefaultNoRange:
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
            default:break;
        }
        
        _sliderLabel.text = [NSString stringWithFormat:@"%@ %@", _sliderLabel.text, _unit];
        _sliderLabel.textColor = UIColor.blackColor;
        _sliderLabel.font = [UIFont boldSystemFontOfSize:56.0];
        _sliderLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_sliderLabel];
        
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.05), (height - 72.0),
                                                                 (width * 0.3), _buttonHeight)];
        
        [self setupButton:_saveButton
                   target:self
                 selector:@selector(saveButtonTapped:)
                    title:@"Save"];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.65), (height - 72.0),
                                                                   (width * 0.3), _buttonHeight)];
        
        [self setupButton:_cancelButton
                   target:self
                 selector:@selector(cancelButtonTapped:)
                    title:@"Cancel"];
        
        if (_configuration == NVSliderConfigurationDefault)
        {
            _rangeButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.4), (height - 72.0),
                                                                      (width * 0.2), _buttonHeight)];
            
            [self setupButton:_rangeButton
                       target:self
                     selector:@selector(rangeButtonTapped:)
                        title:@"Range"];
        }
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
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (void)setupLabel:(UILabel *)label
             value:(double)value
{
    label.numberOfLines = 2;
    
    if (_configuration == NVSliderConfigurationFacilities)
    {
        if (_slider.maximumValue - _slider.minimumValue > 10.0)
            label.text = [NSString stringWithFormat:@"%.0f\n|", value];
        
        else
            label.text = [NSString stringWithFormat:@"%.1f\n|", value];
    }
    
    else if (_configuration == NVSliderConfigurationManualSlope)
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
    if (_formatString && _formatString.length)
    {
        NSString *format = [NSString stringWithFormat:@"%@\n|", _formatString];
        _lowTic.text = [NSString stringWithFormat:format, _minValue];
        
        _midLowTic.text = [NSString stringWithFormat:format,
                           (((_minValue * 3.0) + _maxValue) / 4.0)];
        
        _midTic.text = [NSString stringWithFormat:format,
                        ((_maxValue + _minValue) / 2.0)];
        
        _midHighTic.text = [NSString stringWithFormat:format,
                            (((_maxValue * 3.0) + _minValue) / 4.0)];
        
        _highTic.text = [NSString stringWithFormat:format, _maxValue];
    }
    
    else switch (_configuration)
    {
        case NVSliderConfigurationManualSlope:
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                    _lowTic.text = [NSString stringWithFormat:@"%.1f\n|", _minValue];
                    
                    _midLowTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                       (((_minValue * 3.0) + _maxValue) / 4.0)];
                    
                    _midTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                    ((_maxValue + _minValue) / 2.0)];
                    
                    _midHighTic.text = [NSString stringWithFormat:@"%.1f\n|",
                                        (((_maxValue * 3.0) + _minValue) / 4.0)];
                    
                    _highTic.text = [NSString stringWithFormat:@"%.1f\n|", _maxValue];
                    break;
                case NVSliderControllerRangeTen:
                    _lowTic.text = @"-1.0\n|";
                    _midLowTic.text = @"-0.5\n|";
                    _midTic.text = @"0.0\n|";
                    _midHighTic.text = @"+0.5\n|";
                    _highTic.text = @"+1.0\n|";
                    break;
                case NVSliderControllerRangeTwo:
                    _lowTic.text = @"-.50\n|";
                    _midLowTic.text = @"-.25\n|";
                    _midTic.text = @".00\n|";
                    _midHighTic.text = @"+.25\n|";
                    _highTic.text = @"+.50\n|";
                    break;
                default:break;
            }
        }
            break;
        case NVSliderConfigurationDefault:
        case NVSliderConfigurationDefaultNoRange:
        case NVSliderConfigurationCalibrationRunningSlope:
        case NVSliderConfigurationCalibrationDegrees:
        case NVSliderConfigurationCalibrationRiseRun:
            switch (_range)
        {
            case NVSliderControllerRangeMax:
                _lowTic.text = [NSString stringWithFormat:@"%.0f\n|", _minValue];
                
                _midLowTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                   (((_minValue * 3.0) + _maxValue) / 4.0)];
                
                _midTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                ((_maxValue + _minValue) / 2.0)];
                
                _midHighTic.text = [NSString stringWithFormat:@"%.0f\n|",
                                    (((_maxValue * 3.0) + _minValue) / 4.0)];
                
                _highTic.text = [NSString stringWithFormat:@"%.0f\n|", _maxValue];
                break;
            case NVSliderControllerRangeTen:
                _lowTic.text = @"-5\n|";
                _midLowTic.text = @"-2.5\n|";
                _midTic.text = @"0\n|";
                _midHighTic.text = @"+2.5\n|";
                _highTic.text = @"+5\n|";
                break;
            case NVSliderControllerRangeTwo:
                _lowTic.text = @"-1.0\n|";
                _midLowTic.text = @"-0.5\n|";
                _midTic.text = @"0.0\n|";
                _midHighTic.text = @"+0.5\n|";
                _highTic.text = @"+1.0\n|";
                break;
            default:break;
        }
            break;
        default:break;
    }
}

- (void)sliderValueChanged
{
    if (_formatString && _formatString.length)
        _sliderLabel.text = [NSString stringWithFormat:_formatString, _slider.value];
    
    else switch (_configuration)
    {
        case NVSliderConfigurationFacilities:
            if (_slider.maximumValue - _slider.minimumValue > 10.0)
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
            break;
        case NVSliderConfigurationManualSlope:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
            break;
        case NVSliderConfigurationDefault:
        case NVSliderConfigurationDefaultNoRange:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
            break;
        case NVSliderConfigurationCalibrationRunningSlope:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f%%", _slider.value];
            
            else if (_range == NVSliderControllerRangeTen)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f%%", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f%%", _slider.value];
            break;
        case NVSliderConfigurationCalibrationDegrees:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f\u00B0", _slider.value];
            
            else if (_range == NVSliderControllerRangeTen)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", _slider.value];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f\u00B0", _slider.value];
            break;
        case NVSliderConfigurationCalibrationRiseRun:
            _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", _slider.value];
            break;
        default:break;
    }
    
    _sliderLabel.text = [NSString stringWithFormat:@"%@ %@", _sliderLabel.text, _unit];
}

- (void)saveButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        double value = [_sliderLabel.text floatValue];
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
                default:break;
            }
            break;
        case NVSliderConfigurationDefault:
        case NVSliderConfigurationDefaultNoRange:
        case NVSliderConfigurationCalibrationRunningSlope:
        case NVSliderConfigurationCalibrationDegrees:
        case NVSliderConfigurationCalibrationRiseRun:
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
                default:break;
            }
            break;
        default:break;
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
            _promptLabel.text = @"Manual Running Slope Measurement Required";
        
        else if (_type == NVSliderMeasurementTypeSideSlope)
            _promptLabel.text = @"Manual Cross Slope Measurement Required";
        
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

- (void)addTitle:(NSString *)title
          prompt:(NSString *)prompt
            help:(BOOL)help
       reference:(BOOL)reference
            link:(BOOL)link
         comment:(BOOL)comment
{
    CGFloat fontSize = 24.0;
    CGFloat margin = 20.0;
    _usedTopSpace = margin;
    UILabel *label = nil;
    
    if (title && title.length)
    {
        title = removeEndingReturn(title);
        NSInteger lines = [title componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet].count;
        CGFloat titleHeight = (lines * (fontSize * 1.2));
        
        label = UILabel.new;
        label.frame = CGRectMake(0.0, _usedTopSpace, self.frame.size.width, titleHeight);
        label.text = title;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.blackColor;
        label.font = [UIFont boldSystemFontOfSize:fontSize];
        _usedTopSpace += (titleHeight + margin);
        
        [self.superview addSubview:label];
    }
    
    if (prompt && prompt.length)
    {
        label = UILabel.new;
        label.frame = CGRectMake(0.0, _usedTopSpace, self.frame.size.width, (fontSize * 1.8));
        label.text = prompt;
        label.numberOfLines = 0;
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.blackColor;
        label.font = [UIFont boldSystemFontOfSize:(fontSize * 1.2)];
        _usedTopSpace += (label.frame.size.height + margin);
        
        [self.superview addSubview:label];
    }
    
    if (help || reference || link || comment)
    {
        CGFloat buttonWidth = (self.frame.size.width / 4);
        
        UIButton *button = nil;
        
        if (help)
        {
            button = [self facButton:@"Help" tag:NVFacButtonTypeHelp];
            button.frame = CGRectMake(0.0, _usedTopSpace, buttonWidth, _buttonHeight);
            [self.superview addSubview:button];
        }
        
        if (reference)
        {
            button = [self facButton:@"Reference" tag:NVFacButtonTypeReference];
            button.frame = CGRectMake(buttonWidth, _usedTopSpace, buttonWidth, _buttonHeight);
            [self.superview addSubview:button];
        }
        
        if (link)
        {
            button = [self facButton:@"Link" tag:NVFacButtonTypeLink];
            button.frame = CGRectMake((buttonWidth * 2), _usedTopSpace, buttonWidth, _buttonHeight);
            [self.superview addSubview:button];
        }
        
        if (comment)
        {
            button = [self facButton:@"Comment" tag:NVFacButtonTypeComment];
            button.frame = CGRectMake((buttonWidth * 3), _usedTopSpace, buttonWidth, _buttonHeight);
            [self.superview addSubview:button];
        }
        
        _usedTopSpace += (_buttonHeight + margin);
    }
}

- (UIButton *)facButton:(NSString *)title
                    tag:(NVFacButtonType)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UserDefaults.defaults.appleBlue forState:UIControlStateNormal];
    [button setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button addTarget:self
               action:@selector(facButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)facButtonTapped:(UIButton *)button
{
    [_delegate sliderViewDidTapButton:button];
}

- (void)removeRequiredFromLabel
{
    _promptLabel.text = [_promptLabel.text stringByReplacingOccurrencesOfString:@" Required"
                                                                     withString:@""];
}

- (void)setNumDecimals:(int)numDecimals
{
    _formatString = [NSString stringWithFormat:@"%%.%df", numDecimals];
    [self updateTicLabelText];
    [self sliderValueChanged];
}

@end
