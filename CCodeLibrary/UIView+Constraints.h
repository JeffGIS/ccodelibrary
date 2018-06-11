//  UIView+Constraints.h
//  CCodeLibrary

@import UIKit;

@interface NVConstrainedView : UIView

@end

@interface NVConstrainedButton : UIButton

@end

@interface NVConstrainedLabel : UILabel

@end

@interface NVConstrainedSwitch : UISwitch

@end

@interface NVConstrainedTextField : UITextField

@end

@interface NVConstrainedTableView : UITableView

@end

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
- (void)constrainHeightToAnchor:(NSLayoutDimension *)anchor;
- (void)constrainWidthToAnchor:(NSLayoutDimension *)anchor;

- (void)constrainLeadingToAnchor:(NSLayoutXAxisAnchor *)anchor
                        constant:(CGFloat)constant;

- (void)constrainTrailingToAnchor:(NSLayoutXAxisAnchor *)anchor
                         constant:(CGFloat)constant;

- (void)constrainTopToAnchor:(NSLayoutYAxisAnchor *)anchor
                    constant:(CGFloat)constant;

- (void)constrainBottomToAnchor:(NSLayoutYAxisAnchor *)anchor
                       constant:(CGFloat)constant;

- (void)constrainWidthToAnchor:(NSLayoutDimension *)anchor
                    multiplier:(CGFloat)multipler;

- (void)constrainHeightToAnchor:(NSLayoutDimension *)anchor
                     multiplier:(CGFloat)multipler;

- (void)constrainCenterXToAnchor:(NSLayoutXAxisAnchor *)anchor
                        constant:(CGFloat)constant;

- (void)constrainCenterYToAnchor:(NSLayoutYAxisAnchor *)anchor
                        constant:(CGFloat)constant;

- (UIImage *)imageOfFrame:(CGRect)frame;
- (UIImageView *)imageViewOfFrame:(CGRect)frame;
- (UIImageView *)invertedImageViewOfFrame:(CGRect)frame;
- (void)invertColorsInsideFrame:(CGRect)frame;

@end
