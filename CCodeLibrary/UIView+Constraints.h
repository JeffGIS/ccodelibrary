//  UIView+Constraints.h
//  CCodeLibrary

@import UIKit;

@interface UIView (Constraints)

- (void)constrainToView:(UIView *)view
                leading:(CGFloat)leading
               trailing:(CGFloat)trailing
                    top:(CGFloat)top
                 bottom:(CGFloat)bottom;

- (void)removeAllConstraints;

@end