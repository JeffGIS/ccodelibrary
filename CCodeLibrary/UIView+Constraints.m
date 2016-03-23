//  UIView+Constraints.m
//  CCodeLibrary

#import "UIView+Constraints.h"

@implementation UIView (Constraints)

- (void)constrainToView:(UIView *)view
                leading:(CGFloat)leading
               trailing:(CGFloat)trailing
                    top:(CGFloat)top
                 bottom:(CGFloat)bottom
{
    [self removeAllConstraints];
    
    [self.leadingAnchor constraintEqualToAnchor:view.leadingAnchor
                                       constant:leading].active = YES;
    
    [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor
                                        constant:trailing].active = YES;
    
    [self.topAnchor constraintEqualToAnchor:view.topAnchor
                                   constant:top].active = YES;
    
    [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor
                                      constant:bottom].active = YES;
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