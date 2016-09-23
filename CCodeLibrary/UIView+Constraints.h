//  UIView+Constraints.h
//  CCodeLibrary

@import UIKit;

@interface UIView (Constraints)

- (void)constrainToView:(UIView *)view
                leading:(CGFloat)leading
               trailing:(CGFloat)trailing
                    top:(CGFloat)top
                 bottom:(CGFloat)bottom;

- (UIViewController *)parentViewController;
- (void)removeAllConstraints;

- (void)constrainLeadingToAnchor:(NSLayoutXAxisAnchor *)anchor;
- (void)constrainTrailingToAnchor:(NSLayoutXAxisAnchor *)anchor;
- (void)constrainTopToAnchor:(NSLayoutYAxisAnchor *)anchor;
- (void)constrainBottomToAnchor:(NSLayoutYAxisAnchor *)anchor;
- (void)constrainHeightToConstant:(CGFloat)constant;
- (void)constrainWidthToConstant:(CGFloat)constant;
- (void)constrainCenterXToAnchor:(NSLayoutXAxisAnchor *)anchor;
- (void)constrainCenterYToAnchor:(NSLayoutYAxisAnchor *)anchor;

- (void)constrainLeadingToAnchor:(NSLayoutXAxisAnchor *)anchor
                        constant:(CGFloat)constant;

- (void)constrainTrailingToAnchor:(NSLayoutXAxisAnchor *)anchor
                         constant:(CGFloat)constant;

- (void)constrainTopToAnchor:(NSLayoutYAxisAnchor *)anchor
                    constant:(CGFloat)constant;

- (void)constrainBottomToAnchor:(NSLayoutYAxisAnchor *)anchor
                       constant:(CGFloat)constant;

@end
