//  NVAlertView.m
//  CCodeLibrary

#import "NVAlertView.h"
#import "UserDefaults.h"

@interface NVAlertView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITabBar *tabBar;

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
    
    NVAlertView *alert = NVAlertView.new;
    alert.overlayView = UIView.new;
    alert.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    alert.overlayView.backgroundColor = UIColor.blackColor;
    alert.overlayView.alpha = 0.0;
    alert.delegate = delegate;
    alert.buttonBorderColor = UIColor.lightGrayColor;
    
    [view addSubview:alert.overlayView];
    
    alert.tabBar = view.parentViewController.tabBarController.tabBar;
    alert.tabBar.userInteractionEnabled = NO;
    
    [alert.overlayView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
    [alert.overlayView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
    [alert.overlayView.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    [alert.overlayView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
    
    CGFloat width = 340.0, heightSpacer = 10.0;
    UIFont *font = [UIFont boldSystemFontOfSize:28.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        width = 240.0, heightSpacer = 6.0, font = [UIFont boldSystemFontOfSize:20.0];
    
    CGFloat yPosition = heightSpacer;
    
    CGFloat height = [alert getHeightForText:title
                                        font:font
                                       width:width];
    
    alert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(heightSpacer, yPosition,
                                                                 (width - (heightSpacer * 2.0)), height)];
    
    alert.titleLabel.text = title;
    alert.titleLabel.font = font;
    alert.titleLabel.numberOfLines = 0;
    alert.titleLabel.adjustsFontSizeToFitWidth = YES;
    alert.titleLabel.backgroundColor = UIColor.clearColor;
    alert.titleLabel.textColor = UIColor.blackColor;
    alert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [alert addSubview:alert.titleLabel];
    
    yPosition += (height + heightSpacer);
    
    for (int i = 0; i < buttonTextArray.count; i++)
    {
        NSString *title = buttonTextArray[i];
        
        CGFloat height = [alert getHeightForText:title
                                            font:font
                                           width:width];
        
        height += heightSpacer;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(-1.0 , yPosition,
                                                                      (width + 2.0), height)];
        
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
    
    alert.translatesAutoresizingMaskIntoConstraints = NO;
    alert.backgroundColor = UIColor.whiteColor;
    alert.alpha = 0.0;
    alert.layer.cornerRadius = heightSpacer;
    alert.clipsToBounds = YES;
    
    [view addSubview:alert];
    
    [alert.leadingAnchor constraintEqualToAnchor:view.centerXAnchor
                                        constant:(-width / 2.0)].active = YES;
    
    [alert.trailingAnchor constraintEqualToAnchor:view.centerXAnchor
                                        constant:(width / 2.0)].active = YES;
    
    [alert.topAnchor constraintEqualToAnchor:view.centerYAnchor
                                    constant:(-yPosition / 2.0)].active = YES;
    
    [alert.bottomAnchor constraintEqualToAnchor:view.centerYAnchor
                                       constant:(yPosition / 2.0)].active = YES;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         alert.overlayView.alpha = 0.7;
                         alert.alpha = 1.0;
                         alert.tabBar.alpha = 0.3;
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
                         _tabBar.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [_overlayView removeFromSuperview];
                         [self removeFromSuperview];
                         _tabBar.userInteractionEnabled = YES;
                     }];
}

- (CGFloat)getHeightForText:(NSString *)text
                       font:(UIFont *)font
                      width:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width , 20000.0);
    CGSize titleSize = CGSizeZero;
    CGFloat totalHeight = 0.0;
    
    titleSize = [text boundingRectWithSize:constraint
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil].size;
    
    totalHeight = ceil(titleSize.height);
    CGFloat height = MAX(totalHeight, 40.0);
    return height;
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