//  NVPhotoController.m
//  CCodeLibrary

#import "NVPhotoController.h"
#import "CRAPI.h"
#import "NVColor.h"

@interface NVPhoto ()

@property (nonatomic, copy) NSString *identifier, *key;

@end

@implementation NVPhoto

+ (instancetype)photoWithIdentifier:(NSString *)identifier
                                key:(NSString *)key
{
    NVPhoto *nvp = NVPhoto.new;
    nvp.identifier = identifier;
    nvp.key = key;
    return nvp;
}

@end

@interface NVPhotoController ()

@property (nonatomic, weak) id <NVPhotoControllerDelegate> delegate;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSArray *photosArray;
@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UIImageView *photoView;
@property NSInteger imageIndex;
@property (nonatomic) UILabel *photoLabel, *titleLabel;

@end

@implementation NVPhotoController

+ (instancetype)photoControllerWithNVPhotosArray:(NSArray *)photosArray
                                        delegate:(id)delegate
                                           title:(NSString *)title
{
    if (!photosArray.count || !delegate)
        return nil;
    
    NVPhotoController *nvpc = NVPhotoController.new;
    nvpc.delegate = delegate;
    nvpc.titleString = title;
    nvpc.photosArray = photosArray;
    return nvpc;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    CGFloat viewHeight = 60.0, margin = 20.0;
    UIFont *font = [UIFont boldSystemFontOfSize:40.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        viewHeight = 40.0, margin = 8.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.lightGrayColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_returnButton constrainTopToAnchor:self.view.topAnchor];
    [_returnButton constrainHeightToConstant:viewHeight];
    
    _titleLabel = UILabel.new;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.backgroundColor = UIColor.clearColor;
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.font = font;
    _titleLabel.text = _titleString;
    
    [self.view addSubview:_titleLabel];
    [_titleLabel constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_titleLabel constrainTopToAnchor:_returnButton.bottomAnchor];
    [_titleLabel constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_titleLabel constrainHeightToConstant:viewHeight];
    
    _photoLabel = UILabel.new;
    _photoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _photoLabel.backgroundColor = UIColor.clearColor;
    _photoLabel.textColor = UIColor.whiteColor;
    _photoLabel.textAlignment = NSTextAlignmentCenter;
    _photoLabel.adjustsFontSizeToFitWidth = YES;
    _photoLabel.font = font;
    
    [self.view addSubview:_photoLabel];
    [_photoLabel constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_photoLabel constrainBottomToAnchor:self.view.bottomAnchor];
    [_photoLabel constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_photoLabel constrainHeightToConstant:viewHeight];
    
    _photoView = UIImageView.new;
    _photoView.translatesAutoresizingMaskIntoConstraints = NO;
    _photoView.contentMode = UIViewContentModeScaleAspectFit;
    _photoView.userInteractionEnabled = YES;
    _imageIndex = 0;
    
    [self.view addSubview:_photoView];
    [_photoView constrainLeadingToAnchor:self.view.leadingAnchor];
    [_photoView constrainTopToAnchor:_titleLabel.bottomAnchor];
    [_photoView constrainBottomToAnchor:_photoLabel.topAnchor];
    [_photoView constrainTrailingToAnchor:self.view.trailingAnchor];
    
    if (_photosArray.count > 1)
    {
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(imageLeftSwiped:)];
        
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        [_photoView addGestureRecognizer:leftSwipe];
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(imageRightSwiped:)];
        
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [_photoView addGestureRecognizer:rightSwipe];
    }
    
    [self updateImage];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)returnButtonTapped:(UIButton *)button
{
    CRAPI.sharedInstance.refreshMap = YES;
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imageLeftSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == (_photosArray.count - 1))
        _imageIndex = 0;
    
    else
        _imageIndex++;
    
    [self updateImage];
}

- (void)imageRightSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == 0)
        _imageIndex = (_photosArray.count - 1);
    
    else
        _imageIndex--;
    
    [self updateImage];
}

- (void)updateImage
{
    if (_photosArray.count)
    {
        NVPhoto *nvp = (NVPhoto *)_photosArray[_imageIndex];
        
        _photoView.image = [UIImage imageWithContentsOfFile:[_delegate getImagePath:self
                                                                             forKey:nvp.key]];
        
        _photoLabel.text = [NSString stringWithFormat:@"%@ (%i of %lu)",
                            nvp.identifier, (_imageIndex + 1), (unsigned long)_photosArray.count];
    }
    
    else
        _photoLabel.text = @"No photos exist for this item";
}

@end

@interface NVPhotoView ()

@property (nonatomic, weak) id <NVPhotoViewDelegate> delegate;
@property (nonatomic, copy) NSArray *photosArray;
@property (nonatomic) CGSize size;
@property CGFloat currentScale;
@property NSInteger imageIndex;
@property BOOL isDragged;

@end

@implementation NVPhotoView

+ (instancetype)showPhotoViewWithNVPhotosArray:(NSArray *)photosArray
                                        inView:(UIView *)view
                               constrainToView:(UIView *)constrainedView
                                      delegate:(id)delegate
                                    coordinate:(CLLocationCoordinate2D)coordinate
{
    if (!photosArray.count || !delegate)
        return nil;
    
    NVPhotoView *nvpv = NVPhotoView.new;
    nvpv.userInteractionEnabled = YES;
    nvpv.layer.cornerRadius = 10.0;
    nvpv.layer.masksToBounds = YES;
    nvpv.layer.borderColor = UIColor.whiteColor.CGColor;
    nvpv.layer.borderWidth = 1.0;
    nvpv.alpha = 0.0;
    nvpv.delegate = delegate;
    nvpv.coordinate = coordinate;
    nvpv.photosArray = photosArray;
    nvpv.imageIndex = 0;
    nvpv.isDragged = NO;
    
    nvpv.overlay = NVPhotoViewOverlay.new;
    nvpv.overlay.translatesAutoresizingMaskIntoConstraints = NO;
    nvpv.overlay.backgroundColor = UIColor.clearColor;
    nvpv.overlay.userInteractionEnabled = NO;
    nvpv.overlay.alpha = 0.0;
    
    [view addSubview:nvpv.overlay];
    [nvpv.overlay constrainToView:constrainedView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:nvpv
                                                                                    action:@selector(insetImageLeftSwiped:)];
    
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [nvpv addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:nvpv
                                                                                     action:@selector(insetImageRightSwiped:)];
    
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [nvpv addGestureRecognizer:rightSwipe];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:nvpv
                                                                          action:@selector(insetImagePanned:)];
    
    [pan requireGestureRecognizerToFail:rightSwipe];
    [pan requireGestureRecognizerToFail:leftSwipe];
    
    [nvpv addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:nvpv
                                                                                action:@selector(insetImagePinched:)];
    
    [nvpv addGestureRecognizer:pinch];
    nvpv.currentScale = pinch.scale;
    
    [nvpv updateInsetImage];
    [nvpv updateSize];
    [nvpv updatePosition];
    
    [view addSubview:nvpv];
    
    nvpv.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nvpv.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    nvpv.deleteButton.imageEdgeInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
    
    [nvpv.deleteButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"transWhiteX"
                                                                                               ofType:@"png"]]
                       forState:UIControlStateNormal];
    
    [nvpv addSubview:nvpv.deleteButton];
    [nvpv.deleteButton constrainLeadingToAnchor:nvpv.trailingAnchor constant:-40.0];
    [nvpv.deleteButton constrainTrailingToAnchor:nvpv.trailingAnchor];
    [nvpv.deleteButton constrainTopToAnchor:nvpv.topAnchor];
    [nvpv.deleteButton constrainBottomToAnchor:nvpv.topAnchor constant:40.0];
    
    [nvpv.deleteButton addTarget:nvpv
                          action:@selector(deleteButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [nvpv.delegate didAddPhotoView];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvpv.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         nvpv.overlay.alpha = 0.6;
                     }];
    
    return nvpv;
}

- (void)hidePhotoView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                             _overlay.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [_overlay removeFromSuperview];
                         }];
    }
    
    else
    {
        [self removeFromSuperview];
        [_overlay removeFromSuperview];
    }
    
    [_delegate didDeletePhotoView:self];
}

- (void)updateSize
{
    CGFloat aspectRatio = (self.image.size.height / self.image.size.width);
    CGFloat width = 264.0;
    _size = CGSizeMake(width, (aspectRatio * width));
}

- (void)updatePosition
{
    CGSize scaledSize = CGSizeMake(_size.width * _currentScale, _size.height * _currentScale);
    
    self.frame = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    CGPoint coordPoint = [_delegate getPointForCoordinate:_coordinate];
    CGFloat offset = [_delegate getVerticalOffset];
    CGFloat statusBarHeight = [_delegate getStatusBarHeight];
    
    self.center = CGPointMake(coordPoint.x, (coordPoint.y + statusBarHeight - offset - (scaledSize.height / 2.0)));
    
    [self updateOverlayPosition:coordPoint];
}

- (void)updateOverlayPosition:(CGPoint)coordPoint
{
    _overlay.startPoint = coordPoint;
    _overlay.endPoint = CGPointApplyAffineTransform(self.center, self.transform);
    
    [_overlay setNeedsDisplay];
}

- (void)insetImageLeftSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == (_photosArray.count - 1))
        _imageIndex = 0;
    
    else
        _imageIndex++;
    
    [self updateInsetImage];
}

- (void)insetImageRightSwiped:(UISwipeGestureRecognizer *)gesture
{
    if (_imageIndex == 0)
        _imageIndex = (_photosArray.count - 1);
    
    else
        _imageIndex--;
    
    [self updateInsetImage];
}

- (void)insetImagePanned:(UIPanGestureRecognizer *)gesture
{
    CGPoint coordPoint = [_delegate getPointForCoordinate:_coordinate];
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (CGRectContainsPoint(gesture.view.frame, coordPoint))
        {
            gesture.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
            _isDragged = NO;
            [self updatePosition];
        }
        
        else
            _isDragged = YES;
    }
    
    else
    {
        CGPoint point = [gesture translationInView:gesture.view];
        CGAffineTransform translate = CGAffineTransformTranslate(gesture.view.transform, point.x, point.y);
        gesture.view.transform = translate;
        
        [gesture setTranslation:CGPointZero
                         inView:gesture.view];
        
        [self updateOverlayPosition:coordPoint];
    }
}

- (void)insetImagePinched:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
        gesture.scale = _currentScale;
    
    else
    {
        _currentScale = gesture.scale;
        [self updatePosition];
    }
}

- (void)updateInsetImage
{
    NVPhoto *nvp = (NVPhoto *)_photosArray[_imageIndex];
    
    self.image = [UIImage imageWithContentsOfFile:[_delegate getInsetImagePath:self
                                                                        forKey:nvp.key]];
    
    [self updateSize];
    [self updatePosition];
}

- (void)deleteButtonTapped:(UIButton *)button
{
    [self hidePhotoView:YES];
}

@end

@implementation NVPhotoViewOverlay

- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = 4.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, _startPoint.x , _startPoint.y);
    CGContextAddLineToPoint(context, _endPoint.x, _endPoint.y);
    
    for (int i = 1; i < 9; i++)
    {
        CGContextMoveToPoint(context, _startPoint.x , _startPoint.y);
        CGContextAddLineToPoint(context, (_endPoint.x - (i * lineWidth)), _endPoint.y);
        CGContextMoveToPoint(context, _startPoint.x , _startPoint.y);
        CGContextAddLineToPoint(context, (_endPoint.x + (i * lineWidth)), _endPoint.y);
        CGContextMoveToPoint(context, _startPoint.x , _startPoint.y);
        CGContextAddLineToPoint(context, _endPoint.x, (_endPoint.y - (i * lineWidth)));
        CGContextMoveToPoint(context, _startPoint.x , _startPoint.y);
        CGContextAddLineToPoint(context, _endPoint.x, (_endPoint.y + (i * lineWidth)));
    }
    
    CGContextSetStrokeColorWithColor(context, NVColor.goldenrodColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokePath(context);
}

@end
