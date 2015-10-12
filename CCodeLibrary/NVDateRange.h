//  NVDateRange.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVDateRange;

@protocol NVDateRangeDelegate <NSObject>

- (void)dateRange:(NVDateRange *)dateRange
didReturnFromDate:(NSInteger)fromDate
           toDate:(NSInteger)toDate;

@end

@interface NVDateRange : UIView

@property (nonatomic, weak) id <NVDateRangeDelegate> delegate;

+ (NVDateRange *)showDateRangeInView:(UIView *)view
                            delegate:(id)delegate
                            fromDate:(NSInteger)fromDate
                              toDate:(NSInteger)toDate;

- (void)hideDateRange:(BOOL)animated;

@end