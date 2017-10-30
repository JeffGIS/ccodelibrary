//  HotSpotVideoVC.m
//  CCodeLibrary

#define STD_SLIDER_HEIGHT 31

#import "HotSpotVideoVC.h"
#import "CRAPI.h"

@interface HotSpotVideoVC ()

@property (nonatomic) UIImageView *imageView1, *imageView2, *backgroundImageView;
@property NSInteger index1, index2;
@property (nonatomic) UISlider *slider;
@property CGFloat topMargin, bottomMargin, xMargin, timeInterval, imagesPerSecond;
@property (nonatomic) NSTimer *timer;
@property BOOL killTap, loop;
@property (nonatomic) UILabel *infoLabel;
@property int labelUpdateFactor, timerCounter;
@property (nonatomic) UIButton *playPauseButton, *stopButton, *loopButton;

@end

@implementation HotSpotVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _index1 = 0;
    _index2 = 1;
    _xMargin = 20.0;
    _topMargin = 72.0;
    _bottomMargin = 52.0;
    _timeInterval = 0.02;
    _imagesPerSecond = 2.0;
    _killTap = _loop = NO;
    _labelUpdateFactor = 10;
    
    if (CRAPI.sharedInstance.hsv.backgroundImageFile)
    {
        _backgroundImageView = UIImageView.new;
        [self setupImageView:_backgroundImageView];
        _backgroundImageView.alpha = 1;
        
        _backgroundImageView.image = [UIImage imageWithContentsOfFile:
                                      CRAPI.sharedInstance.hsv.backgroundImageFile];
    }
    
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
        [_slider constrainBottomToAnchor:self.view.bottomAnchor constant:-((_bottomMargin - STD_SLIDER_HEIGHT) / 2)];
        
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
    
    if (CRAPI.sharedInstance.hsv.timeRanges.count)
    {
        _infoLabel = UILabel.new;
        _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _infoLabel.font = [UIFont systemFontOfSize:32.0];
        _infoLabel.textColor = UIColor.whiteColor;
        
        _infoLabel.text = [NSString stringWithFormat:@"%i",
                           CRAPI.sharedInstance.hsv.timeRanges[0].intValue];
        
        [self.view addSubview:_infoLabel];
        [_infoLabel constrainCenterXToAnchor:self.view.centerXAnchor];
        [_infoLabel constrainBottomToAnchor:self.view.bottomAnchor constant:-_bottomMargin];
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
    [returnButton constrainCenterYToAnchor:self.view.topAnchor constant:(_topMargin / 2)];
    
    _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setupVideoButton:_playPauseButton
                     image:@"hsvPause"
                  selector:@selector(playPauseButtonTapped:)];
    
    [_playPauseButton constrainCenterXToAnchor:self.view.centerXAnchor];
    [_playPauseButton constrainCenterYToAnchor:self.view.topAnchor constant:(_topMargin / 2)];
    [_playPauseButton constrainHeightToConstant:(_topMargin * 0.8)];
    [_playPauseButton constrainWidthToAnchor:_playPauseButton.heightAnchor];
    
    _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setupVideoButton:_stopButton
                     image:@"hsvStop"
                  selector:@selector(stopButtonTapped:)];
    
    [_stopButton constrainCenterXToAnchor:self.view.centerXAnchor constant:_topMargin];
    [_stopButton constrainCenterYToAnchor:_playPauseButton.centerYAnchor];
    [_stopButton constrainHeightToAnchor:_playPauseButton.heightAnchor];
    [_stopButton constrainWidthToAnchor:_playPauseButton.heightAnchor];
    
    _loopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loopButton.alpha = 0.5;
    
    [self setupVideoButton:_loopButton
                     image:@"hsvLoop"
                  selector:@selector(loopButtonTapped:)];
    
    [_loopButton constrainCenterXToAnchor:self.view.centerXAnchor constant:(_topMargin * 2)];
    [_loopButton constrainCenterYToAnchor:_playPauseButton.centerYAnchor];
    [_loopButton constrainHeightToAnchor:_playPauseButton.heightAnchor];
    [_loopButton constrainWidthToAnchor:_playPauseButton.heightAnchor];
    
    [self startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)startTimer
{
    _timer = nil;
    _timerCounter = 0;
    [self updateButton:_playPauseButton image:@"hsvPause"];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                              target:self
                                            selector:@selector(moveToNextFrame)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)killTimer
{
    if (_timer && _timer.valid)
    {
        [self updateButton:_playPauseButton image:@"hsvPlay"];
        [_timer invalidate];
    }
}

- (void)setupImageView:(UIImageView *)imageView
{
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    
    [self.view addSubview:imageView];
    
    [imageView constrainToView:self.view leading:0.0 trailing:0.0
                           top:_topMargin bottom:(-_bottomMargin * 2.0)];
}

- (void)setupVideoButton:(UIButton *)button
                   image:(NSString *)image
                selector:(SEL)selector
{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *imagePath = [NSBundle.mainBundle pathForResource:image ofType:@"png"];
    [button setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)updateButton:(UIButton *)button
               image:(NSString *)image
{
    NSString *imagePath = [NSBundle.mainBundle pathForResource:image ofType:@"png"];
    [button setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self killTimer];
    CRAPI.sharedInstance.hsv = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    if (_timer.valid)
        _timerCounter++;
    
    int index = MIN((int)slider.value, (CRAPI.sharedInstance.hsv.numImages - 2));
    
    if (_index1 != index)
    {
        _index1 = index;
        _imageView1.image = [UIImage imageWithContentsOfFile:CRAPI.sharedInstance.hsv.imageFiles[_index1]];
    }
    
    if (_index2 != (index + 1))
    {
        _index2 = (index + 1);
        _imageView2.image = [UIImage imageWithContentsOfFile:CRAPI.sharedInstance.hsv.imageFiles[_index2]];
    }
    
    float offset = (slider.value - index);
    _imageView2.alpha = offset;
    
    if (!_timer.valid || (_timerCounter % _labelUpdateFactor == 0))
    {
        int timeRange = (CRAPI.sharedInstance.hsv.timeRanges[index + 1].intValue -
                         CRAPI.sharedInstance.hsv.timeRanges[index].intValue);
        
        int time = (CRAPI.sharedInstance.hsv.timeRanges[index].intValue + (timeRange * offset));
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterLongStyle
                                                              timeStyle:NSDateFormatterNoStyle];
        
        _infoLabel.text = dateString;
    }
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
    
    if (_slider.value > (_slider.maximumValue - increment))
    {
        if (_loop)
        {
            _timerCounter = 0;
            [_slider setValue:0.0 animated:NO];
        }
        
        else
        {
            [_slider setValue:_slider.maximumValue animated:NO];
            [self killTimer];
        }
    }
    
    [self sliderValueChanged:_slider];
}

- (void)playPauseButtonTapped:(UIButton *)button
{
    if (_timer.valid)
        [self killTimer];
    
    else
        [self startTimer];
}

- (void)stopButtonTapped:(UIButton *)button
{
    [self killTimer];
    [_slider setValue:0.0 animated:NO];
    [self sliderValueChanged:_slider];
}

- (void)loopButtonTapped:(UIButton *)button
{
    _loop = !_loop;
    
    if (_loop)
        _loopButton.alpha = 1.0;
    
    else
        _loopButton.alpha = 0.5;
}

@end
