//  UIView+Constraints.m
//  CCodeLibrary

#import "UIView+Constraints.h"

@implementation UIView (Constraints)

- (void)constrainLeadingToAnchor:(NSLayoutXAxisAnchor *)anchor
{
    [self.leadingAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainTrailingToAnchor:(NSLayoutXAxisAnchor *)anchor
{
    [self.trailingAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainTopToAnchor:(NSLayoutYAxisAnchor *)anchor
{
    [self.topAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainBottomToAnchor:(NSLayoutYAxisAnchor *)anchor
{
    [self.bottomAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainLeadingToAnchor:(NSLayoutXAxisAnchor *)anchor
                        constant:(CGFloat)constant
{
    [self.leadingAnchor constraintEqualToAnchor:anchor constant:constant].active = YES;
}

- (void)constrainTrailingToAnchor:(NSLayoutXAxisAnchor *)anchor
                         constant:(CGFloat)constant
{
    [self.trailingAnchor constraintEqualToAnchor:anchor constant:constant].active = YES;
}

- (void)constrainTopToAnchor:(NSLayoutYAxisAnchor *)anchor
                    constant:(CGFloat)constant
{
    [self.topAnchor constraintEqualToAnchor:anchor constant:constant].active = YES;
}

- (void)constrainBottomToAnchor:(NSLayoutYAxisAnchor *)anchor
                       constant:(CGFloat)constant
{
    [self.bottomAnchor constraintEqualToAnchor:anchor constant:constant].active = YES;
}

- (void)constrainHeightToConstant:(CGFloat)constant
{
    [self.heightAnchor constraintEqualToConstant:constant].active = YES;
}

- (void)constrainWidthToConstant:(CGFloat)constant
{
    [self.widthAnchor constraintEqualToConstant:constant].active = YES;
}

- (void)constrainCenterXToAnchor:(NSLayoutXAxisAnchor *)anchor
{
    [self.centerXAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainCenterYToAnchor:(NSLayoutYAxisAnchor *)anchor
{
    [self.centerYAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainHeightToAnchor:(NSLayoutDimension *)anchor
{
    [self.heightAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainWidthToAnchor:(NSLayoutDimension *)anchor
{
    [self.widthAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)constrainHeightToAnchor:(NSLayoutDimension *)anchor
                     multiplier:(CGFloat)multipler
{
    [self.heightAnchor constraintEqualToAnchor:anchor multiplier:multipler].active = YES;
}

- (void)constrainWidthToAnchor:(NSLayoutDimension *)anchor
                    multiplier:(CGFloat)multipler
{
    [self.widthAnchor constraintEqualToAnchor:anchor multiplier:multipler].active = YES;
}

- (void)constrainCenterXToAnchor:(NSLayoutXAxisAnchor *)anchor
                        constant:(CGFloat)constant
{
    [self.centerXAnchor constraintEqualToAnchor:anchor constant:constant].active = YES;
}

- (void)constrainCenterYToAnchor:(NSLayoutYAxisAnchor *)anchor
                        constant:(CGFloat)constant
{
    [self.centerYAnchor constraintEqualToAnchor:anchor constant:constant].active = YES;
}

- (void)constrainToView:(UIView *)view
                leading:(CGFloat)leading
               trailing:(CGFloat)trailing
                    top:(CGFloat)top
                 bottom:(CGFloat)bottom
{
    [self removeAllConstraints];
    [self.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:leading].active = YES;
    [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:trailing].active = YES;
    [self.topAnchor constraintEqualToAnchor:view.topAnchor constant:top].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:bottom].active = YES;
}

- (void)removeAllConstraints
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        for (NSLayoutConstraint *constraints in superview.constraints)
        {
            if (constraints.firstItem == self || constraints.secondItem == self)
                [superview removeConstraint:constraints];
        }
        
        superview = superview.superview;
    }
    
    [self removeConstraints:self.constraints];
}

- (UIViewController *)parentViewController
{
    for (UIView *next = self; next; next = next.superview)
    {
        UIResponder *nextResponder = next.nextResponder;
        
        if ([nextResponder isKindOfClass:UIViewController.class])
            return (UIViewController *)nextResponder;
    }
    
    return nil;
}

@end
