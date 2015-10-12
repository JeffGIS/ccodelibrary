//  NVDateRange.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DateRangeButton)
{
    DateRangeButtonNone,
    DateRangeButtonToday,
    DateRangeButtonYesterday,
    DateRangeButtonThisWeek,
    DateRangeButtonLastWeek,
    DateRangeButtonPastWeek,
    DateRangeButtonThisMonth,
    DateRangeButtonLastMonth,
    DateRangeButtonThisYear,
    DateRangeButtonLastYear,
    DateRangeButtonPastYear,
};

typedef NS_ENUM(NSInteger, DateRangeInverval)
{
    DateRangeInvervalNone,
    DateRangeInvervalDay,
    DateRangeInvervalWeek,
    DateRangeInvervalMonth,
    DateRangeInvervalYear,
};

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