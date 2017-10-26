//  HotSpotVideoVC.m
//  CCodeLibrary

#import "HotSpotVideoVC.h"
#import "CRAPI.h"

@interface HotSpotVideoVC ()

@property (nonatomic) UIImageView *imageView1, *imageView2;
@property (nonatomic) NSMutableArray <UIImage *> *images;
@property NSInteger currentIndex;

@end

@implementation HotSpotVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentIndex = 0;
    
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
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:20.0];
    [returnButton constrainTopToAnchor:self.view.topAnchor constant:4.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupImageView:(UIImageView *)imageView
{
    CGFloat yMargin = 60;
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    
    [self.view addSubview:imageView];
    [imageView constrainToView:self.view leading:0.0 trailing:0.0 top:yMargin bottom:-yMargin];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
    CRAPI.sharedInstance.hsv = nil;
}

@end
