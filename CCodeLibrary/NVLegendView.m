//  NVLegendView.m
//  CCodeLibrary

#import "NVLegendView.h"
#import "UserDefaults.h"

@interface NVLegendView ()

@property (nonatomic) CGFloat originalHeight, zoomLevel, lastScale;
@property (nonatomic) CGPoint origin, viewCenter;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) CGRect containerFrame;
@property BOOL selectable;

@end

@implementation NVLegendView

+ (NVLegendView *)showLegendViewAtOrigin:(CGPoint)origin
                                  inView:(UIView *)view
                          containerFrame:(CGRect)containerFrame
                                delegate:(id)delegate
                              selectable:(BOOL)selectable
                                animated:(BOOL)animated
{
    NVLegendView *legendView = [[NVLegendView alloc] init];
    legendView.delegate = delegate;
    legendView.layer.cornerRadius = 10.0;
    legendView.layer.masksToBounds = YES;
    legendView.layer.borderColor = UIColor.blackColor.CGColor;
    legendView.layer.borderWidth = 4.0;
    legendView.userInteractionEnabled = YES;
    legendView.backgroundColor = UIColor.whiteColor;
    legendView.zoomLevel = 1.0;
    legendView.origin = origin;
    legendView.containerFrame = containerFrame;
    legendView.selectable = selectable;
    legendView.selectedIndex = 1;
    
    if (legendView.selectable)
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:legendView
                                                                                     action:@selector(legendViewWasTapped:)];
        
        tapGesture.delegate = legendView;
        [legendView addGestureRecognizer:tapGesture];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:legendView
                                                                                 action:@selector(legendViewWasPanned:)];
    
    panGesture.delegate = legendView;
    [legendView addGestureRecognizer:panGesture];
    [legendView loadView];
    
    if (animated)
    {
        legendView.alpha = 0.0;
        [view addSubview:legendView];
        
        [UIView animateWithDuration:0.25 animations:^{
            legendView.alpha = 1.0;
        }];
    }
    
    else
        [view addSubview:legendView];
    
    return legendView;
}

- (void)hideLegendView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    
    else
        [self removeFromSuperview];
}

- (void)loadView
{
    if (_delegate)
    {
        UIFont *font = [UIFont boldSystemFontOfSize:18.0];
        CGFloat height = 24.0, xMargin = 8.0, yMargin = 6.0, minWidth = 0.0;
        CGFloat originY = yMargin, markerHeight = (height * 0.75), countWidth = 0.0;
        NSString *title = [_delegate titleForLegendView];
        NSUInteger numberOfRows = [_delegate numberOfRowsInLegendView];
        CGFloat titleHeight = 0.0;
        
        if (title && ![title isEqualToString:@""])
        {
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = [_delegate titleForLegendView];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = UIColor.blackColor;
            titleLabel.backgroundColor = UIColor.clearColor;
            titleLabel.numberOfLines = 0;
            titleLabel.font = font;
            titleLabel.frame = CGRectMake(0.0, originY, 0.0, titleLabel.intrinsicContentSize.height);
            minWidth = (titleLabel.intrinsicContentSize.width + (xMargin * 2.0));
            [self addSubview:titleLabel];
            titleHeight = titleLabel.frame.size.height;
            originY += titleHeight;
        }
        
        for (int index = 0; index < numberOfRows; index++)
        {
            UIColor *color = [_delegate colorForRowInLegendViewAtIndex:index];
            
            if (color)
            {
                UIView *marker = [[UIView alloc] initWithFrame:CGRectMake(xMargin, (originY + (height * 0.125)),
                                                                          markerHeight, markerHeight)];
                
                marker.backgroundColor = color;
                marker.layer.cornerRadius = (markerHeight / 2.0);
                marker.layer.borderColor = UIColor.blackColor.CGColor;
                marker.layer.borderWidth = 1.0;
                [self addSubview:marker];
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((((xMargin * 2.0) + markerHeight) - self.layer.borderWidth),
                                                                       originY, 0.0, height)];
            
            label.text = [NSString stringWithFormat:@"%@",
                          [_delegate nameForRowInLegendViewAtIndex:index]];
            
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = UIColor.blackColor;
            label.backgroundColor = UIColor.clearColor;
            label.font = font;
            label.tag = ((index + 1) * 10);
            minWidth = max(minWidth, (((label.intrinsicContentSize.width + (xMargin * 3.0)) + markerHeight)) - self.layer.borderWidth);
            [self addSubview:label];
            originY += height;
        }
        
        for (UILabel *labels in self.subviews)
        {
            if ([labels isKindOfClass:UILabel.class])
            {
                if (labels.tag > 9)
                {
                    labels.frame = CGRectMake(labels.frame.origin.x, labels.frame.origin.y,
                                              (((minWidth - (xMargin * 3.0)) - markerHeight) + self.layer.borderWidth),
                                              labels.frame.size.height);
                    
                    NSUInteger index = ((labels.tag / 10) - 1);
                    
                    long count = [_delegate countForRowInLegendViewAtIndex:index];
                    if (count >= 0)
                    {
                        UILabel *countLabel = [[UILabel alloc] init];
                        countLabel.text = [NSString stringWithFormat:@"%lu",
                                           (unsigned long)count];
                        countLabel.textAlignment = NSTextAlignmentLeft;
                        countLabel.textColor = UIColor.blackColor;
                        countLabel.backgroundColor = UIColor.clearColor;
                        countLabel.font = font;
                        countLabel.tag = (labels.tag + 1);
                        countWidth = max(countWidth, countLabel.intrinsicContentSize.width);
                        
                        countLabel.frame = CGRectMake((labels.frame.size.width + xMargin),
                                                      0.0, countLabel.intrinsicContentSize.width, height);
                        
                        [labels addSubview:countLabel];
                    }
                }
            }
        }
        
        minWidth += (countWidth + xMargin);
        
        for (UILabel *labels in self.subviews)
        {
            if ([labels isKindOfClass:UILabel.class])
            {
                if (labels.tag > 9)
                {
                    labels.frame = CGRectMake(labels.frame.origin.x, labels.frame.origin.y,
                                              (((minWidth - (xMargin * 3.0)) - markerHeight) + self.layer.borderWidth),
                                              labels.frame.size.height);
                }
                
                else
                {
                    labels.frame = CGRectMake(labels.frame.origin.x, labels.frame.origin.y,
                                              minWidth, labels.frame.size.height);
                }
            }
        }
        
        self.frame = CGRectMake(_origin.x, _origin.y, minWidth,
                                (titleHeight + (height * numberOfRows) + (yMargin * 2.0)));
        
        _originalHeight = self.frame.size.height;
        
        if (_selectable)
            [self highlightAtIndex:_selectedIndex];
    }
}

- (void)reloadView
{
    for (UIView *subviews in self.subviews)
        [subviews removeFromSuperview];
        
    [self loadView];
}

- (void)highlightAtIndex:(NSUInteger)index
{
    if (_delegate)
    {
        for (UILabel *labels in self.subviews)
        {
            NSUInteger tag = ((index + 1) * 10);
            
            if (labels.tag == tag)
            {
                labels.backgroundColor = UIColor.blackColor;
                labels.textColor = UIColor.whiteColor;
                
                for (UILabel *countLabels in labels.subviews)
                {
                    if (countLabels.tag == (tag + 1))
                    {
                        countLabels.backgroundColor = UIColor.blackColor;
                        countLabels.textColor = UIColor.whiteColor;
                    }
                }
            }
            
            else if (labels.tag > 9)
            {
                labels.backgroundColor = UIColor.clearColor;
                labels.textColor = UIColor.blackColor;
                
                for (UILabel *countLabels in labels.subviews)
                {
                    countLabels.backgroundColor = UIColor.clearColor;
                    countLabels.textColor = UIColor.blackColor;
                }
            }
        }
    }
}

- (void)legendViewWasTapped:(UITapGestureRecognizer *)gesture
{
    if (_delegate)
    {
        if (_selectedIndex == [_delegate numberOfRowsInLegendView] - 1)
            _selectedIndex = 1;
        
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
        _viewCenter = gesture.view.center;
    
    [gesture setTranslation:CGPointMake(0.0, 0.0)
                     inView:gesture.view];
}

@end
