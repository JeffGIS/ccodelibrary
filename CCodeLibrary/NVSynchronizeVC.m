//  NVSynchronizeVC.m
//  CCodeLibrary

#import "NVSynchronizeVC.h"
#import "NVProgressView.h"
#import "GeoMasterServer.h"
#import "UserDefaults.h"
#import "Colors.h"

@interface NVSynchronizeVC ()

@property (nonatomic) UILabel *titleLabel, *dataUpLabel, *pixUpLabel, *dataDownLabel, *pixDownLabel;
@property (nonatomic) UIButton *syncButton, *cancelButton;
@property (nonatomic) UISwitch *pixUpSwitch, *pixDownSwitch;
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
    
    int numSections = 9;
    
    for (int i = 0; i < numSections; i++)
    {
        UIView *sectionView = UIView.new;
        sectionView.tag = ((i + 1) * 100);
        sectionView.translatesAutoresizingMaskIntoConstraints = NO;
        sectionView.backgroundColor = UIColor.clearColor;
        
        [self.view addSubview:sectionView];
        
        [sectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [sectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        
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
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end