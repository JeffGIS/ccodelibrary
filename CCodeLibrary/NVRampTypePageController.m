//  NVRampTypePageController.m
//  CCodeLibrary

#import "NVRampTypePageController.h"
#import "NVRampTypePageView.h"
#import "UserDefaults.h"

@implementation NVRampType

+ (instancetype)perpRamp
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Perpendicular";
    rt.imageName = @"Perp";
    rt.type = RampTypePerp;
    return rt;
}

+ (instancetype)perpNonWalkableRamp
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Perpendicular With\nNon-Walkable Surface";
    rt.imageName = @"PerpNonWalkable";
    rt.type = RampTypePerpNonWalk;
    return rt;
}

+ (instancetype)comPerp
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Combined Perpendicular\nWith Walkable Surface";
    rt.imageName = @"ComPerp";
    rt.type = RampTypeCombPerpWalk;
    return rt;
}

+ (instancetype)comPerpNW
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Combined Perpendicular\nWith Non-Walkable Surface";
    rt.imageName = @"ComPerpNW";
    rt.type = RampTypeCombPerpNonWalk;
    return rt;
}

+ (instancetype)oneWayAdj
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"One Way Directional\nAdjacent to Curb & Gutter";
    rt.imageName = @"OneWayAdj";
    rt.type = RampTypeOneWayDirCurbGutter;
    return rt;
}

+ (instancetype)oneWayBlend
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"One Way Directional\nBlended Transition";
    rt.imageName = @"OneWayBlend";
    rt.type = RampTypeOneWayDirBlendTrans;
    return rt;
}

+ (instancetype)parallel
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Parallel";
    rt.imageName = @"Parallel";
    rt.type = RampTypeParallel;
    return rt;
}

+ (instancetype)depCorner
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Depressed Corner";
    rt.imageName = @"DepCorner";
    rt.type = RampTypeDepressedCorner;
    return rt;
}

+ (instancetype)fan
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Fan";
    rt.imageName = @"Fan";
    rt.type = RampTypeFan;
    return rt;
}

+ (instancetype)builtUp
{
    NVRampType *rt = NVRampType.new;
    rt.displayText = @"Built Up";
    rt.imageName = @"BuiltUp";
    rt.type = RampTypeBuiltUp;
    return rt;
}

@end

@interface NVRampTypePageController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,NVRampTypePageViewDelegate>

@property (nonatomic, weak) id <NVRampTypePageControllerDelegate> controllerDelegate;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSMutableArray *rampTypes;
@property (nonatomic) UIButton *returnButton;
@property RampTypeEditOption editOption;
@property RampType selectedType;

@end

@implementation NVRampTypePageController

+ (instancetype)rampTypeControllerWithDelegate:(id)delegate
                                  selectedType:(RampType)selectedType
                                    editOption:(RampTypeEditOption)editOption
{
    if (!delegate)
    {
        NSLog(@"NVRampTypePageController ERROR:Cannot set delegate to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(rampTypeController:didReturnRampType:editOption:)])
    {
        NSLog(@"NVRampTypePageController ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    NVRampTypePageController *nvrtpc = NVRampTypePageController.new;
    nvrtpc.controllerDelegate = delegate;
    nvrtpc.selectedType = selectedType;
    nvrtpc.editOption = editOption;
    return nvrtpc;
}

+ (void)setupReturnButton:(UIButton *)button
{
    button.frame = CGRectMake(20.0, 20.0, 160.0, 40.0);
    button.backgroundColor = UIColor.clearColor;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    [button setTitle:@"< Return"
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
}

+ (NSArray *)defaultRampTypes
{
    return @[NVRampType.perpRamp, NVRampType.perpNonWalkableRamp, NVRampType.comPerp, NVRampType.comPerpNW,
             NVRampType.oneWayAdj, NVRampType.oneWayBlend, NVRampType.parallel, NVRampType.depCorner,
             NVRampType.fan, NVRampType.builtUp];
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
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    _pages = NSMutableArray.array;
    
    _rampTypes = NSMutableArray.array;
    [_rampTypes addObjectsFromArray:NVRampTypePageController.defaultRampTypes];
    [_rampTypes addObjectsFromArray:[UserDefaults.defaults arrayForKey:@"CustomRampTypes"]];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [NVRampTypePageController setupReturnButton:_returnButton];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    
    [self setupPages];
    
    [self setViewControllers:@[_pages[0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setupPages
{
    NSMutableArray *pageArray = NSMutableArray.array;
    NSUInteger index = 0;
    
    for (int i = 0; i < _rampTypes.count; i++)
    {
        [pageArray addObject:_rampTypes[i]];
        
        if (pageArray.count == 9)
        {
            NVRampTypePageView *page = [NVRampTypePageView pageViewWithRampTypes:pageArray.copy
                                                                   startingIndex:index
                                                                    selectedType:_selectedType
                                                                        delegate:self];
            
            [_pages addObject:page];
            
            index += 9;
            [pageArray removeAllObjects];
        }
    }
    
    NVRampTypePageView *page = [NVRampTypePageView pageViewWithRampTypes:pageArray.copy
                                                           startingIndex:index
                                                            selectedType:_selectedType
                                                                delegate:self];
    
    [_pages addObject:page];
    
    CGFloat pageControlHeight = 40.0;
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - pageControlHeight,
                                                                   self.view.frame.size.width, pageControlHeight)];
    
    _pageControl.numberOfPages = _pages.count;
    _pageControl.currentPage = 0;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.hidesForSinglePage = YES;
    [self.view addSubview:_pageControl];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [_controllerDelegate rampTypeController:self
                          didReturnRampType:_selectedType
                                 editOption:_editOption];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [_pages indexOfObject:viewController];
    
    NSParameterAssert(index != NSNotFound);
    
    if (index >= (_pages.count - 1))
        return nil;
    
    return _pages[index + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [_pages indexOfObject:viewController];
    NSParameterAssert(index != NSNotFound);
    
    if (index <= 0)
        return nil;
    
    return _pages[index - 1];
}

- (void)pageViewController:(UIPageViewController *)pvc
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    NSInteger currentPage = [_pages indexOfObject:pvc.viewControllers[0]];
    NVRampTypePageView *page = _pages[currentPage];
    _returnButton.hidden = page.isZoomed;
    
    if (finished && completed)
        _pageControl.currentPage = currentPage;
}

- (void)rampTypePageView:(NVRampTypePageView *)rampTypePageView
       didReturnRampType:(RampType)rampType
{
    [_controllerDelegate rampTypeController:self
                          didReturnRampType:rampType
                                 editOption:_editOption];
}

- (void)rampTypePageViewDidZoom:(BOOL)didZoom
{
    _returnButton.hidden = didZoom;
}

@end