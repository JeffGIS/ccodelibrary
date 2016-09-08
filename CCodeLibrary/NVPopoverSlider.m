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
    [nvps.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:(height * 0.1)].active = YES;
    [nvps.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-(height * 0.1)].active = YES;
    [nvps.heightAnchor constraintEqualToConstant:height].active = YES;
    [nvps.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:(nvps.tabBar.frame.size.height * 0.5)].active = YES;
    
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
    [nvps.slider.leadingAnchor constraintEqualToAnchor:nvps.leadingAnchor constant:(height * 0.05)].active = YES;
    [nvps.slider.trailingAnchor constraintEqualToAnchor:nvps.trailingAnchor constant:-(height * 0.05)].active = YES;
    [nvps.slider.topAnchor constraintEqualToAnchor:nvps.centerYAnchor].active = YES;
    
    nvps.tap = [[UITapGestureRecognizer alloc] initWithTarget:nvps
                                                       action:@selector(sliderTapped:)];
    
    [nvps.slider addGestureRecognizer:nvps.tap];
    
    UIView *ticView = UIView.new;
    ticView.translatesAutoresizingMaskIntoConstraints = NO;
    ticView.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:ticView];
    [ticView.leadingAnchor constraintEqualToAnchor:nvps.slider.leadingAnchor constant:offset].active = YES;
    [ticView.trailingAnchor constraintEqualToAnchor:nvps.slider.trailingAnchor constant:-offset].active = YES;
    [ticView.bottomAnchor constraintEqualToAnchor:nvps.slider.centerYAnchor].active = YES;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [ticView.heightAnchor constraintEqualToConstant:(capHeight * 1.5)].active = YES;
    
    else
        [ticView.heightAnchor constraintEqualToConstant:(capHeight * 1.75)].active = YES;
    
    UIView *midTic = UIView.new;
    midTic.translatesAutoresizingMaskIntoConstraints = NO;
    midTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:midTic];
    [midTic.topAnchor constraintEqualToAnchor:ticView.topAnchor].active = YES;
    [midTic.bottomAnchor constraintEqualToAnchor:ticView.bottomAnchor].active = YES;
    [midTic.centerXAnchor constraintEqualToAnchor:ticView.centerXAnchor].active = YES;
    [midTic.widthAnchor constraintEqualToConstant:2.0].active = YES;
    
    UIView *leftTic = UIView.new;
    leftTic.translatesAutoresizingMaskIntoConstraints = NO;
    leftTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:leftTic];
    [leftTic.topAnchor constraintEqualToAnchor:ticView.topAnchor].active = YES;
    [leftTic.bottomAnchor constraintEqualToAnchor:ticView.bottomAnchor].active = YES;
    [leftTic.leadingAnchor constraintEqualToAnchor:ticView.leadingAnchor].active = YES;
    [leftTic.widthAnchor constraintEqualToConstant:2.0].active = YES;
    
    [nvps bringSubviewToFront:nvps.slider];
    
    UIView *rightTic = UIView.new;
    rightTic.translatesAutoresizingMaskIntoConstraints = NO;
    rightTic.backgroundColor = UIColor.blackColor;
    
    [ticView addSubview:rightTic];
    [rightTic.topAnchor constraintEqualToAnchor:ticView.topAnchor].active = YES;
    [rightTic.bottomAnchor constraintEqualToAnchor:ticView.bottomAnchor].active = YES;
    [rightTic.trailingAnchor constraintEqualToAnchor:ticView.trailingAnchor].active = YES;
    [rightTic.widthAnchor constraintEqualToConstant:2.0].active = YES;
    
    UIView *leftFill = UIView.new;
    leftFill.translatesAutoresizingMaskIntoConstraints = NO;
    leftFill.backgroundColor = UIColor.clearColor;
    
    [ticView addSubview:leftFill];
    [leftFill.topAnchor constraintEqualToAnchor:ticView.topAnchor].active = YES;
    [leftFill.bottomAnchor constraintEqualToAnchor:ticView.bottomAnchor].active = YES;
    [leftFill.leadingAnchor constraintEqualToAnchor:leftTic.trailingAnchor].active = YES;
    [leftFill.trailingAnchor constraintEqualToAnchor:midTic.leadingAnchor].active = YES;
    
    UIView *leftMidTic = UIView.new;
    leftMidTic.translatesAutoresizingMaskIntoConstraints = NO;
    leftMidTic.backgroundColor = UIColor.blackColor;
    
    [leftFill addSubview:leftMidTic];
    [leftMidTic.topAnchor constraintEqualToAnchor:leftFill.topAnchor].active = YES;
    [leftMidTic.bottomAnchor constraintEqualToAnchor:leftFill.bottomAnchor].active = YES;
    [leftMidTic.centerXAnchor constraintEqualToAnchor:leftFill.centerXAnchor].active = YES;
    [leftMidTic.widthAnchor constraintEqualToConstant:2.0].active = YES;
    
    UIView *rightFill = UIView.new;
    rightFill.translatesAutoresizingMaskIntoConstraints = NO;
    rightFill.backgroundColor = UIColor.clearColor;
    
    [ticView addSubview:rightFill];
    [rightFill.topAnchor constraintEqualToAnchor:ticView.topAnchor].active = YES;
    [rightFill.bottomAnchor constraintEqualToAnchor:ticView.bottomAnchor].active = YES;
    [rightFill.leadingAnchor constraintEqualToAnchor:midTic.trailingAnchor].active = YES;
    [rightFill.trailingAnchor constraintEqualToAnchor:rightTic.leadingAnchor].active = YES;
    
    UIView *rightMidTic = UIView.new;
    rightMidTic.translatesAutoresizingMaskIntoConstraints = NO;
    rightMidTic.backgroundColor = UIColor.blackColor;
    
    [rightFill addSubview:rightMidTic];
    [rightMidTic.topAnchor constraintEqualToAnchor:rightFill.topAnchor].active = YES;
    [rightMidTic.bottomAnchor constraintEqualToAnchor:rightFill.bottomAnchor].active = YES;
    [rightMidTic.centerXAnchor constraintEqualToAnchor:rightFill.centerXAnchor].active = YES;
    [rightMidTic.widthAnchor constraintEqualToConstant:2.0].active = YES;
    
    UIView *ticValuesView = UIView.new;
    ticValuesView.translatesAutoresizingMaskIntoConstraints = NO;
    ticValuesView.backgroundColor = UIColor.clearColor;
    ticValuesView.clipsToBounds = NO;
    
    [nvps addSubview:ticValuesView];
    [ticValuesView.leadingAnchor constraintEqualToAnchor:ticView.leadingAnchor].active = YES;
    [ticValuesView.trailingAnchor constraintEqualToAnchor:ticView.trailingAnchor].active = YES;
    [ticValuesView.bottomAnchor constraintEqualToAnchor:ticView.topAnchor].active = YES;
    [ticValuesView.heightAnchor constraintEqualToConstant:capHeight].active = YES;
    
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
    [leftTicValue.topAnchor constraintEqualToAnchor:ticValuesView.topAnchor].active = YES;
    [leftTicValue.bottomAnchor constraintEqualToAnchor:ticValuesView.bottomAnchor].active = YES;
    [leftTicValue.centerXAnchor constraintEqualToAnchor:ticValuesView.leadingAnchor].active = YES;
    [leftTicValue.widthAnchor constraintEqualToConstant:60.0].active = YES;
    
    UILabel *rightTicValue = UILabel.new;
    [nvps setupLabel:rightTicValue];
    rightTicValue.text = [NSString stringWithFormat:@"%i", (int)round(maxValue)];
    rightTicValue.font = ticFont;
    
    [ticValuesView addSubview:rightTicValue];
    [rightTicValue.topAnchor constraintEqualToAnchor:ticValuesView.topAnchor].active = YES;
    [rightTicValue.bottomAnchor constraintEqualToAnchor:ticValuesView.bottomAnchor].active = YES;
    [rightTicValue.centerXAnchor constraintEqualToAnchor:ticValuesView.trailingAnchor].active = YES;
    [rightTicValue.widthAnchor constraintEqualToConstant:60.0].active = YES;
    
    UILabel *midTicValue = UILabel.new;
    [nvps setupLabel:midTicValue];
    midTicValue.text = [NSString stringWithFormat:@"%i", (int)round((maxValue + minValue) / 2.0)];
    midTicValue.font = ticFont;
    
    [ticValuesView addSubview:midTicValue];
    [midTicValue.topAnchor constraintEqualToAnchor:ticValuesView.topAnchor].active = YES;
    [midTicValue.bottomAnchor constraintEqualToAnchor:ticValuesView.bottomAnchor].active = YES;
    [midTicValue.centerXAnchor constraintEqualToAnchor:ticValuesView.centerXAnchor].active = YES;
    [midTicValue.widthAnchor constraintEqualToConstant:60.0].active = YES;
    
    UIView *leftValueFill = UIView.new;
    leftValueFill.translatesAutoresizingMaskIntoConstraints = NO;
    leftValueFill.backgroundColor = UIColor.clearColor;
    
    [ticValuesView addSubview:leftValueFill];
    [leftValueFill.topAnchor constraintEqualToAnchor:ticValuesView.topAnchor].active = YES;
    [leftValueFill.bottomAnchor constraintEqualToAnchor:ticValuesView.bottomAnchor].active = YES;
    [leftValueFill.leadingAnchor constraintEqualToAnchor:leftTicValue.trailingAnchor].active = YES;
    [leftValueFill.trailingAnchor constraintEqualToAnchor:midTicValue.leadingAnchor].active = YES;
    
    UILabel *leftMidTicValue = UILabel.new;
    [nvps setupLabel:leftMidTicValue];
    leftMidTicValue.text = [NSString stringWithFormat:@"%i", (int)round((maxValue + (minValue * 2.0)) / 2.0)];
    leftMidTicValue.font = ticFont;
    
    [leftValueFill addSubview:leftMidTicValue];
    [leftMidTicValue.topAnchor constraintEqualToAnchor:leftValueFill.topAnchor].active = YES;
    [leftMidTicValue.bottomAnchor constraintEqualToAnchor:leftValueFill.bottomAnchor].active = YES;
    [leftMidTicValue.centerXAnchor constraintEqualToAnchor:leftValueFill.centerXAnchor].active = YES;
    [leftMidTicValue.widthAnchor constraintEqualToConstant:60.0].active = YES;
    
    UIView *rightValueFill = UIView.new;
    rightValueFill.translatesAutoresizingMaskIntoConstraints = NO;
    rightValueFill.backgroundColor = UIColor.clearColor;
    
    [ticValuesView addSubview:rightValueFill];
    [rightValueFill.topAnchor constraintEqualToAnchor:ticValuesView.topAnchor].active = YES;
    [rightValueFill.bottomAnchor constraintEqualToAnchor:ticValuesView.bottomAnchor].active = YES;
    [rightValueFill.leadingAnchor constraintEqualToAnchor:midTicValue.trailingAnchor].active = YES;
    [rightValueFill.trailingAnchor constraintEqualToAnchor:rightTicValue.leadingAnchor].active = YES;
    
    UILabel *rightMidTicValue = UILabel.new;
    [nvps setupLabel:rightMidTicValue];
    rightMidTicValue.text = [NSString stringWithFormat:@"%i", (int)round((minValue + (maxValue * 2.0)) / 2.0)];
    rightMidTicValue.font = ticFont;
    
    [rightValueFill addSubview:rightMidTicValue];
    [rightMidTicValue.topAnchor constraintEqualToAnchor:rightValueFill.topAnchor].active = YES;
    [rightMidTicValue.bottomAnchor constraintEqualToAnchor:rightValueFill.bottomAnchor].active = YES;
    [rightMidTicValue.centerXAnchor constraintEqualToAnchor:rightValueFill.centerXAnchor].active = YES;
    [rightMidTicValue.widthAnchor constraintEqualToConstant:60.0].active = YES;
    
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
    [nvps.titleLabel.leadingAnchor constraintEqualToAnchor:nvps.leadingAnchor constant:(height * 0.05)].active = YES;
    [nvps.titleLabel.trailingAnchor constraintEqualToAnchor:nvps.trailingAnchor constant:-(height * 0.05)].active = YES;
    [nvps.titleLabel.topAnchor constraintEqualToAnchor:nvps.topAnchor].active = YES;
    
    [nvps addSubview:nvps.valueLabel];
    [nvps.valueLabel.leadingAnchor constraintEqualToAnchor:nvps.leadingAnchor constant:(height * 0.05)].active = YES;
    [nvps.valueLabel.trailingAnchor constraintEqualToAnchor:nvps.trailingAnchor constant:-(height * 0.05)].active = YES;
    [nvps.valueLabel.bottomAnchor constraintEqualToAnchor:ticValuesView.topAnchor].active = YES;
    [nvps.valueLabel.topAnchor constraintEqualToAnchor:nvps.titleLabel.bottomAnchor].active = YES;
    [nvps.valueLabel.heightAnchor constraintEqualToAnchor:nvps.titleLabel.heightAnchor multiplier:1.5].active = YES;
    
    UIView *leftButtonSpace = UIView.new;
    leftButtonSpace.translatesAutoresizingMaskIntoConstraints = NO;
    leftButtonSpace.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:leftButtonSpace];
    [leftButtonSpace.leadingAnchor constraintEqualToAnchor:nvps.leadingAnchor].active = YES;
    [leftButtonSpace.trailingAnchor constraintEqualToAnchor:nvps.centerXAnchor].active = YES;
    [leftButtonSpace.bottomAnchor constraintEqualToAnchor:nvps.bottomAnchor].active = YES;
    [leftButtonSpace.topAnchor constraintEqualToAnchor:nvps.slider.bottomAnchor].active = YES;
    
    nvps.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupButton:nvps.cancelButton];
    
    [nvps.cancelButton setTitle:@"Cancel"
                       forState:UIControlStateNormal];
    
    [leftButtonSpace addSubview:nvps.cancelButton];
    [nvps.cancelButton.centerXAnchor constraintEqualToAnchor:leftButtonSpace.centerXAnchor].active = YES;
    [nvps.cancelButton.centerYAnchor constraintEqualToAnchor:leftButtonSpace.centerYAnchor].active = YES;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [nvps.cancelButton.widthAnchor constraintEqualToAnchor:leftButtonSpace.widthAnchor multiplier:0.8].active = YES;
        [nvps.cancelButton.heightAnchor constraintEqualToAnchor:leftButtonSpace.heightAnchor multiplier:0.7].active = YES;
    }
    
    else
    {
        [nvps.cancelButton.widthAnchor constraintEqualToAnchor:leftButtonSpace.widthAnchor multiplier:0.7].active = YES;
        [nvps.cancelButton.heightAnchor constraintEqualToAnchor:leftButtonSpace.heightAnchor multiplier:0.4].active = YES;
    }
    
    [nvps.cancelButton addTarget:nvps
                          action:@selector(cancelTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightButtonSpace = UIView.new;
    rightButtonSpace.translatesAutoresizingMaskIntoConstraints = NO;
    rightButtonSpace.backgroundColor = UIColor.clearColor;
    
    [nvps addSubview:rightButtonSpace];
    [rightButtonSpace.leadingAnchor constraintEqualToAnchor:nvps.centerXAnchor].active = YES;
    [rightButtonSpace.trailingAnchor constraintEqualToAnchor:nvps.trailingAnchor].active = YES;
    [rightButtonSpace.bottomAnchor constraintEqualToAnchor:nvps.bottomAnchor].active = YES;
    [rightButtonSpace.topAnchor constraintEqualToAnchor:nvps.slider.bottomAnchor].active = YES;
    
    nvps.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nvps setupButton:nvps.saveButton];
    
    [nvps.saveButton setTitle:@"Save"
                     forState:UIControlStateNormal];
    
    [rightButtonSpace addSubview:nvps.saveButton];
    [nvps.saveButton.centerXAnchor constraintEqualToAnchor:rightButtonSpace.centerXAnchor].active = YES;
    [nvps.saveButton.centerYAnchor constraintEqualToAnchor:rightButtonSpace.centerYAnchor].active = YES;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [nvps.saveButton.widthAnchor constraintEqualToAnchor:rightButtonSpace.widthAnchor multiplier:0.9].active = YES;
        [nvps.saveButton.heightAnchor constraintEqualToAnchor:rightButtonSpace.heightAnchor multiplier:0.7].active = YES;
    }
    
    else
    {
        [nvps.saveButton.widthAnchor constraintEqualToAnchor:rightButtonSpace.widthAnchor multiplier:0.7].active = YES;
        [nvps.saveButton.heightAnchor constraintEqualToAnchor:rightButtonSpace.heightAnchor multiplier:0.4].active = YES;
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