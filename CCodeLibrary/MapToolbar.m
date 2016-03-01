//  MapToolbar.m
//  GMMobile

#import "MapToolbar.h"
#import "UserDefaults.h"
#import "HelpButton.h"
#import "NVColor.h"

@interface MapToolbar ()

@property (nonatomic) UIButton *extentsButton, *userLocationButton, *legendsButton, *digitizeButton;
@property (nonatomic) UIButton *grayscaleButton, *clearMarkerButton, *emailPDFButton, *helpButton;
@property (nonatomic) UISegmentedControl *mapTypeSC, *platSC;
@property (nonatomic) CGSize size;
@property BOOL configChanged, myLocationEnabled, platOverride;
@property (nonatomic) CGFloat buttonSize, switchHeight, switchWidth, SCHeight, mapTypeSCWidth;
@property (nonatomic) CGFloat buttonMargin, switchMargin, SCMargin, platSCWidth, platSCVertWidth;
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) NSTimer *helpBackgroundToggleTimer;

@end

@implementation MapToolbar
{
    BOOL _previousConfig[NUMMapToolbarProperty];
}

+ (MapToolbar *)showMapToolbarWithCenter:(CGPoint)center
                                    view:(UIView *)view
                                delegate:(id)delegate;
{
    MapToolbar *mt = [[MapToolbar alloc] init];
    mt.configChanged = mt.myLocationEnabled = mt.platOverride = mt.helpLongPressed = NO;
    
    //set default configuration
    [mt setConfigurationProperty:MapToolbarPropertyWantUserLocation
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantExtents
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantGrayscale
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantClearMarkers
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantEmailPDF
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantProgressBar
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantHelpButton
                           value:YES];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantPlat
                           value:NO];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantDigitize
                           value:NO];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantMapType
                           value:NO];
    
    [mt setConfigurationProperty:MapToolbarPropertyWantLegends
                           value:NO];
    
    //set internal sizes for all devices
    mt.buttonSize = 47.0, mt.SCHeight = 29.0, mt.mapTypeSCWidth = 76.0;
    mt.buttonMargin = 8.0, mt.switchMargin = 16.0, mt.SCMargin = 17.0, mt.platSCWidth = 196.0;
    mt.platSCVertWidth = 112.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        //reset internal sizes for iPhone
        mt.buttonSize = 39.0, mt.buttonMargin = 5.0, mt.SCMargin = 10.0;
        mt.mapTypeSCWidth = 78.0, mt.platSCWidth = 166.0;
    }
    
    //set default size for all devices
    mt.size = CGSizeMake(((mt.buttonSize * 5.0) + (mt.buttonMargin * 6.0)),
                         (mt.buttonSize + (mt.buttonMargin * 2.0) + 10.0));
    
    mt.backgroundColor = UserDefaults.defaults.appleBlue;
    mt.frame = CGRectMake(0.0, 0.0, mt.size.width, mt.size.height);
    mt.center = center;
    mt.layer.borderWidth = 2.0;
    mt.layer.borderColor = UIColor.blackColor.CGColor;
    mt.delegate = delegate;
    mt.orientation = MapToolbarOrientationTop;
    mt.previousOrientation = MapToolbarOrientationDefault;
    mt.previousFrame = CGRectZero;
    
    [view addSubview:mt];
    
    mt.userLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(mt.buttonMargin, mt.buttonMargin,
                                                                       mt.buttonSize, mt.buttonSize)];
    
    [mt setupButton:mt.userLocationButton
         imageTitle:@"userLocation"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(userLocationSelected:)];

    //add user location button added by default
    [mt addSubview:mt.userLocationButton];
    
    mt.extentsButton = [[UIButton alloc] initWithFrame:CGRectMake((mt.buttonSize + (mt.buttonMargin * 2.0)),
                                                                  mt.buttonMargin, mt.buttonSize, mt.buttonSize)];
    
    [mt setupButton:mt.extentsButton
         imageTitle:@"zoom"
         edgeInsets:UIEdgeInsetsMake(-2.0, -2.0, -2.0, -2.0)
           selector:@selector(extentsSelected:)];
    
    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                            action:@selector(extentsLongPressed:)];
    
    [mt.extentsButton addGestureRecognizer:lpGesture];
  
    //add extents button added by default
    [mt addSubview:mt.extentsButton];
    
    mt.grayscaleButton = [[UIButton alloc] initWithFrame:CGRectMake(((mt.buttonSize * 2.0) + (mt.buttonMargin * 3.0)),
                                                                    mt.buttonMargin, mt.buttonSize, mt.buttonSize)];
    
    [mt setupButton:mt.grayscaleButton
         imageTitle:@"grayscale"
         edgeInsets:UIEdgeInsetsZero
           selector:@selector(grayscaleSelected:)];
    
    //grayscale button added by default
    [mt addSubview:mt.grayscaleButton];
    
    mt.clearMarkerButton = [[UIButton alloc] initWithFrame:CGRectMake(((mt.buttonSize * 3.0) + (mt.buttonMargin * 4.0)),
                                                                      mt.buttonMargin, mt.buttonSize, mt.buttonSize)];
    
    [mt setupButton:mt.clearMarkerButton
         imageTitle:@"clearMarkers"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(clearMarkersSelected:)];
    
    //clear marker button added by default
    [mt addSubview:mt.clearMarkerButton];
    
    mt.emailPDFButton = [[UIButton alloc] initWithFrame:CGRectMake(((mt.buttonSize * 4.0) + (mt.buttonMargin * 5.0)),
                                                                   mt.buttonMargin, mt.buttonSize, mt.buttonSize)];
    
    [mt setupButton:mt.emailPDFButton
         imageTitle:@"emailIcon"
         edgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
           selector:@selector(emailPDFSelected:)];
    
    UILongPressGestureRecognizer *emailLpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                                 action:@selector(emailLongPressed:)];
    
    [mt.emailPDFButton addGestureRecognizer:emailLpGesture];
    
    //email PDF button added by default
    [mt addSubview:mt.emailPDFButton];
    
    mt.helpButton = [[UIButton alloc] initWithFrame:CGRectMake(((mt.buttonSize * 5.0) + (mt.buttonMargin * 5.0)),
                                                               mt.buttonMargin, mt.buttonSize, mt.buttonSize)];
    
    [mt setupButton:mt.helpButton
         imageTitle:@"questionMark"
         edgeInsets:UIEdgeInsetsMake(4.0, -2.0, 4.0, -2.0)
           selector:@selector(helpButtonSelected:)];
    
    UILongPressGestureRecognizer *helpLpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:mt
                                                                                                action:@selector(helpLongPressed:)];
    
    [mt.helpButton addGestureRecognizer:helpLpGesture];
    
    //email PDF button added by default
    [mt addSubview:mt.helpButton];
    
    mt.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(mt.buttonMargin, mt.size.height - 10.0,
                                                                       mt.size.width - (mt.buttonMargin * 2.0), 4.0)];
    
    mt.progressView.trackTintColor = UIColor.darkGrayColor;
    mt.progressView.progressTintColor = UIColor.whiteColor;
    
    //progress view added by default
    [mt addSubview:mt.progressView];
    
    mt.mapTypeSC = [[UISegmentedControl alloc] initWithItems:@[@"Stnd", @"Hybd"]];
    
    [mt setupSegControl:mt.mapTypeSC
   selectedSegmentIndex:0
               selector:@selector(mapTypeSelected:)];
    
    //map type SC is NOT added by default
    
    mt.digitizeButton = [[UIButton alloc] init];
    
    [mt setupButton:mt.digitizeButton
         imageTitle:@"plusSign"
         edgeInsets:UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)
           selector:@selector(digitizeSelected:)];
    
    //digitize button is NOT added by default
    
    mt.legendsButton = [[UIButton alloc] init];
    
    [mt setupButton:mt.legendsButton
         imageTitle:@"list"
         edgeInsets:UIEdgeInsetsZero
           selector:@selector(legendsSelected:)];
    
    //legends button is NOT added by default
    
    mt.platSC = [[UISegmentedControl alloc] initWithItems:@[@"Full", @"Split", @"Tri", @"Plat"]];
    
    [mt setupSegControl:mt.platSC
   selectedSegmentIndex:MapViewScreenSettingFullscreen
               selector:@selector(splitScreenSettingSelected:)];
    
    //plat SC is NOT added by default
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:mt
                                                                                 action:@selector(mapToolbarDragged:)];
    
    panGesture.delegate = mt;
    [mt addGestureRecognizer:panGesture];
    
    return mt;
}

- (void)setupButton:(UIButton *)button
         imageTitle:(NSString *)imageTitle
         edgeInsets:(UIEdgeInsets)edgeInsets
           selector:(SEL)selector
{
    button.imageEdgeInsets = edgeInsets;
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = 10.0;
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    button.layer.masksToBounds = YES;
    
    [button setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageTitle
                                                                                    ofType:@"png"]]
            forState:UIControlStateNormal];
    
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
    button.layer.borderWidth = 6.0;
}

- (void)setupSegControl:(UISegmentedControl *)segControl
   selectedSegmentIndex:(NSInteger)selectedSegmentIndex
               selector:(SEL)selector
{
    segControl.backgroundColor = UIColor.blackColor;
    segControl.tintColor = UIColor.whiteColor;
    segControl.layer.cornerRadius = 4.0;
    segControl.layer.borderColor = UIColor.blackColor.CGColor;
    segControl.layer.borderWidth = 2.0;
    segControl.layer.masksToBounds = YES;
    segControl.selectedSegmentIndex = MapViewScreenSettingFullscreen;
    
    [segControl addTarget:self
                   action:selector
         forControlEvents:UIControlEventValueChanged];
}

- (void)userLocationSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    _myLocationEnabled = !_myLocationEnabled;
    
    if (_myLocationEnabled)
        _userLocationButton.backgroundColor = UIColor.greenColor;
    
    else
        _userLocationButton.backgroundColor = UIColor.whiteColor;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectUserLocation:_myLocationEnabled];
}

- (void)deselectMyLocationButton
{
    _userLocationButton.backgroundColor = UIColor.whiteColor;
    _myLocationEnabled = NO;
}

- (void)extentsSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectZoomExtent];
}

- (void)extentsLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _extentsButton.layer.borderColor = UIColor.greenColor.CGColor;
        _extentsButton.layer.borderWidth = 6.0;
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _extentsButton.layer.borderColor = UIColor.blackColor.CGColor;
        _extentsButton.layer.borderWidth = 2.0;
    }
}

- (void)grayscaleSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectGrayscale];
}

- (void)clearMarkersSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectClearMarkers];
}

- (void)emailPDFSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectEmailPDF];
}

- (void)emailLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _emailPDFButton.layer.borderColor = UIColor.greenColor.CGColor;
        _emailPDFButton.layer.borderWidth = 6.0;
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _emailPDFButton.layer.borderColor = UIColor.blackColor.CGColor;
        _emailPDFButton.layer.borderWidth = 2.0;
        
        if (_delegate)
            [_delegate mapToolbarDidLongPressEmailPDF];
    }
}

- (void)helpButtonSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_helpLongPressed)
        [self endHBLongPressMode];
    
    else if (_delegate)
        [_delegate mapToolbarDidSelectHelpButton];
}

- (void)helpLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan && !_helpLongPressed)
    {
        _helpButton.layer.borderColor = UIColor.greenColor.CGColor;
        _helpButton.layer.borderWidth = 6.0;
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _helpButton.layer.borderColor = UIColor.blackColor.CGColor;
        _helpButton.layer.borderWidth = 2.0;
        
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
}

- (void)mapTypeSelected:(UISegmentedControl *)segControl
{
    if (_delegate)
        [_delegate mapToolbarDidSelectMapType:segControl.selectedSegmentIndex];
}

- (void)digitizeSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectDigitize];
}

- (void)legendsSelected:(UIButton *)button
{
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 2.0;
    
    if (_delegate)
        [_delegate mapToolbarDidSelectLegends];
}

- (void)splitScreenSettingSelected:(UISegmentedControl *)segControl
{
    if (_delegate)
        [_delegate mapToolbarDidSelectSplitScreenSetting:segControl.selectedSegmentIndex];
}

- (void)mapToolbarDragged:(UIPanGestureRecognizer *)gesture
{
    if (_orientation == MapToolbarOrientationMinimized)
        return;
    
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
                    buttons.layer.borderWidth = 2.0;
                }
            }
        }
        
        gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                          gesture.view.center.y + translation.y);
        
        [gesture setTranslation:CGPointZero
                         inView:self];
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate)
            [_delegate mapToolbarDidFinishDrag];
    }
}

- (void)animateToVerticalOrientation
{
    CGFloat yCount = _buttonMargin;
    CGFloat xCount = 0.0;
    
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
        self.frame = CGRectMake(0.0, 0.0, xCount, (yCount + 10.0));
        
        _progressView.frame = CGRectMake(_buttonMargin, self.frame.size.height - 10.0,
                                         self.frame.size.width - (_buttonMargin * 2.0),
                                         _progressView.frame.size.height);
    }
    
    for (UIView *views in self.subviews)
        views.center = CGPointMake(self.center.x, views.center.y);
    
    [_platSC setTitle:@"F"
    forSegmentAtIndex:0];
    
    [_platSC setTitle:@"S"
    forSegmentAtIndex:1];
    
    [_platSC setTitle:@"T"
    forSegmentAtIndex:2];
    
    [_platSC setTitle:@"P"
    forSegmentAtIndex:3];
}

- (void)animateToHorizontalOrientation
{
    CGFloat xCount = _buttonMargin;
    
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
        _progressView.frame = CGRectMake(_buttonMargin, self.frame.size.height - 10.0,
                                         self.frame.size.width - (_buttonMargin * 2.0),
                                         _progressView.frame.size.height);
    }
    
    [_platSC setTitle:@"Full"
           forSegmentAtIndex:0];
    
    [_platSC setTitle:@"Split"
           forSegmentAtIndex:1];
    
    [_platSC setTitle:@"Tri"
           forSegmentAtIndex:2];
    
    [_platSC setTitle:@"Plat"
           forSegmentAtIndex:3];
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
    
    switch (_orientation)
    {
        case MapToolbarOrientationTop:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.center = CGPointMake(((superviewFrame.size.height + tabBarHeight) / 2.0),
                                                           (statusBarHeight + (self.frame.size.height / 2.0)));
                                 
                             }];
        }
            break;
            
        case MapToolbarOrientationBottom:
        {
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.center = CGPointMake(((superviewFrame.size.height + tabBarHeight) / 2.0),
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
                                 self.center = CGPointMake(((superviewFrame.size.height + tabBarHeight) -
                                                            (self.frame.size.width / 2.0)),
                                                           ((superviewFrame.size.width - tabBarHeight) / 2.0));
                             }];
        }
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
    _wantEmailPDF = _wantProgressBar = _wantClearMarkers = NO;
    
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
            _progressView.frame = CGRectMake(_buttonMargin, self.frame.size.height - 10.0,
                                             self.frame.size.width - (_buttonMargin * 2.0),
                                             _progressView.frame.size.height);
        }
    }
    
    else
    {
        CGFloat yCount = _buttonMargin;
        CGFloat xCount = 0.0;
        
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
                                    self.frame.size.width, (self.frame.size.height + 10.0));
            
            _progressView.frame = CGRectMake(_buttonMargin, self.frame.size.height - 10.0,
                                             self.frame.size.width - (_buttonMargin * 2.0),
                                             _progressView.frame.size.height);
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
    
    [_progressView setProgress:_progress
                      animated:NO];
}

- (void)addExpandButton
{
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expandButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    expandButton.backgroundColor = UIColor.clearColor;
    expandButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    expandButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [expandButton setTitle:@"MT"
                  forState:UIControlStateNormal];
    
    [expandButton setTitleColor:UIColor.whiteColor
                       forState:UIControlStateNormal];
    
    [expandButton setTitleColor:UIColor.darkGrayColor
                       forState:UIControlStateHighlighted];
    
    [expandButton addTarget:self
                     action:@selector(expandToolbar:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:expandButton];
}

- (void)expandToolbar:(UIButton *)button
{
    [button removeFromSuperview];
    
    if (_delegate)
        [_delegate mapToolbarDidWantExpand];
}

@end