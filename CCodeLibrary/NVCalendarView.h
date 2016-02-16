//  NVCalendarView.h
//  CCodeLibrary

@import UIKit;

@interface NVCalendarView : UIView

- (id)initWithMonth:(NSInteger)month
               year:(NSInteger)year
           firstDay:(NSInteger)firstDay
            numDays:(NSUInteger)numDays;

@end