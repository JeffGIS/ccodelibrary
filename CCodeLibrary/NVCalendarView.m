//  NVCalendarView.m
//  CCodeLibrary

#import "NVCalendarView.h"
#import "NVCalendarCell.h"

@interface NVCalendarView ()

@property (nonatomic) NSString *title;
@property (nonatomic) UIFont *font;
@property (nonatomic) NVCalendarCell *titleLabel, *sun, *mon, *tues, *wed, *thurs, *fri, *sat;

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
        self.layer.masksToBounds = YES;
        _title = title;
        
        [self setupTitleLabel];
        [self setupDayHeaders];
        [self setupCells];
    }
    
    return self;
}

- (void)setupTitleLabel
{
    _titleLabel = [[NVCalendarCell alloc] initWithText:_title
                                                   tag:0];

    _titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [self addCellToView:_titleLabel];
    
    [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

- (void)setupDayHeaders
{
    _sun = [[NVCalendarCell alloc] initWithText:@"Sun"
                                            tag:0];
    
    _mon = [[NVCalendarCell alloc] initWithText:@"Mon"
                                            tag:0];
    
    _tues = [[NVCalendarCell alloc] initWithText:@"Tue"
                                             tag:0];
    
    _wed = [[NVCalendarCell alloc] initWithText:@"Wed"
                                            tag:0];
    
    _thurs = [[NVCalendarCell alloc] initWithText:@"Thu"
                                              tag:0];
    
    _fri = [[NVCalendarCell alloc] initWithText:@"Fri"
                                            tag:0];
    
    _sat = [[NVCalendarCell alloc] initWithText:@"Sat"
                                            tag:0];
    
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
    NSUInteger index = 0;
    
    NVCalendarCell *a1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *a2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *a3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *a4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *a5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *a6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *a7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *b7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *c7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *d7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *e7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f1 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f2 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f3 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f4 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f5 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f6 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
    NVCalendarCell *f7 = [[NVCalendarCell alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                          tag:index];
    
    index++;
    
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
    
    [a2.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a2.leadingAnchor constraintEqualToAnchor:a1.trailingAnchor].active = YES;
    [a2.widthAnchor constraintEqualToAnchor:a1.widthAnchor].active = YES;
    
    [a3.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a3.leadingAnchor constraintEqualToAnchor:a2.trailingAnchor].active = YES;
    [a3.widthAnchor constraintEqualToAnchor:a2.widthAnchor].active = YES;
    
    [a4.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a4.leadingAnchor constraintEqualToAnchor:a3.trailingAnchor].active = YES;
    [a4.widthAnchor constraintEqualToAnchor:a3.widthAnchor].active = YES;
    
    [a5.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a5.leadingAnchor constraintEqualToAnchor:a4.trailingAnchor].active = YES;
    [a5.widthAnchor constraintEqualToAnchor:a4.widthAnchor].active = YES;
    
    [a6.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a6.leadingAnchor constraintEqualToAnchor:a5.trailingAnchor].active = YES;
    [a6.widthAnchor constraintEqualToAnchor:a5.widthAnchor].active = YES;
    
    [a7.topAnchor constraintEqualToAnchor:_mon.bottomAnchor].active = YES;
    [a7.leadingAnchor constraintEqualToAnchor:a6.trailingAnchor].active = YES;
    [a7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [a7.widthAnchor constraintEqualToAnchor:a6.widthAnchor].active = YES;
    
    [b1.topAnchor constraintEqualToAnchor:a1.bottomAnchor].active = YES;
    [b1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [b1.heightAnchor constraintEqualToAnchor:a1.heightAnchor].active = YES;
    
    [b2.topAnchor constraintEqualToAnchor:a2.bottomAnchor].active = YES;
    [b2.leadingAnchor constraintEqualToAnchor:b1.trailingAnchor].active = YES;
    [b2.widthAnchor constraintEqualToAnchor:b1.widthAnchor].active = YES;
    
    [b3.topAnchor constraintEqualToAnchor:a3.bottomAnchor].active = YES;
    [b3.leadingAnchor constraintEqualToAnchor:b2.trailingAnchor].active = YES;
    [b3.widthAnchor constraintEqualToAnchor:b2.widthAnchor].active = YES;
    
    [b4.topAnchor constraintEqualToAnchor:a4.bottomAnchor].active = YES;
    [b4.leadingAnchor constraintEqualToAnchor:b3.trailingAnchor].active = YES;
    [b4.widthAnchor constraintEqualToAnchor:b3.widthAnchor].active = YES;
    
    [b5.topAnchor constraintEqualToAnchor:a5.bottomAnchor].active = YES;
    [b5.leadingAnchor constraintEqualToAnchor:b4.trailingAnchor].active = YES;
    [b5.widthAnchor constraintEqualToAnchor:b4.widthAnchor].active = YES;
    
    [b6.topAnchor constraintEqualToAnchor:a6.bottomAnchor].active = YES;
    [b6.leadingAnchor constraintEqualToAnchor:b5.trailingAnchor].active = YES;
    [b6.widthAnchor constraintEqualToAnchor:b5.widthAnchor].active = YES;
    
    [b7.topAnchor constraintEqualToAnchor:a7.bottomAnchor].active = YES;
    [b7.leadingAnchor constraintEqualToAnchor:b6.trailingAnchor].active = YES;
    [b7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [b7.widthAnchor constraintEqualToAnchor:b6.widthAnchor].active = YES;
    
    [c1.topAnchor constraintEqualToAnchor:b1.bottomAnchor].active = YES;
    [c1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [c1.heightAnchor constraintEqualToAnchor:b1.heightAnchor].active = YES;
    
    [c2.topAnchor constraintEqualToAnchor:b2.bottomAnchor].active = YES;
    [c2.leadingAnchor constraintEqualToAnchor:c1.trailingAnchor].active = YES;
    [c2.widthAnchor constraintEqualToAnchor:c1.widthAnchor].active = YES;
    
    [c3.topAnchor constraintEqualToAnchor:b3.bottomAnchor].active = YES;
    [c3.leadingAnchor constraintEqualToAnchor:c2.trailingAnchor].active = YES;
    [c3.widthAnchor constraintEqualToAnchor:c2.widthAnchor].active = YES;
    
    [c4.topAnchor constraintEqualToAnchor:b4.bottomAnchor].active = YES;
    [c4.leadingAnchor constraintEqualToAnchor:c3.trailingAnchor].active = YES;
    [c4.widthAnchor constraintEqualToAnchor:c3.widthAnchor].active = YES;
    
    [c5.topAnchor constraintEqualToAnchor:b5.bottomAnchor].active = YES;
    [c5.leadingAnchor constraintEqualToAnchor:c4.trailingAnchor].active = YES;
    [c5.widthAnchor constraintEqualToAnchor:c4.widthAnchor].active = YES;
    
    [c6.topAnchor constraintEqualToAnchor:b6.bottomAnchor].active = YES;
    [c6.leadingAnchor constraintEqualToAnchor:c5.trailingAnchor].active = YES;
    [c6.widthAnchor constraintEqualToAnchor:c5.widthAnchor].active = YES;
    
    [c7.topAnchor constraintEqualToAnchor:b7.bottomAnchor].active = YES;
    [c7.leadingAnchor constraintEqualToAnchor:c6.trailingAnchor].active = YES;
    [c7.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [c7.widthAnchor constraintEqualToAnchor:c6.widthAnchor].active = YES;
    
    [d1.topAnchor constraintEqualToAnchor:c1.bottomAnchor].active = YES;
    [d1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [d1.heightAnchor constraintEqualToAnchor:c1.heightAnchor].active = YES;
    
    [e1.topAnchor constraintEqualToAnchor:d1.bottomAnchor].active = YES;
    [e1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [e1.heightAnchor constraintEqualToAnchor:d1.heightAnchor].active = YES;
    
    [f1.topAnchor constraintEqualToAnchor:e1.bottomAnchor].active = YES;
    [f1.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [f1.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [f1.heightAnchor constraintEqualToAnchor:e1.heightAnchor].active = YES;
}

- (void)addCellToView:(NVCalendarCell *)cell
{
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:cell];
}

@end