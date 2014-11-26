//  LegendView.m
//  CCodeLibrary

#import "LegendView.h"

@implementation LegendView
{
    CGFloat _size;
}

- (id)initWithOrigin:(CGPoint)origin
      hasComplexView:(BOOL)hasComplexView;
{
    CGFloat margin = 4.0, width = 264.0, height = 140.0, markerMargin = 6.0;
    UIColor *green = UserDefaults.defaults.darkGreen;
    UIColor *red = UIColor.redColor;
    UIColor *blue = UserDefaults.defaults.appleBlue;
    UIColor *gray = UIColor.darkGrayColor;
    UIColor *black = UIColor.blackColor;
    CGRect frame;
    _size = 15.0;
    
    if (hasComplexView == YES)
        frame = CGRectMake(origin.x, origin.y, width, height);
    
    else
        frame = CGRectMake(origin.x, origin.y, width, 120.0);
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 4.0;
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColor.whiteColor;
        
        CGFloat buffer = (margin * 2.0);
        CGFloat leftMargin = (_size + buffer);
        CGFloat labelWidth = (width - leftMargin);
        CGFloat labelHeight = ((height - buffer) / 6.0);
        
        self.completed = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, margin, labelWidth, labelHeight)];
        self.toBeDone = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, (labelHeight + margin), labelWidth, labelHeight)];
        self.notAssigned = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 2.0) + margin), labelWidth, labelHeight)];
        
        [self setupLabel:self.completed
               textColor:green];
        
        [self setupLabel:self.toBeDone
               textColor:red];
        
        [self setupLabel:self.notAssigned
               textColor:blue];
        
        if (hasComplexView == YES)
        {
            self.complex = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 3.0) + margin), labelWidth, labelHeight)];
            self.numInts = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 4.0) + margin), labelWidth, labelHeight)];
            self.numRamps = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 5.0) + margin), labelWidth, labelHeight)];
            
            [self setupLabel:self.complex
                   textColor:gray];
        }
        
        else
        {
            self.numRamps = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 3.0) + margin), labelWidth, labelHeight)];
            self.numInts = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 4.0) + margin), labelWidth, labelHeight)];
        }
        
        [self setupLabel:self.numRamps
               textColor:black];
        
        [self setupLabel:self.numInts
               textColor:black];
        
        self.completedMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, buffer, _size, _size)];
        self.toBeDoneMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, (labelHeight + buffer), _size, _size)];
        self.notAssignedMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, ((labelHeight * 2.0) + buffer), _size, _size)];
        
        [self setupView:self.completedMarker
        backgroundColor:green];
        
        [self setupView:self.toBeDoneMarker
        backgroundColor:red];
        
        [self setupView:self.notAssignedMarker
        backgroundColor:blue];
        
        if (hasComplexView == YES)
        {
            self.complexMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, ((labelHeight * 3.0) + buffer), _size, _size)];
            
            [self setupView:self.complexMarker
            backgroundColor:gray];
        }
    }
    
    return self;
}

- (void)setupLabel:(UILabel *)label
         textColor:(UIColor *)textColor
{
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = UIColor.clearColor;
    [self addSubview:label];
}

- (void)setupView:(UIView *)view
  backgroundColor:(UIColor *)backgroundColor
{
    view.backgroundColor = backgroundColor;
    view.layer.cornerRadius = (_size / 2.0);
    view.layer.borderColor = UIColor.blackColor.CGColor;
    view.layer.borderWidth = 1.5;
    view.clipsToBounds = NO;
    [self addSubview:view];
}

@end