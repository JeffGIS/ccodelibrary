//  UserDefaults.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserDefaults : NSObject
{
    NSUserDefaults *_defaults;
}

+ (UserDefaults *) defaults;

- (UIColor *)colorForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (CGFloat)CGFloatForKey:(NSString *)key;
- (NSArray *)locationList;
- (UIColor *)appleBlue;
- (UIColor *)green;
- (UIColor *)polygonFillColor;

- (void)saveColorWithRed:(CGFloat)red
                   green:(CGFloat)green
                    blue:(CGFloat)blue
                  forKey:(NSString *)key;

- (void)saveColor:(UIColor *)color
           forKey:(NSString *)key;

- (void)saveInteger:(int)integer
             forKey:(NSString *)key;

- (void)saveBool:(BOOL)boolean
          forKey:(NSString *)key;

- (void)saveString:(NSString *)string
            forKey:(NSString *)key;

- (void)saveCGFloat:(CGFloat)CGFloat
             forKey:(NSString *)key;

- (void)addLocationToListWithName:(NSString *)name
                            state:(NSString *)state
                            geoid:(int)geoid
                         bounds_w:(CGFloat)bounds_w
                         bounds_s:(CGFloat)bounds_s
                         bounds_e:(CGFloat)bounds_e
                         bounds_n:(CGFloat)bounds_n
                           status:(int)status;

- (UIColor *)lightColorForColor:(UIColor *)color;
- (UIColor *)darkColorForColor:(UIColor *)color;

- (bool)pickAdjustedTextColorForColor1:(UIColor *)color1
                                color2:(UIColor *)color2;

- (CGFloat)getTotalRGBforColor:(UIColor *)color;

@end