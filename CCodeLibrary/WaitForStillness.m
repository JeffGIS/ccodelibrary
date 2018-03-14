//  WaitForStillness.m
//  CCodeLibrary

#import "WaitForStillness.h"
@import CoreMotion;
@import AVFoundation;

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
@property (nonatomic) NSTimer *beepTimer;
@property (nonatomic) AVAudioPlayer *beep, *finalBeep;

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
    wfs.count = (countFactor * COUNT_MULTIPLIER);
    wfs.orientationTolerance = (orientationFactor * ORIENTATION_MULTIPLER);
    wfs.aTarget = aTarget;
    wfs.aSelector = aSelector;
    wfs.orientation = orientation;
    wfs.motionManager = CMMotionManager.new;
    
    if (beepSeconds > 0)
    {
        wfs.beep = [[AVAudioPlayer alloc] initWithContentsOfURL:
                    [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.mp3",
                                            NSBundle.mainBundle.resourcePath]] error:nil];
        
        [wfs.beep prepareToPlay];
        wfs.beep.volume = 1.0;
        
        wfs.beepTimer = [NSTimer scheduledTimerWithTimeInterval:beepSeconds
                                                         target:wfs
                                                       selector:@selector(doBeep:)
                                                       userInfo:nil
                                                        repeats:YES];
    }

    [wfs verifyStillness];
    return wfs;
}

- (void)doBeep:(NSTimer *)timer
{
    [_beep play];
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
        double angleX = acos(accelX / denom);
        double angleY = acos(accelY / denom);
        double angleZ = acos(accelZ / denom);
        
        switch (_orientation)
        {
            //horizontal: x=90°, y=90°, z=180°
            case HORIZONTAL:
                angleX = fabs(angleX - M_PI_2);
                angleY = fabs(angleY - M_PI_2);
                angleZ = fabs(angleZ - M_PI);
                break;
            //horizontal: x=0°, y=90°, z=90°
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
            if (_beepTimer)
                [_beepTimer invalidate];

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
    if (_beepTimer)
        [_beepTimer invalidate];
    
    [_motionManager stopAccelerometerUpdates];
    
    if (_aTarget && [_aTarget respondsToSelector:@selector(stillnessWasCanceled)])
        [_aTarget stillnessWasCanceled];
}

@end
