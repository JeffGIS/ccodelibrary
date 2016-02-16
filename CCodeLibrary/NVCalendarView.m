//  NVCalendarView.m
//  CCodeLibrary

#import "NVCalendarView.h"
#import "NVCalendarCell.h"

@interface NVCalendarView ()

@property (nonatomic) NSString *title;
@property (nonatomic) UIFont *font;
@property (nonatomic) NVCalendarCell *titleLabel, *sun, *mon, *tues, *wed, *thurs, *fri, *sat;
@property NSInteger index, startDay, numDays;

@end

@implementation NVCalendarView

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = UIColor.blackColor;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.masksToBounds = YES;
        _title = title;
        _index = 1;
        _startDay = 9;
        _numDays = 29;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.layer.borderWidth = 2.0;
            self.layer.cornerRadius = 4.0;
        }
        
        
        else
        {
            self.layer.borderWidth = 4.0;
            self.layer.cornerRadius = 10.0;
        }
        
        [self setupTitleLabel];
        [self setupDayHeaders];
        [self setupCells];
    }
    
    return self;
}

- (void)setupTitleLabel
{
    _titleLabel = [[NVCalendarCell alloc] initWithText:_title tag:_index++ numDays:_numDays];
    
    [self addCellToView:_titleLabel];
    
    [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

- (void)setupDayHeaders
{
    _sun = [[NVCalendarCell alloc] initWithText:@"Sun" tag:_index++ numDays:_numDays];
    _mon = [[NVCalendarCell alloc] initWithText:@"Mon" tag:_index++ numDays:_numDays];
    _tues = [[NVCalendarCell alloc] initWithText:@"Tue" tag:_index++ numDays:_numDays];
    _wed = [[NVCalendarCell alloc] initWithText:@"Wed" tag:_index++ numDays:_numDays];
    _thurs = [[NVCalendarCell alloc] initWithText:@"Thu" tag:_index++ numDays:_numDays];
    _fri = [[NVCalendarCell alloc] initWithText:@"Fri" tag:_index++ numDays:_numDays];
    _sat = [[NVCalendarCell alloc] initWithText:@"Sat" tag:_index++ numDays:_numDays];
    
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

- (void)setupCells
{
    NVCalendarCell *a1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%li", (_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    [self addCellToView:a1];
    [self addCellToView:a2];
    [self addCellToView:a3];
    [self addCellToView:a4];
    [self addCellToView:a5];
    [self addCellToView:a6];
    [self addCellToView:a7];
    
    [self addCellToView:b1];
    [self addCellToView:b2];
    [self addCellToView:b3];
    [self addCellToView:b4];
    [self addCellToView:b5];
    [self addCellToView:b6];
    [self addCellToView:b7];
    
    [self addCellToView:c1];
    [self addCellToView:c2];
    [self addCellToView:c3];
    [self addCellToView:c4];
    [self addCellToView:c5];
    [self addCellToView:c6];
    [self addCellToView:c7];
    
    [self addCellToView:d1];
    [self addCellToView:d2];
    [self addCellToView:d3];
    [self addCellToView:d4];
    [self addCellToView:d5];
    [self addCellToView:d6];
    [self addCellToView:d7];
    
    [self addCellToView:e1];
    [self addCellToView:e2];
    [self addCellToView:e3];
    [self addCellToView:e4];
    [self addCellToView:e5];
    [self addCellToView:e6];
    [self addCellToView:e7];
    
    [self addCellToView:f1];
    [self addCellToView:f2];
    [self addCellToView:f3];
    [self addCellToView:f4];
    [self addCellToView:f5];
    [self addCellToView:f6];
    [self addCellToView:f7];
    
    [a1.topAnchor constraintEqualToAnchor:_sun.bottomAnchor].active = YES;
    [a1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [a1.heightAnchor constraintEqualToAnchor:_sun.heightAnchor].active = YES;
    
    [a2.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a2.leadingAnchor constraintEqualToAnchor:a1.trailingAnchor].active = YES;
    [a2.widthAnchor constraintEqualToAnchor:a1.widthAnchor].active = YES;
    [a2.heightAnchor constraintEqualToAnchor:_mon.heightAnchor].active = YES;
    
    [a3.topAnchor constraintEqualToAnchor:_tues.bottomAnchor].active = YES;
    [a3.leadingAnchor constraintEqualToAnchor:a2.trailingAnchor].active = YES;
    [a3.widthAnchor constraintEqualToAnchor:a2.widthAnchor].active = YES;
    [a3.heightAnchor constraintEqualToAnchor:_tues.heightAnchor].active = YES;
    
    [a4.topAnchor constraintEqualToAnchor:_wed.bottomAnchor].active = YES;
    [a4.leadingAnchor constraintEqualToAnchor:a3.trailingAnchor].active = YES;
    [a4.widthAnchor constraintEqualToAnchor:a3.widthAnchor].active = YES;
    [a4.heightAnchor constraintEqualToAnchor:_wed.heightAnchor].active = YES;
    
    [a5.topAnchor constraintEqualToAnchor:_thurs.bottomAnchor].active = YES;
    [a5.leadingAnchor constraintEqualToAnchor:a4.trailingAnchor].active = YES;
    [a5.widthAnchor constraintEqualToAnchor:a4.widthAnchor].active = YES;
    [a5.heightAnchor constraintEqualToAnchor:_thurs.heightAnchor].active = YES;
    
    [a6.topAnchor constraintEqualToAnchor:_fri.bottomAnchor].active = YES;
    [a6.leadingAnchor constraintEqualToAnchor:a5.trailingAnchor].active = YES;
    [a6.widthAnchor constraintEqualToAnchor:a5.widthAnchor].active = YES;
    [a6.heightAnchor constraintEqualToAnchor:_fri.heightAnchor].active = YES;
    
    [a7.topAnchor constraintEqualToAnchor:_sat.bottomAnchor].active = YES;
    [a7.leadingAnchor constraintEqualToAnchor:a6.trailingAnchor].active = YES;
    [a7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [a7.widthAnchor constraintEqualToAnchor:a6.widthAnchor].active = YES;
    [a7.heightAnchor constraintEqualToAnchor:_sat.heightAnchor].active = YES;
    
    [b1.topAnchor constraintEqualToAnchor:a1.bottomAnchor].active = YES;
    [b1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [b1.heightAnchor constraintEqualToAnchor:a1.heightAnchor].active = YES;
    
    [b2.topAnchor constraintEqualToAnchor:a2.bottomAnchor].active = YES;
    [b2.leadingAnchor constraintEqualToAnchor:b1.trailingAnchor].active = YES;
    [b2.widthAnchor constraintEqualToAnchor:b1.widthAnchor].active = YES;
    [b2.heightAnchor constraintEqualToAnchor:a2.heightAnchor].active = YES;
    
    [b3.topAnchor constraintEqualToAnchor:a3.bottomAnchor].active = YES;
    [b3.leadingAnchor constraintEqualToAnchor:b2.trailingAnchor].active = YES;
    [b3.widthAnchor constraintEqualToAnchor:b2.widthAnchor].active = YES;
    [b3.heightAnchor constraintEqualToAnchor:a3.heightAnchor].active = YES;
    
    [b4.topAnchor constraintEqualToAnchor:a4.bottomAnchor].active = YES;
    [b4.leadingAnchor constraintEqualToAnchor:b3.trailingAnchor].active = YES;
    [b4.widthAnchor constraintEqualToAnchor:b3.widthAnchor].active = YES;
    [b4.heightAnchor constraintEqualToAnchor:a4.heightAnchor].active = YES;
    
    [b5.topAnchor constraintEqualToAnchor:a5.bottomAnchor].active = YES;
    [b5.leadingAnchor constraintEqualToAnchor:b4.trailingAnchor].active = YES;
    [b5.widthAnchor constraintEqualToAnchor:b4.widthAnchor].active = YES;
    [b5.heightAnchor constraintEqualToAnchor:a5.heightAnchor].active = YES;
    
    [b6.topAnchor constraintEqualToAnchor:a6.bottomAnchor].active = YES;
    [b6.leadingAnchor constraintEqualToAnchor:b5.trailingAnchor].active = YES;
    [b6.widthAnchor constraintEqualToAnchor:b5.widthAnchor].active = YES;
    [b6.heightAnchor constraintEqualToAnchor:a6.heightAnchor].active = YES;
    
    [b7.topAnchor constraintEqualToAnchor:a7.bottomAnchor].active = YES;
    [b7.leadingAnchor constraintEqualToAnchor:b6.trailingAnchor].active = YES;
    [b7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [b7.widthAnchor constraintEqualToAnchor:b6.widthAnchor].active = YES;
    [b1.heightAnchor constraintEqualToAnchor:a1.heightAnchor].active = YES;
    
    [c1.topAnchor constraintEqualToAnchor:b1.bottomAnchor].active = YES;
    [c1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [c1.heightAnchor constraintEqualToAnchor:b1.heightAnchor].active = YES;
    
    [c2.topAnchor constraintEqualToAnchor:b2.bottomAnchor].active = YES;
    [c2.leadingAnchor constraintEqualToAnchor:c1.trailingAnchor].active = YES;
    [c2.widthAnchor constraintEqualToAnchor:c1.widthAnchor].active = YES;
    [c2.heightAnchor constraintEqualToAnchor:b2.heightAnchor].active = YES;
    
    [c3.topAnchor constraintEqualToAnchor:b3.bottomAnchor].active = YES;
    [c3.leadingAnchor constraintEqualToAnchor:c2.trailingAnchor].active = YES;
    [c3.widthAnchor constraintEqualToAnchor:c2.widthAnchor].active = YES;
    [c3.heightAnchor constraintEqualToAnchor:b3.heightAnchor].active = YES;
    
    [c4.topAnchor constraintEqualToAnchor:b4.bottomAnchor].active = YES;
    [c4.leadingAnchor constraintEqualToAnchor:c3.trailingAnchor].active = YES;
    [c4.widthAnchor constraintEqualToAnchor:c3.widthAnchor].active = YES;
    [c4.heightAnchor constraintEqualToAnchor:b4.heightAnchor].active = YES;
    
    [c5.topAnchor constraintEqualToAnchor:b5.bottomAnchor].active = YES;
    [c5.leadingAnchor constraintEqualToAnchor:c4.trailingAnchor].active = YES;
    [c5.widthAnchor constraintEqualToAnchor:c4.widthAnchor].active = YES;
    [c5.heightAnchor constraintEqualToAnchor:b5.heightAnchor].active = YES;
    
    [c6.topAnchor constraintEqualToAnchor:b6.bottomAnchor].active = YES;
    [c6.leadingAnchor constraintEqualToAnchor:c5.trailingAnchor].active = YES;
    [c6.widthAnchor constraintEqualToAnchor:c5.widthAnchor].active = YES;
    [c6.heightAnchor constraintEqualToAnchor:b6.heightAnchor].active = YES;
    
    [c7.topAnchor constraintEqualToAnchor:b7.bottomAnchor].active = YES;
    [c7.leadingAnchor constraintEqualToAnchor:c6.trailingAnchor].active = YES;
    [c7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [c7.widthAnchor constraintEqualToAnchor:c6.widthAnchor].active = YES;
    [c7.heightAnchor constraintEqualToAnchor:b7.heightAnchor].active = YES;
    
    [d1.topAnchor constraintEqualToAnchor:c1.bottomAnchor].active = YES;
    [d1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [d1.heightAnchor constraintEqualToAnchor:c1.heightAnchor].active = YES;
    
    [d2.topAnchor constraintEqualToAnchor:c2.bottomAnchor].active = YES;
    [d2.leadingAnchor constraintEqualToAnchor:d1.trailingAnchor].active = YES;
    [d2.widthAnchor constraintEqualToAnchor:d1.widthAnchor].active = YES;
    [d2.heightAnchor constraintEqualToAnchor:c2.heightAnchor].active = YES;
    
    [d3.topAnchor constraintEqualToAnchor:c3.bottomAnchor].active = YES;
    [d3.leadingAnchor constraintEqualToAnchor:d2.trailingAnchor].active = YES;
    [d3.widthAnchor constraintEqualToAnchor:d2.widthAnchor].active = YES;
    [d3.heightAnchor constraintEqualToAnchor:c3.heightAnchor].active = YES;
    
    [d4.topAnchor constraintEqualToAnchor:c4.bottomAnchor].active = YES;
    [d4.leadingAnchor constraintEqualToAnchor:d3.trailingAnchor].active = YES;
    [d4.widthAnchor constraintEqualToAnchor:d3.widthAnchor].active = YES;
    [d4.heightAnchor constraintEqualToAnchor:c4.heightAnchor].active = YES;
    
    [d5.topAnchor constraintEqualToAnchor:c5.bottomAnchor].active = YES;
    [d5.leadingAnchor constraintEqualToAnchor:d4.trailingAnchor].active = YES;
    [d5.widthAnchor constraintEqualToAnchor:d4.widthAnchor].active = YES;
    [d5.heightAnchor constraintEqualToAnchor:c5.heightAnchor].active = YES;
    
    [d6.topAnchor constraintEqualToAnchor:c6.bottomAnchor].active = YES;
    [d6.leadingAnchor constraintEqualToAnchor:d5.trailingAnchor].active = YES;
    [d6.widthAnchor constraintEqualToAnchor:d5.widthAnchor].active = YES;
    [d6.heightAnchor constraintEqualToAnchor:c6.heightAnchor].active = YES;
    
    [d7.topAnchor constraintEqualToAnchor:c7.bottomAnchor].active = YES;
    [d7.leadingAnchor constraintEqualToAnchor:d6.trailingAnchor].active = YES;
    [d7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [d7.widthAnchor constraintEqualToAnchor:d6.widthAnchor].active = YES;
    [d7.heightAnchor constraintEqualToAnchor:c7.heightAnchor].active = YES;
    
    [e1.topAnchor constraintEqualToAnchor:d1.bottomAnchor].active = YES;
    [e1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [e1.heightAnchor constraintEqualToAnchor:d1.heightAnchor].active = YES;
    
    [e2.topAnchor constraintEqualToAnchor:d2.bottomAnchor].active = YES;
    [e2.leadingAnchor constraintEqualToAnchor:e1.trailingAnchor].active = YES;
    [e2.widthAnchor constraintEqualToAnchor:e1.widthAnchor].active = YES;
    [e2.heightAnchor constraintEqualToAnchor:d2.heightAnchor].active = YES;
    
    [e3.topAnchor constraintEqualToAnchor:d3.bottomAnchor].active = YES;
    [e3.leadingAnchor constraintEqualToAnchor:e2.trailingAnchor].active = YES;
    [e3.widthAnchor constraintEqualToAnchor:e2.widthAnchor].active = YES;
    [e3.heightAnchor constraintEqualToAnchor:d3.heightAnchor].active = YES;
    
    [e4.topAnchor constraintEqualToAnchor:d4.bottomAnchor].active = YES;
    [e4.leadingAnchor constraintEqualToAnchor:e3.trailingAnchor].active = YES;
    [e4.widthAnchor constraintEqualToAnchor:e3.widthAnchor].active = YES;
    [e4.heightAnchor constraintEqualToAnchor:d4.heightAnchor].active = YES;
    
    [e5.topAnchor constraintEqualToAnchor:d5.bottomAnchor].active = YES;
    [e5.leadingAnchor constraintEqualToAnchor:e4.trailingAnchor].active = YES;
    [e5.widthAnchor constraintEqualToAnchor:e4.widthAnchor].active = YES;
    [e5.heightAnchor constraintEqualToAnchor:d5.heightAnchor].active = YES;
    
    [e6.topAnchor constraintEqualToAnchor:d6.bottomAnchor].active = YES;
    [e6.leadingAnchor constraintEqualToAnchor:e5.trailingAnchor].active = YES;
    [e6.widthAnchor constraintEqualToAnchor:e5.widthAnchor].active = YES;
    [e6.heightAnchor constraintEqualToAnchor:d6.heightAnchor].active = YES;
    
    [e7.topAnchor constraintEqualToAnchor:d7.bottomAnchor].active = YES;
    [e7.leadingAnchor constraintEqualToAnchor:e6.trailingAnchor].active = YES;
    [e7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [e7.widthAnchor constraintEqualToAnchor:e6.widthAnchor].active = YES;
    [e7.heightAnchor constraintEqualToAnchor:d7.heightAnchor].active = YES;
    
    [f1.topAnchor constraintEqualToAnchor:e1.bottomAnchor].active = YES;
    [f1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [f1.heightAnchor constraintEqualToAnchor:e1.heightAnchor].active = YES;
    [f1.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [f2.topAnchor constraintEqualToAnchor:e2.bottomAnchor].active = YES;
    [f2.leadingAnchor constraintEqualToAnchor:f1.trailingAnchor].active = YES;
    [f2.widthAnchor constraintEqualToAnchor:f1.widthAnchor].active = YES;
    [f2.heightAnchor constraintEqualToAnchor:e2.heightAnchor].active = YES;
    [f2.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [f3.topAnchor constraintEqualToAnchor:e3.bottomAnchor].active = YES;
    [f3.leadingAnchor constraintEqualToAnchor:f2.trailingAnchor].active = YES;
    [f3.widthAnchor constraintEqualToAnchor:f2.widthAnchor].active = YES;
    [f3.heightAnchor constraintEqualToAnchor:e3.heightAnchor].active = YES;
    [f3.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [f4.topAnchor constraintEqualToAnchor:e4.bottomAnchor].active = YES;
    [f4.leadingAnchor constraintEqualToAnchor:f3.trailingAnchor].active = YES;
    [f4.widthAnchor constraintEqualToAnchor:f3.widthAnchor].active = YES;
    [f4.heightAnchor constraintEqualToAnchor:e4.heightAnchor].active = YES;
    [f4.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [f5.topAnchor constraintEqualToAnchor:e5.bottomAnchor].active = YES;
    [f5.leadingAnchor constraintEqualToAnchor:f4.trailingAnchor].active = YES;
    [f5.widthAnchor constraintEqualToAnchor:f4.widthAnchor].active = YES;
    [f5.heightAnchor constraintEqualToAnchor:e5.heightAnchor].active = YES;
    [f5.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [f6.topAnchor constraintEqualToAnchor:e6.bottomAnchor].active = YES;
    [f6.leadingAnchor constraintEqualToAnchor:f5.trailingAnchor].active = YES;
    [f6.widthAnchor constraintEqualToAnchor:f5.widthAnchor].active = YES;
    [f6.heightAnchor constraintEqualToAnchor:e6.heightAnchor].active = YES;
    [f6.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [f7.topAnchor constraintEqualToAnchor:e7.bottomAnchor].active = YES;
    [f7.leadingAnchor constraintEqualToAnchor:f6.trailingAnchor].active = YES;
    [f7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [f7.widthAnchor constraintEqualToAnchor:f6.widthAnchor].active = YES;
    [f7.heightAnchor constraintEqualToAnchor:e7.heightAnchor].active = YES;
    [f7.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}

- (void)addCellToView:(NVCalendarCell *)cell
{
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:cell];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    
    for (NVCalendarCell *cells in self.subviews)
    {
        if ([cells isKindOfClass:NVCalendarCell.class])
        {
            if (cells.tag > 8 && ![cells.text isEqualToString:@""])
            {
                if (CGRectContainsPoint(cells.frame, loc))
                    cells.selected = !cells.selected;
            }
            
            else if (cells.tag > 1 && cells.tag < 9)
            {
                if (CGRectContainsPoint(cells.frame, loc))
                {
                    for (int i = 7; i < 43; i += 7)
                    {
                        NVCalendarCell *cell = (NVCalendarCell *)[self viewWithTag:(cells.tag + i)];
                        
                        if (![cell.text isEqualToString:@""])
                            cell.selected = !cell.selected;
                    }
                }
            }
            
            else if (cells.tag == 1)
            {
                if (CGRectContainsPoint(cells.frame, loc))
                {
                    for (NVCalendarCell *theCells in self.subviews)
                    {
                        if ([theCells isKindOfClass:NVCalendarCell.class])
                        {
                            if (theCells.tag > 8 && ![theCells.text isEqualToString:@""])
                                theCells.selected = !theCells.selected;
                        }
                    }
                }
            }
        }
    }
}

@end