//  WaitForStillness.h
//  CCodeLibrary

@import Foundation;

@protocol WaitForStillnessTarget <NSObject>

- (void)stillnessWasCanceled;

@end

@interface WaitForStillness : NSObject

/**
            PARAMETER UNITS
            steadyFactor: +/- 0.02 g forces
            countFactor: 4 seconds
            orientationFactor: +/- 0.1 radians
 **/

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
                               countFactor:(double)countFactor
                         orientationFactor:(double)orientationFactor
                                beepFactor:(double)beepSeconds
                                    target:(id)aTarget
                                  selector:(SEL)aSelector;

+ (instancetype)waitForVerticalStillness:(double)steadyFactor
                             countFactor:(double)countFactor
                       orientationFactor:(double)orientationFactor
                              beepFactor:(double)beepSeconds
                                  target:(id)aTarget
                                selector:(SEL)aSelector;

- (void)cancelWaitForStillness;

@end
