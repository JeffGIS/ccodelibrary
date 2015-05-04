//  NVPhotoViewController.m
//  CCodeLibrary

#import "NVPhotoViewController.h"
#import "UserDefaults.h"

@interface NVPhotoViewController ()

@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UIImageView *photoView;

@end

@implementation NVPhotoViewController

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
    
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 100.0,
                                                               (self.view.frame.size.width - 40.0),
                                                               (self.view.frame.size.height - 200.0))];
    
    _photoView.backgroundColor = UIColor.whiteColor;
    
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