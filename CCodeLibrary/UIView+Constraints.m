//  UIView+Constraints.m
//  CCodeLibrary

#import "UIView+Constraints.h"
#import "UserDefaults.h"

@implementation NVConstrainedView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UserDefaults.defaults.appleGray;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 2.0;
    }
    
    return self;
}

@end

@implementation NVConstrainedButton

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.blackColor;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    }
    
    return self;
}

@end

@implementation NVConstrainedLabel

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.adjustsFontSizeToFitWidth = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = UIColor.clearColor;
        self.textColor = UIColor.blackColor;
        self.adjustsFontSizeToFitWidth = YES;
        self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    }
    
    return self;
}

@end

@implementation NVConstrainedSwitch

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.tintColor = UIColor.redColor;
    }
    
    return self;
}

@end

@implementation NVConstrainedTextField

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.adjustsFontSizeToFitWidth = YES;
        self.textColor = UIColor.blackColor;
        self.backgroundColor = UIColor.whiteColor;
        self.tintColor = UIColor.grayColor;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    return self;
}

@end

@implementation NVConstrainedTableView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.separatorInset = UIEdgeInsetsZero;
        self.separatorColor = UIColor.blackColor;
        self.backgroundColor = UserDefaults.defaults.green;
        self.layer.borderColor = UIColor.blackColor.CGColor;
    }
    
    return self;
}

@end

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

- (UIImage *)imageOfFrame:(CGRect)frame
{
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImageView *)imageViewOfFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [self imageOfFrame:frame];
    return imageView;
}

- (UIImageView *)invertedImageViewOfFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    CIImage *input = [[CIImage alloc] initWithImage:[self imageOfFrame:frame]];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setDefaults];
    [filter setValue:input forKey:@"inputImage"];
    CIImage *output = [filter valueForKey:@"outputImage"];
    UIImage *image = [[UIImage alloc] initWithCIImage:output];
    imageView.image = image;
    return imageView;
}

- (void)invertColorsInsideFrame:(CGRect)frame
{
    [self addSubview:[self invertedImageViewOfFrame:frame]];
}

@end
