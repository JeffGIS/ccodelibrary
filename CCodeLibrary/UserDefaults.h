//  UserDefaults.h
//  CCodeLibrary
//
//  Created by Bill Munson on 8/13/14.
//  Copyright (c) 2014 GSSi. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserDefaults : NSObject
{
    NSUserDefaults *_defaults;
}

+ (UserDefaults *) defaults;

- (UIColor *)colorForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (bool)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (CGFloat)CGFloatForKey:(NSString *)key;

- (void)saveColorWithRed:(CGFloat)red
                   green:(CGFloat)green
                    blue:(CGFloat)blue
                  forKey:(NSString *)key;

- (void)saveColor:(UIColor *)color
           forKey:(NSString *)key;

- (void)saveInteger:(int)integer
             forKey:(NSString *)key;

- (void)saveBool:(bool)boolean
          forKey:(NSString *)key;

- (void)saveString:(NSString *)string
            forKey:(NSString *)key;

- (void)saveCGFloat:(CGFloat)CGFloat
             forKey:(NSString *)key;

- (UIColor *)lightColorForColor:(UIColor *)color;
- (UIColor *)darkColorForColor:(UIColor *)color;

- (bool)pickAdjustedTextColorForColor1:(UIColor *)color1
                                color2:(UIColor *)color2;

@end