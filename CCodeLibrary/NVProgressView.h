//  NVProgressView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVProgressView : UIView

@property (nonatomic) CGFloat progress;

- (id)initWithTrackColor:(UIColor *)trackColor
           progressColor:(UIColor *)progressColor;

@end