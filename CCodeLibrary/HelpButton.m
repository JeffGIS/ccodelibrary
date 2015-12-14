//  HelpButton.m
//  CCodeLibrary

#import "HelpButton.h"
#import "UserDefaults.h"
#import "HelpWebView.h"

@interface HelpButton ()

@property (nonatomic) UIView *view;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation HelpButton

+ (HelpButton *)showHelpButtonWithOrigin:(CGPoint)origin
                                    size:(CGFloat)size
                                    view:(UIView *)view
                                     tag:(NSInteger)tag
                                  tabBar:(UITabBar *)tabBar
{
    HelpButton *helpButton = [[HelpButton alloc] initWithFrame:CGRectMake(origin.x, origin.y, size, size)];
    helpButton.tag = tag;
    helpButton.view = view;
    helpButton.tabBar = tabBar;
    
    [helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"greenHelpButton"
                                                                                        ofType:@"png"]]
                forState:UIControlStateNormal];
    
    [view addSubview:helpButton];
    
    [helpButton addTarget:helpButton
                   action:@selector(helpButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    return helpButton;
}

- (void)helpButtonTapped:(HelpButton *)helpButton
{
    NSString *presenterID = @"";
    
    switch (helpButton.tag)
    {
        case HelpButtonPresenterMapVC:
            presenterID = @"Map View";
            break;
            
        case HelpButtonPresenterLayersVC:
            presenterID = @"Layers View";
            break;
            
        case HelpButtonPresenterFindVC:
            presenterID = @"Find View";
            break;
            
        case HelpButtonPresenterApplicationsVC:
            presenterID = @"Applications View";
            break;
            
        case HelpButtonPresenterSettingsVC:
            presenterID = @"Settings View";
            break;
            
        case HelpButtonPresenterCRISInventoryVC:
            presenterID = @"CRIS Inventory View";
            break;
            
        default:
            break;
    }
    
    HelpWebView *helpWebView = [HelpWebView showHelpWebView:_view
                                                presenterID:presenterID
                                                     tabBar:_tabBar];
#pragma unused(helpWebView)
}

@end