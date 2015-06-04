//  NVCalibrationController.m
//  CCodeLibrary

#import "NVCalibrationController.h"
#import "CRAPI.h"
#import "SharedDefaults.h"

@interface NVCalibrationController ()

@property (nonatomic) UIButton *returnButton, *testButton, *editButton;
@property (nonatomic) UILabel *titleLabel, *lastCalibrationlabel, *promptLabel;
@property (nonatomic) NSArray *calibrationValues;

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
    
    NSDate *lastCalDate = [SharedDefaults.defaults dateForKey:@"LastCalibrationDate"];
    NSString *lastCalText = @"";
    
    if (!lastCalDate)
        lastCalText = [NSString stringWithFormat:@"Not calibrated"];
    
    _lastCalibrationlabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 984.0, 728.0, 32.0)];
    
    [self setupLabel:_lastCalibrationlabel
                text:lastCalText
            fontSize:24.0];
    
    _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, 160.0, 60.0)];
    _returnButton.enabled = YES;
    
    [self setupButton:_returnButton
             selector:@selector(returnButtonTapped:)
                title:@"< Return"
              enabled:YES
             fontSize:36.0];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 20.0, 368.0, 60.0)];
    
    [self setupLabel:_titleLabel
                text:@"Calibration Manager"
            fontSize:48.0];
    
    _calibrationValues = [SharedDefaults.defaults calibrationValueArray];
    
    [self setupCalibrationButtons];
    
    _testButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 912.0, 354.0, 64.0)];
    
    [self setupButton:_testButton
             selector:@selector(testButtonTapped:)
                title:@"Test"
              enabled:YES
             fontSize:56.0];
    
    _editButton = [[UIButton alloc] initWithFrame:CGRectMake(394.0, 912.0, 354.0, 64.0)];
    
    [self setupButton:_editButton
             selector:@selector(editButtonTapped:)
                title:@"Edit"
              enabled:YES
             fontSize:56.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupCalibrationButtons
{
    NSUInteger yOrigin = 96.0;
    CGFloat buttonWidth = 728.0, margin = 14.0;
    CGFloat buttonHeight = 62.0, fontSize = 48.0;
    
    for (int i = 0; i < _calibrationValues.count; i++)
    {
        BOOL enabled = NO;
        NSString *title = @"";
        
        UIButton *frontButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, yOrigin,
                                                                           buttonWidth, buttonHeight)];
        
        frontButton.tag = (i * 2);
        
        if (frontButton.tag == 0)
        {
            enabled = YES;
            
            title = [NSString stringWithFormat:@"Calibrate %.2f%%",
                     [_calibrationValues[i] floatValue]];
        }
        
        else
        {
            title = [NSString stringWithFormat:@"Calibrate %.2f%% Front",
                     [_calibrationValues[i] floatValue]];
        }
        
        [self setupButton:frontButton
                 selector:@selector(calibrateButtonTapped:)
                    title:title
                  enabled:enabled
                 fontSize:fontSize];
        
        [self.view addSubview:frontButton];
        
        if (frontButton.tag > 0)
        {
            yOrigin += (buttonHeight + margin);
            
            UIButton *sideButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, yOrigin,
                                                                              buttonWidth, buttonHeight)];
            
            frontButton.tag = ((i * 2) + 1);
            
            title = [NSString stringWithFormat:@"Calibrate %.2f%% Side",
                     [_calibrationValues[i] floatValue]];
            
            [self setupButton:sideButton
                     selector:@selector(calibrateButtonTapped:)
                        title:title
                      enabled:enabled
                     fontSize:fontSize];
            
            [self.view addSubview:frontButton];
        }
        
        yOrigin += (buttonHeight + margin);
    }
    
    yOrigin += ((5 - _calibrationValues.count) * ((buttonHeight + margin) * 2.0));
    
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, (yOrigin - margin), buttonWidth, ((912.0 - yOrigin) + margin))];
    
    [self setupLabel:_promptLabel
                text:@"Place iPad on a flat surface and tap on\n'Calibrate 0.00%' to begin calibration routine."
            fontSize:34.0];
}

- (void)setupButton:(UIButton *)button
           selector:(SEL)selector
              title:(NSString *)title
            enabled:(BOOL)enabled
           fontSize:(CGFloat)fontSize
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
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
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
          fontSize:(CGFloat)fontSize
{
    label.backgroundColor = UIColor.clearColor;
    label.text = text;
    label.textColor = CRAPI.sharedInstance.defaultColors.textColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:fontSize];
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [SharedDefaults.defaults saveCalibrationValueArray:_calibrationValues];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)calibrateButtonTapped:(UIButton *)button
{
    
}

- (void)testButtonTapped:(UIButton *)button
{
    GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                                          flipRadius:0.0
                                                                                            delegate:self];
    
    [self presentViewController:slopeVC
                       animated:YES
                     completion:nil];
}

- (void)editButtonTapped:(UIButton *)button
{
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

- (BOOL)shouldUseCalibration:(GSSiSlopeViewController *)controller
{
    return YES;
}

@end