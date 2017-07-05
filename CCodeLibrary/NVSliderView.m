//  NVSliderView.m
//  CCodeLibrary

#import "NVSliderView.h"
#import "UserDefaults.h"

@interface NVSliderView ()

@property (nonatomic) UISlider *slider;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *sliderLabel, *titleLabel;
@property (nonatomic) UIButton *cancelButton, *saveButton, *photoButton;
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
    if (!view || !delegate)
    {
        NSLog(@"NVSliderView ERROR:Cannot set delegate or view to nil");
        return nil;
    }
    
    NVSliderView *sliderView = [[NVSliderView alloc] initWithFrame:CGRectMake((view.frame.size.width * 0.1),
                                                                              (view.frame.size.height * 0.25),
                                                                              (view.frame.size.width * 0.8),
                                                                              (view.frame.size.height * 0.5))];
    
    sliderView.overlayView = UIView.new;
    sliderView.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    sliderView.overlayView.backgroundColor = UIColor.blackColor;
    sliderView.overlayView.alpha = 0.0;
    [view addSubview:sliderView.overlayView];
    [sliderView.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    sliderView.tabBar = tabBar;
    sliderView.tabBar.userInteractionEnabled = NO;
    sliderView.delegate = delegate;
    sliderView.tag = tag;
    sliderView.units = @"";
    sliderView.titleText = @"NVMobile Slider Manager";
    sliderView.roundToTenths = NO;
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
    
    [sliderView.slider setMinimumTrackImage:sliderLeft forState:UIControlStateNormal];
    [sliderView.slider setMaximumTrackImage:sliderRight forState:UIControlStateNormal];
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
    
    CGFloat size = sliderView.cancelButton.frame.size.height;
    sliderView.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sliderView.photoButton.hidden = YES;
    sliderView.photoButton.frame = CGRectMake(0.0, 0.0, size, size);
    sliderView.photoButton.center = CGPointMake((sliderView.frame.size.width * 0.5), sliderView.cancelButton.center.y);
    [sliderView addSubview:sliderView.photoButton];
    
    [sliderView.photoButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"cameraIcon"
                                                                                                    ofType:@"png"]]
                  forState:UIControlStateNormal];
    
    [sliderView.photoButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"cameraIconHighlighted"
                                                                                                    ofType:@"png"]]
                            forState:UIControlStateHighlighted];
    
    [sliderView.photoButton addTarget:sliderView
                               action:@selector(photoButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
    
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
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    [self updateSliderLabel];
}

- (void)updateSliderLabel
{
    double value = 0.0;
    
    if (_roundToTenths)
    {
        value = ((roundf(_slider.value * 10.0)) / 10.0);
        _sliderLabel.text = [NSString stringWithFormat:@"%.1f %@", value, _units];
    }
    
    else
    {
        value = roundf(_slider.value);
        _sliderLabel.text = [NSString stringWithFormat:@"%.0f %@", value, _units];
    }
}

- (void)cancelButtonTapped:(UIButton *)button
{
    [_delegate sliderViewDidCancel:self];
}

- (void)saveButtonTapped:(UIButton *)button
{
    double value = 0.0;
    
    if (_roundToTenths)
        value = ((roundf(_slider.value * 10.0)) / 10.0);
    
    else
        value = roundf(_slider.value);
    
    [_delegate sliderView:self
           didReturnValue:value
           forViewWithTag:self.tag];
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
    _units = units;
    [self updateSliderLabel];
}

- (void)setRoundToTenths:(BOOL)roundToTenths
{
    _roundToTenths = roundToTenths;
    [self updateSliderLabel];
}

- (void)showPhotoButton
{
    _photoButton.hidden = NO;
}

- (void)photoButtonTapped:(UIButton *)button
{
    [_delegate sliderViewDidWantPhoto:self];
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
