//  NVCalendarCell.h
//  CCodeLibrary

@import UIKit;

@interface NVCalendarCell : UILabel

- (id)initWithText:(NSString *)text
               tag:(NSUInteger)tag
           numDays:(NSInteger)numDays;

@end