//  NVPopoverSlider.m
//  CCodeLibrary

#import "GSSiDefs.h"
#import "NVPopoverSlider.h"
#import "UserDefaults.h"
#import "SharedDefaults.h"
#import "CRAPI.h"

@interface NVPopoverSlider ()

@property (nonatomic) UIView *fromView;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UISlider *slider;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) UILabel *titleLabel, *valueLabel;
@property (nonatomic) UIButton *left, *right, *mid, *leftMid, *rightMid, *cancelButton;
@property (nonatomic, weak) id <NVPopoverSliderDelegate> delegate;
@property float initialValue, initialMin, initialMax;
@property (nonatomic) UISwitch *modeSwitch;

@end

static BOOL useBosch = FALSE;

@implementation NVPopoverSlider
- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    return;
}

+ (instancetype)showPopoverSliderInView:(UIView *)view
                               minValue:(float)minValue
                               maxValue:(float)maxValue
                             startValue:(float)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag
                                  title:(NSString *)title
                             allowBosch:(BOOL)allowBosch;

{
    if (!delegate || !view)
    {
        NSLog(@"NVPopoverSlider ERROR:Cannot set delegate or view to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(popoverSlider:didReturnValue:tag:)] ||
        ![delegate respondsToSelector:@selector(popoverSliderDidCancel:)])
    {
        NSLog(@"NVPopoverSlider ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat shortestSide = MIN(bounds.size.height, bounds.size.width);
    CGFloat height = (shortestSide * 0.95);
    CGFloat width = 80.0;
    
    NVPopoverSlider *nvps = NVPopoverSlider.new;
    nvps.translatesAutoresizingMaskIntoConstraints = NO;
    nvps.delegate = delegate;
    nvps.title = title;
    nvps.tabBar = view.parentViewController.tabBarController.tabBar;
    nvps.tabBar.userInteractionEnabled = NO;
    nvps.tag = tag;
    nvps.alpha = 0.0;
    nvps.backgroundColor = UIColor.whiteColor;
    nvps.layer.cornerRadius = 10.0;
    nvps.units = @"";
    nvps.allowBosch = allowBosch;
    nvps.fromView = view;
    
    nvps.overlayView = UIView.new;
    nvps.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    nvps.overlayView.backgroundColor = UIColor.blackColor;
    nvps.overlayView.alpha = 0.0;
    
    [view addSubview:nvps.overlayView];
    [nvps.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    [view addSubview:nvps];
    [nvps constrainLeadingToAnchor:view.leadingAnchor constant:(height * 0.1)];
    [nvps constrainTrailingToAnchor:view.trailingAnchor constant:-(height * 0.1)];
    [nvps constrainHeightToConstant:height];
    [nvps constrainCenterYToAnchor:view.centerYAnchor constant:(nvps.tabBar.frame.size.height * 0.5)];
    
    UIImage *sliderLeft = nil, *sliderRight = nil;
    double capHeight = 0.0, capWidth = 0.0, offset = 0.0;
    
    nvps.slider = UISlider.new;
    nvps.slider.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        capHeight = 20.0, capWidth = 10.0, offset = 28.0;
        
        sliderLeft = [UserDefaults.defaults.metalSliderLeftPhone stretchableImageWithLeftCapWidth:capWidth
                                                                                     topCapHeight:capHeight];
        
        sliderRight = [UserDefaults.defaults.metalSliderRightPhone stretchableImageWithLeftCapWidth:capWidth
                                                                                       topCapHeight:capHeight];
        
        [nvps.slider setThumbImage:UserDefaults.defaults.redSliderThumbPhone
                          forState:UIControlStateNormal];
    }
    
    else
    {
        capHeight = 29.0, capWidth = 14.5, offset = 40.0;
        
        sliderLeft = [UserDefaults.defaults.metalSliderLeft stretchableImageWithLeftCapWidth:capWidth
                                                                                topCapHeight:capHeight];
        
        sliderRight = [UserDefaults.defaults.metalSliderRight stretchableImageWithLeftCapWidth:capWidth
                                                                                  topCapHeight:capHeight];
        
        [nvps.slider setThumbImage:UserDefaults.defaults.redSliderThumb
                          forState:UIControlStateNormal];
    }
    
    [nvps.slider setMinimumTrackImage:sliderLeft
                             forState:UIControlStateNormal];
    
    [nvps.slider setMaximumTrackImage:sliderRight
                             forState:UIControlStateNormal];
    
    nvps.slider.minimumValue = nvps.initialMin = minValue;
    nvps.slider.maximumValue = nvps.initialMax = maxValue;
    nvps.slider.value = nvps.initialValue = startValue;
    
    [nvps.slider addTarget:nvps
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    
    [nvps addSubview:nvps.slider];
    [nvps.slider constrainLeadingToAnchor:nvps.leadingAnchor constant:(height * 0.05)];
    [nvps.slider constrainTrailingToAnchor:nvps.trailingAnchor constant:-(height * 0.05)];
    [nvps.slider constrainTopToAnchor:nvps.centerYAnchor constant:-(height * 0.1)];
    
    nvps.tap = [[UITapGestureRecognizer alloc] initWithTarget:nvps
                                                       action:@selector(sliderTapped:)];
    
    [nvps.slider addGestureRecognizer:nvps.tap];
    
    UIView *ticView = UIView.new;
    ticView.translatesAutoresizingMaskIntoConstraints = NO;
    ticView.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:ticView];
    offset = 11;
    [ticView constrainLeadingToAnchor:nvps.slider.leadingAnchor constant:offset];
    [ticView constrainTrailingToAnchor:nvps.slider.trailingAnchor constant:-offset];
    [ticView constrainBottomToAnchor:nvps.slider.centerYAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [ticView constrainHeightToConstant:(capHeight * 1.5)];
    
    else
        [ticView constrainHeightToConstant:(capHeight * 1.75)];
    
    UIView *midTic = UIView.new;
    midTic.translatesAutoresizingMaskIntoConstraints = NO;
    midTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:midTic];
    [midTic constrainTopToAnchor:ticView.topAnchor];
    [midTic constrainBottomToAnchor:ticView.bottomAnchor];
    [midTic constrainCenterXToAnchor:ticView.centerXAnchor];
    [midTic constrainWidthToConstant:2.0];
    
    UIView *leftTic = UIView.new;
    leftTic.translatesAutoresizingMaskIntoConstraints = NO;
    leftTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:leftTic];
    [leftTic constrainTopToAnchor:ticView.topAnchor];
    [leftTic constrainBottomToAnchor:ticView.bottomAnchor];
    [leftTic constrainLeadingToAnchor:ticView.leadingAnchor];
    [leftTic constrainWidthToAnchor:midTic.widthAnchor];
    
    [nvps bringSubviewToFront:nvps.slider];

    UIView *rightTic = UIView.new;
    rightTic.translatesAutoresizingMaskIntoConstraints = NO;
    rightTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:rightTic];
    [rightTic constrainTopToAnchor:ticView.topAnchor];
    [rightTic constrainBottomToAnchor:ticView.bottomAnchor];
    [rightTic constrainTrailingToAnchor:ticView.trailingAnchor];
    [rightTic constrainWidthToAnchor:midTic.widthAnchor];
    
    UIView *leftFill = UIView.new;
    leftFill.translatesAutoresizingMaskIntoConstraints = NO;
    leftFill.backgroundColor = UIColor.clearColor;
    leftFill.backgroundColor = UIColor.redColor;

    [ticView addSubview:leftFill];
    [leftFill constrainTopToAnchor:ticView.topAnchor];
    [leftFill constrainBottomToAnchor:ticView.bottomAnchor];
    [leftFill constrainLeadingToAnchor:leftTic.leadingAnchor];
    [leftFill constrainTrailingToAnchor:midTic.leadingAnchor];
    
    UIView *leftMidTic = UIView.new;
    leftMidTic.translatesAutoresizingMaskIntoConstraints = NO;
    leftMidTic.backgroundColor = UIColor.blackColor;
    
    [leftFill addSubview:leftMidTic];
    [leftMidTic constrainTopToAnchor:leftFill.topAnchor];
    [leftMidTic constrainBottomToAnchor:leftFill.bottomAnchor];
    [leftMidTic constrainCenterXToAnchor:leftFill.centerXAnchor];
    [leftMidTic constrainWidthToAnchor:midTic.widthAnchor];
    
    UIView *rightFill = UIView.new;
    rightFill.translatesAutoresizingMaskIntoConstraints = NO;
    rightFill.backgroundColor = UIColor.clearColor;
    
    [ticView addSubview:rightFill];
    [rightFill constrainTopToAnchor:ticView.topAnchor];
    [rightFill constrainBottomToAnchor:ticView.bottomAnchor];
    [rightFill constrainLeadingToAnchor:midTic.trailingAnchor];
    [rightFill constrainTrailingToAnchor:rightTic.leadingAnchor];
    
    UIView *rightMidTic = UIView.new;
    rightMidTic.translatesAutoresizingMaskIntoConstraints = NO;
    rightMidTic.backgroundColor = UIColor.blackColor;
    
    [rightFill addSubview:rightMidTic];
    [rightMidTic constrainTopToAnchor:rightFill.topAnchor];
    [rightMidTic constrainBottomToAnchor:rightFill.bottomAnchor];
    [rightMidTic constrainCenterXToAnchor:rightFill.centerXAnchor];
    [rightMidTic constrainWidthToAnchor:midTic.widthAnchor];
    
    UIView *ticValuesView = UIView.new;
    ticValuesView.translatesAutoresizingMaskIntoConstraints = NO;
    ticValuesView.backgroundColor = UIColor.clearColor;
    ticValuesView.clipsToBounds = NO;
    
    [nvps addSubview:ticValuesView];
    [ticValuesView constrainLeadingToAnchor:ticView.leadingAnchor constant:(-width / 2.0)];
    [ticValuesView constrainTrailingToAnchor:ticView.trailingAnchor constant:(width / 2.0)];
    [ticValuesView constrainBottomToAnchor:ticView.topAnchor];
    [ticValuesView constrainHeightToConstant:capHeight];
    
    nvps.left = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupTicButton:nvps.left];
    [ticValuesView addSubview:nvps.left];
    [nvps.left constrainTopToAnchor:ticValuesView.topAnchor];
    [nvps.left constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [nvps.left constrainCenterXToAnchor:ticValuesView.leadingAnchor constant:(width / 2.0)];
    [nvps.left constrainWidthToConstant:width];
    
    nvps.right = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupTicButton:nvps.right];
    [ticValuesView addSubview:nvps.right];
    [nvps.right constrainTopToAnchor:ticValuesView.topAnchor];
    [nvps.right constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [nvps.right constrainCenterXToAnchor:ticValuesView.trailingAnchor constant:(-width / 2.0)];
    [nvps.right constrainWidthToConstant:width];
    
    nvps.mid = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupTicButton:nvps.mid];
    [ticValuesView addSubview:nvps.mid];
    [nvps.mid constrainTopToAnchor:ticValuesView.topAnchor];
    [nvps.mid constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [nvps.mid constrainCenterXToAnchor:ticValuesView.centerXAnchor];
    [nvps.mid constrainWidthToConstant:width];
    
    UIView *leftValueFill = UIView.new;
    leftValueFill.translatesAutoresizingMaskIntoConstraints = NO;
    leftValueFill.backgroundColor = UIColor.clearColor;
    
    [ticValuesView addSubview:leftValueFill];
    [leftValueFill constrainTopToAnchor:ticValuesView.topAnchor];
    [leftValueFill constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [leftValueFill constrainLeadingToAnchor:nvps.left.trailingAnchor];
    [leftValueFill constrainTrailingToAnchor:nvps.mid.leadingAnchor];
    
    nvps.leftMid = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupTicButton:nvps.leftMid];
    [leftValueFill addSubview:nvps.leftMid];
    [nvps.leftMid constrainTopToAnchor:leftValueFill.topAnchor];
    [nvps.leftMid constrainBottomToAnchor:leftValueFill.bottomAnchor];
    [nvps.leftMid constrainCenterXToAnchor:leftValueFill.centerXAnchor];
    [nvps.leftMid constrainWidthToConstant:width];
    
    UIView *rightValueFill = UIView.new;
    rightValueFill.translatesAutoresizingMaskIntoConstraints = NO;
    rightValueFill.backgroundColor = UIColor.clearColor;
    
    [ticValuesView addSubview:rightValueFill];
    [rightValueFill constrainTopToAnchor:ticValuesView.topAnchor];
    [rightValueFill constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [rightValueFill constrainLeadingToAnchor:nvps.mid.trailingAnchor];
    [rightValueFill constrainTrailingToAnchor:nvps.right.leadingAnchor];
    
    nvps.rightMid = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupTicButton:nvps.rightMid];
    [rightValueFill addSubview:nvps.rightMid];
    [nvps.rightMid constrainTopToAnchor:rightValueFill.topAnchor];
    [nvps.rightMid constrainBottomToAnchor:rightValueFill.bottomAnchor];
    [nvps.rightMid constrainCenterXToAnchor:rightValueFill.centerXAnchor];
    [nvps.rightMid constrainWidthToConstant:width];
    
    nvps.titleLabel = UILabel.new;
    [nvps setupLabel:nvps.titleLabel];
    nvps.titleLabel.text = title;
    
    nvps.valueLabel = UILabel.new;
    [nvps setupLabel:nvps.valueLabel];
    nvps.valueLabel.text = [NSString stringWithFormat:@"%i", (int)round(nvps.slider.value)];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        nvps.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
        nvps.valueLabel.font = [UIFont boldSystemFontOfSize:48.0];
    }
    
    else
    {
        nvps.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
        nvps.valueLabel.font = [UIFont boldSystemFontOfSize:84.0];
    }
    
    [nvps addSubview:nvps.titleLabel];
    [nvps.titleLabel constrainLeadingToAnchor:nvps.slider.leadingAnchor];
    [nvps.titleLabel constrainTrailingToAnchor:nvps.slider.trailingAnchor];
    [nvps.titleLabel constrainTopToAnchor:nvps.topAnchor];
    
    [nvps addSubview:nvps.valueLabel];
    [nvps.valueLabel constrainLeadingToAnchor:nvps.slider.leadingAnchor];
    [nvps.valueLabel constrainTrailingToAnchor:nvps.slider.trailingAnchor];
    [nvps.valueLabel constrainBottomToAnchor:ticValuesView.topAnchor];
    [nvps.valueLabel constrainTopToAnchor:nvps.titleLabel.bottomAnchor];
    [nvps.valueLabel constrainHeightToAnchor:nvps.titleLabel.heightAnchor multiplier:1.5];
    
    UIView *leftButtonSpace = UIView.new;
    leftButtonSpace.translatesAutoresizingMaskIntoConstraints = NO;
    leftButtonSpace.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:leftButtonSpace];
    [leftButtonSpace constrainLeadingToAnchor:nvps.leadingAnchor];
    [leftButtonSpace constrainTrailingToAnchor:nvps.centerXAnchor];
    [leftButtonSpace constrainBottomToAnchor:nvps.bottomAnchor];
   // [leftButtonSpace constrainTopToAnchor:nvps.slider.bottomAnchor constant:40.0];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nvps.cancelButton = cancelButton;
    [nvps setupButton:cancelButton];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [leftButtonSpace addSubview:cancelButton];
    [cancelButton constrainCenterXToAnchor:leftButtonSpace.centerXAnchor];
    [cancelButton constrainCenterYToAnchor:leftButtonSpace.centerYAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [cancelButton constrainWidthToAnchor:leftButtonSpace.widthAnchor multiplier:0.8];
        [cancelButton constrainHeightToAnchor:leftButtonSpace.heightAnchor multiplier:0.6];
    }
    
    else
    {
        [cancelButton constrainWidthToAnchor:leftButtonSpace.widthAnchor multiplier:0.8];
        [cancelButton constrainHeightToAnchor:leftButtonSpace.heightAnchor multiplier:0.3];
    }
    
    [cancelButton addTarget:nvps
                     action:@selector(cancelTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightButtonSpace = UIView.new;
    rightButtonSpace.translatesAutoresizingMaskIntoConstraints = NO;
    rightButtonSpace.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:rightButtonSpace];
    [rightButtonSpace constrainLeadingToAnchor:leftButtonSpace.trailingAnchor];
    [rightButtonSpace constrainTrailingToAnchor:nvps.trailingAnchor];
    [rightButtonSpace constrainBottomToAnchor:leftButtonSpace.bottomAnchor];
    [rightButtonSpace constrainTopToAnchor:leftButtonSpace.topAnchor];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupButton:saveButton];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    [rightButtonSpace addSubview:saveButton];
    [saveButton constrainCenterXToAnchor:rightButtonSpace.centerXAnchor];
    [saveButton constrainCenterYToAnchor:rightButtonSpace.centerYAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [saveButton constrainWidthToAnchor:rightButtonSpace.widthAnchor multiplier:0.8];
        [saveButton constrainHeightToAnchor:rightButtonSpace.heightAnchor multiplier:0.6];
    }
    
    else
    {
        [saveButton constrainWidthToAnchor:rightButtonSpace.widthAnchor multiplier:0.8];
        [saveButton constrainHeightToAnchor:rightButtonSpace.heightAnchor multiplier:0.3];
    }
    
    [saveButton addTarget:nvps
                   action:@selector(saveTapped)
         forControlEvents:UIControlEventTouchUpInside];
    
    if (nvps.allowBosch)
    {
        CGRect rect = cancelButton.frame;
        UIButton *gotoBoschButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nvps setupButton:gotoBoschButton];
        [gotoBoschButton setTitle:@"Use Laser Device" forState:UIControlStateNormal];
        
        [nvps addSubview:gotoBoschButton];
        [gotoBoschButton constrainCenterXToAnchor:nvps.centerXAnchor];
         
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            [gotoBoschButton constrainBottomToAnchor:saveButton.topAnchor constant:-8];
            [gotoBoschButton constrainWidthToAnchor:nvps.widthAnchor multiplier:0.8];
            [gotoBoschButton constrainHeightToAnchor:leftButtonSpace.heightAnchor multiplier:0.6];
        }
        
        else
        {
            [gotoBoschButton constrainBottomToAnchor:saveButton.topAnchor constant:-24];
            [gotoBoschButton constrainWidthToAnchor:nvps.widthAnchor multiplier:0.8];
            [gotoBoschButton constrainHeightToAnchor:leftButtonSpace.heightAnchor multiplier:0.3];
        }
        
        [gotoBoschButton addTarget:nvps
                            action:@selector(gotoBoschTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        CRAPI.sharedInstance.currentMeasurementView = nvps;

    }
    [nvps bringSubviewToFront:nvps.slider];
    [nvps showStepper];
    [nvps updateTicLabels];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvps.overlayView.alpha = 0.7;
                         nvps.alpha = 1.0;
                         nvps.tabBar.alpha = 0.0;
                     }];
    if (nvps.allowBosch && useBosch)
    {
        [nvps performSelector:@selector(gotoBoschTapped) withObject:nil afterDelay:0.1];
    }
    return nvps;
}

- (void)setupLabel:(UILabel *)label
{
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = UIColor.clearColor;
    label.textColor = UIColor.blackColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
}

- (void)setupTicButton:(UIButton *)button
{
    CGFloat fontSize = 32.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        fontSize = 22.0;
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = UIColor.clearColor;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.clipsToBounds = NO;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:fontSize];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ticTapped:) forControlEvents:UIControlEventTouchDown];
}

- (void)setupButton:(UIButton *)button
{
    CGFloat fontSize = 40.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        fontSize = 28.0;
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = UIColor.blackColor;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
}

- (void)hidePopoverSliderView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                             _overlayView.alpha = 0.0;
                             _tabBar.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             _tabBar.userInteractionEnabled = YES;
                             [_overlayView removeFromSuperview];
                             [self removeFromSuperview];
                         }];
    }
    
    else
    {
        _tabBar.userInteractionEnabled = YES;
        [_overlayView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (void)sliderValueChanged:(UISlider *)slider
{
    _tap.enabled = NO;
    _tap.enabled = YES;
    [self updateSliderLabel];
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_slider];
    float percentage = (point.x / _slider.bounds.size.width);
    float delta = (percentage * (_slider.maximumValue - _slider.minimumValue));
    float rawValue = (_slider.minimumValue + delta);
    float medianValue = ((_slider.maximumValue + _slider.minimumValue) / 2.0);
    float value = (rawValue - ((medianValue - rawValue) * 0.15));
    
    [_slider setValue:value animated:NO];
    [self updateSliderLabel];
}

- (void)cancelTapped
{
    CRAPI.sharedInstance.currentMeasurementView = 0;

    [_delegate popoverSliderDidCancel:self];
}

- (void)saveTapped
{
    CRAPI.sharedInstance.currentMeasurementView = 0;

    float value = roundf(_slider.value);
    
    if (_roundToTenths)
        value = ((roundf(_slider.value * 10.0)) / 10.0);
    
    if (_modeSwitch.on)
    {
        value+= _initialValue;
        
        if (value < _initialMin)
            value+= _initialMax;
        
        else if (value > _initialMax)
            value -= _initialMax;
    }
    
    [_delegate popoverSlider:self
              didReturnValue:value
                         tag:self.tag];
}

-(double) adjustValue:(double) inVal
            fromUnits:(NSString *)inUnits
{
    double outVal = 0;
    
    if ([inUnits isEqual:@"m"])
    {
        if ([_units isEqual:@"Inches"])
        {
            outVal = inVal * MFT * 12;
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
    }
    
    return;
}
void returnToCallerInOC (void)
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    //SharedDefaults *defaults = [SharedDefaults defaults];
    NSString * returnUrl = [defaults stringForKey:@"MeasureSourceApplication"];
    NSLog (@"%@",returnUrl);
    return;
}
-(void)gotoBoschTapped
{
    NSString *measureURL = @"DeviceConnect://";
    [SharedDefaults.defaults saveString:@"SidewalkAssistant://" forKey:@"MeasureSourceApplication"];
    returnToCallerInOC();
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
- (void)ticTapped:(UIButton *)button
{
    [_slider setValue:button.titleLabel.text.floatValue animated:NO];
    [self updateSliderLabel];
}

- (void)showStepper
{
    UISegmentedControl *stepperSC = [[UISegmentedControl alloc] initWithItems:@[@"-", @"+"]];
    stepperSC.translatesAutoresizingMaskIntoConstraints = NO;
    stepperSC.momentary = YES;
    stepperSC.tintColor = UIColor.blackColor;
    
    [stepperSC setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:48.0]
                                                                  forKey:NSFontAttributeName]
                             forState:UIControlStateNormal];
    
    [stepperSC setContentPositionAdjustment:UIOffsetMake(0.0, -2.0)
                             forSegmentType:UISegmentedControlSegmentAny
                                 barMetrics:UIBarMetricsDefault];
    
    [self addSubview:stepperSC];
    [stepperSC constrainCenterXToAnchor:_slider.centerXAnchor];
    [stepperSC constrainTopToAnchor:_slider.bottomAnchor constant:20.0];
    [stepperSC constrainHeightToConstant:50.0];
    [stepperSC constrainWidthToAnchor:stepperSC.heightAnchor multiplier:3.0];
    
    [stepperSC addTarget:self
                  action:@selector(stepperSCTapped:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)stepperSCTapped:(UISegmentedControl *)sc
{
    if (sc.selectedSegmentIndex)
    {
        if (_roundToTenths)
            [_slider setValue:(_slider.value + 0.1) animated:NO];
        
        else
            [_slider setValue:(_slider.value + 1) animated:NO];
    }
    
    else
    {
        if (_roundToTenths)
            [_slider setValue:(_slider.value - 0.1) animated:NO];
        
        else
            [_slider setValue:(_slider.value - 1) animated:NO];
    }
    
    [self updateSliderLabel];
}

- (void)showRelativeModeSwitch
{
    _modeSwitch = UISwitch.new;
    _modeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    _modeSwitch.tintColor = UIColor.redColor;
    _modeSwitch.backgroundColor = UIColor.redColor;
    _modeSwitch.layer.cornerRadius = 18.0;
    _modeSwitch.onTintColor = UIColor.greenColor;
    
    [self addSubview:_modeSwitch];
    [_modeSwitch constrainCenterXToAnchor:self.centerXAnchor];
    [_modeSwitch constrainBottomToAnchor:self.bottomAnchor constant:-20.0];
    
    [_modeSwitch addTarget:self
                    action:@selector(modeSwitchChanged:)
          forControlEvents:UIControlEventValueChanged];
    
    UILabel *switchLabel = UILabel.new;
    switchLabel.translatesAutoresizingMaskIntoConstraints = NO;
    switchLabel.text = @"Relative to Current Value";
    switchLabel.textColor = UIColor.blackColor;
    [self addSubview:switchLabel];
    [switchLabel constrainLeadingToAnchor:_modeSwitch.trailingAnchor constant:10.0];
    [switchLabel constrainCenterYToAnchor:_modeSwitch.centerYAnchor];
}

- (void)modeSwitchChanged:(UISwitch *)modeSwitch
{
    if (modeSwitch.on)
    {
        _slider.maximumValue = 180.0;
        _slider.minimumValue = -180.0;
        [_slider setValue:0.0 animated:NO];
    }
    
    else
    {
        _slider.maximumValue = _initialMax;
        _slider.minimumValue = _initialMin;
        [_slider setValue:_initialValue animated:NO];
    }
    
    [self updateTicLabels];
    [self updateSliderLabel];
}

- (void)updateTicLabels
{
    float max = _slider.maximumValue;
    float min = _slider.minimumValue;
    
    if (_roundToTenths)
    {
        [_left setTitle:[NSString stringWithFormat:@"%.1f", roundf(min * 10.0) / 10.0]
               forState:UIControlStateNormal];
        
        [_right setTitle:[NSString stringWithFormat:@"%.1f", roundf(max * 10.0) / 10.0]
                forState:UIControlStateNormal];
        
        [_mid setTitle:[NSString stringWithFormat:@"%.1f", roundf(((max + min) / 2.0) * 10.0) / 10.0]
              forState:UIControlStateNormal];
        
        [_leftMid setTitle:[NSString stringWithFormat:@"%.1f", roundf(((max + (min * 3.0)) / 4.0) * 10.0) / 10.0]
                  forState:UIControlStateNormal];
        
        [_rightMid setTitle:[NSString stringWithFormat:@"%.1f", roundf(((min + (max * 3.0)) / 4.0) * 10.0) / 10.0]
                   forState:UIControlStateNormal];
    }
    
    else
    {
        [_left setTitle:[NSString stringWithFormat:@"%.0f", roundf(min)]
               forState:UIControlStateNormal];
        
        [_right setTitle:[NSString stringWithFormat:@"%.0f", roundf(max)]
                forState:UIControlStateNormal];
        
        [_mid setTitle:[NSString stringWithFormat:@"%.0f", roundf((max + min) / 2.0)]
              forState:UIControlStateNormal];
        
        [_leftMid setTitle:[NSString stringWithFormat:@"%.0f", roundf((max + (min * 3.0)) / 4.0)]
                  forState:UIControlStateNormal];
        
        [_rightMid setTitle:[NSString stringWithFormat:@"%.0f", roundf((min + (max * 3.0)) / 4.0)]
                   forState:UIControlStateNormal];
    }
}

- (void)updateSliderLabel
{
    double value = 0.0;
    
    if (_roundToTenths)
    {
        value = roundf(_slider.value * 10.0) / 10.0;
        _valueLabel.text = [NSString stringWithFormat:@"%.1f %@", value, _units];
    }
    
    else
    {
        value = roundf(_slider.value);
        _valueLabel.text = [NSString stringWithFormat:@"%.0f %@", value, _units];
    }
}

- (void)setRoundToTenths:(BOOL)roundToTenths
{
    _roundToTenths = roundToTenths;
    [self updateSliderLabel];
    [self updateTicLabels];
}

- (void)setUnits:(NSString *)units
{
    _units = units;
    [self updateSliderLabel];
    [self updateTicLabels];
}
- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
         default:break;
    }
    
    [alertView hideLargeAlertView:YES];
}

@end
