//  WaitForStillness.h
//  CCodeLibrary

@import Foundation;

@protocol WaitForStillnessTarget <NSObject>

- (void)stillnessWasCanceled;

@end

@interface WaitForStillness : NSObject

+ (instancetype)waitForVerticalStillness:(double)steadyFactor
                             countFactor:(double)countFactor
                                  target:(id)aTarget
                                selector:(SEL)aSelector;

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
                               countFactor:(double)countFactor
                                    target:(id)aTarget
                                  selector:(SEL)aSelector;

- (void)cancelWaitForStillness;

@end
