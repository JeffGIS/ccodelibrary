//  SharedDefaults.m
//  CCodeLibrary

#import "SharedDefaults.h"

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

- (NSDate *)dateForKey:(NSString *)key
{
    NSDate *defaultDate = [_defaults objectForKey:key];
    return defaultDate;
}

- (NSArray *)calibrationValueArray
{
    NSArray *defaultArray = [_defaults arrayForKey:@"CalibrationValueArray"];
    
    if (!defaultArray.count)
    {
        NSArray *valuesArray = @[@(0.0), @(100.0 / 12.0)];
        
        NSArray *typesArray = @[@(NVCalibrationTypeRunningSlope),
                                @(NVCalibrationTypeRunningSlope)];
        
        NSArray *selectedArray = @[@YES, @YES];
        
        defaultArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, nil];
    }
    
    return defaultArray;
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

- (void)saveDate:(NSDate *)date
          forKey:(NSString *)key
{
    [_defaults setObject:date
                  forKey:key];
    
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
        
        defaultArray = [NSArray arrayWithObjects:valuesArray, typesArray, selectedArray, nil];
        
        [_defaults setObject:defaultArray
                      forKey:@"CalibrationValueArray"];
        
        [_defaults synchronize];
    }
}

@end