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
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _font = [UIFont boldSystemFontOfSize:24.0];
        _margin = 12.0;
    }
    
    else
    {
        _font = [UIFont boldSystemFontOfSize:32.0];
        _margin = 20.0;
    }
    
    [self setupReturnButton];
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
}

- (void)setupCalendarView
{
    _calendarView = [[NVCalendarView alloc] initWithTitle:@"February 2016"];
    _calendarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_calendarView];
    
    [_calendarView.topAnchor constraintEqualToAnchor:_returnButton.bottomAnchor
                                            constant:_margin].active = YES;
    
    [_calendarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                constant:_margin].active = YES;
    
    [_calendarView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                constant:-_margin].active = YES;
    
    [_calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                constant:-_margin].active = YES;
}

- (void)dismiss:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end