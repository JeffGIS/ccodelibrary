//  NVRampButton.m
//  CCodeLibrary

#import "NVRampButton.h"

@interface NVRampButton ()

@property (nonatomic) UILabel *rampTypeLabel;

@end

@implementation NVRampButton

+ (NVRampButton *)addToView:(UIView *)view
                        tag:(NSInteger)tag
                      title:(NSString *)title
{
    NVRampButton *rampButton = [[NVRampButton alloc] init];
    rampButton.tag = tag;
    
    [rampButton setTitle:title
                forState:UIControlStateNormal];
    
    CGFloat buttonSize = 80.0;
    CGFloat cornerRadius = (buttonSize / 2.0);
    
    if (tag < 9)
    {
        rampButton.frame = CGRectMake(0.0, 0.0, buttonSize, buttonSize);
        rampButton.layer.cornerRadius = cornerRadius;
    }
    
    else
    {
        rampButton.frame = CGRectMake(0.0, 0.0, (buttonSize * 1.5), buttonSize);
        rampButton.layer.cornerRadius = (cornerRadius * 1.5);
    }
    
    rampButton.backgroundColor = UIColor.redColor;
    rampButton.titleLabel.font = [UIFont boldSystemFontOfSize:54];
    rampButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    rampButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    rampButton.layer.borderWidth = 4.0;
    rampButton.layer.borderColor = UIColor.blackColor.CGColor;
    rampButton.showsTouchWhenHighlighted = NO;
    rampButton.hidden = YES;
    
    [rampButton setTitleColor:UIColor.whiteColor
                     forState:UIControlStateNormal];
    
    [view addSubview:rampButton];
    
    rampButton.rampTypeLabel = [[UILabel alloc] initWithFrame:
                                CGRectMake((rampButton.frame.size.width - 20.0),
                                           ((rampButton.frame.size.height / 2.0) - 6.0),
                                           12.0, 12.0)];
    
    rampButton.rampTypeLabel.textColor = UIColor.whiteColor;
    rampButton.rampTypeLabel.font = [UIFont systemFontOfSize:16.0];
    rampButton.rampTypeLabel.adjustsFontSizeToFitWidth = YES;
    [rampButton addSubview:rampButton.rampTypeLabel];
    
    return rampButton;
}

- (void)setType:(RampType)type
{
    _type = type;
    _rampTypeLabel.text = [NSString stringWithFormat:@"%li", ((long)type + 1)];
}

@end