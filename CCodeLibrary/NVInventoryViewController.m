//  NVInventoryViewController.m
//  CCodeLibrary

#import "NVInventoryViewController.h"
#import "UserDefaults.h"
#import "IntersectionsDatabase.h"
#import "CRAPI.h"
#import "TileGraphics.h"
#import "MathUtil.h"
#import "NVRampButton.h"
#import "NVSignalButton.h"
#import "NVXWalkButton.h"
#import "RampTypeView.h"

@interface NVInventoryViewController ()

@property (nonatomic) UIImageView *backgroundImage, *imageTargetView;
@property (nonatomic) UIButton *cancelButton, *doneButton;
@property (nonatomic) UIButton *addRampButton, *addSignalButton, *addXWalkButton;
@property (nonatomic) UIButton *editItemButton, *rampTypeButton, *currentEditButton;
@property (nonatomic, copy) NSString *imageName, *pathToImageFile, *pathToBPWFile;
@property (nonatomic) LPTRANDATA pTranWToBMP, pTranBMPToW;
@property (nonatomic) CGFloat xFactor, yFactor, xOffset, yOffset, latitude, longitude;
@property int currentIntersectionID, currentZoom;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) UISegmentedControl *zoomSC;
@property (nonatomic) NVRampButton *ramp1, *ramp2, *ramp3, *ramp4, *ramp5, *ramp6, *ramp7, *ramp8;
@property (nonatomic) NVRampButton *ramp23, *ramp45, *ramp67, *ramp81;
@property BOOL firstTime, draggableTarget;
@property NVUpdateOption updateOption;
@property (nonatomic) NVSignalButton *signal23, *signal45, *signal67, *signal81;
@property (nonatomic) NVXWalkButton *xWalkA, *xWalkB, *xWalkC, *xWalkD;
@property RampType currentRampType;
@property (nonatomic) UILabel *headingLabel, *intersectionLabel;
@property (nonatomic) CGPoint newTarget;
@property (nonatomic) CGFloat targetSize;

@end

@implementation NVInventoryViewController

+ (NVInventoryViewController *)showInventoryViewControllerForIntersection:(MPIntersection *)intersection
                                                                 delegate:(id)delegate
                                                                     from:(NSInteger)from
                                                          draggableTarget:(BOOL)draggableTarget;
{
    NVInventoryViewController *inventoryVC = [[NVInventoryViewController alloc] init];
    inventoryVC.currentIntersection = intersection;
    inventoryVC.delegate = delegate;
    inventoryVC.from = from;
    inventoryVC.draggableTarget = draggableTarget;
    
    if ([delegate isKindOfClass:UIViewController.class])
    {
        [delegate presentViewController:inventoryVC
                               animated:YES
                             completion:nil];
    }
    
    return inventoryVC;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.blackColor;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentIntersectionID = _currentIntersection.intID;
    _currentZoom = 21;
    _firstTime = YES;
    _pTranWToBMP = _pTranBMPToW = 0;
    _updateOption = NVUpdateOptionNone;
    _currentRampType = [UserDefaults.defaults integerForKey:@"CurrentRampType"];
    _targetSize = 160.0;
    
    _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 98.0, 768.0, 768.0)];
    _backgroundImage.clipsToBounds = YES;
    _backgroundImage.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(pointPicked:)];
    
    [_backgroundImage addGestureRecognizer:tapGesture];
    [self.view addSubview:_backgroundImage];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(224.0, 20.0, 320.0, 70.0)];
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, 148.0, 70.0)];
    
    [self setupButton:_doneButton
             selector:@selector(done:)
                title:@"Done"
             fontSize:56.0];
    
    [self setupButton:_cancelButton
             selector:@selector(cancel:)
                title:@"Cancel"
             fontSize:40.0];
    
    [self setupBottomButtons];
    [self setupZoomSC];
    [self setupRampButtons];
    [self setupXWalkButtons];
    [self setupSignalButtons];
    [self setBKImage:NO];
    
    if (_draggableTarget)
        [self setupImageTarget];
    
    _headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(600.0, 20.0, 148.0, 70.0)];
    _headingLabel.font = [UIFont boldSystemFontOfSize:60.0];
    [self setupLabel:_headingLabel];
    
    _intersectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(_addXWalkButton.frame.origin.x,
                                                                   _zoomSC.frame.origin.y,
                                                                   752.0 - _addXWalkButton.frame.origin.x,
                                                                   _zoomSC.frame.size.height)];
    
    _intersectionLabel.font = [UIFont boldSystemFontOfSize:32.0];
    _intersectionLabel.text = [NSString stringWithFormat:@"Intersection %i", _currentIntersectionID];
    [self setupLabel:_intersectionLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.headingOrientation = CLDeviceOrientationFaceUp;
    _locationManager.headingFilter = kCLHeadingFilterNone;
    
    if (CLLocationManager.headingAvailable)
        [_locationManager startUpdatingHeading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_pTranBMPToW)
        free(_pTranBMPToW);
    
    if (_pTranWToBMP)
        free(_pTranWToBMP);
    
    _pTranBMPToW = nil;
    _pTranWToBMP = nil;
    
    if (_locationManager)
    {
        [_locationManager stopUpdatingHeading];
        _locationManager.delegate = nil;
        _locationManager = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupLabel:(UILabel *)label
{
    label.backgroundColor = UIColor.clearColor;
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:label];
}

- (void)setBKImage:(BOOL)forceRefresh;
{
    CGRect windowBounds = CGRectZero;
    CGSize imageSize = CGSizeZero;
    
    _imageName = [NSString stringWithFormat:@"%i", _currentIntersectionID];
    
    IntersectionsDatabase *database = [IntersectionsDatabase databaseForGeoid:CRAPI.sharedInstance.currentGeoid];
    IntersectionPoint *info = (IntersectionPoint *)[database getCurrentIntersectionPoint:_currentIntersectionID];
    
    _latitude = info.latitude;
    _longitude = info.longitude;
    
    CRAPI.sharedInstance.currentView = self.view;
    
    _pathToImageFile = [CRAPI.sharedInstance getImageFileforIntersection:_currentIntersectionID
                                                                   atLat:_latitude
                                                                  andLon:_longitude
                                                                 andZoom:_currentZoom
                                                            forceRefresh:forceRefresh];
    
    if (_pathToImageFile)
    {
        NSString *dirAndName = [_pathToImageFile stringByDeletingPathExtension];
        _pathToBPWFile = [dirAndName stringByAppendingPathExtension:@"cpt"];
    }
    
    UIImage *backImage = [UIImage imageWithContentsOfFile:_pathToImageFile];
    int pixelx = 0, pixely = 0;
    LatLongToPixelXY(info.latitude, info.longitude, _currentZoom, &pixelx, &pixely);
    
    NSString *intAzms = @"";
    
    [CRAPI.sharedInstance setIntersectionRotAndQuadDeviders:intAzms
                                                     forInt:_currentIntersection];
    
    if (_pTranBMPToW)
        free(_pTranBMPToW);
    
    if (_pTranWToBMP)
        free(_pTranWToBMP);
    
    _pTranBMPToW = LoadTranFromCPT(_pathToBPWFile.UTF8String, 1);
    _pTranWToBMP = LoadTranFromCPT(_pathToBPWFile.UTF8String, 2);
    _backgroundImage.image = backImage;
    windowBounds = _backgroundImage.frame;
    imageSize = _backgroundImage.intrinsicContentSize;
    _xFactor = (CGFloat)imageSize.width / (CGFloat)windowBounds.size.width;
    _yFactor = (CGFloat)imageSize.height / (CGFloat)windowBounds.size.height;
    _xOffset = (windowBounds.origin.x * _xFactor);
    _yOffset = (windowBounds.origin.y * _yFactor);
    
    [self setupButtons:NO];
}

- (void)adjustXYtoBKImage:(int *)x
                        y:(int *)y
{
    CGRect rect = _backgroundImage.frame;
    CGFloat xfactor = (rect.size.width / 640.0);
    CGFloat yfactor = (rect.size.height / 640.0);
    *x = rect.origin.x + (*x * xfactor);
    *y = rect.origin.y + (*y * yfactor);
}

- (void)setXWalkButton:(NVXWalkButton *)xWalkButton
             doesExist:(BOOL)doesExist
                   atX:(int)x
                  andY:(int)y
{
    if (doesExist)
    {
        double bmpx = 0.0, bmpy = 0.0;
        TRANS2(x, y, &bmpx, &bmpy, _pTranWToBMP);
        x = bmpx;
        y = bmpy;
        
        [self adjustXYtoBKImage:&x
                              y:&y];
        
        x -= (xWalkButton.frame.size.width / 2.0);
        y -= (xWalkButton.frame.size.height / 2.0);
        
        CGRect newLoc = CGRectMake(x, y, xWalkButton.frame.size.width,
                                   xWalkButton.frame.size.height);
        
        xWalkButton.frame = newLoc;
        xWalkButton.hidden = NO;
    }
    
    else
        xWalkButton.hidden = YES;
}

- (void)setSignalButton:(NVSignalButton *)signalButton
              doesExist:(BOOL)doesExist
                    atX:(int)x
                   andY:(int)y
{
    if (doesExist)
    {
        double bmpx = 0.0, bmpy = 0.0;
        TRANS2(x, y, &bmpx, &bmpy, _pTranWToBMP);
        x = bmpx;
        y = bmpy;
        
        [self adjustXYtoBKImage:&x
                              y:&y];
        
        x -= (signalButton.frame.size.width / 2.0);
        y -= (signalButton.frame.size.height / 2.0);
        
        CGRect newLoc = CGRectMake(x, y, signalButton.frame.size.width,
                                   signalButton.frame.size.height);
        
        signalButton.frame = newLoc;
        signalButton.hidden = NO;
    }
    
    else
        signalButton.hidden = YES;
}

- (void)setupButtons:(BOOL)resetOptions
{
    MPRamp *ramp = nil;
    
    [self setXWalkButton:_xWalkA
               doesExist:_currentIntersection.xWalkAExists
                     atX:_currentIntersection.xWalkAlev21x
                    andY:_currentIntersection.xWalkAlev21y];
    
    [self setXWalkButton:_xWalkB
               doesExist:_currentIntersection.xWalkBExists
                     atX:_currentIntersection.xWalkBlev21x
                    andY:_currentIntersection.xWalkBlev21y];
    
    [self setXWalkButton:_xWalkC
               doesExist:_currentIntersection.xWalkCExists
                     atX:_currentIntersection.xWalkClev21x
                    andY:_currentIntersection.xWalkClev21y];
    
    [self setXWalkButton:_xWalkD
               doesExist:_currentIntersection.xWalkDExists
                     atX:_currentIntersection.xWalkDlev21x
                    andY:_currentIntersection.xWalkDlev21y];
    
    [self setSignalButton:_signal81
                doesExist:_currentIntersection.signal81Exists
                      atX:_currentIntersection.signal81lev21x
                     andY:_currentIntersection.signal81lev21y];
    
    [self setSignalButton:_signal23
                doesExist:_currentIntersection.signal23Exists
                      atX:_currentIntersection.signal23lev21x
                     andY:_currentIntersection.signal23lev21y];
    
    [self setSignalButton:_signal45
                doesExist:_currentIntersection.signal45Exists
                      atX:_currentIntersection.signal45lev21x
                     andY:_currentIntersection.signal45lev21y];
    
    [self setSignalButton:_signal67
                doesExist:_currentIntersection.signal67Exists
                      atX:_currentIntersection.signal67lev21x
                     andY:_currentIntersection.signal67lev21y];
    
    for (int i = 1; i < 13; i++)
    {
        int x = 0, y = 0;
        double bmpx = 0.0, bmpy = 0.0;
        NVRampButton *rampButton = nil;
        
        ramp = _currentIntersection.ramps[i];
        
        switch (i)
        {
            case 1:
                _ramp1.hidden = !ramp.rampExists;
                rampButton = _ramp1;
                break;
                
            case 2:
                _ramp2.hidden = !ramp.rampExists;
                rampButton = _ramp2;
                break;
                
            case 3:
                _ramp3.hidden = !ramp.rampExists;
                rampButton = _ramp3;
                break;
                
            case 4:
                _ramp4.hidden = !ramp.rampExists;
                rampButton = _ramp4;
                break;
                
            case 5:
                _ramp5.hidden = !ramp.rampExists;
                rampButton = _ramp5;
                break;
                
            case 6:
                _ramp6.hidden = !ramp.rampExists;
                rampButton = _ramp6;
                break;
                
            case 7:
                _ramp7.hidden = !ramp.rampExists;
                rampButton = _ramp7;
                break;
                
            case 8:
                _ramp8.hidden = !ramp.rampExists;
                rampButton = _ramp8;
                break;
                
            case 9:
                _ramp23.hidden = !ramp.rampExists;
                rampButton = _ramp23;
                break;
                
            case 10:
                _ramp45.hidden = !ramp.rampExists;
                rampButton = _ramp45;
                break;
                
            case 11:
                _ramp67.hidden = !ramp.rampExists;
                rampButton = _ramp67;
                break;
                
            case 12:
                _ramp81.hidden = !ramp.rampExists;
                rampButton = _ramp81;
                break;
        }
        
        if (ramp.rampExists)
        {
            TRANS2(ramp.lev21x, ramp.lev21y, &bmpx, &bmpy, _pTranWToBMP);
            x = bmpx;
            y = bmpy;
            
            [self adjustXYtoBKImage:&x
                                  y:&y];
            
            x -= (rampButton.frame.size.width / 2.0);
            y -= (rampButton.frame.size.height / 2.0);
            
            rampButton.frame = CGRectMake(x, y, rampButton.frame.size.width, rampButton.frame.size.height);
            rampButton.type = ramp.rampType;
            rampButton.hidden = (rampButton.type > 9);
        }
    }
    
    if (resetOptions)
    {
        _updateOption = NVUpdateOptionNone;
        [self deselectAll];
    }
    
    [self updateBottomButtonAppearance];
}

- (void)deselectAll
{
    _editItemButton.selected = NO;
    _addSignalButton.selected = NO;
    _addXWalkButton.selected = NO;
    _addRampButton.selected = NO;
}

- (void)setupBottomButtons
{
    CGFloat height = 84.0, width = 132.0, top = 874.0;
    CGFloat outBorder = 16.0;
    CGFloat inBorder = ((768.0 - ((width * 5.0) + (outBorder * 2.0))) / 4.0);
    
    _addRampButton = [[UIButton alloc] initWithFrame:
                      CGRectMake(outBorder, top, width, height)];
    
    _addSignalButton = [[UIButton alloc] initWithFrame:
                        CGRectMake((outBorder + width + inBorder), top, width, height)];
    
    _addXWalkButton = [[UIButton alloc] initWithFrame:
                       CGRectMake((outBorder + ((width + inBorder) * 2.0)), top, width, height)];
    
    _editItemButton =  [[UIButton alloc] initWithFrame:
                        CGRectMake((outBorder + ((width + inBorder) * 3.0)), top, width, height)];
    
    _rampTypeButton = [[UIButton alloc] initWithFrame:
                       CGRectMake((outBorder + ((width + inBorder) * 4.0)), top, width, height)];
    
    [self setupButton:_addRampButton
             selector:@selector(addRamp:)
                title:@"Add\nRamp"
             fontSize:32.0];
    
    [self setupButton:_addSignalButton
             selector:@selector(addSignal:)
                title:@"Add\nSignal"
             fontSize:32.0];
    
    [self setupButton:_addXWalkButton
             selector:@selector(addXWalk:)
                title:@"Add\nXWalk"
             fontSize:32.0];
    
    [self setupButton:_editItemButton
             selector:@selector(editItem:)
                title:@"Edit\nItem"
             fontSize:32.0];
    
    [self setupButton:_rampTypeButton
             selector:@selector(rampType:)
                title:[NSString stringWithFormat:@"Ramp\nType %li", ((long)_currentRampType + 1)]
             fontSize:32.0];
}

- (void)setupButton:(UIButton *)button
           selector:(SEL)selector
              title:(NSString *)title
           fontSize:(CGFloat)fontSize
{
    button.backgroundColor = UserDefaults.defaults.appleBlue;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.layer.borderColor = UIColor.whiteColor.CGColor;
    button.layer.borderWidth = 2.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    button.titleLabel.numberOfLines = 2;
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateSelected];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)setupZoomSC
{
    NSArray *itemArray = [NSArray arrayWithObjects:@"In", @"Out", nil];
    _zoomSC = [[UISegmentedControl alloc] initWithItems:itemArray];
    _zoomSC.frame = CGRectMake(16.0, 973.0, 284.0, 36.0);
    _zoomSC.backgroundColor = UserDefaults.defaults.appleBlue;
    _zoomSC.layer.cornerRadius = 10.0;
    _zoomSC.clipsToBounds = YES;
    _zoomSC.tintColor = UIColor.whiteColor;
    _zoomSC.layer.borderColor = UIColor.whiteColor.CGColor;
    _zoomSC.layer.borderWidth = 2.0;
    _zoomSC.selectedSegmentIndex = 0;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:24.0]
                                                           forKey:NSFontAttributeName];
    
    [_zoomSC setTitleTextAttributes:attributes
                           forState:UIControlStateNormal];
    
    [_zoomSC addTarget:self
                action:@selector(zoomChanged:)
      forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_zoomSC];
}

- (void)setupRampButtons
{
    _ramp1 = [NVRampButton addToView:self.view
                                 tag:1
                               title:@"1"];
    
    _ramp2 = [NVRampButton addToView:self.view
                                 tag:2
                               title:@"2"];
    
    _ramp3 = [NVRampButton addToView:self.view
                                 tag:3
                               title:@"3"];
    
    _ramp4 = [NVRampButton addToView:self.view
                                 tag:4
                               title:@"4"];
    
    _ramp5 = [NVRampButton addToView:self.view
                                 tag:5
                               title:@"5"];
    
    _ramp6 = [NVRampButton addToView:self.view
                                 tag:6
                               title:@"6"];
    
    _ramp7 = [NVRampButton addToView:self.view
                                 tag:7
                               title:@"7"];
    
    _ramp8 = [NVRampButton addToView:self.view
                                 tag:8
                               title:@"8"];
    
    _ramp23 = [NVRampButton addToView:self.view
                                 tag:9
                               title:@"23"];
    
    _ramp45 = [NVRampButton addToView:self.view
                                 tag:10
                               title:@"45"];
    
    _ramp67 = [NVRampButton addToView:self.view
                                 tag:11
                               title:@"67"];
    
    _ramp81 = [NVRampButton addToView:self.view
                                 tag:12
                               title:@"81"];
    
    [self addTargets:_ramp1];
    [self addTargets:_ramp2];
    [self addTargets:_ramp3];
    [self addTargets:_ramp4];
    [self addTargets:_ramp5];
    [self addTargets:_ramp6];
    [self addTargets:_ramp7];
    [self addTargets:_ramp8];
    [self addTargets:_ramp23];
    [self addTargets:_ramp45];
    [self addTargets:_ramp67];
    [self addTargets:_ramp81];
}

- (void)setupXWalkButtons
{
    _xWalkA = [NVXWalkButton addToView:self.view
                                   tag:13
                                 title:@"A"];
    
    _xWalkB = [NVXWalkButton addToView:self.view
                                   tag:14
                                 title:@"B"];
    
    _xWalkC = [NVXWalkButton addToView:self.view
                                   tag:15
                                 title:@"C"];
    
    _xWalkD = [NVXWalkButton addToView:self.view
                                   tag:16
                                 title:@"D"];
    
    [self addTargets:_xWalkA];
    [self addTargets:_xWalkB];
    [self addTargets:_xWalkC];
    [self addTargets:_xWalkD];
}

- (void)setupSignalButtons
{
    _signal23 = [NVSignalButton addToView:self.view
                                      tag:17
                                    title:@"S23"];
    
    _signal45 = [NVSignalButton addToView:self.view
                                      tag:18
                                    title:@"S45"];
    
    _signal67 = [NVSignalButton addToView:self.view
                                      tag:19
                                    title:@"S67"];
    
    _signal81 = [NVSignalButton addToView:self.view
                                      tag:20
                                    title:@"S81"];
    
    [self addTargets:_signal23];
    [self addTargets:_signal45];
    [self addTargets:_signal67];
    [self addTargets:_signal81];
}

- (void)addTargets:(UIButton *)button
{
    [button addTarget:self
               action:@selector(buttonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [button addTarget:self
               action:@selector(wasDragged:withEvent:)
     forControlEvents:UIControlEventTouchDragInside];
}

- (void)zoomChanged:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
            _currentZoom = 21;
            break;
            
        case 1:
            _currentZoom = 20;
            break;
            
        default:
            break;
    }
    
    [self setBKImage:NO];
}

- (void)done:(UIButton *)button
{
    [_currentIntersection setRampsXWalkAndSignal];
    
    if (_delegate)
    {
        [_delegate inventoryViewController:self
                           didSetInventory:_currentIntersection];
    }
}

- (void)cancel:(UIButton *)button
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:@"Do you really want to cancel all changes to this intersection?"
                                               buttonTextArray:@[@"NO", @"YES"]
                                              destructiveIndex:2];
    alert.tag = 999;
}

- (void)addRamp:(UIButton *)button
{
    if (!_addRampButton.selected)
    {
        [self deselectAll];
        _addRampButton.selected = YES;
        _updateOption = NVUpdateOptionAddRamp;
    }
    
    else
    {
        _addRampButton.selected = NO;
        _updateOption = NVUpdateOptionNone;
    }
    
    [self updateBottomButtonAppearance];
}

- (void)addSignal:(UIButton *)button
{
    if (!_addSignalButton.selected)
    {
        [self deselectAll];
        _addSignalButton.selected = YES;
        _updateOption = NVUpdateOptionAddSignal;
    }
    
    else
    {
        _addSignalButton.selected = NO;
        _updateOption = NVUpdateOptionNone;
    }
    
    [self updateBottomButtonAppearance];
}

- (void)addXWalk:(UIButton *)button
{
    if (!_addXWalkButton.selected)
    {
        [self deselectAll];
        _addXWalkButton.selected = YES;
        _updateOption = NVUpdateOptionAddXWalk;
    }
    
    else
    {
        _addXWalkButton.selected = NO;
        _updateOption = NVUpdateOptionNone;
    }
    
    [self updateBottomButtonAppearance];
}

- (void)editItem:(UIButton *)button
{
    if (!_editItemButton.selected)
    {
        [self deselectAll];
        _editItemButton.selected = YES;
        _updateOption = NVUpdateOptionEdit;
    }
    
    else
    {
        _editItemButton.selected = NO;
        _updateOption = NVUpdateOptionNone;
    }
    
    [self updateBottomButtonAppearance];
}

- (void)buttonTapped:(UIButton *)button
{
    if (_updateOption != NVUpdateOptionEdit)
        return;
    
    [self performItemEdit:button];
}

- (void)performItemEdit:(UIButton *)button
{
    _currentEditButton = button;
    NVAlertView *alert = nil;
#pragma unused(alert)
    
    if ([button isKindOfClass:NVXWalkButton.class])
    {
        alert = [NVAlertView showLargeAlertViewinView:self.view
                                             delegate:self
                                                title:@"Edit XWalk"
                                      buttonTextArray:@[@"Cancel", @"Delete"]
                                     destructiveIndex:2];
    }
    
    else if ([button isKindOfClass:NVSignalButton.class])
    {
        alert = [NVAlertView showLargeAlertViewinView:self.view
                                             delegate:self
                                                title:@"Edit Signal"
                                      buttonTextArray:@[@"Cancel", @"Delete"]
                                     destructiveIndex:2];
    }
    
    else
    {
        NSArray *rampOptions = nil;
        MPRamp *ramp = _currentIntersection.ramps[_currentEditButton.tag];
        
        if ([self isMiddleRamp:_currentEditButton.tag] && [self isMiddleRampType:ramp.rampType])
            rampOptions = @[@"Cancel", @"Delete", @"Change Ramp Type"];
        
        else
        {
            rampOptions = @[@"Cancel", @"Delete", @"Change Ramp Type", @"Change to Left Ramp",
                            @"Change to Middle Ramp", @"Change to Right Ramp"];
        }
        
        alert = [NVAlertView showLargeAlertViewinView:self.view
                                             delegate:self
                                                title:@"Edit Ramp"
                                      buttonTextArray:rampOptions
                                     destructiveIndex:2];
    }
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:YES];
    
    int rampID = 0, switchWith = 0;
    
    if (alertView.tag == 999 && buttonIndex == 1)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
    
    switch (buttonIndex)
    {
        case 1://delete
            if (_currentEditButton == _xWalkA)
                _currentIntersection.xWalkAExists = NO;
            
            else if (_currentEditButton == _xWalkB)
                _currentIntersection.xWalkBExists = NO;
            
            else if (_currentEditButton == _xWalkC)
                _currentIntersection.xWalkCExists = NO;
            
            else if (_currentEditButton == _xWalkD)
                _currentIntersection.xWalkDExists = NO;
            
            else if (_currentEditButton == _signal81)
                _currentIntersection.signal81Exists = NO;
            
            else if (_currentEditButton == _signal23)
                _currentIntersection.signal23Exists = NO;
            
            else if (_currentEditButton == _signal45)
                _currentIntersection.signal45Exists = NO;
            
            else if (_currentEditButton == _signal67)
                _currentIntersection.signal67Exists = NO;
            
            else if ((rampID = (int)_currentEditButton.tag))
            {
                MPRamp *ramp = _currentIntersection.ramps[rampID];
                ramp.rampExists = NO;
                ramp.isComplete = YES;
                ramp.rampType = 0;
                
                if (rampID > 8)
                {
                    MPRamp *sideRamp = _currentIntersection.ramps[[self getLeftRampIDFromRampID:rampID]];
                    sideRamp.rampExists = NO;
                    sideRamp.isComplete = YES;
                    sideRamp.rampType = 0;
                    
                    sideRamp = _currentIntersection.ramps[[self getRightRampIDFromRampID:rampID]];
                    sideRamp.rampExists = NO;
                    sideRamp.isComplete = YES;
                    sideRamp.rampType = 0;
                }
            }
            
            [self setupButtons:NO];
            break;
            
        case 2://change ramp type
            if ((rampID = (int)_currentEditButton.tag))
            {
                MPRamp *ramp = _currentIntersection.ramps[rampID];
                
                RampTypeView *rtv = [RampTypeView showRampTypeViewWithView:self.view
                                                                  delegate:self
                                                              selectedType:ramp.rampType
                                                                editOption:RampTypeEditOptionIndividual];
#pragma unused(rtv)
            }
            
            break;
            
        case 3://change to left ramp
            if ((rampID = (int)_currentEditButton.tag))
            {
                MPRamp *ramp = _currentIntersection.ramps[rampID];
                switchWith = [self getLeftRampIDFromRampID:rampID];
                
                if (switchWith > 0)
                {
                    MPRamp *switchRamp = _currentIntersection.ramps[switchWith];
                    int savex = ramp.lev21x;
                    int savey = ramp.lev21y;
                    int savear = ramp.adjustedRot;
                    CGFloat saveah = ramp.approximateHeading;
                    ramp.lev21x = switchRamp.lev21x;
                    ramp.lev21y = switchRamp.lev21y;
                    ramp.adjustedRot = switchRamp.adjustedRot;
                    ramp.approximateHeading = switchRamp.approximateHeading;
                    switchRamp.lev21x = savex;
                    switchRamp.lev21y = savey;
                    switchRamp.adjustedRot = savear;
                    switchRamp.approximateHeading = saveah;
                    switchRamp.rampType = ramp.rampType;
                    ramp.rampType = 0;
                    ramp.rampExists = NO;
                    ramp.isComplete = YES;
                    switchRamp.rampExists = YES;
                    switchRamp.isComplete = NO;
                }
            }
            
            [self setupButtons:NO];
            break;
            
        case 4://change to middle ramp
            if ((rampID = (int)_currentEditButton.tag))
            {
                MPRamp *ramp = _currentIntersection.ramps[rampID];
                switchWith = [self getMiddleRampIDFromRampID:rampID];
                int otherID = [self getOtherRampIDFromRampID:rampID];
                
                if (switchWith > 0)
                {
                    MPRamp *switchRamp = _currentIntersection.ramps[switchWith];
                    MPRamp *otherRamp = _currentIntersection.ramps[otherID];
                    int savex = ramp.lev21x;
                    int savey = ramp.lev21y;
                    int savear = ramp.adjustedRot;
                    CGFloat saveah = ramp.approximateHeading;
                    ramp.lev21x = switchRamp.lev21x;
                    ramp.lev21y = switchRamp.lev21y;
                    ramp.adjustedRot = switchRamp.adjustedRot;
                    ramp.approximateHeading = switchRamp.approximateHeading;
                    switchRamp.lev21x = savex;
                    switchRamp.lev21y = savey;
                    switchRamp.adjustedRot = savear;
                    switchRamp.approximateHeading = saveah;
                    switchRamp.rampType = ramp.rampType;
                    ramp.rampType = 0;
                    ramp.rampExists = NO;
                    ramp.isComplete = YES;
                    switchRamp.rampExists = YES;
                    switchRamp.isComplete = NO;
                    otherRamp.rampType = 0;
                    otherRamp.rampExists = NO;
                    otherRamp.isComplete = YES;
                    
                    if ([self isCombinedRampType:switchRamp.rampType])
                        [self addSideRamps:switchRamp];
                }
            }
            
            [self setupButtons:NO];
            break;
            
        case 5://change to right ramp
            if ((rampID = (int)_currentEditButton.tag))
            {
                MPRamp *ramp = _currentIntersection.ramps[rampID];
                switchWith = [self getRightRampIDFromRampID:rampID];
                
                if (switchWith > 0)
                {
                    MPRamp *switchRamp = _currentIntersection.ramps[switchWith];
                    int savex = ramp.lev21x;
                    int savey = ramp.lev21y;
                    int savear = ramp.adjustedRot;
                    CGFloat saveah = ramp.approximateHeading;
                    ramp.lev21x = switchRamp.lev21x;
                    ramp.lev21y = switchRamp.lev21y;
                    ramp.adjustedRot = switchRamp.adjustedRot;
                    ramp.approximateHeading = switchRamp.approximateHeading;
                    switchRamp.lev21x = savex;
                    switchRamp.lev21y = savey;
                    switchRamp.adjustedRot = savear;
                    switchRamp.approximateHeading = saveah;
                    switchRamp.rampType = ramp.rampType;
                    ramp.rampType = 0;
                    ramp.rampExists = NO;
                    ramp.isComplete = YES;
                    switchRamp.rampExists = YES;
                    switchRamp.isComplete = NO;
                }
            }
            
            [self setupButtons:NO];
            break;
    }
    
    _editItemButton.selected = NO;
    _updateOption = NVUpdateOptionNone;
    [self updateBottomButtonAppearance];
}

- (void)rampType:(UIButton *)button
{
    RampTypeView *rtv = [RampTypeView showRampTypeViewWithView:self.view
                                                      delegate:self
                                                  selectedType:_currentRampType
                                                    editOption:RampTypeEditOptionGlobal];
#pragma unused(rtv)
}

//this method is called continuosly while the button is being dragged
- (void)wasDragged:(UIButton *)button
         withEvent:(UIEvent *)event
{
    if (_addRampButton.selected || _addXWalkButton.selected ||
        _addSignalButton.selected || _editItemButton.selected)
    {
        return;
    }
    
    else
    {
        if (_firstTime)
        {
            //add target to handle when dragging is completed (only once per drag)
            [button addTarget:self
                       action:@selector(finishedDragging:withEvent:)
             forControlEvents:UIControlEventTouchUpInside];
            
            _updateOption = NVUpdateOptionMove;
            _firstTime = NO;
        }
        
        UITouch *touch = [[event touchesForView:button] anyObject];
        CGPoint previousLocation = [touch previousLocationInView:button];
        CGPoint location = [touch locationInView:button];
        CGFloat deltaX = (location.x - previousLocation.x);
        CGFloat deltaY = (location.y - previousLocation.y);
        
        CGPoint newCenter = CGPointMake(button.center.x + deltaX,
                                        button.center.y + deltaY);
        
        if (newCenter.x > (_backgroundImage.frame.origin.x + (button.frame.size.width / 2.0)) &&
            newCenter.x < ((_backgroundImage.frame.origin.x + _backgroundImage.frame.size.width) - (button.frame.size.width / 2.0)) &&
            newCenter.y > (_backgroundImage.frame.origin.y + (button.frame.size.height / 2.0)) &&
            newCenter.y < ((_backgroundImage.frame.origin.y + _backgroundImage.frame.size.height) - (button.frame.size.height / 2.0)))
        {
            button.center = newCenter;
        }
    }
}

//this method is only called after user finishes dragging button
- (void)finishedDragging:(UIButton *)button
               withEvent:(UIEvent *)event
{
    _firstTime = YES;
    _currentEditButton = button;
    
    CGPoint location = CGPointMake((button.frame.origin.x + (button.frame.size.width / 2.0)),
                                   (button.frame.origin.y + (button.frame.size.height / 2.0)));
    
    [self updateButtons:location];
    
    //need to clear out touchUpInside targets
    [button removeTarget:self
                  action:@selector(finishedDragging:withEvent:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [button removeTarget:self
                  action:@selector(buttonTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    
    //need to add back the buttonTapped touchUpInside target
    [button addTarget:self
               action:@selector(buttonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    _updateOption = NVUpdateOptionNone;
}

- (void)pointPicked:(UIGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.view];
    [self updateButtons:location];
}

- (void)updateButtons:(CGPoint)location
{
    double x = 0.0, y = 0.0;
    CGRect windowBounds = CGRectZero;
    CGSize imageSize = CGSizeZero;
    int xWalkID = 0, signalID = 0, rampID = 0;
    
    if (_updateOption == NVUpdateOptionEdit ||
        _updateOption == NVUpdateOptionNone)
    {
        return;
    }
    
    _imageName = [NSString stringWithFormat:@"%i", _currentIntersection.intID];
    
    if (_pTranBMPToW)
        free(_pTranBMPToW);
    
    if (_pTranWToBMP)
        free(_pTranWToBMP);
    
    _pTranBMPToW = LoadTranFromCPT(_pathToBPWFile.UTF8String, 1);
    _pTranWToBMP = LoadTranFromCPT(_pathToBPWFile.UTF8String, 2);
    
    windowBounds = _backgroundImage.frame;
    //imageSize = _backgroundImage.image.size;
    imageSize = _backgroundImage.intrinsicContentSize;
    x = windowBounds.size.width;
    y = windowBounds.size.height;
    _xFactor = (CGFloat)imageSize.width / (CGFloat)windowBounds.size.width;
    _yFactor = (CGFloat)imageSize.height / (CGFloat)windowBounds.size.height;
    _xOffset = (windowBounds.origin.x * _xFactor);
    _yOffset = (windowBounds.origin.y * _yFactor);
    
    location.x *= _xFactor;
    location.y *= _yFactor;
    
    location.y -= _yOffset;
    location.x -= _xOffset;
    
    TRANS2(location.x, location.y, &x, &y, _pTranBMPToW);
    
    switch (_updateOption)
    {
        case NVUpdateOptionMove:
            if (_currentEditButton == _xWalkA)
            {
                _currentIntersection.xWalkAlev21x = x;
                _currentIntersection.xWalkAlev21y = y;
            }
            
            else if (_currentEditButton == _xWalkB)
            {
                _currentIntersection.xWalkBlev21x = x;
                _currentIntersection.xWalkBlev21y = y;
            }
            
            else if (_currentEditButton == _xWalkC)
            {
                _currentIntersection.xWalkClev21x = x;
                _currentIntersection.xWalkClev21y = y;
            }
            
            else if (_currentEditButton == _xWalkD)
            {
                _currentIntersection.xWalkDlev21x = x;
                _currentIntersection.xWalkDlev21y = y;
            }

            else if (_currentEditButton == _signal23)
            {
                _currentIntersection.signal23lev21x = x;
                _currentIntersection.signal23lev21y = y;
            }
            
            else if (_currentEditButton == _signal45)
            {
                _currentIntersection.signal45lev21x = x;
                _currentIntersection.signal45lev21y = y;
            }
            
            else if (_currentEditButton == _signal67)
            {
                _currentIntersection.signal67lev21x = x;
                _currentIntersection.signal67lev21y = y;
            }
            
            else if (_currentEditButton == _signal81)
            {
                _currentIntersection.signal81lev21x = x;
                _currentIntersection.signal81lev21y = y;
            }
            
            else
            {
                rampID = (int)_currentEditButton.tag;
                
                if (rampID > 0)
                {
                    MPRamp *ramp = _currentIntersection.ramps[rampID];
                    
                    ramp.lev21x = x;
                    ramp.lev21y = y;
                    
                    if ([self isCombinedRampType:[(NVRampButton *)_currentEditButton type]])
                    {
                        MPRamp *leftRamp = _currentIntersection.ramps[[self getLeftRampIDFromRampID:rampID]];
                        MPRamp *rightRamp = _currentIntersection.ramps[[self getRightRampIDFromRampID:rampID]];
                        
                        CGFloat d = LDIST(_currentIntersection.lev21x, _currentIntersection.lev21y, ramp.lev21x, ramp.lev21y);
                        CGFloat az = LGETAZ(_currentIntersection.lev21x, _currentIntersection.lev21y, ramp.lev21x, ramp.lev21y);
                        dvec2 pt = {_currentIntersection.lev21x, _currentIntersection.lev21y};
                        dvec2 np = dnewpt(&pt, (az - (HALFPI / 6)), d);
                        leftRamp.lev21x = np.x;
                        leftRamp.lev21y = np.y;
                        
                        np = dnewpt(&pt, (az + (HALFPI / 6)), d);
                        rightRamp.lev21x = np.x;
                        rightRamp.lev21y = np.y;
                    }
                }
            }
            
            _updateOption = NVUpdateOptionNone;
            break;
            
        case NVUpdateOptionAddRamp:
        {
            int switchWith = 0;
            
            rampID = [self getXRampIDFromX:x
                                      andY:y
                          switchWithRampID:&switchWith];
            
            int middleID = [self getMiddleRampIDFromRampID:rampID];
            MPRamp *middleRamp = _currentIntersection.ramps[middleID];
            
            if (middleRamp.rampExists)
                return;
            
            if (rampID > 0)
            {
                MPRamp *ramp = _currentIntersection.ramps[rampID];
                DPOINT pt = {0.0,0.0}, midPt = {0.0, 0.0};
                CGFloat az = 0.0;
                ramp.rampType = _currentRampType;
                ramp.rampExists = YES;
                ramp.isComplete = NO;
                ramp.lev21x = x;
                ramp.lev21y = y;
                pt.x = x;
                pt.y = y;
                midPt.x = _currentIntersection.lev21x;
                midPt.y = _currentIntersection.lev21y;
                az = getazd(&midPt, &pt);
                ramp.adjustedRot = Between0And360(ClockwiseDegFromNorth ((az * RADtoDEG) + _currentIntersection.intRotation));
                ramp.approximateHeading = Between0And360(az*RADtoDEG);
                
                if (switchWith < 0)
                    switchWith = -switchWith;
                
                MPRamp *switchRamp = _currentIntersection.ramps[switchWith];
                
                if (ramp.adjustedRot < switchRamp.adjustedRot)
                {
                    int savex = ramp.lev21x;
                    int savey = ramp.lev21y;
                    int savear = ramp.adjustedRot;
                    CGFloat saveah = ramp.approximateHeading;
                    RampType savert = ramp.rampType;
                    ramp.lev21x = switchRamp.lev21x;
                    ramp.lev21y = switchRamp.lev21y;
                    ramp.adjustedRot = switchRamp.adjustedRot;
                    ramp.approximateHeading = switchRamp.approximateHeading;
                    ramp.rampType = switchRamp.rampType;
                    switchRamp.lev21x = savex;
                    switchRamp.lev21y = savey;
                    switchRamp.adjustedRot = savear;
                    switchRamp.approximateHeading = saveah;
                    switchRamp.rampType = savert;
                }
                
                if ([self isMiddleRampType:_currentRampType])
                {
                    _currentEditButton = (UIButton *)[self.view viewWithTag:rampID];
                    
                    [self alertView:nil
                didTapButtonAtIndex:4];
                    
                    ramp = _currentIntersection.ramps[[self getMiddleRampIDFromRampID:ramp.rampNum]];
                    
                    if ([self isCombinedRampType:ramp.rampType])
                        [self addSideRamps:ramp];
                }
            }
        }
            break;
            
        case NVUpdateOptionAddXWalk:
            xWalkID = [self getXWalkIDFromX:x
                                       andY:y];
            
            switch (xWalkID)
        {
            case 1://A
                _currentIntersection.xWalkAExists = YES;
                _currentIntersection.xWalkAlev21x = x;
                _currentIntersection.xWalkAlev21y = y;
                break;
                
            case 2://B
                _currentIntersection.xWalkBExists = YES;
                _currentIntersection.xWalkBlev21x = x;
                _currentIntersection.xWalkBlev21y = y;
                break;
                
            case 3://C
                _currentIntersection.xWalkCExists = YES;
                _currentIntersection.xWalkClev21x = x;
                _currentIntersection.xWalkClev21y = y;
                break;
                
            case 4://D
                _currentIntersection.xWalkDExists = YES;
                _currentIntersection.xWalkDlev21x = x;
                _currentIntersection.xWalkDlev21y = y;
                break;
        }
            break;
            
        case NVUpdateOptionAddSignal:
            signalID = [self getSignalIDFromX:x
                                         andY:y];
            
            switch (signalID)
        {
            case 81:
                _currentIntersection.signal81Exists = YES;
                _currentIntersection.signal81lev21x = x;
                _currentIntersection.signal81lev21y = y;
                break;
                
            case 23:
                _currentIntersection.signal23Exists = YES;
                _currentIntersection.signal23lev21x = x;
                _currentIntersection.signal23lev21y = y;
                break;
                
            case 45:
                _currentIntersection.signal45Exists = YES;
                _currentIntersection.signal45lev21x = x;
                _currentIntersection.signal45lev21y = y;
                break;
                
            case 67:
                _currentIntersection.signal67Exists = YES;
                _currentIntersection.signal67lev21x = x;
                _currentIntersection.signal67lev21y = y;
                break;
        }
            break;
            
        default:
            break;
    }
    
    if (_updateOption == NVUpdateOptionMove)
    {
        _updateOption = NVUpdateOptionEdit;
        [self setupButtons:NO];
    }
    
    else
        [self setupButtons:NO];
}

- (void)addSideRamps:(MPRamp *)ramp
{
    _updateOption = NVUpdateOptionAddRamp;
    
    MPRamp *sideRamp = _currentIntersection.ramps[[self getLeftRampIDFromRampID:ramp.rampNum]];
    
    if (ramp.rampType == RampTypeCombPerpWalk)
        sideRamp.rampType = RampTypeCombLeftWalk;
    
    else
        sideRamp.rampType = RampTypeCombLeftNonWalk;
    
    sideRamp.rampExists = YES;
    sideRamp.isComplete = NO;
    CGFloat d = LDIST(_currentIntersection.lev21x, _currentIntersection.lev21y,ramp.lev21x, ramp.lev21y);
    CGFloat az = LGETAZ(_currentIntersection.lev21x, _currentIntersection.lev21y,ramp.lev21x, ramp.lev21y);
    dvec2 pt = {_currentIntersection.lev21x, _currentIntersection.lev21y};
    dvec2 np = dnewpt(&pt, (az - (HALFPI / 6)), d);
    sideRamp.lev21x = np.x;
    sideRamp.lev21y = np.y;
    ramp.adjustedRot = Between0And360(ClockwiseDegFromNorth ((az * RADtoDEG) + _currentIntersection.intRotation));
    ramp.approximateHeading = Between0And360(az*RADtoDEG);
    
    sideRamp = _currentIntersection.ramps[[self getRightRampIDFromRampID:ramp.rampNum]];
    
    if (ramp.rampType == RampTypeCombPerpWalk)
        sideRamp.rampType = RampTypeCombRightWalk;
    else
        sideRamp.rampType = RampTypeCombRightNonWalk;
    
    sideRamp.rampExists = YES;
    sideRamp.isComplete = NO;
    d = LDIST(_currentIntersection.lev21x, _currentIntersection.lev21y,ramp.lev21x, ramp.lev21y);
    az = LGETAZ(_currentIntersection.lev21x, _currentIntersection.lev21y,ramp.lev21x, ramp.lev21y);
    pt.x = _currentIntersection.lev21x;
    pt.y = _currentIntersection.lev21y;
    np = dnewpt(&pt, (az + (HALFPI / 6)), d);
    sideRamp.lev21x = np.x;
    sideRamp.lev21y = np.y;
    ramp.adjustedRot = Between0And360(ClockwiseDegFromNorth ((az * RADtoDEG) + _currentIntersection.intRotation));
    ramp.approximateHeading = Between0And360(az*RADtoDEG);
}

- (int)getXRampIDFromX:(int)x
                  andY:(int)y
      switchWithRampID:(int *)switchID
{
    int corner = [CRAPI.sharedInstance getCornerFromX:x
                                                 andY:y
                                       atIntersection:_currentIntersection];
    
    int rampID = -1;
    MPRamp *ramp1 = nil, *ramp2 = nil;
    *switchID = 0;
    
    switch (corner)
    {
        case 81:
            ramp1 = _currentIntersection.ramps[8];
            ramp2 = _currentIntersection.ramps[1];
            
            if (ramp1.rampExists && ramp2.rampExists)
                break;
            
            if (ramp1.rampExists)
            {
                rampID = 1;
                *switchID = 8;
            }
            
            else if (ramp2.rampExists)
            {
                rampID = 8;
                *switchID = -1;
            }
            
            else
                rampID = 8;
            
            break;
            
        case 23:
            ramp1 = _currentIntersection.ramps[2];
            ramp2 = _currentIntersection.ramps[3];
            
            if (ramp1.rampExists && ramp2.rampExists)
                break;
            
            if (ramp1.rampExists)
            {
                rampID = 3;
                *switchID = 2;
            }
            
            else if (ramp2.rampExists)
            {
                rampID = 2;
                *switchID = -3;
            }
            
            else
                rampID = 2;
            
            break;
            
        case 45:
            ramp1 = _currentIntersection.ramps[4];
            ramp2 = _currentIntersection.ramps[5];
            
            if (ramp1.rampExists && ramp2.rampExists)
                break;
            
            if (ramp1.rampExists)
            {
                rampID = 5;
                *switchID = 4;
            }
            
            else if (ramp2.rampExists)
            {
                rampID = 4;
                *switchID = -5;
            }
            
            else
                rampID = 4;
            
            break;
            
        case 67:
            ramp1 = _currentIntersection.ramps[6];
            ramp2 = _currentIntersection.ramps[7];
            
            if (ramp1.rampExists && ramp2.rampExists)
                break;
            
            if (ramp1.rampExists)
            {
                rampID = 7;
                *switchID = 6;
            }
            
            else if (ramp2.rampExists)
            {
                rampID = 6;
                *switchID = -7;
            }
            
            else
                rampID = 6;
            
            break;
    }
    
    return rampID;
}

- (int)getXWalkIDFromX:(int)x
                  andY:(int)y
{
    int xwalknum = [CRAPI.sharedInstance getQuadDeviderFromX:x
                                                        andY:y
                                              atIntersection:_currentIntersection];
    return xwalknum;
}

- (int)getSignalIDFromX:(int)x
                   andY:(int)y
{
    int corner = [CRAPI.sharedInstance getCornerFromX:x
                                                 andY:y
                                       atIntersection:_currentIntersection];
    return corner;
}

- (void)updateBottomButtonAppearance
{
    [self setButtonAppearance:_addRampButton];
    [self setButtonAppearance:_addXWalkButton];
    [self setButtonAppearance:_addSignalButton];
    [self setButtonAppearance:_editItemButton];
}

- (void)setButtonAppearance:(UIButton *)button
{
    if (button.selected)
        button.backgroundColor = UIColor.whiteColor;
    
    else
        button.backgroundColor = UserDefaults.defaults.appleBlue;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)heading
{
    _headingLabel.text = [NSString stringWithFormat:@"%i", (int)heading.trueHeading];
}

- (int)getLeftRampIDFromRampID:(int)rampID
{
    int rtn = 0;
    
    switch (rampID)
    {
        case 8:
        case 12:
            rtn = 1;
            break;
        case 2:
        case 9:
            rtn = 3;
            break;
        case 4:
        case 10:
            rtn = 5;
            break;
        case 6:
        case 11:
            rtn = 7;
            break;
    }
    
    return rtn;
}

- (int)getRightRampIDFromRampID:(int)rampID
{
    int rtn = 0;
    
    switch (rampID)
    {
        case 1:
        case 12:
            rtn = 8;
            break;
        case 3:
        case 9:
            rtn = 2;
            break;
        case 5:
        case 10:
            rtn = 4;
            break;
        case 7:
        case 11:
            rtn = 6;
            break;
    }
    
    return rtn;
}

- (int)getMiddleRampIDFromRampID:(int)rampID
{
    int rtn = 0;
    
    switch (rampID)
    {
        case 1:
        case 8:
            rtn = 12;
            break;
        case 3:
        case 2:
            rtn = 9;
            break;
        case 5:
        case 4:
            rtn = 10;
            break;
        case 7:
        case 6:
            rtn = 11;
            break;
    }
    
    return rtn;
}

- (int)getOtherRampIDFromRampID:(int)rampID
{
    int rtn = 0;
    
    switch (rampID)
    {
        case 1:
            rtn = 8;
            break;
        case 2:
            rtn = 3;
            break;
        case 3:
            rtn = 2;
            break;
        case 4:
            rtn = 5;
            break;
        case 5:
            rtn = 4;
            break;
        case 6:
            rtn = 7;
            break;
        case 7:
            rtn = 6;
            break;
        case 8:
            rtn = 1;
            break;
    }
    
    return rtn;
}

- (BOOL)isMiddleRamp:(NSInteger)tag
{
    BOOL rtn = NO;
    
    if (tag > 8)
        rtn = YES;
    
    return rtn;
}

- (BOOL)isMiddleRampType:(RampType)rampType
{
    BOOL rtn = NO;
    
    if (rampType == RampTypeCombPerpNonWalk ||
        rampType == RampTypeCombPerpWalk ||
        rampType == RampTypeDepressedCorner ||
        rampType == RampTypeFan)
    {
        rtn = YES;
    }
    
    return rtn;
}

- (BOOL)isCombinedRampType:(RampType)rampType
{
    BOOL rtn = NO;
    
    if (rampType == RampTypeCombPerpNonWalk ||
        rampType == RampTypeCombPerpWalk)
    {
        rtn = YES;
    }
    
    return rtn;
}

- (void)rampTypeView:(RampTypeView *)rampTypeView
   didReturnRampType:(RampType)rampType
          editOption:(RampTypeEditOption)editOption
{
    switch (editOption)
    {
        case RampTypeEditOptionGlobal:
            if (rampType != _currentRampType)
            {
                _currentRampType = rampType;
                
                [UserDefaults.defaults saveNSInteger:rampType
                                              forKey:@"CurrentRampType"];
                
                [_rampTypeButton setTitle:[NSString stringWithFormat:@"Ramp\nType %li", ((long)_currentRampType + 1)]
                                 forState:UIControlStateNormal];
            }
            
            break;
            
        case RampTypeEditOptionIndividual:
        {
            MPRamp *ramp = _currentIntersection.ramps[_currentEditButton.tag];
            
            if ([self isCombinedRampType:ramp.rampType] &&
                ![self isCombinedRampType:rampType])
            {
                MPRamp *sideRamp = _currentIntersection.ramps[[self getLeftRampIDFromRampID:ramp.rampNum]];
                sideRamp.rampExists = NO;
                sideRamp.isComplete = YES;
                sideRamp.rampType = 0;
                
                sideRamp = _currentIntersection.ramps[[self getRightRampIDFromRampID:ramp.rampNum]];
                sideRamp.rampExists = NO;
                sideRamp.isComplete = YES;
                sideRamp.rampType = 0;
                
                [self setupButtons:NO];
            }
            
            ramp.rampType = rampType;
            
            NVRampButton *rampButton = (NVRampButton *)_currentEditButton;
            rampButton.type = rampType;
            
            if (![self isMiddleRamp:_currentEditButton.tag] && [self isMiddleRampType:rampType])
            {
                [self alertView:nil
            didTapButtonAtIndex:4];
            }
            
            else if ([self isCombinedRampType:rampType])
            {
                [self addSideRamps:ramp];
                [self setupButtons:NO];
            }
        }
            
            break;
            
        default:
            break;
    }
    
    [rampTypeView hideRampTypeView:YES];
}

- (void)setupImageTarget
{
    _imageTargetView = [[UIImageView alloc] initWithImage:UserDefaults.defaults.imageTarget];
    
    _imageTargetView.frame = CGRectMake ((_backgroundImage.frame.size.width / 2.0) - (_targetSize / 2.0),
                                         (_backgroundImage.frame.size.height / 2.0) - (_targetSize / 2.0), _targetSize, _targetSize);
    
    _imageTargetView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(targetDragged:)];
    
    gesture.cancelsTouchesInView = NO;
    
    [_imageTargetView addGestureRecognizer:gesture];
    [_backgroundImage addSubview:_imageTargetView];
}

//this method is called continuosly while the target is being dragged
- (void)targetDragged:(UIPanGestureRecognizer *)gesture
{
    //only called after the target is done being dragged
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        double x = 0.0, y = 0.0, lat = 0.0, lon = 0.0;
        TRANS2((_newTarget.x * _xFactor) - _xOffset, (_newTarget.y * _yFactor) - _yOffset + (_targetSize / 2.0), &x, &y, _pTranBMPToW);
        
        IntersectionsDatabase *database = [IntersectionsDatabase databaseForGeoid:CRAPI.sharedInstance.currentGeoid];
        IntersectionPoint *info = (IntersectionPoint *)[database getCurrentIntersectionPoint:_currentIntersectionID];
        
        PixelXYToLatLongd(x, y, _currentZoom, &lat, &lon);
        info.latitude = lat;
        info.longitude = lon;
        [database setCurrentIntersectionPoint:info];
        [self setBKImage:YES];
        
        _imageTargetView.frame = CGRectMake ((_backgroundImage.frame.size.width / 2.0) - (_targetSize / 2.0),
                                             (_backgroundImage.frame.size.height / 2.0) - (_targetSize / 2.0), _targetSize, _targetSize);
    }
    
    //called continuosly while the target is being dragged
    UIImageView *target = (UIImageView *)gesture.view;
    CGPoint translation = [gesture translationInView:target];
    
    CGPoint newTarget = CGPointMake(target.center.x + translation.x,
                                    target.center.y + translation.y);
    
    if (newTarget.x > 0.0 && newTarget.y > 0.0 &&
        newTarget.x < _backgroundImage.frame.size.width &&
        newTarget.y < _backgroundImage.frame.size.height)
    {
        _newTarget = newTarget;
        target.center = _newTarget;
        
        [gesture setTranslation:CGPointZero
                         inView:target];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end