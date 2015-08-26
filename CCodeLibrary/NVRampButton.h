//  NVRampButton.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "RampTypeView.h"

@interface NVRampButton : UIButton

@property (nonatomic) RampType type;
@property (nonatomic) UIButton *leftSideRamp;
@property (nonatomic) UIButton *rightSideRamp;

+ (NVRampButton *)addToView:(UIView *)view
                        tag:(NSInteger)tag
                      title:(NSString *)title;

@end