//  NVAlertView.m
//  CCodeLibrary

#import "NVAlertView.h"
#import "UserDefaults.h"

@interface NVAlertView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITabBar *tabBar;

@end

@implementation NVAlertView

- (id)init
{
    self = [super init];
    
    if (self)
        _buttonIdentifiers = NSArray.array;
    
    return self;
}

+ (instancetype)showLargeAlertViewinView:(UIView *)view
                                delegate:(id)delegate
                                   title:(NSString *)title
                         buttonTextArray:(NSArray *)buttonTextArray
                        destructiveIndex:(NSUInteger)destructiveIndex
{
    if (!delegate || !view || !title || !buttonTextArray)
    {
        NSLog(@"NVAlertView ERROR:Cannot set delegate, view, title or buttonTextArray to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(alertView:didTapButtonAtIndex:)])
    {
        NSLog(@"NVAlertView ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    for (UIView *subviews in view.subviews)
    {
        if ([subviews isKindOfClass:NVAlertView.class])
        {
            NSLog(@"NVAlertView ERROR:Cannot present alert when one already exists in superview");
            return nil;
        }
    }
    
    NVAlertView *alert = NVAlertView.new;
    alert.overlayView = UIView.new;
    alert.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    alert.overlayView.backgroundColor = UIColor.blackColor;
    alert.overlayView.alpha = 0.0;
    alert.delegate = delegate;
    alert.buttonBorderColor = UIColor.lightGrayColor;
    alert.buttonTextArray = buttonTextArray;
    alert.tabBar = view.parentViewController.tabBarController.tabBar;
    alert.tabBar.userInteractionEnabled = NO;
    
    [view addSubview:alert.overlayView];
    [alert.overlayView constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
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
        NSString *title = textBeforePipe(buttonTextArray[i]);
        
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
        
        [button setTitle:title forState:UIControlStateNormal];
        
        if (destructiveIndex == (i + 1))
            [button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        
        else
            [button setTitleColor:UserDefaults.defaults.appleBlue forState:UIControlStateNormal];
        
        [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        
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
    [alert constrainLeadingToAnchor:view.centerXAnchor constant:(-width / 2.0)];
    [alert constrainTrailingToAnchor:view.centerXAnchor constant:(width / 2.0)];
    [alert constrainTopToAnchor:view.centerYAnchor constant:(-yPosition / 2.0)];
    [alert constrainBottomToAnchor:view.centerYAnchor constant:(yPosition / 2.0)];
    
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
    NSInteger buttonIndex = (button.tag - 1);
    
    if ([_buttonTextArray[buttonIndex] containsString:@"|"])
        buttonIndex = textAfterPipe(_buttonTextArray[buttonIndex]).integerValue;
    
    [_delegate alertView:self didTapButtonAtIndex:buttonIndex];
}

- (void)hideLargeAlertView:(BOOL)animated
{
    if (animated)
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
    
    else
    {
        [_overlayView removeFromSuperview];
        [self removeFromSuperview];
        _tabBar.userInteractionEnabled = YES;
        _tabBar.alpha = 1.0;
    }
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

- (void)showTabBar
{
    _tabBar.userInteractionEnabled = YES;
    _tabBar.alpha = 1.0;
}

@end
