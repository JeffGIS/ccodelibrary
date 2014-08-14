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

- (void)saveColorForKey:(NSString *)key
                    red:(float)red
                  green:(float)green
                   blue:(float)blue;

- (void)saveInteger:(int)integer
             forKey:(NSString *)key;

- (void)saveBool:(bool)boolean
          forKey:(NSString *)key;

- (void)saveString:(NSString *)string
            forKey:(NSString *)key;

@end