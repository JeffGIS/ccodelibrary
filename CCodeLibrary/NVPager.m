//  NVPager.m
//  CCodeLibrary

#import "NVPager.h"

@interface NVPager ()  <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic) NSArray<UIViewController *> *controllers;
@property (nonatomic) UIPageControl *pageControl;

@end

@implementation NVPager

+ (instancetype)pagerWithViewControllers:(NSArray<UIViewController *> *)controllers
{
    NVPager *pager = NVPager.new;
    pager.controllers = controllers;
    return pager;
}

- (id)init
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = UIColor.clearColor;
    
    _pageControl = UIPageControl.new;
    _pageControl.numberOfPages = _controllers.count;
    _pageControl.currentPage = 0;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    _pageControl.currentPageIndicatorTintColor = UIColor.blackColor;
    
    [self.view addSubview:_pageControl];
    [_pageControl constrainCenterXToAnchor:self.view.centerXAnchor];
    [_pageControl constrainBottomToAnchor:self.view.bottomAnchor constant:8.0];
    
    [self setViewControllers:@[_controllers[0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if (_controllers.count < 2)
        return nil;
    
    NSInteger index = [_controllers indexOfObject:viewController];
    NSParameterAssert(index != NSNotFound);
    
    if (index >= (_controllers.count - 1))
        return _controllers[0];
    
    else
        return _controllers[index + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (_controllers.count < 2)
        return nil;
    
    NSInteger index = [_controllers indexOfObject:viewController];
    NSParameterAssert(index != NSNotFound);
    
    if (index <= 0)
        return _controllers[_controllers.count - 1];
    
    else
        return _controllers[index - 1];
}

- (void)pageViewController:(UIPageViewController *)pvc
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (finished && completed)
    {
        NSInteger currentPage = [_controllers indexOfObject:pvc.viewControllers[0]];
        _pageControl.currentPage = currentPage;
    }
}

@end
