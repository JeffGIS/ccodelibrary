//  NVLegendView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVLegendView : UIView

+ (NVLegendView *)showLegendViewAtOrigin:(CGPoint)origin
                                  inView:(UIView *)view
                                   title:(NSString *)title;

- (void)hideLegendView:(BOOL)animated;

@end