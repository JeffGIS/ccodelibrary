//  SharedDefaults.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NVCalibrationType) {
    NVCalibrationTypeDefault,
    NVCalibrationTypeRunningSlope,
    NVCalibrationTypeDegrees,
    NVCalibrationTypeRiseRun,
};

typedef NS_ENUM(NSInteger, NVCalibrationArrayIndex) {
    NVCalibrationArrayIndexValue,
    NVCalibrationArrayIndexType,
    NVCalibrationArrayIndexSelected,
    NVCalibrationArrayDeviceValues,
};

@interface SharedDefaults : NSObject
{
    NSUserDefaults *_defaults;
}

+ (SharedDefaults *)defaults;

- (UIColor *)colorForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (CGFloat)CGFloatForKey:(NSString *)key;
- (NSDate *)dateForKey:(NSString *)key;
- (NSArray *)calibrationValueArray;

- (void)saveColorWithRed:(CGFloat)red
                   green:(CGFloat)green
                    blue:(CGFloat)blue
                  forKey:(NSString *)key;

- (void)saveColor:(UIColor *)color
           forKey:(NSString *)key;

- (void)saveInteger:(int)integer
             forKey:(NSString *)key;

- (void)saveNSInteger:(NSInteger)integer
               forKey:(NSString *)key;

- (void)saveBool:(BOOL)boolean
          forKey:(NSString *)key;

- (void)saveString:(NSString *)string
            forKey:(NSString *)key;

- (void)saveCGFloat:(CGFloat)CGFloat
             forKey:(NSString *)key;

- (void)saveDate:(NSDate *)date
          forKey:(NSString *)key;

- (void)saveCalibrationValueArray:(NSArray *)array;

- (void)setCalibrationValueSelected:(BOOL)selected
                            atIndex:(NSUInteger)index;

- (void)addCalibrationValue:(CGFloat)value
                     ofType:(NVCalibrationType)type;

- (void)deleteCalibrationValueAtIndex:(NSUInteger)index;

@end