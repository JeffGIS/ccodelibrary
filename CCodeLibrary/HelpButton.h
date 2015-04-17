//  HelpButton.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HelpButtonPresenter)
{
    HelpButtonPresenterDefault,
    HelpButtonPresenterMapVC,
    HelpButtonPresenterLayersVC,
    HelpButtonPresenterFindVC,
    HelpButtonPresenterApplicationsVC,
    HelpButtonPresenterSettingsVC,
};


@interface HelpButton : UIButton

+ (HelpButton *)showHelpButtonWithOrigin:(CGPoint)origin
                                    size:(CGFloat)size
                                    view:(UIView *)view
                                     tag:(NSInteger)tag
                                  tabBar:(UITabBar *)tabBar;

@end