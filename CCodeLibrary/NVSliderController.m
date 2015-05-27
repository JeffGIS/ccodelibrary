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
@property (nonatomic) UILabel *sliderLabel, *lowTic, *highTic, *midTic, *midLowTic, *midHighTic;
@property (nonatomic) UIButton *saveButton, *cancelButton, *rangeButton;
@property (nonatomic) UIView *ticView, *overlayView;
@property (nonatomic) CGFloat minValue, maxValue;
@property NVSliderControllerRange range;
@property NVSliderConfiguration configuration;

@end

@implementation NVSliderController

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate
       configuration:(NVSliderConfiguration)configuration
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
        
        if (_configuration == NVSliderConfigurationManualSlope)
            _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
        
        else
            _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
        
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
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
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
    if (_configuration == NVSliderConfigurationManualSlope)
    {
        if (_range == NVSliderControllerRangeTwo)
            _sliderLabel.text = [NSString stringWithFormat:@"%.2f", _slider.value];
        
        else
            _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
    }
    
    else
    {
        if (_range == NVSliderControllerRangeTwo)
            _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
        
        else
            _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
    }
}

- (void)saveButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        if (_configuration == NVSliderConfigurationDefault &&
            _range != NVSliderControllerRangeTwo)
        {
            _slider.value = roundf(_slider.value);
        }
        
        [_delegate sliderView:self
               didReturnValue:_slider.value];
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
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                    _slider.value = roundf(_slider.value);
                    _slider.minimumValue = (_slider.value - 5.0);
                    _slider.maximumValue = (_slider.value + 5.0);
                    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                    _range = NVSliderControllerRangeTen;
                    break;
                    
                case NVSliderControllerRangeTen:
                    _slider.value = roundf(_slider.value);
                    _slider.minimumValue = (_slider.value - 1.0);
                    _slider.maximumValue = (_slider.value + 1.0);
                    _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                    _range = NVSliderControllerRangeTwo;
                    break;
                    
                case NVSliderControllerRangeTwo:
                    _slider.value = roundf(_slider.value);
                    _slider.minimumValue = _minValue;
                    _slider.maximumValue = _maxValue;
                    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
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
    
    if (animated)
        self.alpha = 0.0;
    
    [view addSubview:self];
    
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _overlayView.alpha = 0.7;
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
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [_overlayView removeFromSuperview];
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