//  NVColorWheel.m
//  CCodeLibrary

#import "NVColorWheel.h"
#import "NamedColors.h"

@interface NVColorWheel ()

@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) UIView *overlayView, *displayView;
@property (nonatomic) UILabel *colorNameLabel;
@property (nonatomic) UIButton *cancelButton, *saveButton;
@property (nonatomic) UIColor *pickedColor;
@property (nonatomic) NSString *pickedColorName;
@property (nonatomic) id item;
@property (nonatomic) NamedColors *namedColors;

@end

@implementation NVColorWheel

+ (NVColorWheel *)showColorWheelWithView:(UIView *)view
                              startColor:(UIColor *)startColor
                                delegate:(id)delegate
                                  tabBar:(UITabBar *)tabBar
                                     tag:(NSInteger)tag
{
    UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"colormap"
                                                                                    ofType:@"png"]];
    
    NVColorWheel *colorWheel = [[NVColorWheel alloc] initWithImage:image];
    colorWheel.namedColors = [[NamedColors alloc] init];
    
    UIScreen *screen = UIScreen.mainScreen;
    colorWheel.overlayView = [[UIView alloc] initWithFrame:screen.bounds];
    colorWheel.overlayView.backgroundColor = UIColor.blackColor;
    colorWheel.overlayView.alpha = 0.0;
    [view addSubview:colorWheel.overlayView];
    
    colorWheel.delegate = delegate;
    colorWheel.tabBar = tabBar;
    colorWheel.tag = tag;
    colorWheel.tabBar.userInteractionEnabled = NO;
    colorWheel.userInteractionEnabled = YES;
    colorWheel.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    colorWheel.center = CGPointMake(view.center.x, view.center.y +
                                    (colorWheel.tabBar.frame.size.height / 2.0));
    
    colorWheel.alpha = 0.0;
    [view addSubview:colorWheel];
    
    int index = [colorWheel.namedColors getNearestNamedColorIndex:startColor];
    colorWheel.pickedColor = [colorWheel.namedColors colorFromIndex:index];
    colorWheel.displayView.backgroundColor = colorWheel.pickedColor;
    
    colorWheel.displayView = [[UIView alloc] initWithFrame:CGRectMake((view.frame.size.width * 0.1),
                                                                      (view.frame.size.height * 0.04) ,
                                                                      (view.frame.size.width * 0.8),
                                                                      (view.frame.size.height * 0.08))];
    
    colorWheel.displayView.alpha = 0.0;
    colorWheel.displayView.layer.cornerRadius = 10.0;
    colorWheel.displayView.backgroundColor = [colorWheel.namedColors colorFromIndex:index];
    
    [view addSubview:colorWheel.displayView];
    
    colorWheel.colorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width * 0.1),
                                                                          (view.frame.size.height * 0.12) ,
                                                                          (view.frame.size.width * 0.8),
                                                                          (view.frame.size.height * 0.08))];
    
    colorWheel.pickedColorName = [colorWheel.namedColors colorNameFromIndex:index];
    
    colorWheel.colorNameLabel.alpha = 0.0;
    colorWheel.colorNameLabel.backgroundColor = UIColor.clearColor;
    colorWheel.colorNameLabel.text = colorWheel.pickedColorName.capitalizedString;
    colorWheel.colorNameLabel.textColor = UIColor.whiteColor;
    colorWheel.colorNameLabel.textAlignment = NSTextAlignmentCenter;
    colorWheel.colorNameLabel.adjustsFontSizeToFitWidth = YES;
    colorWheel.colorNameLabel.font = [UIFont boldSystemFontOfSize:48.0];
    
    [view addSubview:colorWheel.colorNameLabel];
    
    colorWheel.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((view.frame.size.width * 0.1),
                                                                         (view.frame.size.height * 0.85),
                                                                         (view.frame.size.width * 0.3),
                                                                         (view.frame.size.height * 0.06))];
    
    colorWheel.cancelButton.alpha = 0.0;
    colorWheel.cancelButton.layer.cornerRadius = 10.0;
    colorWheel.cancelButton.backgroundColor = UIColor.whiteColor;
    colorWheel.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [colorWheel.cancelButton setTitle:@"Cancel"
                             forState:UIControlStateNormal];
    
    [colorWheel.cancelButton setTitleColor:UIColor.blackColor
                                  forState:UIControlStateNormal];
    
    [colorWheel.cancelButton addTarget:colorWheel
                                action:@selector(cancelButtonSelected:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:colorWheel.cancelButton];
    
    colorWheel.saveButton = [[UIButton alloc] initWithFrame:CGRectMake((view.frame.size.width * 0.6),
                                                                       (view.frame.size.height * 0.85),
                                                                       (view.frame.size.width * 0.3),
                                                                       (view.frame.size.height * 0.06))];
    
    colorWheel.saveButton.alpha = 0.0;
    colorWheel.saveButton.layer.cornerRadius = 10.0;
    colorWheel.saveButton.backgroundColor = UIColor.whiteColor;
    colorWheel.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
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
                         colorWheel.overlayView.alpha = 0.7;
                         colorWheel.displayView.alpha = 1.0;
                         colorWheel.colorNameLabel.alpha = 1.0;
                         colorWheel.cancelButton.alpha = 1.0;
                         colorWheel.saveButton.alpha = 1.0;
                         colorWheel.tabBar.alpha = 0.3;
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
    
    _displayView.backgroundColor = [_namedColors colorFromIndex:index];
    _pickedColorName = [_namedColors colorNameFromIndex:index];
    _colorNameLabel.text = _pickedColorName.capitalizedString;
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    _pickedColor = [self colorOfPoint:loc];
    int index = [_namedColors getNearestNamedColorIndex:_pickedColor];
    
    _displayView.backgroundColor = [_namedColors colorFromIndex:index];
    _pickedColorName = [_namedColors colorNameFromIndex:index];
    _colorNameLabel.text = _pickedColorName.capitalizedString;
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self];
    _pickedColor = [self colorOfPoint:loc];
    int index = [_namedColors getNearestNamedColorIndex:_pickedColor];
    
    _displayView.backgroundColor = [_namedColors colorFromIndex:index];
    _pickedColorName = [_namedColors colorNameFromIndex:index];
    _colorNameLabel.text = _pickedColorName.capitalizedString;
}

- (void)hideColorWheel:(BOOL)animated
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                         _overlayView.alpha = 0.0;
                         _displayView.alpha = 0.0;
                         _colorNameLabel.alpha = 0.0;
                         _cancelButton.alpha = 0.0;
                         _saveButton.alpha = 0.0;
                         _tabBar.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         _tabBar.userInteractionEnabled = YES;
                         [_overlayView removeFromSuperview];
                         [_displayView removeFromSuperview];
                         [_colorNameLabel removeFromSuperview];
                         [_saveButton removeFromSuperview];
                         [_cancelButton removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

@end