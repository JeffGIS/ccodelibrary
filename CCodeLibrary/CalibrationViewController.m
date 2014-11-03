//  CalibrationViewController.m
//  CCodeLibrary

#import "CalibrationViewController.h"

@interface CalibrationViewController ()

@end

@implementation CalibrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    self.returnButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 20.0, 180.0, 60.0)];
    
    [self.returnButton addTarget:self
                          action:@selector(goBack:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.returnButton];
    
    [self setupButton:self.returnButton
                title:@"< Return"
                 font:[UIFont boldSystemFontOfSize:36.0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateButtonAppearance:self.returnButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
               font:(UIFont *)font
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    button.titleLabel.font = font;
    button.layer.cornerRadius = 10.0;
    button.layer.borderColor = UserDefaults.defaults.green.CGColor;
    button.layer.borderWidth = 6.0;
}

- (void)updateButtonAppearance:(UIButton *)button
{
    if (button.enabled == YES)
    {
        button.backgroundColor = UIColor.whiteColor;
        button.layer.borderColor = UserDefaults.defaults.green.CGColor;
        
        [button setTitleColor:UIColor.blackColor
                     forState:UIControlStateNormal];
    }
    
    else
    {
        button.backgroundColor = UserDefaults.defaults.green;
        button.layer.borderColor = UIColor.grayColor.CGColor;
        
        [button setTitleColor:UIColor.grayColor
                     forState:UIControlStateNormal];
    }
}

- (void)goBack:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end