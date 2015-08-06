//  NVPhotoViewController.m
//  CCodeLibrary

#import "NVPhotoViewController.h"
#import "UserDefaults.h"

@interface NVPhotoViewController ()

@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UIImageView *photoView;
@property (nonatomic, copy) NSString *directory, *identifier;
@property (nonatomic) NSArray *imageArray;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic) UILabel *photoLabel;

@end

@implementation NVPhotoViewController

+ (NVPhotoViewController *)viewerWithPhotosFromDirectory:(NSString *)directory
                                          withIdentifier:(NSString *)identifier
{
    NVPhotoViewController *photoViewer = [[NVPhotoViewController alloc] init];
    photoViewer.directory = directory;
    photoViewer.identifier = identifier;
    return photoViewer;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.blackColor;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, 180.0, 60.0)];
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UserDefaults.defaults.appleBlue
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError *error = nil;
    
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:_directory
                                                                  error:&error];
    
    if (error)
        NSLog(@"File Directory Error:%@", error.localizedDescription);
    
    else if (directoryContents.count)
    {
        NSString *string1 = [NSString stringWithFormat:@"AlleyWallInventory_%@", _identifier];
        NSString *string2 = [NSString stringWithFormat:@"UploadedAlleyWallInventory_%@", _identifier];
        
        NSPredicate *jpgFilter = [NSPredicate predicateWithFormat:
                                  @"self ENDSWITH[cd] '.jpg'"];
        
        NSPredicate *idFilter = [NSPredicate predicateWithFormat:
                                 @"self BEGINSWITH[cd] %@ OR self BEGINSWITH[cd] %@", string1, string2];
        
        NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:
                               [NSArray arrayWithObjects:jpgFilter, idFilter, nil]];
        
        _imageArray = [directoryContents filteredArrayUsingPredicate:filter];
    }
    
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 100.0, self.view.frame.size.width,
                                                               (self.view.frame.size.height - 200.0))];
    
    _photoView.contentMode = UIViewContentModeScaleAspectFit;
    _photoView.userInteractionEnabled = YES;
    
    _imageIndex = 0;
    
    [self.view addSubview:_photoView];
    
    if (_imageArray.count > 1)
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
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imageLeftSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == (_imageArray.count - 1))
        _imageIndex = 0;
    
    else
        _imageIndex++;
    
    [self updateImage];
}

- (void)imageRightSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == 0)
        _imageIndex = (_imageArray.count - 1);
    
    else
        _imageIndex--;
    
    [self updateImage];
}

- (void)updateImage
{
    if (_imageArray.count)
    {
        _photoView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",
                                                             _directory, _imageArray[_imageIndex]]];
        
        _photoLabel.text = [NSString stringWithFormat:@"Photo %lu of %lu",
                            (unsigned long)(_imageIndex + 1), (unsigned long)_imageArray.count];
    }
    
    else
        _photoLabel.text = @"No photos exist for this item";
}

@end