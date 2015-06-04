//  NVCalibrationController.m
//  CCodeLibrary

#import "NVCalibrationController.h"
#import "CCodeLibrary/CRAPI.h"

@interface NVCalibrationController ()

@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UILabel *titleLabel;

@end

@implementation NVCalibrationController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = CRAPI.sharedInstance.defaultColors.backgroundColor;
    
    _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, 160.0, 60.0)];
    _returnButton.enabled = YES;
    
    [self setupButton:_returnButton
             selector:@selector(returnButtonTapped:)
                title:@"< Return"
              enabled:YES];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 20.0, 368.0, 60.0)];
    
    [self setupLabel:_titleLabel
                text:@"Calibration Manager"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupButton:(UIButton *)button
           selector:(SEL)selector
              title:(NSString *)title
            enabled:(BOOL)enabled
{
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:CRAPI.sharedInstance.defaultColors.titleColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateHighlighted];
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    button.enabled = enabled;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    if (button.enabled)
        button.backgroundColor = CRAPI.sharedInstance.defaultColors.enabledColor;
    
    else
        button.backgroundColor = CRAPI.sharedInstance.defaultColors.disabledColor;
    
    [self.view addSubview:button];
}

- (void)setupLabel:(UILabel *)label
             text:(NSString *)text
{
    label.backgroundColor = UIColor.clearColor;
    label.text = text;
    label.textColor = CRAPI.sharedInstance.defaultColors.textColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:36.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end