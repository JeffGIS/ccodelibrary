//  UserDefaults.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GSSiPopoverView.h"
#import "Colors.h"
#import "CCodeTypes.h"

@interface UserDefaults : NSObject
{
    NSUserDefaults *_defaults;
}

+ (UserDefaults *)defaults;

- (UIColor *)colorForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (CGFloat)CGFloatForKey:(NSString *)key;
- (NSData *)NSDataForKey:(NSString *)key;
- (NSArray *)geoidList;
- (NSArray *)locationList;
- (NSArray *)iPadList;
- (UIColor *)appleBlue;
- (UIColor *)lightBlue;
- (UIColor *)green;
- (UIColor *)darkGreen;
- (UIColor *)appleGray;
- (UIColor *)polygonFillColor;
- (Colors *)defaultColors;
- (UIImage *)checkmark;
- (UIImage *)imageTarget;
- (UIImage *)yellowArrow;
- (UIImage *)whiteArrow;
- (UIImage *)redArrow;
- (UIImage *)triangleImage;
- (UIImage *)redCircle;
- (UIImage *)deleteButton;
- (UIImage *)googleMapsImage;
- (UIImage *)redSliderThumb;
- (UIImage *)metalSliderRight;
- (UIImage *)metalSliderLeft;
- (NSString *)googleKey;
- (UIImage *)invertImage:(UIImage *)image;
- (void)disableWebKitDiskImageCache;
- (NSString *)sharedFilePath;
- (NSString *)localFilePath;

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

- (void)saveArray:(NSArray *)array
           forKey:(NSString *)key;

- (void)saveCGFloat:(CGFloat)CGFloat
             forKey:(NSString *)key;

- (void)saveNSData:(NSData *)data
            forKey:(NSString *)key;

- (void)setStatus:(int)status
         forGeoid:(int)geoid;

- (void)addLocationToListWithName:(NSString *)name
                            state:(NSString *)state
                            geoid:(int)geoid
                         bounds_w:(CGFloat)bounds_w
                         bounds_s:(CGFloat)bounds_s
                         bounds_e:(CGFloat)bounds_e
                         bounds_n:(CGFloat)bounds_n;

- (void)removeLocationFromListAtIndex:(NSUInteger)index;

- (UIColor *)lightColorForColor:(UIColor *)color;
- (UIColor *)darkColorForColor:(UIColor *)color;

- (BOOL)pickAdjustedTextColorForColor1:(UIColor *)color1
                                color2:(UIColor *)color2;

- (CGFloat)getTotalRGBforColor:(UIColor *)color;

- (void)shakeButton:(UIButton *)button;
- (void)deleteFilesForGeoid:(int)geoid;

- (UIImage *)imageWithColor:(UIColor *)color
                   andFrame:(CGRect)frame;

- (NSArray *)mapTypes;

UIImage *grayscaleImage(UIImage *image);

@end