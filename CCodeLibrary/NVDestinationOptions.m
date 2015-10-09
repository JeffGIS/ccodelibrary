//  NVDestinationOptions.m
//  CCodeLibrary

#import "NVDestinationOptions.h"
#import "UserDefaults.h"

@interface NVDestinationOptions ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) NSInteger frequency, timeDepart, timeReturn, destinationID;
@property (nonatomic) UIPickerView *frequencyPicker;
@property (nonatomic) UIDatePicker *departTimePicker, *returnTimePicker;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSArray *frequencyTitles;

@end

@implementation NVDestinationOptions

+ (NSString *)frequencyTitleForFrequency:(NSInteger)frequency
{
    NSString *frequencyTitle = @"";
    
    switch (frequency)
    {
        case 1:
            frequencyTitle = @"Once per month";
            
        case 2:
            frequencyTitle = @"Twice per month";
            break;
            
        case 3:
            frequencyTitle = @"3 times per month";
            break;
            
        case 4:
            frequencyTitle = @"Once per week";
            break;
            
        case 8:
            frequencyTitle = @"Twice per week";
            break;
            
        case 12:
            frequencyTitle = @"3 times per week";
            break;
            
        case 16:
            frequencyTitle = @"4 times per week";
            break;
            
        case 20:
            frequencyTitle = @"5 times per week";
            break;
            
        case 24:
            frequencyTitle = @"6 times per week";
            break;
            
        case 28:
            frequencyTitle = @"Once per day";
            break;
            
        case 56:
            frequencyTitle = @"Twice per day";
            break;
            
        case 84:
            frequencyTitle = @"3 times per day";
            break;
            
        default:
            break;
    }
    
    return frequencyTitle;
}

+ (NVDestinationOptions *)showDestinationOptionsInView:(UIView *)view
                                              delegate:(id)delegate
                                             frequency:(NSInteger)frequency
                                            timeDepart:(NSInteger)timeDepart
                                            timeReturn:(NSInteger)timeReturn
                                         destinationID:(NSInteger)destinationID
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat minBounds = (MIN(bounds.size.width, bounds.size.height) * 0.9);
    
    NVDestinationOptions *destOpt =
    [[NVDestinationOptions alloc] initWithFrame:CGRectMake(0.0, 0.0, minBounds, minBounds)];
    
    destOpt.center = CGPointMake((bounds.size.width / 2.0),
                                 (bounds.size.height / 2.0));
    
    destOpt.delegate = delegate;
    destOpt.frequency = frequency;
    destOpt.timeReturn = timeReturn;
    destOpt.timeDepart = timeDepart;
    destOpt.destinationID = destinationID;
    destOpt.cornerRadius = (minBounds / 60.0);
    destOpt.alpha = 0.0;
    destOpt.backgroundColor = UserDefaults.defaults.defaultColors.backgroundColor;
    destOpt.layer.cornerRadius = destOpt.cornerRadius;
    
    destOpt.frequencyTitles = @[@"Once per month", @"Twice per month", @"3 times per month", @"Once per week", @"Twice per week", @"3 times per week", @"4 times per week", @"5 times per week", @"6 times per week", @"Once per day", @"Twice per day", @"3 times per day"];
    
    if ([destOpt.delegate isKindOfClass:UIViewController.class])
    {
        UIViewController *vc = (UIViewController *)destOpt.delegate;
        destOpt.tabBar = vc.tabBarController.tabBar;
    }
    
    destOpt.overlayView = [[UIView alloc] initWithFrame:bounds];
    destOpt.overlayView.backgroundColor = UIColor.blackColor;
    destOpt.overlayView.alpha = 0.0;
    
    [view addSubview:destOpt.overlayView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.02), (minBounds * 0.02),
                                                                        (minBounds * 0.21), (minBounds * 0.07))];
    
    returnButton.backgroundColor = UIColor.blackColor;
    
    [returnButton setTitle:@"< Return"
                  forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [returnButton setTitleColor:UIColor.grayColor
                       forState:UIControlStateHighlighted];
    
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    returnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    returnButton.layer.cornerRadius = destOpt.cornerRadius;
    
    [returnButton addTarget:destOpt
                     action:@selector(returnButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [destOpt addSubview:returnButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.25), (minBounds * 0.01),
                                                                    (minBounds * 0.5), (minBounds * 0.07))];
    
    [destOpt setupLabel:titleLabel];
    
    titleLabel.text = @"Destinations Options";
    titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [destOpt addSubview:titleLabel];
    
    destOpt.frequencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.16),
                                                                             (minBounds * 0.9), (minBounds * 0.38))];
    
    destOpt.frequencyPicker.delegate = destOpt;
    destOpt.frequencyPicker.dataSource = destOpt;
    destOpt.frequencyPicker.backgroundColor = UIColor.whiteColor;
    destOpt.frequencyPicker.layer.borderColor = UIColor.blackColor.CGColor;
    destOpt.frequencyPicker.layer.borderWidth = 4.0;
    destOpt.frequencyPicker.layer.cornerRadius = destOpt.cornerRadius;
    
    [destOpt.frequencyPicker selectRow:[destOpt pickerIndexForFrequency:destOpt.frequency]
                           inComponent:0
                              animated:NO];
    
    [destOpt addSubview:destOpt.frequencyPicker];
    
    UILabel *fpLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.11),
                                                                 (minBounds * 0.9), (minBounds * 0.05))];
    
    [destOpt setupLabel:fpLabel];
    
    fpLabel.text = @"Select Frequency Option";
    fpLabel.font = [UIFont systemFontOfSize:24.0];
    
    [destOpt addSubview:fpLabel];
    
    destOpt.departTimePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.6),
                                                                              (minBounds * 0.44), (minBounds * 0.38))];
    
    destOpt.departTimePicker.date = [destOpt getDateForTime:destOpt.timeDepart];
    
    [destOpt setupDatePicker:destOpt.departTimePicker];
    [destOpt addSubview:destOpt.departTimePicker];
    
    UILabel *dtpLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.55),
                                                                  (minBounds * 0.44), (minBounds * 0.05))];
    
    [destOpt setupLabel:dtpLabel];
    
    dtpLabel.text = @"Select Depart Time";
    dtpLabel.font = [UIFont systemFontOfSize:24.0];
    
    [destOpt addSubview:dtpLabel];
    
    destOpt.returnTimePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake((minBounds * 0.51), (minBounds * 0.6),
                                                                              (minBounds * 0.44), (minBounds * 0.38))];
    
    destOpt.returnTimePicker.date = [destOpt getDateForTime:destOpt.timeReturn];
    
    [destOpt setupDatePicker:destOpt.returnTimePicker];
    [destOpt addSubview:destOpt.returnTimePicker];
    
    UILabel *rtpLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.51), (minBounds * 0.55),
                                                                  (minBounds * 0.44), (minBounds * 0.05))];
    
    [destOpt setupLabel:rtpLabel];
    
    rtpLabel.text = @"Select Return Time";
    rtpLabel.font = [UIFont systemFontOfSize:24.0];
    
    [destOpt addSubview:rtpLabel];
    
    [view addSubview:destOpt];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         destOpt.overlayView.alpha = 0.7;
                         destOpt.alpha = 1.0;
                         
                         if (destOpt.tabBar)
                         {
                             destOpt.tabBar.alpha = 0.2;
                             destOpt.tabBar.userInteractionEnabled = NO;
                         }
                     }];
    
    return destOpt;
}

- (void)setupLabel:(UILabel *)label
{
    label.backgroundColor = UIColor.clearColor;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.blackColor;
}

- (void)setupDatePicker:(UIDatePicker *)datePicker
{
    datePicker.backgroundColor = UIColor.whiteColor;
    datePicker.layer.borderColor = UIColor.blackColor.CGColor;
    datePicker.layer.borderWidth = 4.0;
    datePicker.layer.cornerRadius = _cornerRadius;
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 5;
}

- (void)hideDestinationOptions:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                             _overlayView.alpha = 0.0;
                             
                             if (_tabBar)
                             {
                                 _tabBar.alpha = 1.0;
                                 _tabBar.userInteractionEnabled = YES;
                             }
                         } completion:^(BOOL finished) {
                             [_overlayView removeFromSuperview];
                             [self removeFromSuperview];
                         }];
    }
    
    else
    {
        [_overlayView removeFromSuperview];
        [self removeFromSuperview];
        
        _tabBar.alpha = 1.0;
        _tabBar.userInteractionEnabled = YES;
    }
}

- (void)returnButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HHmm"];
        
        NSString *timeString = [formatter stringFromDate:_departTimePicker.date];
        _timeDepart = timeString.integerValue;
        
        timeString = [formatter stringFromDate:_returnTimePicker.date];
        _timeReturn = timeString.integerValue;
        
        [_delegate destinationOptions:self
                   didReturnFrequency:_frequency
                           timeDepart:_timeDepart
                           timeReturn:_timeReturn
                        destinationID:_destinationID];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _frequencyTitles.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component
{
    return (pickerView.frame.size.height / 5.0);
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel *pView = (UILabel *)view;
    
    if (!pView)
    {
        pView = [[UILabel alloc] init];
        pView.font = [UIFont systemFontOfSize:36.0];
        pView.textAlignment = NSTextAlignmentCenter;
    }
    
    pView.text = _frequencyTitles[row];
    
    return pView;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    _frequency = [self monthlyFrequencyForPickerOption:_frequencyTitles[row]];
}

- (NSInteger)monthlyFrequencyForPickerOption:(NSString *)pickerOption
{
    NSInteger frequency = 0;
    
    if ([pickerOption isEqualToString:@"Once per month"])
        frequency = 1;
    
    else if ([pickerOption isEqualToString:@"Twice per month"])
        frequency = 2;
    
    else if ([pickerOption isEqualToString:@"3 times per month"])
        frequency = 3;
    
    else if ([pickerOption isEqualToString:@"Once per week"])
        frequency = 4;
    
    else if ([pickerOption isEqualToString:@"Twice per week"])
        frequency = 8;
    
    else if ([pickerOption isEqualToString:@"3 times per week"])
        frequency = 12;
    
    else if ([pickerOption isEqualToString:@"4 times per week"])
        frequency = 16;
    
    else if ([pickerOption isEqualToString:@"5 times per week"])
        frequency = 20;
    
    else if ([pickerOption isEqualToString:@"6 times per week"])
        frequency = 24;
    
    else if ([pickerOption isEqualToString:@"Once per day"])
        frequency = 28;
    
    else if ([pickerOption isEqualToString:@"Twice per day"])
        frequency = 56;
    
    else if ([pickerOption isEqualToString:@"3 times per day"])
        frequency = 84;

    return frequency;
}

- (NSUInteger)pickerIndexForFrequency:(NSInteger)frequency
{
    NSUInteger index = 0;
    
    switch (frequency)
    {
        case 2:
            index = 1;
            break;
            
        case 3:
            index = 2;
            break;
            
        case 4:
            index = 3;
            break;
            
        case 8:
            index = 4;
            break;
            
        case 12:
            index = 5;
            break;
            
        case 16:
            index = 6;
            break;
            
        case 20:
            index = 7;
            break;
            
        case 24:
            index = 8;
            break;
            
        case 28:
            index = 9;
            break;
            
        case 56:
            index = 10;
            break;
            
        case 84:
            index = 11;
            break;
            
        default:
            break;
    }
    
    return index;
}

- (NSDate *)getDateForTime:(NSInteger)time
{
    NSInteger hours = (time / 100);
    NSInteger minutes = (time - (hours * 100));
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *date = [calendar dateBySettingHour:hours
                                        minute:minutes
                                        second:0
                                        ofDate:NSDate.date
                                       options:0];
    
    return date;
}

@end