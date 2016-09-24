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
    [_returnButton constrainTopToAnchor:self.view.topAnchor constant:(_margin / 2.0)];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_returnButton constrainHeightToConstant:40.0];
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
    [nextYear constrainTopToAnchor:self.view.topAnchor constant:(_margin / 2.0)];
    [nextYear constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [nextYear constrainHeightToAnchor:_returnButton.heightAnchor];
    
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
    [nextMonth constrainTopToAnchor:self.view.topAnchor constant:(_margin / 2.0)];
    [nextMonth constrainTrailingToAnchor:nextYear.leadingAnchor];
    [nextMonth constrainHeightToAnchor:_returnButton.heightAnchor];
    [nextMonth constrainWidthToAnchor:nextYear.widthAnchor];
    
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
    [lastMonth constrainTopToAnchor:self.view.topAnchor constant:(_margin / 2.0)];
    [lastMonth constrainTrailingToAnchor:nextMonth.leadingAnchor];
    [lastMonth constrainHeightToAnchor:_returnButton.heightAnchor];
    [lastMonth constrainWidthToAnchor:nextMonth.widthAnchor];
    
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
    
    [lastYear constrainTopToAnchor:self.view.topAnchor constant:(_margin / 2.0)];
    [lastYear constrainLeadingToAnchor:_returnButton.trailingAnchor constant:_margin];
    [lastYear constrainTrailingToAnchor:lastMonth.leadingAnchor];
    [lastYear constrainHeightToAnchor:_returnButton.heightAnchor];
    [lastYear constrainWidthToAnchor:lastMonth.widthAnchor];
    [_returnButton constrainWidthToAnchor:lastYear.widthAnchor multiplier:2.0];
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
    [_calendarView constrainTopToAnchor:_returnButton.bottomAnchor constant:(_margin / 2.0)];
    [_calendarView constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_calendarView constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [_calendarView constrainBottomToAnchor:self.view.bottomAnchor constant:-_margin];
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
