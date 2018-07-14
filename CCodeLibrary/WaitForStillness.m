//  WaitForStillness.m
//  CCodeLibrary

#import "WaitForStillness.h"
@import CoreMotion;
@import AVFoundation;
#import "CRAPI.h"

#define STEADY_MULTIPLIER 0.02
#define COUNT_MULTIPLIER 100
#define ORIENTATION_MULTIPLER 0.1
#define MEASUREMENT_FREQUENCY 0.02

@interface WaitForStillness ()

@property double steadyDiff, orientationTolerance;
@property double maxX, minX, maxY, minY, maxZ, minZ, sumX, sumY, sumZ;
@property id aTarget;
@property SEL aSelector;
@property int counter, count;
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
                      orientation:VERTICAL];
}

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
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
                      orientation:HORIZONTAL];
}

+ (instancetype)waitForStillness:(double)steadyFactor
                     countFactor:(double)countFactor
               orientationFactor:(double)orientationFactor
                      beepFactor:(double)beepSeconds
                          target:(id)aTarget
                        selector:(SEL)aSelector
                     orientation:(int)orientation
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.steadyDiff = (steadyFactor * STEADY_MULTIPLIER);
    wfs.count = (int)(countFactor * COUNT_MULTIPLIER);
    wfs.orientationTolerance = (orientationFactor * ORIENTATION_MULTIPLER);
    wfs.aTarget = aTarget;
    wfs.aSelector = aSelector;
    wfs.orientation = orientation;
    wfs.motionManager = CMMotionManager.new;
    
    [CRAPI.sharedInstance startBeepTimer:beepSeconds];
    [wfs verifyStillness];
    return wfs;
}

+ (void)determineIsDeviceIsPortraitOrUpsideDown:(id)aTarget
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.aTarget = aTarget;
    wfs.motionManager = CMMotionManager.new;
    wfs.count = 5;
    [wfs verifyPortraitOrUpsideDown];
}

- (void)verifyStillness
{
    [self resetSumsAndCounter];
    
    typedef void (^CMAccelerometerHandler)(CMAccelerometerData *accelerometerData, NSError *error);
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
    if (_counter == _count)
    {
        double accelX = (_sumX / _count);
        double accelY = (_sumY / _count);
        double accelZ = (_sumZ / _count);
        
        double denom = sqrt(square(accelX) + square(accelY) + square(accelZ));
        double angleX = acos(accelX / denom);
        double angleY = acos(accelY / denom);
        double angleZ = acos(accelZ / denom);
        angleX = min (angleX,fabs (M_PI - angleX));
        angleY = min (angleY,fabs (M_PI - angleY));
        //angleZ = min (angleZ,fabs (M_PI - angleZ));
        switch (_orientation)
        {
            //horizontal: x=90°, y=90°, z=180°
            case HORIZONTAL:
                angleX = fabs(angleX - M_PI_2);
                angleY = fabs(angleY - M_PI_2);
                angleZ = fabs(angleZ - M_PI);
                break;
            //vertical: x=0°, y=90°, z=90°
            case VERTICAL:
                angleX = fabs(angleX);
                angleY = fabs(angleY - M_PI_2);
                angleZ = fabs(angleZ - M_PI_2);
                break;
            default:break;
        }
        
        if ((angleX < _orientationTolerance) &&
            (angleY < _orientationTolerance) &&
            (angleZ < _orientationTolerance))
        {
            NSTimeInterval delay = 0.1;
            
            [self cancelOperations:delay];
            [_aTarget performSelector:_aSelector withObject:nil afterDelay:delay];
        }
        
        else
            [self verifyStillness];
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
