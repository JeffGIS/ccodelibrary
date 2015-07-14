//  SharedDefaults.m
//  CCodeLibrary

#import "SharedDefaults.h"
#import "MathUtil.h"

@implementation SharedDefaults

static SharedDefaults *_defaults;

+ (SharedDefaults *)defaults
{
    if (!_defaults)
        _defaults = [[SharedDefaults alloc] init];
    
    return _defaults;
}

- (id)init
{
    if ((self = [super init]))
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.GSSi.SurveyApps"];
    
    return self;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    NSArray *defaultArray = [_defaults arrayForKey:key];
    return defaultArray;
}

- (UIColor *)colorForKey:(NSString *)key
{
    CGFloat red = [_defaults floatForKey:[NSString stringWithFormat:@"%@Red", key]];
    CGFloat green = [_defaults floatForKey:[NSString stringWithFormat:@"%@Green", key]];
    CGFloat blue = [_defaults floatForKey:[NSString stringWithFormat:@"%@Blue", key]];
    
    UIColor *defaultColor = [UIColor colorWithRed:(red / 255.0)
                                            green:(green / 255.0)
                                             blue:(blue / 255.0)
                                            alpha:1.0];
    
    return defaultColor;
}

- (NSInteger)integerForKey:(NSString *)key
{
    NSInteger defaultInteger = [_defaults integerForKey:key];
    return defaultInteger;
}

- (BOOL)boolForKey:(NSString *)key
{
    BOOL defaultBoolean = [_defaults boolForKey:key];
    return defaultBoolean;
}

- (NSString *)stringForKey:(NSString *)key
{
    NSString *defaultString = [_defaults stringForKey:key];
    return defaultString;
}

- (CGFloat)CGFloatForKey:(NSString *)key
{
    CGFloat defaultFloat = [_defaults floatForKey:key];
    return defaultFloat;
}

- (NSData *)NSDataForKey:(NSString *)key
{
    NSData *data = [_defaults objectForKey:key];
    return data;
}

- (NSDate *)dateForKey:(NSString *)key
{
    NSDate *defaultDate = [_defaults objectForKey:key];
    return defaultDate;
}

- (NSArray *)calibrationValueArray
{
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    
    if (defaultArray.count < 4)
    {
        NSArray *valuesArray = @[@(0.0), @(8.3)];
        
        NSArray *typesArray = @[@(NVCalibrationTypeRunningSlope),
                                @(NVCalibrationTypeRunningSlope)];
        
        NSArray *selectedArray = @[@YES, @YES];
        
        // device values always in degrees. value[0] is front/back flat slope average, value[1] is side slope flat average,
        // value[2] is front slope for calibration slope 1, value[3] is back slope for calibration slope 1,
        // value[4] is left side slope for calibration slope 1, value[5] is right side slope for calibration slope 1,
        // value[6] is front slope for calibration slope 2, value[7] is back slope for calibration slope 2,
        // value[8] is left side slope for calibration slope 2, value[9] is right side slope for calibration slope 2,
        // etc
        
        NSArray *deviceValuesArray = @[@(0.0), @(4.745)];
        
        defaultArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, deviceValuesArray, nil];
        
        [self saveCalibrationValueArray:defaultArray];
    }
    
    return defaultArray;
}

- (CLLocationCoordinate2D)coordinateForKey:(NSString *)key
{
    CGFloat latitude = [_defaults floatForKey:[NSString stringWithFormat:@"%@Latitide", key]];
    CGFloat longitude = [_defaults floatForKey:[NSString stringWithFormat:@"%@Longitude", key]];
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

- (void)saveArray:(NSArray *)array
           forKey:(NSString *)key
{
    [_defaults setObject:array
                  forKey:key];
    
    [_defaults synchronize];
}

- (void)saveColorWithRed:(CGFloat)red
                   green:(CGFloat)green
                    blue:(CGFloat)blue
                  forKey:(NSString *)key
{
    [_defaults setFloat:red
                 forKey:[NSString stringWithFormat:@"%@Red", key]];
    
    [_defaults setFloat:green
                 forKey:[NSString stringWithFormat:@"%@Green", key]];
    
    [_defaults setFloat:blue
                 forKey:[NSString stringWithFormat:@"%@Blue", key]];
    
    [_defaults synchronize];
}

- (void)saveColor:(UIColor *)color
           forKey:(NSString *)key
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    [_defaults setFloat:(red * 255.0)
                 forKey:[NSString stringWithFormat:@"%@Red", key]];
    
    [_defaults setFloat:(green * 255.0)
                 forKey:[NSString stringWithFormat:@"%@Green", key]];
    
    [_defaults setFloat:(blue * 255.0)
                 forKey:[NSString stringWithFormat:@"%@Blue", key]];
    
    [_defaults synchronize];
}

- (void)saveInteger:(int)integer
             forKey:(NSString *)key
{
    [_defaults setInteger:integer
                   forKey:key];
    
    [_defaults synchronize];
}

- (void)saveNSInteger:(NSInteger)integer
               forKey:(NSString *)key
{
    [_defaults setInteger:integer
                   forKey:key];
    
    [_defaults synchronize];
}

- (void)saveBool:(BOOL)boolean
          forKey:(NSString *)key
{
    [_defaults setBool:boolean
                forKey:key];
    
    [_defaults synchronize];
}

- (void)saveString:(NSString *)string
            forKey:(NSString *)key
{
    [_defaults setObject:string
                  forKey:key];
    
    [_defaults synchronize];
}

- (void)saveCGFloat:(CGFloat)CGFloat
             forKey:(NSString *)key
{
    [_defaults setFloat:CGFloat
                 forKey:key];
    
    [_defaults synchronize];
}

- (void)saveNSData:(NSData *)data
            forKey:(NSString *)key
{
    [_defaults setObject:data
                  forKey:key];
    
    [_defaults synchronize];
}

- (void)saveDate:(NSDate *)date
          forKey:(NSString *)key
{
    [_defaults setObject:date
                  forKey:key];
    
    [_defaults synchronize];
}

- (void)saveCoordinate:(CLLocationCoordinate2D)coordinate
                forKey:(NSString *)key
{
    [_defaults setFloat:coordinate.latitude
                 forKey:[NSString stringWithFormat:@"%@Latitide", key]];
    
    [_defaults setFloat:coordinate.longitude
                 forKey:[NSString stringWithFormat:@"%@Longitude", key]];
    
    [_defaults synchronize];
}

- (void)saveCalibrationValueArray:(NSArray *)array
{
    [_defaults setObject:array
                  forKey:@"CalibrationValueArray"];
    
    [_defaults synchronize];
}

- (void)setCalibrationValueSelected:(BOOL)selected
                            atIndex:(NSUInteger)index
{
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    
    if (defaultArray.count)
    {
        NSMutableArray *selectedArray = [defaultArray[NVCalibrationArrayIndexSelected] mutableCopy];
        
        [selectedArray replaceObjectAtIndex:index
                                 withObject:@(selected)];
        
        NSArray *valuesArray = defaultArray[NVCalibrationArrayIndexValue];
        NSArray *typesArray = defaultArray[NVCalibrationArrayIndexType];
        NSArray *deviceValuesArray = defaultArray[NVCalibrationArrayDeviceValues];
        
        defaultArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, deviceValuesArray, nil];
        
        [_defaults setObject:defaultArray
                      forKey:@"CalibrationValueArray"];
        
        [_defaults synchronize];
    }
}

- (void)addCalibrationValue:(CGFloat)value
                     ofType:(NVCalibrationType)type
{
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    
    if (defaultArray.count)
    {
        NSMutableArray *valuesArray = [defaultArray[NVCalibrationArrayIndexValue] mutableCopy];
        NSMutableArray *typesArray = [defaultArray[NVCalibrationArrayIndexType] mutableCopy];
        NSMutableArray *selectedArray = [defaultArray[NVCalibrationArrayIndexSelected] mutableCopy];
        NSArray *deviceValuesArray = defaultArray[NVCalibrationArrayDeviceValues];
        
        [valuesArray addObject:@(value)];
        [typesArray addObject:@(type)];
        [selectedArray addObject:@YES];
        
        defaultArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, deviceValuesArray, nil];
        
        [_defaults setObject:defaultArray
                      forKey:@"CalibrationValueArray"];
        
        [_defaults synchronize];
    }
}

- (void)deleteCalibrationValueAtIndex:(NSUInteger)index
{
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    
    if (defaultArray.count)
    {
        NSMutableArray *valuesArray = [defaultArray[NVCalibrationArrayIndexValue] mutableCopy];
        NSMutableArray *typesArray = [defaultArray[NVCalibrationArrayIndexType] mutableCopy];
        NSMutableArray *selectedArray = [defaultArray[NVCalibrationArrayIndexSelected] mutableCopy];
        NSArray *deviceValuesArray = defaultArray[NVCalibrationArrayDeviceValues];
        
        [valuesArray removeObjectAtIndex:index];
        [typesArray removeObjectAtIndex:index];
        [selectedArray removeObjectAtIndex:index];
        
        defaultArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, deviceValuesArray, nil];
        
        [_defaults setObject:defaultArray
                      forKey:@"CalibrationValueArray"];
        
        [_defaults synchronize];
    }
}

- (NSUInteger)calibrationValueSelectedCount
{
    NSUInteger count = 0;
    
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    NSArray *selectedArray = defaultArray[NVCalibrationArrayIndexSelected];
    
    for (int i = 0; i < selectedArray.count; i++)
    {
        BOOL selected = [selectedArray[i] boolValue];
        
        if (selected)
            count++;
    }
    
    return count;
}

- (CGFloat)calibrationValueMinRange
{
    CGFloat range = 100.0;
    
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    NSArray *valuesArray = defaultArray[NVCalibrationArrayIndexValue];
    NSArray *typesArray = defaultArray[NVCalibrationArrayIndexType];
    
    if (valuesArray.count > 1)
    {
        for (int i = 0; i < valuesArray.count; i++)
        {
            for (int j = 0; j < valuesArray.count; j++)
            {
                if (i < j)
                {
                    CGFloat iVal = [valuesArray[i] floatValue];
                    CGFloat jVal = [valuesArray[j] floatValue];
                    
                    if ([typesArray[i] integerValue] == NVCalibrationTypeRunningSlope)
                        iVal = (atan(iVal / 100) * RADtoDEG);
                    
                    if ([typesArray[j] integerValue] == NVCalibrationTypeRunningSlope)
                        jVal = (atan(jVal / 100) * RADtoDEG);
                    
                    CGFloat diff = (jVal - iVal);
                    range = min(range, diff);
                }
            }
        }
    }
    
    return range;
}

@end