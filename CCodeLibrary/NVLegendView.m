//  NVLegendView.m
//  CCodeLibrary

#import "NVLegendView.h"
#import "UserDefaults.h"

@interface NVLegendView ()

@property CGFloat minWidth;
@property CGPoint origin;

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
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xMargin, originY, 0.0, height)];
            titleLabel.text = [_delegate titleForLegendView];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = UIColor.blackColor;
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
            label.font = font;
            label.tag = ((index + 1) * 10);
            _minWidth = max(_minWidth, (label.intrinsicContentSize.width + (xMargin * 2.0)));
            [self addSubview:label];
            originY += height;
        }
        
        for (UILabel *labels in self.subviews)
        {
            labels.frame = CGRectMake(labels.frame.origin.x, labels.frame.origin.y,
                                      _minWidth, labels.frame.size.height);
        }
        
        self.frame = CGRectMake(_origin.x, _origin.y, _minWidth,
                                ((height * totalRows) + (yMargin * 2.0)));
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

@end