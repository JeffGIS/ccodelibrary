//  NVRampButton.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "RampTypeView.h"

@interface NVRampButton : UIButton

@property (nonatomic) RampType type;

+ (NVRampButton *)addToView:(UIView *)view
                        tag:(NSInteger)tag
                      title:(NSString *)title;

@end