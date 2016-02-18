//  NVCalendarVC.m
//  CCodeLibrary

#import "NVCalendarVC.h"
#import "UserDefaults.h"
#import "NVCalendarView.h"

@interface NVCalendarVC ()

@property (nonatomic) UIFont *font;
@property (nonatomic) UIButton *returnButton;
@property (nonatomic) NVCalendarView *calendarView;
@property (nonatomic) CGFloat margin;
@property (nonatomic) NSMutableSet *calendarSet;
@property (nonatomic) NSDateComponents *currentCalendar;
@property (nonatomic) NSUInteger numDays;
@property (nonatomic) NSCalendar *calendar;

@end

@implementation NVCalendarVC

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    _calendar = NSCalendar.currentCalendar;
    
    _currentCalendar = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                   fromDate:NSDate.date];
    
    _currentCalendar.day = 1;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _font = [UIFont boldSystemFontOfSize:24.0];
        _margin = 8.0;
    }
    
    else
    {
        _font = [UIFont boldSystemFontOfSize:32.0];
        _margin = 20.0;
    }
    
    [self setupReturnButton];
    [self setupTopButtons];
    [self setupCalendarView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupReturnButton
{
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    _returnButton.titleLabel.font = _font;
    _returnButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    _returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _returnButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [_returnButton setTitle:@"< Return"
                    forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.lightGrayColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(dismiss:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    
    [_returnButton.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                            constant:(_margin / 2.0)].active = YES;
    
    [_returnButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                constant:_margin].active = YES;
    
    [_returnButton.heightAnchor constraintEqualToConstant:40.0].active = YES;
}

- (void)setupTopButtons
{
    UIButton *nextYear = [UIButton buttonWithType:UIButtonTypeCustom];
    nextYear.translatesAutoresizingMaskIntoConstraints = NO;
    nextYear.backgroundColor = UIColor.clearColor;
    nextYear.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [nextYear setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"doubleArrowForward"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [nextYear addTarget:self
                 action:@selector(nextYear:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:nextYear];
    
    [nextYear.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                       constant:(_margin / 2.0)].active = YES;
    
    [nextYear.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                            constant:-_margin].active = YES;
    
    [nextYear.heightAnchor constraintEqualToAnchor:_returnButton.heightAnchor].active = YES;
    
    UIButton *nextMonth = [UIButton buttonWithType:UIButtonTypeCustom];
    nextMonth.translatesAutoresizingMaskIntoConstraints = NO;
    nextMonth.backgroundColor = UIColor.clearColor;
    nextMonth.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [nextMonth setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"singleArrowForward"
                                                                                       ofType:@"png"]]
               forState:UIControlStateNormal];
    
    [nextMonth addTarget:self
                  action:@selector(nextMonth:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:nextMonth];
    
    [nextMonth.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                        constant:(_margin / 2.0)].active = YES;
    
    [nextMonth.trailingAnchor constraintEqualToAnchor:nextYear.leadingAnchor].active = YES;
    [nextMonth.heightAnchor constraintEqualToAnchor:_returnButton.heightAnchor].active = YES;
    [nextMonth.widthAnchor constraintEqualToAnchor:nextYear.widthAnchor].active = YES;
    
    UIButton *lastMonth = [UIButton buttonWithType:UIButtonTypeCustom];
    lastMonth.translatesAutoresizingMaskIntoConstraints = NO;
    lastMonth.backgroundColor = UIColor.clearColor;
    lastMonth.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [lastMonth setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"singleArrowReverse"
                                                                                       ofType:@"png"]]
               forState:UIControlStateNormal];
    
    [lastMonth addTarget:self
                  action:@selector(lastMonth:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lastMonth];
    
    [lastMonth.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                        constant:(_margin / 2.0)].active = YES;
    
    [lastMonth.trailingAnchor constraintEqualToAnchor:nextMonth.leadingAnchor].active = YES;
    [lastMonth.heightAnchor constraintEqualToAnchor:_returnButton.heightAnchor].active = YES;
    [lastMonth.widthAnchor constraintEqualToAnchor:nextMonth.widthAnchor].active = YES;
    
    UIButton *lastYear = [UIButton buttonWithType:UIButtonTypeCustom];
    lastYear.translatesAutoresizingMaskIntoConstraints = NO;
    lastYear.backgroundColor = UIColor.clearColor;
    lastYear.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [lastYear setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"doubleArrowReverse"
                                                                                      ofType:@"png"]]
              forState:UIControlStateNormal];
    
    [lastYear addTarget:self
                 action:@selector(lastYear:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lastYear];
    
    [lastYear.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                       constant:(_margin / 2.0)].active = YES;
    
    [lastYear.leadingAnchor constraintEqualToAnchor:_returnButton.trailingAnchor
                                           constant:_margin].active = YES;
    
    [lastYear.trailingAnchor constraintEqualToAnchor:lastMonth.leadingAnchor].active = YES;
    [lastYear.heightAnchor constraintEqualToAnchor:_returnButton.heightAnchor].active = YES;
    [lastYear.widthAnchor constraintEqualToAnchor:lastMonth.widthAnchor].active = YES;
    
    [_returnButton.widthAnchor constraintEqualToAnchor:lastYear.widthAnchor
                                            multiplier:2.0].active = YES;
}

- (void)nextYear:(UIButton *)button
{
    _currentCalendar.year += 1;
    [self setupCalendarView];
}

- (void)lastYear:(UIButton *)button
{
    _currentCalendar.year -= 1;
    [self setupCalendarView];
}

- (void)nextMonth:(UIButton *)button
{
    _currentCalendar.month += 1;
    [self setupCalendarView];
}

- (void)lastMonth:(UIButton *)button
{
    _currentCalendar.month -= 1;
    [self setupCalendarView];
}

- (void)setupCalendarView
{
    [self computeCalendarExtents];
    
    if ([self.view.subviews containsObject:_calendarView])
        [_calendarView removeFromSuperview];
    
    _calendarView = [[NVCalendarView alloc] initWithMonth:_currentCalendar.month
                                                     year:_currentCalendar.year
                                                 firstDay:_currentCalendar.weekday
                                                  numDays:_numDays];
    
    _calendarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_calendarView];
    
    [_calendarView.topAnchor constraintEqualToAnchor:_returnButton.bottomAnchor
                                            constant:(_margin / 2.0)].active = YES;
    
    [_calendarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                constant:_margin].active = YES;
    
    [_calendarView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                constant:-_margin].active = YES;
    
    [_calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                constant:-_margin].active = YES;
}

- (void)computeCalendarExtents
{
    NSDate *firstDay = [_calendar dateFromComponents:_currentCalendar];
    
    _currentCalendar = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                    fromDate:firstDay];
    
    NSDateComponents *nextMonth = _currentCalendar.copy;
    nextMonth.month += 1;
    nextMonth.day = 0;
    NSDate *lastDay = [_calendar dateFromComponents:nextMonth];
    
    nextMonth = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                             fromDate:lastDay];
    
    _numDays = nextMonth.day;
}

- (void)dismiss:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end