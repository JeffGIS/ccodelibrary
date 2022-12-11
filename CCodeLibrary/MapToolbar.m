//  MapToolbar.m
//  GMMobile

#import "MapToolbar.h"
#import "UserDefaults.h"
#import "NVColor.h"

@interface MapToolbar ()

@property (nonatomic) UIButton *extentsButton, *userLocationButton, *legendsButton, *digitizeButton, *mapTypeButton;
@property (nonatomic) UIButton *grayscaleButton, *clearMarkerButton, *emailPDFButton, *helpButton, *returnButton, *weatherButton;
@property (nonatomic) UISegmentedControl *mapTypeSC, *platSC;
@property (nonatomic) CGSize size;
@property BOOL configChanged, myLocationEnabled, platOverride;
@property (nonatomic) CGFloat buttonSize, switchHeight, switchWidth, SCHeight, mapTypeSCWidth, cornerRad, bordWidth;
@property (nonatomic) CGFloat buttonMargin, switchMargin, SCMargin, platSCWidth, platSCVertWidth, progressMargin;
@property (nonatomic) UIProgressView *progressView;
//@property (nonatomic) NSTimer *helpBackgroundToggleTimer;
@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic) CGFloat indicatorSize;

@end

@implementation MapToolbar
{
    BOOL _previousConfig[NUMMapToolbarProperty];
}

+ (MapToolbar *)showMapToolbarWithCenter:(CGPoint)center
                                    view:(UIView *)view
                                delegate:(id)delegate;
{
    if (!delegate || !view)
    {
        NSLog(@"NVRampTypePageView ERROR:Cannot set delegate or view to nil");
        return nil;
    }
    
    int nButtons=0;
    
    MapToolbar *mt = [[MapToolbar alloc] init];
    mt.configChanged = mt.myLocationEnabled = mt.platOverride = mt.helpLongPressed = NO;
    mt.isOffset = mt.showIndicator = mt.applyRotation = NO;
    mt.indicatorSize = 44.0, mt.legendOffset = 0.0;
    
    //set default configuration
    [mt setConfigurationProperty:MapToolbarPropertyWantUserLocation value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantExtents value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantGrayscale value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantClearMarkers value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantEmailPDF value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantProgressBar value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantHelpButton value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantPlat value:NO];
    [mt setConfigurationProperty:MapToolbarPropertyWantDigitize value:NO];
    [mt setConfigurationProperty:MapToolbarPropertyWantMapType value:NO];
    [mt setConfigurationProperty:MapToolbarPropertyWantMapTypeButton value:YES];
    [mt setConfigurationProperty:MapToolbarPropertyWantLegends value:NO];
    [mt setConfigurationProperty:MapToolbarPropertyWantReturnButton value:NO];
    [mt setConfigurationProperty:MapToolbarPropertyWantWeatherButton value:NO];

    //set internal sizes for all devices
    mt.buttonSize = 47.0, mt.SCHeight = 29.0, mt.mapTypeSCWidth = 76.0;
    mt.buttonMargin = 8.0, mt.switchMargin = 16.0, mt.SCMargin = 17.0, mt.platSCWidth = 196.0;
    mt.platSCVertWidth = 112.0, mt.cornerRad = 10.0, mt.progressMargin = 10.0, mt.bordWidth = 2.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        //reset internal sizes for iPhone
        mt.buttonSize = 38.0, mt.buttonMargin = 2.0, mt.SCMargin = 8.5, mt.progressMargin = 4.0;
        mt.mapTypeSCWidth = 60.0, mt.platSCWidth = 166.0, mt.cornerRad = 4.0, mt.bordWidth = 1.0;
    }
    
    //set default size for all devices
    mt.size = CGSizeMake(((mt.buttonSize * 5.0) + (mt.buttonMargin * 6.0)),
                         ((mt.buttonSize + (mt.buttonMargin * 2.0) + mt.progressMargin)));
    
    mt.backgroundColor = UserDefaults.defaults.appleBlue;
    mt.frame = CGRectMake(0.0, 0.0, mt.size.width, mt.size.height);
    mt.center = center;
    mt.layer.borderWidth = mt.bordWidth;
    mt.layer.borderColor = UIColor.blackColor.CGColor;
    mt.delegate = delegate;
    mt.orientation = MapToolbarOrientationBottom;
    mt.previousOrientation = MapToolbarOrientationDefault;
    mt.previousFrame = CGRectZero;
    
    [view addSubview:mt];
    
    //add user location button added by default
    mt.userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    mt.userLocationButton.frame = CGRectMake(mt.buttonMargin, mt.buttonMargin,
                                             mt.buttonSize, mt.buttonSize);
    nButtons++;
    [mt setupButton:mt.userLocationButton
         imageTitle:@"userLocation"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(userLocationSelected:)];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                            action:@selector(userLocationLongPressed:)];
    
    [mt.userLocationButton addGestureRecognizer:longPress];
    [mt addSubview:mt.userLocationButton];

    //add map type button added by default
    mt.mapTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect;
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
            mt.buttonMargin,mt.buttonSize, mt.buttonSize);
    mt.mapTypeButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.mapTypeButton
         imageTitle:@"update"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(mapTypeButtonSelected:)];
    [mt addSubview:mt.mapTypeButton];
   
   //add extents button added by default
    mt.extentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
                      mt.buttonMargin, mt.buttonSize, mt.buttonSize);
    mt.extentsButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.extentsButton
         imageTitle:@"zoom"
         edgeInsets:UIEdgeInsetsMake(-2.0, -2.0, -2.0, -2.0)
           selector:@selector(extentsSelected:)];
    
    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                            action:@selector(extentsLongPressed:)];
    
    [mt.extentsButton addGestureRecognizer:lpGesture];
    [mt addSubview:mt.extentsButton];
    
    //grayscale button added by default
    mt.grayscaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
                      mt.buttonMargin, mt.buttonSize, mt.buttonSize);

    mt.grayscaleButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.grayscaleButton
         imageTitle:@"grayscale"
         edgeInsets:UIEdgeInsetsZero
           selector:@selector(grayscaleSelected:)];
    
    [mt addSubview:mt.grayscaleButton];
    
    //clear marker button added by default
    mt.clearMarkerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
                      mt.buttonMargin, mt.buttonSize, mt.buttonSize);

    mt.clearMarkerButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.clearMarkerButton
         imageTitle:@"clearMarkers"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(clearMarkersSelected:)];
    
    [mt addSubview:mt.clearMarkerButton];
    
    //weather button added by default
    mt.weatherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
                      mt.buttonMargin, mt.buttonSize, mt.buttonSize);

    mt.weatherButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.weatherButton
         imageTitle:@"weather"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(weatherButtonSelected:)];
    UILongPressGestureRecognizer *longWeatherPress = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                            action:@selector(weatherButtonLongPressed:)];
    
    [mt.weatherButton addGestureRecognizer:longWeatherPress];
 
    [mt addSubview:mt.weatherButton];
    
    //email PDF button added by default
    mt.emailPDFButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
                      mt.buttonMargin, mt.buttonSize, mt.buttonSize);

    mt.emailPDFButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.emailPDFButton
         imageTitle:@"emailIcon"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(emailPDFSelected:)];
    
    [mt addSubview:mt.emailPDFButton];
    
    //help button added by default
    mt.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rect = CGRectMake((mt.buttonSize*nButtons + (mt.buttonMargin * (nButtons+1))),
                      mt.buttonMargin, mt.buttonSize, mt.buttonSize);

    mt.helpButton.frame = rect;
    nButtons++;
    [mt setupButton:mt.helpButton
         imageTitle:@"questionMark"
         edgeInsets:UIEdgeInsetsMake(4.0, -2.0, 4.0, -2.0)
           selector:@selector(helpButtonSelected:)];
    
    /*UILongPressGestureRecognizer *helpLpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                                action:@selector(helpLongPressed:)];
    
    [mt.helpButton addGestureRecognizer:helpLpGesture];*/
    [mt addSubview:mt.helpButton];
    
    //progress view added by default
    mt.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(mt.buttonMargin, (mt.size.height - mt.progressMargin),
                                                                       (mt.size.width - (mt.buttonMargin * 2.0)), 4.0)];
    
    mt.progressView.trackTintColor = UIColor.darkGrayColor;
    mt.progressView.progressTintColor = UIColor.whiteColor;
    [mt addSubview:mt.progressView];
    
/*
    //map type SC is NOT added by default
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        mt.mapTypeSC = [[UISegmentedControl alloc] initWithItems:@[@"St", @"Hy"]];
    
    else
        mt.mapTypeSC = [[UISegmentedControl alloc] initWithItems:@[@"Stnd", @"Hybd"]];
    
    [mt setupSegControl:mt.mapTypeSC
   selectedSegmentIndex:0
               selector:@selector(mapTypeSelected:)];
*/
    //digitize button is NOT added by default
    mt.digitizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [mt setupButton:mt.digitizeButton
         imageTitle:@"plusSign"
         edgeInsets:UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)
           selector:@selector(digitizeSelected:)];
    
    //legends button is NOT added by default
    mt.legendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [mt setupButton:mt.legendsButton
         imageTitle:@"list"
         edgeInsets:UIEdgeInsetsZero
           selector:@selector(legendsSelected:)];
    
    //plat SC is NOT added by default
    mt.platSC = [[UISegmentedControl alloc] initWithItems:@[@"Map", @"Split", @"Tri", @"Plat"]];
    
    [mt setupSegControl:mt.platSC
   selectedSegmentIndex:MapViewScreenSettingFullscreen
               selector:@selector(splitScreenSettingSelected:)];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:mt
                                                                                 action:@selector(mapToolbarDragged:)];
    
    panGesture.delegate = mt;
    [mt addGestureRecognizer:panGesture];
    
    //return button is NOT added by default
    mt.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [mt setupButton:mt.returnButton
         imageTitle:nil
         edgeInsets:UIEdgeInsetsZero
           selector:@selector(returnButtonSelected:)];
    
    [mt.returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [mt.returnButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    mt.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    mt.returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    mt.returnButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    mt.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    mt.indicatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    mt.indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    mt.indicatorView.userInteractionEnabled = NO;
    mt.indicatorView.layer.cornerRadius = (mt.indicatorSize / 2.0);
    [view addSubview:mt.indicatorView];
    
    return mt;
}

- (void)setupButton:(UIButton *)button
         imageTitle:(NSString *)imageTitle
         edgeInsets:(UIEdgeInsets)edgeInsets
           selector:(SEL)selector
{
    button.imageEdgeInsets = edgeInsets;
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = _cornerRad;
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    button.layer.masksToBounds = YES;
    
    if (imageTitle && imageTitle.length)
    {
        [button setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageTitle
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    }
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [button addTarget:self
               action:@selector(buttonPressedDown:)
     forControlEvents:UIControlEventTouchDown];
}

- (void)buttonPressedDown:(UIButton *)button
{
    button.layer.borderColor = UIColor.darkGrayColor.CGColor;
    button.layer.borderWidth = (_bordWidth * 3.0);
}

- (void)setupSegControl:(UISegmentedControl *)segControl
   selectedSegmentIndex:(NSInteger)selectedSegmentIndex
               selector:(SEL)selector
{
    segControl.backgroundColor = UIColor.blackColor;
    segControl.tintColor = UIColor.whiteColor;
    segControl.layer.cornerRadius = 4.0;
    segControl.layer.borderColor = UIColor.blackColor.CGColor;
    segControl.layer.borderWidth = _bordWidth;
    segControl.layer.masksToBounds = YES;
    segControl.selectedSegmentIndex = selectedSegmentIndex;
    
    [segControl addTarget:self
                   action:selector
         forControlEvents:UIControlEventValueChanged];
}

- (void)userLocationSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    _myLocationEnabled = !_myLocationEnabled;
    _applyRotation = NO;
    
    if (_myLocationEnabled)
        _userLocationButton.backgroundColor = UIColor.greenColor;
    
    else
        _userLocationButton.backgroundColor = UIColor.whiteColor;
    
    [_delegate mapToolbarDidSelectUserLocation:_myLocationEnabled];
}

- (void)deselectMyLocationButton
{
    _userLocationButton.backgroundColor = UIColor.whiteColor;
    _myLocationEnabled = NO;
}
- (void)selectMyLocationButton:(BOOL)amCreatingTrackRoute
{
    if (amCreatingTrackRoute)
        _userLocationButton.backgroundColor = UIColor.redColor;
    else
        _userLocationButton.backgroundColor = UIColor.greenColor;
    _myLocationEnabled = YES;
}
- (void)mapTypeButtonSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    
    [_delegate mapToolbarDidToggleMapType];
}


- (void)extentsSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectZoomExtent];
}

- (void)extentsLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _extentsButton.layer.borderColor = UIColor.greenColor.CGColor;
        _extentsButton.layer.borderWidth = (_bordWidth * 3.0);
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _extentsButton.layer.borderColor = UIColor.blackColor.CGColor;
        _extentsButton.layer.borderWidth = _bordWidth;
    }
}

- (void)grayscaleSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectGrayscale];
}

- (void)clearMarkersSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectClearMarkers];
}

- (void)weatherButtonSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectWeatherButton:FALSE];
}
- (void)weatherButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
        [_delegate mapToolbarDidSelectWeatherButton:TRUE];
}

- (void)emailPDFSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectEmailPDF];
}

- (void)helpButtonSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    
    /*if (_helpLongPressed)
        [self endHBLongPressMode];
    else*/
    
    [_delegate mapToolbarDidSelectHelpButton];
}

- (void)returnButtonSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectReturnButton];
}

/*- (void)helpLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan && !_helpLongPressed)
    {
        _helpButton.layer.borderColor = UIColor.greenColor.CGColor;
        _helpButton.layer.borderWidth = (_bordWidth * 3.0);
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _helpButton.layer.borderColor = UIColor.blackColor.CGColor;
        _helpButton.layer.borderWidth = _bordWidth;
        
        if (_helpLongPressed)
            [self endHBLongPressMode];
        
        else
            [self beginHBLongPressMode];
    }
}

- (void)beginHBLongPressMode
{
    _helpLongPressed = YES;
    
    _helpBackgroundToggleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                  target:self
                                                                selector:@selector(toggleHelpBackground)
                                                                userInfo:nil
                                                                 repeats:YES];
}

- (void)endHBLongPressMode
{
    _helpLongPressed = NO;
    [_helpBackgroundToggleTimer invalidate];
    _helpButton.backgroundColor = UIColor.whiteColor;
}

- (void)toggleHelpBackground
{
    if (_helpButton.backgroundColor == UIColor.whiteColor)
        _helpButton.backgroundColor = UIColor.redColor;
    
    else
        _helpButton.backgroundColor = UIColor.whiteColor;
}*/

- (void)mapTypeSelected:(UISegmentedControl *)segControl
{
    [_delegate mapToolbarDidSelectMapType:segControl.selectedSegmentIndex];
}

- (void)digitizeSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectDigitize];
}

- (void)legendsSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = _bordWidth;
    [_delegate mapToolbarDidSelectLegends];
}

- (void)splitScreenSettingSelected:(UISegmentedControl *)segControl
{
    [_delegate mapToolbarDidSelectSplitScreenSetting:segControl.selectedSegmentIndex];
}

- (void)mapToolbarDragged:(UIPanGestureRecognizer *)gesture
{
    if (_orientation == MapToolbarOrientationMinimized)
        return;
    
    [self.superview bringSubviewToFront:self];
    
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            for (UIButton *buttons in self.subviews)
            {
                if ([buttons isKindOfClass:UIButton.class])
                {
                    buttons.layer.borderColor = UIColor.blackColor.CGColor;
                    buttons.layer.borderWidth = _bordWidth;
                }
            }
        }
        
        gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                          gesture.view.center.y + translation.y);
        
        [gesture setTranslation:CGPointZero
                         inView:self];
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
        [_delegate mapToolbarDidFinishDrag:[gesture locationInView:self.superview]
                                            superView:self.superview];
}

- (void)animateToVerticalOrientation
{
    CGFloat yCount = _buttonMargin, xCount = 0.0;
    
    if (_wantReturnButton)
    {
        _returnButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, (_buttonSize * 2.0));
        _returnButton.titleLabel.numberOfLines = 2;
        [_returnButton setTitle:@"<\nR"forState:UIControlStateNormal];
        yCount += (_buttonMargin + (_buttonSize * 2.0));
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantUserLocation)
    {
        _userLocationButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantExtents)
    {
        _extentsButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantLegends)
    {
        _legendsButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantDigitize)
    {
        _digitizeButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantGrayscale)
    {
        _grayscaleButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantClearMarkers)
    {
        _clearMarkerButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantEmailPDF)
    {
        _emailPDFButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantHelpButton)
    {
        _helpButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantMapType)
    {
        _mapTypeSC.frame = CGRectMake(_buttonMargin, yCount, _mapTypeSCWidth, _SCHeight);
        yCount += (_buttonMargin + _SCHeight);
        xCount = max(xCount, (_buttonMargin * 2.0) + _mapTypeSCWidth);
    }
    
    if (_wantMapTypeButton)
    {
        _mapTypeButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantWeatherButton)
    {
        _weatherButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
        yCount += (_buttonMargin + _buttonSize);
        xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
    }
    
    if (_wantPlat)
    {
        _platSC.frame = CGRectMake(_buttonMargin, yCount, _platSCVertWidth, _SCHeight);
        yCount += (_buttonMargin + _SCHeight);
        xCount = max(xCount, (_buttonMargin * 2.0) + _platSCVertWidth);
    }
    
    if (yCount < 20.0)
        yCount = 0.0;
    
    self.frame = CGRectMake(0.0, 0.0, xCount, yCount);
    
    if (_wantProgressBar)
    {
        self.frame = CGRectMake(0.0, 0.0, xCount, (yCount + _progressMargin));
        
        _progressView.frame = CGRectMake(_buttonMargin, (self.frame.size.height - _progressMargin),
                                         (self.frame.size.width - (_buttonMargin * 2.0)),
                                         _progressView.frame.size.height);
    }
    
    for (UIView *views in self.subviews)
        views.center = CGPointMake(self.center.x, views.center.y);
    
    [_platSC setTitle:@"M" forSegmentAtIndex:0];
    [_platSC setTitle:@"S" forSegmentAtIndex:1];
    [_platSC setTitle:@"T" forSegmentAtIndex:2];
    [_platSC setTitle:@"P" forSegmentAtIndex:3];
}

- (void)animateToHorizontalOrientation
{
    CGFloat xCount = _buttonMargin;
    
    if (_wantReturnButton)
    {
        _returnButton.frame = CGRectMake(xCount, _buttonMargin, (_buttonSize * 3.0), _buttonSize);
        _returnButton.titleLabel.numberOfLines = 1;
        [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
        xCount += (_buttonMargin + (_buttonSize * 3.0));
    }
    
    if (_wantUserLocation)
    {
        _userLocationButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantExtents)
    {
        _extentsButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantLegends)
    {
        _legendsButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantDigitize)
    {
        _digitizeButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantGrayscale)
    {
        _grayscaleButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantClearMarkers)
    {
        _clearMarkerButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantEmailPDF)
    {
        _emailPDFButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantHelpButton)
    {
        _helpButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }
    
    if (_wantMapTypeButton)
    {
        _mapTypeButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }

    if (_wantWeatherButton)
    {
        _weatherButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
        xCount += (_buttonMargin + _buttonSize);
    }

    if (_wantMapType)
    {
        _mapTypeSC.frame = CGRectMake(xCount, _SCMargin, _mapTypeSCWidth, _SCHeight);
        xCount += (_buttonMargin + _mapTypeSCWidth);
    }
    
    if (_wantPlat)
    {
        _platSC.frame = CGRectMake(xCount, _SCMargin, _platSCWidth, _SCHeight);
        xCount += (_buttonMargin + _platSCWidth);
    }
    
    if (xCount < 20.0)
        xCount = 0.0;
    
    self.frame = CGRectMake((self.center.x - (xCount / 2.0)),
                                (self.center.y - (_size.height / 2.0)), xCount, _size.height);
    
    if (_wantProgressBar)
    {
        _progressView.frame = CGRectMake(_buttonMargin, (self.frame.size.height - _progressMargin),
                                         (self.frame.size.width - (_buttonMargin * 2.0)),
                                         _progressView.frame.size.height);
    }
    
    [_platSC setTitle:@"Map" forSegmentAtIndex:0];
    [_platSC setTitle:@"Split" forSegmentAtIndex:1];
    [_platSC setTitle:@"Tri" forSegmentAtIndex:2];
    [_platSC setTitle:@"Plat" forSegmentAtIndex:3];
}

- (void)splitScreenSelectedSegmentIndex:(NSInteger)index
{
    _platSC.selectedSegmentIndex = index;
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight
               statusBarHeight:(CGFloat)statusBarHeight
{
    CGRect superviewFrame = self.superview.frame;
    CGFloat offset = 0.0;
    
    if (_isOffset)
        offset = _legendOffset;
    
    switch (_orientation)
    {
        case MapToolbarOrientationTop:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.center = CGPointMake((((superviewFrame.size.height + tabBarHeight) - offset) / 2.0),
                                                           (statusBarHeight + (self.frame.size.height / 2.0)));
                                 
                             }];
        }
            break;
            
        case MapToolbarOrientationBottom:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.center = CGPointMake((((superviewFrame.size.height + tabBarHeight) - offset) / 2.0),
                                                           ((superviewFrame.size.width - tabBarHeight) -
                                                            (self.frame.size.height / 2.0)));
                             }];
        }
            break;
            
        case MapToolbarOrientationLeft:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.center = CGPointMake((self.frame.size.width / 2.0),
                                                           ((superviewFrame.size.width - tabBarHeight) / 2.0));
                             }];
        }
            break;
            
        case MapToolbarOrientationRight:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.center = CGPointMake((((superviewFrame.size.height + tabBarHeight) - offset) -
                                                            (self.frame.size.width / 2.0)),
                                                           ((superviewFrame.size.width - tabBarHeight) / 2.0));
                             }];
        }
            break;
            
        default:
            break;
    }
}

- (void)didRotateWithTabBarHeight:(CGFloat)tabBarHeight
                  statusBarHeight:(CGFloat)statusBarHeight
{
    CGFloat offset = 0.0, margin = 10.0;
    
    if (_isOffset)
        offset = _legendOffset;
    
    [_indicatorView removeAllConstraints];
    
    switch (_orientation)
    {
        case MapToolbarOrientationMinimized:
            [_indicatorView constrainTopToAnchor:self.bottomAnchor constant:margin];
            [_indicatorView constrainCenterXToAnchor:self.centerXAnchor];
            [self resetIndicatorSize];
            break;
        
        case MapToolbarOrientationTop:
            self.center = CGPointMake(((self.superview.frame.size.width - offset) / 2.0),
                                      (statusBarHeight + (self.frame.size.height / 2.0)));
            
            [_indicatorView constrainTopToAnchor:self.bottomAnchor constant:margin];
            [_indicatorView constrainCenterXToAnchor:self.centerXAnchor];
            [self resetIndicatorSize];
            break;
            
        case MapToolbarOrientationBottom:
            self.center = CGPointMake(((self.superview.frame.size.width - offset) / 2.0),
                                      ((self.superview.frame.size.height) - (self.frame.size.height / 2.0)));
            
            [_indicatorView constrainBottomToAnchor:self.topAnchor constant:-margin];
            [_indicatorView constrainCenterXToAnchor:self.centerXAnchor];
            [self resetIndicatorSize];
            break;
            
        case MapToolbarOrientationLeft:
            self.center = CGPointMake((self.frame.size.width / 2.0),
                                      (self.superview.frame.size.height / 2.0));
            
            [_indicatorView constrainLeadingToAnchor:self.trailingAnchor constant:margin];
            [_indicatorView constrainCenterYToAnchor:self.centerYAnchor];
            [self resetIndicatorSize];
            break;
            
        case MapToolbarOrientationRight:
            self.center = CGPointMake(((self.superview.frame.size.width - offset) - (self.frame.size.width / 2.0)),
                                      (self.superview.frame.size.height / 2.0));
            
            [_indicatorView constrainTrailingToAnchor:self.leadingAnchor constant:-margin];
            [_indicatorView constrainCenterYToAnchor:self.centerYAnchor];
            [self resetIndicatorSize];
            break;
            
        default:
            break;
    }
}

- (void)hide
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                     }];
}

- (void)show
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 1.0;
                     }];
}

- (void)platViewMode:(MapViewScreenSetting)screenSetting
{
    [self setPreviousConfiguration];
    
    _wantDigitize = _wantExtents = _wantLegends = _wantMapType =
    _wantGrayscale = _wantUserLocation = _wantHelpButton =
    _wantEmailPDF = _wantProgressBar = _wantClearMarkers = _wantReturnButton = NO;
    _wantPlat = _configChanged = YES;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self configure:screenSetting];
                     }];
}

- (void)normalMode:(MapViewScreenSetting)screenSetting
{
    [self getPreviousConfiguration];
    
    if (_platOverride)
        _wantPlat = NO;
    
    _configChanged = YES;
    _platOverride = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self configure:screenSetting];
                     }];
}

- (void)setPreviousConfiguration
{
    _previousConfig[MapToolbarPropertyWantUserLocation] = _wantUserLocation;
    _previousConfig[MapToolbarPropertyWantPlat] = _wantPlat;
    _previousConfig[MapToolbarPropertyWantGrayscale] = _wantGrayscale;
    _previousConfig[MapToolbarPropertyWantClearMarkers] = _wantClearMarkers;
    _previousConfig[MapToolbarPropertyWantEmailPDF] = _wantEmailPDF;
    _previousConfig[MapToolbarPropertyWantProgressBar] = _wantProgressBar;
    _previousConfig[MapToolbarPropertyWantMapType] = _wantMapType;
    _previousConfig[MapToolbarPropertyWantLegends] = _wantLegends;
    _previousConfig[MapToolbarPropertyWantExtents] = _wantExtents;
    _previousConfig[MapToolbarPropertyWantDigitize] = _wantDigitize;
    _previousConfig[MapToolbarPropertyWantHelpButton] = _wantHelpButton;
    _previousConfig[MapToolbarPropertyWantHelpButton] = _wantReturnButton;
    _previousConfig[MapToolbarPropertyWantWeatherButton] = _wantWeatherButton;
}

- (void)getPreviousConfiguration
{
    _wantUserLocation = _previousConfig[MapToolbarPropertyWantUserLocation];
    _wantPlat = _previousConfig[MapToolbarPropertyWantPlat];
    _wantGrayscale = _previousConfig[MapToolbarPropertyWantGrayscale];
    _wantClearMarkers = _previousConfig[MapToolbarPropertyWantClearMarkers];
    _wantEmailPDF = _previousConfig[MapToolbarPropertyWantEmailPDF];
    _wantProgressBar = _previousConfig[MapToolbarPropertyWantProgressBar];
    _wantMapType = _previousConfig[MapToolbarPropertyWantMapType];
    _wantLegends = _previousConfig[MapToolbarPropertyWantLegends];
    _wantExtents = _previousConfig[MapToolbarPropertyWantExtents];
    _wantDigitize = _previousConfig[MapToolbarPropertyWantDigitize];
    _wantHelpButton = _previousConfig[MapToolbarPropertyWantHelpButton];
    _wantReturnButton = _previousConfig[MapToolbarPropertyWantReturnButton];
    _wantWeatherButton = _previousConfig[MapToolbarPropertyWantWeatherButton];
}

- (void)setConfigurationProperty:(MapToolbarProperty)property
                           value:(BOOL)value
{
    switch (property)
    {
        case MapToolbarPropertyWantPlat:
            _wantPlat = value;
            break;
            
        case MapToolbarPropertyWantDigitize:
            _wantDigitize = value;
            break;
            
        case MapToolbarPropertyWantMapType:
            _wantMapType = value;
            break;
            
        case MapToolbarPropertyWantMapTypeButton:
            _wantMapTypeButton = value;
            break;
            
        case MapToolbarPropertyWantUserLocation:
            _wantUserLocation = value;
            break;
            
        case MapToolbarPropertyWantExtents:
            _wantExtents = value;
            break;
            
        case MapToolbarPropertyWantLegends:
            _wantLegends = value;
            break;
            
        case MapToolbarPropertyWantGrayscale:
            _wantGrayscale = value;
            break;
            
        case MapToolbarPropertyWantClearMarkers:
            _wantClearMarkers = value;
            break;
            
        case MapToolbarPropertyWantEmailPDF:
            _wantEmailPDF = value;
            break;
            
        case MapToolbarPropertyWantProgressBar:
            _wantProgressBar = value;
            break;
            
        case MapToolbarPropertyWantHelpButton:
            _wantHelpButton = value;
            break;
            
        case MapToolbarPropertyWantReturnButton:
            _wantReturnButton = value;
            break;
            
        case MapToolbarPropertyWantWeatherButton:
            _wantWeatherButton = value;
            break;
            
        default:
            break;
    }
    
    _configChanged = YES;
}

- (void)configure:(MapViewScreenSetting)screenSetting
{
    if (!_configChanged)
        return;
    
    _configChanged = NO;
    
    if (_orientation == MapToolbarOrientationTop ||
        _orientation == MapToolbarOrientationBottom)
    {
        CGFloat xCount = _buttonMargin;
        
        if (_wantReturnButton)
        {
            _returnButton.frame = CGRectMake(xCount, _buttonMargin, (_buttonSize * 3.0), _buttonSize);
            _returnButton.titleLabel.numberOfLines = 1;
            [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
            
            if (![self.subviews containsObject:_returnButton])
                [self addSubview:_returnButton];
            
            xCount += (_buttonMargin + (_buttonSize * 3.0));
        }
        
        else
        {
            if ([self.subviews containsObject:_returnButton])
                [_returnButton removeFromSuperview];
        }
        
        if (_wantUserLocation)
        {
            _userLocationButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_userLocationButton])
                [self addSubview:_userLocationButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_userLocationButton])
                [_userLocationButton removeFromSuperview];
        }
        
        if (_wantExtents)
        {
            _extentsButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_extentsButton])
                [self addSubview:_extentsButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_extentsButton])
                [_extentsButton removeFromSuperview];
        }
        
        if (_wantLegends)
        {
            _legendsButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_legendsButton])
                [self addSubview:_legendsButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_legendsButton])
                [_legendsButton removeFromSuperview];
        }
        
        if (_wantDigitize)
        {
            _digitizeButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_digitizeButton])
                [self addSubview:_digitizeButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_digitizeButton])
                [_digitizeButton removeFromSuperview];
        }
        
        if (_wantGrayscale)
        {
            _grayscaleButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_grayscaleButton])
                [self addSubview:_grayscaleButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_grayscaleButton])
                [_grayscaleButton removeFromSuperview];
        }
        
        if (_wantClearMarkers)
        {
            _clearMarkerButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_clearMarkerButton])
                [self addSubview:_clearMarkerButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_clearMarkerButton])
                [_clearMarkerButton removeFromSuperview];
        }
        
        if (_wantEmailPDF)
        {
            _emailPDFButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_emailPDFButton])
                [self addSubview:_emailPDFButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_emailPDFButton])
                [_emailPDFButton removeFromSuperview];
        }
        
        if (_wantHelpButton)
        {
            _helpButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_helpButton])
                [self addSubview:_helpButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_helpButton])
                [_helpButton removeFromSuperview];
        }
        
        if (_wantMapType)
        {
            _mapTypeSC.frame = CGRectMake(xCount, _SCMargin, _mapTypeSCWidth, _SCHeight);
            
            if (![self.subviews containsObject:_mapTypeSC])
                [self addSubview:_mapTypeSC];
            
            xCount += (_buttonMargin + _mapTypeSCWidth);
        }
        
        else
        {
            if ([self.subviews containsObject:_mapTypeSC])
                [_mapTypeSC removeFromSuperview];
        }
        
        if (_wantWeatherButton)
        {
            _weatherButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_weatherButton])
                [self addSubview:_weatherButton];
            
            xCount += (_buttonMargin + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_weatherButton])
                [_weatherButton removeFromSuperview];
        }
        
        if (_wantPlat)
        {
            _platSC.frame = CGRectMake(xCount, _SCMargin, _platSCWidth, _SCHeight);
            
            if (![self.subviews containsObject:_platSC])
                [self addSubview:_platSC];
            
            xCount += (_buttonMargin + _platSCWidth);
        }
        
        else
        {
            if ([self.subviews containsObject:_platSC])
                [_platSC removeFromSuperview];
        }
        
        if (xCount < 20.0)
            xCount = 0.0;
        
        self.frame = CGRectMake((self.center.x - (xCount / 2.0)),
                                (self.center.y - (_size.height / 2.0)), xCount, _size.height);
        
        if (_wantProgressBar)
        {
            if (![self.subviews containsObject:_progressView])
                [self addSubview:_progressView];
            
            _progressView.frame = CGRectMake(_buttonMargin, (self.frame.size.height - _progressMargin),
                                             (self.frame.size.width - (_buttonMargin * 2.0)),
                                             _progressView.frame.size.height);
        }
        
        else
        {
            if ([self.subviews containsObject:_progressView])
                [_progressView removeFromSuperview];
        }
    }
    
    else
    {
        CGFloat yCount = _buttonMargin;
        CGFloat xCount = 0.0;
        
        if (_wantReturnButton)
        {
            _returnButton.frame = CGRectMake(xCount, _buttonMargin, _buttonSize, (_buttonSize * 2.0));
            _returnButton.titleLabel.numberOfLines = 2;
            [_returnButton setTitle:@"<\nR" forState:UIControlStateNormal];
            
            if (![self.subviews containsObject:_returnButton])
                [self addSubview:_returnButton];
            
            yCount += (_buttonMargin + (_buttonSize * 2.0));
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_returnButton])
                [_returnButton removeFromSuperview];
        }
        
        if (_wantUserLocation)
        {
            _userLocationButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_userLocationButton])
                [self addSubview:_userLocationButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_userLocationButton])
                [_userLocationButton removeFromSuperview];
        }
        
        if (_wantExtents)
        {
            _extentsButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_extentsButton])
                [self addSubview:_extentsButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_extentsButton])
                [_extentsButton removeFromSuperview];
        }
        
        if (_wantLegends)
        {
            _legendsButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_legendsButton])
                [self addSubview:_legendsButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_legendsButton])
                [_legendsButton removeFromSuperview];
        }
        
        if (_wantDigitize)
        {
            _digitizeButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_digitizeButton])
                [self addSubview:_digitizeButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_digitizeButton])
                [_digitizeButton removeFromSuperview];
        }
        
        if (_wantGrayscale)
        {
            _grayscaleButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_grayscaleButton])
                [self addSubview:_grayscaleButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_grayscaleButton])
                [_grayscaleButton removeFromSuperview];
        }
        
        if (_wantClearMarkers)
        {
            _clearMarkerButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_clearMarkerButton])
                [self addSubview:_clearMarkerButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_clearMarkerButton])
                [_clearMarkerButton removeFromSuperview];
        }
        
        if (_wantEmailPDF)
        {
            _emailPDFButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_emailPDFButton])
                [self addSubview:_emailPDFButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_emailPDFButton])
                [_emailPDFButton removeFromSuperview];
        }
        
        if (_wantHelpButton)
        {
            _helpButton.frame = CGRectMake(_buttonMargin, yCount, _buttonSize, _buttonSize);
            
            if (![self.subviews containsObject:_helpButton])
                [self addSubview:_helpButton];
            
            yCount += (_buttonMargin + _buttonSize);
            xCount = max(xCount, (_buttonMargin * 2.0) + _buttonSize);
        }
        
        else
        {
            if ([self.subviews containsObject:_helpButton])
                [_helpButton removeFromSuperview];
        }
        
        if (_wantMapType)
        {
            _mapTypeSC.frame = CGRectMake(_buttonMargin, yCount, _mapTypeSCWidth, _SCHeight);
            
            if (![self.subviews containsObject:_mapTypeSC])
                [self addSubview:_mapTypeSC];
            
            yCount += (_buttonMargin + _SCHeight);
            xCount = max(xCount, (_buttonMargin * 2.0) + _mapTypeSCWidth);
        }
        
        else
        {
            if ([self.subviews containsObject:_mapTypeSC])
                [_mapTypeSC removeFromSuperview];
        }
        
        if (_wantPlat)
        {
            _platSC.frame = CGRectMake(_buttonMargin, yCount, _platSCVertWidth, _SCHeight);
            
            if (![self.subviews containsObject:_platSC])
                [self addSubview:_platSC];
            
            yCount += (_buttonMargin + _SCHeight);
            xCount = max(xCount, (_buttonMargin * 2.0) + _platSCVertWidth);
        }
        
        else
        {
            if ([self.subviews containsObject:_platSC])
                [_platSC removeFromSuperview];
        }
        
        if (yCount < 20.0)
            yCount = 0.0;
        
        if (_orientation == MapToolbarOrientationLeft)
        {
            self.frame = CGRectMake(0.0, (self.center.y - (yCount / 2.0)),
                                    xCount, yCount);
        }
        
        else
        {
            self.frame = CGRectMake((self.superview.frame.size.width - xCount),
                                    (self.center.y - (yCount / 2.0)), xCount, yCount);
        }
        
        if (_wantProgressBar)
        {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                    self.frame.size.width, (self.frame.size.height + _progressMargin));
            
            if (![self.subviews containsObject:_progressView])
                [self addSubview:_progressView];
            
            _progressView.frame = CGRectMake(_buttonMargin, (self.frame.size.height - _progressMargin),
                                             self.frame.size.width - (_buttonMargin * 2.0),
                                             _progressView.frame.size.height);
        }
        
        else
        {
            if ([self.subviews containsObject:_progressView])
                [_progressView removeFromSuperview];
        }
        
        for (UIView *views in self.subviews)
            views.center = CGPointMake(self.center.x, views.center.y);
    }
    
    if (screenSetting != MapViewScreenSettingFullscreen && !_wantPlat)
    {
        _platOverride = YES;
        [self splitScreenSettingSelected:MapViewScreenSettingFullscreen];
        _platSC.selectedSegmentIndex = MapViewScreenSettingFullscreen;
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [_progressView setProgress:_progress animated:NO];
}

- (void)addExpandButton
{
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expandButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    expandButton.backgroundColor = UIColor.clearColor;
    expandButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    expandButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [expandButton setTitle:@"MT" forState:UIControlStateNormal];
    [expandButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [expandButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateHighlighted];
    
    [expandButton addTarget:self
                     action:@selector(expandToolbar:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:expandButton];
    
    if (_wantProgressBar)
    {
        _progressView.frame = CGRectMake((_buttonMargin * 0.5), (self.frame.size.height - _progressMargin),
                                         (self.frame.size.width - _buttonMargin), _progressView.frame.size.height);
        
        _progressView.alpha = 1.0;
    }
}

- (void)expandToolbar:(UIButton *)button
{
    [button removeFromSuperview];
    [_delegate mapToolbarDidWantExpand];
}

- (void)adjustFrameToScrollView
{
    CGRect superviewFrame = self.superview.frame;
    CGFloat offset = 0.0;
    
    if (_isOffset)
        offset = _legendOffset;
    
    switch (_orientation)
    {
        case MapToolbarOrientationTop:
        case MapToolbarOrientationBottom:
            self.center = CGPointMake(((superviewFrame.size.width - offset) / 2.0), self.center.y);
            break;
            
        case MapToolbarOrientationRight:
            self.center = CGPointMake(((superviewFrame.size.width - offset) -
                                       (self.frame.size.width / 2.0)), self.center.y);
            break;
            
        default:
            break;
    }
}

- (void)resetIndicatorSize
{
    [_indicatorView constrainWidthToConstant:_indicatorSize];
    [_indicatorView constrainHeightToConstant:_indicatorSize];
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    _showIndicator = showIndicator;
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (showIndicator)
                           [_indicatorView startAnimating];
                       
                       else
                           [_indicatorView stopAnimating];
                   });
}

- (void)bringToFrontOfView
{
    [self.superview bringSubviewToFront:self];
    [self.superview bringSubviewToFront:_indicatorView];
}

- (void)setOrientation:(MapToolbarOrientation)orientation
{
    _orientation = orientation;
    CGFloat margin = 10.0;
    [_indicatorView removeAllConstraints];
    
    switch (orientation)
    {
        case MapToolbarOrientationMinimized:
            [_indicatorView constrainTopToAnchor:self.bottomAnchor constant:margin];
            [_indicatorView constrainCenterXToAnchor:self.centerXAnchor];
            [self resetIndicatorSize];
            break;
        
        case MapToolbarOrientationTop:
            [_indicatorView constrainTopToAnchor:self.bottomAnchor constant:margin];
            [_indicatorView constrainCenterXToAnchor:self.centerXAnchor];
            [self resetIndicatorSize];
            break;
            
        case MapToolbarOrientationBottom:
            [_indicatorView constrainBottomToAnchor:self.topAnchor constant:-margin];
            [_indicatorView constrainCenterXToAnchor:self.centerXAnchor];
            [self resetIndicatorSize];
            break;
            
        case MapToolbarOrientationLeft:
            [_indicatorView constrainLeadingToAnchor:self.trailingAnchor constant:margin];
            [_indicatorView constrainCenterYToAnchor:self.centerYAnchor];
            [self resetIndicatorSize];
            break;
            
        case MapToolbarOrientationRight:
            [_indicatorView constrainTrailingToAnchor:self.leadingAnchor constant:-margin];
            [_indicatorView constrainCenterYToAnchor:self.centerYAnchor];
            [self resetIndicatorSize];
            break;
            
        default:
            break;
    }
}

- (void)userLocationLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _userLocationButton.layer.borderColor = UIColor.blackColor.CGColor;
        _userLocationButton.layer.borderWidth = _bordWidth;
        _applyRotation = _myLocationEnabled = !_myLocationEnabled;
        
        if (_myLocationEnabled)
            _userLocationButton.backgroundColor = UIColor.redColor;
        
        else
            _userLocationButton.backgroundColor = UIColor.whiteColor;
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
        [_delegate mapToolbarDidSelectUserLocation:_myLocationEnabled];
}

@end
