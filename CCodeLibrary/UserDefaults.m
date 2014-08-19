//  UserDefaults.m
//  CCodeLibrary
//
//  Created by Bill Munson on 8/13/14.
//  Copyright (c) 2014 GSSi. All rights reserved.

#import "UserDefaults.h"

@implementation UserDefaults

static UserDefaults *_defaults;

+ (UserDefaults *)defaults
{
    if (_defaults == nil)
    {
        _defaults = [[UserDefaults alloc] init];
    }
    
    return _defaults;
}

- (id)init
{
    if ((self = [super init]))
    {
        _defaults = NSUserDefaults.standardUserDefaults;
    }
    
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

- (bool)boolForKey:(NSString *)key
{
    bool defaultBoolean = [_defaults boolForKey:key];
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

- (UIColor *)appleBlue
{
    UIColor *appleBlue = [UIColor colorWithRed:(0.0 / 255.0)
                                         green:(122.0 / 255.0)
                                          blue:(255.0 / 255.0)
                                         alpha:1.0];
    
    return appleBlue;
}

- (UIColor *)green
{
    UIColor *green = [UIColor colorWithRed:(160.0 / 255.0)
                                     green:(197.0 / 255.0)
                                      blue:(129.0 / 255.0)
                                     alpha:1.0];
    
    return green;
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

- (void)saveBool:(bool)boolean
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

- (void)saveLocationWithBounds_w:(CGFloat)bounds_w
                        bounds_s:(CGFloat)bounds_s
                        bounds_e:(CGFloat)bounds_e
                        bounds_n:(CGFloat)bounds_n
                            city:(NSString *)city
                           state:(NSString *)state
                           geoid:(int)geoid
                          forKey:(NSString *)key
{
    [_defaults setFloat:bounds_w
                 forKey:[NSString stringWithFormat:@"%@BoundsWest", key]];
    
    [_defaults setFloat:bounds_s
                 forKey:[NSString stringWithFormat:@"%@BoundsSouth", key]];
    
    [_defaults setFloat:bounds_e
                 forKey:[NSString stringWithFormat:@"%@BoundsEast", key]];
    
    [_defaults setFloat:bounds_n
                 forKey:[NSString stringWithFormat:@"%@BoundsNorth", key]];
    
    [_defaults setObject:city
                  forKey:[NSString stringWithFormat:@"%@City", key]];
    
    [_defaults setObject:state
                  forKey:[NSString stringWithFormat:@"%@State", key]];
    
    [_defaults setInteger:geoid
                  forKey:[NSString stringWithFormat:@"%@Geoid", key]];
    
    [_defaults synchronize];
}

- (UIColor *)lightColorForColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    CGFloat lightRed = (1.0 - ((1.0 - red) / 3.0));
    CGFloat lightGreen = (1.0 - ((1.0 - green) / 3.0));
    CGFloat lightBlue = (1.0 - ((1.0 - blue) / 3.0));
    
    UIColor *lightColor = [UIColor colorWithRed:lightRed
                                          green:lightGreen
                                           blue:lightBlue
                                          alpha:1.0];
    
    return lightColor;
}

- (UIColor *)darkColorForColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    CGFloat darkRed = (red / 3.0);
    CGFloat darkGreen = (green / 3.0);
    CGFloat darkBlue = (blue / 3.0);
    
    UIColor *darkColor = [UIColor colorWithRed:darkRed
                                         green:darkGreen
                                          blue:darkBlue
                                         alpha:1.0];
    
    return darkColor;
}

- (bool)pickAdjustedTextColorForColor1:(UIColor *)color1
                                color2:(UIColor *)color2
{
    bool rtn;
    CGFloat red1, green1, blue1, alpha1;
    CGFloat red2, green2, blue2, alpha2;
    
    [color1 getRed:&red1
             green:&green1
              blue:&blue1
             alpha:&alpha1];
    
    [color2 getRed:&red2
             green:&green2
              blue:&blue2
             alpha:&alpha2];
    
    CGFloat RGB1 = (red1 + green1 + blue1);
    CGFloat RGB2 = (red2 + green2 + blue2);
    
    if (RGB2 > RGB1)
        rtn = YES;
    
    else
        rtn = NO;
    
    return rtn;
}

@end