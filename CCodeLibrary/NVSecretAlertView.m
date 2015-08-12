//  NVSecretAlertView.m
//  CCodeLibrary

#import "NVSecretAlertView.h"
#import "UserDefaults.h"

@interface NVSecretAlertView ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *OKButton;

@end

@implementation NVSecretAlertView

+ (NVSecretAlertView *)showSecretAlertViewinView:(UIView *)view
                                           title:(NSString *)title
                                     deviceNames:(NSArray *)deviceNames
{
    if (!view || !deviceNames)
        return nil;
    
    if (![deviceNames containsObject:UIDevice.currentDevice.name])
        return nil;
    
    if (!title)
        title = @"NULL";
    
    NVSecretAlertView *alert = [[NVSecretAlertView alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    alert.overlayView = [[UIView alloc] initWithFrame:bounds];
    alert.overlayView.backgroundColor = UIColor.blackColor;
    alert.overlayView.alpha = 0.0;
    
    [view addSubview:alert.overlayView];
    
    UIFont *font = [UIFont boldSystemFontOfSize:28.0];
    
    CGFloat height = [alert getHeightForText:title
                                        font:font
                                       width:340.0];
    
    alert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 320.0, height)];
    alert.titleLabel.text = title;
    alert.titleLabel.font = font;
    alert.titleLabel.numberOfLines = 0;
    alert.titleLabel.adjustsFontSizeToFitWidth = YES;
    alert.titleLabel.backgroundColor = UIColor.clearColor;
    alert.titleLabel.textColor = UIColor.blackColor;
    alert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    alert.OKButton = [[UIButton alloc] initWithFrame:CGRectMake(-1.0 , (height + 20.0), 342.0, 60.0)];
    alert.OKButton.backgroundColor = UIColor.clearColor;
    alert.OKButton.titleLabel.font = font;
    alert.OKButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
    alert.OKButton.layer.borderWidth = 1.0;
    alert.OKButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    alert.OKButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    alert.OKButton.titleLabel.numberOfLines = 0;
    alert.OKButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    alert.OKButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [alert.OKButton setTitle:@"OK"
            forState:UIControlStateNormal];
    
    [alert.OKButton setTitleColor:UserDefaults.defaults.appleBlue
                         forState:UIControlStateNormal];
    
    [alert.OKButton setTitleColor:UIColor.lightGrayColor
                         forState:UIControlStateHighlighted];
    
    [alert.OKButton addTarget:alert
                       action:@selector(buttonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [alert addSubview:alert.OKButton];
    
    alert.frame = CGRectMake(0.0, 0.0, 340.0, (height + 80.0));
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

- (void)buttonTapped:(UIButton *)button
{
    [self hideLargeAlertView:YES];
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

@end