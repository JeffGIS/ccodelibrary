//  ChartsBitmapVC.m
//  CCodeLibrary

#import "ChartsBitmapVC.h"
#import "CRAPI.h"

@interface ChartsBitmapVC ()

@property (nonatomic) UIImageView *chartsView;
@property NSInteger currentIndex;
@property int yMargin, sizeFactor;

@end

@implementation ChartsBitmapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _yMargin = 60;
    _currentIndex = 0;
    _sizeFactor = 2;
    
    _chartsView = UIImageView.new;
    _chartsView.translatesAutoresizingMaskIntoConstraints = NO;
    _chartsView.contentMode = UIViewContentModeScaleAspectFit;
    _chartsView.clipsToBounds = YES;
    
    [self.view addSubview:_chartsView];
    [_chartsView constrainToView:self.view leading:0.0 trailing:0.0 top:_yMargin bottom:-_yMargin];
    
    UIFont *font = [UIFont boldSystemFontOfSize:32.0];
    CGFloat xm = 20.0;
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.titleLabel.font = font;
    [returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [returnButton addTarget:self
                     action:@selector(returnButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:xm];
    [returnButton constrainTopToAnchor:self.view.topAnchor constant:4.0];
    
    font = [UIFont boldSystemFontOfSize:48.0];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.translatesAutoresizingMaskIntoConstraints = NO;
    previousButton.titleLabel.font = font;
    [previousButton setTitle:@"<<" forState:UIControlStateNormal];
    [previousButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [previousButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [previousButton addTarget:self
                       action:@selector(previousButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:previousButton];
    [previousButton constrainLeadingToAnchor:self.view.leadingAnchor constant:xm];
    [previousButton constrainBottomToAnchor:self.view.bottomAnchor];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    nextButton.titleLabel.font = font;
    [nextButton setTitle:@">>" forState:UIControlStateNormal];
    [nextButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [nextButton addTarget:self
                       action:@selector(nextButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:nextButton];
    [nextButton constrainTrailingToAnchor:self.view.trailingAnchor constant:-xm];
    [nextButton constrainBottomToAnchor:self.view.bottomAnchor];
    
    [self updateChart];
}

- (void)updateChart
{
    ChartsBitmap *cb = CRAPI.sharedInstance.chartBitmaps[_currentIndex];
    cb.chartWidth = (int)(self.view.frame.size.width * _sizeFactor);
    cb.chartHeight = (int)((self.view.frame.size.height - (_yMargin * 2)) * _sizeFactor);
    cb.useOffset = YES;
    [cb createChartBitmap];
    UIImage *image = [UIImage imageWithContentsOfFile:cb.outputFile];
    _chartsView.image = image;
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

- (void)previousButtonTapped:(UIButton *)button
{
    if (_currentIndex > 0)
        _currentIndex--;
    
    else
        _currentIndex = (int)(CRAPI.sharedInstance.chartBitmaps.count - 1);
    
    [self updateChart];
}

- (void)nextButtonTapped:(UIButton *)button
{
    if (_currentIndex < (CRAPI.sharedInstance.chartBitmaps.count - 1))
        _currentIndex++;
    
    else
        _currentIndex = 0;
    
    [self updateChart];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateChart];
}

@end
