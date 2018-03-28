//  DrivewayCrossingVC.m
//  CCodeLibrary

#import "DrivewayCrossingVC.h"
#import "UserDefaults.h"

@interface DrivewayCrossingVC ()

@property (nonatomic, weak) id<DrivewayCrossingDelegate> delegate;

@end

@implementation DrivewayCrossingVC

+ (void)presentDrivewayCrossingInController:(UIViewController *)controller
                                   delegate:(id<DrivewayCrossingDelegate>)delegate
{
    DrivewayCrossingVC *dcvc = DrivewayCrossingVC.new;
    dcvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    dcvc.delegate = delegate;
    [controller presentViewController:dcvc animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.defaultColors.backgroundColor;
    CGFloat margin = 16.0, inset = -7.0;
    
    UIImage *image1 = [UIImage imageWithContentsOfFile:
                       [NSBundle.mainBundle pathForResource:@"backButton"
                                                     ofType:@"png"]];
    
    UIImage *image2 = [UIImage imageWithContentsOfFile:
                       [NSBundle.mainBundle pathForResource:@"backButtonHighlighted"
                                                     ofType:@"png"]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setImage:image1 forState:UIControlStateNormal];
    [backButton setImage:image2 forState:UIControlStateHighlighted];
    
    [self.view addSubview:backButton];
    [backButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [backButton constrainTopToAnchor:self.view.topAnchor constant:margin];
    [backButton constrainWidthToConstant:60.0];
    [backButton constrainHeightToAnchor:backButton.widthAnchor];
    
    [backButton addTarget:self
                   action:@selector(backButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    
    image1 = [UIImage imageWithContentsOfFile:
              [NSBundle.mainBundle pathForResource:@"question-256x256"
                                            ofType:@"png"]];
    
    image2 = [UIImage imageWithContentsOfFile:
              [NSBundle.mainBundle pathForResource:@"questionMarkHighlighted"
                                            ofType:@"png"]];
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.translatesAutoresizingMaskIntoConstraints = NO;
    helpButton.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [helpButton setImage:image1 forState:UIControlStateNormal];
    [helpButton setImage:image2 forState:UIControlStateHighlighted];
    
    [self.view addSubview:helpButton];
    [helpButton constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [helpButton constrainTopToAnchor:backButton.topAnchor];
    [helpButton constrainWidthToAnchor:backButton.widthAnchor];
    [helpButton constrainHeightToAnchor:backButton.widthAnchor];
    
    [helpButton addTarget:self
                   action:@selector(helpButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = UILabel.new;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textColor = UserDefaults.defaults.defaultColors.textColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:52.0];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = @"Select Driveway Crossing Type";
    
    [self.view addSubview:titleLabel];
    [titleLabel constrainLeadingToAnchor:backButton.trailingAnchor constant:margin];
    [titleLabel constrainTrailingToAnchor:helpButton.leadingAnchor constant:-margin];
    [titleLabel constrainTopToAnchor:backButton.topAnchor];
    [titleLabel constrainHeightToAnchor:backButton.widthAnchor];
    
    for (int i = 1; i < 6; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = i;
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSString *imageName = [NSString stringWithFormat:@"Driveway_%d", i];
        
        [button setImage:[UIImage imageWithContentsOfFile:
                          [NSBundle.mainBundle pathForResource:imageName
                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
        
        [button addTarget:self
                   action:@selector(typeButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
        switch (i)
        {
            case 1:
                [button constrainTopToAnchor:titleLabel.bottomAnchor constant:margin];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                break;
            case 2:
                [button constrainTopToAnchor:titleLabel.bottomAnchor constant:margin];
                [button constrainLeadingToAnchor:[self.view viewWithTag:1].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:1].widthAnchor];
                [button constrainTrailingToAnchor:helpButton.trailingAnchor];
                break;
            case 3:
                [button constrainTopToAnchor:[self.view viewWithTag:1].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:1].heightAnchor];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                break;
            case 4:
                [button constrainTopToAnchor:[self.view viewWithTag:2].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:2].heightAnchor];
                [button constrainLeadingToAnchor:[self.view viewWithTag:3].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:3].widthAnchor];
                [button constrainTrailingToAnchor:helpButton.trailingAnchor];
                [button constrainBottomToAnchor:[self.view viewWithTag:3].bottomAnchor];
                break;
            case 5:
                [button constrainTopToAnchor:[self.view viewWithTag:3].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:3].heightAnchor];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                [button constrainTrailingToAnchor:helpButton.trailingAnchor];
                [button constrainBottomToAnchor:self.view.bottomAnchor constant:-margin];
                break;
            default:break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)typeButtonTapped:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(drivewayCrossingController:didReturnType:)])
        [_delegate drivewayCrossingController:self didReturnType:(int)button.tag];
}

- (void)helpButtonTapped
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"DrivewayCrossing_Overview"
                                                       ofType:@"pdf"];
    
    [NVWebView showWebViewInView:self.view
                  showFileAtPath:filePath
                        delegate:nil];
}

@end
