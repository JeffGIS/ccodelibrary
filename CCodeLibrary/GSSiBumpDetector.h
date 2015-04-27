//  GSSiBumpDetector.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class GSSiBumpDetector;

@protocol GSSiBumpDetectorDelegate <NSObject>

- (void)bumpDetector:(GSSiBumpDetector *)bumpDetector
didReturnTimeInterval:(NSString *)timeInterval;

- (void)bumpDetectorDidCancel:(GSSiBumpDetector *)bumpDetector;

@end

@interface GSSiBumpDetector : UIView

@property (nonatomic, weak) id <GSSiBumpDetectorDelegate> delegate;

+ (GSSiBumpDetector *)showBumpDetectorWithView:(UIView *)view
                                  coundownTime:(NSInteger)countdownTime
                                         title:(NSString *)title
                                      delegate:(id)delegate;

- (void)hideBumpDetector:(BOOL)animated;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight;

@end