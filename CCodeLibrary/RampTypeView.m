//  RampTypeView.m
//  CCodeLibrary

#import "RampTypeView.h"

@implementation RampTypeView

+ (RampTypeView *)showRampTypeViewWithView:(UIView *)view
                                  delegate:(id)delegate
{
    RampTypeView *rampTypeView = [[RampTypeView alloc] initWithFrame:view.frame];
    rampTypeView.delegate = delegate;
    
    CGFloat margin = 90.0;
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin,
                                                                  (rampTypeView.frame.size.width - (margin * 2.0)),
                                                                  (rampTypeView.frame.size.height - (margin * 2.0)))];
    
    //CGSize buttonSize = CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
    
    return rampTypeView;
}

@end