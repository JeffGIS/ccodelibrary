//  NVPopoverSlider.m
//  CCodeLibrary

#import "NVPopoverSlider.h"
#import "UserDefaults.h"

@interface NVPopoverSlider ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UISlider *slider;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic, weak) id <NVPopoverSliderDelegate> delegate;

@end

@implementation NVPopoverSlider

+ (instancetype)showPopoverSliderInView:(UIView *)view
                               minValue:(double)minValue
                               maxValue:(double)maxValue
                             startValue:(double)startValue
                               delegate:(id)delegate
                                    tag:(NSInteger)tag
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
    CGFloat longestSide = MAX(bounds.size.height, bounds.size.width);
    CGFloat shortestSide = MIN(bounds.size.height, bounds.size.width);
    
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
    [nvps.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:30.0].active = YES;
    [nvps.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-30.0].active = YES;
    [nvps.heightAnchor constraintEqualToConstant:(shortestSide * 0.5)].active = YES;
    [nvps.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:(nvps.tabBar.frame.size.height * 0.5)].active = YES;
    
    double capHeight = 29.0;
    double capWidth = (capHeight / 2.0);
    
    nvps.slider = UISlider.new;
    nvps.slider.translatesAutoresizingMaskIntoConstraints = NO;
    
    [nvps.slider setThumbImage:UserDefaults.defaults.redSliderThumb
                      forState:UIControlStateNormal];
    
    UIImage *sliderLeft = [UserDefaults.defaults.metalSliderLeft stretchableImageWithLeftCapWidth:capWidth
                                                                                     topCapHeight:capHeight];
    
    UIImage *sliderRight = [UserDefaults.defaults.metalSliderRight stretchableImageWithLeftCapWidth:capWidth
                                                                                       topCapHeight:capHeight];
    
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
    [nvps.slider.leadingAnchor constraintEqualToAnchor:nvps.leadingAnchor constant:10.0].active = YES;
    [nvps.slider.trailingAnchor constraintEqualToAnchor:nvps.trailingAnchor constant:-10.0].active = YES;
    [nvps.slider.centerYAnchor constraintEqualToAnchor:nvps.centerYAnchor].active = YES;
    
    nvps.tap = [[UITapGestureRecognizer alloc] initWithTarget:nvps
                                                       action:@selector(sliderTapped:)];
    
    [nvps.slider addGestureRecognizer:nvps.tap];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvps.overlayView.alpha = 0.7;
                         nvps.alpha = 1.0;
                         nvps.tabBar.alpha = 0.3;
                     }];
    
    return nvps;
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
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture
{
    _slider = (UISlider *)gesture.view;
    CGPoint point = [gesture locationInView:_slider];
    float percentage = (point.x / _slider.bounds.size.width);
    float delta = (percentage * (_slider.maximumValue - _slider.minimumValue));
    float rawValue = (_slider.minimumValue + delta);
    float medianValue = ((_slider.maximumValue + _slider.minimumValue) / 2.0);
    float value = (rawValue - ((medianValue - rawValue) * 0.15));
    
    [_slider setValue:value
             animated:NO];
}

@end