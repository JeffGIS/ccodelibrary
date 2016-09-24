//  NVCalendarView.m
//  CCodeLibrary

#import "NVCalendarView.h"
#import "NVCalendarCell.h"
#import "UserDefaults.h"

@interface NVCalendarView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic) UIFont *font;
@property (nonatomic) NVCalendarCell *titleLabel, *sun, *mon, *tues, *wed, *thurs, *fri, *sat;
@property (nonatomic) NVCalendarCell *currentCell;
@property (nonatomic) NSInteger index, startDay, month, year;
@property (nonatomic) NSUInteger numDays;
@property (nonatomic) NSMutableArray *calendarArray;

@end

@implementation NVCalendarView

- (id)initWithMonth:(NSInteger)month
               year:(NSInteger)year
           firstDay:(NSInteger)firstDay
            numDays:(NSUInteger)numDays
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = UIColor.blackColor;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.masksToBounds = YES;
        _month = month, _year = year;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSString *monthName = [df.monthSymbols objectAtIndex:(_month - 1)];
        
        _title = [NSString stringWithFormat:@"%@ %li", monthName, (long)_year];
        _index = 1, _startDay = (firstDay + 7), _numDays = numDays;
        
        _calendarArray = [[NSMutableArray alloc] initWithArray:[UserDefaults.defaults arrayForKey:@"TestCalendarArray"]];
        
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
    [_titleLabel constrainTopToAnchor:self.topAnchor];
    [_titleLabel constrainLeadingToAnchor:self.leadingAnchor];
    [_titleLabel constrainTrailingToAnchor:self.trailingAnchor];
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
    
    [_sun constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_sun constrainLeadingToAnchor:self.leadingAnchor];
    [_sun constrainHeightToAnchor:_titleLabel.heightAnchor];
    
    [_mon constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_mon constrainLeadingToAnchor:_sun.trailingAnchor];
    [_mon constrainHeightToAnchor:_titleLabel.heightAnchor];
    [_mon constrainWidthToAnchor:_sun.widthAnchor];
    
    [_tues constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_tues constrainLeadingToAnchor:_mon.trailingAnchor];
    [_tues constrainHeightToAnchor:_titleLabel.heightAnchor];
    [_tues constrainWidthToAnchor:_mon.widthAnchor];
    
    [_wed constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_wed constrainLeadingToAnchor:_tues.trailingAnchor];
    [_wed constrainHeightToAnchor:_titleLabel.heightAnchor];
    [_wed constrainWidthToAnchor:_tues.widthAnchor];
    
    [_thurs constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_thurs constrainLeadingToAnchor:_wed.trailingAnchor];
    [_thurs constrainHeightToAnchor:_titleLabel.heightAnchor];
    [_thurs constrainWidthToAnchor:_wed.widthAnchor];
    
    [_fri constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_fri constrainLeadingToAnchor:_thurs.trailingAnchor];
    [_fri constrainHeightToAnchor:_titleLabel.heightAnchor];
    [_fri constrainWidthToAnchor:_thurs.widthAnchor];
    
    [_sat constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_sat constrainLeadingToAnchor:_fri.trailingAnchor];
    [_sat constrainHeightToAnchor:_titleLabel.heightAnchor];
    [_sat constrainTrailingToAnchor:self.trailingAnchor];
    [_sat constrainWidthToAnchor:_fri.widthAnchor];
}

- (void)setupCells
{
    NVCalendarCell *a1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *a7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *b7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *c7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *d7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *e7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
                                                          tag:_index numDays:_numDays];_index++;
    
    NVCalendarCell *f7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)(_index - _startDay)]
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
    
    [a1 constrainTopToAnchor:_sun.bottomAnchor];
    [a1 constrainLeadingToAnchor:self.leadingAnchor];
    [a1 constrainHeightToAnchor:_sun.heightAnchor];
    
    [a2 constrainTopToAnchor:_mon.bottomAnchor];
    [a2 constrainLeadingToAnchor:a1.trailingAnchor];
    [a2 constrainWidthToAnchor:a1.widthAnchor];
    [a2 constrainHeightToAnchor:_mon.heightAnchor];
    
    [a3 constrainTopToAnchor:_tues.bottomAnchor];
    [a3 constrainLeadingToAnchor:a2.trailingAnchor];
    [a3 constrainWidthToAnchor:a2.widthAnchor];
    [a3 constrainHeightToAnchor:_tues.heightAnchor];
    
    [a4 constrainTopToAnchor:_wed.bottomAnchor];
    [a4 constrainLeadingToAnchor:a3.trailingAnchor];
    [a4 constrainWidthToAnchor:a3.widthAnchor];
    [a4 constrainHeightToAnchor:_wed.heightAnchor];
    
    [a5 constrainTopToAnchor:_thurs.bottomAnchor];
    [a5 constrainLeadingToAnchor:a4.trailingAnchor];
    [a5 constrainWidthToAnchor:a4.widthAnchor];
    [a5 constrainHeightToAnchor:_thurs.heightAnchor];
    
    [a6 constrainTopToAnchor:_fri.bottomAnchor];
    [a6 constrainLeadingToAnchor:a5.trailingAnchor];
    [a6 constrainWidthToAnchor:a5.widthAnchor];
    [a6 constrainHeightToAnchor:_fri.heightAnchor];
    
    [a7 constrainTopToAnchor:_sat.bottomAnchor];
    [a7 constrainLeadingToAnchor:a6.trailingAnchor];
    [a7 constrainTrailingToAnchor:self.trailingAnchor];
    [a7 constrainWidthToAnchor:a6.widthAnchor];
    [a7 constrainHeightToAnchor:_sat.heightAnchor];
    
    [b1 constrainTopToAnchor:a1.bottomAnchor];
    [b1 constrainLeadingToAnchor:self.leadingAnchor];
    [b1 constrainHeightToAnchor:a1.heightAnchor];
    
    [b2 constrainTopToAnchor:a2.bottomAnchor];
    [b2 constrainLeadingToAnchor:b1.trailingAnchor];
    [b2 constrainWidthToAnchor:b1.widthAnchor];
    [b2 constrainHeightToAnchor:a2.heightAnchor];
    
    [b3 constrainTopToAnchor:a3.bottomAnchor];
    [b3 constrainLeadingToAnchor:b2.trailingAnchor];
    [b3 constrainWidthToAnchor:b2.widthAnchor];
    [b3 constrainHeightToAnchor:a3.heightAnchor];
    
    [b4 constrainTopToAnchor:a4.bottomAnchor];
    [b4 constrainLeadingToAnchor:b3.trailingAnchor];
    [b4 constrainWidthToAnchor:b3.widthAnchor];
    [b4 constrainHeightToAnchor:a4.heightAnchor];
    
    [b5 constrainTopToAnchor:a5.bottomAnchor];
    [b5 constrainLeadingToAnchor:b4.trailingAnchor];
    [b5 constrainWidthToAnchor:b4.widthAnchor];
    [b5 constrainHeightToAnchor:a5.heightAnchor];
    
    [b6 constrainTopToAnchor:a6.bottomAnchor];
    [b6 constrainLeadingToAnchor:b5.trailingAnchor];
    [b6 constrainWidthToAnchor:b5.widthAnchor];
    [b6 constrainHeightToAnchor:a6.heightAnchor];
    
    [b7 constrainTopToAnchor:a7.bottomAnchor];
    [b7 constrainLeadingToAnchor:b6.trailingAnchor];
    [b7 constrainTrailingToAnchor:self.trailingAnchor];
    [b7 constrainWidthToAnchor:b6.widthAnchor];
    [b1 constrainHeightToAnchor:a1.heightAnchor];
    
    [c1 constrainTopToAnchor:b1.bottomAnchor];
    [c1 constrainLeadingToAnchor:self.leadingAnchor];
    [c1 constrainHeightToAnchor:b1.heightAnchor];
    
    [c2 constrainTopToAnchor:b2.bottomAnchor];
    [c2 constrainLeadingToAnchor:c1.trailingAnchor];
    [c2 constrainWidthToAnchor:c1.widthAnchor];
    [c2 constrainHeightToAnchor:b2.heightAnchor];
    
    [c3 constrainTopToAnchor:b3.bottomAnchor];
    [c3 constrainLeadingToAnchor:c2.trailingAnchor];
    [c3 constrainWidthToAnchor:c2.widthAnchor];
    [c3 constrainHeightToAnchor:b3.heightAnchor];
    
    [c4 constrainTopToAnchor:b4.bottomAnchor];
    [c4 constrainLeadingToAnchor:c3.trailingAnchor];
    [c4 constrainWidthToAnchor:c3.widthAnchor];
    [c4 constrainHeightToAnchor:b4.heightAnchor];
    
    [c5 constrainTopToAnchor:b5.bottomAnchor];
    [c5 constrainLeadingToAnchor:c4.trailingAnchor];
    [c5 constrainWidthToAnchor:c4.widthAnchor];
    [c5 constrainHeightToAnchor:b5.heightAnchor];
    
    [c6 constrainTopToAnchor:b6.bottomAnchor];
    [c6 constrainLeadingToAnchor:c5.trailingAnchor];
    [c6 constrainWidthToAnchor:c5.widthAnchor];
    [c6 constrainHeightToAnchor:b6.heightAnchor];
    
    [c7 constrainTopToAnchor:b7.bottomAnchor];
    [c7 constrainLeadingToAnchor:c6.trailingAnchor];
    [c7 constrainTrailingToAnchor:self.trailingAnchor];
    [c7 constrainWidthToAnchor:c6.widthAnchor];
    [c7 constrainHeightToAnchor:b7.heightAnchor];
    
    [d1 constrainTopToAnchor:c1.bottomAnchor];
    [d1 constrainLeadingToAnchor:self.leadingAnchor];
    [d1 constrainHeightToAnchor:c1.heightAnchor];
    
    [d2 constrainTopToAnchor:c2.bottomAnchor];
    [d2 constrainLeadingToAnchor:d1.trailingAnchor];
    [d2 constrainWidthToAnchor:d1.widthAnchor];
    [d2 constrainHeightToAnchor:c2.heightAnchor];
    
    [d3 constrainTopToAnchor:c3.bottomAnchor];
    [d3 constrainLeadingToAnchor:d2.trailingAnchor];
    [d3 constrainWidthToAnchor:d2.widthAnchor];
    [d3 constrainHeightToAnchor:c3.heightAnchor];
    
    [d4 constrainTopToAnchor:c4.bottomAnchor];
    [d4 constrainLeadingToAnchor:d3.trailingAnchor];
    [d4 constrainWidthToAnchor:d3.widthAnchor];
    [d4 constrainHeightToAnchor:c4.heightAnchor];
    
    [d5 constrainTopToAnchor:c5.bottomAnchor];
    [d5 constrainLeadingToAnchor:d4.trailingAnchor];
    [d5 constrainWidthToAnchor:d4.widthAnchor];
    [d5 constrainHeightToAnchor:c5.heightAnchor];
    
    [d6 constrainTopToAnchor:c6.bottomAnchor];
    [d6 constrainLeadingToAnchor:d5.trailingAnchor];
    [d6 constrainWidthToAnchor:d5.widthAnchor];
    [d6 constrainHeightToAnchor:c6.heightAnchor];
    
    [d7 constrainTopToAnchor:c7.bottomAnchor];
    [d7 constrainLeadingToAnchor:d6.trailingAnchor];
    [d7 constrainTrailingToAnchor:self.trailingAnchor];
    [d7 constrainWidthToAnchor:d6.widthAnchor];
    [d7 constrainHeightToAnchor:c7.heightAnchor];
    
    [e1 constrainTopToAnchor:d1.bottomAnchor];
    [e1 constrainLeadingToAnchor:self.leadingAnchor];
    [e1 constrainHeightToAnchor:d1.heightAnchor];
    
    [e2 constrainTopToAnchor:d2.bottomAnchor];
    [e2 constrainLeadingToAnchor:e1.trailingAnchor];
    [e2 constrainWidthToAnchor:e1.widthAnchor];
    [e2 constrainHeightToAnchor:d2.heightAnchor];
    
    [e3 constrainTopToAnchor:d3.bottomAnchor];
    [e3 constrainLeadingToAnchor:e2.trailingAnchor];
    [e3 constrainWidthToAnchor:e2.widthAnchor];
    [e3 constrainHeightToAnchor:d3.heightAnchor];
    
    [e4 constrainTopToAnchor:d4.bottomAnchor];
    [e4 constrainLeadingToAnchor:e3.trailingAnchor];
    [e4 constrainWidthToAnchor:e3.widthAnchor];
    [e4 constrainHeightToAnchor:d4.heightAnchor];
    
    [e5 constrainTopToAnchor:d5.bottomAnchor];
    [e5 constrainLeadingToAnchor:e4.trailingAnchor];
    [e5 constrainWidthToAnchor:e4.widthAnchor];
    [e5 constrainHeightToAnchor:d5.heightAnchor];
    
    [e6 constrainTopToAnchor:d6.bottomAnchor];
    [e6 constrainLeadingToAnchor:e5.trailingAnchor];
    [e6 constrainWidthToAnchor:e5.widthAnchor];
    [e6 constrainHeightToAnchor:d6.heightAnchor];
    
    [e7 constrainTopToAnchor:d7.bottomAnchor];
    [e7 constrainLeadingToAnchor:e6.trailingAnchor];
    [e7 constrainTrailingToAnchor:self.trailingAnchor];
    [e7 constrainWidthToAnchor:e6.widthAnchor];
    [e7 constrainHeightToAnchor:d7.heightAnchor];
    
    [f1 constrainTopToAnchor:e1.bottomAnchor];
    [f1 constrainLeadingToAnchor:self.leadingAnchor];
    [f1 constrainHeightToAnchor:e1.heightAnchor];
    [f1 constrainBottomToAnchor:self.bottomAnchor];
    
    [f2 constrainTopToAnchor:e2.bottomAnchor];
    [f2 constrainLeadingToAnchor:f1.trailingAnchor];
    [f2 constrainWidthToAnchor:f1.widthAnchor];
    [f2 constrainHeightToAnchor:e2.heightAnchor];
    [f2 constrainBottomToAnchor:self.bottomAnchor];
    
    [f3 constrainTopToAnchor:e3.bottomAnchor];
    [f3 constrainLeadingToAnchor:f2.trailingAnchor];
    [f3 constrainWidthToAnchor:f2.widthAnchor];
    [f3 constrainHeightToAnchor:e3.heightAnchor];
    [f3 constrainBottomToAnchor:self.bottomAnchor];
    
    [f4 constrainTopToAnchor:e4.bottomAnchor];
    [f4 constrainLeadingToAnchor:f3.trailingAnchor];
    [f4 constrainWidthToAnchor:f3.widthAnchor];
    [f4 constrainHeightToAnchor:e4.heightAnchor];
    [f4 constrainBottomToAnchor:self.bottomAnchor];
    
    [f5 constrainTopToAnchor:e5.bottomAnchor];
    [f5 constrainLeadingToAnchor:f4.trailingAnchor];
    [f5 constrainWidthToAnchor:f4.widthAnchor];
    [f5 constrainHeightToAnchor:e5.heightAnchor];
    [f5 constrainBottomToAnchor:self.bottomAnchor];
    
    [f6 constrainTopToAnchor:e6.bottomAnchor];
    [f6 constrainLeadingToAnchor:f5.trailingAnchor];
    [f6 constrainWidthToAnchor:f5.widthAnchor];
    [f6 constrainHeightToAnchor:e6.heightAnchor];
    [f6 constrainBottomToAnchor:self.bottomAnchor];
    
    [f7 constrainTopToAnchor:e7.bottomAnchor];
    [f7 constrainLeadingToAnchor:f6.trailingAnchor];
    [f7 constrainTrailingToAnchor:self.trailingAnchor];
    [f7 constrainWidthToAnchor:f6.widthAnchor];
    [f7 constrainHeightToAnchor:e7.heightAnchor];
    [f7 constrainBottomToAnchor:self.bottomAnchor];
}

- (void)addCellToView:(NVCalendarCell *)cell
{
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:cell];
    
    if (cell.tag > 8 && ![cell.text isEqualToString:@""])
    {
        if ([_calendarArray containsObject:[self identifierForCell:cell]])
            cell.selected = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    [self handleTouchAtLoc:loc];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    
    if (CGRectContainsPoint(_currentCell.frame, loc))
        return;
    
    [self handleTouchAtLoc:loc];
}

- (void)handleTouchAtLoc:(CGPoint)loc
{
    for (NVCalendarCell *cells in self.subviews)
    {
        if ([cells isKindOfClass:NVCalendarCell.class])
        {
            if (cells.tag > 8 && ![cells.text isEqualToString:@""])
            {
                if (CGRectContainsPoint(cells.frame, loc))
                {
                    _currentCell = cells;
                    
                    if (!cells.selected)
                        [self addCell:cells];
                    
                    else
                        [self removeCell:cells];
                }
            }
            
            else if (cells.tag > 1 && cells.tag < 9)
            {
                if (CGRectContainsPoint(cells.frame, loc))
                {
                    _currentCell = cells;
                    
                    for (int i = 7; i < 43; i += 7)
                    {
                        NVCalendarCell *cell = (NVCalendarCell *)[self viewWithTag:(cells.tag + i)];
                        
                        if (![cell.text isEqualToString:@""])
                        {
                            if (!cell.selected)
                                [self addCell:cell];
                            
                            else
                                [self removeCell:cell];
                        }
                    }
                }
            }
            
            else if (cells.tag == 1)
            {
                if (CGRectContainsPoint(cells.frame, loc))
                {
                    _currentCell = cells;
                    
                    for (NVCalendarCell *theCells in self.subviews)
                    {
                        if ([theCells isKindOfClass:NVCalendarCell.class])
                        {
                            if (theCells.tag > 8 && ![theCells.text isEqualToString:@""])
                            {
                                if (!theCells.selected)
                                    [self addCell:theCells];
                                
                                else
                                    [self removeCell:theCells];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)addCell:(NVCalendarCell *)cell
{
    [_calendarArray addObject:[self identifierForCell:cell]];
    [self saveCalendarArray];
    cell.selected = YES;
}

- (void)removeCell:(NVCalendarCell *)cell
{
    [_calendarArray removeObject:[self identifierForCell:cell]];
    [self saveCalendarArray];
    cell.selected = NO;
}

- (void)saveCalendarArray
{
    [UserDefaults.defaults saveArray:_calendarArray.copy
                              forKey:@"TestCalendarArray"];
}

- (NSString *)identifierForCell:(NVCalendarCell *)cell
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumIntegerDigits = 2;
    
    NSString *monthString = [formatter stringFromNumber:[NSNumber numberWithInteger:_month]];
    NSString *dayString = [formatter stringFromNumber:[NSNumber numberWithInteger:cell.text.integerValue]];
    return [NSString stringWithFormat:@"%li%@%@", (long)_year, monthString, dayString];
}

@end
