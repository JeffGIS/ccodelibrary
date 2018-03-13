//  WaitForStillness.h
//  CCodeLibrary

@import Foundation;

@protocol WaitForStillnessTarget <NSObject>

- (void)stillnessWasCanceled;

@end

@interface WaitForStillness : NSObject

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
                               countFactor:(double)countFactor
                         orientationFactor:(double)orientationFactor
                                    target:(id)aTarget
                                  selector:(SEL)aSelector;

+ (instancetype)waitForVerticalStillness:(double)steadyFactor
                             countFactor:(double)countFactor
                       orientationFactor:(double)orientationFactor
                                  target:(id)aTarget
                                selector:(SEL)aSelector;

- (void)cancelWaitForStillness;

@end
