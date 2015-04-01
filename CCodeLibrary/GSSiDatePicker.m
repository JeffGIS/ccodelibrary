//  GSSiDatePicker.m
//  CCodeLibrary

#import "GSSiDatePicker.h"

@interface GSSiDatePicker ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation GSSiDatePicker

+ (GSSiDatePicker *)showDatePickerWithView:(UIView *)view
{
    GSSiDatePicker *datePicker = [[GSSiDatePicker alloc] init];
    
    datePicker.center = CGPointMake((view.frame.size.width / 2.0),
                                    (view.frame.size.height / 2.0));
    
    datePicker.backgroundColor = UIColor.whiteColor;
    datePicker.clipsToBounds = YES;
    datePicker.layer.cornerRadius = 10.0;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.alpha = 0.0;
    
    datePicker.dateFormatter = [[NSDateFormatter alloc] init];
    [datePicker.dateFormatter setDateFormat:@"MM-dd-yyyy"];
    datePicker.dateString = [datePicker.dateFormatter stringFromDate:datePicker.date];
    
    [datePicker addTarget:datePicker
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    datePicker.overlayView = [[UIView alloc] initWithFrame:view.frame];
    datePicker.overlayView.backgroundColor = UIColor.blackColor;
    datePicker.overlayView.alpha = 0.0;
    [view addSubview:datePicker.overlayView];
    [view addSubview:datePicker];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         datePicker.overlayView.alpha = 0.6;
                         datePicker.alpha = 1.0;
                     }];
    
    return datePicker;
}

- (void)hideDatePicker
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         _overlayView.alpha = 0.0;
                         self.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [_overlayView removeFromSuperview];
                     }];
}

- (void)bringToFrontOfView:(UIView *)view
{
    [view bringSubviewToFront:_overlayView];
    [view bringSubviewToFront:self];
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight
{
    CGRect superviewFrame = self.superview.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _overlayView.frame = CGRectMake(superviewFrame.origin.y, superviewFrame.origin.x,
                                                         (superviewFrame.size.height + tabBarHeight),
                                                         (superviewFrame.size.width - tabBarHeight));
                         
                         self.center = CGPointMake(((superviewFrame.size.height + tabBarHeight) / 2.0),
                                                   ((superviewFrame.size.width - tabBarHeight) / 2.0));
                     }];
}

- (void)datePickerValueChanged:(GSSiDatePicker *)datePicker
{
    _dateString = [_dateFormatter stringFromDate:datePicker.date];
}

@end