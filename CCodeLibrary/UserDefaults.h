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

- (UIColor *)getColor:(NSString *)color;
- (NSInteger)getInteger:(NSString *)integer;
- (bool)getBoolean:(NSString *)boolean;
- (NSString *)getString:(NSString *)string;

- (void)saveColor:(NSString *)color
              red:(float)red
            green:(float)green
             blue:(float)blue;

- (void)saveInteger:(NSString *)integer
              value:(int)value;

- (void)saveBoolean:(NSString *)boolean
              value:(bool)value;

- (void)saveString:(NSString *)string
          contents:(NSString *)contents;

@end