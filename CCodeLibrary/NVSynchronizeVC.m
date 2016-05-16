//  NVSynchronizeVC.m
//  CCodeLibrary

#import "NVSynchronizeVC.h"
#import "NVProgressView.h"
#import "GeoMasterServer.h"
#import "UserDefaults.h"
#import "Colors.h"
#import "CRAPI.h"
#import "NVAlertView.h"

@interface NVSynchronizeVC () <GeoMasterServerDelegate,NVAlertViewDelegate>

@property (nonatomic) UILabel *titleLabel, *dataUpLabel, *pixUpLabel, *dataDownLabel, *pixDownLabel, *overallLabel, *currentFileLabel;
@property (nonatomic) UIButton *syncButton, *cancelButton, *returnButton;
@property (nonatomic) UISwitch *pixUpSwitch, *pixDownSwitch, *dataDownSwitch;
@property (nonatomic) NVProgressView *overallProgressView, *currentFileProgressView;
@property (nonatomic) Colors *colors;
@property int upFiles, upPix, downFiles, downPix;
@property (nonatomic) GeoMasterServer *GMServer;

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
    
    _colors = UserDefaults.defaults.defaultColors;
    self.view.backgroundColor = _colors.backgroundColor;
    _upFiles = _upPix = _downFiles = _downPix = 0;
    
    _titleLabel = UILabel.new;
    [self setupLabel:_titleLabel];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:44.0];
    _titleLabel.text = @"Synchronize";
    
    _dataUpLabel = UILabel.new;
    [self setupLabel:_dataUpLabel];
    
    _pixUpLabel = UILabel.new;
    [self setupLabel:_pixUpLabel];
    
    _pixUpSwitch = UISwitch.new;
    [self setupSwitch:_pixUpSwitch];
    
    _dataDownLabel = UILabel.new;
    [self setupLabel:_dataDownLabel];
    
    _dataDownSwitch = UISwitch.new;
    [self setupSwitch:_dataDownSwitch];
    
    _pixDownLabel = UILabel.new;
    [self setupLabel:_pixDownLabel];
    
    _pixDownSwitch = UISwitch.new;
    [self setupSwitch:_pixDownSwitch];
    
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
    
    _overallProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                        progressColor:UIColor.whiteColor];
    
    _currentFileProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                            progressColor:UIColor.whiteColor];
    
    _overallLabel = UILabel.new;
    [self setupLabel:_overallLabel];
    _overallLabel.textAlignment = NSTextAlignmentCenter;
    [self updateOverallProgress:0.0];
    
    _currentFileLabel = UILabel.new;
    [self setupLabel:_currentFileLabel];
    _currentFileLabel.textAlignment = NSTextAlignmentCenter;
    [self updateCurrentFileProgress:0.0];
    
    int numSections = 9;
    CGFloat borderWidth = 1.0;
    CGFloat margin = (40.0 + borderWidth);
    CGFloat buttonMargin = 16.0;
    CGFloat screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    
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
                [sectionView addSubview:_titleLabel];
                [_titleLabel constrainToView:sectionView leading:margin trailing:-margin top:0.0 bottom:0.0];
                [_titleLabel.topAnchor constraintEqualToAnchor:sectionView.topAnchor].active = YES;
                
                [sectionView addSubview:_returnButton];
                [_returnButton.centerYAnchor constraintEqualToAnchor:sectionView.centerYAnchor].active = YES;
                [_returnButton.leadingAnchor constraintEqualToAnchor:sectionView.leadingAnchor constant:buttonMargin].active = YES;
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
    [_GMServer initCommunication:5.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    button.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
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

- (void)syncButtonTapped:(UIButton *)button
{
    
}

- (void)cancelButtonTapped:(UIButton *)button
{
    
}

- (void)returnButtonTapped:(UIButton *)button
{
    [_delegate synchronizeControllerDidReturn:self];
}

- (void)closeGMServer
{
    if (_GMServer)
    {
        [_GMServer closeServer];
        _GMServer.delegate = nil;
        _GMServer = nil;
    }
}

- (void)GMServerDidOpen:(GeoMasterServer *)server
{
    NSString *msg = [NSString stringWithFormat:@"$M(GetUploadStatus,%i,%i)",
                     CRAPI.sharedInstance.currentManageriPad, CRAPI.sharedInstance.currentGeoid];
    
    if (msg)
        [_GMServer sendMessage:msg];
    
    NSLog(@"GMServer Query:%@", msg);
}

- (void)GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
      withStatus:(long)status
{
    [self closeGMServer];
    NSLog(@"GMServer Message(NVSynchronizeVC):%@", message);
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
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:YES];
}

@end