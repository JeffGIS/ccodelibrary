//  RampTypeView.m
//  CCodeLibrary

#import "RampTypeView.h"
#import "UserDefaults.h"

@implementation RampTypeView

+ (RampTypeView *)showRampTypeViewWithView:(UIView *)view
                                  delegate:(id)delegate
{
    RampTypeView *rtView = [[RampTypeView alloc] initWithFrame:view.frame];
    rtView.delegate = delegate;
    rtView.backgroundColor = UserDefaults.defaults.appleBlue;
    rtView.alpha = 0.0;
    [view addSubview:rtView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, 240.0, 50.0)];
    
    [rtView setupButton:returnButton
                 target:rtView
               selector:@selector(returnButtonTapped:)
                  title:@"< Return"];
    
    [rtView addSubview:returnButton];
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(42.0, 90.0, 684.0, 912.0)];
    
    [rtView addSubview:buttonView];
    
    CGSize buttonSize = CGSizeMake((buttonView.frame.size.width / 3.0), (buttonView.frame.size.height / 4.0));
   
    NSInteger tag = 0;
    
    for (int row = 0; row < 4; row++)
    {
        for (int column = 0; column < 3; column++)
        {
            UIButton *rtButton = [[UIButton alloc] initWithFrame:CGRectMake((column * buttonSize.width),
                                                                            (row * buttonSize.height),
                                                                            buttonSize.width, buttonSize.height)];
            
            tag ++;
            rtButton.tag = tag;
            
            rtButton.backgroundColor = UIColor.whiteColor;
            rtButton.layer.borderColor = UIColor.blackColor.CGColor;
            rtButton.layer.borderWidth = 4.0;
            rtButton.titleLabel.font = [UIFont boldSystemFontOfSize:80.0];
            rtButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            [rtButton setTitleColor:UIColor.blackColor
                           forState:UIControlStateNormal];
            
            [rtButton setTitleColor:UIColor.lightGrayColor
                           forState:UIControlStateHighlighted];
            
            [rtButton setTitle:[NSString stringWithFormat:@"%ld", (long)tag]
                      forState:UIControlStateNormal];
            
            [rtButton addTarget:rtView
                         action:@selector(rtButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
            
            [buttonView addSubview:rtButton];
        }
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         rtView.alpha = 1.0;
                     }];
    
    return rtView;
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [self hideRampTypeView:YES];
}

- (void)rtButtonTapped:(UIButton *)button
{
    NSLog(@"SelectedButton:%ld", (long)button.tag);
}

- (void)hideRampTypeView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
    
    else
        [self removeFromSuperview];
}

@end