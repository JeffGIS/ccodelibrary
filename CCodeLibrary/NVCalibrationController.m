//  NVCalibrationController.m
//  CCodeLibrary

#import "NVCalibrationController.h"
#import "CRAPI.h"
#import "SharedDefaults.h"
#import "VerticalSegmentedControl.h"

@interface NVCalibrationController ()

@property (nonatomic) UIButton *returnButton, *testButton, *editButton;
@property (nonatomic) UILabel *titleLabel, *lastCalibrationlabel, *promptLabel;
@property (nonatomic) NSArray *calibrationValues;
@property NVCalibrationType currentType, newType;
@property (nonatomic) CGFloat currentValue;
@property NSInteger currentIndex, counter;
@property (nonatomic, copy) NSString *previousPromptText;

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
    _currentType = NVCalibrationTypeDefault, _newType = NVCalibrationTypeRunningSlope;
    _currentValue = 0.0;
    _currentIndex = 0;

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
    _counter = 1;
    
    for (int i = 0; i < [_calibrationValues[NVCalibrationArrayIndexValue] count]; i++)
    {
        BOOL selected = [_calibrationValues[NVCalibrationArrayIndexSelected][i] boolValue];
        
        if (selected)
        {
            BOOL enabled = NO;
            NSString *title = @"", *valueString = @"";
            
            UIButton *frontButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, yOrigin,
                                                                               buttonWidth, buttonHeight)];
            
            frontButton.tag = _counter;
            
            CGFloat floatValue = [_calibrationValues[NVCalibrationArrayIndexValue][i] floatValue];
            NVCalibrationType type = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][i] integerValue];
            
            switch (type)
            {
                case NVCalibrationTypeRunningSlope:
                    valueString = [NSString stringWithFormat:@"%.2f%%", floatValue];
                    break;
                    
                case NVCalibrationTypeDegrees:
                    valueString = [NSString stringWithFormat:@"%.2f\u00B0", floatValue];
                    break;
                    
                case NVCalibrationTypeRiseRun:
                    valueString = [NSString stringWithFormat:@"1:%i", (int)floatValue];
                    break;
                    
                default:
                    break;
            }
            
            if (frontButton.tag < 2)
            {
                enabled = YES;
                title = [NSString stringWithFormat:@"Calibrate %@", valueString];
            }
            
            else
                title = [NSString stringWithFormat:@"Calibrate %@ Front", valueString];
            
            [self setupButton:frontButton
                     selector:@selector(calibrateButtonTapped:)
                        title:title
                      enabled:enabled
                     fontSize:fontSize];
            
            [self.view addSubview:frontButton];
            
            if (frontButton.tag > 1)
            {
                yOrigin += (buttonHeight + margin);
                _counter++;
                
                UIButton *sideButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, yOrigin,
                                                                                  buttonWidth, buttonHeight)];
                
                sideButton.tag = _counter;
                
                title = [NSString stringWithFormat:@"Calibrate %@ Side", valueString];
                
                [self setupButton:sideButton
                         selector:@selector(calibrateButtonTapped:)
                            title:title
                          enabled:enabled
                         fontSize:fontSize];
                
                [self.view addSubview:frontButton];
            }
            
            yOrigin += (buttonHeight + margin);
            _counter++;
        }
    }
    
    yOrigin += ((10 - _counter) * (buttonHeight + margin));
    
    if (![self.view.subviews containsObject:_promptLabel])
    {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, (yOrigin - margin), buttonWidth,
                                                                 ((912.0 - yOrigin) + margin))];
        
        [self setupLabel:_promptLabel
                    text:@"Place iPad on a flat surface and tap on\n'Calibrate 0.00%' to begin calibration routine."
                fontSize:34.0];
    }
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
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)calibrateButtonTapped:(UIButton *)button
{
    NSUInteger index = ((_currentIndex + 1) / 2);
    NSString *valueString = @"", *buttonString = @"";
    _previousPromptText = _promptLabel.text;
    
    _currentValue = [_calibrationValues[NVCalibrationArrayIndexValue][index] floatValue];
    _currentType = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][index] integerValue];
    
    GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                                          flipRadius:0.0
                                                                                            delegate:self];
    
    [self presentViewController:slopeVC
                       animated:YES
                     completion:nil];
    
    if (_currentIndex == [_calibrationValues[NVCalibrationArrayIndexValue] count])
        _promptLabel.text = @"Calibration Routine is Complete.";
    
    else
    {
        index = ((_currentIndex + 2) / 2);
        
        CGFloat nextValue = [_calibrationValues[NVCalibrationArrayIndexValue][index] floatValue];
        NVCalibrationType nextType = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][index] integerValue];
        
        switch (nextType)
        {
            case NVCalibrationTypeRunningSlope:
                valueString = [NSString stringWithFormat:@"%.2f%%", nextValue];
                break;
                
            case NVCalibrationTypeDegrees:
                valueString = [NSString stringWithFormat:@"%.2f\u00B0", nextValue];
                break;
                
            case NVCalibrationTypeRiseRun:
                valueString = [NSString stringWithFormat:@"1:%i", (int)nextValue];
                break;
                
            default:
                break;
        }
        
        for (UIButton *buttons in self.view.subviews)
        {
            if (buttons.tag == _currentIndex + 2)
                buttonString = buttons.titleLabel.text;
        }
        
        _promptLabel.text = [NSString stringWithFormat:@"Place iPad on a %@ surface and tap on\n'%@' to continue.",
                             valueString, buttonString];
    }
}

- (void)testButtonTapped:(UIButton *)button
{
    _currentType = NVCalibrationTypeDefault;
    
    GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                                          flipRadius:0.0
                                                                                            delegate:self];
    
    [self presentViewController:slopeVC
                       animated:YES
                     completion:nil];
}

- (void)editButtonTapped:(UIButton *)button
{
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    overlayView.alpha = 0.0;
    overlayView.backgroundColor = UIColor.blackColor;
    overlayView.tag = 111;
    [self.view addSubview:overlayView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 576.0, 768.0)
                                                          style:UITableViewStylePlain];
    
    tableView.center = CGPointMake((self.view.frame.size.width / 2.0),
                                   (self.view.frame.size.height / 2.0));
    
    tableView.alpha = 0.0;
    tableView.layer.cornerRadius = 10.0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = UIColor.grayColor;
    tableView.bounces = NO;
    tableView.scrollEnabled = NO;
    tableView.delaysContentTouches = NO;
    tableView.tag = 222;
    
    tableView.sectionHeaderHeight = tableView.rowHeight =
    (tableView.frame.size.height / 6.0);
                                     
    [self.view addSubview:tableView];
    
    [UIView animateWithDuration:0.25 animations:^{
        overlayView.alpha = 0.7;
        tableView.alpha = 1.0;
    }];
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
    switch (_currentType)
    {
        case NVCalibrationTypeRunningSlope:
            break;
            
        case NVCalibrationTypeDegrees:
            break;
            
        case NVCalibrationTypeRiseRun:
            break;
            
        default:
            break;
    }
    
    if (_currentType != NVCalibrationTypeDefault)
    {
        if (slopeData.frontSlope != -9999.0)
        {
            _currentIndex++;
            
            for (UIButton *buttons in self.view.subviews)
            {
                if (buttons.tag == _currentIndex + 1)
                {
                    buttons.enabled = YES;
                    buttons.backgroundColor = CRAPI.sharedInstance.defaultColors.enabledColor;
                }
                
                else if (buttons.tag > 0)
                {
                    buttons.enabled = NO;
                    buttons.backgroundColor = CRAPI.sharedInstance.defaultColors.disabledColor;
                }
            }
        }
        
        else
            _promptLabel.text = _previousPromptText;
    }
    
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

- (BOOL)shouldUseCalibration:(GSSiSlopeViewController *)controller
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return min(([_calibrationValues[NVCalibrationArrayIndexValue] count] + 1), 5);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == [_calibrationValues[NVCalibrationArrayIndexValue] count])
    {
        cell.backgroundColor = UserDefaults.defaults.appleGray;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        VerticalSegmentedControl *segControl = [[VerticalSegmentedControl alloc]
                                                initWithSectionTitles:@[@"Running Slope", @"Slope Angle", @"Rise Run"]];
        
        segControl.frame = CGRectMake(80.0, 10.0, 280.0, (tableView.rowHeight - 20.0));
        segControl.backgroundColor = UIColor.blackColor;
        segControl.layer.cornerRadius = 10.0;
        segControl.layer.masksToBounds = YES;
        segControl.textColor = UIColor.grayColor;
        segControl.selectedTextColor = UIColor.whiteColor;
        segControl.textFont = [UIFont boldSystemFontOfSize:32.0];
        segControl.selectionIndicatorThickness = 0.0;
        segControl.textAlignment = VerticalSegmentedControlTextAlignmentCenter;
        
        [segControl addTarget:self
                       action:@selector(segControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:segControl];
        
        UIButton *addValueButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
        
        [addValueButton setImage:[UIImage imageWithContentsOfFile:
                                  [NSBundle.mainBundle pathForResource:@"greenPlusSign"
                                                                ofType:@"png"]]
                        forState:UIControlStateNormal];
        
        addValueButton.center = CGPointMake(((576.0 + (segControl.frame.origin.x + segControl.frame.size.width)) / 2.0),
                                            (tableView.rowHeight / 2.0));
        
        [addValueButton addTarget:self
                           action:@selector(addCalibrationValue:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:addValueButton];
    }
    
    else
    {
        CGFloat floatValue = [_calibrationValues[NVCalibrationArrayIndexValue][indexPath.row] floatValue];
        NVCalibrationType type = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][indexPath.row] integerValue];
        BOOL selected = [_calibrationValues[NVCalibrationArrayIndexSelected][indexPath.row] boolValue];
        
        switch (type)
        {
            case NVCalibrationTypeRunningSlope:
                cell.textLabel.text = [NSString stringWithFormat:@"%.2f%%", floatValue];
                break;
                
            case NVCalibrationTypeDegrees:
                cell.textLabel.text = [NSString stringWithFormat:@"%.2f\u00B0", floatValue];
                break;
                
            case NVCalibrationTypeRiseRun:
                cell.textLabel.text = [NSString stringWithFormat:@"1:%i", (int)floatValue];
                break;
                
            default:
                break;
        }
        
        if (selected)
        {
            UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:
                                                                             [NSBundle.mainBundle pathForResource:@"checkmark"
                                                                                                           ofType:@"png"]]];
            
            checkmarkView.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
            checkmarkView.contentMode = UIViewContentModeScaleToFill;
            cell.accessoryView = checkmarkView;
        }
        
        else
            cell.accessoryView = nil;
        
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.textColor = UIColor.blackColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:56.0];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.indentationLevel = 1;
        cell.indentationWidth = 60.0;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(0.0, 0.0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:40.0];
    headerLabel.textColor = UIColor.blackColor;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.numberOfLines = 2;
    headerLabel.text = @"Calibration\nValues";
    
    UIView *headerView = [[UIView alloc] initWithFrame:
                          CGRectMake(0.0, 0.0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = UserDefaults.defaults.appleGray;
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 30.0, 140.0,
                                                                        (headerView.frame.size.height - 60.0))];
    
    returnButton.layer.cornerRadius = 10.0;
    returnButton.backgroundColor = UIColor.blackColor;
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    
    [returnButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UserDefaults.defaults.appleBlue
                       forState:UIControlStateHighlighted];
    
    [returnButton setTitle:@"< Return"
                  forState:UIControlStateNormal];
    
    [returnButton addTarget:self
                     action:@selector(dismissTableView:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:returnButton];
    
    return headerView;
}

- (void)dismissTableView:(UIButton *)button
{
    for (UIView *views in self.view.subviews)
    {
        if (views.tag == 111 || views.tag == 222)
        {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 views.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [views removeFromSuperview];
                                 
                                 for (UIButton *buttons in self.view.subviews)
                                 {
                                     if (buttons.tag > 0 && buttons.tag < 99)
                                         [buttons removeFromSuperview];
                                 }
                                 
                                 [self setupCalibrationButtons];
                             }];
        }
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0 &&
        indexPath.row < [_calibrationValues[NVCalibrationArrayIndexValue] count])
    {
        BOOL selected = [_calibrationValues[NVCalibrationArrayIndexSelected][indexPath.row] boolValue];
        
        [SharedDefaults.defaults setCalibrationValueSelected:!selected
                                                     atIndex:indexPath.row];
        
        _calibrationValues = [SharedDefaults.defaults calibrationValueArray];
        
        if (selected)
            [tableView cellForRowAtIndexPath:indexPath].accessoryView = nil;
        
        else
        {
            UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:
                                                                             [NSBundle.mainBundle pathForResource:@"checkmark"
                                                                                                           ofType:@"png"]]];
            
            checkmarkView.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
            checkmarkView.contentMode = UIViewContentModeScaleToFill;
            [tableView cellForRowAtIndexPath:indexPath].accessoryView = checkmarkView;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

- (void)addCalibrationValue:(UIButton *)button
{
    NVSliderController *slider = nil;
    
    switch (_newType)
    {
        case NVCalibrationTypeRunningSlope:
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:(self.view.frame.size.width - 40.0)
                                                     startValue:0.0
                                                       minValue:0.0
                                                       maxValue:100.0
                                                       delegate:self
                                                  configuration:NVSliderConfigurationDefault];
            
        }
            break;
            
        case NVCalibrationTypeDegrees:
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:(self.view.frame.size.width - 40.0)
                                                     startValue:0.0
                                                       minValue:0.0
                                                       maxValue:90.0
                                                       delegate:self
                                                  configuration:NVSliderConfigurationDefault];
            
        }
            break;
            
        case NVCalibrationTypeRiseRun:
            break;
            
        default:
            break;
    }
    
    if (slider)
    {
        [slider showSliderControllerInView:self.view
                                  animated:YES
                                   overlay:YES];
    }
}

- (void)segControlValueChanged:(VerticalSegmentedControl *)segControl
{
    _newType = (NVCalibrationType)(segControl.selectedSegmentIndex + 1);
}

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(CGFloat)value
{
    [sliderView hideSliderController:YES];
}

- (void)sliderViewDidCancel:(NVSliderController *)sliderView
{
    [sliderView hideSliderController:YES];
}

@end