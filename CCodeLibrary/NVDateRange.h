//  NVDateRange.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#define SECONDS_PER_DAY 86400
#define SECONDS_PER_HOUR 3600

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
    DateRangeTypeManual,
};

typedef NS_ENUM(NSInteger, DateRangeInverval)
{
    DateRangeInvervalNone,
    DateRangeInvervalDay,
    DateRangeInvervalWeek,
    DateRangeInvervalMonth,
    DateRangeInvervalYear,
};

typedef NS_ENUM(NSInteger, TimeArraySpan)
{
    TimeArraySpanNone,
    TimeArraySpanNextDay,
    TimeArraySpanNextWorkWeekDay,
    TimeArraySpanNextWorkWeek,
    TimeArraySpanNextWeek,
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

/*
 * startTime & endTime are 24 hour format (hhmm)
 * endTime must be greater than startTime at least by interval
 * interval is in minutes
 */
+ (NSArray<NSNumber *> *)getArrayOfTimesWithStartTime:(int)startTime
                                              endTime:(int)endTime
                                                 span:(TimeArraySpan)span
                                             interval:(int)interval;

+ (NSArray<NSNumber *> *)getArrayOfMonthsSpanningTime:(NSInteger)time;

+ (void)getCurrentFromDate:(NSInteger *)fromDate
                    toDate:(NSInteger *)toDate;

+ (NVDateRange *)showDateRangeInView:(UIView *)view
                            delegate:(id)delegate
                            fromDate:(NSInteger)fromDate
                              toDate:(NSInteger)toDate;

- (void)hideDateRange:(BOOL)animated;
- (NSDate *)startOfDayDateForDate:(NSDate *)date;

@end
