//  NVDigitizerView.m
//  CCodeLibrary

#import "NVDigitizerView.h"
#import "UserDefaults.h"

@interface NVDigitizerView ()

@property (nonatomic, weak) id <NVDigitizerViewDelegate> delegate;
@property (nonatomic) NSMutableArray *coordinates;
@property (nonatomic) UIImageView *targetView;
@property (nonatomic) CGFloat targetSize, markerSize, yOffset;
@property BOOL clearMarkers, targetDragged, targetTapped, finalDisplayMode;

@end

@implementation NVDigitizerView

+ (instancetype)showDigitizerInView:(UIView *)view
                  constrainedToView:(UIView *)constrainedView
                           delegate:(id)delegate
{
    if (!delegate)
        return nil;
    
    NVDigitizerView *nvdv = NVDigitizerView.new;
    nvdv.coordinates = NSMutableArray.array;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        nvdv.targetSize = 200.0;
    
    else
        nvdv.targetSize = 300.0;
    
    nvdv.markerSize = 20.0;
    nvdv.clearMarkers = NO;
    nvdv.targetDragged = NO;
    nvdv.targetTapped = NO;
    nvdv.finalDisplayMode = NO;
    nvdv.delegate = delegate;
    nvdv.yOffset = constrainedView.frame.origin.y;
    nvdv.backgroundColor = UIColor.clearColor;
    nvdv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:nvdv];
    
    [nvdv.leadingAnchor constraintEqualToAnchor:constrainedView.leadingAnchor].active = YES;
    [nvdv.trailingAnchor constraintEqualToAnchor:constrainedView.trailingAnchor].active = YES;
    [nvdv.bottomAnchor constraintEqualToAnchor:constrainedView.bottomAnchor].active = YES;
    [nvdv.topAnchor constraintEqualToAnchor:constrainedView.topAnchor].active = YES;
    
    nvdv.targetView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:
                                                          [NSBundle.mainBundle pathForResource:@"newCrosshairs"
                                                                                        ofType:@"png"]]];
    
    nvdv.targetView.frame = CGRectMake(0.0, 0.0, nvdv.targetSize, nvdv.targetSize);
    
    nvdv.targetView.center = CGPointMake(CGRectGetMidX(constrainedView.frame),
                                         CGRectGetMidY(constrainedView.frame));
    
    nvdv.targetView.userInteractionEnabled = YES;
    [nvdv addSubview:nvdv.targetView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:nvdv
                                                                          action:@selector(targetViewDragged:)];
    
    [nvdv.targetView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nvdv
                                                                          action:@selector(targetViewTapped:)];
    
    [nvdv.targetView addGestureRecognizer:tap];
    
    return nvdv;
}

- (BOOL)pointInside:(CGPoint)point
          withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(_targetView.frame, point) || _finalDisplayMode)
        return YES;
    
    else
        return NO;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    if (_finalDisplayMode)
        [_delegate digitizerViewDidComplete:self];
}

- (void)targetViewDragged:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                          gesture.view.center.y + translation.y);
    
    [gesture setTranslation:CGPointZero
                     inView:self];
    
    _targetDragged = YES;
    _targetTapped = NO;
    [self setNeedsDisplay];
}

- (void)targetViewTapped:(UITapGestureRecognizer *)gesture
{
    if (_targetTapped)
    {
        _targetView.hidden = YES;
        _finalDisplayMode = YES;
    }
    
    else
    {
        CLLocationCoordinate2D coord = [_delegate coordinateForPoint:gesture.view.center];
        [_coordinates addObject:[NSValue valueWithMKCoordinate:coord]];
        _targetTapped = YES;
    }
    
    [self setNeedsDisplay];
}

- (void)clearDigitizerView
{
    _clearMarkers = YES;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_clearMarkers)
    {
        CGContextClearRect(context, self.frame);
        _clearMarkers = NO;
        _targetTapped = NO;
        return;
    }
    
    if (_targetDragged && _coordinates.count)
    {
        NSValue *lastValue = _coordinates.lastObject;
        CGPoint lastPoint = [_delegate pointForCoordinate:lastValue.MKCoordinateValue];
        
        CGContextSetStrokeColorWithColor(context, UserDefaults.defaults.appleBlue.CGColor);
        CGContextSetLineWidth(context, 12.0);
        CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(context, _targetView.center.x, _targetView.center.y);
        CGContextStrokePath(context);
        
        _targetDragged = NO;
    }
    
    for (int i = 1; i < _coordinates.count; i++)
    {
        NSValue *value1 = _coordinates[i - 1];
        NSValue *value2 = _coordinates[i];
        CGPoint point1 = [_delegate pointForCoordinate:value1.MKCoordinateValue];
        CGPoint point2 = [_delegate pointForCoordinate:value2.MKCoordinateValue];
        
        CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
        CGContextSetLineWidth(context, 6.0);
        CGContextMoveToPoint(context, point1.x, point1.y);
        CGContextAddLineToPoint(context, point2.x, point2.y);
        CGContextStrokePath(context);
        
        if (_targetTapped || _finalDisplayMode)
        {
            if (_coordinates.count > 2)
            {
                NSValue *value1 = _coordinates.lastObject;
                NSValue *value2 = _coordinates.firstObject;
                CGPoint point1 = [_delegate pointForCoordinate:value1.MKCoordinateValue];
                CGPoint point2 = [_delegate pointForCoordinate:value2.MKCoordinateValue];
                
                if (_finalDisplayMode)
                    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
                
                else
                    CGContextSetStrokeColorWithColor(context, UserDefaults.defaults.appleBlue.CGColor);
                    
                CGContextSetLineWidth(context, 6.0);
                CGContextMoveToPoint(context, point1.x, point1.y);
                CGContextAddLineToPoint(context, point2.x, point2.y);
                CGContextStrokePath(context);
            }
        }
    }
    
    for (NSValue *values in _coordinates)
    {
        CGPoint point = [_delegate pointForCoordinate:values.MKCoordinateValue];
        
        CGRect markerFrame = CGRectMake((point.x - _markerSize / 2.0),
                                        (point.y - _markerSize / 2.0),
                                        _markerSize, _markerSize);
        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
        CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect (context, markerFrame);
        CGContextStrokeEllipseInRect(context, markerFrame);
        CGContextFillPath(context);
    }
}

- (void)placeTargetInCenter
{
    [UIView animateWithDuration:0.25 animations:^{
        _targetView.center = CGPointMake(CGRectGetMidY(self.frame) + _yOffset,
                                         CGRectGetMidX(self.frame) - _yOffset);
    }];
}

@end