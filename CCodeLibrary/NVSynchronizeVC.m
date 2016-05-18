//  NVSynchronizeVC.m
//  CCodeLibrary

#import "NVSynchronizeVC.h"
#import "NVProgressView.h"
#import "GeoMasterServer.h"
#import "UserDefaults.h"
#import "Colors.h"
#import "CRAPI.h"
#import "NVAlertView.h"

@interface NVSynchronizeVC () <GeoMasterServerDelegate,NVAlertViewDelegate,GSSiPopoverViewDelegate>

@property (nonatomic) UILabel *titleLabel, *dataUpLabel, *pixUpLabel, *dataDownLabel, *pixDownLabel, *overallLabel, *currentFileLabel, *connectLabel;
@property (nonatomic) UIButton *syncButton, *cancelButton, *returnButton, *connectButton;
@property (nonatomic) UISwitch *pixUpSwitch, *pixDownSwitch, *dataDownSwitch;
@property (nonatomic) NVProgressView *overallProgressView, *currentFileProgressView;
@property (nonatomic) Colors *colors;
@property int upFiles, upPix, downFiles, downPix;
@property (nonatomic) GeoMasterServer *GMServer;
@property BOOL serverOpen;
@property NSTimer *timer;
@property int numConnectionAttempts;
@property int totConnectionAttempts;
@property NSString *iPad_id;
@property NSString *iPad_name;

@end

@implementation NVSynchronizeVC
{
    GSSiPopoverView *_popoverView;
    CLLocationManager *_locationManager;
    NSInteger _selectedRow;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _iPad_id = UIDevice.currentDevice.identifierForVendor.UUIDString;
    _iPad_name = UIDevice.currentDevice.name;
   
    _popoverView = [[GSSiPopoverView alloc] initWithView:self.view];
    _popoverView.delegate = self;
    _colors = UserDefaults.defaults.defaultColors;
    self.view.backgroundColor = _colors.backgroundColor;
    _upFiles = _upPix = _downFiles = _downPix = 0;
    
    _titleLabel = UILabel.new;
    [self setupLabel:_titleLabel];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:44.0];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.numberOfLines = 2;
    _titleLabel.text = @"Synchronize\nData";
    
    _dataUpLabel = UILabel.new;
    [self setupLabel:_dataUpLabel];
    
    _pixUpLabel = UILabel.new;
    [self setupLabel:_pixUpLabel];
    
    _pixUpSwitch = UISwitch.new;
    [self setupSwitch:_pixUpSwitch];
    _pixUpSwitch.on = CRAPI.sharedInstance.uploadPix;
    
    [_pixUpSwitch addTarget:self
                     action:@selector(pixUpSwitchTapped:)
           forControlEvents:UIControlEventValueChanged];
    
    _dataDownLabel = UILabel.new;
    [self setupLabel:_dataDownLabel];
    
    _dataDownSwitch = UISwitch.new;
    [self setupSwitch:_dataDownSwitch];
    _dataDownSwitch.on = CRAPI.sharedInstance.downloadData;
    
    [_dataDownSwitch addTarget:self
                        action:@selector(dataDownSwitchTapped:)
              forControlEvents:UIControlEventValueChanged];
    
    _pixDownLabel = UILabel.new;
    [self setupLabel:_pixDownLabel];
    
    _pixDownSwitch = UISwitch.new;
    [self setupSwitch:_pixDownSwitch];
    _pixDownSwitch.on = CRAPI.sharedInstance.downloadPix;
    
    [_pixDownSwitch addTarget:self
                       action:@selector(pixDownSwitchTapped:)
             forControlEvents:UIControlEventValueChanged];
    
    [self updateLabels];
    
    _syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_syncButton];
    
    [_syncButton setTitle:@"Synchronize"
                 forState:UIControlStateNormal];
    
    [_syncButton addTarget:self
                    action:@selector(syncButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_cancelButton];
    _cancelButton.enabled = NO;
    [self updateButton:_cancelButton];
    
    [_cancelButton setTitle:@"Cancel"
                 forState:UIControlStateNormal];
    
    [_cancelButton addTarget:self
                      action:@selector(cancelButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_returnButton];
    
    [_returnButton setTitle:@" < Return "
                   forState:UIControlStateNormal];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_connectButton];
    _connectButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    
    [_connectButton setTitle:@" Connect "
                    forState:UIControlStateNormal];
    
    [_connectButton addTarget:self
                       action:@selector(connectButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
    
    _connectLabel = UILabel.new;
    [self setupLabel:_connectLabel];
    _connectLabel.textAlignment = NSTextAlignmentCenter;
    _connectLabel.font = [UIFont boldSystemFontOfSize:24.0];
    [self updateConnectLabel];
    
    _overallProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                        progressColor:UIColor.whiteColor];
    
    _currentFileProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                            progressColor:UIColor.whiteColor];
    
    _overallLabel = UILabel.new;
    [self setupLabel:_overallLabel];
    _overallLabel.textAlignment = NSTextAlignmentCenter;
    _overallLabel.font = [UIFont boldSystemFontOfSize:22.0];
    [self updateOverallProgress:0.0];
    
    _currentFileLabel = UILabel.new;
    [self setupLabel:_currentFileLabel];
    _currentFileLabel.textAlignment = NSTextAlignmentCenter;
    _currentFileLabel.font = [UIFont boldSystemFontOfSize:22.0];
    [self updateCurrentFileProgress:0.0];
    
    int numSections = 9;
    CGFloat borderWidth = 1.0;
    CGFloat margin = (40.0 + borderWidth);
    CGFloat buttonMargin = 14.0;
    CGFloat screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _connectLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _overallLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _currentFileLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _connectButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        margin = (10.0 + borderWidth);
        buttonMargin = 12.0;
    }
    
    for (int i = 0; i < numSections; i++)
    {
        UIView *sectionView = UIView.new;
        sectionView.tag = ((i + 1) * 100);
        sectionView.translatesAutoresizingMaskIntoConstraints = NO;
        sectionView.backgroundColor = UIColor.clearColor;
        sectionView.layer.borderColor = UIColor.darkGrayColor.CGColor;
        sectionView.layer.borderWidth = borderWidth;
        
        [self.view addSubview:sectionView];
        
        [sectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:-borderWidth].active = YES;
        [sectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:borderWidth].active = YES;
        
        if (i == 0)
            [sectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        
        else
        {
            if (i == (numSections - 1))
                [sectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
            
            UIView *viewOnTop = [self.view viewWithTag:(i * 100)];
            [sectionView.topAnchor constraintEqualToAnchor:viewOnTop.bottomAnchor].active = YES;
            [sectionView.heightAnchor constraintEqualToAnchor:viewOnTop.heightAnchor].active = YES;
        }
        
        switch (i)
        {
            case 0://title label
                [sectionView addSubview:_returnButton];
                [_returnButton.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_returnButton.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:buttonMargin].active = YES;
                [_returnButton.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor constant:-buttonMargin].active = YES;
                
                [sectionView addSubview:_connectLabel];
                [_connectLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor].active = YES;
                [_connectLabel.widthAnchor constraintEqualToAnchor:_returnButton.widthAnchor].active = YES;
                [_connectLabel.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-buttonMargin].active = YES;
                
                [sectionView addSubview:_connectButton];
                [_connectButton.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_connectButton.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-buttonMargin].active = YES;
                [_connectButton.widthAnchor constraintEqualToAnchor:_returnButton.widthAnchor].active = YES;
                [_connectButton.bottomAnchor constraintEqualToAnchor:_connectLabel.topAnchor].active = YES;
                
                [sectionView addSubview:_titleLabel];
                [_titleLabel.leadingAnchor constraintEqualToAnchor:_returnButton.trailingAnchor constant:buttonMargin].active = YES;
                [_titleLabel.trailingAnchor constraintEqualToAnchor:_connectButton.leadingAnchor constant:-buttonMargin].active = YES;
                [_titleLabel.topAnchor constraintEqualToAnchor:sectionView.topAnchor].active = YES;
                [_titleLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor].active = YES;
                break;
                
            case 1://data files to be uploaded
                [sectionView addSubview:_dataUpLabel];
                [_dataUpLabel constrainToView:sectionView leading:margin trailing:-margin top:0.0 bottom:0.0];
                break;
                
            case 2://pictures to be uploaded
                [sectionView addSubview:_pixUpSwitch];
                [_pixUpSwitch.centerYAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                [_pixUpSwitch.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                
                [sectionView addSubview:_pixUpLabel];
                [_pixUpLabel.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_pixUpLabel.trailingAnchor constraintEqualToAnchor:_pixUpSwitch.leadingAnchor].active = YES;
                [_pixUpLabel.topAnchor constraintEqualToAnchor:sectionView.topAnchor].active = YES;
                [_pixUpLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor].active = YES;
                break;
                
            case 3://data files to be downloaded
                [sectionView addSubview:_dataDownSwitch];
                [_dataDownSwitch.centerYAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                [_dataDownSwitch.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                
                [sectionView addSubview:_dataDownLabel];
                [_dataDownLabel.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_dataDownLabel.trailingAnchor constraintEqualToAnchor:_pixUpSwitch.leadingAnchor].active = YES;
                [_dataDownLabel.topAnchor constraintEqualToAnchor:sectionView.topAnchor].active = YES;
                [_dataDownLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor].active = YES;
                break;
                
            case 4://pictures to be downloaded
                [sectionView addSubview:_pixDownSwitch];
                [_pixDownSwitch.centerYAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                [_pixDownSwitch.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                
                [sectionView addSubview:_pixDownLabel];
                [_pixDownLabel.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_pixDownLabel.trailingAnchor constraintEqualToAnchor:_pixUpSwitch.leadingAnchor].active = YES;
                [_pixDownLabel.topAnchor constraintEqualToAnchor:sectionView.topAnchor].active = YES;
                [_pixDownLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor].active = YES;
                break;
                
            case 5://sync button
                [sectionView addSubview:_syncButton];
                [_syncButton constrainToView:sectionView leading:(screenWidth / 4.0) trailing:(-screenWidth / 4.0) top:buttonMargin bottom:-buttonMargin];
                break;
                
            case 6://overall progress
                [sectionView addSubview:_overallProgressView];
                [_overallProgressView.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_overallProgressView.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                [_overallProgressView.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_overallProgressView.bottomAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                
                [sectionView addSubview:_overallLabel];
                [_overallLabel.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_overallLabel.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                [_overallLabel.topAnchor constraintEqualToAnchor:_overallProgressView.bottomAnchor].active = YES;
                [_overallLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor constant:-buttonMargin].active = YES;
                break;
                
            case 7://current file progress
                [sectionView addSubview:_currentFileProgressView];
                [_currentFileProgressView.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_currentFileProgressView.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                [_currentFileProgressView.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_currentFileProgressView.bottomAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                
                [sectionView addSubview:_currentFileLabel];
                [_currentFileLabel.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:margin].active = YES;
                [_currentFileLabel.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-margin].active = YES;
                [_currentFileLabel.topAnchor constraintEqualToAnchor:_currentFileProgressView.bottomAnchor].active = YES;
                [_currentFileLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor constant:-buttonMargin].active = YES;
                break;
                
            case 8://cancel button
                [sectionView addSubview:_cancelButton];
                [_cancelButton constrainToView:sectionView leading:(screenWidth / 4.0) trailing:(-screenWidth / 4.0) top:buttonMargin bottom:-buttonMargin];
                break;
                
            default:
                break;
        }
    }
    
    _GMServer = GeoMasterServer.open;
    _GMServer.delegate = self;
    _GMServer.messageID = GMSMessageOpenConnect;
    [_GMServer initCommunication:5.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    
    else
        return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return NO;
    
    else
        return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationPortrait;
    
    else
        return UIApplication.sharedApplication.statusBarOrientation;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self closeGMServer];
}

- (void)setupLabel:(UILabel *)label
{
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = UIColor.clearColor;
    label.textColor = _colors.textColor;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        label.font = [UIFont boldSystemFontOfSize:16.0];
    
    else
        label.font = [UIFont boldSystemFontOfSize:32.0];
    
    label.adjustsFontSizeToFitWidth = YES;
}

- (void)setupSwitch:(UISwitch *)aSwitch
{
    aSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    aSwitch.tintColor = UIColor.redColor;
}

- (void)setupButton:(UIButton *)button
{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = _colors.enabledColor;
    button.layer.cornerRadius = 10.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        button.layer.cornerRadius = 6.0;
    }
    
    else
    {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
        button.layer.cornerRadius = 10.0;
    }
    
    
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [button setTitleColor:_colors.titleColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
}

- (void)updateButton:(UIButton *)button
{
    if (button.enabled)
        button.backgroundColor = _colors.enabledColor;
    
    else
        button.backgroundColor = _colors.disabledColor;
}

- (void)updateLabels
{
    _dataUpLabel.text = [NSString stringWithFormat:@"Data Files to be Uploaded:%i", _upFiles];
    _pixUpLabel.text = [NSString stringWithFormat:@"Pictures to be Uploaded:%i", _upPix];
    _dataDownLabel.text = [NSString stringWithFormat:@"Data Files to be Downloaded:%i", _downFiles];
    _pixDownLabel.text = [NSString stringWithFormat:@"Pictures to be Downloaded:%i", _downPix];
}

- (void)updateOverallProgress:(CGFloat)progress
{
    _overallProgressView.progress = progress;
    int progressInt = (int)roundf(progress * 100.0);
    _overallLabel.text = [NSString stringWithFormat:@"Overall Progress:%i%%", progressInt];
}

- (void)updateCurrentFileProgress:(CGFloat)progress
{
    _currentFileProgressView.progress = progress;
    int progressInt = (int)roundf(progress * 100.0);
    _currentFileLabel.text = [NSString stringWithFormat:@"Current File Progress:%i%%", progressInt];
}

- (void)updateConnectLabel
{
    _connectLabel.text = [NSString stringWithFormat:@"%i-%i:%i of %i",
                          CRAPI.sharedInstance.GSSiPadNumber, CRAPI.sharedInstance.currentManageriPad,
                          CRAPI.sharedInstance.currentiPadWithinManager, CRAPI.sharedInstance.totiPadWithinManager];
}

- (void)syncButtonTapped:(UIButton *)button
{
    
}

- (void)cancelButtonTapped:(UIButton *)button
{
    
}

- (void)connectButtonTapped:(UIButton *)button
{
        _GMServer = [GeoMasterServer open];
        _GMServer.delegate = self;
        _GMServer.messageID = GMSMessageSetNearby;
        [_GMServer initCommunication:7.5];
        
        _numConnectionAttempts = 0;
        _totConnectionAttempts = 60;
        [_popoverView showAfter:0.0
                      withTitle:@"Waiting\nto Connect\nto Manager"
                      andButton:@"Cancel"];
    
    
}

- (void)closeGMServer
{
    if (_GMServer)
    {
        [_GMServer closeServer];
        _GMServer.delegate = nil;
    }
    
    _GMServer = nil;
}

- (void)GMServerDidOpen:(GeoMasterServer *)server
{
    _serverOpen = YES;
    NSString *msg;
    
    switch (server.messageID)
    {
        case GMSMessageOpenConnect:
            msg = [NSString stringWithFormat:@"$M(GetCitiesForiPad,%@)\r\n", deviceInfo()];
            break;
            
        case GMSMessageGetUploadStatus:
            msg = [NSString stringWithFormat:@"$M(GetUploadStatus,%i,%i)",
                             CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid];
            break;
        case GMSMessageSetNearby:
            msg = [NSString stringWithFormat:@"$M(SetNearbyiPad,%@,%@,%f %f)\r\n",
                   _iPad_id, _iPad_name, _locationManager.location.coordinate.latitude,
                   _locationManager.location.coordinate.longitude];
            break;
            
        case GMSMessageCheckNearby:
            msg = [NSString stringWithFormat:@"$M(CheckNearbyiPad,%@)\r\n",
                   _iPad_id];
            break;
            
        case GMSMessageCancelConnect:
            msg = [NSString stringWithFormat:@"$M(RemoveNearbyiPad,%@)\r\n",
                   _iPad_id];
            break;
    }
    
    if (msg)
        [_GMServer sendMessage:msg];
    
    NSLog(@"GMServer Query: %@", msg);
}


- (void)GMServer:(GeoMasterServer *)server
 didReceiveError:(NSString *)error
      withStatus:(long)status
{
    [self closeGMServer];
    
    NSString *titleMessage;
    
    if ([error isEqualToString:@"Internet Connection Not Available"])
        titleMessage = @"Network Error";
    
    else
        titleMessage = @"NVCRIS Server Error";
    
    UIAlertView *serverError = [[UIAlertView alloc] initWithTitle:titleMessage
                                                          message:error
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
    [serverError show];
}

- (void)GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
      withStatus:(long)status
{
    [self closeGMServer];
    NSLog(@"GMServer Message(ADASetupViewController): %@", message);
    
    if (status == GMServerStatusOK)
    {
        switch (server.messageID)
        {
            case GMSMessageOpenConnect:
            {
                [CRAPI.sharedInstance savePlacesString:message];
                
                [CRAPI.sharedInstance processPlaces];
                
                if (CRAPI.sharedInstance.placesArray.count == 0)
                {
                    UIAlertView *serverError = [[UIAlertView alloc] initWithTitle:@"No Cities"
                                                                          message:@"Please use the\nCRiS Management Module\nto assign cities\nbefore starting\nthe Preliminary Survey."
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                    
                    [serverError show];
                }
                
                _selectedRow = [UserDefaults.defaults integerForKey:@"SelectedRow"];
                
                if (CRAPI.sharedInstance.placesArray.count <= 1 || CRAPI.sharedInstance.placesArray.count <= _selectedRow ||CRAPI.sharedInstance.currentGeoid == 0)
                {
                    _selectedRow = 0;
                    [UserDefaults.defaults saveInteger:(int)_selectedRow
                                                forKey:@"SelectedRow"];
                }
                [CRAPI.sharedInstance processPlacesArray:_selectedRow];

                _locationManager = [[CLLocationManager alloc] init];
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                _locationManager.distanceFilter = kCLDistanceFilterNone;
                _locationManager.delegate = self;
                [self updateConnectLabel];
                [_locationManager startUpdatingLocation];
            }
                
                break;
                
            case GMSMessageSetNearby:
                self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                              target:self
                                                            selector:@selector(checkNearby:)
                                                            userInfo:nil
                                                             repeats:NO];
                break;
                
            case GMSMessageCheckNearby:
                if ([message isEqualToString:@"YES"] && _numConnectionAttempts++ < _totConnectionAttempts)
                {
                    CGFloat progress = 1.0 - (_numConnectionAttempts / (CGFloat)_totConnectionAttempts);
                    [_popoverView updateProgress:progress];
                    
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                  target:self
                                                                selector:@selector(checkNearby:)
                                                                userInfo:nil
                                                                 repeats:NO];
                }
                
                else
                    [_popoverView hide];
                
                break;
                
            case GMSMessageCancelConnect:
                [_popoverView hide];
                break;
        }
    }
}

    - (void)checkNearby:(NSTimer *)timer
    {
        [self.timer invalidate];
        _GMServer = [GeoMasterServer open];
        _GMServer.delegate = self;
        _GMServer.messageID = GMSMessageCheckNearby;
        [_GMServer initCommunication:7.5];
    }
    
    - (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView
    {
        [self.timer invalidate];
        [self closeGMServer];
        _GMServer = [GeoMasterServer open];
        _GMServer.delegate = self;
        _GMServer.messageID = GMSMessageCancelConnect;
        [_GMServer initCommunication:7.5];
    }
    

- (void)returnButtonTapped:(UIButton *)button
{
    [_delegate synchronizeControllerDidReturn:self];
}

- (void)pixUpSwitchTapped:(UISwitch *)aSwitch
{
    [UserDefaults.defaults saveBool:aSwitch.on
                             forKey:@"UploadPix"];
    
    CRAPI.sharedInstance.uploadPix = aSwitch.on;
}

- (void)dataDownSwitchTapped:(UISwitch *)aSwitch
{
    [UserDefaults.defaults saveBool:aSwitch.on
                             forKey:@"DownloadData"];
    
    CRAPI.sharedInstance.downloadData = aSwitch.on;
}

- (void)pixDownSwitchTapped:(UISwitch *)aSwitch
{
    [UserDefaults.defaults saveBool:aSwitch.on
                             forKey:@"DownloadPix"];
    
    CRAPI.sharedInstance.downloadPix = aSwitch.on;
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:YES];
}

@end