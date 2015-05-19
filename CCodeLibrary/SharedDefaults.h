//  SharedDefaults.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

@end