//  NVColorWheel.m
//  CCodeLibrary

#import "NVColorWheel.h"
#import "NamedColors.h"

@interface NVColorWheel ()

@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIView *overlayView, *displayView, *pickedColorView;
@property (nonatomic) UILabel *colorNameLabel;
@property (nonatomic) UIButton *cancelButton, *saveButton;
@property (nonatomic) UIColor *pickedColor;
@property (nonatomic) NSString *pickedColorName;
@property (nonatomic) id item;
@property (nonatomic) NamedColors *namedColors;
@property (nonatomic) CGFloat displayViewTop;

@end

@implementation NVColorWheel

+ (NVColorWheel *)showColorWheelWithView:(UIView *)view
                              startColor:(UIColor *)startColor
                                delegate:(id)delegate
                                  tabBar:(UITabBar *)tabBar
                                     tag:(NSInteger)tag
{
    CGFloat cornerRadius = 10.0;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"colormap"
                                                                                    ofType:@"png"]];
    
    NVColorWheel *colorWheel = [[NVColorWheel alloc] initWithImage:image];
    colorWheel.namedColors = [[NamedColors alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    colorWheel.overlayView = [[UIView alloc] initWithFrame:bounds];
    
    colorWheel.overlayView.backgroundColor = [UIColor colorWithRed:0.2
                                                             green:0.2
                                                              blue:0.2
                                                             alpha:1.0];
    
    colorWheel.overlayView.alpha = 0.0;
    [view addSubview:colorWheel.overlayView];
    
    colorWheel.delegate = delegate;
    colorWheel.tabBar = tabBar;
    colorWheel.tag = tag;
    colorWheel.displayViewTop = 32.0;
    colorWheel.tabBar.userInteractionEnabled = NO;
    colorWheel.userInteractionEnabled = YES;
    colorWheel.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    colorWheel.center = CGPointMake(view.center.x, view.center.y +
                                    (colorWheel.tabBar.frame.size.height / 2.0));
    
    colorWheel.alpha = 0.0;
    [view addSubview:colorWheel];
    
    int index = [colorWheel.namedColors getNearestNamedColorIndex:startColor];
    colorWheel.pickedColor = [colorWheel.namedColors colorFromIndex:index];
    
    CGRect displayViewFrame, pickedColorViewFrame, colorNameLabelFrame;
    
    if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
        UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        displayViewFrame = CGRectMake((view.frame.size.width * 0.1), colorWheel.displayViewTop,
                                      (view.frame.size.width * 0.8), (view.frame.size.height * 0.1));
        
        pickedColorViewFrame = CGRectMake(0.0, 0.0,
                                          (displayViewFrame.size.width * 0.5),
                                          displayViewFrame.size.height);
        
        colorNameLabelFrame = CGRectMake((displayViewFrame.size.width * 0.5), 0.0,
                                         (displayViewFrame.size.width * 0.5),
                                         displayViewFrame.size.height);
    }
    
    else
    {
        displayViewFrame = CGRectMake((view.frame.size.width * 0.1), colorWheel.displayViewTop,
                                      (view.frame.size.width * 0.8), (view.frame.size.height * 0.2));
        
        pickedColorViewFrame = CGRectMake(0.0, 0.0,
                                          displayViewFrame.size.width,
                                          (displayViewFrame.size.height * 0.5));
        
        colorNameLabelFrame = CGRectMake(0.0, (displayViewFrame.size.height * 0.5),
                                         displayViewFrame.size.width,
                                         (displayViewFrame.size.height * 0.5));
    }
    
    colorWheel.displayView = [[UIView alloc] initWithFrame:displayViewFrame];
    
    colorWheel.displayView.alpha = 0.0;
    colorWheel.displayView.backgroundColor = UIColor.blackColor;
    
    [view addSubview:colorWheel.displayView];
    
    colorWheel.pickedColorView = [[UIView alloc] initWithFrame:pickedColorViewFrame];
    
    colorWheel.pickedColorView.backgroundColor = [colorWheel.namedColors colorFromIndex:index];
    
    [colorWheel.displayView addSubview:colorWheel.pickedColorView];
    
    colorWheel.colorNameLabel = [[UILabel alloc] initWithFrame:colorNameLabelFrame];
    
    colorWheel.pickedColorName = [colorWheel.namedColors colorNameFromIndex:index];
    
    colorWheel.colorNameLabel.backgroundColor = UIColor.blackColor;
    colorWheel.colorNameLabel.text = colorWheel.pickedColorName;
    colorWheel.colorNameLabel.textColor = UIColor.whiteColor;
    colorWheel.colorNameLabel.textAlignment = NSTextAlignmentCenter;
    colorWheel.colorNameLabel.adjustsFontSizeToFitWidth = YES;
    colorWheel.colorNameLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [colorWheel.displayView addSubview:colorWheel.colorNameLabel];
    
    colorWheel.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((bounds.size.width * 0.1),
                                                                         (bounds.size.height * 0.88),
                                                                         (bounds.size.width * 0.35),
                                                                         (bounds.size.height * 0.08))];
    
    colorWheel.cancelButton.alpha = 0.0;
    colorWheel.cancelButton.layer.cornerRadius = cornerRadius;
    colorWheel.cancelButton.backgroundColor = UIColor.whiteColor;
    colorWheel.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [colorWheel.cancelButton setTitle:@"Cancel"
                             forState:UIControlStateNormal];
    
    [colorWheel.cancelButton setTitleColor:UIColor.blackColor
                                  forState:UIControlStateNormal];
    
    [colorWheel.cancelButton addTarget:colorWheel
                                action:@selector(cancelButtonSelected:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:colorWheel.cancelButton];
    
    colorWheel.saveButton = [[UIButton alloc] initWithFrame:CGRectMake((bounds.size.width * 0.6),
                                                                       (bounds.size.height * 0.88),
                                                                       (bounds.size.width * 0.35),
                                                                       (bounds.size.height * 0.08))];
    
    colorWheel.saveButton.alpha = 0.0;
    colorWheel.saveButton.layer.cornerRadius = cornerRadius;
    colorWheel.saveButton.backgroundColor = UIColor.whiteColor;
    colorWheel.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [colorWheel.saveButton setTitle:@"Save"
                             forState:UIControlStateNormal];
    
    [colorWheel.saveButton setTitleColor:UIColor.blackColor
                                  forState:UIControlStateNormal];
    
    [colorWheel.saveButton addTarget:colorWheel
                              action:@selector(saveButtonSelected:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:colorWheel.saveButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         colorWheel.alpha = 1.0;
                         colorWheel.overlayView.alpha = 1.0;
                         colorWheel.displayView.alpha = 1.0;
                         colorWheel.cancelButton.alpha = 1.0;
                         colorWheel.saveButton.alpha = 1.0;
                         colorWheel.tabBar.alpha = 0.0;
                     }];
    
    return colorWheel;
}

- (void)cancelButtonSelected:(UIButton *)button
{
    if (_delegate)
        [_delegate colorWheelDidCancel:self];
}

- (void)saveButtonSelected:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate colorWheel:self
               didReturnColor:_pickedColor
                          tag:self.tag];
    }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    _pickedColor = [self colorOfPoint:loc];
    
    int index = [_namedColors getNearestNamedColorIndex:_pickedColor];
    
    _pickedColorView.backgroundColor = [_namedColors colorFromIndex:index];
    _pickedColorName = [_namedColors colorNameFromIndex:index];
    _colorNameLabel.text = _pickedColorName;
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    _pickedColor = [self colorOfPoint:loc];
    int index = [_namedColors getNearestNamedColorIndex:_pickedColor];
    
    _pickedColorView.backgroundColor = [_namedColors colorFromIndex:index];
    _pickedColorName = [_namedColors colorNameFromIndex:index];
    _colorNameLabel.text = _pickedColorName;
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    _pickedColor = [self colorOfPoint:loc];
    int index = [_namedColors getNearestNamedColorIndex:_pickedColor];
    
    _pickedColorView.backgroundColor = [_namedColors colorFromIndex:index];
    _pickedColorName = [_namedColors colorNameFromIndex:index];
    _colorNameLabel.text = _pickedColorName;
}

- (void)hideColorWheel:(BOOL)animated
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                         _overlayView.alpha = 0.0;
                         _displayView.alpha = 0.0;
                         _cancelButton.alpha = 0.0;
                         _saveButton.alpha = 0.0;
                         _tabBar.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         _tabBar.userInteractionEnabled = YES;
                         [_overlayView removeFromSuperview];
                         [_displayView removeFromSuperview];
                         [_saveButton removeFromSuperview];
                         [_cancelButton removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         UIScreen *screen = UIScreen.mainScreen;
                         _overlayView.frame = CGRectMake(0.0, 0.0, screen.bounds.size.height,
                                                         screen.bounds.size.width);
                         
                         self.center = CGPointMake((self.superview.center.y + (_tabBar.frame.size.height / 2.0)),
                                                   self.superview.center.x);
                         
                         _cancelButton.frame = CGRectMake((bounds.size.height * 0.1),
                                                          (bounds.size.width * 0.88),
                                                          (bounds.size.height * 0.35),
                                                          (bounds.size.width * 0.08));
                         
                         _saveButton.frame = CGRectMake((bounds.size.height * 0.6),
                                                        (bounds.size.width * 0.88),
                                                        (bounds.size.height * 0.35),
                                                        (bounds.size.width * 0.08));
                     }];
    
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [UIView animateWithDuration:duration
                         animations:^{
                             _displayView.frame = CGRectMake(bounds.size.height * 0.1,
                                                             _displayViewTop, (bounds.size.height * 0.8),
                                                             (bounds.size.width * 0.1));
                             
                             _pickedColorView.frame = CGRectMake(0.0, 0.0,
                                                                 _displayView.frame.size.width * 0.5,
                                                                 _displayView.frame.size.height);
                             
                             _colorNameLabel.frame = CGRectMake((_displayView.frame.size.width * 0.5), 0.0,
                                                                _displayView.frame.size.width * 0.5,
                                                                _displayView.frame.size.height);
                         }];
    }
    
    else
    {
        [UIView animateWithDuration:duration
                         animations:^{
                             _displayView.frame = CGRectMake(bounds.size.height * 0.1,
                                                             _displayViewTop, (bounds.size.height * 0.8),
                                                             (bounds.size.width * 0.2));
                             
                             _pickedColorView.frame = CGRectMake(0.0, 0.0,
                                                                 _displayView.frame.size.width,
                                                                 _displayView.frame.size.height * 0.5);
                             
                             _colorNameLabel.frame = CGRectMake(0.0,
                                                                (_displayView.frame.size.height * 0.5),
                                                                _displayView.frame.size.width,
                                                                (_displayView.frame.size.height * 0.5));
                         }];
    }
}

@end