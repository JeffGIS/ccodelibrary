//  NVDateRange.m
//  CCodeLibrary

#import "NVDateRange.h"
#import "UserDefaults.h"
#import "NVDestinationOptions.h"

@interface NVDateRange ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIDatePicker *fromDatePicker, *toDatePicker;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSInteger fromDate, toDate;
@property (nonatomic) UILabel *fromDateLabel, *toDateLabel;
@property (nonatomic) DateRangeInverval interval;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSInteger maxDate;

@end

@implementation NVDateRange

+ (void)getPastWeekFromDate:(NSInteger *)fromDate
                     toDate:(NSInteger *)toDate
{
    NVDateRange *nvdr = [[NVDateRange alloc] init];
    
    nvdr.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    nvdr.calendar.locale = NSLocale.currentLocale;
    nvdr.calendar.timeZone = NSTimeZone.localTimeZone;
    
    NSDateComponents *dateComponents = [nvdr.calendar components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitMonth|
                                        NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                   fromDate:NSDate.date];
    
    dateComponents.day -= 6;
    
    NSDate *fd = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
    NSDate *td = [nvdr endOfDayDateForDate:NSDate.date];
    
    *fromDate = fd.timeIntervalSince1970;
    *toDate = td.timeIntervalSince1970;
    
}

+ (NVDateRange *)showDateRangeInView:(UIView *)view
                            delegate:(id)delegate
                            fromDate:(NSInteger)fromDate
                              toDate:(NSInteger)toDate
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat minBounds = (MIN(bounds.size.width, bounds.size.height) * 0.9);
    
    NVDateRange *nvdr = [[NVDateRange alloc] initWithFrame:CGRectMake(0.0, 0.0, minBounds, minBounds)];
    
    nvdr.center = CGPointMake((bounds.size.width / 2.0),
                              (bounds.size.height / 2.0));
    
    nvdr.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    nvdr.calendar.locale = NSLocale.currentLocale;
    nvdr.calendar.timeZone = NSTimeZone.localTimeZone;
    
    nvdr.delegate = delegate;
    nvdr.cornerRadius = (minBounds / 60.0);
    nvdr.fromDate = fromDate;
    nvdr.toDate = toDate;
    nvdr.interval = DateRangeInvervalNone;
    nvdr.minDate = 631173600;
    nvdr.maxDate = [nvdr endOfDayDateForDate:NSDate.date].timeIntervalSince1970;
    
    nvdr.alpha = 0.0;
    nvdr.backgroundColor = UserDefaults.defaults.defaultColors.backgroundColor;
    nvdr.layer.cornerRadius = nvdr.cornerRadius;
    
    if ([nvdr.delegate isKindOfClass:UIViewController.class])
    {
        UIViewController *vc = (UIViewController *)nvdr.delegate;
        nvdr.tabBar = vc.tabBarController.tabBar;
    }
    
    nvdr.overlayView = [[UIView alloc] initWithFrame:bounds];
    nvdr.overlayView.backgroundColor = UIColor.blackColor;
    nvdr.overlayView.alpha = 0.0;
    
    [view addSubview:nvdr.overlayView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.02), (minBounds * 0.02),
                                                                        (minBounds * 0.21), (minBounds * 0.1))];
    
    [nvdr setupButton:returnButton
                title:@"< Return"
             selector:@selector(returnButtonTapped:)];
    
    [nvdr addSubview:returnButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.25), (minBounds * 0.01),
                                                                    (minBounds * 0.5), (minBounds * 0.14))];
    
    [nvdr setupLabel:titleLabel];
    
    titleLabel.text = @"Date Range\nController";
    titleLabel.font = [UIFont boldSystemFontOfSize:44.0];
    titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:titleLabel];
    
    nvdr.fromDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.22),
                                                                              (minBounds * 0.44), (minBounds * 0.4))];
    
    if (nvdr.toDate && nvdr.fromDate)
    {
        nvdr.fromDatePicker.date = [nvdr startOfDayDateForDate:
                                    [NSDate dateWithTimeIntervalSince1970:nvdr.fromDate]];
    }
    
    else
    {
        NSDateComponents *dateComponents = [nvdr.calendar components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitMonth|
                                            NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                            fromDate:NSDate.date];
        
        dateComponents.day -= 6;
        nvdr.fromDatePicker.date = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
    }
    
    [nvdr setupDatePicker:nvdr.fromDatePicker];
    
    [nvdr.fromDatePicker addTarget:nvdr
                            action:@selector(datePickerValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    
    [nvdr addSubview:nvdr.fromDatePicker];
    
    UILabel *fdpLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.17),
                                                                  (minBounds * 0.44), (minBounds * 0.05))];
    
    [nvdr setupLabel:fdpLabel];
    
    fdpLabel.text = @"Select From Date";
    fdpLabel.font = [UIFont systemFontOfSize:24.0];
    
    [nvdr addSubview:fdpLabel];
    
    nvdr.fromDateLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.05), (minBounds * 0.62),
                                                                   (minBounds * 0.44), (minBounds * 0.05))];
    
    [nvdr setupLabel:nvdr.fromDateLabel];
    
    nvdr.fromDateLabel.text = [nvdr formattedDate:nvdr.fromDatePicker.date];
    nvdr.fromDateLabel.font = [UIFont systemFontOfSize:24.0];
    
    [nvdr addSubview:nvdr.fromDateLabel];
    
    nvdr.toDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake((minBounds * 0.51), (minBounds * 0.22),
                                                                         (minBounds * 0.44), (minBounds * 0.4))];
    
    if (nvdr.toDate && nvdr.fromDate)
    {
        nvdr.toDatePicker.date = [nvdr endOfDayDateForDate:
                                  [NSDate dateWithTimeIntervalSince1970:nvdr.toDate]];
    }
    
    else
        nvdr.toDatePicker.date = [nvdr endOfDayDateForDate:NSDate.date];
    
    [nvdr setupDatePicker:nvdr.toDatePicker];
    
    [nvdr.toDatePicker addTarget:nvdr
                          action:@selector(datePickerValueChanged:)
                forControlEvents:UIControlEventValueChanged];
    
    [nvdr addSubview:nvdr.toDatePicker];
    
    UILabel *tdpLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.51), (minBounds * 0.17),
                                                                  (minBounds * 0.44), (minBounds * 0.05))];
    
    [nvdr setupLabel:tdpLabel];
    
    tdpLabel.text = @"Select To Date";
    tdpLabel.font = [UIFont systemFontOfSize:24.0];
    
    [nvdr addSubview:tdpLabel];
    
    nvdr.toDateLabel = [[UILabel alloc] initWithFrame:CGRectMake((minBounds * 0.51), (minBounds * 0.62),
                                                                   (minBounds * 0.44), (minBounds * 0.05))];
    
    [nvdr setupLabel:nvdr.toDateLabel];
    
    nvdr.toDateLabel.text = [nvdr formattedDate:nvdr.toDatePicker.date];
    nvdr.toDateLabel.font = [UIFont systemFontOfSize:24.0];
    
    [nvdr addSubview:nvdr.toDateLabel];
    
    UIButton *today = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.02), (minBounds * 0.7),
                                                                 (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:today
                title:@"Today"
             selector:@selector(bottomButtonTapped:)];
    
    today.tag = 1;
    
    [nvdr addSubview:today];
    
    UIButton *yesterday = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.216), (minBounds * 0.7),
                                                                     (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:yesterday
                title:@"Yesterday"
             selector:@selector(bottomButtonTapped:)];
    
    yesterday.tag = 2;
    
    [nvdr addSubview:yesterday];
    
    UIButton *thisWeek = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.412), (minBounds * 0.7),
                                                                    (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:thisWeek
                title:@"This\nWeek"
             selector:@selector(bottomButtonTapped:)];
    
    thisWeek.tag = 3;
    thisWeek.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:thisWeek];
    
    UIButton *lastWeek = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.608), (minBounds * 0.7),
                                                                    (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:lastWeek
                title:@"Last\nWeek"
             selector:@selector(bottomButtonTapped:)];
    
    lastWeek.tag = 4;
    lastWeek.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:lastWeek];
    
    UIButton *pastWeek = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.804), (minBounds * 0.7),
                                                                    (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:pastWeek
                title:@"Past\nWeek"
             selector:@selector(bottomButtonTapped:)];
    
    pastWeek.tag = 5;
    pastWeek.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:pastWeek];
    
    UIButton *thisMonth = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.02), (minBounds * 0.85),
                                                                     (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:thisMonth
                title:@"This Month"
             selector:@selector(bottomButtonTapped:)];
    
    thisMonth.tag = 6;
    thisMonth.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:thisMonth];
    
    UIButton *lastMonth = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.216), (minBounds * 0.85),
                                                                     (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:lastMonth
                title:@"Last Month"
             selector:@selector(bottomButtonTapped:)];
    
    lastMonth.tag = 7;
    lastMonth.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:lastMonth];
    
    UIButton *thisYear = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.412), (minBounds * 0.85),
                                                                    (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:thisYear
                title:@"This\nYear"
             selector:@selector(bottomButtonTapped:)];
    
    thisYear.tag = 8;
    thisYear.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:thisYear];
    
    UIButton *lastYear = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.608), (minBounds * 0.85),
                                                                    (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:lastYear
                title:@"Last\nYear"
             selector:@selector(bottomButtonTapped:)];
    
    lastYear.tag = 9;
    lastYear.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:lastYear];
    
    UIButton *pastYear = [[UIButton alloc] initWithFrame:CGRectMake((minBounds * 0.804), (minBounds * 0.85),
                                                                    (minBounds * 0.176), (minBounds * 0.12))];
    
    [nvdr setupButton:pastYear
                title:@"Past\nYear"
             selector:@selector(bottomButtonTapped:)];
    
    pastYear.tag = 10;
    pastYear.titleLabel.numberOfLines = 2;
    
    [nvdr addSubview:pastYear];
    
    [view addSubview:nvdr];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvdr.overlayView.alpha = 0.7;
                         nvdr.alpha = 1.0;
                         
                         if (nvdr.tabBar)
                         {
                             nvdr.tabBar.alpha = 0.2;
                             nvdr.tabBar.userInteractionEnabled = NO;
                         }
                     }];
    
    return nvdr;
}

- (void)setupButton:(UIButton *)button
              title:(NSString *)title
           selector:(SEL)selector
{
    button.backgroundColor = UIColor.blackColor;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.grayColor
                 forState:UIControlStateHighlighted];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.layer.cornerRadius = _cornerRadius;
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
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
    datePicker.datePickerMode = UIDatePickerModeDate;
}

- (void)hideDateRange:(BOOL)animated
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
        [_delegate dateRange:self
           didReturnFromDate:_fromDatePicker.date.timeIntervalSince1970
                      toDate:_toDatePicker.date.timeIntervalSince1970];
    }
}

- (void)bottomButtonTapped:(UIButton *)button
{
    NSDate *fromDate = nil;
    NSDate *toDate = nil;
    
    NSDateComponents *dateComponents = [_calendar components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitMonth|
                                        NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                    fromDate:NSDate.date];
    
    switch ((DateRangeButton)button.tag)
    {
        case DateRangeButtonToday:
            fromDate = [self startOfDayDateForDate:NSDate.date];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalDay;
            break;
            
        case DateRangeButtonYesterday:
            dateComponents.day -= 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalDay;
            break;
            
        case DateRangeButtonThisWeek:
            dateComponents.day -= (dateComponents.weekday - 1);
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalWeek;
            break;
            
        case DateRangeButtonLastWeek:
            dateComponents.day -= ((dateComponents.weekday - 1) + 7);
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            
            dateComponents.day += 6;
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalWeek;
            break;
            
        case DateRangeButtonPastWeek:
            dateComponents.day -= 6;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalWeek;
            break;
            
        case DateRangeButtonThisMonth:
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalMonth;
            break;
            
        case DateRangeButtonLastMonth:
            dateComponents.day = 0;
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            
            dateComponents.month -= 1;
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalMonth;
            break;
            
        case DateRangeButtonThisYear:
            dateComponents.month = 1;
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalYear;
            break;
            
        case DateRangeButtonLastYear:
            dateComponents.month = 1;
            dateComponents.day = 0;
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            
            dateComponents.year -= 1;
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalYear;
            break;
            
        case DateRangeButtonPastYear:
            dateComponents.year -= 1;
            dateComponents.day += 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalYear;
            break;
            
        case DateRangeButtonNone:
        default:
            break;
    }
    
    [_fromDatePicker setDate:fromDate
                    animated:YES];
    
    _fromDateLabel.text = [self formattedDate:fromDate];
    
    [_toDatePicker setDate:[self endOfDayDateForDate:toDate]
                  animated:YES];
    
    _toDateLabel.text = [self formattedDate:toDate];
    
    
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    if (datePicker == _fromDatePicker)
    {
        if (_fromDatePicker.date.timeIntervalSince1970 < _minDate)
        {
            [_fromDatePicker setDate:[NSDate dateWithTimeIntervalSince1970:_minDate]
                            animated:YES];
        }
        
        else if (_fromDatePicker.date.timeIntervalSince1970 > _maxDate)
        {
            [_fromDatePicker setDate:[self startOfDayDateForDate:[NSDate dateWithTimeIntervalSince1970:_maxDate]]
                            animated:YES];
        }
        
        if (_interval != DateRangeInvervalNone)
        {
            NSDateComponents *dateComponents = [_calendar components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitMonth|
                                                NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                            fromDate:_fromDatePicker.date];
            
            switch (_interval)
            {
                case DateRangeInvervalDay:
                    break;
                    
                case DateRangeInvervalWeek:
                    dateComponents.day += 6;
                    break;
                    
                case DateRangeInvervalMonth:
                    dateComponents.month += 1;
                    dateComponents.day -= 1;
                    break;
                    
                case DateRangeInvervalYear:
                    dateComponents.year += 1;
                    dateComponents.day -= 1;
                    break;
                    
                default:
                    break;
            }
            
            NSDate *newDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            
            if (newDate.timeIntervalSince1970 > _maxDate)
                newDate = [NSDate dateWithTimeIntervalSince1970:_maxDate];
            
            dateComponents = [_calendar components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitMonth|
                              NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                          fromDate:newDate];
            
            switch (_interval)
            {
                case DateRangeInvervalDay:
                    break;
                    
                case DateRangeInvervalWeek:
                    dateComponents.day -= 6;
                    break;
                    
                case DateRangeInvervalMonth:
                    dateComponents.month -= 1;
                    dateComponents.day += 1;
                    break;
                    
                case DateRangeInvervalYear:
                    dateComponents.year -= 1;
                    dateComponents.day += 1;
                    break;
                    
                default:
                    break;
            }
            
            [_toDatePicker setDate:newDate
                          animated:YES];
            
            _toDateLabel.text = [self formattedDate:_toDatePicker.date];
            
            [_fromDatePicker setDate:[self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]]
                            animated:YES];
            
            _fromDateLabel.text = [self formattedDate:_fromDatePicker.date];
        }
        
        if (_fromDatePicker.date.timeIntervalSince1970 > _toDatePicker.date.timeIntervalSince1970)
        {
            [_toDatePicker setDate:[self endOfDayDateForDate:_fromDatePicker.date]
                          animated:YES];
            
            _toDateLabel.text = [self formattedDate:_toDatePicker.date];
        }
        
        _fromDateLabel.text = [self formattedDate:_fromDatePicker.date];
    }
    
    else
    {
        if (_toDatePicker.date.timeIntervalSince1970 > _maxDate)
        {
            [_toDatePicker setDate:[NSDate dateWithTimeIntervalSince1970:_maxDate]
                          animated:YES];
        }
        
        else if (_toDatePicker.date.timeIntervalSince1970 < _minDate)
        {
            [_toDatePicker setDate:[self endOfDayDateForDate:[NSDate dateWithTimeIntervalSince1970:_minDate]]
                          animated:YES];
        }
        
        if (_toDatePicker.date.timeIntervalSince1970 < _fromDatePicker.date.timeIntervalSince1970)
        {
            [_fromDatePicker setDate:[self startOfDayDateForDate:_toDatePicker.date]
                            animated:YES];
            
            _fromDateLabel.text = [self formattedDate:_fromDatePicker.date];
        }
        
        _toDateLabel.text = [self formattedDate:_toDatePicker.date];
        _interval = DateRangeInvervalNone;
    }
}

- (NSString *)formattedDate:(NSDate *)date
{
    NSString *formattedDate = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss yyyy";
    formattedDate = [dateFormatter stringFromDate:date];
    
    return formattedDate;
}

- (NSDate *)startOfDayDateForDate:(NSDate *)date
{
    NSDate *newDate = [_calendar dateBySettingHour:0
                                            minute:0
                                            second:0
                                            ofDate:date
                                           options:NSCalendarMatchStrictly];
    
    return newDate;
    
}


- (NSDate *)endOfDayDateForDate:(NSDate *)date
{
    NSDate *newDate = [_calendar dateBySettingHour:23
                                            minute:59
                                            second:59
                                            ofDate:date
                                           options:NSCalendarMatchStrictly];
    
    return newDate;
}

@end