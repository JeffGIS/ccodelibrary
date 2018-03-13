//  WaitForStillness.m
//  CCodeLibrary

#import "WaitForStillness.h"
@import CoreMotion;

#define HORIZONTAL 1
#define VERTICAL 2

#define STEADY_MULTIPLIER 0.02
#define COUNT_MULTIPLIER 100
#define ORIENTATION_MULTIPLER 0.1
#define MEASUREMENT_FREQUENCY 0.04

@interface WaitForStillness ()

@property double count, steadyDiff, orientationTolerance;
@property double maxX, minX, maxY, minY, maxZ, minZ, sumX, sumY, sumZ;
@property id aTarget;
@property SEL aSelector;
@property int orientation, counter;
@property (nonatomic) CMMotionManager *motionManager;

@end

@implementation WaitForStillness

+ (instancetype)waitForVerticalStillness:(double)steadyFactor
                             countFactor:(double)countFactor
                       orientationFactor:(double)orientationFactor
                                  target:(id)aTarget
                                selector:(SEL)aSelector
{
    return [self waitForStillness:steadyFactor
                      countFactor:countFactor
                orientationFactor:orientationFactor
                           target:aTarget
                         selector:aSelector
                      orientation:VERTICAL];
}

+ (instancetype)waitForHorizontalStillness:(double)steadyFactor
                               countFactor:(double)countFactor
                         orientationFactor:(double)orientationFactor
                                    target:(id)aTarget
                                  selector:(SEL)aSelector
{
    return [self waitForStillness:steadyFactor
                      countFactor:countFactor
                orientationFactor:orientationFactor
                           target:aTarget
                         selector:aSelector
                      orientation:HORIZONTAL];
}

+ (instancetype)waitForStillness:(double)steadyFactor
                     countFactor:(double)countFactor
               orientationFactor:(double)orientationFactor
                          target:(id)aTarget
                        selector:(SEL)aSelector
                     orientation:(int)orientation
{
    WaitForStillness *wfs = WaitForStillness.new;
    wfs.steadyDiff = (steadyFactor * STEADY_MULTIPLIER);
    wfs.count = (countFactor * COUNT_MULTIPLIER);
    wfs.orientationTolerance = (orientationFactor * ORIENTATION_MULTIPLER);
    wfs.aTarget = aTarget;
    wfs.aSelector = aSelector;
    wfs.orientation = orientation;
    wfs.motionManager = CMMotionManager.new;
    [wfs verifyStillness];
    return wfs;
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
        [_motionManager stopAccelerometerUpdates];
        
        double accelX = (_sumX / _count);
        double accelY = (_sumY / _count);
        double accelZ = (_sumZ / _count);
        
        double denom = sqrt(square(accelX) + square(accelY) + square(accelZ));
        double angleX = acos(accelY / denom);
        double angleY = acos(accelX / denom);
        double angleZ = acos(accelZ / denom);
        
        switch (_orientation)
        {
            case HORIZONTAL:
                angleX = fabs(angleX - M_PI_2);
                angleY = fabs(angleY - M_PI_2);
                angleZ = fabs(angleZ - M_PI);
                break;
            case VERTICAL:
                angleX = fabs(angleX - M_PI_2);
                angleY = fabs(angleY);
                angleZ = fabs(angleZ - M_PI_2);
                break;
            default:break;
        }
        
        if ((angleX < _orientationTolerance) &&
            (angleY < _orientationTolerance) &&
            (angleZ < _orientationTolerance))
        {
            [_aTarget performSelector:_aSelector];
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

- (void)cancelWaitForStillness
{
    [_motionManager stopAccelerometerUpdates];
    
    if (_aTarget && [_aTarget respondsToSelector:@selector(stillnessWasCanceled)])
        [_aTarget stillnessWasCanceled];
}

@end
