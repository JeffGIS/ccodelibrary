//  NVAlertView.m
//  CCodeLibrary

#import "NVAlertView.h"
#import "UserDefaults.h"

@interface NVAlertView ()

@property (nonatomic) UILabel *titleLabel;

@end

@implementation NVAlertView

+ (NVAlertView *)showLargeAlertViewinView:(UIView *)view
                                 delegate:(id)delegate
                                    title:(NSString *)title
                          buttonTextArray:(NSArray *)buttonTextArray
                         destructiveIndex:(NSUInteger)destructiveIndex
{
    if (!view || !delegate || !title || !buttonTextArray)
        return nil;
    
    NVAlertView *alert = [[NVAlertView alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat longestSide = MAX(bounds.size.height, bounds.size.width);
    
    alert.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, longestSide, longestSide)];
    alert.overlayView.backgroundColor = UIColor.blackColor;
    alert.overlayView.alpha = 0.0;
    alert.delegate = delegate;
    alert.buttonBorderColor = UIColor.lightGrayColor;
    
    [view addSubview:alert.overlayView];
    
    CGFloat width = 340.0, yPosition = 10.0;
    
    UIFont *font = [UIFont boldSystemFontOfSize:28.0];
    
    CGFloat height = [alert getHeightForText:title
                                        font:font
                                       width:width];
    
    alert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPosition, (width - 20.0), height)];
    alert.titleLabel.text = title;
    alert.titleLabel.font = font;
    alert.titleLabel.numberOfLines = 0;
    alert.titleLabel.adjustsFontSizeToFitWidth = YES;
    alert.titleLabel.backgroundColor = UIColor.clearColor;
    alert.titleLabel.textColor = UIColor.blackColor;
    alert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    yPosition += (height + 10.0);
    
    for (int i = 0; i < buttonTextArray.count; i++)
    {
        NSString *title = buttonTextArray[i];
        
        CGFloat height = [alert getHeightForText:title
                                            font:font
                                           width:width];
        
        height += 10.0;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(-1.0 , yPosition, (width + 2.0), height)];
        
        button.tag = (i + 1);
        button.backgroundColor = UIColor.clearColor;
        button.titleLabel.font = font;
        button.layer.borderColor = alert.buttonBorderColor.CGColor;
        button.layer.borderWidth = 1.0;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [button setTitle:title
                forState:UIControlStateNormal];
        
        if (destructiveIndex == (i + 1))
        {
            [button setTitleColor:UIColor.redColor
                         forState:UIControlStateNormal];
        }
        
        else
        {
            [button setTitleColor:UserDefaults.defaults.appleBlue
                         forState:UIControlStateNormal];
        }
        
        [button setTitleColor:UIColor.lightGrayColor
                     forState:UIControlStateHighlighted];
        
        [button addTarget:alert
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [alert addSubview:button];
        
        yPosition += (height - 1.0);
    }
    
    alert.frame = CGRectMake(0.0, 0.0, width, yPosition);
    alert.center = CGPointMake((bounds.size.width / 2.0), (bounds.size.height / 2.0));
    alert.backgroundColor = UIColor.whiteColor;
    alert.alpha = 0.0;
    alert.layer.cornerRadius = 10.0;
    alert.clipsToBounds = YES;
    
    [view addSubview:alert];
    [alert addSubview:alert.titleLabel];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         alert.overlayView.alpha = 0.7;
                         alert.alpha = 1.0;
                     }];
    
    return alert;
}

- (void)buttonTapped:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate alertView:self
         didTapButtonAtIndex:(button.tag - 1)];
    }
}

- (void)hideLargeAlertView:(BOOL)animated
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                         _overlayView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [_overlayView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

- (CGFloat)getHeightForText:(NSString *)text
                       font:(UIFont *)font
                      width:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width , 20000.0);
    CGSize titleSize;
    CGFloat totalHeight;
    
    titleSize = [text boundingRectWithSize:constraint
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil].size;
    
    totalHeight = ceil(titleSize.height);
    CGFloat height = MAX(totalHeight, 40.0);
    return height;
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.center = CGPointMake((self.superview.frame.size.height / 2.0 + _tabBar.frame.size.height / 2.0),
                                  (self.superview.frame.size.width / 2.0));
    }];
}

- (void)setButtonBorderColor:(UIColor *)buttonBorderColor
{
    for (UIButton *buttons in self.subviews)
    {
        if ([buttons isKindOfClass:UIButton.class] && buttons.tag > 0)
            buttons.layer.borderColor = buttonBorderColor.CGColor;
    }
    
    _buttonBorderColor = buttonBorderColor;
}

@end