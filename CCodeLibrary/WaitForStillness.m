//  WaitForStillness.m
//  CCodeLibrary

#import "WaitForStillness.h"
@import CoreMotion;
@import AVFoundation;
#import "CRAPI.h"

#define STEADY_MULTIPLIER 0.02
#define COUNT_MULTIPLIER 50
#define ORIENTATION_MULTIPLER 0.1
#define MEASUREMENT_FREQUENCY 0.02

@interface WaitForStillness ()

@property double steadyDiff, orientationTolerance;
@property double maxX, minX, maxY, minY, maxZ, minZ, sumX, sumY, sumZ;
@property id aTarget;
@property SEL aSelector;
@property SEL holdSelector;
@property int counter, count;
@property BOOL wantAccelerometerData;
@property (nonatomic) CMMotionManager *motionManager;

@end

@implementation WaitForStillness

+ (instancetype)waitForVerticalStillness:(double)steadyFactor
                             countFactor:(double)countFactor
                       orientationFactor:(double)orientationFactor
                              beepFactor:(double)beepSeconds
                                  target:(id)aTarget
                                selector:(SEL)aSelector
{
    return [self waitForStillness:steadyFactor
                      countFactor:countFactor
                orientationFactor:orientationFactor
                       beepFactor:beepSeconds
                           target:aTarget
                         selector:aSelector
                 ifInHoldSelector:nil
                      orientation:VERTICAL];
}

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
                               countFactor:(double)countFactor
                         orientationFactor:(double)orientationFactor
                                beepFactor:(double)beepSeconds
                                    target:(id)aTarget
                                  selector:(SEL)aSelector
                            ifInHoldSelector:(SEL)holdSelector
{
    return [self waitForStillness:steadyFactor
                      countFactor:countFactor
                orientationFactor:orientationFactor
                       beepFactor:beepSeconds
                           target:aTarget
                         selector:aSelector
                 ifInHoldSelector:holdSelector
                      orientation:HORIZONTAL];
}

+ (instancetype)waitForMotion:(double)steadyFactor
                               countFactor:(double)countFactor
                         orientationFactor:(double)orientationFactor
                                beepFactor:(double)beepSeconds
                                    target:(id)aTarget
                                  selector:(SEL)aSelector
{
    return [self waitForStillness:steadyFactor
                      countFactor:countFactor
                orientationFactor:orientationFactor
                       beepFactor:beepSeconds
                           target:aTarget
                         selector:aSelector
                 ifInHoldSelector:nil
                      orientation:WAITFORMOTION];
}

+ (instancetype)waitForStillness:(double)steadyFactor
                     countFactor:(double)countFactor
               orientationFactor:(double)orientationFactor
                      beepFactor:(double)beepSeconds
                          target:(id)aTarget
                        selector:(SEL)aSelector
                  ifInHoldSelector:(SEL)holdSelector
                     orientation:(int)orientation
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.steadyDiff = (steadyFactor * STEADY_MULTIPLIER);
    wfs.count = (int)(countFactor * COUNT_MULTIPLIER);
    wfs.orientationTolerance = orientationFactor;
    wfs.aTarget = aTarget;
    wfs.aSelector = aSelector;
    wfs.holdSelector = holdSelector;
    wfs.orientation = orientation;
    wfs.motionManager = [CRAPI.sharedInstance getMotionManager];
    
    [CRAPI.sharedInstance startBeepTimer:beepSeconds];
    [wfs verifyStillness];
    return wfs;
}

+ (WaitForStillness*)determineIsDeviceIsPortraitOrUpsideDown:(id)aTarget
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.aTarget = aTarget;
    wfs.motionManager = [CRAPI.sharedInstance getMotionManager];
    wfs.count = 5;
    [wfs verifyPortraitOrUpsideDown];
    return wfs;
}
- (id)init
{
    self = [super init];
    
    return self;
}
- (void)dealloc
{
    return;
}

- (void)verifyStillness
{
    [self resetSumsAndCounter];
    _wantAccelerometerData = YES;
    typedef void (^CMAccelerometerHandler)(CMAccelerometerData *accelerometerData, NSError *error);
    
    [_motionManager startDeviceMotionUpdates];
    _motionManager.accelerometerUpdateInterval = MEASUREMENT_FREQUENCY;
    
    if (_motionManager.isAccelerometerAvailable)
    {
        [_motionManager startAccelerometerUpdatesToQueue:NSOperationQueue.currentQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                                 [self computeSlopeFromAccelerometer:accelerometerData];
                                                 
                                                 if(error)
                                                     NSLog(@"CMMotionManager ERROR: %@", error.localizedDescription);
                                             }];
    }
    
    else {NSLog(@"CMMotionManager ERROR: No Accelerometer Data Available.");}
}

- (void)computeSlopeFromAccelerometer:(CMAccelerometerData *)accelerometerData
{
    NSTimeInterval delay = 0.1;
    if (!_wantAccelerometerData)
        return;
    if (CRAPI.sharedInstance.holdForMeasurement)
    {
        if (_holdSelector)
            [_aTarget performSelector:_holdSelector withObject:nil afterDelay:delay];
        return;
    }
    if (_counter == _count)
    {
        double accelX = (_sumX / _count);
        double accelY = (_sumY / _count);
        double accelZ = (_sumZ / _count);
        double wantVal = -1.0;
        BOOL inPosition = FALSE;
        switch (_orientation)
        {
            //horizontal: x=90°, y=90°, z=180°
            case HORIZONTAL:
                if (fabs (accelZ - wantVal) <_orientationTolerance && fabs(accelX) < 0.5 && fabs (accelY) < 0.5)
                    inPosition = TRUE;
                break;
            //vertical: x=0°, y=90°, z=90°
            case VERTICAL:
                if (fabs (accelX - wantVal) <_orientationTolerance && fabs(accelY) < 0.5 && fabs (accelZ) < 0.5)
                    inPosition = TRUE;
                break;
            case WAITFORMOTION:
                [self resetSumsAndCounter];
                return;
                break;
       }
        
        if (inPosition)
        {
            _wantAccelerometerData = NO;
            [self cancelOperations:delay];
            [_aTarget performSelector:_aSelector withObject:nil afterDelay:delay];
        }
        
        else
        {
            [self resetSumsAndCounter];
            //[_motionManager stopAccelerometerUpdates];
            //[self verifyStillness];
        }
    }
    
    else if (_counter < _count)
    {
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        _maxX = max(_maxX, acceleration.x);
        _minX = min(_minX, acceleration.x);
        _maxY = max(_maxY, acceleration.y);
        _minY = min(_minY, acceleration.y);
        _maxZ = max(_maxZ, acceleration.z);
        _minZ = min(_minZ, acceleration.z);
        
        double xRange = (_maxX - _minX);
        double yRange = (_maxY - _minY);
        double zRange = (_maxZ - _minZ);
        
        if (yRange > _steadyDiff ||
            xRange > _steadyDiff ||
            zRange > _steadyDiff)
        {
            if (_orientation == WAITFORMOTION)
            {
                NSTimeInterval delay = 0.1;
                
                [self cancelOperations:delay];
                [_aTarget performSelector:_aSelector withObject:nil afterDelay:delay];
                
            }
            else
                [self resetSumsAndCounter];
        }
        
        _sumX += acceleration.x;
        _sumY += acceleration.y;
        _sumZ += acceleration.z;
        _counter++;
    }
}

- (void)resetSumsAndCounter
{
    _maxX = _maxY = _maxZ = -10.0;
    _minX = _minY = _minZ = 10.0;
    _sumX = _sumY = _sumZ = 0.0;
    _counter = 0;
}

- (void)cancelOperations:(NSTimeInterval)stopBeepDelay
{
    [_motionManager stopAccelerometerUpdates];
    [CRAPI.sharedInstance performSelector:@selector(cancelBeepTimer)
                               withObject:nil
                               afterDelay:stopBeepDelay];
}

- (void)cancelWaitForStillness
{
    [self cancelOperations:0];
    
    if (_aTarget && [_aTarget respondsToSelector:@selector(stillnessWasCanceled)])
        [_aTarget stillnessWasCanceled];
}

- (void)verifyPortraitOrUpsideDown
{
    typedef void (^CMAccelerometerHandler)(CMAccelerometerData *accelerometerData, NSError *error);
    
    [_motionManager startDeviceMotionUpdates];
    _motionManager.accelerometerUpdateInterval = MEASUREMENT_FREQUENCY;
    
    if (_motionManager.isAccelerometerAvailable)
    {
        [_motionManager startAccelerometerUpdatesToQueue:NSOperationQueue.currentQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                                 [self verifyPortraitFromAccelerometer:accelerometerData];
                                                 
                                                 if(error)
                                                     NSLog(@"CMMotionManager ERROR: %@", error.localizedDescription);
                                             }];
    }
    
    else {NSLog(@"CMMotionManager ERROR: No Accelerometer Data Available.");}
}

- (void)verifyPortraitFromAccelerometer:(CMAccelerometerData *)accelerometerData
{
    if (_counter == _count)
    {
        [_motionManager stopAccelerometerUpdates];
        
        if (_aTarget && [_aTarget respondsToSelector:@selector(deviceIsInPortraitOrUpsideDown:)])
        {
            double accelY = (_sumY / _count);
            
            if (accelY > 0.5 || accelY < -0.5)
                [_aTarget deviceIsInPortraitOrUpsideDown:YES];
            
            else
                [_aTarget deviceIsInPortraitOrUpsideDown:NO];
        }
    }
    
    else if (_counter < _count)
    {
        _sumY += accelerometerData.acceleration.y;
        _counter++;
    }
}

@end
