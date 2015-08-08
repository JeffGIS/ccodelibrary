//  NVSignalButton.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVSignalButton : UIButton

+ (NVSignalButton *)addToView:(UIView *)view
                          tag:(NSInteger)tag
                        title:(NSString *)title;

@end