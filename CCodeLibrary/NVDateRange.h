//  NVDateRange.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DateRangeType)
{
    DateRangeTypePastWeek,
    DateRangeTypeToday,
    DateRangeTypeYesterday,
    DateRangeTypeThisWeek,
    DateRangeTypeLastWeek,
    DateRangeTypeThisMonth,
    DateRangeTypeLastMonth,
    DateRangeTypeThisYear,
    DateRangeTypeLastYear,
    DateRangeTypePastYear,
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
@property (nonatomic) NSInteger minDate;

+ (void)getCurrentFromDate:(NSInteger *)fromDate
                    toDate:(NSInteger *)toDate;

+ (NVDateRange *)showDateRangeInView:(UIView *)view
                            delegate:(id)delegate
                            fromDate:(NSInteger)fromDate
                              toDate:(NSInteger)toDate;

- (void)hideDateRange:(BOOL)animated;

@end
