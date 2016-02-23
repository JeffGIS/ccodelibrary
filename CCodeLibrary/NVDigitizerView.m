//  NVDigitizerView.m
//  CCodeLibrary

#import "NVDigitizerView.h"

@interface NVDigitizerView ()

@property (nonatomic, weak) id <NVDigitizerViewDelegate> delegate;
@property (nonatomic) NSMutableArray *coordinates;
@property (nonatomic) UIImageView *targetView;
@property (nonatomic) CGFloat targetSize, markerSize;
@property BOOL clearMarkers;

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
    nvdv.targetSize = 200.0;
    nvdv.markerSize = 24.0;
    nvdv.clearMarkers = NO;
    nvdv.delegate = delegate;
    nvdv.backgroundColor = UIColor.clearColor;
    nvdv.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:nvdv];
    
    [nvdv.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
    [nvdv.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
    [nvdv.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    [nvdv.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
    
    nvdv.targetView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:
                                                          [NSBundle.mainBundle pathForResource:@"newCrosshairs"
                                                                                        ofType:@"png"]]];
    
    nvdv.targetView.frame = CGRectMake((CGRectGetMinX(constrainedView.frame) +
                                       CGRectGetMidX(constrainedView.frame)) - (nvdv.targetSize / 2.0),
                                       (CGRectGetMinY(constrainedView.frame) +
                                       CGRectGetMidY(constrainedView.frame)) - (nvdv.targetSize / 2.0),
                                       nvdv.targetSize, nvdv.targetSize);
    
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
    if (CGRectContainsPoint(_targetView.frame, point))
        return YES;
    
    else
        return NO;
}

- (void)targetViewDragged:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                          gesture.view.center.y + translation.y);
    
    [gesture setTranslation:CGPointZero
                     inView:self];
}

- (void)targetViewTapped:(UITapGestureRecognizer *)gesture
{
    CLLocationCoordinate2D coord = [_delegate coordinateForPoint:gesture.view.center];
    [_coordinates addObject:[NSValue valueWithMKCoordinate:coord]];
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
        return;
    }
    
    for (NSValue *values in _coordinates)
    {
        CLLocationCoordinate2D coord = values.MKCoordinateValue;
        CGPoint point = [_delegate pointForCoordinate:coord];
        
        CGRect markerFrame = CGRectMake((point.x - _markerSize / 2.0),
                                        (point.y - _markerSize / 2.0),
                                        _markerSize, _markerSize);
        
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect (context, markerFrame);
        CGContextStrokeEllipseInRect(context, markerFrame);
        CGContextFillPath(context);
    }
}

@end