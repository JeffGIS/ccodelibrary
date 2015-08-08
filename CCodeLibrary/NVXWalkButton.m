//  NVXWalkButton.m
//  CCodeLibrary

#import "NVXWalkButton.h"

@implementation NVXWalkButton

+ (NVXWalkButton *)addToView:(UIView *)view
                         tag:(NSInteger)tag
                       title:(NSString *)title
{
    NVXWalkButton *xWalkButton = [[NVXWalkButton alloc] init];
    xWalkButton.tag = tag;
    
    [xWalkButton setTitle:title
                 forState:UIControlStateNormal];
    
    xWalkButton.frame = CGRectMake(0.0, 0.0, 108.0, 40.0);
    xWalkButton.backgroundColor = UIColor.whiteColor;
    xWalkButton.layer.borderWidth = 4.0;
    xWalkButton.layer.borderColor = UIColor.blackColor.CGColor;
    xWalkButton.titleLabel.font = [UIFont boldSystemFontOfSize:34];
    xWalkButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    xWalkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    xWalkButton.showsTouchWhenHighlighted = NO;
    xWalkButton.hidden = YES;
    
    [xWalkButton setTitleColor:UIColor.blackColor
                      forState:UIControlStateNormal];
    
    [view addSubview:xWalkButton];
    
    return xWalkButton;
}

@end