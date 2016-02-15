//  NVCalendarView.m
//  CCodeLibrary

#import "NVCalendarView.h"
#import "NVCalendarCell.h"

@interface NVCalendarView ()

@property (nonatomic) NSString *title;
@property (nonatomic) UIFont *font;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) NVCalendarCell *sun, *mon, *tues, *wed, *thurs, *fri, *sat;

@end

@implementation NVCalendarView

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 10.0;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 4.0;
        self.title = title;
        
        [self setupTitleLabel];
        [self setupDayHeaders];
    }
    
    return self;
}

- (void)setupTitleLabel
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = _title;
    _titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    _titleLabel.textColor = UIColor.blackColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_titleLabel];
    
    [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

- (void)setupDayHeaders
{
    _sun = [[NVCalendarCell alloc] initWithText:@"Sun"];
    _mon = [[NVCalendarCell alloc] initWithText:@"Mon"];
    _tues = [[NVCalendarCell alloc] initWithText:@"Tue"];
    _wed = [[NVCalendarCell alloc] initWithText:@"Wed"];
    _thurs = [[NVCalendarCell alloc] initWithText:@"Thu"];
    _fri = [[NVCalendarCell alloc] initWithText:@"Fri"];
    _sat = [[NVCalendarCell alloc] initWithText:@"Sat"];
    
    [self addCellToView:_sun];
    [self addCellToView:_mon];
    [self addCellToView:_tues];
    [self addCellToView:_wed];
    [self addCellToView:_thurs];
    [self addCellToView:_fri];
    [self addCellToView:_sat];
    
    [_sun.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_sun.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_sun.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    
    [_mon.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_mon.leadingAnchor constraintEqualToAnchor:_sun.trailingAnchor].active = YES;
    [_mon.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    [_mon.widthAnchor constraintEqualToAnchor:_sun.widthAnchor].active = YES;
    
    [_tues.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_tues.leadingAnchor constraintEqualToAnchor:_mon.trailingAnchor].active = YES;
    [_tues.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    [_tues.widthAnchor constraintEqualToAnchor:_mon.widthAnchor].active = YES;
    
    [_wed.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_wed.leadingAnchor constraintEqualToAnchor:_tues.trailingAnchor].active = YES;
    [_wed.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    [_wed.widthAnchor constraintEqualToAnchor:_tues.widthAnchor].active = YES;
    
    [_thurs.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_thurs.leadingAnchor constraintEqualToAnchor:_wed.trailingAnchor].active = YES;
    [_thurs.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    [_thurs.widthAnchor constraintEqualToAnchor:_wed.widthAnchor].active = YES;
    
    [_fri.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_fri.leadingAnchor constraintEqualToAnchor:_thurs.trailingAnchor].active = YES;
    [_fri.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    [_fri.widthAnchor constraintEqualToAnchor:_thurs.widthAnchor].active = YES;
    
    [_sat.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_sat.leadingAnchor constraintEqualToAnchor:_fri.trailingAnchor].active = YES;
    [_sat.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor].active = YES;
    [_sat.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_sat.widthAnchor constraintEqualToAnchor:_fri.widthAnchor].active = YES;
}

- (void)addCellToView:(NVCalendarCell *)cell
{
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:cell];
}

@end