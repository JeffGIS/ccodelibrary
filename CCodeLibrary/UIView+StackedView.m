//  UIView+StackedView.m
//  CCodeLibrary

#import "UIView+StackedView.h"

@implementation UIView (StackedView)

- (BOOL)isStacked
{
    BOOL rtn = NO;
    
    for (UIView *views in self.superview.subviews)
    {
        if ([views isKindOfClass:self.class] && (self != views))
        {
            if (CGRectIntersectsRect(views.frame, self.frame))
                return YES;
        }
    }
    
    return rtn;
}

@end