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
        
    }
    
    return self;
}

- (UIColor *)getColor:(NSString *)color
{
    float red = [self.defaults floatForKey:[NSString stringWithFormat:@"%@red", color]];
    float blue = [self.defaults floatForKey:[NSString stringWithFormat:@"%@blue", color]];
    float green = [self.defaults floatForKey:[NSString stringWithFormat:@"%@green", color]];

    UIColor *defaultColor = [UIColor colorWithRed:red
                                            green:green
                                             blue:blue
                                            alpha:1.0];
    
    return defaultColor;
}

- (NSInteger)getInteger:(NSString *)integer
{
    NSInteger defaultInteger = [self.defaults integerForKey:integer];
    return defaultInteger;
}

- (bool)getBoolean:(NSString *)boolean
{
    bool defaultBoolean = [self.defaults boolForKey:boolean];
    return defaultBoolean;
}

- (void)saveColor:(NSString *)color
              red:(float)red
            green:(float)green
             blue:(float)blue
{
    [self.defaults setFloat:red
                     forKey:[NSString stringWithFormat:@"%@red", color]];
    
    [self.defaults setFloat:green
                     forKey:[NSString stringWithFormat:@"%@green", color]];
    
    [self.defaults setFloat:blue
                     forKey:[NSString stringWithFormat:@"%@blue", color]];
    
    [self.defaults synchronize];
}

- (void)saveInteger:(NSString *)integer
              value:(int)value;
{
    [self.defaults setInteger:value
                       forKey:integer];
    
    [self.defaults synchronize];
}

- (void)saveBoolean:(NSString *)boolean
              value:(bool)value;
{
    [self.defaults setBool:value
                    forKey:boolean];
    
    [self.defaults synchronize];
}

@end