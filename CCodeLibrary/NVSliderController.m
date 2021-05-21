//  NVSliderController.m
//  CCodeLibrary

#import "NVSliderController.h"
#import "UserDefaults.h"
#import "SharedDefaults.h"
#import "GSSiDefs.h"

static BOOL useBosch = FALSE;

typedef NS_ENUM(NSInteger, NVSliderControllerRange)
{
    NVSliderControllerRangeDefault,
    NVSliderControllerRangeMax,
    NVSliderControllerRangeTen,
    NVSliderControllerRangeTwo,
};

@interface NVSliderController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <NVSliderControllerDelegate>delegate;
@property (nonatomic) UISlider *slider;
@property (nonatomic) UILabel *sliderLabel, *lowTic, *highTic, *midTic, *midLowTic, *midHighTic, *promptLabel;
@property (nonatomic) UIButton *saveButton, *cancelButton, *rangeButton, *boschButton;
@property (nonatomic) UIView *ticView, *overlayView;
@property double minValue, maxValue, unitFactor;
@property NVSliderControllerRange range;
@property NVSliderConfiguration configuration;
@property (nonatomic, copy) NSString *unit, *origUnit, *formatString;
@property CGFloat buttonHeight;
@property int origNumDecimals;
@property BOOL titleAdded;

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
          allowBosch:(BOOL)allowBosch
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
        self.allowBosch = allowBosch;
        _buttonHeight = 56.0;
        _configuration = configuration;
        _delegate = delegate;
        _range = NVSliderControllerRangeMax;
        _minValue = minValue;
        _maxValue = maxValue;
        _type = type;
        _unit = _origUnit = unit;
        _unitFactor = 1.0;
        _origNumDecimals = -1;
        
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
        
        CGFloat labelHeight = 52.0;
        CGFloat labelMargin = (labelHeight * 1.5 + _slider.frame.origin.x);
        _sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMargin, 0.0, (width - (labelMargin * 2.0)), labelHeight)];
        _sliderLabel.backgroundColor = UIColor.clearColor;
        if (_allowBosch)
        {
            _boschButton = [[UIButton alloc] initWithFrame:CGRectMake((width -labelMargin), 0,
                                                                       labelMargin, labelHeight)];
            [self setupButton:_boschButton
                       target:self
                     selector:@selector(gotoBoschTapped:)
                        title:@"ULD"];
            CRAPI.sharedInstance.currentMeasurementView = self;
        }
        switch (_configuration)
        {
            case NVSliderConfigurationManualSlope:
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", _slider.value];
                break;
            case NVSliderConfigurationFacilities:
                if (_slider.maximumValue - _slider.minimumValue > 10.0)
                    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                
                else
                    self.numDecimals = 1;
                break;
            case NVSliderConfigurationDefault:
            case NVSliderConfigurationDefaultNoRange:
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
                break;
            case NVSliderConfigurationCalibrationRunningSlope:
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f%%", _slider.value];
                break;
            case NVSliderConfigurationCalibrationDegrees:
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", _slider.value];
                break;
            case NVSliderConfigurationCalibrationRiseRun:
                _sliderLabel.text = [NSString stringWithFormat:@"1:%.1f", _slider.value];
                break;
            default:break;
        }
        
        if (![_sliderLabel.text containsString:_unit])
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
        
        if (_configuration == NVSliderConfigurationDefault || _configuration == NVSliderConfigurationCalibrationRunningSlope)
        {
            _rangeButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.4), (height - 72.0),
                                                                      (width * 0.2), _buttonHeight)];
            
            [self setupButton:_rangeButton
                       target:self
                     selector:@selector(rangeButtonTapped:)
                        title:@"Range"];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(sliderTapped:)];
        
        tap.delegate = self;
        [_slider addGestureRecognizer:tap];
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
    
    label.font = [UIFont systemFontOfSize:24.0];
    label.textColor = UIColor.redColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [_ticView addSubview:label];
}

- (void)updateTicLabelText
{
    double minValue = (_slider.minimumValue * _unitFactor);
    double maxValue = (_slider.maximumValue * _unitFactor);
    double midLow = (((minValue * 3.0) + maxValue) / 4.0);
    double mid = ((maxValue + minValue) / 2.0);
    double midHigh = (((maxValue * 3.0) + minValue) / 4.0);
    
    if (_formatString && _formatString.length)
    {
        NSString *format = [NSString stringWithFormat:@"%@\n|", _formatString];
        _lowTic.text = [NSString stringWithFormat:format, minValue];
        _midLowTic.text = [NSString stringWithFormat:format, midLow];
        _midTic.text = [NSString stringWithFormat:format, mid];
        _midHighTic.text = [NSString stringWithFormat:format, midHigh];
        _highTic.text = [NSString stringWithFormat:format, maxValue];
    }
    
    else switch (_configuration)
    {
        case NVSliderConfigurationManualSlope:
        {
            switch (_range)
            {
                case NVSliderControllerRangeMax:
                    _lowTic.text = [NSString stringWithFormat:@"%.1f\n|", minValue];
                    _midLowTic.text = [NSString stringWithFormat:@"%.1f\n|", midLow];
                    _midTic.text = [NSString stringWithFormat:@"%.1f\n|", mid];
                    _midHighTic.text = [NSString stringWithFormat:@"%.1f\n|", midHigh];
                    _highTic.text = [NSString stringWithFormat:@"%.1f\n|", maxValue];
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
                _lowTic.text = [NSString stringWithFormat:@"%.0f\n|", minValue];
                _midLowTic.text = [NSString stringWithFormat:@"%.0f\n|", midLow];
                _midTic.text = [NSString stringWithFormat:@"%.0f\n|", mid];
                _midHighTic.text = [NSString stringWithFormat:@"%.0f\n|", midHigh];
                _highTic.text = [NSString stringWithFormat:@"%.0f\n|", maxValue];
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
    double labelValue = (_slider.value * _unitFactor);
    
    if (_formatString && _formatString.length)
    {
        _sliderLabel.text = [NSString stringWithFormat:_formatString, labelValue];
        labelValue = [_sliderLabel.text doubleValue]/_unitFactor;
        [_slider setValue:labelValue animated:NO];
    }
    else switch (_configuration)
    {
        case NVSliderConfigurationFacilities:
            if (_slider.maximumValue - _slider.minimumValue > 10.0)
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", labelValue];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", labelValue];
            break;
        case NVSliderConfigurationManualSlope:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f", labelValue];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", labelValue];
            break;
        case NVSliderConfigurationDefault:
        case NVSliderConfigurationDefaultNoRange:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f", labelValue];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f", labelValue];
            break;
        case NVSliderConfigurationCalibrationRunningSlope:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f%%", labelValue];
            
            else if (_range == NVSliderControllerRangeTen)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f%%", labelValue];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f%%", labelValue];
            break;
        case NVSliderConfigurationCalibrationDegrees:
            if (_range == NVSliderControllerRangeTwo)
                _sliderLabel.text = [NSString stringWithFormat:@"%.2f\u00B0", labelValue];
            
            else if (_range == NVSliderControllerRangeTen)
                _sliderLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", labelValue];
            
            else
                _sliderLabel.text = [NSString stringWithFormat:@"%.0f\u00B0", labelValue];
            break;
        case NVSliderConfigurationCalibrationRiseRun:
            _sliderLabel.text = [NSString stringWithFormat:@"1:%.0f", labelValue];
            break;
        default:break;
    }
    
    _sliderLabel.text = [NSString stringWithFormat:@"%@ %@", _sliderLabel.text, _unit];
}

- (void)saveButtonTapped:(UIButton *)button
{
    CRAPI.sharedInstance.currentMeasurementView = 0;

    if (_delegate && [_delegate respondsToSelector:@selector(sliderView:didReturnValue:)])
    {
        if (![_unit.uppercaseString isEqualToString:_origUnit.uppercaseString])
            [self switcherTapped];
        
        double value = [textBefore(_sliderLabel.text, @" ") doubleValue];
        [_delegate sliderView:self didReturnValue:value];
    }
}


- (void)cancelButtonTapped:(UIButton *)button
{
    CRAPI.sharedInstance.currentMeasurementView = 0;
    if (_delegate)
        [_delegate sliderViewDidCancel:self];
}

-(double) adjustValue:(double) inVal
            fromUnits:(NSString *)inUnits
{
    double outVal = 0;
    
    if ([inUnits isEqual:@"m"])
    {
        if ([_unit isEqual:@"Inches"])
        {
            outVal = inVal * MFT * 12;
        }
        else if ([_unit isEqual:@"Feet"])
        {
            outVal = inVal * MFT;
        }
    }
    return outVal;
}
-(void) setMeasurementValues
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    //SharedDefaults *defaults = [SharedDefaults defaults];
    NSString * returnedValues = [defaults stringForKey:@"MeasurementValues"];
    NSArray<NSString *> * array  = [returnedValues componentsSeparatedByString:@"!"];
    if (array.count == 1)
    {
        NSString * value = array[0];
        NSString * cvalue = textBefore (value,@"|");
        if ([cvalue isEqual:@"EnterManually"])
        {
            useBosch = NO;
        }
    }
    else if (array.count == 3)
    {
        NSString * dist = array[0];
        NSString * value = textAfter(dist,@"|");
        NSString * incomingUnits = textAfter (value,@" ");
        NSString * cvalue = textBefore (value,@" ");
        double dvalue = cvalue.doubleValue;
        _slider.value = [self adjustValue:dvalue fromUnits:incomingUnits];
        [_slider setValue:_slider.value animated:NO];
        [self updateSliderLabel];
        [self sliderValueChanged];

    }
    
    return;
}
- (void)updateSliderLabel
{
    double value = 0.0;
    
    if (_roundToTenths)
    {
        value = roundf(_slider.value * 10.0) / 10.0;
        _sliderLabel.text = [NSString stringWithFormat:@"%.1f %@", value, _unit];
    }
    
    else
    {
        value = roundf(_slider.value);
        _sliderLabel.text = [NSString stringWithFormat:@"%.0f %@", value, _unit];
    }
}

void returnToCallerInOC2 (void)
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    //SharedDefaults *defaults = [SharedDefaults defaults];
    NSString * returnUrl = [defaults stringForKey:@"MeasureSourceApplication"];
    NSLog (@"%@",returnUrl);
    return;
}
-(void)gotoBoschTapped:(UIButton *)button
{
    NSString *measureURL = @"DeviceConnect://";
    [SharedDefaults.defaults saveString:@"FISDetail://" forKey:@"MeasureSourceApplication"];
    returnToCallerInOC2();
    if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:measureURL]])
    {
        useBosch = YES;
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:measureURL]];
    }
    else
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self
                                                          delegate:self
                                                             title:@"NVMobile cannot launch DeviceConnect App"
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
        
        alert.identifier = @"CannotLaunchDeviceConnectApp";
    }
    
    return;
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
    if (_titleAdded)
        return;
    
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
        _titleAdded = YES;
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
    if (_origNumDecimals == -1)
        _origNumDecimals = numDecimals;
    
    _numDecimals = numDecimals;
    _formatString = [NSString stringWithFormat:@"%%.%df", MAX(0, numDecimals)];
    [self updateTicLabelText];
    [self sliderValueChanged];
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_slider];
    double percentage = (point.x / _slider.bounds.size.width);
    double delta = (percentage * (_slider.maximumValue - _slider.minimumValue));
    double rawValue = (_slider.minimumValue + delta);
    double medianValue = ((_slider.maximumValue + _slider.minimumValue) / 2.0);
    double value = (rawValue - ((medianValue - rawValue) * 0.15));
    [_slider setValue:value animated:NO];
    [self sliderValueChanged];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL rtn = YES;
    
    for (UIImageView *imageView in _slider.subviews)
    {
        if ([imageView isKindOfClass:UIImageView.class])
        {
            if (imageView.image == _slider.currentThumbImage)
            {
                CGPoint point = [gestureRecognizer locationInView:_slider];
                
                if (CGRectContainsPoint(imageView.frame, point))
                {
                    rtn = NO;
                    break;
                }
            }
        }
    }
    
    return rtn;
}

- (void)showStepper
{
    CGFloat height = _saveButton.frame.size.height;
    UISegmentedControl *stepperSC = [[UISegmentedControl alloc] initWithItems:@[@"-", @"+"]];
    stepperSC.momentary = YES;
    stepperSC.tintColor = UIColor.blackColor;
    
    [stepperSC setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:48.0]
                                                                  forKey:NSFontAttributeName]
                             forState:UIControlStateNormal];
    
    [stepperSC setContentPositionAdjustment:UIOffsetMake(0.0, -2.0)
                             forSegmentType:UISegmentedControlSegmentAny
                                 barMetrics:UIBarMetricsDefault];
    
    stepperSC.frame = CGRectMake(0.0, 0.0, (height * 2.0), height);
    stepperSC.center = CGPointMake(((_saveButton.center.x + _cancelButton.center.x) / 2.0), _saveButton.center.y);
    [self addSubview:stepperSC];
    
    [stepperSC addTarget:self
                  action:@selector(stepperSCTapped:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)stepperSCTapped:(UISegmentedControl *)stepperSC
{
    float gradient = 1.0;
    
    if (_numDecimals > 0)
        gradient = (1 / pow(10.0, _numDecimals));
    
    float newValue = _slider.value;
    
    switch (stepperSC.selectedSegmentIndex)
    {
        case 0:
            newValue -= gradient / _unitFactor ;
            break;
        case 1:
            newValue += gradient / _unitFactor;
            break;
        default:break;
    }
    
    [_slider setValue:newValue animated:NO];
    [self sliderValueChanged];
}

- (void)showUnitSwitcher
{
    UIButton *switcher = [UIButton buttonWithType:UIButtonTypeCustom];
    switcher.translatesAutoresizingMaskIntoConstraints = NO;
    switcher.layer.borderWidth = 1.0;
    switcher.layer.borderColor = UIColor.blackColor.CGColor;
    switcher.layer.cornerRadius = 4.0;
    
    [switcher setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"twoWayArrow"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [switcher setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"twoWayArrowHighlighted"
                                                                                      ofType:@"png"]]
              forState:UIControlStateHighlighted];
    
    [switcher addTarget:self
                 action:@selector(switcherTapped)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:switcher];
    [switcher constrainWidthToAnchor:switcher.heightAnchor];
    [switcher constrainTrailingToAnchor:_sliderLabel.leadingAnchor];
    [switcher constrainTopToAnchor:_sliderLabel.topAnchor];
    [switcher constrainBottomToAnchor:_sliderLabel.bottomAnchor];
}

- (void)switcherTapped
{
    NSString *unit = _unit.uppercaseString;
    NSString *origUnit = _origUnit.uppercaseString;
    
    if (_origNumDecimals == -1)
        _origNumDecimals = _numDecimals;
    
    if ([unit isEqualToString:@"FEET"])
    {
        _unit = @"Inches";
        
        if ([origUnit isEqualToString:@"FEET"])
            _unitFactor = 12.0;
        
        else if ([origUnit isEqualToString:@"INCHES"])
            _unitFactor = 1.0;
        
        self.numDecimals--;
    }
    
    else if ([unit isEqualToString:@"INCHES"])
    {
        if (_allowSteps)
        {
            _unit = @"Steps";
            _unitFactor = 1.0/CRAPI.sharedInstance.feetPerStep;
            if ([origUnit isEqualToString:@"INCHES"])
            {
                _unitFactor = (_unitFactor / 12.0);
                self.numDecimals++;
            }
            else
                self.numDecimals = 1;
        }
        else
        {
            _unit = @"Feet";
            if ([origUnit isEqualToString:@"INCHES"])
                _unitFactor = (1.0 / 12.0);
            else if ([origUnit isEqualToString:@"FEET"])
                _unitFactor = 1.0;
            self.numDecimals++;
        }
    }
    
    else if ([unit isEqualToString:@"STEPS"])
    {
        _unit = @"Feet";
        
        if ([origUnit isEqualToString:@"INCHES"])
        {
            _unitFactor = (1.0 / 12.0);
            self.numDecimals++;
        }
        
        else if ([origUnit isEqualToString:@"FEET"])
        {
            _unitFactor = 1.0;
            self.numDecimals = _origNumDecimals;
        }
        
     }
    
    [self sliderValueChanged];
}

@end
