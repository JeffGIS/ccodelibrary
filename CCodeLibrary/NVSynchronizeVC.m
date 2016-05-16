//  NVSynchronizeVC.m
//  CCodeLibrary

#import "NVSynchronizeVC.h"
#import "NVProgressView.h"
#import "GeoMasterServer.h"
#import "UserDefaults.h"
#import "Colors.h"

@interface NVSynchronizeVC ()

@property (nonatomic) UILabel *titleLabel, *dataUpLabel, *pixUpLabel, *dataDownLabel, *pixDownLabel, *overallLabel, *currentFileLabel;
@property (nonatomic) UIButton *syncButton, *cancelButton;
@property (nonatomic) UISwitch *pixUpSwitch, *pixDownSwitch, *dataDownSwitch;
@property (nonatomic) NVProgressView *overallProgressView, *currentFileProgressView;
@property (nonatomic) Colors *colors;

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
    
    _titleLabel = UILabel.new;
    [self setupLabel:_titleLabel];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:44.0];
    _titleLabel.text = @"Synchronize Devices";
    
    _dataUpLabel = UILabel.new;
    [self setupLabel:_dataUpLabel];
    _dataUpLabel.text = @"Data Files to be Uploaded:";
    
    _pixUpLabel = UILabel.new;
    [self setupLabel:_pixUpLabel];
    _pixUpLabel.text = @"Pictures to be Uploaded:";
    
    _pixUpSwitch = UISwitch.new;
    [self setupSwitch:_pixUpSwitch];
    
    _dataDownLabel = UILabel.new;
    [self setupLabel:_dataDownLabel];
    _dataDownLabel.text = @"Data Files to be Downloaded:";
    
    _dataDownSwitch = UISwitch.new;
    [self setupSwitch:_dataDownSwitch];
    
    _pixDownLabel = UILabel.new;
    [self setupLabel:_pixDownLabel];
    _pixDownLabel.text = @"Pictures to be Downloaded:";
    
    _pixDownSwitch = UISwitch.new;
    [self setupSwitch:_pixDownSwitch];
    
    _syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_syncButton];
    
    [_syncButton setTitle:@"Synchronize"
                 forState:UIControlStateNormal];
    
    [_syncButton addTarget:self
                    action:@selector(syncButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:_cancelButton];
    
    [_cancelButton setTitle:@"Cancel"
                 forState:UIControlStateNormal];
    
    [_cancelButton addTarget:self
                      action:@selector(cancelButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _overallProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                        progressColor:UIColor.whiteColor];
    
    _currentFileProgressView = [[NVProgressView alloc] initWithTrackColor:UIColor.blackColor
                                                            progressColor:UIColor.whiteColor];
    
    _overallLabel = UILabel.new;
    [self setupLabel:_overallLabel];
    _overallLabel.textAlignment = NSTextAlignmentCenter;
    _overallLabel.text = @"Overall Progress:";
    
    _currentFileLabel = UILabel.new;
    [self setupLabel:_currentFileLabel];
    _currentFileLabel.textAlignment = NSTextAlignmentCenter;
    _currentFileLabel.text = @"Current File Progress:";
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)syncButtonTapped:(UIButton *)button
{
    
}

- (void)cancelButtonTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end