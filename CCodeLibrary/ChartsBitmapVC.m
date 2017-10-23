//  ChartsBitmapVC.m
//  CCodeLibrary

#import "ChartsBitmapVC.h"
#import "CRAPI.h"

@interface ChartsBitmapVC ()

@property (nonatomic) UIImageView *chartsView;
@property (nonatomic) UIButton *returnButton;
@property NSInteger currentIndex;
@property int yMargin;

@end

@implementation ChartsBitmapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _yMargin = 60;
    _currentIndex = 0;
    
    ChartsBitmap *cb = CRAPI.sharedInstance.chartBitmaps[_currentIndex];
    cb.chartWidth = (int)(self.view.frame.size.width * 4);
    cb.chartHeight = (int)((self.view.frame.size.height - (_yMargin * 2)) * 4);
    cb.useOffset = YES;
    [cb createChartBitmap];
    UIImage *image = [UIImage imageWithContentsOfFile:cb.outputFile];
    _chartsView = [[UIImageView alloc] initWithImage:image];
    _chartsView.translatesAutoresizingMaskIntoConstraints = NO;
    _chartsView.contentMode = UIViewContentModeScaleAspectFit;
    _chartsView.clipsToBounds = YES;
    
    [self.view addSubview:_chartsView];
    [_chartsView constrainToView:self.view leading:0.0 trailing:0.0 top:_yMargin bottom:-_yMargin];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:20.0];
    [_returnButton constrainTopToAnchor:self.view.topAnchor constant:6.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ChartsBitmap *cb = CRAPI.sharedInstance.chartBitmaps[_currentIndex];
    cb.chartWidth = (int)(self.view.frame.size.width * 4);
    cb.chartHeight = (int)((self.view.frame.size.height - (_yMargin * 2)) * 4);
    [cb createChartBitmap];
    UIImage *image = [UIImage imageWithContentsOfFile:cb.outputFile];
    _chartsView.image = image;
}

@end
