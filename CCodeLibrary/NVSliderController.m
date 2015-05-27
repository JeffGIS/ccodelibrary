//  NVSliderController.m
//  CCodeLibrary

#import "NVSliderController.h"
#import "UserDefaults.h"

@interface NVSliderController ()

@property (nonatomic) UISlider *slider;
@property (nonatomic) UILabel *sliderLabel;
@property (nonatomic) UIButton *saveButton, *cancelButton;
@property (nonatomic) UIView *overlayView;

@end

@implementation NVSliderController

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate
{
    CGFloat height = 260.0;
    
    self = [super initWithFrame:CGRectMake((center.x - (width / 2.0)),
                                           (center.y - (height / 2.0)), width, height)];
    
    if (self)
    {
        _delegate = delegate;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 4.0;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = UIColor.whiteColor;
        
        CGFloat ticMargin = ((UserDefaults.defaults.redSliderThumb.size.width / 2.0) - 10.0);
        
        UIView *ticView = [[UIView alloc] initWithFrame:CGRectMake(ticMargin, 58.0,
                                                                   (width - (ticMargin * 2.0)), 64.0)];
        
        [self addSubview:ticView];
        
        CGSize ticLabelSize = CGSizeMake(40.0, ticView.frame.size.height);
        
        UILabel *middleTic = [[UILabel alloc] initWithFrame:CGRectMake(((ticView.frame.size.width * 0.5) - (ticLabelSize.width / 2.0)),
                                                                       0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:middleTic
                   value:((maxValue + minValue) / 2.0)];
        
        [ticView addSubview:middleTic];
        
        UILabel *lowTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:lowTic
                   value:minValue];
        
        [ticView addSubview:lowTic];
        
        UILabel *highTic = [[UILabel alloc] initWithFrame:CGRectMake((ticView.frame.size.width - ticLabelSize.width),
                                                                     0.0, ticLabelSize.width, ticLabelSize.height)];
        
        [self setupLabel:highTic
                   value:maxValue];
        
        [ticView addSubview:highTic];
        
        UILabel *midLowTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        
        midLowTic.center = CGPointMake(((middleTic.center.x + lowTic.center.x) / 2.0), middleTic.center.y);
        
        [self setupLabel:midLowTic
                   value:(((minValue * 3.0) + maxValue) / 4.0)];
        
        [ticView addSubview:midLowTic];
        
        UILabel *midHighTic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ticLabelSize.width, ticLabelSize.height)];
        
        midHighTic.center = CGPointMake(((middleTic.center.x + highTic.center.x) / 2.0), middleTic.center.y);
        
        [self setupLabel:midHighTic
                   value:(((maxValue * 3.0) + minValue) / 4.0)];
        
        [ticView addSubview:midHighTic];
        
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
        
        _slider.minimumValue = minValue;
        _slider.maximumValue = maxValue;
        _slider.value = startValue;
        
        [_slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_slider];
        
        _sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 6.0, width, 52.0)];
        
        _sliderLabel.backgroundColor = UIColor.clearColor;
        _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
        _sliderLabel.textColor = UIColor.blackColor;
        _sliderLabel.font = [UIFont boldSystemFontOfSize:56.0];
        _sliderLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_sliderLabel];
        
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.05), (height - 72.0),
                                                                 (width * 0.35), 56.0)];
        
        [self setupButton:_saveButton
                   target:self
                 selector:@selector(saveButtonTapped:)
                    title:@"Save"];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((width * 0.6), (height - 72.0),
                                                                   (width * 0.35), 56.0)];
        
        [self setupButton:_cancelButton
                   target:self
                 selector:@selector(cancelButtonTapped:)
                    title:@"Cancel"];
    }
    
    return self;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
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
    label.text = [NSString stringWithFormat:@"%.0f\n|", value];
    label.font = [UIFont boldSystemFontOfSize:24.0];
    label.textColor = UIColor.redColor;
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)sliderValueChanged:(NVSliderController *)slider
{
    _sliderLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
}

- (void)saveButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate sliderView:self
               didReturnValue:_slider.value];
    }
}

- (void)cancelButtonTapped:(UIButton *)button
{
    if (_delegate)
        [_delegate sliderViewDidCancel:self];
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
    
}

@end