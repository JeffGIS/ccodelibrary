//  NVColorWheel.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "UIView+ColorOfPoint.h"

@class NVColorWheel;

@protocol NVColorWheelDelegate <NSObject>

- (void)colorWheel:(NVColorWheel *)colorWheel
    didReturnColor:(UIColor *)color
               tag:(NSInteger)tag;

- (void)colorWheelDidCancel:(NVColorWheel *)colorWheel;

@end

@interface NVColorWheel : UIImageView

@property (nonatomic, weak) id <NVColorWheelDelegate> delegate;

+ (NVColorWheel *)showColorWheelWithView:(UIView *)view
                              startColor:(UIColor *)startColor
                                delegate:(id)delegate
                                  tabBar:(UITabBar *)tabBar
                                     tag:(NSInteger)tag;

- (void)hideColorWheel:(BOOL)animated;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end