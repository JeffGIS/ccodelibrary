//  NVLegendView.m
//  CCodeLibrary

#import "NVLegendView.h"
#import "UserDefaults.h"

@interface NVLegendView ()

@property CGFloat minWidth;
@property CGPoint origin;
@property NSUInteger selectedIndex;

@end

@implementation NVLegendView

+ (NVLegendView *)showLegendViewAtOrigin:(CGPoint)origin
                                  inView:(UIView *)view
                                delegate:(id)delegate
{
    NVLegendView *legendView = [[NVLegendView alloc] init];
    legendView.delegate = delegate;
    legendView.layer.cornerRadius = 10.0;
    legendView.layer.masksToBounds = YES;
    legendView.layer.borderColor = UIColor.blackColor.CGColor;
    legendView.layer.borderWidth = 4.0;
    legendView.userInteractionEnabled = YES;
    legendView.backgroundColor = UIColor.whiteColor;
    legendView.minWidth = 0.0;
    legendView.origin = origin;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:legendView
                                                                                 action:@selector(legendViewWasTapped:)];
    
    tapGesture.delegate = legendView;
    [legendView addGestureRecognizer:tapGesture];
    
    [legendView loadView];
    [view addSubview:legendView];
    
    return legendView;
}

- (void)loadView
{
    if (_delegate)
    {
        UIFont *font = [UIFont boldSystemFontOfSize:18.0];
        CGFloat height = 24.0, xMargin = 8.0, yMargin = 4.0;
        CGFloat originY = yMargin;
        NSString *title = [_delegate titleForLegendView];
        NSUInteger numberOfRows = [_delegate numberOfRowsInLegendView];
        NSUInteger totalRows = numberOfRows;
        
        if (title && ![title isEqualToString:@""])
        {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, 0.0, height)];
            titleLabel.text = [_delegate titleForLegendView];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = UIColor.blackColor;
            titleLabel.backgroundColor = UIColor.clearColor;
            titleLabel.font = font;
            _minWidth = (titleLabel.intrinsicContentSize.width + (xMargin * 2.0));
            [self addSubview:titleLabel];
            originY += height;
            totalRows++;
        }
        
        for (int index = 0; index < numberOfRows; index++)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xMargin, originY, 0.0, height)];
            
            label.text = [NSString stringWithFormat:@"%@ (%lu)",
                          [_delegate nameForRowInLegendViewAtIndex:index],
                          (unsigned long)[_delegate countForRowInLegendViewAtIndex:index]];
            
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [_delegate colorForRowInLegendViewAtIndex:index];
            label.backgroundColor = UIColor.clearColor;
            label.font = font;
            label.tag = ((index + 1) * 10);
            _minWidth = max(_minWidth, (label.intrinsicContentSize.width + (xMargin * 2.0)));
            [self addSubview:label];
            originY += height;
        }
        
        for (UILabel *labels in self.subviews)
        {
            if (labels.tag > 9)
            {
                labels.frame = CGRectMake(labels.frame.origin.x, labels.frame.origin.y,
                                          (_minWidth - (xMargin * 2.0)), labels.frame.size.height);
            }
            
            else
            {
                labels.frame = CGRectMake(labels.frame.origin.x, labels.frame.origin.y,
                                          _minWidth, labels.frame.size.height);
            }
        }
        
        self.frame = CGRectMake(_origin.x, _origin.y, _minWidth,
                                ((height * totalRows) + (yMargin * 2.0)));
        
        _selectedIndex = 0;
        [self highlightAtIndex:_selectedIndex];
    }
}

- (void)reloadView
{
    for (UIView *subviews in self.subviews)
        [subviews removeFromSuperview];
        
    [self loadView];
}

- (void)reloadData
{
    for (UILabel *labels in self.subviews)
    {
        if (labels.tag > 9)
        {
            NSUInteger index = ((labels.tag / 10) - 1);
            
            labels.text = [NSString stringWithFormat:@"%@ (%lu)",
                           [_delegate nameForRowInLegendViewAtIndex:index],
                           (unsigned long)[_delegate countForRowInLegendViewAtIndex:index]];
        }
    }
}

- (void)highlightAtIndex:(NSUInteger)index
{
    if (_delegate)
    {
        for (UILabel *labels in self.subviews)
        {
            if (labels.tag == ((index + 1) * 10))
            {
                labels.backgroundColor = [_delegate colorForRowInLegendViewAtIndex:index];
                labels.textColor = UIColor.whiteColor;
            }
            
            else if (labels.tag > 9)
            {
                labels.backgroundColor = UIColor.clearColor;
                labels.textColor = [_delegate colorForRowInLegendViewAtIndex:((labels.tag / 10) - 1)];
            }
        }
    }
}

- (void)legendViewWasTapped:(UITapGestureRecognizer *)gesture
{
    if (_delegate)
    {
        if (_selectedIndex == [_delegate numberOfRowsInLegendView] - 1)
            _selectedIndex = 0;
        
        else
            _selectedIndex++;
        
        [self highlightAtIndex:_selectedIndex];
        
        [_delegate legendView:self
       didChangeSelectedIndex:_selectedIndex];
    }
}

@end