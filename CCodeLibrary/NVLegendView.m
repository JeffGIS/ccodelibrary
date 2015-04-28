//  NVLegendView.m
//  CCodeLibrary

#import "NVLegendView.h"
#import "UserDefaults.h"

@interface NVLegendView ()

@property (nonatomic) UILabel *titleLabel, *completedLabel, *toBeDoneLabel, *pctCompletedLabel;

@end

@implementation NVLegendView

+ (NVLegendView *)showLegendViewAtOrigin:(CGPoint)origin
                                  inView:(UIView *)view
                                   title:(NSString *)title;
{
    NVLegendView *legendView = [[NVLegendView alloc] initWithFrame:CGRectMake(origin.x, origin.y, 220.0, 120.0)];
    legendView.layer.cornerRadius = 10.0;
    legendView.layer.masksToBounds = YES;
    legendView.layer.borderColor = UIColor.blackColor.CGColor;
    legendView.layer.borderWidth = 4.0;
    legendView.userInteractionEnabled = YES;
    legendView.backgroundColor = UIColor.whiteColor;
    legendView.alpha = 0.0;
    
    [view addSubview:legendView];
    
    legendView.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, legendView.frame.size.width,
                                                                      (legendView.frame.size.height / 4.0))];
    
    [legendView setupLabel:legendView.titleLabel
                      text:title
                 alignment:NSTextAlignmentCenter
                     color:UIColor.blackColor];
    
    [legendView addSubview:legendView.titleLabel];
    
    legendView.completedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, (legendView.frame.size.height * 0.25),
                                                                          (legendView.frame.size.width - 12.0),
                                                                          (legendView.frame.size.height * 0.25))];
    
    [legendView setupLabel:legendView.completedLabel
                      text:@"Completed: 245"
                 alignment:NSTextAlignmentLeft
                     color:UserDefaults.defaults.darkGreen];
    
    [legendView addSubview:legendView.completedLabel];
    
    legendView.toBeDoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, (legendView.frame.size.height * 0.5),
                                                                         (legendView.frame.size.width - 12.0),
                                                                         (legendView.frame.size.height * 0.25))];

    [legendView setupLabel:legendView.toBeDoneLabel
                      text:@"To Be Done: 160"
                 alignment:NSTextAlignmentLeft
                     color:UIColor.redColor];
    
    [legendView addSubview:legendView.toBeDoneLabel];
    
    legendView.pctCompletedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, (legendView.frame.size.height * 0.75),
                                                                             (legendView.frame.size.width - 12.0),
                                                                             (legendView.frame.size.height * 0.25))];
    
    [legendView setupLabel:legendView.pctCompletedLabel
                      text:@"Percent Done: 60.49%"
                 alignment:NSTextAlignmentLeft
                     color:UIColor.blueColor];
    
    [legendView addSubview:legendView.pctCompletedLabel];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         legendView.alpha = 1.0;
                     }];
    
    return legendView;
}

- (void)setupLabel:(UILabel *)label
              text:(NSString *)text
         alignment:(NSTextAlignment)alignment
             color:(UIColor *)color
{
    label.text = text;
    label.textAlignment = alignment;
    label.textColor = color;
    label.backgroundColor = UIColor.clearColor;
    label.font = [UIFont boldSystemFontOfSize:18.0];
}

- (void)hideLegendView:(BOOL)animated
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