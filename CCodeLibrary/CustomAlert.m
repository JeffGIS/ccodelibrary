//  CustomAlert.m
//  CCodeLibrary

#import "CustomAlert.h"

@implementation CustomAlert

@synthesize delegate;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)AlertDelegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle
{
    CGRect frame;
    
    if (UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
        UIApplication.sharedApplication.statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);
    }
    
    else
    {
        frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.backgroundColor = [UIColor colorWithRed:0.0
                                               green:0.0
                                                blue:0.0
                                               alpha:0.75];
        
        UIFont *font = [UIFont boldSystemFontOfSize:40.0];
        UIColor *white = UIColor.whiteColor;
        UIColor *clear = UIColor.clearColor;
        UIColor *black = UIColor.blackColor;
        
        CGFloat alertHeight = 10.0;
        CGFloat alertHeightDispl = 48.0;
        CGSize shadowHeight = CGSizeMake(3.0, 3.0);

        UIImage *alertImage = [UIImage imageNamed:@"alertImage.png"];
        UIImage *buttonImage = [UIImage imageNamed:@"buttonImage.png"];
        
        UIImageView *alertImageView = [[UIImageView alloc] initWithImage:alertImage];
        alertImageView.layer.shadowColor = black.CGColor;
        alertImageView.layer.shadowOffset = shadowHeight;
        alertImageView.layer.shadowOpacity = 1.0;
        
        CGFloat alertWidth = alertImageView.frame.size.width;
        
        UILabel *titleLabel;
        UIScrollView *messageScrollView;
        UILabel *messageLabel;
        UIButton *cancelButton;
        UIButton *otherButton;
        
        if (title)
        {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, alertHeight, alertWidth, 50.0)];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.font = font;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.backgroundColor = clear;
            titleLabel.textColor = white;
            titleLabel.text = title;
            titleLabel.layer.shadowColor = black.CGColor;
            titleLabel.layer.shadowOffset = shadowHeight;
            titleLabel.layer.shadowOpacity = 1.0;
            
            alertHeight += (titleLabel.frame.size.height + alertHeightDispl);
        }
        else
        {
            alertHeight += alertHeightDispl;
        }
        
        if (message)
        {
            messageLabel = [[UILabel alloc] init];
            messageLabel.numberOfLines = 0;
            messageLabel.font = font;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            messageLabel.backgroundColor = clear;
            messageLabel.textColor = white;
            messageLabel.text = message;
            messageLabel.layer.shadowColor = black.CGColor;
            messageLabel.layer.shadowOffset = shadowHeight;
            messageLabel.layer.shadowOpacity = 1.0;
            
            [messageLabel sizeToFit];
            
            messageLabel.frame = CGRectMake(0.0, 0.0, alertWidth, messageLabel.frame.size.height);
            
            messageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, alertHeight, alertWidth,
                                                                               messageLabel.frame.size.height)];
            messageScrollView.contentSize = messageLabel.frame.size;
            
            [messageScrollView addSubview:messageLabel];
            
            alertHeight += (messageScrollView.frame.size.height + alertHeightDispl);
        }
        
        else
        {
            alertHeight += alertHeightDispl;
        }
        
        if (cancelButtonTitle && otherButtonTitle)
        {
            CGFloat xDispl = (int)((alertWidth - (buttonImage.size.width * 2.0)) / 3.0);
            
            cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(xDispl, alertHeight,
                                                                      buttonImage.size.width,
                                                                      buttonImage.size.height)];
            cancelButton.tag = 1000;
            
            [cancelButton setTitle:cancelButtonTitle
                          forState:UIControlStateNormal];
            
            cancelButton.titleLabel.font = font;
            cancelButton.layer.shadowColor = black.CGColor;
            cancelButton.layer.shadowOffset = shadowHeight;
            cancelButton.layer.shadowOpacity = 1.0;
            cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            cancelButton.titleLabel.shadowColor = black;
            cancelButton.titleLabel.shadowOffset = shadowHeight;
            
            [cancelButton setBackgroundImage:buttonImage
                                 forState:UIControlStateNormal];
            
            [cancelButton addTarget:self
                             action:@selector(onBtnPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
            
            otherButton = [[UIButton alloc] initWithFrame:CGRectMake(((xDispl * 2.0) + buttonImage.size.width), alertHeight,
                                                                     buttonImage.size.width, buttonImage.size.height)];
            otherButton.tag = 1001;
            
            [otherButton setTitle:otherButtonTitle
                         forState:UIControlStateNormal];
            
            otherButton.titleLabel.font = font;
            otherButton.layer.shadowColor = black.CGColor;
            otherButton.layer.shadowOffset = shadowHeight;
            otherButton.layer.shadowOpacity = 1.0;
            otherButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            otherButton.titleLabel.shadowColor = black;
            otherButton.titleLabel.shadowOffset = shadowHeight;
            
            [otherButton setBackgroundImage:buttonImage
                                forState:UIControlStateNormal];
            
            [otherButton addTarget:self
                            action:@selector(onBtnPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            alertHeight += (cancelButton.frame.size.height + alertHeightDispl);
        }
        
        else if (cancelButtonTitle)
        {
            cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((alertWidth - buttonImage.size.width) / 2.0), alertHeight,
                                                                      buttonImage.size.width, buttonImage.size.height)];
            cancelButton.tag = 1000;
            
            [cancelButton setTitle:cancelButtonTitle
                          forState:UIControlStateNormal];
            
            cancelButton.titleLabel.font = font;
            cancelButton.layer.shadowColor = black.CGColor;
            cancelButton.layer.shadowOffset = shadowHeight;
            cancelButton.layer.shadowOpacity = 1.0;
            cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            cancelButton.titleLabel.shadowColor = black;
            cancelButton.titleLabel.shadowOffset = shadowHeight;


            [cancelButton setBackgroundImage:buttonImage
                                 forState:UIControlStateNormal];
            
            [cancelButton addTarget:self
                             action:@selector(onBtnPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
            
            (alertHeight += cancelButton.frame.size.height + alertHeightDispl);
        }
        
        else if (otherButtonTitle)
        {
            otherButton = [[UIButton alloc] initWithFrame:CGRectMake((int)((alertWidth-buttonImage.size.width) / 2.0), alertHeight,
                                                                     buttonImage.size.width, buttonImage.size.height)];
            
            otherButton.tag = 1001;
            
            [otherButton setTitle:otherButtonTitle
                         forState:UIControlStateNormal];
            
            otherButton.titleLabel.font = font;
            otherButton.layer.shadowColor = black.CGColor;
            otherButton.layer.shadowOffset = shadowHeight;
            otherButton.layer.shadowOpacity = 1.0;
            otherButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            otherButton.titleLabel.shadowColor = black;
            otherButton.titleLabel.shadowOffset = shadowHeight;
            
            [otherButton setBackgroundImage:buttonImage
                                forState:UIControlStateNormal];
            
            [otherButton addTarget:self
                            action:@selector(onBtnPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            alertHeight += (otherButton.frame.size.height + alertHeightDispl);
        }
        
        else
        {
            alertHeight += alertHeightDispl;
        }
        
        alertView = [[UIView alloc] initWithFrame:CGRectMake((int)((self.frame.size.width - alertWidth) / 2.0),
                                                             (int)((self.frame.size.height - alertHeight) / 2.0), alertWidth, alertHeight)];
        
        alertView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        alertImageView.frame = alertView.bounds;
        
        [alertView addSubview:alertImageView];
        
        [self addSubview:alertView];
        
        if (titleLabel)
            [alertView addSubview:titleLabel];
        
        if (messageScrollView)
            [alertView addSubview:messageScrollView];
        
        if (cancelButton)
            [alertView addSubview:cancelButton];
        
        if (otherButton)
            [alertView addSubview:otherButton];
    }
    
    return self;
}

- (void)onBtnPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    long buttonIndex = (button.tag - 1000);
    
    if ([delegate respondsToSelector:@selector(customAlertView:clickedButtonAtIndex:)])
    {
            [delegate customAlertView:self
                 clickedButtonAtIndex:buttonIndex];
    }
    
    [self animateHide];
}

- (void)animateShow
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1.0);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1.0);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1.0);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1.0);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.3;
    
    [alertView.layer addAnimation:animation
                           forKey:@"show"];
}

- (void)animateHide
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1.0);
    CATransform3D scale2 = CATransform3DMakeScale(0.5, 0.5, 1.0);
    CATransform3D scale3 = CATransform3DMakeScale(0.0, 0.0, 1.0);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            nil];
    
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           nil];
    
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.3;
    
    [alertView.layer addAnimation:animation
                           forKey:@"hide"];
    
    [self performSelector:@selector(removeFromSuperview)
               withObject:self
               afterDelay:0.305];
}

- (void)showInView:(UIView *)view
{
    if ([view isKindOfClass:UIView.class])
    {
        [view addSubview:self];
        [self animateShow];
    }
}

@end