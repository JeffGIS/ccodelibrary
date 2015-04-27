//  NamedColors.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NamedColors : NSObject

- (UIColor *)colorFromIndex:(int)index;
- (NSString *)colorNameFromIndex:(int)index;
- (int)getNearestNamedColorIndex:(UIColor *)color;

@end