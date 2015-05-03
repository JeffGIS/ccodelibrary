//  NVProgressView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVProgressView : UIView

@property (nonatomic) CGFloat progress;

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          trackColor:(UIColor *)trackColor
       progressColor:(UIColor *)progressColor;

@end