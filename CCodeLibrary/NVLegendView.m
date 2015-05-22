//  NVLegendView.m
//  CCodeLibrary

#import "NVLegendView.h"
#import "UserDefaults.h"

@interface NVLegendView ()

@property (nonatomic) CGFloat minWidth, originalHeight, zoomLevel, lastScale;
@property (nonatomic) CGPoint origin, viewCenter;
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
    legendView.zoomLevel = 1.0;
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
    
    CGFloat centerX = (gesture.view.center.x + translation.x * _zoomLevel);
    CGFloat centerY = (gesture.view.center.y + translation.y * _zoomLevel);
    
    centerX = min(centerX, ((_containerFrame.origin.x + _containerFrame.size.width) - (self.frame.size.width / 2.0)));
    centerX = max(centerX, (_containerFrame.origin.x + (self.frame.size.width / 2.0)));
    
    centerY = min(centerY, ((_containerFrame.origin.y + _containerFrame.size.height) - (self.frame.size.height / 2.0)));
    centerY = max(centerY, (_containerFrame.origin.y + (self.frame.size.height / 2.0)));
    
    gesture.view.center = CGPointMake(centerX, centerY);
        
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        CGFloat filter = 50.0, duration = 0.6;
        
        if ([gesture velocityInView:gesture.view].x < -filter ||
            [gesture velocityInView:gesture.view].x > filter ||
            [gesture velocityInView:gesture.view].y < -filter ||
            [gesture velocityInView:gesture.view].y > filter)
            {
                CGFloat centerX = (gesture.view.center.x + ([gesture velocityInView:gesture.view].x * duration));
                CGFloat centerY = (gesture.view.center.y + ([gesture velocityInView:gesture.view].y * duration));
                
                centerX = min(centerX, ((_containerFrame.origin.x + _containerFrame.size.width) - (self.frame.size.width / 2.0)));
                centerX = max(centerX, (_containerFrame.origin.x + (self.frame.size.width / 2.0)));
                
                centerY = min(centerY, ((_containerFrame.origin.y + _containerFrame.size.height) - (self.frame.size.height / 2.0)));
                centerY = max(centerY, (_containerFrame.origin.y + (self.frame.size.height / 2.0)));
                
                [UIView animateWithDuration:duration
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     gesture.view.center = CGPointMake(centerX, centerY);
                                 }
                                 completion:^(BOOL finished) {
                                     if (_delegate)
                                     {
                                         [_delegate legendView:self
                                            wasDraggedToOrigin:gesture.view.frame.origin];
                                     }
                                     
                                     _viewCenter = gesture.view.center;
                                 }];
            }
        
        else
            _viewCenter = gesture.view.center;
    }
    
    [gesture setTranslation:CGPointMake(0.0, 0.0)
                     inView:gesture.view];
}

- (void)legendViewWasPinched:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _zoomLevel = (gesture.view.frame.size.height / _originalHeight);
        _viewCenter = gesture.view.center;
        
        if (_delegate)
        {
            [_delegate legendView:self
                wasPinchedToScale:_zoomLevel];
        }
        
        return;
    }
    
    if(gesture.state == UIGestureRecognizerStateBegan)
        _lastScale = gesture.scale;
    
    CGPoint origin = gesture.view.frame.origin;
    CGFloat currentScale = [[gesture.view.layer valueForKeyPath:@"transform.scale"] floatValue];
    
    const CGFloat kMaxScale = 2.2, kMinScale = 0.8;
    
    CGFloat newScale = (1.0 - (_lastScale - gesture.scale));
    newScale = min(newScale, kMaxScale / currentScale);
    newScale = max(newScale, kMinScale / currentScale);
    
    CGAffineTransform transform = CGAffineTransformScale(gesture.view.transform, newScale, newScale);
    gesture.view.transform = transform;
    _lastScale = gesture.scale;
    CGRect frame = gesture.view.frame;
    
    if (_viewCenter.x < (_containerFrame.size.width / 2.0) &&
        _viewCenter.y < (_containerFrame.size.height / 2.0))
    {
        frame.origin = origin;
        gesture.view.frame = frame;
    }
    
    else if (_viewCenter.x > (_containerFrame.size.width / 2.0) &&
             _viewCenter.y > (_containerFrame.size.height / 2.0))
    {
        frame.origin.x = (origin.x - ((origin.x - frame.origin.x) * 2.0));
        frame.origin.y = (origin.y - ((origin.y - frame.origin.y) * 2.0));
        gesture.view.frame = frame;
    }
    
    else if (_viewCenter.x > (_containerFrame.size.width / 2.0) &&
             _viewCenter.y < (_containerFrame.size.height / 2.0))
    {
        frame.origin.x = (origin.x - ((origin.x - frame.origin.x) * 2.0));
        frame.origin.y = origin.y;
        gesture.view.frame = frame;
    }
    
    else if (_viewCenter.x < (_containerFrame.size.width / 2.0) &&
             _viewCenter.y > (_containerFrame.size.height / 2.0))
    {
        frame.origin.x = origin.x;
        frame.origin.y = (origin.y - ((origin.y - frame.origin.y) * 2.0));
        gesture.view.frame = frame;
    }
}

@end