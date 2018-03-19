//  WaitForStillness.h
//  CCodeLibrary

@import Foundation;

@class WaitForStillness;

@protocol WaitForStillnessTarget <NSObject>

@optional
- (void)stillnessWasCanceled;
- (void)deviceIsInPortraitOrUpsideDown:(BOOL)portraitOrUpsideDown;

@end

@interface WaitForStillness : NSObject

/**
            PARAMETER UNITS
            steadyFactor: +/- 0.02 g forces
            countFactor: 4 seconds
            orientationFactor: +/- 0.1 radians (+/- 5.73°)
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

+ (void)determineIsDeviceIsPortraitOrUpsideDown:(id)aTarget;

- (void)cancelWaitForStillness;

@end
