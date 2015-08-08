//  NVSignalButton.m
//  CCodeLibrary

#import "NVSignalButton.h"
#import "UserDefaults.h"

@implementation NVSignalButton

+ (NVSignalButton *)addToView:(UIView *)view
                          tag:(NSInteger)tag
                        title:(NSString *)title
{
    NVSignalButton *signalButton = [[NVSignalButton alloc] init];
    signalButton.tag = tag;
    
    [signalButton setTitle:title
                  forState:UIControlStateNormal];
    
    signalButton.frame = CGRectMake(0.0, 0.0, 100.0, 140.0);
    signalButton.titleLabel.font = [UIFont boldSystemFontOfSize:34];
    signalButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signalButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    signalButton.titleEdgeInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
    signalButton.showsTouchWhenHighlighted = NO;
    signalButton.hidden = YES;
    
    [signalButton setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [signalButton setBackgroundImage:UserDefaults.defaults.triangleImage
                            forState:UIControlStateNormal];
    
    [view addSubview:signalButton];
    
    return signalButton;
}

@end