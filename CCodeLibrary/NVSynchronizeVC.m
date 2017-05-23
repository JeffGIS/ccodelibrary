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
#import "NVEmailFileList.h"
#import "SharedDefaults.h"

#define FTP_CATCHUP_DELAY 0.5
#define UPLOAD_STATUS_VERSION 1
#define MAX_ATTEMPS 3

@interface NVSynchronizeVC () <GeoMasterServerDelegate,NVAlertViewDelegate,GSSiPopoverViewDelegate,FTPDataPullDelegate,FTPDataPushDelegate,FTPDirectoryCreateDelegate,NVPopoverTableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic) UILabel *dataUpLabel, *pixUpLabel, *dataDownLabel, *pixDownLabel, *overallLabel, *currentFileLabel, *connectLabel;
@property (nonatomic) UIButton *syncButton, *emailFileListButton, *returnButton, *connectButton, *titleButton;
@property (nonatomic) UISwitch *pixUpSwitch, *pixDownSwitch, *dataDownSwitch;
@property (nonatomic) NVProgressView *overallProgressView;
@property (nonatomic) Colors *colors;
@property (nonatomic) GeoMasterServer *GMServer;
@property (nonatomic) GSSiPopoverView *popoverView;
@property (nonatomic) CLLocationManager *locationManager;
@property int upFiles, upPix, downFiles, downPix, numConnectionAttempts, totConnectionAttempts;;
@property BOOL serverOpen, setDemoID, didConnect;
@property NSTimer *timer;
@property (nonatomic, copy) NSString *iPad_name;
@property (nonatomic) FTPDataPush *push;
@property (nonatomic) FTPDataPull *pull;
@property NSInteger selectedRow;
@property (nonatomic) NVEmailFileList *nvefl;
@property NSDate * sendDataStartTime;

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
    
    _first = NO;
    _iPad_name = UIDevice.currentDevice.name;
    _setDemoID = getUseDemoID();
    _colors = UserDefaults.defaults.defaultColors;
    self.view.backgroundColor = _colors.backgroundColor;
    _upFiles = _upPix = _downFiles = _downPix = 0;
    _didConnect = NO;
    
    if (CRAPI.sharedInstance.currentModule == PRELIM_MODULE ||
        CRAPI.sharedInstance.currentModule == DETAIL_MODULE)
    {
        CRAPI.sharedInstance.downloadPix = NO;
    }
    
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
    _first = YES;
    
    _syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_syncButton];
    
    [_syncButton setTitle:@"Synchronize"
                 forState:UIControlStateNormal];
    
    [_syncButton addTarget:self
                    action:@selector(syncButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    if (CRAPI.sharedInstance.showDeveloperFunctions)
    {
        _emailFileListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setupButton:_emailFileListButton];
        
        [_emailFileListButton setTitle:@"Email File List"
                              forState:UIControlStateNormal];
        
        [_emailFileListButton addTarget:self
                                 action:@selector(emailFileListButtonTapped:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    
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
        [sectionView constrainLeadingToAnchor:self.view.leadingAnchor constant:-borderWidth];
        [sectionView constrainTrailingToAnchor:self.view.trailingAnchor constant:borderWidth];
        
        if (i == 0)
            [sectionView constrainTopToAnchor:self.view.topAnchor];
        
        else
        {
            if (i == (numSections - 1))
                [sectionView constrainBottomToAnchor:self.view.bottomAnchor];
            
            UIView *viewOnTop = [self.view viewWithTag:(i * 100)];
            [sectionView constrainTopToAnchor:viewOnTop.bottomAnchor];
            [sectionView constrainHeightToAnchor:viewOnTop.heightAnchor];
        }
        
        switch (i)
        {
            case 0://title label
                [sectionView addSubview:_connectLabel];
                [_connectLabel constrainBottomToAnchor:sectionView.bottomAnchor];
                [_connectLabel constrainTrailingToAnchor:sectionView.trailingAnchor constant:-buttonMargin];
                
                [sectionView addSubview:_connectButton];
                [_connectButton constrainTopToAnchor:sectionView.topAnchor constant:buttonMargin];
                [_connectButton constrainTrailingToAnchor:sectionView.trailingAnchor constant:-buttonMargin];
                [_connectButton constrainBottomToAnchor:_connectLabel.topAnchor];
                [_connectButton constrainWidthToAnchor:_connectLabel.widthAnchor];
                
                [sectionView addSubview:_returnButton];
                [_returnButton constrainTopToAnchor:sectionView.topAnchor constant:buttonMargin];
                [_returnButton constrainLeadingToAnchor:sectionView.leadingAnchor constant:buttonMargin];
                [_returnButton constrainBottomToAnchor:_connectButton.bottomAnchor];
                [_returnButton constrainWidthToAnchor:_connectButton.widthAnchor];
                
                [sectionView addSubview:_titleButton];
                [_titleButton constrainLeadingToAnchor:_returnButton.trailingAnchor constant:buttonMargin];
                [_titleButton constrainTrailingToAnchor:_connectButton.leadingAnchor constant:-buttonMargin];
                [_titleButton constrainTopToAnchor:sectionView.topAnchor constant:buttonMargin];
                [_titleButton constrainBottomToAnchor:sectionView.bottomAnchor constant:-buttonMargin];
                break;
            case 1://data files to be uploaded
                [sectionView addSubview:_dataUpLabel];
                [_dataUpLabel constrainToView:sectionView leading:margin trailing:-margin top:0.0 bottom:0.0];
                break;
            case 2://pictures to be uploaded
                [sectionView addSubview:_pixUpSwitch];
                [_pixUpSwitch constrainCenterYToAnchor:sectionView.centerYAnchor];
                [_pixUpSwitch constrainTrailingToAnchor:sectionView.trailingAnchor constant:-margin];
                
                [sectionView addSubview:_pixUpLabel];
                [_pixUpLabel constrainLeadingToAnchor:sectionView.leadingAnchor constant:margin];
                [_pixUpLabel constrainTrailingToAnchor:_pixUpSwitch.leadingAnchor];
                [_pixUpLabel constrainTopToAnchor:sectionView.topAnchor];
                [_pixUpLabel constrainBottomToAnchor:sectionView.bottomAnchor];
                break;
            case 3://data files to be downloaded
                [sectionView addSubview:_dataDownSwitch];
                [_dataDownSwitch constrainCenterYToAnchor:sectionView.centerYAnchor];
                [_dataDownSwitch constrainTrailingToAnchor:sectionView.trailingAnchor constant:-margin];
                
                [sectionView addSubview:_dataDownLabel];
                [_dataDownLabel constrainLeadingToAnchor:sectionView.leadingAnchor constant:margin];
                [_dataDownLabel constrainTrailingToAnchor:_pixUpSwitch.leadingAnchor];
                [_dataDownLabel constrainTopToAnchor:sectionView.topAnchor];
                [_dataDownLabel constrainBottomToAnchor:sectionView.bottomAnchor];
                break;
            case 4://pictures to be downloaded
                if (CRAPI.sharedInstance.currentModule != PRELIM_MODULE &&
                    CRAPI.sharedInstance.currentModule != DETAIL_MODULE)
                {
                    [sectionView addSubview:_pixDownSwitch];
                    [_pixDownSwitch constrainCenterYToAnchor:sectionView.centerYAnchor];
                    [_pixDownSwitch constrainTrailingToAnchor:sectionView.trailingAnchor constant:-margin];
                    
                    [sectionView addSubview:_pixDownLabel];
                    [_pixDownLabel constrainLeadingToAnchor:sectionView.leadingAnchor constant:margin];
                    [_pixDownLabel constrainTrailingToAnchor:_pixUpSwitch.leadingAnchor];
                    [_pixDownLabel constrainTopToAnchor:sectionView.topAnchor];
                    [_pixDownLabel constrainBottomToAnchor:sectionView.bottomAnchor];
                }
                break;
            case 5://sync button
                [sectionView addSubview:_syncButton];
                
                [_syncButton constrainToView:sectionView leading:(screenWidth / 4.0)
                                    trailing:(-screenWidth / 4.0) top:buttonMargin bottom:-buttonMargin];
                break;
            case 6://help button
                [sectionView addSubview:helpButton];
                [helpButton constrainHeightToAnchor:sectionView.heightAnchor multiplier:0.8];
                [helpButton constrainWidthToAnchor:sectionView.heightAnchor multiplier:0.8];
                [helpButton constrainCenterXToAnchor:sectionView.centerXAnchor];
                [helpButton constrainCenterYToAnchor:sectionView.centerYAnchor];
                break;
            case 7://overall progress
                [sectionView addSubview:_overallProgressView];
                [_overallProgressView constrainLeadingToAnchor:sectionView.leadingAnchor constant:margin];
                [_overallProgressView constrainTrailingToAnchor:sectionView.trailingAnchor constant:-margin];
                [_overallProgressView constrainTopToAnchor:sectionView.topAnchor constant:buttonMargin];
                [_overallProgressView constrainBottomToAnchor:sectionView.centerYAnchor];
                
                [sectionView addSubview:_overallLabel];
                [_overallLabel constrainLeadingToAnchor:sectionView.leadingAnchor constant:margin];
                [_overallLabel constrainTrailingToAnchor:sectionView.trailingAnchor constant:-margin];
                [_overallLabel constrainTopToAnchor:_overallProgressView.bottomAnchor];
                [_overallLabel constrainBottomToAnchor:sectionView.bottomAnchor constant:-buttonMargin];
                break;
            case 8://email file list button
                if (CRAPI.sharedInstance.showDeveloperFunctions)
                {
                    [sectionView addSubview:_emailFileListButton];
                    
                    [_emailFileListButton constrainToView:sectionView leading:(screenWidth / 4.0)
                                                 trailing:(-screenWidth / 4.0) top:buttonMargin bottom:-buttonMargin];
                }
                break;
            default:break;
        }
    }
    
    _popoverView = [[GSSiPopoverView alloc] initWithView:self.view];
    _popoverView.delegate = self;
    _connectButton.hidden = YES;
    _syncButton.enabled = NO;
    [self updateButton:_syncButton];
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
    
    BOOL useDemo = (_setDemoID && !_didConnect);
    SetUseDemoID(useDemo);
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
    if (_first)
    {
        _first = NO;
        if (_upFiles < 0 || _upPix < 0 || _downFiles < 0 || _downPix < 0)
        {
            NSString * msg = [NSString stringWithFormat:@"Negative numbers in sync: %i %i %i %i",_upFiles,_upPix,_downFiles,_downPix];
            if (getUseMasterID())
            {
                _upFiles = 0;
            }
            else
                [CRAPI.sharedInstance logToErrorFile:msg];
        }
    }
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

- (void)startSync
{
    _autoSync = FALSE;
    _process = UPLOAD_DATA_PROCESS;
    _uploadedFiles = 0;
    _origUpFiles = _upFiles + _upPix;
    [self getDownloadCounts:YES];
    [self updateLabels];
    [self uploadNextFile];
    
}
- (void)syncButtonTapped:(UIButton *)button
{
    _syncButton.enabled = NO;
    [self updateButton:_syncButton];
    CRAPI.sharedInstance.refreshMap = YES;
    
    if ([CRAPI.sharedInstance haveErrorLog])
    {
        _process = UPLOAD_ERROR_FILE;
        NSString * errorFile = [CRAPI.sharedInstance errorLogPath];
        _push = [FTPDataPush push];
        _push.delegate = self;
        _push.popover = _popoverView;
        _push.dataType = FTPErrorFile;
        int iTime = NSDate.timeIntervalSinceReferenceDate;
        _errorFileName = [NSString stringWithFormat:@"%i_%i.txt",CRAPI.sharedInstance.GSSiPadNumber,iTime];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Error File"];
        NSString *toDir = [NSString stringWithFormat:@"NVCRISData/ErrorFiles"];
        
        [_push sendFile:[errorFile lastPathComponent]
          fromDirectory:[errorFile stringByDeletingLastPathComponent]
                 toFile:_errorFileName
            toDirectory:toDir
         deleteWhenDone:NO
         appendFileName:NO];
    }
    else
        [self startSync];
}

- (void)emailFileListButtonTapped:(UIButton *)button
{
    //if (getUseMasterID())
        [self uploadDatabases:button];
    //else
        //[NVEmailFileList sendFileList:self];
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
        [self tempFix:CRAPI.sharedInstance.GSSiPadNumber
                geoid:geoid];
        [_databaseID incrementLastDataFileNum];
        [_databaseID incrementLastPictFileNum];
    }
    
    else
    {
        _crd = CurbRampData.new;
        _databaseID = _crd;
        [self tempFix:CRAPI.sharedInstance.GSSiPadNumber
                geoid:geoid];
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
    _totConnectionAttempts = 50;
    _process = CONNECT_PROCESS;
    _popoverView.progressLabel.hidden = YES;
    
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
            msg = [NSString stringWithFormat:@"$M(GetUploadStatus,%i,%i,%i,%i)",
                   CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid,
                   CRAPI.sharedInstance.totiPadWithinManager,UPLOAD_STATUS_VERSION];
            break;
            
        case GMSMessageFileUploaded:
            if (_process == UPLOAD_ERROR_FILE)
            {
                msg = [NSString stringWithFormat:@"$M(UploadErrors,%@)",_errorFileName];
            }
            else if (_process == UPLOAD_DATA_PROCESS)
            {
#define AVERAGE_UPLOAD_SPEED 25000.0
                double timePassed = max (0.01,-[_sendDataStartTime timeIntervalSinceNow] - 1);
                double uploadSpeed = _lastUploadFileSize / timePassed;
                double speedFactor = min (5,max (1.0,AVERAGE_UPLOAD_SPEED/uploadSpeed));
                NSTimeInterval interval = speedFactor * (FTP_CATCHUP_DELAY * (1 + _lastUploadFileSize/500000.0));
                [NSThread sleepForTimeInterval:interval];
                msg = [NSString stringWithFormat:@"$M(UploadCompleteData,%i,%i,%i,%i,%i)",
                       CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid,
                       CRAPI.sharedInstance.currentiPadWithinManager, _nextFileNumToUpload,_lastUploadFileSize];
            }
            else
            {
               [NSThread sleepForTimeInterval:FTP_CATCHUP_DELAY*2];
               msg = [NSString stringWithFormat:@"$M(UploadCompletePict,%i,%i,%i,%i,%i)",
                       CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid,
                       CRAPI.sharedInstance.currentiPadWithinManager, _nextFileNumToUpload,_lastUploadFileSize];
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
        titleMessage = [NSString stringWithFormat:@"NVCRIS Server Error\n%@",error];
    
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
    int i = 0;
    
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
    _processedFiles = 0;
    for (int iPad = 0; iPad <= _numiPadsInMsg; iPad++)
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
                NSMutableArray *oldPlaces = [CRAPI.sharedInstance copyPlaces];
                [CRAPI.sharedInstance savePlacesString:message];
                [CRAPI.sharedInstance processPlaces];
                
                if (CRAPI.sharedInstance.placesArray.count == 0)
                {
                    [_titleButton setTitle:@"Synchronize Data\nNO CITIES IN LIST"
                                  forState:UIControlStateNormal];
                    
                    _syncButton.enabled = NO;
                    [self updateButton:_syncButton];
                    _didConnect = NO;
                    
                    _connectLabel.text = [NSString stringWithFormat:@"%i-NO MANAGER",
                                          CRAPI.sharedInstance.GSSiPadNumber];
                    
                    [_connectButton setHidden:CRAPI.sharedInstance.hideConnectButton];
                    
                    break;
                }
                
                _didConnect = YES;
                
                _selectedRow = [CRAPI.sharedInstance newPlace:_oldPlaces];
                if (_selectedRow < 0)
                    _selectedRow = [UserDefaults.defaults integerForKey:@"SelectedRow"];
                else
                {
                    [UserDefaults.defaults saveInteger:(int)_selectedRow
                                                forKey:@"SelectedRow"];
                    _autoSync = TRUE;
                }
                if (CRAPI.sharedInstance.placesArray.count < 2 ||
                    (int)CRAPI.sharedInstance.placesArray.count <= _selectedRow ||
                    CRAPI.sharedInstance.currentGeoid == 0)
                {
                    _selectedRow = 0;
                    
                    [UserDefaults.defaults saveInteger:(int)_selectedRow
                                                forKey:@"SelectedRow"];
                }
                
                [CRAPI.sharedInstance setGeoIDForCurrentApp];
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
                [_connectButton setHidden:CRAPI.sharedInstance.hideConnectButton];
                [self sendGMServerMessage:GMSMessageGetUploadStatus];
            }
                
                break;
                
            case GMSMessageFileUploaded:
                if (_process == UPLOAD_ERROR_FILE)
                {
                    [CRAPI.sharedInstance clearErrorFile];
                    [self startSync];
                }
                else if ([message isEqualToString:@"OK"])
                {
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
                }
                else if ([[message substringToIndex:3] isEqualToString:@"ERR1"] &&
                         _numAttemps++ < MAX_ATTEMPS)
                {
                    [NSThread sleepForTimeInterval:2.0*_numAttemps];
                    [self sendGMServerMessage:GMSMessageFileUploaded];
                }
                else
                {
                    NSString * title = [NSString stringWithFormat:@"Upload Size/Rename Error:%@",message];
                    [_popoverView showAfter:0.1
                                  withTitle:title];
                    [CRAPI.sharedInstance logToErrorFile:title];

                }
                break;
                
            case GMSMessageGetUploadStatus:
            {
                _uploadStatusMsg = message.copy;
               // NSString *edit = [_uploadStatusMsg stringByReplacingOccurrencesOfString:@"3-5" withString:@"1-5"];
               // _uploadStatusMsg = edit;
                _numiPadsInMsg = atoi (_uploadStatusMsg.UTF8String)+1;
                [self closeGMServer];
                
                int pictNum = 0;
                _myiPad = CRAPI.sharedInstance.currentiPadWithinManager;
                int lastNum = [_databaseID getLastDataUpdateNumber:_myiPad
                                                lastPictNum:&pictNum];
                if (_myiPad > 0 || getUseMasterID())
                {
                    _syncButton.enabled = YES;
                    [_syncButton setTitle:@"Synchronize"
                                 forState:UIControlStateNormal];
                    [self updateButton:_syncButton];
                }

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
                if (_autoSync)
                    [self startSync];
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
                    _GMServer = [GeoMasterServer open];
                    _GMServer.delegate = self;
                    _GMServer.messageID = GMSMessageCancelConnect;
                    [_GMServer initCommunication:7.5];
                }
                
                break;
                
            case GMSMessageCancelConnect:
                [_popoverView hide];
                _oldPlaces = [CRAPI.sharedInstance copyPlaces];
                [self sendGMServerMessage:GMSMessageOpenConnect];
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
                    _upPix = (_lastFileNumToUpload - _nextFileNumToUpload + 1);
                
                [self updateLabels];
                
                goto Top;
            }
        }
    
        _process = DOWNLOAD_DATA_PROCESS;
        _downloadiPad = [self nextiPadToDownload:-1];
        
        if (_downloadiPad > -1)
        {
            [self setDownloadFilesFor:_downloadiPad];
            [self downloadNextFile];
        }
        [_syncButton setTitle:@"Complete"
                     forState:UIControlStateNormal];
        
        _syncButton.enabled = NO;
        [self updateButton:_syncButton];
        
        return;
    }
    
    if (_process == UPLOAD_DATA_PROCESS)
    {
        _filePath = [_databaseID outputDataFile:_nextFileNumToUpload
                                           iPad:_myiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Data"];
    }
    
    else if (_process == UPLOAD_PICT_PROCESS)
    {
        _filePath = [_databaseID outputPictFile:_nextFileNumToUpload
                                           iPad:_myiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Picture"];
    }
    else
    {
        [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"Invalid process:%i in upload %i %i",_process,_nextFileNumToUpload,_myiPad]];
        return;
    }
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:_filePath
                                                                   error:nil].fileSize;
    if (!fileSize)
    {
        NSString * emptyFileMessage = @"/*This file is empty*/";
        [emptyFileMessage writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [CRAPI.sharedInstance logToErrorFile:[_filePath lastPathComponent]
                                  withHeader:@"Writing empty file"];
    }
    _push = [FTPDataPush push];
    _push.delegate = self;
    _push.popover = _popoverView;
    if (_process == UPLOAD_DATA_PROCESS)
    {
        _push.dataType = FTPData;
        _sendDataStartTime = NSDate.date;
    }
    else
        _push.dataType = FTPDataPhoto;
    
    NSString *toDir = [NSString stringWithFormat:@"NVCRISData/%i/%i",
                       CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid];
    _lastUploadFileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:_filePath
                                                                   error:nil].fileSize;
    
    [_push sendFile:[_filePath lastPathComponent]
      fromDirectory:[_filePath stringByDeletingLastPathComponent]
             toFile:[_filePath lastPathComponent]
        toDirectory:toDir
     deleteWhenDone:NO
     appendFileName:YES];
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
    
    if (currentiPad == _myiPad && !getUseMasterID())
        currentiPad++;
    
    if (currentiPad > _numiPadsInMsg)
        return -1;
    
    return currentiPad;
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
        [self updateButton:_syncButton];
        [_popoverView hide];
        return;
    }
    
    _doTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                target:self
                                              selector:@selector(doDownloadNextFile:)
                                              userInfo:nil
                                               repeats:NO];
}


- (void)doDownloadNextFile:(NSTimer *)timer
{
Top:
    if (_nextFileNumToDownload > _lastFileNumToDownload)
    {
        _downloadiPad = [self nextiPadToDownload:_downloadiPad];
        
        if (_downloadiPad < 0)
        {
            if (_process == DOWNLOAD_DATA_PROCESS)
            {
                _process = DOWNLOAD_PICT_PROCESS;
                if (!CRAPI.sharedInstance.downloadPix)
                    goto Done;
                _downloadiPad = [self nextiPadToDownload:0];
                
                if (_downloadiPad > -1)
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
                [self updateButton:_syncButton];
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
    
    else if (_process == DOWNLOAD_PICT_PROCESS)
    {
        _filePath = [_databaseID outputPictFile:_nextFileNumToDownload
                                           iPad:_downloadiPad];
        
        [_popoverView showAfter:0.5
                      withTitle:@"Upload Picture"];
    }
    else
    {
        [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"Invalid process:%i in download %i %i",_process,_nextFileNumToDownload,_downloadiPad]];
        return;
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
        _numAttemps = 0;
        if (dataType != FTPDatabase)
            [self sendGMServerMessage:GMSMessageFileUploaded];
    }
    
    else
    {
        NSString * msg = [NSString stringWithFormat:@"%@\n%@",statusString,[path lastPathComponent]];
        _popoverView.title = msg;
        [CRAPI.sharedInstance logToErrorFile:msg];
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
                   NSString *msg = [NSString stringWithFormat:@"Data load failed\n%@",[path lastPathComponent]];
                   _popoverView.title = msg;
                   [CRAPI.sharedInstance logToErrorFile:msg];
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
    {
        NSString * msg = [NSString stringWithFormat:@"%@\n%@",statusString,[path lastPathComponent]];
        _popoverView.title = msg;
        [CRAPI.sharedInstance logToErrorFile:msg];
    }
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
    
    if (_process == CONNECT_PROCESS)
    {
        _GMServer = [GeoMasterServer open];
        _GMServer.delegate = self;
        _GMServer.messageID = GMSMessageCancelConnect;
        [_GMServer initCommunication:7.5];
    }
    else
        [popoverView hide];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [_delegate synchronizeControllerDidReturn:self];
}

- (void)pixUpSwitchTapped:(UISwitch *)aSwitch
{
    [SharedDefaults.defaults saveBool:aSwitch.on
                               forKey:@"UploadPix"];
    
    CRAPI.sharedInstance.uploadPix = aSwitch.on;
    if (!_syncButton.enabled && CRAPI.sharedInstance.uploadPix)
        [self sendGMServerMessage:GMSMessageOpenConnect];
}

- (void)dataDownSwitchTapped:(UISwitch *)aSwitch
{
    [SharedDefaults.defaults saveBool:aSwitch.on
                               forKey:@"DownloadData"];
    
    CRAPI.sharedInstance.downloadData = aSwitch.on;
    if (!_syncButton.enabled && CRAPI.sharedInstance.downloadData)
        [self sendGMServerMessage:GMSMessageOpenConnect];
}

- (void)pixDownSwitchTapped:(UISwitch *)aSwitch
{
    [SharedDefaults.defaults saveBool:aSwitch.on
                               forKey:@"DownloadPix"];
    
    CRAPI.sharedInstance.downloadPix = aSwitch.on;
    if (!_syncButton.enabled && CRAPI.sharedInstance.downloadPix)
        [self sendGMServerMessage:GMSMessageOpenConnect];

}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:YES];
}

- (void)helpButtonTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"NVCRISHelp_Synchronize"
                                                       ofType:@"pdf"];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath];
#pragma unused(nvwv)
}

- (void)tempFix:(int)iPad
          geoid:(int)geoid
{
    /*if (iPad == 1008 || iPad == 1009) // MP Alleywalls
    {
        int lastPict;
        int lastData = [_databaseID getLastDataUpdateNumber:1
                                                lastPictNum:&lastPict];
        if (lastData < 64)
            [_databaseID setLastDataUpdateNum:64
                                      foriPad:1];
        if (lastPict < 480)
            [_databaseID setLastPictUpdateNum:480
                                      foriPad:1];
        lastData = [_databaseID getLastDataUpdateNumber:2
                                            lastPictNum:&lastPict];
        if (lastData < 102)
            [_databaseID setLastDataUpdateNum:102
                                      foriPad:2];
        if (lastPict < 728)
            [_databaseID setLastPictUpdateNum:728
                                      foriPad:2];
        
    }*/
    
    /*if (iPad == 1055 && geoid == 2707966)// Brooklyn Park
    {
        int currentFix = 4;
        int lastFix = (int)[UserDefaults.defaults integerForKey:@"lastFix"];
        
        if (lastFix < currentFix)
        {
            [UserDefaults.defaults saveInteger:currentFix
                                        forKey:@"lastFix"];
            int lastPict;
            
            [_databaseID setLastDataUpdateNum:227
                                      foriPad:2];
            [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"Fix %i applied to 1055",currentFix]];
        }
        
    }*/
    
    /*if (iPad == 1055 && geoid == 2707966)// Brooklyn Park
    {
        //All of these files are from device 1055:
         
         2_2.sql
         2_92.sql
         2_125.sql
         2_127.sql
         2_123.jpg
        int iPad = 2;
        int currentFix = 5;
        int lastFix = (int)[UserDefaults.defaults integerForKey:@"lastFix"];
        NSError *error = nil;
       
        if (lastFix < currentFix)
        {
            int filenums[]={2,92,125,127};
            [UserDefaults.defaults saveInteger:currentFix
                                        forKey:@"lastFix"];
            int lastPict;
            
            for (int i = 0;i<4;i++)
            {
                int lastData = [_databaseID getLastDataUpdateNumber:iPad
                                                        lastPictNum:&lastPict];
                NSString *fromPath = [_databaseID outputDataFile:filenums[i]
                                                            iPad:iPad];
                NSString *toPath = [_databaseID outputDataFile:lastData
                                                          iPad:iPad];
                if ((int)[NSFileManager.defaultManager attributesOfItemAtPath:toPath
                                                                               error:nil].fileSize > 0)
                {
                    lastData++;
                    toPath = [_databaseID outputDataFile:lastData
                                                   iPad:iPad];
                }
                
                if ([[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error])
                {
                    [_databaseID setLastDataUpdateNum:lastData
                                              foriPad:iPad];
                    [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"File %@ renamed to %@",fromPath,toPath]];
                }
                else
                    [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"Failed to rename file %@ to %@",fromPath,toPath]];
            }
            {
                int lastData = [_databaseID getLastDataUpdateNumber:iPad
                                                        lastPictNum:&lastPict];
                NSString *fromPath = [_databaseID outputPictFile:123
                                                            iPad:iPad];
                NSString *toPath = [_databaseID outputPictFile:lastPict
                                                          iPad:iPad];
                
                if ((int)[NSFileManager.defaultManager attributesOfItemAtPath:toPath
                                                                        error:nil].fileSize > 0)
                {
                    lastPict++;
                    toPath = [_databaseID outputDataFile:lastData
                                                    iPad:iPad];
                }
                if ([[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error])
                {
                    [_databaseID setLastPictUpdateNum:lastPict
                                              foriPad:iPad];
                    [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"File %@ renamed to %@",fromPath,toPath]];
                }
                else
                    [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"Failed to rename file %@ to %@",fromPath,toPath]];
            }
            [CRAPI.sharedInstance logToErrorFile:[NSString stringWithFormat:@"Fix %i applied to 1055",currentFix]];
        }
        
    }*/
}

- (IBAction)uploadDatabases:(id)sender
{
    NSString *dir1 = [NSString stringWithFormat:@"%i",CRAPI.sharedInstance.currentManageriPad];
    
    NSString *dir2 =[NSString stringWithFormat:@"%i/%i",
                     CRAPI.sharedInstance.currentManageriPad,CRAPI.sharedInstance.currentiPadWithinManager];
    
    NSArray *directories = @[dir1,dir2];
    
    _ftpdc = [FTPDirectoryCreate createDirectories:directories
                                       inFTPDomain:[CRAPI.sharedInstance getNVCRISServer]
                                         directory:@"NVMobile/UploadedDatabases"
                                          username:@"GSSiProfessionalServer"
                                          password:@"GSSi"
                                              port:@"21"
                                          delegate:self];
}

- (void)FTPDirectoryCreateDidCompleteWithStatus:(FTPStatus)status
                                   statusString:(NSString *)statusString
                                      directory:(NSString *)directory
{
    if (status == FTPStatusOK)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(uploadDatabases2:)
                                                    userInfo:nil
                                                     repeats:NO];
        
    }
    else
    {
        _popoverView.title = [NSString stringWithFormat:@"Unable to create directories\n%@",statusString];
        [_popoverView setCancelButtonTitle:@"OK"];
        [_popoverView show];
    }
}

- (void)uploadDatabases2:(NSTimer *)timer
{
    [timer invalidate];
    _push = FTPDataPush.push;
    _push.delegate = self;
    _push.popover = _popoverView;
    _push.dataType = FTPDatabase;
    
    NSString *sendToServerFile = @"";
    
    switch (CRAPI.sharedInstance.currentApp)
    {
        case HCConfigCrimes:
            sendToServerFile = CrimeData.new.path;
            break;
        case HCConfigSewers:
            sendToServerFile = SewerData.new.path;
            break;
        case HCConfigCurbRamps:
            sendToServerFile = CurbRampData.new.databasePath;
            break;
        case HCConfigAlleyWalls:
        case HCConfigAlleyWallStatus:
            sendToServerFile = AlleyWallData.new.databasePath;
            break;
        default:break;
    }
    
    NSString *toDir = [NSString stringWithFormat:@"NVMobile/UploadedDatabases/%i/%i",
                       CRAPI.sharedInstance.currentManageriPad,
                       CRAPI.sharedInstance.currentiPadWithinManager];
    
    NSString *file = sendToServerFile.lastPathComponent;
    NSString *fromDir = sendToServerFile.stringByDeletingLastPathComponent;
    [_popoverView showAfter:0.1 withTitle:@"Upload Database"];
    
    [_push sendFile:file
      fromDirectory:fromDir
             toFile:file
        toDirectory:toDir
     deleteWhenDone:NO
     appendFileName:NO];
}

@end
