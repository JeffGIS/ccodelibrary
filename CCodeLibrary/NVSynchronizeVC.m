//  NVSynchronizeVC.m
//  CCodeLibrary

#import "NVSynchronizeVC.h"
#import "NVProgressView.h"
#import "FTPDataPull.h"
#import "FTPDataPush.h"
#import "UserDefaults.h"
#import "Colors.h"
#import "CRAPI.h"
#import "NVAlertView.h"
#import "NVPopoverTableView.h"
#import "CityOrOrganizationData.h"

@interface NVSynchronizeVC () <GeoMasterServerDelegate,NVAlertViewDelegate,GSSiPopoverViewDelegate,FTPDataPullDelegate,FTPDataPushDelegate,NVPopoverTableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic) UILabel *dataUpLabel, *pixUpLabel, *dataDownLabel, *pixDownLabel, *overallLabel, *currentFileLabel, *connectLabel;
@property (nonatomic) UIButton *syncButton, *cancelButton, *returnButton, *connectButton, *titleButton;
@property (nonatomic) UISwitch *pixUpSwitch, *pixDownSwitch, *dataDownSwitch;
@property (nonatomic) NVProgressView *overallProgressView;
@property (nonatomic) Colors *colors;
@property (nonatomic) GeoMasterServer *GMServer;
@property (nonatomic) GSSiPopoverView *popoverView;
@property (nonatomic) CLLocationManager *locationManager;
@property int upFiles, upPix, downFiles, downPix, numConnectionAttempts, totConnectionAttempts;;
@property BOOL serverOpen;
@property NSTimer *timer;
@property NSString *iPad_name;
@property FTPDataPush *push;
@property FTPDataPull *pull;
@property NSInteger selectedRow;

@end

@implementation NVSynchronizeVC

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _iPad_name = UIDevice.currentDevice.name;
    _popoverView = [[GSSiPopoverView alloc] initWithView:self.view];
    _popoverView.delegate = self;
    _colors = UserDefaults.defaults.defaultColors;
    self.view.backgroundColor = _colors.backgroundColor;
    _upFiles = _upPix = _downFiles = _downPix = 0;
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_titleButton];
    _titleButton.backgroundColor = UIColor.clearColor;
    _titleButton.userInteractionEnabled = NO;
    _titleButton.titleLabel.numberOfLines = 2;
    _titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_titleButton setTitleColor:_colors.textColor
                       forState:UIControlStateNormal];
    
    [_titleButton addTarget:self
                     action:@selector(titleButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_connectButton];
    
    [_connectButton setTitle:@"Connect"
                    forState:UIControlStateNormal];
    
    [_connectButton addTarget:self
                       action:@selector(connectButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
    
    _connectLabel = UILabel.new;
    [self setupLabel:_connectLabel];
    [self updateConnectLabel];
    
    _overallProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
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
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"question-256x256"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"questionMarkHighlighted"
                                                                                        ofType:@"png"]]
                forState:UIControlStateHighlighted];
    
    [helpButton addTarget:self
                   action:@selector(helpButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
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
                [sectionView addSubview:_connectLabel];
                [_connectLabel.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor].active = YES;
                [_connectLabel.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-buttonMargin].active = YES;
                
                [sectionView addSubview:_connectButton];
                [_connectButton.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_connectButton.trailingAnchor constraintEqualToAnchor:sectionView.trailingAnchor constant:-buttonMargin].active = YES;
                [_connectButton.bottomAnchor constraintEqualToAnchor:_connectLabel.topAnchor].active = YES;
                [_connectButton.widthAnchor constraintEqualToAnchor:_connectLabel.widthAnchor].active = YES;
                
                [sectionView addSubview:_returnButton];
                [_returnButton.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_returnButton.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:buttonMargin].active = YES;
                [_returnButton.bottomAnchor constraintEqualToAnchor:_connectButton.bottomAnchor].active = YES;
                [_returnButton.widthAnchor constraintEqualToAnchor:_connectButton.widthAnchor].active = YES;
                
                [sectionView addSubview:_titleButton];
                [_titleButton.leadingAnchor constraintEqualToAnchor:_returnButton.trailingAnchor constant:buttonMargin].active = YES;
                [_titleButton.trailingAnchor constraintEqualToAnchor:_connectButton.leadingAnchor constant:-buttonMargin].active = YES;
                [_titleButton.topAnchor constraintEqualToAnchor:sectionView.topAnchor constant:buttonMargin].active = YES;
                [_titleButton.bottomAnchor constraintEqualToAnchor:sectionView.bottomAnchor constant:-buttonMargin].active = YES;
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
                
            case 6://help button
                [sectionView addSubview:helpButton];
                [helpButton.heightAnchor constraintEqualToAnchor:sectionView.heightAnchor].active = YES;
                [helpButton.widthAnchor constraintEqualToAnchor:sectionView.heightAnchor].active = YES;
                [helpButton.centerXAnchor constraintEqualToAnchor:sectionView.centerXAnchor].active = YES;
                [helpButton.centerYAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                break;
                
            case 7://overall progress
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
                
            case 8://cancel button
                [sectionView addSubview:_cancelButton];
                [_cancelButton constrainToView:sectionView leading:(screenWidth / 4.0) trailing:(-screenWidth / 4.0) top:buttonMargin bottom:-buttonMargin];
                break;
                
            default:
                break;
        }
    }
    
    [self sendGMServerMessage:GMSMessageOpenConnect];
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
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self closeGMServer];
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
    SetUseDemoID(CRAPI.sharedInstance.GSSiPadNumber != 1021);
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
    button.contentEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        button.contentEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
        button.layer.cornerRadius = 6.0;
    }
    
    else
    {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
        button.layer.cornerRadius = 10.0;
    }
    
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
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
    _dataUpLabel.text = [NSString stringWithFormat:@"Data Files to be Uploaded: %i", _upFiles];
    _pixUpLabel.text = [NSString stringWithFormat:@"Pictures to be Uploaded: %i", _upPix];
    _dataDownLabel.text = [NSString stringWithFormat:@"Data Files to be Downloaded: %i", _downFiles];
    _pixDownLabel.text = [NSString stringWithFormat:@"Pictures to be Downloaded: %i", _downPix];
}

- (void)updateOverallProgress:(CGFloat)progress
{
    _overallProgressView.progress = progress;
    int progressInt = (int)roundf(progress * 100.0);
    _overallLabel.text = [NSString stringWithFormat:@"Overall Progress:%i%%", progressInt];
}

- (void)updateConnectLabel
{
    _connectLabel.text = [NSString stringWithFormat:@"%i-%i:%i of %i",
                          CRAPI.sharedInstance.GSSiPadNumber, CRAPI.sharedInstance.currentManageriPad,
                          CRAPI.sharedInstance.currentiPadWithinManager, CRAPI.sharedInstance.totiPadWithinManager];
}

- (void)syncButtonTapped:(UIButton *)button
{
    _process = UPLOAD_DATA_PROCESS;
    _uploadedFiles = 0;
    _origUpFiles = _upFiles + _upPix;
    [self getDownloadCounts:YES];
    [self updateLabels];
    [self uploadNextFile];
}

- (void)cancelButtonTapped:(UIButton *)button
{
    NSLog (@"cancel button tapped");
}

- (void)titleButtonTapped:(UIButton *)button
{
    NSMutableArray *tempArray = NSMutableArray.array;
    
    for (CityOrOrganizationData *cod in CRAPI.sharedInstance.placesArray.copy)
        [tempArray addObject:cod.name];
    
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Select City to Synchronize Data"
                                                                     textArray:tempArray.copy
                                                                 includeCancel:YES];
#pragma unused(nvptv)
}

- (void)setDatabaseIDToDB
{
    int geoid = CRAPI.sharedInstance.currentGeoid;
    
    if (geoid > 100000000)
    {
        _awd = AlleyWallData.new;
        _databaseID = _awd;
        [_databaseID incrementLastDataFileNum];
    }
    
    else
    {
        _crd = CurbRampData.new;
        _databaseID = _crd;
        [_databaseID incrementLastDataFileNum];
    }
    
    [self updateConnectLabel];
}

- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView
{
    [popoverTableView hide:YES];
}

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
                 atIndex:(NSInteger)index
{
    [popoverTableView hide:YES];
    
    _selectedRow = index;
    
    [UserDefaults.defaults saveInteger:(int)_selectedRow
                                forKey:@"SelectedRow"];

    [CRAPI.sharedInstance processPlacesArray:_selectedRow];
    [self setDatabaseIDToDB];
    
    [_titleButton setTitle:[NSString stringWithFormat:@"Synchronize Data for\n%@",
                            CRAPI.sharedInstance.currentCityNameAndState]
                  forState:UIControlStateNormal];
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
    NSString *msg = @"";
    
    switch (server.messageID)
    {
        case GMSMessageOpenConnect:
            SetUseDemoID(NO);
            msg = [NSString stringWithFormat:@"$M(GetCitiesForiPad,%@)\r\n", deviceInfo()];
            break;
            
        case GMSMessageGetUploadStatus:
            msg = [NSString stringWithFormat:@"$M(GetUploadStatus,%i,%i,%i)",
                   CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid,
                   CRAPI.sharedInstance.totiPadWithinManager];
            break;
            
        case GMSMessageFileUploaded:
            if (_process == UPLOAD_DATA_PROCESS)
            {
                msg = [NSString stringWithFormat:@"$M(UploadCompleteData,%i,%i,%i,%i)",
                       CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid,
                       CRAPI.sharedInstance.currentiPadWithinManager, _nextFileNumToUpload];
            }
            
            else
            {
                msg = [NSString stringWithFormat:@"$M(UploadCompletePict,%i,%i,%i,%i)",
                       CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid,
                       CRAPI.sharedInstance.currentiPadWithinManager, _nextFileNumToUpload];
            }
            
            break;
            
        case GMSMessageSetNearby:
            msg = [NSString stringWithFormat:@"$M(SetNearbyiPad,%@,%@,%f %f)\r\n",
                   vendorUUIDString(), _iPad_name, _locationManager.location.coordinate.latitude,
                   _locationManager.location.coordinate.longitude];
            break;
            
        case GMSMessageCheckNearby:
            msg = [NSString stringWithFormat:@"$M(CheckNearbyiPad,%@)\r\n",
                   vendorUUIDString()];
            break;
            
        case GMSMessageCancelConnect:
            msg = [NSString stringWithFormat:@"$M(RemoveNearbyiPad,%@)\r\n",
                   vendorUUIDString()];
            break;
    }
    
    if (msg)
        [_GMServer sendMessage:msg];
    
    NSLog(@"GMServer Query:%@", msg);
}

- (void)GMServer:(GeoMasterServer *)server
 didReceiveError:(NSString *)error
      withStatus:(long)status
{
    [self closeGMServer];
    
    NSString *titleMessage = @"";
    
    if ([error isEqualToString:@"Internet Connection Not Available"])
        titleMessage = @"Network Error";
    
    else
        titleMessage = @"NVCRIS Server Error";
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:titleMessage
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (void)doSendGMServerMessage:(NSTimer *)timer
{
    _GMServer = [GeoMasterServer open];
    _GMServer.delegate = self;
    _GMServer.messageID = _currentServerMsgID;
    [_GMServer initCommunication:7.5];
}

- (void)sendGMServerMessage:(NSInteger)msgID
{
    _currentServerMsgID = msgID;
    
    _sendTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self
                                            selector:@selector(doSendGMServerMessage:)
                                            userInfo:nil
                                             repeats:NO];
}

- (int)getDataNumFromServerMsg:(int)iPad
                   wantPictNum:(BOOL)wantPict
{
    int dataNum = -4;
    
    if (_uploadStatusMsg.length < 5)
        return -3;
    
    if (iPad > _numiPadsInMsg)
        return -2;
    
    LPSTR pMsg = malloc(_uploadStatusMsg.length + 4);
    strcpy(pMsg,_uploadStatusMsg.UTF8String);
    LPSTR pPipe = strchr(pMsg,'|');
    int i = 1;
    
    while (pPipe)
    {
        pPipe++;
        
        if (i++ == iPad)
        {
            if (wantPict)
            {
                pPipe = strchr(pPipe,'-');
                
                if (!pPipe)
                    break;
                
                pPipe++;
            }
            
            dataNum = atoi(pPipe);
            break;
        }
        
        pPipe = strchr(pPipe,'|');
    }
    
    free (pMsg);
    return dataNum;
}

- (void)getDownloadCounts:(BOOL)loading
{
    _downFiles = _downPix = 0;
    _totFilesToProcess =  _origUpFiles;
    for (int iPad = 1; iPad <= _numiPadsInMsg; iPad++)
    {
        if (iPad != _myiPad)
        {
            int lastPictIHave;
            
            int lastDataIHave = [_databaseID getLastDataUpdateNumber:iPad
                                                         lastPictNum:&lastPictIHave];
            
            lastDataIHave++;
            int fileSize = 0;
            
            while (lastDataIHave && !fileSize)
            {
                lastDataIHave--;
                
                NSString *filePath = [_databaseID outputDataFile:lastDataIHave
                                                            iPad:iPad];
                
                fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:filePath
                                                                               error:nil].fileSize;
            }
            
            int lastDataFileOnServer = [self getDataNumFromServerMsg:iPad
                                                         wantPictNum:NO];
            
            int lastPictFileOnServer = [self getDataNumFromServerMsg:iPad
                                                         wantPictNum:YES];
            
            lastPictIHave++;
            fileSize = 0;
            
            while (lastPictIHave && !fileSize)
            {
                lastPictIHave--;
                
                NSString *filePath = [_databaseID outputPictFile:lastPictIHave
                                                            iPad:iPad];
                
                fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:filePath
                                                                               error:nil].fileSize;
            }
            
            _downFiles += max (0,lastDataFileOnServer - lastDataIHave);
            if (!loading || CRAPI.sharedInstance.downloadData)
                _totFilesToProcess += max (0,lastDataFileOnServer - lastDataIHave);
            if (!loading || CRAPI.sharedInstance.downloadPix)
            {
                _downPix += max(0,lastPictFileOnServer - lastPictIHave);
                _totFilesToProcess += max(0,lastPictFileOnServer - lastPictIHave);
            }
        }
    }
}

- (void)GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
      withStatus:(long)status
{
    [self closeGMServer];
    NSLog(@"GMServer Message(NVSynchronizeVC): %@", message);
    
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
                    [_titleButton setTitle:@"Synchronize Data\nNO CITIES IN LIST"
                                  forState:UIControlStateNormal];
                    
                    _syncButton.enabled = NO;
                    [self updateButton:_syncButton];
                    
                    _connectLabel.text = [NSString stringWithFormat:@"%i-NO MANAGER",
                                          CRAPI.sharedInstance.GSSiPadNumber];
                    
                    break;
                }
                
                _selectedRow = [UserDefaults.defaults integerForKey:@"SelectedRow"];
                
                if (CRAPI.sharedInstance.placesArray.count < 2 ||
                    CRAPI.sharedInstance.placesArray.count <= _selectedRow ||
                    CRAPI.sharedInstance.currentGeoid == 0)
                {
                    _selectedRow = 0;
                    
                    [UserDefaults.defaults saveInteger:(int)_selectedRow
                                                forKey:@"SelectedRow"];
                }
                
                [CRAPI.sharedInstance processPlacesArray:_selectedRow];
                [self setDatabaseIDToDB];
                
                [_titleButton setTitle:[NSString stringWithFormat:@"Synchronize Data for\n%@",
                                        CRAPI.sharedInstance.currentCityNameAndState]
                              forState:UIControlStateNormal];
                
                if (CRAPI.sharedInstance.placesArray.count > 1)
                {
                    _titleButton.backgroundColor = _colors.enabledColor;
                    _titleButton.userInteractionEnabled = YES;
                    
                    [_titleButton setTitleColor:_colors.titleColor
                                       forState:UIControlStateNormal];
                }
                
                _locationManager = [[CLLocationManager alloc] init];
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                _locationManager.distanceFilter = kCLDistanceFilterNone;
                _locationManager.delegate = self;
                [self updateConnectLabel];
                [_locationManager startUpdatingLocation];
                [self closeGMServer];
                [self sendGMServerMessage:GMSMessageGetUploadStatus];
            }
                
                break;
                
            case GMSMessageFileUploaded:
                _nextFileNumToUpload++;
                _uploadedFiles++;
                _processedFiles++;
                if (_totFilesToProcess)
                    [self updateOverallProgress:(float)_processedFiles/_totFilesToProcess];
                
                if (_process == UPLOAD_DATA_PROCESS)
                    _upFiles--;
                else
                    _upPix--;
                [self updateLabels];
                [self uploadNextFile];
                break;
                
            case GMSMessageGetUploadStatus:
            {
                _uploadStatusMsg = message.copy;
               // NSString *edit = [_uploadStatusMsg stringByReplacingOccurrencesOfString:@"3-5" withString:@"1-5"];
               // _uploadStatusMsg = edit;
                _numiPadsInMsg = atoi (_uploadStatusMsg.UTF8String);
                [self closeGMServer];
                
                int pictNum = 0;
                _myiPad = CRAPI.sharedInstance.currentiPadWithinManager;
                
                int lastNum = [_databaseID getLastDataUpdateNumber:_myiPad
                                                lastPictNum:&pictNum];
                
                lastNum++;
                int fileSize = 0;
                
                while (lastNum && !fileSize)
                {
                    lastNum--;
                    
                    NSString *filePath = [_databaseID outputDataFile:lastNum
                                                                iPad:_myiPad];
                    
                    fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:filePath
                                                                                   error:nil].fileSize;
                }
                
                _lastFileNumToUpload = lastNum;
                
                _nextFileNumToUpload = ([self getDataNumFromServerMsg:_myiPad
                                                         wantPictNum:NO] + 1);
                if (_nextFileNumToUpload > 0)
                    _upFiles = (_lastFileNumToUpload - _nextFileNumToUpload + 1);
                
                lastNum = pictNum;
                lastNum++;
                fileSize = 0;
                
                while (lastNum && !fileSize)
                {
                    lastNum--;
                    
                    NSString *filePath = [_databaseID outputPictFile:lastNum
                                                                iPad:_myiPad];
                    
                    fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:filePath
                                                                                   error:nil].fileSize;
                }
                
                _lastPictNumToUpload = lastNum;
                
                _nextPictNumToUpload = ([self getDataNumFromServerMsg:_myiPad
                                                         wantPictNum:YES] + 1);
                
                if (_nextPictNumToUpload > 0)
                    _upPix = (_lastPictNumToUpload - _nextPictNumToUpload + 1);
                
                [self getDownloadCounts:NO];
                [self updateLabels];
                [self updateOverallProgress:0];
            }
                break;
                
            case GMSMessageSetNearby:
                _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
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
                    
                    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                              target:self
                                                            selector:@selector(checkNearby:)
                                                            userInfo:nil
                                                             repeats:NO];
                }
                
                else
                {
                    [_popoverView hide];
                    [self closeGMServer];
                    [self sendGMServerMessage:GMSMessageOpenConnect];
                }
                
                break;
                
            case GMSMessageCancelConnect:
                [_popoverView hide];
                break;
        }
    }
}

- (void)uploadNextFile
{
    _doTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                target:self
                                              selector:@selector(doUploadNextFile:)
                                              userInfo:nil
                                               repeats:NO];
}

- (void)downloadNextFile
{
    if (_process == DOWNLOAD_DATA_PROCESS && !CRAPI.sharedInstance.downloadData)
        _process = DOWNLOAD_PICT_PROCESS;
    
    if (_process == DOWNLOAD_PICT_PROCESS && !CRAPI.sharedInstance.downloadPix)
    {
        [_syncButton setTitle:@"Complete"
                     forState:UIControlStateNormal];
        _syncButton.enabled = NO;
        [_popoverView hide];
        return;

    }
    
    _doTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                target:self
                                              selector:@selector(doDownloadNextFile:)
                                              userInfo:nil
                                               repeats:NO];
}

- (void)doUploadNextFile:(NSTimer *)timer
{
Top:
    if (_nextFileNumToUpload > _lastFileNumToUpload)
    {
        if (_process == UPLOAD_DATA_PROCESS)
        {
            int pictNum = 0;
            _process = UPLOAD_PICT_PROCESS;
            
            if (CRAPI.sharedInstance.uploadPix)
            {
                _myiPad = CRAPI.sharedInstance.currentiPadWithinManager;
                
                int lastNum = [_databaseID getLastDataUpdateNumber:_myiPad
                                                       lastPictNum:&pictNum];
                
                lastNum = pictNum;
                lastNum++;
                int fileSize = 0;
                
                while (lastNum && !fileSize)
                {
                    lastNum--;
                    
                    NSString *filePath = [_databaseID outputPictFile:lastNum
                                                                iPad:_myiPad];
                    
                    fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:filePath
                                                                                   error:nil].fileSize;
                }
                
                _lastFileNumToUpload = lastNum;
                
                _nextFileNumToUpload = ([self getDataNumFromServerMsg:_myiPad
                                                         wantPictNum:YES] + 1);
                
                if (_nextFileNumToUpload > 0)
                    _upFiles = (_lastFileNumToUpload - _nextFileNumToUpload + 1);
                
                [self updateLabels];
                
                goto Top;
            }
        }
    
        _process = DOWNLOAD_DATA_PROCESS;
        _downloadiPad = [self nextiPadToDownload:0];
        
        if (_downloadiPad)
        {
            [self setDownloadFilesFor:_downloadiPad];
            [self downloadNextFile];
        }
        
        return;
    }
    
    if (_process == UPLOAD_DATA_PROCESS)
    {
        _filePath = [_databaseID outputDataFile:_nextFileNumToUpload
                                           iPad:_myiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Data"];
    }
    
    else
    {
        _filePath = [_databaseID outputPictFile:_nextFileNumToUpload
                                           iPad:_myiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Picture"];
    }
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:_filePath
                                                                   error:nil].fileSize;
    if (!fileSize)
    {
        NSString * emptyFileMessage = @"/*This file is empty*/";
        [emptyFileMessage writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    _push = [FTPDataPush push];
    _push.delegate = self;
    _push.popover = _popoverView;
    
    NSString *toDir = [NSString stringWithFormat:@"NVCRISData/%i/%i",
                       CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid];
    
    [_push sendFile:[_filePath lastPathComponent]
      fromDirectory:[_filePath stringByDeletingLastPathComponent]
             toFile:[_filePath lastPathComponent]
        toDirectory:toDir
     deleteWhenDone:NO];
}

- (void)setDownloadFilesFor:(int)iPad
{
    int lastPictIHave = 0, fileSize = 0;
    
    int lastDataIHave = [_databaseID getLastDataUpdateNumber:iPad
                                                 lastPictNum:&lastPictIHave];
    lastDataIHave++;
    //lastDataIHave = 0;
    while (lastDataIHave && !fileSize)
    {
        lastDataIHave--;
        
        NSString *filePath = [_databaseID outputDataFile:lastDataIHave
                                                    iPad:iPad];
        
        fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:filePath
                                                                       error:nil].fileSize;
    }
    
    int lastDataFileOnServer = [self getDataNumFromServerMsg:iPad
                                                 wantPictNum:NO];
    
    int lastPictFileOnServer = [self getDataNumFromServerMsg:iPad
                                                 wantPictNum:YES];
    if (_process == DOWNLOAD_DATA_PROCESS)
    {
        _nextFileNumToDownload = lastDataIHave + 1;
        _lastFileNumToDownload = lastDataFileOnServer;
    }
    else
    {
        _nextFileNumToDownload = lastPictIHave + 1;
        _lastFileNumToDownload = lastPictFileOnServer;
    }
}

- (int)nextiPadToDownload:(int)currentiPad
{
    currentiPad++;
    
    if (currentiPad == _myiPad)
        currentiPad++;
    
    if (currentiPad > _numiPadsInMsg)
        return 0;
    
    return currentiPad;
}

- (void)doDownloadNextFile:(NSTimer *)timer
{
Top:
    if (_nextFileNumToDownload > _lastFileNumToDownload)
    {
        _downloadiPad = [self nextiPadToDownload:_downloadiPad];
        
        if (!_downloadiPad)
        {
            if (_process == DOWNLOAD_DATA_PROCESS)
            {
                _process = DOWNLOAD_PICT_PROCESS;
                if (!CRAPI.sharedInstance.downloadPix)
                    goto Done;
                _downloadiPad = [self nextiPadToDownload:0];
                
                if (_downloadiPad)
                {
                    [self setDownloadFilesFor:_downloadiPad];
                    goto Top;
                }
                else
                    goto Done;
            }
            else
            {
Done:
                [_syncButton setTitle:@"Complete"
                             forState:UIControlStateNormal];
                _syncButton.enabled = NO;
                [_popoverView hide];
                return;
            }
        }
        
        else
        {
            [self setDownloadFilesFor:_downloadiPad];
            goto Top;
        }
    }
    
    if (_process == DOWNLOAD_DATA_PROCESS)
    {
        _filePath = [_databaseID outputDataFile:_nextFileNumToDownload
                                           iPad:_downloadiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Data"];
    }
    
    else
    {
        _filePath = [_databaseID outputPictFile:_nextFileNumToDownload
                                           iPad:_downloadiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Picture"];
    }

    
    
    NSString *fromDir = [NSString stringWithFormat:@"NVCRISData/%i/%i",
                         CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid];
    NSString *toDir = NSTemporaryDirectory ( );
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = _popoverView;
    _pull.useTestServer = NO;
    if (_process == DOWNLOAD_DATA_PROCESS)
    {
        _pull.dataType = FTPData;
        _popoverView.title = [NSString stringWithFormat:@"Download Data\n%@",[_filePath lastPathComponent]];
    }
    else
    {
        _pull.dataType = FTPDataPhoto;
        _popoverView.title = [NSString stringWithFormat:@"Download Photo\n%@",[_filePath lastPathComponent]];
    }
    [_pull getFile:[_filePath lastPathComponent]
     fromDirectory:fromDir
            toFile:[_filePath lastPathComponent]
       toDirectory:[_filePath stringByDeletingLastPathComponent]
     refreshOption:FTPDataPullRefreshOptionOverwriteFile];
    
}

- (void)FTPPushDidComplete:(FTPDataType)dataType
                withStatus:(FTPStatus)status
           andStatusString:(NSString *)statusString
                  filePath:(NSString *)path
{
    if (status == FTPStatusOK)
    {
        [_popoverView hide];
        [self sendGMServerMessage:GMSMessageFileUploaded];
    }
    
    else
    {
        _popoverView.title = [NSString stringWithFormat:@"Upload Error\n%@",statusString];
        [_popoverView setCancelButtonTitle:@"OK"];
    }
    
    NSLog(@"FTP push completed:%@", statusString);
}


- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    
    if (status == FTPStatusOK || status == FTPStatusFileExists)
    {
        {
            if (_process == DOWNLOAD_DATA_PROCESS)
            {
               if ([self loadUpdate:path])
               {
                   [_databaseID setLastDataUpdateNum:_nextFileNumToDownload
                                             foriPad:_downloadiPad];
               }
                
               else
               {
                   _popoverView.title = [NSString stringWithFormat:@"Data load failed\n%@",[path lastPathComponent]];
                   return;
               }
            }
            
            else
            {
                [_databaseID setLastPictUpdateNum:_nextFileNumToDownload
                                          foriPad:_downloadiPad];
            }
            
            _nextFileNumToDownload++;
            
            if (_process == DOWNLOAD_DATA_PROCESS)
                
                _downFiles--;
            else
                _downPix--;
            
            _processedFiles++;
            
            if (_totFilesToProcess)
                [self updateOverallProgress:(float)_processedFiles/_totFilesToProcess];

            [self updateLabels];
            [self downloadNextFile];
        }
    }
    
    else
        _popoverView.title = statusString;
}

- (BOOL)loadUpdate:(NSString*)path
{
    return [_databaseID updateFromFile:path];
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
    CRAPI.sharedInstance.refreshMap = YES;
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

- (void)helpButtonTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"NVCRISHelp_NoneAvailable"
                                                       ofType:@"pdf"];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath];
#pragma unused(nvwv)
}

@end