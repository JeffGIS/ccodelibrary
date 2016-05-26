//  NVPhotoController.m
//  CCodeLibrary

#import "NVPhotoController.h"
#import "CRAPI.h"

@interface NVPhoto ()

@property (nonatomic) NSString *identifier, *key;

@end

@implementation NVPhoto

+ (instancetype)photoWithIdentifier:(NSString *)identifier
                                key:(NSString *)key
{
    NVPhoto *nvp = NVPhoto.new;
    nvp.identifier = identifier;
    nvp.key = key;
    return nvp;
}

@end

@interface NVPhotoController ()

@property (nonatomic, weak) id <NVPhotoControllerDelegate> delegate;
@property (nonatomic) NSString *titleString;
@property (nonatomic) NSArray *photosArray;
@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UIImageView *photoView;
@property NSInteger imageIndex;
@property (nonatomic) UILabel *photoLabel, *titleLabel;

@end

@implementation NVPhotoController

+ (instancetype)photoControllerWithNVPhotosArray:(NSArray *)photosArray
                                        delegate:(id)delegate
                                           title:(NSString *)title
{
    if (!photosArray.count || !delegate)
        return nil;
    
    NVPhotoController *nvpc = NVPhotoController.new;
    nvpc.delegate = delegate;
    nvpc.titleString = title;
    nvpc.photosArray = photosArray;
    return nvpc;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    CGFloat viewHeight = 60.0, margin = 20.0;
    UIFont *font = [UIFont boldSystemFontOfSize:40.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        viewHeight = 40.0, margin = 8.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.lightGrayColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    
    [_returnButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:margin].active = YES;
    [_returnButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_returnButton.heightAnchor constraintEqualToConstant:viewHeight].active = YES;
    
    _titleLabel = UILabel.new;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.backgroundColor = UIColor.clearColor;
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.font = font;
    _titleLabel.text = _titleString;
    
    [self.view addSubview:_titleLabel];
    
    [_titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:margin].active = YES;
    [_titleLabel.topAnchor constraintEqualToAnchor:_returnButton.bottomAnchor].active = YES;
    [_titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margin].active = YES;
    [_titleLabel.heightAnchor constraintEqualToConstant:viewHeight].active = YES;
    
    _photoLabel = UILabel.new;
    _photoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _photoLabel.backgroundColor = UIColor.clearColor;
    _photoLabel.textColor = UIColor.whiteColor;
    _photoLabel.textAlignment = NSTextAlignmentCenter;
    _photoLabel.adjustsFontSizeToFitWidth = YES;
    _photoLabel.font = font;
    
    [self.view addSubview:_photoLabel];
    
    [_photoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:margin].active = YES;
    [_photoLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_photoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margin].active = YES;
    [_photoLabel.heightAnchor constraintEqualToConstant:viewHeight].active = YES;
    
    _photoView = UIImageView.new;
    _photoView.translatesAutoresizingMaskIntoConstraints = NO;
    _photoView.contentMode = UIViewContentModeScaleAspectFit;
    _photoView.userInteractionEnabled = YES;
    _imageIndex = 0;
    
    [self.view addSubview:_photoView];
    
    [_photoView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_photoView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_photoView.bottomAnchor constraintEqualToAnchor:_photoLabel.topAnchor].active = YES;
    [_photoView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    if (_photosArray.count > 1)
    {
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(imageLeftSwiped:)];
        
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        [_photoView addGestureRecognizer:leftSwipe];
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(imageRightSwiped:)];
        
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [_photoView addGestureRecognizer:rightSwipe];
    }
    
    [self updateImage];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)returnButtonTapped:(UIButton *)button
{
    CRAPI.sharedInstance.refreshMap = YES;
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imageLeftSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == (_photosArray.count - 1))
        _imageIndex = 0;
    
    else
        _imageIndex++;
    
    [self updateImage];
}

- (void)imageRightSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == 0)
        _imageIndex = (_photosArray.count - 1);
    
    else
        _imageIndex--;
    
    [self updateImage];
}

- (void)updateImage
{
    if (_photosArray.count)
    {
        NVPhoto *nvp = (NVPhoto *)_photosArray[_imageIndex];
        
        _photoView.image = [UIImage imageWithContentsOfFile:[_delegate getImagePath:self
                                                                             forKey:nvp.key]];
        
        _photoLabel.text = [NSString stringWithFormat:@"%@ (%d of %d)",
                            nvp.identifier, (_imageIndex + 1), _photosArray.count];
    }
    
    else
        _photoLabel.text = @"No photos exist for this item";
}

@end

@interface NVPhotoView ()

@property (nonatomic, weak) id <NVPhotoControllerDelegate> delegate;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSArray *photosArray;
@property NSInteger imageIndex;
@property (nonatomic) CGSize size;

@end

@implementation NVPhotoView

+ (instancetype)showPhotoViewWithNVPhotosArray:(NSArray *)photosArray
                                        inView:(UIView *)view
                                      delegate:(id)delegate
                                    coordinate:(CLLocationCoordinate2D)coordinate
{
    if (!photosArray.count || !delegate)
        return nil;
    
    NVPhotoView *nvpv = NVPhotoView.new;
    nvpv.userInteractionEnabled = YES;
    nvpv.layer.cornerRadius = 10.0;
    nvpv.layer.masksToBounds = YES;
    nvpv.alpha = 0.0;
    nvpv.delegate = delegate;
    nvpv.coordinate = coordinate;
    nvpv.photosArray = photosArray;
    nvpv.imageIndex = 0;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:nvpv
                                                                                    action:@selector(imageLeftSwiped:)];
    
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [nvpv addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:nvpv
                                                                                     action:@selector(imageRightSwiped:)];
    
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [nvpv addGestureRecognizer:rightSwipe];
    
    [nvpv updateInsetImage];
    
    CGFloat aspectRatio = (nvpv.image.size.height / nvpv.image.size.width);
    CGFloat width = 264.0;
    nvpv.size = CGSizeMake(width, (aspectRatio * width));
    [nvpv updatePosition];
    
    [view addSubview:nvpv];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvpv.alpha = 1.0;
                     }];
    
    return nvpv;
}

- (void)updatePosition
{
    self.frame = CGRectMake(0.0, 0.0, _size.width, _size.height);
    CGPoint center = [_delegate getPointForCoordinate:_coordinate];
    CGFloat offset = [_delegate getVerticalOffset];
    self.center = CGPointMake(center.x, ((center.y - offset) - (_size.height / 2.0)));
}

- (void)imageLeftSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == (_photosArray.count - 1))
        _imageIndex = 0;
    
    else
        _imageIndex++;
    
    [self updateInsetImage];
}

- (void)imageRightSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == 0)
        _imageIndex = (_photosArray.count - 1);
    
    else
        _imageIndex--;
    
    [self updateInsetImage];
}

- (void)updateInsetImage
{
    NVPhoto *nvp = (NVPhoto *)_photosArray[_imageIndex];
    
    self.image = [UIImage imageWithContentsOfFile:[_delegate getImagePath:self
                                                                   forKey:nvp.key]];
}

@end