//  NVPopoverSlider.m
//  CCodeLibrary

#import "NVPopoverSlider.h"
#import "UserDefaults.h"

@interface NVPopoverSlider ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UISlider *slider;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) UILabel *titleLabel, *valueLabel;
@property (nonatomic) UIButton *saveButton, *cancelButton;
@property (nonatomic, weak) id <NVPopoverSliderDelegate> delegate;

@end

@implementation NVPopoverSlider

+ (instancetype)showPopoverSliderInView:(UIView *)view
                               minValue:(double)minValue
                               maxValue:(double)maxValue
                             startValue:(double)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag
                                  title:(NSString *)title
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
    CGFloat height = (shortestSide * 0.75);
    
    NVPopoverSlider *nvps = NVPopoverSlider.new;
    nvps.translatesAutoresizingMaskIntoConstraints = NO;
    nvps.delegate = delegate;
    nvps.tabBar = view.parentViewController.tabBarController.tabBar;
    nvps.tabBar.userInteractionEnabled = NO;
    nvps.tag = tag;
    nvps.alpha = 0.0;
    nvps.backgroundColor = UIColor.whiteColor;
    nvps.layer.cornerRadius = 10.0;
    
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
    
    nvps.slider.minimumValue = minValue;
    nvps.slider.maximumValue = maxValue;
    nvps.slider.value = startValue;
    
    [nvps.slider addTarget:nvps
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    
    [nvps addSubview:nvps.slider];
    [nvps.slider constrainLeadingToAnchor:nvps.leadingAnchor constant:(height * 0.05)];
    [nvps.slider constrainTrailingToAnchor:nvps.trailingAnchor constant:-(height * 0.05)];
    [nvps.slider constrainTopToAnchor:nvps.centerYAnchor];
    
    nvps.tap = [[UITapGestureRecognizer alloc] initWithTarget:nvps
                                                       action:@selector(sliderTapped:)];
    
    [nvps.slider addGestureRecognizer:nvps.tap];
    
    UIView *ticView = UIView.new;
    ticView.translatesAutoresizingMaskIntoConstraints = NO;
    ticView.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:ticView];
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
    [leftTic constrainWidthToConstant:2.0];
    
    [nvps bringSubviewToFront:nvps.slider];
    
    UIView *rightTic = UIView.new;
    rightTic.translatesAutoresizingMaskIntoConstraints = NO;
    rightTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:rightTic];
    [rightTic constrainTopToAnchor:ticView.topAnchor];
    [rightTic constrainBottomToAnchor:ticView.bottomAnchor];
    [rightTic constrainTrailingToAnchor:ticView.trailingAnchor];
    [rightTic constrainWidthToConstant:2.0];
    
    UIView *leftFill = UIView.new;
    leftFill.translatesAutoresizingMaskIntoConstraints = NO;
    leftFill.backgroundColor = UIColor.clearColor;
    
    [ticView addSubview:leftFill];
    [leftFill constrainTopToAnchor:ticView.topAnchor];
    [leftFill constrainBottomToAnchor:ticView.bottomAnchor];
    [leftFill constrainLeadingToAnchor:leftTic.trailingAnchor];
    [leftFill constrainTrailingToAnchor:midTic.leadingAnchor];
    
    UIView *leftMidTic = UIView.new;
    leftMidTic.translatesAutoresizingMaskIntoConstraints = NO;
    leftMidTic.backgroundColor = UIColor.blackColor;
    
    [leftFill addSubview:leftMidTic];
    [leftMidTic constrainTopToAnchor:leftFill.topAnchor];
    [leftMidTic constrainBottomToAnchor:leftFill.bottomAnchor];
    [leftMidTic constrainCenterXToAnchor:leftFill.centerXAnchor];
    [leftMidTic constrainWidthToConstant:2.0];
    
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
    [rightMidTic constrainWidthToConstant:2.0];
    
    UIView *ticValuesView = UIView.new;
    ticValuesView.translatesAutoresizingMaskIntoConstraints = NO;
    ticValuesView.backgroundColor = UIColor.clearColor;
    ticValuesView.clipsToBounds = NO;
    
    [nvps addSubview:ticValuesView];
    [ticValuesView constrainLeadingToAnchor:ticView.leadingAnchor];
    [ticValuesView constrainTrailingToAnchor:ticView.trailingAnchor];
    [ticValuesView constrainBottomToAnchor:ticView.topAnchor];
    [ticValuesView constrainHeightToConstant:capHeight];
    
    UIFont *ticFont = nil;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        ticFont = [UIFont fontWithName:@"Avenir Next Condensed"
                                  size:22];
    }
    
    else
    {
        ticFont = [UIFont fontWithName:@"Avenir Next Condensed"
                                  size:32];
    }
    
    UILabel *leftTicValue = UILabel.new;
    [nvps setupLabel:leftTicValue];
    leftTicValue.text = [NSString stringWithFormat:@"%i", (int)round(minValue)];
    leftTicValue.font = ticFont;
    
    [ticValuesView addSubview:leftTicValue];
    [leftTicValue constrainTopToAnchor:ticValuesView.topAnchor];
    [leftTicValue constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [leftTicValue constrainCenterXToAnchor:ticValuesView.leadingAnchor];
    [leftTicValue constrainWidthToConstant:60.0];
    
    UILabel *rightTicValue = UILabel.new;
    [nvps setupLabel:rightTicValue];
    rightTicValue.text = [NSString stringWithFormat:@"%i", (int)round(maxValue)];
    rightTicValue.font = ticFont;
    
    [ticValuesView addSubview:rightTicValue];
    [rightTicValue constrainTopToAnchor:ticValuesView.topAnchor];
    [rightTicValue constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [rightTicValue constrainCenterXToAnchor:ticValuesView.trailingAnchor];
    [rightTicValue constrainWidthToConstant:60.0];
    
    UILabel *midTicValue = UILabel.new;
    [nvps setupLabel:midTicValue];
    midTicValue.text = [NSString stringWithFormat:@"%i", (int)round((maxValue + minValue) / 2.0)];
    midTicValue.font = ticFont;
    
    [ticValuesView addSubview:midTicValue];
    [midTicValue constrainTopToAnchor:ticValuesView.topAnchor];
    [midTicValue constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [midTicValue constrainCenterXToAnchor:ticValuesView.centerXAnchor];
    [midTicValue constrainWidthToConstant:60.0];
    
    UIView *leftValueFill = UIView.new;
    leftValueFill.translatesAutoresizingMaskIntoConstraints = NO;
    leftValueFill.backgroundColor = UIColor.clearColor;
    
    [ticValuesView addSubview:leftValueFill];
    [leftValueFill constrainTopToAnchor:ticValuesView.topAnchor];
    [leftValueFill constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [leftValueFill constrainLeadingToAnchor:leftTicValue.trailingAnchor];
    [leftValueFill constrainTrailingToAnchor:midTicValue.leadingAnchor];
    
    UILabel *leftMidTicValue = UILabel.new;
    [nvps setupLabel:leftMidTicValue];
    leftMidTicValue.text = [NSString stringWithFormat:@"%i", (int)round((maxValue + (minValue * 2.0)) / 2.0)];
    leftMidTicValue.font = ticFont;
    
    [leftValueFill addSubview:leftMidTicValue];
    [leftMidTicValue constrainTopToAnchor:leftValueFill.topAnchor];
    [leftMidTicValue constrainBottomToAnchor:leftValueFill.bottomAnchor];
    [leftMidTicValue constrainCenterXToAnchor:leftValueFill.centerXAnchor];
    [leftMidTicValue constrainWidthToConstant:60.0];
    
    UIView *rightValueFill = UIView.new;
    rightValueFill.translatesAutoresizingMaskIntoConstraints = NO;
    rightValueFill.backgroundColor = UIColor.clearColor;
    
    [ticValuesView addSubview:rightValueFill];
    [rightValueFill constrainTopToAnchor:ticValuesView.topAnchor];
    [rightValueFill constrainBottomToAnchor:ticValuesView.bottomAnchor];
    [rightValueFill constrainLeadingToAnchor:midTicValue.trailingAnchor];
    [rightValueFill constrainTrailingToAnchor:rightTicValue.leadingAnchor];
    
    UILabel *rightMidTicValue = UILabel.new;
    [nvps setupLabel:rightMidTicValue];
    rightMidTicValue.text = [NSString stringWithFormat:@"%i", (int)round((minValue + (maxValue * 2.0)) / 2.0)];
    rightMidTicValue.font = ticFont;
    
    [rightValueFill addSubview:rightMidTicValue];
    [rightMidTicValue constrainTopToAnchor:rightValueFill.topAnchor];
    [rightMidTicValue constrainBottomToAnchor:rightValueFill.bottomAnchor];
    [rightMidTicValue constrainCenterXToAnchor:rightValueFill.centerXAnchor];
    [rightMidTicValue constrainWidthToConstant:60.0];
    
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
    [nvps.titleLabel constrainLeadingToAnchor:nvps.leadingAnchor constant:(height * 0.05)];
    [nvps.titleLabel constrainTrailingToAnchor:nvps.trailingAnchor constant:-(height * 0.05)];
    [nvps.titleLabel constrainTopToAnchor:nvps.topAnchor];
    
    [nvps addSubview:nvps.valueLabel];
    [nvps.valueLabel constrainLeadingToAnchor:nvps.leadingAnchor constant:(height * 0.05)];
    [nvps.valueLabel constrainTrailingToAnchor:nvps.trailingAnchor constant:-(height * 0.05)];
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
    [leftButtonSpace constrainTopToAnchor:nvps.slider.bottomAnchor];
    
    nvps.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupButton:nvps.cancelButton];
    
    [nvps.cancelButton setTitle:@"Cancel"
                       forState:UIControlStateNormal];
    
    [leftButtonSpace addSubview:nvps.cancelButton];
    [nvps.cancelButton constrainCenterXToAnchor:leftButtonSpace.centerXAnchor];
    [nvps.cancelButton constrainCenterYToAnchor:leftButtonSpace.centerYAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [nvps.cancelButton constrainWidthToAnchor:leftButtonSpace.widthAnchor multiplier:0.8];
        [nvps.cancelButton constrainHeightToAnchor:leftButtonSpace.heightAnchor multiplier:0.7];
    }
    
    else
    {
        [nvps.cancelButton constrainWidthToAnchor:leftButtonSpace.widthAnchor multiplier:0.7];
        [nvps.cancelButton constrainHeightToAnchor:leftButtonSpace.heightAnchor multiplier:0.4];
    }
    
    [nvps.cancelButton addTarget:nvps
                          action:@selector(cancelTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightButtonSpace = UIView.new;
    rightButtonSpace.translatesAutoresizingMaskIntoConstraints = NO;
    rightButtonSpace.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:rightButtonSpace];
    [rightButtonSpace constrainLeadingToAnchor:nvps.centerXAnchor];
    [rightButtonSpace constrainTrailingToAnchor:nvps.trailingAnchor];
    [rightButtonSpace constrainBottomToAnchor:nvps.bottomAnchor];
    [rightButtonSpace constrainTopToAnchor:nvps.slider.bottomAnchor];
    
    nvps.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupButton:nvps.saveButton];
    
    [nvps.saveButton setTitle:@"Save"
                     forState:UIControlStateNormal];
    
    [rightButtonSpace addSubview:nvps.saveButton];
    [nvps.saveButton constrainCenterXToAnchor:rightButtonSpace.centerXAnchor];
    [nvps.saveButton constrainCenterYToAnchor:rightButtonSpace.centerYAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [nvps.saveButton constrainWidthToAnchor:rightButtonSpace.widthAnchor multiplier:0.9];
        [nvps.saveButton constrainHeightToAnchor:rightButtonSpace.heightAnchor multiplier:0.7];
    }
    
    else
    {
        [nvps.saveButton constrainWidthToAnchor:rightButtonSpace.widthAnchor multiplier:0.7];
        [nvps.saveButton constrainHeightToAnchor:rightButtonSpace.heightAnchor multiplier:0.4];
    }
    
    [nvps.saveButton addTarget:nvps
                        action:@selector(saveTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [nvps bringSubviewToFront:nvps.slider];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvps.overlayView.alpha = 0.7;
                         nvps.alpha = 1.0;
                         nvps.tabBar.alpha = 0.0;
                     }];
    
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

- (void)setupButton:(UIButton *)button
{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = UIColor.blackColor;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.layer.cornerRadius = 10.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    
    else
        button.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.grayColor
                 forState:UIControlStateHighlighted];
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
    
    _valueLabel.text = [NSString stringWithFormat:@"%i", (int)round(_slider.value)];
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_slider];
    float percentage = (point.x / _slider.bounds.size.width);
    float delta = (percentage * (_slider.maximumValue - _slider.minimumValue));
    float rawValue = (_slider.minimumValue + delta);
    float medianValue = ((_slider.maximumValue + _slider.minimumValue) / 2.0);
    float value = (rawValue - ((medianValue - rawValue) * 0.15));
    
    [_slider setValue:value
             animated:NO];
    
    _valueLabel.text = [NSString stringWithFormat:@"%i", (int)round(_slider.value)];
}

- (void)cancelTapped:(UIButton *)button
{
    [_delegate popoverSliderDidCancel:self];
}

- (void)saveTapped:(UIButton *)button
{
    [_delegate popoverSlider:self
              didReturnValue:_slider.value
                         tag:self.tag];
}

@end
