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
    float red = [_defaults floatForKey:[NSString stringWithFormat:@"%@Red", key]];
    float green = [_defaults floatForKey:[NSString stringWithFormat:@"%@Green", key]];
    float blue = [_defaults floatForKey:[NSString stringWithFormat:@"%@Blue", key]];

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

- (void)saveColorWithRed:(float)red
                   green:(float)green
                    blue:(float)blue
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
    
    [_defaults setFloat:red
                 forKey:[NSString stringWithFormat:@"%@Red", key]];
    
    [_defaults setFloat:green
                 forKey:[NSString stringWithFormat:@"%@Green", key]];
    
    [_defaults setFloat:blue
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

@end