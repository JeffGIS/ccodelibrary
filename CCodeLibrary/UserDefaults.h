//  UserDefaults.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CRAPI.h"
#import "Colors.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PriorityLocation.h"
#import "PointInAreaClass.h"
#import "GSSiEnums.h"
#import "GSSiPopoverView.h"

@class UserDefaults;

@protocol UserDefaultsDelegate <NSObject>

- (void)didFinishPriorityLocationArray:(NSMutableArray *)locationArray;

@end

@interface UserDefaults : NSObject
{
    NSUserDefaults *_defaults;
}

@property (nonatomic, weak) id <UserDefaultsDelegate> delegate;

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
- (NSString *)googleKey;
- (NSString *)removeEndingReturn:(NSString *)string;
- (NSString *)removeTextInsideParentheses:(NSString *)string;
- (NSString *)removeTextInsideParenthesesWithoutSpaces:(NSString *)string;
- (NSString *)removeColonInsideParentheses:(NSString *)string;
- (NSString *)includeTextBeforeParentheses:(NSString *)string;
- (NSString *)includeTextInsideParentheses:(NSString *)string;
- (NSString *)includeTextAfterHyphen:(NSString *)string;
- (NSString *)includeTextBeforeHyphen:(NSString *)string;
- (NSString *)includeTextBeforeTab:(NSString *)string;
- (NSString *)includeTextAfterTab:(NSString *)string;
- (NSString *)includeTextBeforePipe:(NSString *)string;
- (NSString *)includeTextAfterPipe:(NSString *)string;
- (NSString *)includeTextAfterFirstColon:(NSString *)string;
- (NSString *)addSpaceAfterComma:(NSString *)string;
- (NSString *)removeOpeningSpaces:(NSString *)string;
- (UIImage *)invertImage:(UIImage *)image;
- (void)disableWebKitDiskImageCache;
- (NSString *)sharedFilePath;
- (NSString *)localFilePath;
- (NSMutableArray *)sortByContentsOfParentheses:(NSMutableArray *)array;
- (NSArray *)priorityLocationKeywords;
- (NSArray *)priorityLocationTypes;

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

- (void)priorityLocationArrayForSpan:(MKCoordinateSpan)span
                              origin:(CLLocationCoordinate2D)origin
                              bounds:(dbounds)bounds
                         popoverView:(GSSiPopoverView *)popover;

@end