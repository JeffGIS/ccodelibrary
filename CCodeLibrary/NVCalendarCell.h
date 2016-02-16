//  NVCalendarCell.h
//  CCodeLibrary

@import UIKit;

@interface NVCalendarCell : UILabel

@property (nonatomic) BOOL selected;

- (id)initWithText:(NSString *)text
               tag:(NSUInteger)tag
           numDays:(NSInteger)numDays;

@end