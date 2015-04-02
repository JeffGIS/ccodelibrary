//  GSSiDatePicker.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface GSSiDatePicker : UIDatePicker

@property (nonatomic) NSString *dateString;

+ (GSSiDatePicker *)showDatePickerWithView:(UIView *)view;

- (void)hideDatePicker:(BOOL)animated;
- (void)bringToFrontOfView:(UIView *)view;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight;

@end