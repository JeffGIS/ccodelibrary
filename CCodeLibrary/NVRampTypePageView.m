//  NVRampTypePageView.m
//  CCodeLibrary

#import "NVRampTypePageView.h"
#import "UserDefaults.h"

@interface NVRampTypePageView ()

@property NSArray *rampTypes;
@property NSUInteger startingIndex;

@end

@implementation NVRampTypePageView

+ (instancetype)pageViewWithRampTypes:(NSArray *)rampTypes
                        startingIndex:(NSUInteger)startingIndex
{
    NVRampTypePageView *nvpv = NVRampTypePageView.new;
    nvpv.startingIndex = startingIndex;
    nvpv.rampTypes = rampTypes;
    return nvpv;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.clearColor;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end