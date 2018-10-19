//  NVCalibrationController.m
//  CCodeLibrary

#import "NVCalibrationController.h"
#import "CRAPI.h"
#import "SharedDefaults.h"
#import "VerticalSegmentedControl.h"
#import "GSSiSlopeViewController.h"
#import "NVSliderController.h"
#import "NVAlertView.h"
#import "MathUtil.h"
#import "CurbRampData.h"

static double _deviceValues[9][4];
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

@interface NVCalibrationController () <GSSiSlopeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,NVSliderControllerDelegate,NVAlertViewDelegate>

@property (nonatomic) UIButton *returnButton, *testButton, *editButton;
@property (nonatomic) UILabel *titleLabel, *lastCalibrationlabel, *promptLabel;
@property (nonatomic, copy) NSArray *calibrationValues;
@property NVCalibrationType currentType, newType;
@property (nonatomic) double currentValue;
@property NSInteger currentIndex, counter;
@property (nonatomic, copy) NSString *previousPromptText, *nextPromptText;
@property BOOL hasBeenFlipped, hasBeenCalibrated;
@property int initialHeading;
@property double initialSlope;
@property double startValue;
@property int addAtIndex;

@end

@implementation NVCalibrationController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _useHeadingCalibration = YES;
        _headingErrorShown = NO;
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
    
    self.view.backgroundColor = CRAPI.sharedInstance.defaultColors.backgroundColor;
    _currentType = NVCalibrationTypeDefault, _newType = NVCalibrationTypeRunningSlope;
    _currentValue = 0.0;
    _currentIndex = 0;
    _hasBeenFlipped = NO;
    _hasBeenCalibrated = YES;

    NSString *lastCalString = [self refreshCalDateLabel];
    
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
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.frame = CGRectMake(688.0, 16.0, 68.0, 68.0);
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"question-256x256"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"questionMarkHighlighted"
                                                                                        ofType:@"png"]]
                forState:UIControlStateHighlighted];
    
    [helpButton addTarget:self
                   action:@selector(helpButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:helpButton];
    
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

- (void)gssiSlopeViewControllerDidCancelForSystemCalibration:(GSSiSlopeViewController *)controller
{
    _useHeadingCalibration = NO;
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NVAlertView *alert =
    [NVAlertView showLargeAlertViewinView:self.view
                                 delegate:self
                                    title:@"The app became inactive. Please place iPad in previous position to repeat measurement."
                          buttonTextArray:@[@"OK"]
                         destructiveIndex:0];
    
    alert.tag = 44444;
}

- (NSString *)refreshCalDateLabel
{
    NSString *lastCalString = [SharedDefaults.defaults stringForKey:@"LastCalString"];
    
    if (!lastCalString || [lastCalString isEqualToString:@""])
    {
        lastCalString = [NSString stringWithFormat:@"This device has NOT been calibrated"];
        _hasBeenCalibrated = NO;
    }
    
    return lastCalString;
}

- (void)setupCalibrationButtons
{
    NSUInteger yOrigin = 96.0;
    double buttonWidth = 728.0, margin = 14.0;
    double buttonHeight = 62.0, fontSize = 48.0;
    _counter = 1;
    
    for (int i = 0; i < [_calibrationValues[NVCalibrationArrayIndexValue] count]; i++)
    {
        BOOL enabled = NO;
        NSString *title = @"", *valueString = @"";
        
        UIButton *frontButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, yOrigin,
                                                                           buttonWidth, buttonHeight)];
        
        frontButton.tag = _counter;
        
        double doubleValue = [_calibrationValues[NVCalibrationArrayIndexValue][i] doubleValue];
        NVCalibrationType type = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][i] integerValue];
        
        switch (type)
        {
            case NVCalibrationTypeRunningSlope:
                valueString = [NSString stringWithFormat:@"%.1f%%", doubleValue];
                break;
            case NVCalibrationTypeDegrees:
                valueString = [NSString stringWithFormat:@"%.1f\u00B0", doubleValue];
                break;
            case NVCalibrationTypeRiseRun:
                valueString = [NSString stringWithFormat:@"1:%i", (int)doubleValue];
                break;
            default:
                break;
        }
        
        if (frontButton.tag < 2)
        {
            enabled = YES;
            title = [NSString stringWithFormat:@"Flat             Calibrate %@", valueString];
        }
        
        else
            title = [NSString stringWithFormat:@"%i F               Calibrate %@ Front", i,valueString];
        
        frontButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
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
            
            UIButton *sideButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, yOrigin, buttonWidth, buttonHeight)];
            sideButton.tag = _counter;
            sideButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            title = [NSString stringWithFormat:@"%i S               Calibrate %@ Side", i,valueString];
            
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
    
    yOrigin += ((10 - _counter) * (buttonHeight + margin));
    
    if (![self.view.subviews containsObject:_promptLabel])
    {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, (yOrigin - margin), buttonWidth,
                                                                 ((912.0 - yOrigin) + margin))];
        
        [self setupLabel:_promptLabel
                    text:@"Place the iPad on a level surface and tap on'Calibrate 0.0%' to begin calibration routine."
                fontSize:34.0];
    }
}

- (void)setupButton:(UIButton *)button
           selector:(SEL)selector
              title:(NSString *)title
            enabled:(BOOL)enabled
           fontSize:(double)fontSize
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:CRAPI.sharedInstance.defaultColors.titleColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
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
          fontSize:(double)fontSize
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
 //   if (CRAPI.sharedInstance.currentModule == DETAIL_MODULE)
 //       [CurbRampData saveCalibration];
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
    
    _currentValue = [_calibrationValues[NVCalibrationArrayIndexValue][index] doubleValue];
    _currentType = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][index] integerValue];
    
    GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCriticalValue:-9999.0
                                                                               criticalSideValue:-9999.0
                                                                                      errorValue:0.0
                                                                                  useCalibration:NO
                                                                           useHeadingCalibration:_useHeadingCalibration
                                                                                    steadyFactor:0.0
                                                                                     countFactor:0.0
                                                                                  displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                                                        delegate:self];
    
    slopeVC.fromCalibration = YES;
    
    if (!_currentIndex)
        slopeVC.promptText = @"Place the iPad on a level surface and tap 'Start' to begin measurement.";
    
    else if (_currentIndex % 2)
        slopeVC.promptText = @"Place the iPad with the arrow pointing upslope and tap 'Start' to begin measurement.";
    
    else
        slopeVC.promptText = @"Place the iPad with the arrow pointing to the left of the upslope and tap 'Start' to begin measurement.";
    
    [self presentViewController:slopeVC animated:YES completion:nil];
    NSUInteger count = [_calibrationValues[0] count];
    index = ((_currentIndex + 2) / 2);
    
    if ((index < count) && (count > 1))
    {
        double nextValue = [_calibrationValues[NVCalibrationArrayIndexValue][index] doubleValue];
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
        
        if (_currentIndex % 2)
        {
            _promptLabel.text = [NSString stringWithFormat:
                                 @"Place the iPad on the %@ surface with the arrow pointing to the left of the upslope and tap on\n'%@' to continue.",
                                 valueString, buttonString];
        }
        
        else
        {
            _promptLabel.text = [NSString stringWithFormat:
                                 @"Place the iPad on the %@ surface with the arrow pointing upslope and tap on\n'%@' to continue.",
                                 valueString, buttonString];
        }
        
        _nextPromptText = _promptLabel.text;
    }
}

- (void)testButtonTapped:(UIButton *)button
{
    _currentType = NVCalibrationTypeDefault;
    
    GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCriticalValue:-9999.0
                                                      criticalSideValue:-9999.0
                                                             errorValue:0.0
                                                         useCalibration:_hasBeenCalibrated
                                                                           useHeadingCalibration:NO
                                                           steadyFactor:0.0
                                                            countFactor:0.0
                                                         displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                               delegate:self];
    
    slopeVC.fromCalibration = YES;
    [self presentViewController:slopeVC animated:YES completion:nil];
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
    
    NSInteger divisor = (min(([_calibrationValues[NVCalibrationArrayIndexValue] count] + 1), 6) + 1);
    
    tableView.sectionHeaderHeight = tableView.rowHeight = (tableView.frame.size.height / divisor);
                                     
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
        _promptLabel.text = @"Place the iPad on a level surface and tap on 'Calibrate 0.0%' to begin calibration routine.";
        return;
    }
    
    if (_currentType != NVCalibrationTypeDefault)
    {
        BOOL headingError = NO;
        
        if (_hasBeenFlipped)
        {
            _deviceValues[_currentIndex][1] = slopeData.frontSlopeDegrees;
            _deviceValues[_currentIndex][3] = slopeData.sideSlopeDegrees;
            _hasBeenFlipped = NO;
            
            NSUInteger count = [_calibrationValues[0] count];
            count -= 1;
            count *= 2;
            count += 1;
            
            if (CRAPI.sharedInstance.currentModule != GMMOBILE_MODULE && !_headingErrorShown)
            {
                if (!_currentIndex)
                {
                    double headingDiff = 0;
                    double MAXHEADING_ERROR = 90;
                    
                    headingDiff = DeltaAZD (LTWOPI(_initialHeading*DEGtoRAD),LTWOPI(slopeData.heading*DEGtoRAD));
                    headingDiff = fabs (headingDiff);
                    headingDiff *= RADtoDEG;
                    if (headingDiff > 180 + MAXHEADING_ERROR || headingDiff < 180 - MAXHEADING_ERROR)
                        headingError = YES;
                }
                else
                {
                    if (_currentIndex % 2)//front
                    {
                        if (slopeData.frontSlopeDegrees > 0)
                            headingError = YES;
                    }
                    else if (slopeData.sideSlopeDegrees > 0)
                            headingError = YES;
                }
            }
            
            _currentIndex++;

            if ((CRAPI.sharedInstance.showCompassCalibrationScreen && headingError) && CRAPI.sharedInstance.currentModule != GMMOBILE_MODULE && !_headingErrorShown)
            {
                NVAlertView *alert =
                [NVAlertView showLargeAlertViewinView:self.view
                                             delegate:self
                                                title:@"The device appears to be pointed in the wrong direction. Calibration process will restart."
                                      buttonTextArray:@[@"OK"]
                                     destructiveIndex:0];
                
                alert.tag = 33333;
            }
            
            else
            {
                if (_currentIndex >= count || count == 1)
                {
                    [self saveCalibrationValues];
                    _promptLabel.text = @"Calibration Routine is Complete.";
                    [self setTestEditButtonsEnabled:YES];
                    
                    NSDate *date = NSDate.date;
                    [SharedDefaults.defaults saveDate:date forKey:@"LastCalDate"];
                    
                    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                                          dateStyle:NSDateFormatterLongStyle
                                                                          timeStyle:NSDateFormatterLongStyle];
                    
                    NSString *lastCalString = [NSString stringWithFormat:@"Calibrated on %@", dateString];
                    _lastCalibrationlabel.text = lastCalString;
                    [SharedDefaults.defaults saveString:lastCalString forKey:@"LastCalString"];
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
        }
        
        else
        {
            _initialSlope = slopeData.frontSlopeDegrees;
            _deviceValues[_currentIndex][0] = slopeData.frontSlopeDegrees;
            _deviceValues[_currentIndex][2] = slopeData.sideSlopeDegrees;
            _promptLabel.text = _previousPromptText;
            
            if (_currentIndex == 0)
                _initialHeading = (int)round(slopeData.heading);
            
            else if (CRAPI.sharedInstance.currentModule != GMMOBILE_MODULE && !_headingErrorShown)
            {
                if (_currentIndex % 2)//front
                {
                    if (_initialSlope < 0)
                        headingError = YES;
                }
                 else if (slopeData.sideSlopeDegrees < 0)
                    headingError = YES;

            }
            
            if ((CRAPI.sharedInstance.showCompassCalibrationScreen && headingError) && CRAPI.sharedInstance.currentModule != GMMOBILE_MODULE && !_headingErrorShown)
            {
                NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                                  delegate:self
                                                                     title:@"The device appears to be pointed in the wrong direction. Calibration process will restart."
                                                           buttonTextArray:@[@"OK"]
                                                          destructiveIndex:0];
                
                alert.tag = 33333;
            }
            
            else if (slopeData.frontSlopePct != -9999.0)
            {
                _hasBeenFlipped = YES;
                
                NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                                  delegate:self
                                                                     title:@"Turn the iPad 180 degrees and press 'OK' to continue."
                                                           buttonTextArray:@[@"OK"]
                                                          destructiveIndex:0];
                
                alert.tag = 11111;
            }
        }
    }
}

- (BOOL)saveCalibrationValues
{
    BOOL rtn = YES;
    
    NSMutableArray *deviceValuesArray = [[NSMutableArray alloc] init];
    NSNumber *levelFront = [NSNumber numberWithDouble:(_deviceValues[0][0] + _deviceValues[0][1]) / 2.0];
    NSNumber *levelSide = [NSNumber numberWithDouble:(_deviceValues[0][2] + _deviceValues[0][3]) / 2.0];

    [deviceValuesArray addObject:levelFront];
    [deviceValuesArray addObject:levelSide];
    
    for (int i = 1; i < [_calibrationValues[NVCalibrationArrayIndexValue] count]; i++)
    {
        int j = ((i - 1) * 2 + 1);
        NSNumber *frontUpslope = [NSNumber numberWithDouble:_deviceValues[j][0]];
        NSNumber *frontDownslope = [NSNumber numberWithDouble:_deviceValues[j][1]];
        [deviceValuesArray addObject:frontUpslope];
        [deviceValuesArray addObject:frontDownslope];
        
        NSNumber *sideUpslope = [NSNumber numberWithDouble:_deviceValues[j + 1][2]];
        NSNumber *sideDownslope = [NSNumber numberWithDouble:_deviceValues[j + 1][3]];
        [deviceValuesArray addObject:sideUpslope];
        [deviceValuesArray addObject:sideDownslope];
    }
    
    NSArray *valuesArray = _calibrationValues[NVCalibrationArrayIndexValue];
    NSArray *typesArray = _calibrationValues[NVCalibrationArrayIndexType];
    NSArray *selectedArray = @[@YES];//this is just a placeholder
    NSArray *newArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, deviceValuesArray, nil];
    
    [SharedDefaults.defaults saveCalibrationValueArray:newArray];
    if (CRAPI.sharedInstance.currentModule == DETAIL_MODULE)
        [CurbRampData saveCalibration];
    return rtn;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return min(([_calibrationValues[NVCalibrationArrayIndexValue] count] + 1), 6);
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
        
        if ([_calibrationValues[0] count] < 5)
        {
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
            segControl.frame = CGRectMake(148.0, 10.0, 280.0, (tableView.rowHeight - 20.0));
    }
    
    else
    {
        double doubleValue = [_calibrationValues[NVCalibrationArrayIndexValue][indexPath.row] doubleValue];
        NVCalibrationType type = (NVCalibrationType)[_calibrationValues[NVCalibrationArrayIndexType][indexPath.row] integerValue];
        
        switch (type)
        {
            case NVCalibrationTypeRunningSlope:
                cell.textLabel.text = [NSString stringWithFormat:@"%.1f%%", doubleValue];
                break;
                
            case NVCalibrationTypeDegrees:
                cell.textLabel.text = [NSString stringWithFormat:@"%.1f\u00B0", doubleValue];
                break;
                
            case NVCalibrationTypeRiseRun:
                cell.textLabel.text = [NSString stringWithFormat:@"1:%i", (int)doubleValue];
                break;
                
            default:
                break;
        }
        
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.textColor = UIColor.blackColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:56.0];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
    
    [returnButton setTitleColor:UIColor.lightGrayColor
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
    NSUInteger count = [_calibrationValues[0] count];
    double range = SharedDefaults.defaults.calibrationValueMinRange;
    
    if (count == 1)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:@"At least 2 values are required to calibrate your device. You currently have only 1 selected value. You will need to select or add an additional value before calibrating."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
        alert.tag = 22222;
    }
    
    else if (range < 0.0)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:@"Calibration values must be in ascending slope order. You will need to fix this by removing and/or adding values before calibrating."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
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
                                 NSString *lastCalString = [self refreshCalDateLabel];
                                 _lastCalibrationlabel.text = lastCalString;
                             }];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return NO;
    
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return;
    _startValue = [_calibrationValues[NVCalibrationArrayIndexValue][indexPath.row] doubleValue];
    _addAtIndex = (int)indexPath.row;
    [self addCalibrationValue:nil];
    
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
    if (button)
    {
        _addAtIndex = -1;
        _startValue = 0.0;
    }
    if ([_calibrationValues[0] count] > 4 && button)
        return;
    
    NVSliderController *slider = nil;
    
    switch (_newType)
    {
        case NVCalibrationTypeRunningSlope:
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:(self.view.frame.size.width - 40.0)
                                                     startValue:_startValue
                                                       minValue:0.0
                                                       maxValue:20.0
                                                       delegate:self
                                                  configuration:NVSliderConfigurationCalibrationRunningSlope
                                                           type:NVSliderMeasurementTypeDefault
                                                           unit:@""];
        }
            break;
            
        case NVCalibrationTypeDegrees:
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:(self.view.frame.size.width - 40.0)
                                                     startValue:_startValue
                                                       minValue:0.0
                                                       maxValue:180.0
                                                       delegate:self
                                                  configuration:NVSliderConfigurationCalibrationDegrees
                                                           type:NVSliderMeasurementTypeDefault
                                                           unit:@""];
        }
            break;
            
        case NVCalibrationTypeRiseRun:
        {
            slider = [[NVSliderController alloc] initWithCenter:self.view.center
                                                          width:(self.view.frame.size.width - 40.0)
                                                     startValue:max(1.0,_startValue)
                                                       minValue:1.0
                                                       maxValue:48.0
                                                       delegate:self
                                                  configuration:NVSliderConfigurationCalibrationRiseRun
                                                           type:NVSliderMeasurementTypeDefault
                                                           unit:@""];
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
    
    [SharedDefaults.defaults setCalibrationValueArrayToType:_newType];
    _calibrationValues = SharedDefaults.defaults.calibrationValueArray;
    
    for (UITableView *tableViews in self.view.subviews)
    {
        if ([tableViews isKindOfClass:UITableView.class])
            [tableViews reloadData];
    }
}

- (void)sliderView:(NVSliderController *)sliderView
    didReturnValue:(double)value
{
    [sliderView hideSliderController:YES];
    
    if (_addAtIndex < 0)
        [SharedDefaults.defaults addCalibrationValue:value
                                              ofType:_newType];
    else
        [SharedDefaults.defaults replaceCalibrationValue:value
                                                 atIndex:_addAtIndex];
    
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

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:NO];
    
    if (buttonIndex == 0)
    {
        switch (alertView.tag)
        {
            case 11111:
            {
                GSSiSlopeViewController *slopeVC = [GSSiSlopeViewController slopeControllerWithCriticalValue:-9999.0
                                                                                           criticalSideValue:-9999.0
                                                                                                  errorValue:0.0
                                                                                              useCalibration:NO
                                                                                       useHeadingCalibration:_useHeadingCalibration
                                                                                                steadyFactor:0.0
                                                                                                 countFactor:0.0
                                                                                              displayDegrees:(_currentType == NVCalibrationTypeDegrees)
                                                                                                    delegate:self];
                
                slopeVC.fromCalibration = YES;
                slopeVC.promptText = @"";
                [self presentViewController:slopeVC animated:YES completion:nil];
                _promptLabel.text = _nextPromptText;
            }
                break;
            case 22222:
                [self handleTableViewDismissal];
                break;
            case 33333:
                if (_delegate)
                    [_delegate calibrationControllerNeedsRefresh:self];
                break;
            case 44444:
                [self calibrateButtonTapped:nil];
                break;
            default:
                break;
        }
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (CRAPI.sharedInstance.presentUpsideDown)
        return UIInterfaceOrientationPortraitUpsideDown;
    
    else
        return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (CRAPI.sharedInstance.presentUpsideDown)
        return UIInterfaceOrientationMaskPortraitUpsideDown;
    
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void)helpButtonTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"NVCRISHelp_Calibration"
                                                       ofType:@"pdf"];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath
                                          delegate:nil];
#pragma unused(nvwv)
}

@end
