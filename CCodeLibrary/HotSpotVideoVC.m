//  HotSpotVideoVC.m
//  CCodeLibrary

#define STD_SLIDER_HEIGHT 31

#import "HotSpotVideoVC.h"
#import "CRAPI.h"

@interface HotSpotVideoVC ()

@property (nonatomic) UIImageView *imageView1, *imageView2, *backgroundImageView;
@property NSInteger index1, index2;
@property (nonatomic) UISlider *slider;
@property CGFloat yMargin, xMargin, timeInterval, imagesPerSecond;
@property (nonatomic) NSTimer *timer;
@property BOOL killTap;

@end

@implementation HotSpotVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _index1 = 0;
    _index2 = 1;
    _xMargin = 20.0;
    _yMargin = 60.0;
    _timeInterval = 0.02;
    _imagesPerSecond = 2.0;
    _killTap = NO;
    
    if (CRAPI.sharedInstance.hsv.numImages)
    {
        _imageView1 = UIImageView.new;
        [self setupImageView:_imageView1];
        _imageView1.image = [UIImage imageWithContentsOfFile:CRAPI.sharedInstance.hsv.imageFiles[_index1]];
    }
    
    if (CRAPI.sharedInstance.hsv.numImages > 1)
    {
        _imageView2 = UIImageView.new;
        [self setupImageView:_imageView2];
        _imageView2.image = [UIImage imageWithContentsOfFile:CRAPI.sharedInstance.hsv.imageFiles[_index2]];
        _imageView2.alpha = 0.0;
        
        _slider = UISlider.new;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.maximumValue = (CRAPI.sharedInstance.hsv.numImages - 1);
        [self.view addSubview:_slider];
        [_slider constrainLeadingToAnchor:self.view.leadingAnchor constant:_xMargin];
        [_slider constrainTrailingToAnchor:self.view.trailingAnchor constant:-_xMargin];
        [_slider constrainBottomToAnchor:self.view.bottomAnchor constant:-((_yMargin - STD_SLIDER_HEIGHT) / 2)];
        
        [_slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
        
        [_slider addTarget:self
                    action:@selector(sliderTouchedDown:)
          forControlEvents:UIControlEventTouchDown];
        
        [_slider addTarget:self
                    action:@selector(sliderTouchedUp:)
          forControlEvents:UIControlEventTouchUpInside];
        
        [_slider addTarget:self
                    action:@selector(sliderTouchedUp:)
          forControlEvents:UIControlEventTouchCancel];
        
        [_slider addGestureRecognizer:
         [[UITapGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(sliderTapped:)]];
    }
    
    if (CRAPI.sharedInstance.hsv.backgroundImageFile)
    {
        _backgroundImageView = UIImageView.new;
        [self setupImageView:_backgroundImageView];
        _backgroundImageView.alpha = 0.1;
        
        _backgroundImageView.image = [UIImage imageWithContentsOfFile:
                                      CRAPI.sharedInstance.hsv.backgroundImageFile];
    }
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    [returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:_xMargin];
    [returnButton constrainTopToAnchor:self.view.topAnchor constant:4.0];
    
    [self startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                              target:self
                                            selector:@selector(moveToNextFrame)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)killTimer
{
    if (_timer && _timer.valid)
        [_timer invalidate];
}

- (void)setupImageView:(UIImageView *)imageView
{
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    
    [self.view addSubview:imageView];
    [imageView constrainToView:self.view leading:0.0 trailing:0.0 top:_yMargin bottom:-_yMargin];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self killTimer];
    CRAPI.sharedInstance.hsv = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    int idx1 = MIN((int)slider.value, (CRAPI.sharedInstance.hsv.numImages - 2));
    int idx2 = MIN(MAX((int)(slider.value + 1), 1), (CRAPI.sharedInstance.hsv.numImages - 1));
    
    if (_index1 != idx1)
    {
        _index1 = idx1;
        _imageView1.image = [UIImage imageWithContentsOfFile:CRAPI.sharedInstance.hsv.imageFiles[_index1]];
    }
    
    if (_index2 != idx2)
    {
        _index2 = idx2;
        _imageView2.image = [UIImage imageWithContentsOfFile:CRAPI.sharedInstance.hsv.imageFiles[_index2]];
    }
    
    _imageView2.alpha = (slider.value - idx1);
}

- (void)sliderTouchedDown:(UISlider *)slider
{
    [self killTimer];
    _killTap = YES;
}

- (void)sliderTouchedUp:(UISlider *)slider
{
    _killTap = NO;
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture
{
    if (!_killTap)
    {
        [self killTimer];
        CGPoint point = [gesture locationInView:_slider];
        float value = ((point.x / _slider.frame.size.width) * _slider.maximumValue);
        value += ((value - (_slider.maximumValue / 2)) / 30.0);
        [_slider setValue:value animated:NO];
        [self sliderValueChanged:_slider];
    }
}

- (void)moveToNextFrame
{
    CGFloat increment = (_timeInterval * _imagesPerSecond);
    
    [_slider setValue:(_slider.value + increment) animated:NO];
    [self sliderValueChanged:_slider];
    
    if (_slider.value > (_slider.maximumValue - increment))
        [self killTimer];
}

@end
