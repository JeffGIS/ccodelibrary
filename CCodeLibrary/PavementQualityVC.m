//  PavementQualityVC.m
//  CCodeLibrary

#import "PavementQualityVC.h"
#import "UserDefaults.h"

@interface PavementQualityVC ()

@property (nonatomic, weak) id<PavementQualityDelegate> delegate;

@end

@implementation PavementQualityVC

+ (void)presentPavementQualityInController:(UIViewController *)controller
                                  delegate:(id<PavementQualityDelegate>)delegate
{
    PavementQualityVC *pqvc = PavementQualityVC.new;
    pqvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    pqvc.delegate = delegate;
    [controller presentViewController:pqvc animated:YES completion:nil];
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
    titleLabel.text = @"Select Condition";
    
    [self.view addSubview:titleLabel];
    [titleLabel constrainLeadingToAnchor:backButton.trailingAnchor constant:margin];
    [titleLabel constrainTrailingToAnchor:helpButton.leadingAnchor constant:-margin];
    [titleLabel constrainTopToAnchor:backButton.topAnchor];
    [titleLabel constrainHeightToAnchor:backButton.widthAnchor];
    
    for (int i = 10; i > 0; i--)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = i;
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSString *imageName = [NSString stringWithFormat:@"Rating_%d", i];
        
        [button setImage:[UIImage imageWithContentsOfFile:
                          [NSBundle.mainBundle pathForResource:imageName
                                                        ofType:@"png"]]
                    forState:UIControlStateNormal];
        
        
        
        [button addTarget:self
                   action:@selector(qualityButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
        UILabel *label = UILabel.new;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.backgroundColor = UIColor.clearColor;
        label.numberOfLines = 2;
        label.font = [UIFont boldSystemFontOfSize:132.0];
        label.text = [NSString stringWithFormat:@"%d", i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UserDefaults.defaults.appleBlue;
        label.alpha = 0.7;
        
        [button addSubview:label];
        [label constrainToView:button leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
        
        UIButton *help = [UIButton buttonWithType:UIButtonTypeCustom];
        help.translatesAutoresizingMaskIntoConstraints = NO;
        help.tag = i;
        [help setImage:image1 forState:UIControlStateNormal];
        [help setImage:image2 forState:UIControlStateHighlighted];
        
        [button addSubview:help];
        [help constrainTrailingToAnchor:button.trailingAnchor];
        [help constrainTopToAnchor:button.topAnchor];
        [help constrainWidthToAnchor:backButton.widthAnchor];
        [help constrainHeightToAnchor:backButton.widthAnchor];
        
        [help addTarget:self
                 action:@selector(helpTapped:)
       forControlEvents:UIControlEventTouchUpInside];
        
        switch (i)
        {
            case 10:
                [button constrainTopToAnchor:titleLabel.bottomAnchor constant:margin];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                break;
            case 9:
                [button constrainTopToAnchor:titleLabel.bottomAnchor constant:margin];
                [button constrainLeadingToAnchor:[self.view viewWithTag:10].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:10].widthAnchor];
                break;
            case 8:
                [button constrainTopToAnchor:titleLabel.bottomAnchor constant:margin];
                [button constrainLeadingToAnchor:[self.view viewWithTag:9].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:9].widthAnchor];
                [button constrainTrailingToAnchor:helpButton.trailingAnchor];
                break;
            case 7:
                [button constrainTopToAnchor:[self.view viewWithTag:10].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:10].heightAnchor];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                break;
            case 6:
                [button constrainTopToAnchor:[self.view viewWithTag:9].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:9].heightAnchor];
                [button constrainLeadingToAnchor:[self.view viewWithTag:7].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:7].widthAnchor];
                break;
            case 5:
                [button constrainTopToAnchor:[self.view viewWithTag:8].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:8].heightAnchor];
                [button constrainLeadingToAnchor:[self.view viewWithTag:6].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:6].widthAnchor];
                [button constrainTrailingToAnchor:helpButton.trailingAnchor];
                [button constrainBottomToAnchor:[self.view viewWithTag:6].bottomAnchor];
                break;
            case 4:
                [button constrainTopToAnchor:[self.view viewWithTag:7].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:7].heightAnchor];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                break;
            case 3:
                [button constrainTopToAnchor:[self.view viewWithTag:6].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:6].heightAnchor];
                [button constrainLeadingToAnchor:[self.view viewWithTag:4].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:4].widthAnchor];
                [button constrainBottomToAnchor:[self.view viewWithTag:4].bottomAnchor];
                break;
            case 2:
                [button constrainTopToAnchor:[self.view viewWithTag:5].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:5].heightAnchor];
                [button constrainLeadingToAnchor:[self.view viewWithTag:3].trailingAnchor constant:margin];
                [button constrainWidthToAnchor:[self.view viewWithTag:3].widthAnchor];
                [button constrainTrailingToAnchor:helpButton.trailingAnchor];
                [button constrainBottomToAnchor:[self.view viewWithTag:4].bottomAnchor];
                break;
            case 1:
                [button constrainTopToAnchor:[self.view viewWithTag:4].bottomAnchor constant:margin];
                [button constrainHeightToAnchor:[self.view viewWithTag:4].heightAnchor];
                [button constrainLeadingToAnchor:backButton.leadingAnchor];
                [button constrainTrailingToAnchor:[self.view viewWithTag:4].trailingAnchor];
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

- (void)qualityButtonTapped:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(pavementQualityController:didReturnQuality:)])
        [_delegate pavementQualityController:self didReturnQuality:(int)button.tag];
}

- (void)helpButtonTapped
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"Rating_Overview"
                                                       ofType:@"pdf"];
    
    [NVWebView showWebViewInView:self.view
                  showFileAtPath:filePath
                        delegate:nil];
}

- (void)helpTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"Rating_%ld", button.tag]
                                                       ofType:@"pdf"];
    
    [NVWebView showWebViewInView:self.view
                  showFileAtPath:filePath
                        delegate:nil];
}

@end
