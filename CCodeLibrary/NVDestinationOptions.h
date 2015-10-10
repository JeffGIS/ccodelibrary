//  NVDestinationOptions.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WeekDay)
{
    WeekDayNone,
    WeekDaySunday,
    WeekDayMonday,
    WeekDayTuesday,
    WeekDayWednesday,
    WeekDayThursday,
    WeekDayFriday,
    WeekDaySaturday,
};

@class NVDestinationOptions;

@protocol NVDestinationOptionsDelegate <NSObject>

- (void)destinationOptions:(NVDestinationOptions *)destinationOptions
        didReturnFrequency:(NSInteger)frequency
                timeDepart:(NSInteger)timeDepart
                timeReturn:(NSInteger)timeReturn
             destinationID:(NSInteger)destinationID;

@end

@interface NVDestinationOptions : UIView <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, weak) id <NVDestinationOptionsDelegate> delegate;

+ (NSString *)frequencyTitleForFrequency:(NSInteger)frequency;
+ (NSDate *)getDateForTime:(NSInteger)time;

+ (NVDestinationOptions *)showDestinationOptionsInView:(UIView *)view
                                              delegate:(id)delegate
                                             frequency:(NSInteger)frequency
                                            timeDepart:(NSInteger)timeDepart
                                            timeReturn:(NSInteger)timeReturn
                                         destinationID:(NSInteger)destinationID;

- (void)hideDestinationOptions:(BOOL)animated;

@end