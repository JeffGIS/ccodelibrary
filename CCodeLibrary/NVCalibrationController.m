//  NVCalibrationController.m
//  CCodeLibrary

#import "NVCalibrationController.h"
#import "CRAPI.h"
#import "SharedDefaults.h"
#import "VerticalSegmentedControl.h"

static CGFloat _deviceValues[9][4];
// [0][0] = level frontslope
// [0][1] = level sideslope
// [1][0] = first upslope
// [1][1] = first downslope
// [2][2] = first side right up
// [2][3] = first side right down
// [3][0] = second upslope
// [3][1] = second downslope
// [4][2] = second side right up
// [4][3] = second side right down

@interface NVCalibrationController ()

@property (nonatomic) UIButton *returnButton, *testButton, *editButton;
@property (nonatomic) UILabel *titleLabel, *lastCalibrationlabel, *promptLabel;
@property (nonatomic) NSArray *calibrationValues;
@property NVCalibrationType currentType, newType;
@property (nonatomic) CGFloat currentValue;
@property NSInteger currentIndex, counter;
@property (nonatomic, copy) NSString *previousPromptText, *nextPromptText;
@property BOOL hasBeenFlipped, hasBeenCalibrated;

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
    _hasBeenFlipped = NO;
    _hasBeenCalibrated = YES;

    NSString *lastCalString = [SharedDefaults.defaults stringForKey:@"LastCalString"];
    
    if (!lastCalString || [lastCalString isEqualToString:@""])
    {
        lastCalString = [NSString stringWithFormat:@"This device has NOT been calibrated"];
        _hasBeenCalibrated = NO;
    }
    
    _lastCalibrationlabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 984.0, 728.0, 32.0)];
    
    [self setupLabel:_lastCalibrationlabel
                text:lastCalString
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
                    valueString = [NSString stringWithFormat:@"%.1f%%", floatValue];
                    break;
                    
                case NVCalibrationTypeDegrees:
                    valueString = [NSString stringWithFormat:@"%.1f\u00B0", floatValue];
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
                    text:@"Place the iPad on the level surface and tap on\n'Calibrate 0.0%' to begin calibration routine."
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

- (void)setTestEditButtonsEnabled:(BOOL)enabled
{
    _testButton.enabled = enabled;
    _editButton.enabled = enabled;
    
    if (enabled)
    {
        _testButton.backgroundColor = UserDefaults.defaults.defaultColors.enabledColor;
        _editButton.backgroundColor = UserDefaults.defaults.defaultColors.enabledColor;
    }
    
    else
    {
        _testButton.backgroundColor = UserDefaults.defaults.defaultColors.disabledColor;
        _editButton.backgroundColor = UserDefaults.defaults.defaultColors.disabledColor;
    }
}

- (void)calibrateButtonTapped:(UIButton *)button
{
    [self setTestEditButtonsEnabled:NO];
    
    NSUInteger index = ((_currentIndex + 1) / 2);
    NSString *valueString = @"", *buttonString = @"";
    _previousPromptText = _promptLabel.text;
    
    _currentValue = [_calibrationValues[NVCalibrationArrayIndexValue][index] floatValue];
    _currentType = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][index] integerValue];
    
    GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                                          flipRadius:0.0
                                                                                      useCalibration:NO
                                                                                        steadyFactor:0
                                                                                         countFactor:0
                                                                                      displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                                                            delegate:self];
    if (!_currentIndex)
        slopeVC.promptText = @"Place the iPad on the level surface and tap 'Start' to begin measurement.";
    
    else if (_currentIndex % 2)
        slopeVC.promptText = @"Place the iPad with the arrow pointing upslope and tap 'Start' to begin measurement.";
    
    else
        slopeVC.promptText = @"Place the iPad with the arrow pointing to the left of the upslope and tap 'Start' to begin measurement.";
    
    [self presentViewController:slopeVC
                       animated:YES
                     completion:nil];
    
    [slopeVC removeManualMeasurementButton];
    [slopeVC removeCalDateLabel];
    
    NSUInteger selectedCount = SharedDefaults.defaults.calibrationValueSelectedCount;
    
    if (_currentIndex < selectedCount && selectedCount > 1)
    {
        index = ((_currentIndex + 2) / 2);
        
        CGFloat nextValue = [_calibrationValues[NVCalibrationArrayIndexValue][index] floatValue];
        NVCalibrationType nextType = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][index] integerValue];
        
        switch (nextType)
        {
            case NVCalibrationTypeRunningSlope:
                valueString = [NSString stringWithFormat:@"%.1f%%", nextValue];
                break;
                
            case NVCalibrationTypeDegrees:
                valueString = [NSString stringWithFormat:@"%.1f\u00B0", nextValue];
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
        
        if (!(_currentIndex % 2))
        {
            _promptLabel.text = [NSString stringWithFormat:@"Place the iPad on the %@ surface with the arrow pointing upslope and tap on\n'%@' to continue.",
                                 valueString, buttonString];
        }
        
        else
        {
            _promptLabel.text = [NSString stringWithFormat:@"Place the iPad on the %@ surface with the arrow pointing to the left of the upslope and tap on\n'%@' to continue.",
                             valueString, buttonString];
        }
        
        _nextPromptText = _promptLabel.text;
    }
}

- (void)testButtonTapped:(UIButton *)button
{
    _currentType = NVCalibrationTypeDefault;
    
    GSSiSlopeViewController *slopeVC = nil;
    
    if (_hasBeenCalibrated)
    {
        slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                     flipRadius:0.0
                                                                 useCalibration:YES
                                                                   steadyFactor:0
                                                                    countFactor:0
                                                                 displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                                       delegate:self];
    }
    
    else
    {
        slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                     flipRadius:0.0
                                                                 useCalibration:NO
                                                                   steadyFactor:0
                                                                    countFactor:0
                                                                 displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                                       delegate:self];
    }
    
    [self presentViewController:slopeVC
                       animated:YES
                     completion:nil];
    
    [slopeVC removeManualMeasurementButton];
    [slopeVC removeCalDateLabel];
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

- (void)gssiSlopeViewController:(GSSiSlopeViewController *)controller
             didReturnSlopeData:(NVSlopeData)slopeData
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
    
    if (slopeData.frontSlopePct == -9999.0)
    {
        _currentIndex = 0;
        [self setupCalibrationButtons];
        [self setTestEditButtonsEnabled:YES];
        _promptLabel.text = @"Place the iPad on the level surface and tap on\n'Calibrate 0.0%' to begin calibration routine.";
        return;
    }
    
    if (_currentType != NVCalibrationTypeDefault)
    {
        if (_hasBeenFlipped)
        {
            _deviceValues[_currentIndex][1] = slopeData.frontSlopeDegrees;
            _deviceValues[_currentIndex][3] = slopeData.sideSlopeDegrees;
            _currentIndex++;
            _hasBeenFlipped = NO;
            
            NSUInteger selectedCount = SharedDefaults.defaults.calibrationValueSelectedCount;
            
            if (_currentIndex > selectedCount || selectedCount == 1)
            {
                [self saveCalibrationValues];
                
                _promptLabel.text = @"Calibration Routine is Complete.";
                
                [self setTestEditButtonsEnabled:YES];
                
                NSDate *date = NSDate.date;
                
                [SharedDefaults.defaults saveDate:date
                                           forKey:@"LastCalDate"];
                
                NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                                      dateStyle:NSDateFormatterLongStyle
                                                                      timeStyle:NSDateFormatterLongStyle];
                
                NSString *lastCalString = [NSString stringWithFormat:@"Calibrated on %@", dateString];
                _lastCalibrationlabel.text = lastCalString;
                
                [SharedDefaults.defaults saveString:lastCalString
                                             forKey:@"LastCalString"];
                
                _currentIndex = 0;
            }

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
        {
            _deviceValues[_currentIndex][0] = slopeData.frontSlopeDegrees;
            _deviceValues[_currentIndex][2] = slopeData.sideSlopeDegrees;
            _promptLabel.text = _previousPromptText;
            
            if (slopeData.frontSlopePct != -9999.0)
            {
                _hasBeenFlipped = YES;
                
                NSString *title = @"Turn the iPad 180 degrees and press 'OK' to continue.";
                
                NVLargeAlertView *alert = [NVLargeAlertView showLargeAlertViewinView:self.view
                                                                            delegate:self
                                                                               title:title
                                                                       topButtonText:@"OK"
                                                                    bottomButtonText:nil
                                                                    destructiveIndex:NVLargeAlertIndexNone];
                
                alert.tag = 11111;
            }
        }
    }
}

- (BOOL)saveCalibrationValues
{
    BOOL rtn = YES;
    
    NSMutableArray *deviceValuesArray = [[NSMutableArray alloc] init];
    NSNumber *levelFront = [NSNumber numberWithDouble:(_deviceValues[0][0]+_deviceValues[0][1]) / 2.0];
    NSNumber *levelSide = [NSNumber numberWithDouble:(_deviceValues[0][2]+_deviceValues[0][3]) / 2.0];
    [deviceValuesArray addObject:levelFront];
    [deviceValuesArray addObject:levelSide];
    
    for (int i = 1; i < [_calibrationValues[NVCalibrationArrayIndexValue] count]; i++)
    {
        BOOL selected = [_calibrationValues[NVCalibrationArrayIndexSelected][i] boolValue];
        
        if (!selected)
            break;
        
        int j = ((i - 1) * 2 + 1);
        NSNumber *frontUpslope = [NSNumber numberWithDouble:_deviceValues[j][0]];
        NSNumber *frontDownslope = [NSNumber numberWithDouble:_deviceValues[j][1]];
        [deviceValuesArray addObject:frontUpslope];
        [deviceValuesArray addObject:frontDownslope];
        
        NSNumber *sideUpslope = [NSNumber numberWithDouble:_deviceValues[j+1][2]];
        NSNumber *sideDownslope = [NSNumber numberWithDouble:_deviceValues[j+1][3]];
        [deviceValuesArray addObject:sideUpslope];
        [deviceValuesArray addObject:sideDownslope];
    }
    
    NSMutableArray *valuesArray = [_calibrationValues[NVCalibrationArrayIndexValue] mutableCopy];
    NSMutableArray *typesArray = [_calibrationValues[NVCalibrationArrayIndexType] mutableCopy];
    NSMutableArray *selectedArray = [_calibrationValues[NVCalibrationArrayIndexSelected] mutableCopy];
    NSArray *newArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, deviceValuesArray, nil];
    
    [SharedDefaults.defaults saveCalibrationValueArray:newArray];

    return rtn;
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
    
    for (UIView *subviews in cell.contentView.subviews)
    {
        if (subviews.tag == 444 || subviews.tag == 555)
            [subviews removeFromSuperview];
    }
    
    if (indexPath.row == [_calibrationValues[NVCalibrationArrayIndexValue] count])
    {
        cell.backgroundColor = UserDefaults.defaults.appleGray;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        
        VerticalSegmentedControl *segControl = [[VerticalSegmentedControl alloc]
                                                initWithSectionTitles:@[@"Running Slope", @"Slope Angle"]];
        
        segControl.frame = CGRectMake(80.0, 10.0, 280.0, (tableView.rowHeight - 20.0));
        segControl.backgroundColor = UIColor.blackColor;
        segControl.layer.cornerRadius = 10.0;
        segControl.layer.masksToBounds = YES;
        segControl.textColor = UIColor.grayColor;
        segControl.selectedTextColor = UIColor.whiteColor;
        segControl.textFont = [UIFont boldSystemFontOfSize:36.0];
        segControl.selectionIndicatorThickness = 0.0;
        segControl.textAlignment = VerticalSegmentedControlTextAlignmentCenter;
        segControl.selectedSegmentIndex = (_newType - 1);
        segControl.tag = 444;
        
        [segControl addTarget:self
                       action:@selector(segControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:segControl];
        
        UIButton *addValueButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
        addValueButton.tag = 555;
        
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
                cell.textLabel.text = [NSString stringWithFormat:@"%.1f%%", floatValue];
                break;
                
            case NVCalibrationTypeDegrees:
                cell.textLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", floatValue];
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
        cell.indentationWidth = 120.0;
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
    
    for (UIButton *buttons in headerView.subviews)
    {
        if (buttons.tag > 332 && buttons.tag < 336)
            [buttons removeFromSuperview];
    }
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 30.0, 140.0,
                                                                        (headerView.frame.size.height - 60.0))];
    
    returnButton.layer.cornerRadius = 10.0;
    returnButton.tag = 333;
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
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:
                              CGRectMake((headerView.frame.size.width - ((returnButton.frame.size.height + 10.0) * 2.0)),
                                         returnButton.frame.origin.y,
                                         returnButton.frame.size.height,
                                         returnButton.frame.size.height)];
    
    uploadButton.layer.cornerRadius = 10.0;
    uploadButton.tag = 334;
    uploadButton.backgroundColor = UIColor.whiteColor;
    uploadButton.imageEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    uploadButton.layer.borderColor = UIColor.blackColor.CGColor;
    uploadButton.layer.borderWidth = 2.0;
    
    [uploadButton setImage:[UIImage imageWithContentsOfFile:
                            [NSBundle.mainBundle pathForResource:@"uploadCloud"
                                                          ofType:@"png"]]
                  forState:UIControlStateNormal];
    
    [uploadButton addTarget:self
                     action:@selector(uploadValues:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:uploadButton];
    
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:
                                CGRectMake((headerView.frame.size.width - (returnButton.frame.size.height + 10.0)),
                                           returnButton.frame.origin.y,
                                           returnButton.frame.size.height,
                                           returnButton.frame.size.height)];
    
    downloadButton.layer.cornerRadius = 10.0;
    downloadButton.tag = 335;
    downloadButton.backgroundColor = UIColor.whiteColor;
    downloadButton.imageEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    downloadButton.layer.borderColor = UIColor.blackColor.CGColor;
    downloadButton.layer.borderWidth = 2.0;
    
    [downloadButton setImage:[UIImage imageWithContentsOfFile:
                              [NSBundle.mainBundle pathForResource:@"downloadCloud"
                                                            ofType:@"png"]]
                    forState:UIControlStateNormal];
    
    [downloadButton addTarget:self
                       action:@selector(downloadValues:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:downloadButton];
    
    return headerView;
}

- (void)dismissTableView:(UIButton *)button
{
    NSUInteger selected = SharedDefaults.defaults.calibrationValueSelectedCount;
    CGFloat range = SharedDefaults.defaults.calibrationValueMinRange;
    
    if (selected == 1)
    {
        NVLargeAlertView *alert = [NVLargeAlertView showLargeAlertViewinView:self.view
                                                                    delegate:self
                                                                       title:@"At least 2 values are required to calibrate your device. You currently have only 1 selected value. You will need to select or add an additional value before calibrating."
                                                               topButtonText:@"OK"
                                                            bottomButtonText:nil
                                                            destructiveIndex:NVLargeAlertIndexNone];
        alert.tag = 22222;
    }
    
    else if (range < 1.0)
    {
        NVLargeAlertView *alert = [NVLargeAlertView showLargeAlertViewinView:self.view
                                                                    delegate:self
                                                                       title:@"Calibration values must be at least 1\u00B0 apart and must be in ascending slope order. You will need to fix this by removing and/or adding values before calibrating."
                                                               topButtonText:@"OK"
                                                            bottomButtonText:nil
                                                            destructiveIndex:NVLargeAlertIndexNone];
        alert.tag = 22222;
    }
    
    else
        [self handleTableViewDismissal];
}

- (void)handleTableViewDismissal
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

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SharedDefaults.defaults deleteCalibrationValueAtIndex:indexPath.row];
    _calibrationValues = SharedDefaults.defaults.calibrationValueArray;
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
              withRowAnimation:UITableViewRowAnimationAutomatic];
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
                                                  configuration:NVSliderConfigurationCalibrationRunningSlope];
            
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
                                                  configuration:NVSliderConfigurationCalibrationDegrees];
            
        }
            break;
            
        case NVCalibrationTypeRiseRun:
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:(self.view.frame.size.width - 40.0)
                                                     startValue:1.0
                                                       minValue:1.0
                                                       maxValue:48.0
                                                       delegate:self
                                                  configuration:NVSliderConfigurationCalibrationRiseRun];
            
        }
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
    
    [SharedDefaults.defaults addCalibrationValue:value
                                          ofType:_newType];
    
    _calibrationValues = SharedDefaults.defaults.calibrationValueArray;
    
    for (UITableView *tableViews in self.view.subviews)
    {
        if ([tableViews isKindOfClass:UITableView.class])
            [tableViews reloadData];
    }
}

- (void)sliderViewDidCancel:(NVSliderController *)sliderView
{
    [sliderView hideSliderController:YES];
}

- (void)uploadValues:(UIButton *)button
{
    //implement upload calibration values to server here
}

- (void)downloadValues:(UIButton *)button
{
    //implement download calibration values to server here
}

- (void)largeAlertView:(NVLargeAlertView *)largeAlertView
didTapButtonAtIndex:(NVLargeAlertIndex)buttonIndex
{
    if (buttonIndex == NVLargeAlertIndexTopButton)
    {
        if (largeAlertView.tag == 11111)
        {
            GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCalibrationTarget:0.0
                                                                                                  flipRadius:0.0
                                                                                              useCalibration:NO
                                                                                                steadyFactor:0
                                                                                                 countFactor:0
                                                                                              displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                                                                    delegate:self];
            
            slopeVC.promptText = @"";
            
            [self presentViewController:slopeVC
                               animated:YES
                             completion:nil];
            
            [slopeVC removeManualMeasurementButton];
            [slopeVC removeCalDateLabel];
            
            _promptLabel.text = _nextPromptText;
            
            [largeAlertView hideLargeAlertView:NO];
        }
        
        else if (largeAlertView.tag == 22222)
        {
            [largeAlertView hideLargeAlertView:NO];
            [self handleTableViewDismissal];
        }
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end