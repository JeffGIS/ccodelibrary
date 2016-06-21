//  LegendView.m
//  CCodeLibrary

#import "LegendView.h"
#import "UserDefaults.h"

@interface LegendView ()

@property (nonatomic) CGFloat size, nonLabelWidth;

@end

@implementation LegendView

- (id)initWithOrigin:(CGPoint)origin
      hasComplexView:(BOOL)hasComplexView;
{
    CGFloat margin = 4.0, height = 140.0, markerMargin = 6.0;
    CGRect frame = CGRectZero;
    _size = 15.0;
    _nonLabelWidth = (_size + (margin * 3.0));
    
    if (hasComplexView)
        frame = CGRectMake(origin.x, origin.y, _nonLabelWidth, height);
    
    else
        frame = CGRectMake(origin.x, origin.y, _nonLabelWidth, 120.0);
    
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
        CGFloat labelHeight = ((height - buffer) / 6.0);
        
        _completed = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, margin, 0.0, labelHeight)];
        _toBeDone = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, (labelHeight + margin), 0.0, labelHeight)];
        _notAssigned = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 2.0) + margin), 0.0, labelHeight)];
        
        [self setupLabel:_completed
               textColor:UserDefaults.defaults.darkGreen];
        
        [self setupLabel:_toBeDone
               textColor:UIColor.redColor];
        
        [self setupLabel:_notAssigned
               textColor:UIColor.blueColor];
        
        if (hasComplexView)
        {
            _complex = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 3.0) + margin), 0.0, labelHeight)];
            _numInts = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 4.0) + margin), 0.0, labelHeight)];
            _numRamps = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 5.0) + margin), 0.0, labelHeight)];
            
            [self setupLabel:_complex
                   textColor:UIColor.darkGrayColor];
        }
        
        else
        {
            _numInts = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 3.0) + margin), 0.0, labelHeight)];
            _numRamps = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, ((labelHeight * 4.0) + margin), 0.0, labelHeight)];
        }
        
        [self setupLabel:_numRamps
               textColor: UIColor.blackColor];
        
        [self setupLabel:_numInts
               textColor: UIColor.blackColor];
        
        _completedMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, buffer, _size, _size)];
        _toBeDoneMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, (labelHeight + buffer), _size, _size)];
        _notAssignedMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, ((labelHeight * 2.0) + buffer), _size, _size)];
        
        [self setupView:_completedMarker
        backgroundColor:UserDefaults.defaults.darkGreen];
        
        [self setupView:_toBeDoneMarker
        backgroundColor:UIColor.redColor];
        
        [self setupView:_notAssignedMarker
        backgroundColor:UIColor.blueColor];
        
        if (hasComplexView)
        {
            _complexMarker = [[UIView alloc] initWithFrame:CGRectMake(markerMargin, ((labelHeight * 3.0) + buffer), _size, _size)];
            
            [self setupView:_complexMarker
            backgroundColor:UIColor.darkGrayColor];
        }
        
        [self updateWidthForText];
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

- (void)updateWidthForText
{
    CGFloat maxWidth = 0.0;
    
    for (UILabel *labels in self.subviews)
    {
        if ([labels isKindOfClass:UILabel.class])
            maxWidth = MAX(labels.intrinsicContentSize.width, maxWidth);
    }
    
    for (UILabel *labels in self.subviews)
    {
        if ([labels isKindOfClass:UILabel.class])
        {
            CGRect frame = labels.frame;
            frame.size.width = maxWidth;
            labels.frame = frame;
        }
    }
    
    CGRect frame = self.frame;
    frame.size.width = (maxWidth + _nonLabelWidth);
    self.frame = frame;
}

@end