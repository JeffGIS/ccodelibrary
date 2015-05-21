//  NVLegendView.m
//  CCodeLibrary

#import "NVLegendView.h"
#import "UserDefaults.h"

@interface NVLegendView ()

@property (nonatomic) CGFloat minWidth, originalHeight;
@property (nonatomic) CGPoint origin;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) CGRect containerFrame;

@end

@implementation NVLegendView

+ (NVLegendView *)showLegendViewAtOrigin:(CGPoint)origin
                                  inView:(UIView *)view
                          containerFrame:(CGRect)containerFrame
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
    legendView.containerFrame = containerFrame;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:legendView
                                                                                 action:@selector(legendViewWasTapped:)];
    
    tapGesture.delegate = legendView;
    [legendView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:legendView
                                                                                 action:@selector(legendViewWasPanned:)];
    
    panGesture.delegate = legendView;
    [legendView addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:legendView
                                                                                       action:@selector(legendViewWasPinched:)];
    
    pinchGesture.delegate = legendView;
    [legendView addGestureRecognizer:pinchGesture];
    
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
        
        _originalHeight = self.frame.size.height;
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

- (void)legendViewWasPanned:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view];
    
    CGPoint newCenter = CGPointMake(gesture.view.center.x + translation.x,
                                    gesture.view.center.y + translation.y);
    
    if (((newCenter.x - (self.frame.size.width / 2.0)) > _containerFrame.origin.x) &&
        ((newCenter.y - (self.frame.size.height / 2.0)) > _containerFrame.origin.y) &&
        ((newCenter.x + (self.frame.size.width / 2.0)) < (_containerFrame.origin.x + _containerFrame.size.width)) &&
        ((newCenter.y + (self.frame.size.height / 2.0)) < (_containerFrame.origin.y + _containerFrame.size.height)))
    {
        gesture.view.center = newCenter;
    }
        
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate)
        {
            [_delegate legendView:self
               wasDraggedToOrigin:gesture.view.frame.origin];
        }
        
        return;
    }
    
    [gesture setTranslation:CGPointMake(0.0, 0.0)
                     inView:gesture.view];
}

- (void)legendViewWasPinched:(UIPinchGestureRecognizer *)gesture
{
    
}

@end