//  HotSpotVideoVC.m
//  CCodeLibrary

#define STD_SLIDER_HEIGHT 31

#import "HotSpotVideoVC.h"
#import "CRAPI.h"

@interface HotSpotVideoVC ()

@property (nonatomic) UIImageView *imageView1, *imageView2;
@property (nonatomic) NSMutableArray <UIImage *> *images;
@property NSInteger currentIndex;
@property (nonatomic) UISlider *slider;
@property CGFloat yMargin, xMargin;

@end

@implementation HotSpotVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentIndex = 0;
    _images = NSMutableArray.array;
    _xMargin = 20.0, _yMargin = 60.0;
    
    for (NSString *filePath in CRAPI.sharedInstance.hsv.imageFiles)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [_images addObject:image];
    }
    
    if (_images.count)
    {
        _imageView1 = UIImageView.new;
        [self setupImageView:_imageView1];
        _imageView1.image = _images[0];
    }
    
    if (_images.count > 1)
    {
        _imageView2 = UIImageView.new;
        [self setupImageView:_imageView2];
        _imageView2.image = _images[1];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    CRAPI.sharedInstance.hsv = nil;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    int image1 = MIN((int)slider.value, ((int)_images.count - 2));
    int image2 = MIN(MAX((int)(slider.value + 1), 1), ((int)_images.count - 1));
    _imageView1.image = _images[image1];
    _imageView2.image = _images[image2];
    _imageView2.alpha = (slider.value - image1);
}

@end
