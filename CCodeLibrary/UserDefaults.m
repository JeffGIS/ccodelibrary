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
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (UIColor *)getColor:(NSString *)color
{
    float red = [_defaults floatForKey:[NSString stringWithFormat:@"%@red", color]];
    float blue = [_defaults floatForKey:[NSString stringWithFormat:@"%@blue", color]];
    float green = [_defaults floatForKey:[NSString stringWithFormat:@"%@green", color]];

    UIColor *defaultColor = [UIColor colorWithRed:red
                                            green:green
                                             blue:blue
                                            alpha:1.0];
    
    return defaultColor;
}

- (NSInteger)getInteger:(NSString *)integer
{
    NSInteger defaultInteger = [_defaults integerForKey:integer];
    return defaultInteger;
}

- (bool)getBoolean:(NSString *)boolean
{
    bool defaultBoolean = [_defaults boolForKey:boolean];
    return defaultBoolean;
}

- (NSString *)getString:(NSString *)string
{
    NSString *defaultString = [_defaults objectForKey:string];
    return defaultString;
}

- (void)saveColor:(NSString *)color
              red:(float)red
            green:(float)green
             blue:(float)blue
{
    [_defaults setFloat:red
                 forKey:[NSString stringWithFormat:@"%@red", color]];
    
    [_defaults setFloat:green
                 forKey:[NSString stringWithFormat:@"%@green", color]];
    
    [_defaults setFloat:blue
                 forKey:[NSString stringWithFormat:@"%@blue", color]];
    
    [_defaults synchronize];
}

- (void)saveInteger:(NSString *)integer
              value:(int)value;
{
    [_defaults setInteger:value
                   forKey:integer];
    
    [_defaults synchronize];
}

- (void)saveBoolean:(NSString *)boolean
              value:(bool)value;
{
    [_defaults setBool:value
                forKey:boolean];
    
    [_defaults synchronize];
}

- (void)saveString:(NSString *)string
          contents:(NSString *)contents
{
    [_defaults setObject:contents
                  forKey:string];
    
    [_defaults synchronize];
}

@end