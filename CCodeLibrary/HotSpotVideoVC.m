//  HotSpotVideoVC.m
//  CCodeLibrary

#define STD_SLIDER_HEIGHT 31

#import "HotSpotVideoVC.h"
#import "CRAPI.h"

@interface HotSpotVideoVC ()

@property (nonatomic) UIImageView *imageView1, *imageView2, *backgroundImageView;
@property (nonatomic) NSMutableArray <UIImage *> *images;
@property NSInteger index1, index2;
@property (nonatomic) UISlider *slider;
@property CGFloat yMargin, xMargin, timeInterval, imagesPerSecond;
@property (nonatomic) NSTimer *timer;

@end

@implementation HotSpotVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _index1 = 0;
    _index2 = 1;
    _images = NSMutableArray.array;
    _xMargin = 20.0;
    _yMargin = 60.0;
    _timeInterval = 0.02;
    _imagesPerSecond = 2.0;
    
    for (NSString *filePath in CRAPI.sharedInstance.hsv.imageFiles)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [_images addObject:image];
    }
    
    if (_images.count)
    {
        _imageView1 = UIImageView.new;
        [self setupImageView:_imageView1];
        _imageView1.image = _images[_index1];
    }
    
    if (_images.count > 1)
    {
        _imageView2 = UIImageView.new;
        [self setupImageView:_imageView2];
        _imageView2.image = _images[_index2];
        _imageView2.alpha = 0.0;
        
        _slider = UISlider.new;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.maximumValue = (_images.count - 1);
        [self.view addSubview:_slider];
        [_slider constrainLeadingToAnchor:self.view.leadingAnchor constant:_xMargin];
        [_slider constrainTrailingToAnchor:self.view.trailingAnchor constant:-_xMargin];
        [_slider constrainBottomToAnchor:self.view.bottomAnchor constant:-((_yMargin - STD_SLIDER_HEIGHT) / 2)];
        
        [_slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                              target:self
                                            selector:@selector(moveToNextFrame)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [_timer invalidate];
    CRAPI.sharedInstance.hsv = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    int idx1 = MIN((int)slider.value, ((int)_images.count - 2));
    int idx2 = MIN(MAX((int)(slider.value + 1), 1), ((int)_images.count - 1));
    
    if (_index1 != idx1)
    {
        _index1 = idx1;
        _imageView1.image = _images[_index1];
    }
    
    if (_index2 != idx2)
    {
        _index2 = idx2;
        _imageView2.image = _images[_index2];
    }
    
    _imageView2.alpha = (slider.value - idx1);
}

- (void)moveToNextFrame
{
    CGFloat increment = (_timeInterval * _imagesPerSecond);
    
    [_slider setValue:(_slider.value + increment) animated:NO];
    [self sliderValueChanged:_slider];
    
    if (_slider.value > (_slider.maximumValue - increment))
        [_timer invalidate];
}

@end
