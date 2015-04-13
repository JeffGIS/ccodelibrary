//  GSSiBumpDetector.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GSSiBumpDetector;

@protocol GSSiBumpDetectorDelegate <NSObject>

- (void)bumpDetector:(GSSiBumpDetector *)bumpDetector
didReturnTimeInterval:(NSTimeInterval)timeInterval;

- (void)bumpDetectorDidCancel:(GSSiBumpDetector *)bumpDetector;

@end

@interface GSSiBumpDetector : UIView

@property (nonatomic, weak) id <GSSiBumpDetectorDelegate> delegate;

+ (GSSiBumpDetector *)showBumpDetectorWithView:(UIView *)view
                                  coundownTime:(NSInteger)countdownTime
                                      delegate:(id)delegate;

- (void)hideBumpDetector:(BOOL)animated;

@end