//  NVXWalkButton.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVXWalkButton : UIButton

+ (NVXWalkButton *)addToView:(UIView *)view
                         tag:(NSInteger)tag
                       title:(NSString *)title;

@end