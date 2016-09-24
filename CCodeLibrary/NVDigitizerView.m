//  NVDigitizerView.m
//  CCodeLibrary

#import "NVDigitizerView.h"
#import "UserDefaults.h"

@interface NVDigitizerView ()

@property (nonatomic, weak) id <NVDigitizerViewDelegate> delegate;
@property (nonatomic) NSMutableArray *coordinates;
@property (nonatomic) UIImageView *targetView;
@property (nonatomic) CGFloat targetSize, markerSize, yOffset;
@property BOOL clearMarkers, targetTapped, finalDisplayMode, pathTouched;
@property NSInteger touchedItemIndex;
@property (nonatomic) CGMutablePathRef path;

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
    nvdv.touchedItemIndex = -1;
    nvdv.clearMarkers = NO;
    nvdv.targetTapped = NO;
    nvdv.finalDisplayMode = NO;
    nvdv.pathTouched = NO;
    nvdv.delegate = delegate;
    nvdv.yOffset = constrainedView.frame.origin.y;
    nvdv.backgroundColor = UIColor.clearColor;
    nvdv.translatesAutoresizingMaskIntoConstraints = NO;
    nvdv.path = CGPathCreateMutable();
    
    [view addSubview:nvdv];
    [nvdv constrainLeadingToAnchor:constrainedView.leadingAnchor];
    [nvdv constrainTrailingToAnchor:constrainedView.trailingAnchor];
    [nvdv constrainBottomToAnchor:constrainedView.bottomAnchor];
    [nvdv constrainTopToAnchor:constrainedView.topAnchor];
    
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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:nvdv
                                               action:@selector(targetViewLongPressed:)];
    
    
    [nvdv.targetView addGestureRecognizer:longPress];
    
    return nvdv;
}

- (void)dealloc
{
    CGPathRelease(_path);
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
    {
        _touchedItemIndex = -1;
        
        NSMutableArray *pointList = NSMutableArray.array;
        NSMutableArray *indexList = NSMutableArray.array;
        UITouch *touch = event.allTouches.anyObject;
        CGPoint loc = [touch locationInView:self];
        
        for (NSValue *values in _coordinates)
        {
            CGPoint point = [_delegate pointForCoordinate:values.MKCoordinateValue];
            
            if (point.x > (loc.x - _markerSize * 2.0) &&
                point.x < (loc.x + _markerSize * 2.0) &&
                point.y > (loc.y - _markerSize * 2.0) &&
                point.y < (loc.y + _markerSize * 2.0))
                {
                    [pointList addObject:[NSValue valueWithCGPoint:point]];
                    
                    [indexList addObject:[NSNumber numberWithInteger:
                                          [_coordinates indexOfObject:values]]];
                }
        }
        
        CGFloat distance = CGFLOAT_MAX;
        
        for (NSValue *values in pointList)
        {
            CGPoint point = values.CGPointValue;
            CGFloat distX = (point.x - loc.x);
            CGFloat distY = (point.y - loc.y);
            CGFloat totDist = (distX * distX) + (distY * distY);
            
            if (totDist < distance)
            {
                NSInteger index = [pointList indexOfObject:values];
                NSNumber *storedIndex = [indexList objectAtIndex:index];
                _touchedItemIndex = storedIndex.integerValue;
                distance = totDist;
            }
                
        }
        
        if (_touchedItemIndex > -1)
            [self setNeedsDisplay];
        
        else if (CGPathContainsPoint(_path, nil, loc, FALSE))
        {
            _pathTouched = YES;
            [self setNeedsDisplay];
        }
        
        else
        {
            int numPoints = (int)(_coordinates.count + 1);
            LPDPOINT llpoints = malloc(numPoints * sizeof(DPOINT) + 4);
            
            for (int i = 0; i < _coordinates.count; i++)
            {
                NSValue *value = _coordinates[i];
                llpoints[i].x = value.MKCoordinateValue.longitude;
                llpoints[i].y = value.MKCoordinateValue.latitude;
            }
            
            NSValue *value = _coordinates[0];
            llpoints[numPoints - 1].x = value.MKCoordinateValue.longitude;
            llpoints[numPoints - 1].y = value.MKCoordinateValue.latitude;
            
            const char *filePath = [NSString stringWithFormat:@"%@/testArea.bin", UserDefaults.defaults.localFilePath].UTF8String;
            FILE *testAreaFile = fopen(filePath, "wb");
            
            fwrite(&numPoints, sizeof(int), 1, testAreaFile);
            fwrite(llpoints, sizeof(DPOINT), numPoints, testAreaFile);
            fclose(testAreaFile);
            free(llpoints);
            
            NSLog(@"NVDigitizerView did write test area file to %s", filePath);
            
            [_delegate digitizerViewDidComplete:self];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    if (_pathTouched)
    {
        _pathTouched = NO;
        [self setNeedsDisplay];
        [self zoomToExtents];
    }
}

- (void)targetViewDragged:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                          gesture.view.center.y + translation.y);
    
    [gesture setTranslation:CGPointZero
                     inView:self];
    
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

- (void)targetViewLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (_coordinates.count)
    {
        NSValue *lastValue = _coordinates.lastObject;
        CGPoint lastPoint = [_delegate pointForCoordinate:lastValue.MKCoordinateValue];
        _targetTapped = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            _targetView.center = lastPoint;
            [self setNeedsDisplay];
        }];
    }
}

- (void)clearDigitizerView
{
    _clearMarkers = YES;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    _path = CGPathCreateMutable();
    
    if (_clearMarkers || !_coordinates.count)
    {
        CGContextClearRect(context, self.frame);
        _clearMarkers = NO;
        _targetTapped = NO;
        return;
    }
    
    if (!_finalDisplayMode)
    {
        NSValue *lastValue = _coordinates.lastObject;
        CGPoint lastPoint = [_delegate pointForCoordinate:lastValue.MKCoordinateValue];
        
        if (lastPoint.x != _targetView.center.x && lastPoint.y != _targetView.center.y)
        {
            CGContextSetStrokeColorWithColor(context, UserDefaults.defaults.appleBlue.CGColor);
            CGContextSetLineWidth(context, 12.0);
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(context, _targetView.center.x, _targetView.center.y);
            CGContextStrokePath(context);
        }
    }
    
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    
    if (_pathTouched)
        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 0.4);
    
    else
        CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 0.4);
    
    CGContextSetLineWidth(context, 6.0);
    NSValue *value = _coordinates[0];
    CGPoint point = [_delegate pointForCoordinate:value.MKCoordinateValue];
    CGPathMoveToPoint(_path, nil, point.x, point.y);
    
    for (int i = 1; i < _coordinates.count; i++)
    {
        NSValue *value = _coordinates[i];
        CGPoint point = [_delegate pointForCoordinate:value.MKCoordinateValue];
        CGPathAddLineToPoint(_path, nil, point.x, point.y);
    }
    
    if (_finalDisplayMode)
    {
        if (_coordinates.count > 2)
        {
            NSValue *value = _coordinates.firstObject;
            CGPoint point = [_delegate pointForCoordinate:value.MKCoordinateValue];
            CGPathAddLineToPoint(_path, nil, point.x, point.y);
        }
    }
    
    CGContextAddPath(context, _path);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    for (NSValue *values in _coordinates)
    {
        CGPoint point = [_delegate pointForCoordinate:values.MKCoordinateValue];
        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
        CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
        CGContextSetLineWidth(context, 2.0);
        
        CGRect markerFrame = CGRectMake((point.x - _markerSize / 2.0),
                                        (point.y - _markerSize / 2.0),
                                        _markerSize, _markerSize);
        
        if ([_coordinates indexOfObject:values] == _touchedItemIndex)
        {
            CGContextSetFillColorWithColor(context, UserDefaults.defaults.green.CGColor);
            CGContextSetLineWidth(context, 4.0);
            
            markerFrame = CGRectMake((point.x - _markerSize), (point.y - _markerSize),
                                     (_markerSize * 2.0), (_markerSize * 2.0));
        }
        
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

- (void)zoomToExtents
{
    CGFloat minLat = 0.0, maxLat = 0.0, minLon = 0.0, maxLon = 0.0;
    
    for (NSValue *values in _coordinates)
    {
        CLLocationCoordinate2D coord = values.MKCoordinateValue;
        
        if (minLat == 0.0)
            minLat = coord.latitude;
        
        else
            minLat = MIN(minLat, coord.latitude);
        
        if (maxLat == 0.0)
            maxLat = coord.latitude;
        
        else
            maxLat = MAX(maxLat, coord.latitude);
        
        if (minLon == 0.0)
            minLon = coord.longitude;
        
        else
            minLon = MIN(minLon, coord.longitude);
        
        if (maxLon == 0.0)
            maxLon = coord.longitude;
        
        else
            maxLon = MAX(maxLon, coord.longitude);
    }
    
    CLLocationCoordinate2D nearLeft = CLLocationCoordinate2DMake(minLat, minLon);
    CLLocationCoordinate2D farRight = CLLocationCoordinate2DMake(maxLat, maxLon);
    
    [_delegate zoomMapToNearLeft:nearLeft
                        farRight:farRight];
}

@end
