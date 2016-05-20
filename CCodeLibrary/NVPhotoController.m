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
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic) UILabel *photoLabel;

@end

@implementation NVPhotoController

+ (instancetype)photoControllerWithNVPhotosArray:(NSArray *)photosArray
                                        delegate:(id)delegate
                                           title:(NSString *)title
{
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
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.frame = CGRectMake(20.0, 20.0, 180.0, 60.0);
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
    
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 100.0, self.view.frame.size.width,
                                                               (self.view.frame.size.height - 200.0))];
    
    _photoView.contentMode = UIViewContentModeScaleAspectFit;
    _photoView.userInteractionEnabled = YES;
    _imageIndex = 0;
    
    [self.view addSubview:_photoView];
    
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
    
    _photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.view.frame.size.height - 80.0,
                                                            self.view.frame.size.width - 40.0, 60.0)];
    
    _photoLabel.backgroundColor = UIColor.clearColor;
    _photoLabel.textColor = UIColor.whiteColor;
    _photoLabel.textAlignment = NSTextAlignmentCenter;
    _photoLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [self.view addSubview:_photoLabel];
    
    [self updateImage];
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