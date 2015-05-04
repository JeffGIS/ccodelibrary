//  NVPhotoViewController.m
//  CCodeLibrary

#import "NVPhotoViewController.h"
#import "UserDefaults.h"

@interface NVPhotoViewController ()

@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UIImageView *photoView;
@property (nonatomic) NSString *directory;
@property (nonatomic) NSArray *imageArray;

@end

@implementation NVPhotoViewController

+ (NVPhotoViewController *)viewerWithPhotosFromDirectory:(NSString *)directory
{
    NVPhotoViewController *photoViewer = [[NVPhotoViewController alloc] init];
    photoViewer.directory = directory;
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
    NSError *error;
    
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:_directory
                                                                  error:&error];
    
    if (error)
        NSLog(@"File Directory Error:%@", error.localizedDescription);
    
    else
    {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
        _imageArray = [directoryContents filteredArrayUsingPredicate:filter];
    }
    
    NSLog(@"%@,%@", _imageArray, directoryContents);
    
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 100.0, self.view.frame.size.width,
                                                               (self.view.frame.size.height - 200.0))];
    
    _photoView.backgroundColor = UIColor.whiteColor;
    _photoView.contentScaleFactor = UIViewContentModeScaleAspectFit;
    
    _photoView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",
                                                         _directory, _imageArray.firstObject]];
    
    [self.view addSubview:_photoView];
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

@end