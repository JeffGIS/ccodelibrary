//  NVSliderView.m
//  CCodeLibrary

#import "NVSliderView.h"
#import "UserDefaults.h"

@interface NVSliderView ()

@property (nonatomic) UISlider *slider;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *sliderLabel, *titleLabel;
@property (nonatomic) UIButton *cancelButton, *saveButton;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation NVSliderView

+ (NVSliderView *)showSliderWithView:(UIView *)view
                          startValue:(double)startValue
                            minValue:(double)minValue
                            maxValue:(double)maxValue
                            delegate:(id)delegate
                              tabBar:(UITabBar *)tabBar
                                 tag:(NSInteger)tag
{
    NVSliderView *sliderView = [[NVSliderView alloc] initWithFrame:CGRectMake((view.frame.size.width * 0.1),
                                                                              (view.frame.size.height * 0.25),
                                                                              (view.frame.size.width * 0.8),
                                                                              (view.frame.size.height * 0.5))];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    sliderView.overlayView = UIView.new;
    sliderView.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    sliderView.overlayView.backgroundColor = UIColor.blackColor;
    sliderView.tabBar = tabBar;
    sliderView.tabBar.userInteractionEnabled = NO;
    sliderView.overlayView.alpha = 0.0;
    sliderView.delegate = delegate;
    sliderView.tag = tag;
    sliderView.units = @"";
    sliderView.titleText = @"NVMobile Slider Manager";
    
    [view addSubview:sliderView.overlayView];
    
    [sliderView.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    sliderView.backgroundColor = UIColor.whiteColor;
    sliderView.layer.cornerRadius = 10.0;
    sliderView.alpha = 0.0;
    
    [view addSubview:sliderView];
    
    sliderView.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((sliderView.frame.size.width * 0.05),
                                                                      (sliderView.frame.size.height * 0.05),
                                                                      (sliderView.frame.size.width * 0.9),
                                                                      (sliderView.frame.size.height * 0.1))];
    
    sliderView.titleLabel.backgroundColor = UIColor.clearColor;
    sliderView.titleLabel.text = sliderView.titleText;
    sliderView.titleLabel.textColor = UIColor.blackColor;
    sliderView.titleLabel.textAlignment = NSTextAlignmentCenter;
    sliderView.titleLabel.adjustsFontSizeToFitWidth = YES;
    sliderView.titleLabel.font = [UIFont boldSystemFontOfSize:44.0];
    
    [sliderView addSubview:sliderView.titleLabel];
    
    double capHeight = 29.0;
    double capWidth = (capHeight / 2.0);
    
    sliderView.slider = [[UISlider alloc] init];
    
    sliderView.slider.frame = CGRectMake((sliderView.frame.size.width * 0.05),
                               ((sliderView.frame.size.height * 0.5) - (capHeight / 2.0)),
                               (sliderView.frame.size.width * 0.9), capHeight);
    
    [sliderView.slider setThumbImage:UserDefaults.defaults.redSliderThumb
                        forState:UIControlStateNormal];
    
    UIImage *sliderLeft = [UserDefaults.defaults.metalSliderLeft stretchableImageWithLeftCapWidth:capWidth
                                                                                     topCapHeight:capHeight];
    
    UIImage *sliderRight = [UserDefaults.defaults.metalSliderRight stretchableImageWithLeftCapWidth:capWidth
                                                                                       topCapHeight:capHeight];
    
    [sliderView.slider setMinimumTrackImage:sliderLeft
                                   forState:UIControlStateNormal];
    
    [sliderView.slider setMaximumTrackImage:sliderRight
                                   forState:UIControlStateNormal];
    
    sliderView.slider.minimumValue = minValue;
    sliderView.slider.maximumValue = maxValue;
    sliderView.slider.value = roundf(startValue);
    
    [sliderView.slider addTarget:sliderView
                          action:@selector(sliderValueChanged:)
                forControlEvents:UIControlEventValueChanged];
    
    [sliderView addSubview:sliderView.slider];
    
    sliderView.sliderLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(sliderView.slider.frame.origin.x,
                                         (sliderView.slider.frame.origin.y - (sliderView.frame.size.height * 0.2)),
                                         sliderView.slider.frame.size.width,
                                         (sliderView.frame.size.height * 0.1))];
    
    sliderView.sliderLabel.backgroundColor = UIColor.clearColor;
    sliderView.sliderLabel.text = [NSString stringWithFormat:@"%.0f %@", sliderView.slider.value, sliderView.units];
    sliderView.sliderLabel.textColor = UIColor.blackColor;
    sliderView.sliderLabel.font = [UIFont boldSystemFontOfSize:56.0];
    sliderView.sliderLabel.textAlignment = NSTextAlignmentCenter;
    
    [sliderView addSubview:sliderView.sliderLabel];
    
    sliderView.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((sliderView.frame.size.width * 0.1),
                                                                         (sliderView.frame.size.height * 0.75),
                                                                         (sliderView.frame.size.width * 0.3),
                                                                         (sliderView.frame.size.height * 0.15))];
    
    [sliderView setupButton:sliderView.cancelButton
                     target:sliderView
                   selector:@selector(cancelButtonTapped:)
                      title:@"Cancel"];
    
    [sliderView addSubview:sliderView.cancelButton];
    
    sliderView.saveButton = [[UIButton alloc] initWithFrame:CGRectMake((sliderView.frame.size.width * 0.6),
                                                                       (sliderView.frame.size.height * 0.75),
                                                                       (sliderView.frame.size.width * 0.3),
                                                                       (sliderView.frame.size.height * 0.15))];
    
    [sliderView setupButton:sliderView.saveButton
                     target:sliderView
                   selector:@selector(saveButtonTapped:)
                      title:@"Save"];
    
    [sliderView addSubview:sliderView.saveButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         sliderView.overlayView.alpha = 0.7;
                         sliderView.alpha = 1.0;
                         sliderView.tabBar.alpha = 0.0;
                     }];
    
    return sliderView;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.backgroundColor = UIColor.blackColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    double value = roundf(slider.value);
    _sliderLabel.text = [NSString stringWithFormat:@"%.0f %@", value, _units];
}

- (void)cancelButtonTapped:(UIButton *)button
{
    if (_delegate)
        [_delegate sliderViewDidCancel:self];
}

- (void)saveButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        double value = roundf(_slider.value);
        
        [_delegate sliderView:self
               didReturnValue:value
               forViewWithTag:self.tag];
    }
}

- (void)hideSliderView:(BOOL)animated
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

- (void)setTitleText:(NSString *)titleText
{
    _titleLabel.text = titleText;
    _titleText = titleText;
}

- (void)setUnits:(NSString *)units
{
    double value = roundf(_slider.value);
    _sliderLabel.text = [NSString stringWithFormat:@"%.0f %@", value, units];
    _units = units;
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect frame = self.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.frame = CGRectMake(frame.origin.y, frame.origin.x,
                                                 ((frame.size.height + _tabBar.frame.size.height)),
                                                 ((frame.size.width - _tabBar.frame.size.height)));
                     }];
}

@end