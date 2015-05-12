//  NVLargeAlertView.m
//  CCodeLibrary

#import "NVLargeAlertView.h"
#import "UserDefaults.h"

@interface NVLargeAlertView ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *topButton, *bottomButton;
@property (nonatomic) UIFont *font;

@end

@implementation NVLargeAlertView

+ (NVLargeAlertView *)showLargeAlertViewinView:(UIView *)view
                                      delegate:(id)delegate
                                         title:(NSString *)title
                                 topButtonText:(NSString *)topButtontext
                              bottomButtonText:(NSString *)bottomButtonText
                              destructiveIndex:(NVLargeAlertIndex)destructiveIndex;
{
    NVLargeAlertView *largeAlert = [[NVLargeAlertView alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    largeAlert.overlayView = [[UIView alloc] initWithFrame:bounds];
    largeAlert.overlayView.backgroundColor = UIColor.blackColor;
    largeAlert.overlayView.alpha = 0.0;
    largeAlert.delegate = delegate;
    
    [view addSubview:largeAlert.overlayView];
    
    CGFloat titleWidth = 340.0;
    largeAlert.font = [UIFont boldSystemFontOfSize:28.0];
    
    CGFloat titleHeight = [largeAlert getHeightForText:title
                                                  font:largeAlert.font
                                                 width:titleWidth];
    
    largeAlert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, titleWidth, titleHeight)];
    largeAlert.titleLabel.text = title;
    largeAlert.titleLabel.font = largeAlert.font;
    largeAlert.titleLabel.numberOfLines = 0;
    largeAlert.titleLabel.adjustsFontSizeToFitWidth = YES;
    largeAlert.titleLabel.backgroundColor = UIColor.clearColor;
    largeAlert.titleLabel.textColor = UIColor.blackColor;
    largeAlert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat alertHeight = (titleHeight + 160.0);
    CGFloat alertWidth = (titleWidth + 40.0);
    
    if (bottomButtonText)
        largeAlert.frame = CGRectMake(0.0, 0.0, alertWidth, alertHeight);
    
    else
        largeAlert.frame = CGRectMake(0.0, 0.0, alertWidth, (alertHeight - 60.0));
    
    largeAlert.center = CGPointMake((bounds.size.width / 2.0), (bounds.size.height / 2.0));
    largeAlert.backgroundColor = UIColor.whiteColor;
    largeAlert.alpha = 0.0;
    largeAlert.layer.cornerRadius = 10.0;
    largeAlert.clipsToBounds = YES;
    
    [view addSubview:largeAlert];
    [largeAlert addSubview:largeAlert.titleLabel];
    
    largeAlert.topButton = [[UIButton alloc] initWithFrame:CGRectMake(-1.0, (alertHeight - 120.0), (alertWidth + 2.0), 60.0)];
    
    [largeAlert setupButton:largeAlert.topButton
                     target:largeAlert
                   selector:@selector(topButtonTapped:)
                      title:topButtontext
                       font:largeAlert.font];
    
    switch (destructiveIndex)
    {
        case NVLargeAlertIndexNone:
            break;
            
        case NVLargeAlertIndexTopButton:
            [largeAlert.topButton setTitleColor:UIColor.redColor
                                       forState:UIControlStateNormal];
            break;
            
        case NVLargeAlertIndexBottomButton:
            if (bottomButtonText)
            {
                [largeAlert.bottomButton setTitleColor:UIColor.redColor
                                              forState:UIControlStateNormal];
            }
            
            break;
    }
    
    [largeAlert addSubview:largeAlert.topButton];
    
    if (bottomButtonText)
    {
        largeAlert.bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(-1.0, (alertHeight - 61.0), (alertWidth + 2.0), 62.0)];
        
        [largeAlert setupButton:largeAlert.bottomButton
                         target:largeAlert
                       selector:@selector(bottomButtonTapped:)
                          title:bottomButtonText
                           font:largeAlert.font];
        
        [largeAlert addSubview:largeAlert.bottomButton];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         largeAlert.overlayView.alpha = 0.7;
                         largeAlert.alpha = 1.0;
                     }];
    
    return largeAlert;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
               font:(UIFont *)font
{
    button.backgroundColor = UIColor.clearColor;
    button.titleLabel.font = font;
    button.layer.borderColor = UIColor.lightGrayColor.CGColor;
    button.layer.borderWidth = 1.0;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)topButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate largeAlertView:self
              didTapButtonAtIndex:NVLargeAlertIndexTopButton];
    }
}

- (void)bottomButtonTapped:(UIButton *)button
{
    if (_delegate)
    {
        [_delegate largeAlertView:self
              didTapButtonAtIndex:NVLargeAlertIndexBottomButton];
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

@end