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

+ (void)getCurrentFromDate:(NSInteger *)fromDate
                    toDate:(NSInteger *)toDate
{
    NVDateRange *nvdr = NVDateRange.new;
    nvdr.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    nvdr.calendar.locale = NSLocale.currentLocale;
    nvdr.calendar.timeZone = NSTimeZone.localTimeZone;
    
    NSDateComponents *dateComponents = [nvdr.calendar components:NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitMonth|
                                        NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                        fromDate:NSDate.date];
    
    NSDate *from = nil, *to = nil;
    
    switch ([UserDefaults.defaults integerForKey:@"SelectedDateRange"])
    {
        case DateRangeTypePastWeek:
            dateComponents.day -= 6;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            to = [nvdr endOfDayDateForDate:NSDate.date];
            break;
        case DateRangeTypeToday:
            from = [nvdr startOfDayDateForDate:NSDate.date];
            to = [nvdr endOfDayDateForDate:NSDate.date];
            break;
        case DateRangeTypeYesterday:
            dateComponents.day -= 1;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            to = [nvdr endOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            break;
        case DateRangeTypeThisWeek:
            dateComponents.day -= (dateComponents.weekday - 1);
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            to = [nvdr endOfDayDateForDate:NSDate.date];
            break;
        case DateRangeTypeLastWeek:
            dateComponents.day -= ((dateComponents.weekday - 1) + 7);
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            dateComponents.day += 6;
            to = [nvdr endOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            break;
        case DateRangeTypeThisMonth:
            dateComponents.day = 1;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            to = [nvdr endOfDayDateForDate:NSDate.date];
            break;
        case DateRangeTypeLastMonth:
            dateComponents.day = 0;
            to = [nvdr endOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            dateComponents.month -= 1;
            dateComponents.day = 1;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            break;
        case DateRangeTypeThisYear:
            dateComponents.month = 1;
            dateComponents.day = 1;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            to = [nvdr endOfDayDateForDate:NSDate.date];
            break;
        case DateRangeTypeLastYear:
            dateComponents.month = 1;
            dateComponents.day = 0;
            to = [nvdr endOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            dateComponents.year -= 1;
            dateComponents.day = 1;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            break;
        case DateRangeTypePastYear:
            dateComponents.year -= 1;
            dateComponents.day += 1;
            from = [nvdr startOfDayDateForDate:[nvdr.calendar dateFromComponents:dateComponents]];
            to = [nvdr endOfDayDateForDate:NSDate.date];
            break;
        default:
            break;
    }
    
    *fromDate = from.timeIntervalSince1970;
    *toDate = to.timeIntervalSince1970;
}

+ (NVDateRange *)showDateRangeInView:(UIView *)view
                            delegate:(id)delegate
                            fromDate:(NSInteger)fromDate
                              toDate:(NSInteger)toDate
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat minBounds = (MIN(bounds.size.width, bounds.size.height) * 0.95);
    CGFloat outerMargin = 40.0, innerMargin = 16.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        outerMargin = 16.0, innerMargin = 4.0;
    
    NVDateRange *nvdr = [[NVDateRange alloc] init];
    nvdr.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    nvdr.overlayView = UIView.new;
    nvdr.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    nvdr.overlayView.backgroundColor = UIColor.blackColor;
    nvdr.overlayView.alpha = 0.0;
    
    [view addSubview:nvdr.overlayView];
    [nvdr.overlayView constrainLeadingToAnchor:view.leadingAnchor];
    [nvdr.overlayView constrainTrailingToAnchor:view.trailingAnchor];
    [nvdr.overlayView constrainTopToAnchor:view.topAnchor];
    [nvdr.overlayView constrainBottomToAnchor:view.bottomAnchor constant:nvdr.tabBar.frame.size.height];
    
    [view addSubview:nvdr];
    [nvdr constrainLeadingToAnchor:view.leadingAnchor constant:outerMargin];
    [nvdr constrainTrailingToAnchor:view.trailingAnchor constant:-outerMargin];
    [nvdr constrainTopToAnchor:view.topAnchor constant:outerMargin];
    [nvdr constrainBottomToAnchor:view.bottomAnchor constant:(nvdr.tabBar.frame.size.height - outerMargin)];
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:returnButton
                title:@"< Return"
             selector:@selector(returnButtonTapped:)];
    
    [nvdr addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:nvdr.leadingAnchor constant:innerMargin];
    [returnButton constrainTopToAnchor:nvdr.topAnchor constant:innerMargin];
    
    UILabel *titleLabel = UILabel.new;
    
    [nvdr setupLabel:titleLabel
            fontSize:36.0];
    
    titleLabel.text = @"Date Range";
    
    [nvdr addSubview:titleLabel];
    [titleLabel constrainLeadingToAnchor:returnButton.trailingAnchor constant:innerMargin];
    [titleLabel constrainTopToAnchor:returnButton.topAnchor];
    [titleLabel constrainBottomToAnchor:returnButton.bottomAnchor];
    [titleLabel constrainCenterXToAnchor:view.centerXAnchor];
    
    UILabel *fdpLabel = UILabel.new;
    
    [nvdr setupLabel:fdpLabel
            fontSize:24.0];
    
    fdpLabel.text = @"Select From Date";
    
    [nvdr addSubview:fdpLabel];
    [fdpLabel constrainLeadingToAnchor:returnButton.leadingAnchor];
    [fdpLabel constrainTopToAnchor:returnButton.bottomAnchor constant:innerMargin];
    [fdpLabel constrainTrailingToAnchor:nvdr.centerXAnchor constant:(-innerMargin / 2.0)];
    
    UILabel *tdpLabel = UILabel.new;
    
    [nvdr setupLabel:tdpLabel
            fontSize:24.0];
    
    tdpLabel.text = @"Select To Date";
    
    [nvdr addSubview:tdpLabel];
    [tdpLabel constrainLeadingToAnchor:nvdr.centerXAnchor constant:(innerMargin / 2.0)];
    [tdpLabel constrainTopToAnchor:returnButton.bottomAnchor constant:innerMargin];
    [tdpLabel constrainTrailingToAnchor:nvdr.trailingAnchor constant:-innerMargin];
    
    nvdr.fromDatePicker = UIDatePicker.new;
    
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
    [nvdr.fromDatePicker constrainTopToAnchor:fdpLabel.bottomAnchor];
    [nvdr.fromDatePicker constrainCenterXToAnchor:fdpLabel.centerXAnchor];
    
    nvdr.toDatePicker = UIDatePicker.new;
    
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
    [nvdr.toDatePicker constrainTopToAnchor:tdpLabel.bottomAnchor];
    [nvdr.toDatePicker constrainCenterXToAnchor:tdpLabel.centerXAnchor];
    
    nvdr.fromDateLabel = UILabel.new;
    
    [nvdr setupLabel:nvdr.fromDateLabel
            fontSize:24.0];
    
    nvdr.fromDateLabel.text = [nvdr formattedDate:nvdr.fromDatePicker.date];
    
    [nvdr addSubview:nvdr.fromDateLabel];
    [nvdr.fromDateLabel constrainLeadingToAnchor:fdpLabel.leadingAnchor];
    [nvdr.fromDateLabel constrainTrailingToAnchor:fdpLabel.trailingAnchor];
    [nvdr.fromDateLabel constrainTopToAnchor:nvdr.fromDatePicker.bottomAnchor];
    
    nvdr.toDateLabel = UILabel.new;
    
    [nvdr setupLabel:nvdr.toDateLabel
            fontSize:24.0];
    
    nvdr.toDateLabel.text = [nvdr formattedDate:nvdr.toDatePicker.date];
    
    [nvdr addSubview:nvdr.toDateLabel];
    [nvdr.toDateLabel constrainLeadingToAnchor:tdpLabel.leadingAnchor];
    [nvdr.toDateLabel constrainTrailingToAnchor:tdpLabel.trailingAnchor];
    [nvdr.toDateLabel constrainTopToAnchor:nvdr.toDatePicker.bottomAnchor];
    
    UIButton *today = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:today
                title:@"Today"
             selector:@selector(bottomButtonTapped:)];
    
    today.tag = DateRangeTypeToday;
    
    [nvdr addSubview:today];
    [today constrainLeadingToAnchor:nvdr.fromDateLabel.leadingAnchor];
    [today constrainTrailingToAnchor:nvdr.fromDateLabel.trailingAnchor];
    [today constrainTopToAnchor:nvdr.fromDateLabel.bottomAnchor constant:innerMargin];
    
    UIButton *yesterday = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:yesterday
                title:@"Yesterday"
             selector:@selector(bottomButtonTapped:)];
    
    yesterday.tag = DateRangeTypeYesterday;
    
    [nvdr addSubview:yesterday];
    [yesterday constrainLeadingToAnchor:nvdr.toDateLabel.leadingAnchor];
    [yesterday constrainTrailingToAnchor:nvdr.toDateLabel.trailingAnchor];
    [yesterday constrainTopToAnchor:nvdr.toDateLabel.bottomAnchor constant:innerMargin];
    
    UIButton *thisWeek = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:thisWeek
                title:@"This Week"
             selector:@selector(bottomButtonTapped:)];
    
    thisWeek.tag = DateRangeTypeThisWeek;
    
    [nvdr addSubview:thisWeek];
    [thisWeek constrainLeadingToAnchor:today.leadingAnchor];
    [thisWeek constrainTrailingToAnchor:today.trailingAnchor];
    [thisWeek constrainTopToAnchor:today.bottomAnchor constant:innerMargin];
    
    UIButton *lastWeek = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:lastWeek
                title:@"Last Week"
             selector:@selector(bottomButtonTapped:)];
    
    lastWeek.tag = DateRangeTypeLastWeek;
    
    [nvdr addSubview:lastWeek];
    [lastWeek constrainLeadingToAnchor:yesterday.leadingAnchor];
    [lastWeek constrainTrailingToAnchor:yesterday.trailingAnchor];
    [lastWeek constrainTopToAnchor:yesterday.bottomAnchor constant:innerMargin];
    
    UIButton *pastWeek = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:pastWeek
                title:@"Past Week"
             selector:@selector(bottomButtonTapped:)];
    
    pastWeek.tag = DateRangeTypePastWeek;
    
    [nvdr addSubview:pastWeek];
    [pastWeek constrainLeadingToAnchor:thisWeek.leadingAnchor];
    [pastWeek constrainTrailingToAnchor:thisWeek.trailingAnchor];
    [pastWeek constrainTopToAnchor:thisWeek.bottomAnchor constant:innerMargin];
    
    UIButton *thisMonth = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:thisMonth
                title:@"This Month"
             selector:@selector(bottomButtonTapped:)];
    
    thisMonth.tag = DateRangeTypeThisMonth;
    
    [nvdr addSubview:thisMonth];
    [thisMonth constrainLeadingToAnchor:lastWeek.leadingAnchor];
    [thisMonth constrainTrailingToAnchor:lastWeek.trailingAnchor];
    [thisMonth constrainTopToAnchor:lastWeek.bottomAnchor constant:innerMargin];
    
    UIButton *lastMonth = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:lastMonth
                title:@"Last Month"
             selector:@selector(bottomButtonTapped:)];
    
    lastMonth.tag = DateRangeTypeLastMonth;
    
    [nvdr addSubview:lastMonth];
    [lastMonth constrainLeadingToAnchor:pastWeek.leadingAnchor];
    [lastMonth constrainTrailingToAnchor:pastWeek.trailingAnchor];
    [lastMonth constrainTopToAnchor:pastWeek.bottomAnchor constant:innerMargin];
    
    UIButton *thisYear = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:thisYear
                title:@"This Year"
             selector:@selector(bottomButtonTapped:)];
    
    thisYear.tag = DateRangeTypeThisYear;
    
    [nvdr addSubview:thisYear];
    [thisYear constrainLeadingToAnchor:thisMonth.leadingAnchor];
    [thisYear constrainTrailingToAnchor:thisMonth.trailingAnchor];
    [thisYear constrainTopToAnchor:thisMonth.bottomAnchor constant:innerMargin];
    
    UIButton *lastYear = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:lastYear
                title:@"Last Year"
             selector:@selector(bottomButtonTapped:)];
    
    lastYear.tag = DateRangeTypeLastYear;
    
    [nvdr addSubview:lastYear];
    
    [lastYear constrainLeadingToAnchor:lastMonth.leadingAnchor];
    [lastYear constrainTrailingToAnchor:lastMonth.trailingAnchor];
    [lastYear constrainTopToAnchor:lastMonth.bottomAnchor constant:innerMargin];
    [lastYear constrainBottomToAnchor:nvdr.bottomAnchor constant:-innerMargin];
    
    UIButton *pastYear = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [nvdr setupButton:pastYear
                title:@"Past Year"
             selector:@selector(bottomButtonTapped:)];
    
    pastYear.tag = DateRangeTypePastYear;
    
    [nvdr addSubview:pastYear];
    [pastYear constrainLeadingToAnchor:thisYear.leadingAnchor];
    [pastYear constrainTrailingToAnchor:thisYear.trailingAnchor];
    [pastYear constrainTopToAnchor:thisYear.bottomAnchor constant:innerMargin];
    [pastYear constrainBottomToAnchor:nvdr.bottomAnchor constant:-innerMargin];
    
    [lastYear constrainHeightToAnchor:lastMonth.heightAnchor];
    [lastMonth constrainHeightToAnchor:pastWeek.heightAnchor];
    [pastWeek constrainHeightToAnchor:thisWeek.heightAnchor];
    [thisWeek constrainHeightToAnchor:today.heightAnchor];
    
    [pastYear constrainHeightToAnchor:thisYear.heightAnchor];
    [thisYear constrainHeightToAnchor:thisMonth.heightAnchor];
    [thisMonth constrainHeightToAnchor:lastWeek.heightAnchor];
    [lastWeek constrainHeightToAnchor:yesterday.heightAnchor];
    
    [nvdr.fromDatePicker constrainHeightToAnchor:today.heightAnchor multiplier:3.0];
    [nvdr.toDatePicker constrainHeightToAnchor:yesterday.heightAnchor multiplier:3.0];
    [returnButton constrainHeightToAnchor:today.heightAnchor];
    [fdpLabel constrainHeightToAnchor:returnButton.heightAnchor multiplier:0.4];
    [tdpLabel constrainHeightToAnchor:fdpLabel.heightAnchor];
    [nvdr.fromDateLabel constrainHeightToAnchor:fdpLabel.heightAnchor];
    [nvdr.toDateLabel constrainHeightToAnchor:tdpLabel.heightAnchor];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [nvdr.fromDatePicker constrainWidthToAnchor:today.widthAnchor multiplier:2.0];
        [nvdr.toDatePicker constrainWidthToAnchor:yesterday.widthAnchor multiplier:2.0];
    }
    
    else
    {
        [nvdr.fromDatePicker constrainWidthToAnchor:today.widthAnchor];
        [nvdr.toDatePicker constrainWidthToAnchor:yesterday.widthAnchor];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvdr.overlayView.alpha = 0.7;
                         nvdr.alpha = 1.0;
                         
                         if (nvdr.tabBar)
                         {
                             nvdr.tabBar.alpha = 0.0;
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
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    else
        button.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.layer.cornerRadius = _cornerRadius;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupLabel:(UILabel *)label
          fontSize:(CGFloat)fontSize
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        fontSize /= 1.8;
    
    label.backgroundColor = UIColor.clearColor;
    label.font = [UIFont boldSystemFontOfSize:fontSize];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.blackColor;
    label.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupDatePicker:(UIDatePicker *)datePicker
{
    datePicker.backgroundColor = UIColor.whiteColor;
    datePicker.layer.borderColor = UIColor.blackColor.CGColor;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        datePicker.layer.borderWidth = 2.0;
        datePicker.transform = CGAffineTransformMakeScale(0.5, 1.0);
    }
    
    else
        datePicker.layer.borderWidth = 4.0;
    
    datePicker.layer.cornerRadius = _cornerRadius;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    switch ((DateRangeType)button.tag)
    {
        case DateRangeTypePastWeek:
            dateComponents.day -= 6;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalWeek;
            break;
        case DateRangeTypeToday:
            fromDate = [self startOfDayDateForDate:NSDate.date];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalDay;
            break;
        case DateRangeTypeYesterday:
            dateComponents.day -= 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalDay;
            break;
        case DateRangeTypeThisWeek:
            dateComponents.day -= (dateComponents.weekday - 1);
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalWeek;
            break;
        case DateRangeTypeLastWeek:
            dateComponents.day -= ((dateComponents.weekday - 1) + 7);
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            dateComponents.day += 6;
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalWeek;
            break;
        case DateRangeTypeThisMonth:
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalMonth;
            break;
        case DateRangeTypeLastMonth:
            dateComponents.day = 0;
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            dateComponents.month -= 1;
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalMonth;
            break;
        case DateRangeTypeThisYear:
            dateComponents.month = 1;
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalYear;
            break;
        case DateRangeTypeLastYear:
            dateComponents.month = 1;
            dateComponents.day = 0;
            toDate = [self endOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            dateComponents.year -= 1;
            dateComponents.day = 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            _interval = DateRangeInvervalYear;
            break;
        case DateRangeTypePastYear:
            dateComponents.year -= 1;
            dateComponents.day += 1;
            fromDate = [self startOfDayDateForDate:[_calendar dateFromComponents:dateComponents]];
            toDate = [self endOfDayDateForDate:NSDate.date];
            _interval = DateRangeInvervalYear;
            break;
        default:
            break;
    }
    
    [_fromDatePicker setDate:fromDate animated:YES];
    _fromDateLabel.text = [self formattedDate:fromDate];
    [_toDatePicker setDate:[self endOfDayDateForDate:toDate] animated:YES];
    _toDateLabel.text = [self formattedDate:toDate];
    [UserDefaults.defaults saveNSInteger:button.tag forKey:@"SelectedDateRange"];
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
