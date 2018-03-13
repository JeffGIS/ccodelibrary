//  WaitForStillness.m
//  CCodeLibrary

#import "WaitForStillness.h"

#define VERTICAL 1
#define HORIZONTAL 2

@interface WaitForStillness ()

@property double steadyFactor, countFactor;
@property id aTarget;
@property SEL aSelector;
@property int orientation;

@end

@implementation WaitForStillness

+ (instancetype)waitForVerticalStillness:(double)steadyFactor
                             countFactor:(double)countFactor
                                  target:(id)aTarget
                                selector:(SEL)aSelector
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.orientation = VERTICAL;
    wfs.steadyFactor = steadyFactor;
    wfs.countFactor = countFactor;
    wfs.aTarget = aTarget;
    wfs.aSelector = aSelector;
    [wfs verifyStillness];
    return wfs;
}

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
                               countFactor:(double)countFactor
                                    target:(id)aTarget
                                  selector:(SEL)aSelector
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.orientation = HORIZONTAL;
    wfs.steadyFactor = steadyFactor;
    wfs.countFactor = countFactor;
    wfs.aTarget = aTarget;
    wfs.aSelector = aSelector;
    [wfs verifyStillness];
    return wfs;
}

- (void)verifyStillness
{
    [_aTarget performSelector:_aSelector];
}

- (void)cancelWaitForStillness
{
    if (_aTarget && [_aTarget respondsToSelector:@selector(stillnessWasCanceled)])
        [_aTarget stillnessWasCanceled];
}

@end
