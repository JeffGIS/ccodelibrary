//
//  TrackLocationManager.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 11/8/23.
//  Copyright © 2023 GSSi. All rights reserved.
//
#import "TrackLocationManager.h"
//#import <UIKit/UIKit.h>
#import "GSSiDefs.h"
#import "CRAPI.h"
#import "CVTCoord.h"
#include "PROJ.H"
#import "HuntingData.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

typedef struct {
    CMMotionActivityConfidence confidence;
    int startTime;
    BOOL unknown;
    BOOL stationary;
    BOOL walking;
    BOOL running;
    BOOL automotive;
    BOOL cycling;
} GSSiMotionActivity;

@interface TrackLocationManager ()

@property CLLocationManager *locationManager;
@property int minTimerDelay,maxTimerDelay;
@property int timerDelay;
@property double notifyDist;
@property double offCourseDist;
@property BOOL goLeft;
@property BOOL amSavingLocations;
@property NSURL *leftSoundURL, *rightSoundURL, *gotGPSInputSoundURL1, *gotGPSInputSoundURL2, *gotGPSInputSoundURL3;
@property NSURL *bearRightSoundURL, *right45SoundURL, *right90SoundURL, *right135SoundURL, *offCourseSoundURL;
@property NSURL *bearLeftSoundURL, *left45SoundURL, *left90SoundURL, *left135SoundURL, *endOfRouteSoundURL, *turnArroundSoundURL;
@property NSURL *currentGPSTickURL, *endLocationTrackingSoundURL, *vehicleLocationSavedSoundURL, *startTrackingSoundURL, *startFollowingRouteSoundURL;
@property NSURL *playNextURL;
@property float currentGPSTickVol;
@property NSString * savedLocationsFile;
@property NSString * tempDirectory;
@property int currentSimulationIndex;
@property NSTimer *simulationTimer;
@property int numUpdates;
@property BOOL atEndOfRoute;
@property double turnDegrees;
@property int numLastPoints;
@property int maxLastPoints;
@property int * pLastPointsTime;
@property LPDPOINT pLastPoints;
@property double distToRoute;
@property double currentGPSHeading;
@property double headingToNextPoint;
@property AVAudioPlayer *appSoundPlayer;
@property BOOL isPlayingAudio;
@property int lastTurnAroundTime;
@property NSMutableArray *pointsInMessageList;
@property float simulationInterval;
@property CMMotionActivityManager *motionActivityManager;
@property AVAudioPlayer *ticPlayer;
@property AVAudioPlayer *messagePlayer;
@property int needToSetVehicleLocation;
@property BOOL needToInitiateRoute;
@property double moveAwayFromVehicleDist, returnToVehicleDist;
@property double maxDistFromVehicle, minTrackRouteDist;
@property int minTrackTime;
@property BOOL needTurnAdvice;
@property double lastRouteOffset;
@property BOOL crossedRouteSegment;
@property DPOINT minDistIntPoint;
@property DPOINT lastMessageIntPoint;
@property BOOL savingMotion;
@property FILE *fidMotion;
@property NSTimer *motionReplayTimer;
@property int motionRecordID;
@property BOOL replayingMotion;
@property int lastReplayMotionTime;
@property float replayTimeFactor;
@property NSMutableArray * vehicleCoordinates;
@property int walkingCoordinates;
@property float currentSpeed;
@property float maxWalkingSpeed;
@property BOOL motionIsActive;
@end

@implementation TrackLocationManager

-(id) init
{
    self = [super init];
    
    if (self)
    {
        NSError *error = nil;
        
        _maxWalkingSpeed = 1.5;
        _vehicleCoordinates = nil;
        _walkingCoordinates = -1;
        _replayTimeFactor = 1;
        _currentMotionActivity = @"Undefined";
        _simulationInterval = 0.2;
        _locationManager = CLLocationManager.new;
        _locationManager.delegate = self;
        _maxTimerDelay = 60;
        _minTimerDelay = 10;
        _timerDelay = _maxTimerDelay;
        _notifyDist = 7;
        _offCourseDist = 25 * _notifyDist;
        _numLastPoints = 0;
        _maxLastPoints = 8;
        _pLastPoints = malloc (sizeof(DPOINT)*_maxLastPoints+4);
        _pLastPointsTime = malloc (sizeof(int)*_maxLastPoints+4);
        _nearDistance = 10;
        _atDistance = 5;
        _closeDistance = 100;
        _moveAwayFromVehicleDist = 30;
        _returnToVehicleDist = 20;
        _maxDistFromVehicle = 0;
        _minTrackRouteDist = 50;
        _minTrackTime = 90;
        _updateNotificationFrequency = 5;
        _motionIsActive = NO;
        _tempDirectory = UserDefaults.defaults.nonBackedUpFilePath;
        _savedLocationsFile = [_tempDirectory stringByAppendingString:@"/savedlocations.bin"];
        InitProj4CoordConv (FALSE);
        NSString *soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/short_double_high.caf"];
        _leftSoundURL = [NSURL URLWithString:soundFile];
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/short_double_low.caf"];
        _rightSoundURL = [NSURL URLWithString:soundFile];
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/Tock.caf"];
        _gotGPSInputSoundURL1 = [NSURL URLWithString:soundFile];
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/ct-busy.caf"];
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/ct-path-ack.caf"];
        _gotGPSInputSoundURL3 = [NSURL URLWithString:soundFile];
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/jbl_confirm.caf"];
        _gotGPSInputSoundURL2 = [NSURL URLWithString:soundFile];
        _bearRightSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"BearRight" ofType:@"m4a"]];
        _right45SoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Right45Degrees" ofType:@"m4a"]];
        _right90SoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Right90Degrees" ofType:@"m4a"]];
        _right135SoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Right135Degrees" ofType:@"m4a"]];
        _bearLeftSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"BearLeft" ofType:@"m4a"]];
        _left45SoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Left45Degrees" ofType:@"m4a"]];
        _left90SoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Left90Degrees" ofType:@"m4a"]];
        _left135SoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Left135Degrees" ofType:@"m4a"]];
        _endOfRouteSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"EndOfRoute" ofType:@"m4a"]];
        _turnArroundSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"TurnArround" ofType:@"m4a"]];
        _offCourseSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"OffCourse" ofType:@"m4a"]];
        _endLocationTrackingSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"EndLocationTracking" ofType:@"m4a"]];
        _vehicleLocationSavedSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"VehicleLocationSaved" ofType:@"m4a"]];
        _startTrackingSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"StartLocationTracking" ofType:@"m4a"]];
        _startFollowingRouteSoundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"StartFollowingRoute" ofType:@"m4a"]];
        _currentGPSTickURL = _gotGPSInputSoundURL1;
        _currentGPSTickVol = 1;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
        if (error)
        {
            NSLog(@"Received error configuring audio: %@", error);
        }
        _ticPlayer = AVAudioPlayer.new;
        _messagePlayer = AVAudioPlayer.new;
        if (error)
        {
            NSLog(@"Player ERROR: %@", error.localizedDescription);
            return FALSE;
        }

    }
    return self;

}

- (void) dealloc
{
    //AudioServicesDisposeSystemSoundID(_lowSoundID);
    //AudioServicesDisposeSystemSoundID(_highSoundID);
}

- (void) startTrackingMotion
{
    NSString *path = [NSString stringWithFormat:@"%@/motion.bin", DOCUMENTS_FOLDER];
    [self createMotion:path];
    _savingMotion = TRUE;
    [self startUpdatingLocation];
    [self startMotionActivityMonitoring];
}

- (void) stopTrackingMotion
{
    [self closeMotion:TRUE];
    _savingMotion = FALSE;
}
- (BOOL) createMotion:(NSString *)path
{
    BOOL rtn = FALSE;
    _fidMotion = fopenGSSi (path.UTF8String,"w");
    return rtn;
}
- (BOOL) openMotion:(NSString *)path
{
    BOOL rtn = TRUE;
    _fidMotion = fopenGSSi (path.UTF8String,"rb");
    if (_fidMotion == 0)
        rtn = FALSE;
    return rtn;
}
- (void) closeMotion:(BOOL)update
{
    int type = 0;
    if (update)
        fwrite (&type,sizeof(type),1,_fidMotion);
    fcloseGSSi(_fidMotion);
}

- (void) saveMotionLocation:(LLPOINT *)pt
{
    int itime = NSDate.date.timeIntervalSinceReferenceDate;
    fwrite (&itime,sizeof(int),1,_fidMotion);
    int type = 1;
    fwrite (&type,sizeof(type),1,_fidMotion);
    fwrite (pt,sizeof(LLPOINT),1,_fidMotion);
    fwrite (&_GPSHeading,sizeof(_GPSHeading),1,_fidMotion);
    fwrite (&_GPSHeadingAccuracy,sizeof(_GPSHeadingAccuracy),1,_fidMotion);
    return;
}
- (void) saveMotionHeading:(CLHeading *)newHeading
{
    int itime = NSDate.date.timeIntervalSinceReferenceDate;
    fwrite (&itime,sizeof(int),1,_fidMotion);
    int type = 3;
    fwrite (&type,sizeof(type),1,_fidMotion);
    double trueHeading = newHeading.trueHeading;
    fwrite (&trueHeading,sizeof(double),1,_fidMotion);
    double headingAccuracy =  newHeading.headingAccuracy;
    fwrite (&headingAccuracy,sizeof(double),1,_fidMotion);
    return;
}
- (void) saveMotion:(GSSiMotionActivity *)activity
{
    int itime = NSDate.date.timeIntervalSinceReferenceDate;
    fwrite (&itime,sizeof(int),1,_fidMotion);
    int type = 2;
    fwrite (&type,sizeof(type),1,_fidMotion);
    fwrite (activity,sizeof(GSSiMotionActivity),1,_fidMotion);
    return;
}

- (int) getNextMotionTime
{
    int itime = 0;
    fread (&itime,sizeof(itime),1,_fidMotion);
    setCurrentTime(itime);
    return itime;
}
- (void) listMotion
{
    NSString *path = [NSString stringWithFormat:@"%@/motion.bin", DOCUMENTS_FOLDER];
    _motionRecordID = 0;
    _motionActivityManager = nil;
    int fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:path
                                                                         error:nil].fileSize;

    if ([self openMotion:path])
    {
        int nrecs = 0;
        while ([self getNextMotionTime])
        {
            [self getNextMotionRecord:TRUE];
            nrecs++;
        }
        [self closeMotion:FALSE];
        NSLog (@"End of list:%i records",nrecs);
        
    }
}
- (void) replayMotion
{
//    [self listMotion];
//    return;
    NSString *path = [NSString stringWithFormat:@"%@/motion.bin", DOCUMENTS_FOLDER];
    _motionRecordID = 0;
    int fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:path
                                                                         error:nil].fileSize;

    if ([self openMotion:path])
    {
        _motionActivityManager = nil;
        _replayTimeFactor = 0.2;
        _lastReplayMotionTime = [self getNextMotionTime];
        if (_lastReplayMotionTime)
        {
            _replayingMotion = TRUE;
            [self replayNextMotionRecord];
        }
        else
        {
            [self closeMotion:FALSE];
            _replayingMotion = FALSE;
            NSLog (@"Stop replaying motion");
        }
    }
}
- (void) replayNextMotionRecord
{
    [self getNextMotionRecord:FALSE];
    int itime = [self getNextMotionTime];
    if (itime)
    {
        double delay = _replayTimeFactor * ((double)itime - (double)_lastReplayMotionTime);
        //NSLog (@"%f",delay);
        _lastReplayMotionTime = itime;
        [self.motionReplayTimer invalidate];
        self.motionReplayTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                                  target:self
                                                                selector:@selector(replayNextMotionRecord)
                                                                userInfo:nil
                                                                 repeats:NO];
    }
    else
    {
        [self closeMotion:FALSE];
        _replayingMotion = FALSE;
    }
}
- (BOOL) getNextMotionRecord:(BOOL)list
{
    BOOL rtn = TRUE;
    static int wantRecID = 1484;
    int type;
    LLPOINT pt;
    fread (&type,sizeof(type),1,_fidMotion);
    _motionRecordID++;
    if (_motionRecordID == wantRecID)
        ii = 1;
    switch (type)
    {
        case 1:
            fread (&pt,sizeof(LLPOINT),1,_fidMotion);
            fread (&_GPSHeading,sizeof(_GPSHeading),1,_fidMotion);
            fread (&_GPSHeadingAccuracy,sizeof(_GPSHeadingAccuracy),1,_fidMotion);
            if (!list)
                [self newGPSLocation:pt
                         heading:_GPSHeading];
            break;
        case 2:
        {
            GSSiMotionActivity activity;
            fread (&activity,sizeof(GSSiMotionActivity),1,_fidMotion);
            if (list)
            {
                NSString * motionName = [self setMotionName:&activity];
                NSLog(@"%@:%i",motionName,(int)activity.confidence);
            }
            else
                [self processMotionActivity:&activity];
        }
            break;
        case 3:
        {
            double trueHeading;
            fread (&trueHeading,sizeof(double),1,_fidMotion);
            double headingAccuracy;
            fread (&headingAccuracy,sizeof(double),1,_fidMotion);
        }
            break;
        default:
            rtn = FALSE;
            break;
    }
    return rtn;
}

- (void) setDistanceFilter:(CLLocationDistance) dist
{
    _locationManager.distanceFilter = dist;
    _distanceFilter = dist;
}
- (void) setAllowsBackgroundLocationUpdates:(BOOL) set
{
    _locationManager.allowsBackgroundLocationUpdates = set;
}
- (void) setHeadingFilter:(CLLocationDegrees) headingFilter
{
    _locationManager.headingFilter = headingFilter;
}
- (void) setHeadingOrientation:(CLDeviceOrientation) headingOrientation
{
    _locationManager.headingOrientation = headingOrientation;
}
- (void) setDesiredAccuracy:(CLLocationAccuracy) desiredAccuracy
{
    _locationManager.desiredAccuracy = desiredAccuracy;
}
- (void) setActivityType:(CLActivityType) activityType
{
    _locationManager.activityType = activityType;
    [self startMotionActivityMonitoring];
}
- (void) setPausesLocationUpdatesAutomatically:(BOOL) pausesLocationUpdatesAutomatically
{
    _locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
}

- (NSString*) setMotionName:(GSSiMotionActivity *)activity
{
    static NSString * lastHigh = @"Unknown";
    NSString *motionName;
    if (activity->walking)
    {
        motionName = @"Walking";
    }
    else if (activity->running)
        motionName = @"Running";
    else if (activity->automotive)
    {
        motionName = @"Vehicle";
    }
    else if (activity->cycling)
    {
        _currentSpeed = [self GPSSpeedFromPoints];
        if (_currentSpeed < _maxWalkingSpeed)
            motionName = @"Walking";
        else
            motionName = @"Vehicle";
    }
    else if (activity->unknown)
        motionName = @"Unknown";
    else if (activity->stationary)
        motionName = lastHigh;
    else
    {
        _currentSpeed = [self GPSSpeedFromPoints];
        if (_currentSpeed < 0)
            motionName = @"Unknown";
        else if (_currentSpeed < _maxWalkingSpeed)
            motionName = @"Walking";
        else
            motionName = @"Vehicle";
        activity->confidence = CMMotionActivityConfidenceLow;
    }

    if (activity->confidence == CMMotionActivityConfidenceHigh)
    {
        if (![lastHigh isEqual:motionName])
            _numLastPoints = 0;
        lastHigh = motionName;
    }
    return motionName;
}
- (void) processMotionActivity:(GSSiMotionActivity *)activity
{
    ii = _motionRecordID;
    NSString * motionName;
    static int numVehicleLow = 0;
    
   //NSLog(@"Motion activity detected");

    if (_savingMotion)
    {
        [self saveMotion:activity];
    }
    motionName = [self setMotionName:activity];

/*    if (activity->confidence == CMMotionActivityConfidenceLow)
    {
        NSLog (@"Skip %@ %i",motionName,(int)activity->confidence);
        return;
    }*/
    self.currentMotionActivity = motionName;
    
    if (activity->unknown)
    {
        NSLog (@"Skip Unknown 1");
        return;
    }

    if (activity->confidence == CMMotionActivityConfidenceLow)
        self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":low"];
    else if (activity->confidence == CMMotionActivityConfidenceMedium)
        self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":medium"];
    else if (activity->confidence == CMMotionActivityConfidenceHigh)
        self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":high"];
    else
        self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":unknown"];
    NSLog (@"%i %@",_motionRecordID,_currentMotionActivity);
    if ([self.currentMotionActivity isEqual:@"Vehicle:low"])
    {
        numVehicleLow++;
    }
    else
        numVehicleLow = 0;
    if (numVehicleLow > 2 ||
        [self.currentMotionActivity isEqual:@"Vehicle:high"] ||
        [self.currentMotionActivity isEqual:@"Vehicle:medium"])
    {
        LLPOINT pt = {0,0};
        CRAPI.sharedInstance.currentVehicleLocation = pt;

        numVehicleLow = 0;
        _vehicleCoordinates = NSMutableArray.new;
        DPOINT dpnt = LLPointToDPoint (CRAPI.sharedInstance.currentGPSLocation);
        DPoint * dpt = [DPoint fromDPOINT:&dpnt];
        [_vehicleCoordinates addObject:dpt];
        if (CRAPI.sharedInstance.amBuildingTrackRoute)
        {
            HuntingData *hd = HuntingData.new;
            int numPointsInRoute = (int) CRAPI.sharedInstance.currentTrackRoute.count;
            if (_walkingCoordinates > 1)
            {
                int numPointsToRemove = _walkingCoordinates / 2;
                if (numPointsInRoute > numPointsToRemove)
                {
                    while (numPointsToRemove--)
                        [CRAPI.sharedInstance.currentTrackRoute removeLastObject];
                    numPointsInRoute = (int) CRAPI.sharedInstance.currentTrackRoute.count;
                }
            }

            [hd saveTrackRoute:CRAPI.sharedInstance.currentTrackRoute];
            [CRAPI.sharedInstance clearTrackRoute];
            CRAPI.sharedInstance.amBuildingTrackRoute = FALSE;
            [self playRecording:_endLocationTrackingSoundURL];
        }
        _walkingCoordinates = -1;
    }
    else if ([self.currentMotionActivity isEqual:@"Walking:high"]||
             [self.currentMotionActivity isEqual:@"Walking:medium"])
    {
        if (_vehicleCoordinates && _vehicleCoordinates.count > 0)
            [self setVehicleLocation];
        _walkingCoordinates = 0;
    }
    _previousMotionActivity = _currentMotionActivity;

}
- (void)startMotionActivityMonitoring
{
    // create the motion activity handler
    CMMotionActivityHandler motionActivityHandler = ^(CMMotionActivity *activity) {
        GSSiMotionActivity myActivity;
        
        myActivity.confidence = activity.confidence;
        myActivity.startTime = activity.startDate.timeIntervalSinceReferenceDate;
        myActivity.unknown = activity.unknown;
        myActivity.running = activity.running;
        myActivity.stationary = activity.stationary;
        myActivity.walking = activity.walking;
        myActivity.automotive = activity.automotive;
        myActivity.cycling = activity.cycling;

        [self processMotionActivity:&myActivity];
    };

    // check to see if the motion activity manager exists
    if ([CMMotionActivityManager isActivityAvailable])
    {
        CMAuthorizationStatus status = [CMMotionActivityManager authorizationStatus];
        _motionActivityManager = CMMotionActivityManager.new;

        if ([CMMotionActivityManager authorizationStatus] == CMAuthorizationStatusAuthorized)
        {

            if (_motionActivityManager) {
                // if so, start monitoring activity
                // notice that we add updates to the mainQueue. This will call your handler on the main thread
                [_motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:motionActivityHandler];
                _motionIsActive = YES;
            }
        }
    }
}

- (void)pauseMotionActivityMonitoring
{
    if (_motionActivityManager) {
        // if so, start monitoring activity
        // notice that we add updates to the mainQueue. This will call your handler on the main thread
        [_motionActivityManager stopActivityUpdates];
    }
    _motionIsActive = NO;
}

- (NSString *) getCurrentMotionActivity
{
    NSString * rtn = @"";
    if (_motionIsActive && CRAPI.sharedInstance.displayMotion)
        rtn = _currentMotionActivity;
    return rtn;
}
- (void)startUpdatingLocation
{
    if (_inSimulationMode)
    {
        [_simulationTimer invalidate];
        _simulationTimer = [NSTimer scheduledTimerWithTimeInterval:_simulationInterval
                                                      target:self
                                                    selector:@selector(simulateGPS)                                                            userInfo:nil
                                                     repeats:YES];

    }
    else
        [_locationManager startUpdatingLocation];
    _numLastPoints = 0;
}
- (void)startUpdatingHeading
{
    [_locationManager startUpdatingHeading];
}
- (void)stopUpdatingLocation
{
    if (_inSimulationMode)
    {
        [_simulationTimer invalidate];
    }
    else
        [_locationManager stopUpdatingLocation];
    [self setOffCourseSound:0
                 withVolume:0];
    _numLastPoints = 0;
}
- (void)stopUpdatingHeading
{
    [_locationManager stopUpdatingHeading];
}
- (void) startSimulation
{
    [_simulationTimer invalidate];
    _numLastPoints = 0;
    if (CRAPI.sharedInstance.currentTrackRoute.count > 1)
    {
        CRAPI.sharedInstance.locationTrackingEnabled = TRUE;
        _inSimulationMode = YES;
        [self pointInMessageList:-1];
        _currentSimulationIndex = 0;
        _simulationTimer = [NSTimer scheduledTimerWithTimeInterval:_simulationInterval
                                                      target:self
                                                    selector:@selector(simulateGPS)                                                            userInfo:nil
                                                     repeats:YES];
    }

}

- (void) markVehicleLocation
{
    NSLog (@"Mark Vehicle Location");
    _needToSetVehicleLocation = 2;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}
- (void) stopSimulation
{
    if (_inSimulationMode)
    {
        [_simulationTimer invalidate];
        _inSimulationMode = NO;
    }
}

- (void) startSimulationAt:(LLPOINT)startPoint
{
    int nearPoint = 0;
    int index = 0;
    double nearDist = DBL_MAX;
    _numLastPoints = 0;
    if (_simulationTimer)
        [_simulationTimer invalidate];
    [self pointInMessageList:-1];
    for (TrackRoutePoint *tpt in CRAPI.sharedInstance.currentTrackRoute)
    {
        double dist = ArcDistanceLL(tpt.latlon, startPoint);
        if (dist < nearDist)
        {
            nearDist = dist;
            nearPoint = index;
        }
        index++;
    }
    if (CRAPI.sharedInstance.currentTrackRoute.count > 1)
    {
        CRAPI.sharedInstance.locationTrackingEnabled = TRUE;
        _inSimulationMode = YES;
        _currentSimulationIndex = nearPoint;
        _simulationTimer = [NSTimer scheduledTimerWithTimeInterval:_simulationInterval
                                                      target:self
                                                    selector:@selector(simulateGPS)                                                            userInfo:nil
                                                     repeats:YES];
    }

}
- (void) simulateGPS
{
    if (_currentSimulationIndex < CRAPI.sharedInstance.currentTrackRoute.count)
    {
        TrackRoutePoint *tpt = CRAPI.sharedInstance.currentTrackRoute[_currentSimulationIndex++];
        [self newGPSLocation:tpt.latlon
                     heading:tpt.GPSHeading];
    }
    else
    {
        [_simulationTimer invalidate];
        _inSimulationMode = NO;
        [self setOffCourseSound:0
                     withVolume:0];


    }
    return;
}

- (void) setDelegate:(id<TrackLocationManagerDelegate>)delegate
{
    _delegate = delegate;
}

- (void) clearTrackRoute
{
    [CRAPI.sharedInstance clearTrackRoute];
}

- (void) setVehicleLocation
{
    HuntingData *hd = HuntingData.new;
    [self clearTrackRoute];
    CRAPI.sharedInstance.amBuildingTrackRoute = TRUE;
    [hd deleteWaypointsOfType:@"Vehicle"];
    LLPOINT pnt = _currentPoint;
    if (_vehicleCoordinates)
    {
        int midCoorIndex = (int)_vehicleCoordinates.count / 2;
        DPoint * midCoor = _vehicleCoordinates[midCoorIndex];
        DPOINT dpt = [midCoor toDPOINT];
        pnt = DPointToLLPoint(dpt);
        _vehicleCoordinates = nil;
    }
    [hd addWaypoint:@"V" type:@"Vehicle" latlon:pnt description:@"" displayOnCompass:YES];
    CRAPI.sharedInstance.currentVehicleLocation = pnt;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMarkVehicleLocation:)])
    {
        [self.delegate didMarkVehicleLocation:self];
    }
    [self playRecording:_vehicleLocationSavedSoundURL];
}

- (void) newGPSLocation:(LLPOINT)pt
                heading:(double)GPSHeading
{
    static int turnArroundCount = 0;
//    NSLog (@"GPS input recieved");
    CRAPI.sharedInstance.currentGPSLocation = pt;
    _currentPoint = pt;
    _atUTM = LLPointToDPoint (pt);
    ConvertCoord(&_atUTM, LATLONPROJECTION, UTM15PROJECTION);
    [self addPointToLastPoints];
    _currentGPSHeading = [self GPSHeadingFromPoints];
    [self saveLocation];
    
    if (_vehicleCoordinates)
    {
        DPOINT dpnt = LLPointToDPoint (pt);
        DPoint * dpt = [DPoint fromDPOINT:&dpnt];
        [_vehicleCoordinates addObject:dpt];
    }
    if (_walkingCoordinates >= 0)
        _walkingCoordinates++;
    if (_needToSetVehicleLocation)
    {
        if (_needToSetVehicleLocation-- <= 1)
            [self setVehicleLocation];
    }
 
    
    if (self.delegate)
        [self.delegate locationManager:self didUpdateLocations:_currentPoint
                            GPSHeading:GPSHeading];
    if (_needToInitiateRoute)
    {
        _fromPoint = _currentPoint;
        [self initiateRoute];
    }
    [self setOffCourseSound:0];

    if (CRAPI.sharedInstance.inFollowingRouteMode)
    {
        INT64 destRoutePoint = [self computeNextRoutePoint];
        if (!CRAPI.sharedInstance.inFollowingRouteMode)
            return;
        if (_atEndOfRoute)
        {
            [self playRecording:_endOfRouteSoundURL];
            [self exitRouteMode];
            if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRefreshScreen:)])
            {
                [self.delegate shouldRefreshScreen:self];
            }
            return;
        }
        else if (destRoutePoint && destRoutePoint != _currentRoutePointNumber)
        {
            _currentRoutePointNumber = destRoutePoint;
            if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRefreshScreen:)])
            {
                [self.delegate shouldRefreshScreen:self];
            }
            [self turnAlert];
        }
        else if (_crossedRouteSegment && _needTurnAdvice)
            [self turnAlert];
        if (_currentGPSHeading >= 0 && (_turnDegrees >= 150 || _turnDegrees <= -150))
        {
            if (turnArroundCount++ == 3)
            {
                int inow = getCurrentTime();
                if (!_lastTurnAroundTime || (inow - _lastTurnAroundTime) > 30)
                {
                    [self playRecording:_turnArroundSoundURL];
                    _lastTurnAroundTime = inow;
                }
            }
        }
        else
            turnArroundCount = 0;
    }
    if ((CRAPI.sharedInstance.inFollowingRouteMode || CRAPI.sharedInstance.amBuildingTrackRoute) &&
        !(_numUpdates++ % _updateNotificationFrequency))
    {
        [self playRecording:_currentGPSTickURL
                     volume:_currentGPSTickVol];
        
    }
    return;
}

-(void) initiateRoute
{
    _needToInitiateRoute = FALSE;
    _routeStartPoint = _atUTM;
    _lastMessageIntPoint.x = 0;
    self.distanceFilter = kCLDistanceFilterNone;
    CRAPI.sharedInstance.inFollowingRouteMode = YES;
    [self pointInMessageList:-1];
    [self playRecording:_startFollowingRouteSoundURL];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didInitiateRoute:)])
    {
        [self.delegate didInitiateRoute:self];
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count > 0 && !_inSimulationMode && !_replayingMotion)
    {
        CLLocation * loc = locations.lastObject;
        LLPOINT pt;
        pt.lat = loc.coordinate.latitude;
        pt.lon = loc.coordinate.longitude;
        _GPSHeading = loc.course;
        _GPSHeadingAccuracy = loc.courseAccuracy;
        if (_savingMotion)
            [self saveMotionLocation:&pt];
        [self newGPSLocation:pt
                     heading:loc.course];
    }
    return;
}

- (void) requestWhenInUseAuthorization
{
    [_locationManager requestWhenInUseAuthorization];
}
- (void)requestLocation
{
    [_locationManager requestLocation];
}
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    if (_savingMotion)
        [self saveMotionHeading:newHeading];

    if (self.delegate)
        [self.delegate locationManager:self didUpdateHeading:newHeading];
    return;
}

- (void) saveLocation
{
    TrackRoutePoint *trackRoutePoint = TrackRoutePoint.new;
    trackRoutePoint.time = NSDate.timeIntervalSinceReferenceDate;
    trackRoutePoint.latlon = _currentPoint;
    trackRoutePoint.GPSHeading = _currentGPSHeading;
    
    if (CRAPI.sharedInstance.currentRoute.count > 1 && !CRAPI.sharedInstance.inFollowingRouteMode && CRAPI.sharedInstance.autoStartRoute)
    {
        UserWaypoint* waypoint = CRAPI.sharedInstance.currentRoute[0];
        double dist = ArcDistanceLL(trackRoutePoint.latlon,waypoint.latlon);
        if (dist < _nearDistance)
        {
            [self startRoute];
            if (CRAPI.sharedInstance.waitingToMoveAwayFromVehicle)
                [self movedAwayFromVehicle];
        }
    }

    int st = [self addPointToTrackRoute: trackRoutePoint];
    if (st > 0)
    {
        if (st == 2)
        {
            HuntingData *hd = HuntingData.new;
            [hd saveTrackRoute:CRAPI.sharedInstance.currentTrackRoute];
            [self clearTrackRoute];
            CRAPI.sharedInstance.amBuildingTrackRoute = FALSE;
            [self playRecording:_endLocationTrackingSoundURL];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(trackRouteChanged:)])
        {
            [self.delegate trackRouteChanged:self];
        }
    }

}

-(void) startSavingLocations
{
    _amSavingLocations = TRUE;
    _routeWasSaved = FALSE;
}
-(NSArray *) retrieveSavedLocations
{
    _amSavingLocations = FALSE;
    NSMutableArray * array=NSMutableArray.new;
    /*
    FILE *Fid = fopenGSSi(_savedLocationsFile.cString,"r");
    
    if (Fid != NULL)
    {
        RoutePointStruct routePoint;
        while (BigReadF(Fid, (HPSTR)&routePoint ,sizeof(RoutePointStruct)) == sizeof(RoutePointStruct))
        {
            TrackRoutePoint * pt = TrackRoutePoint.new;
            pt.latlon = routePoint.pt;
            pt.time = routePoint.time;
            pt.GPSHeading = routePoint.GPSHeading;
            [array addObject:pt];
        }
        fcloseGSSi(Fid);
        NSError *err = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:_savedLocationsFile error:&err];
    }*/

    return array;
}

- (void) addPointToLastPoints
{
    int itime = getCurrentTime ();
    
    if (_numLastPoints < _maxLastPoints)
    {
        _pLastPointsTime[_numLastPoints] = itime;
        _pLastPoints[_numLastPoints++] = _atUTM;
    }
    else
    {
        for (int i = 1;i < _numLastPoints; i++)
        {
            _pLastPointsTime[i-1] = _pLastPointsTime[i];
            _pLastPoints[i-1] = _pLastPoints[i];
        }
        _pLastPointsTime[_maxLastPoints -1] = itime;
        _pLastPoints[_maxLastPoints -1] = _atUTM;
    }
   
}
-(int) addPointToTrackRoute:(TrackRoutePoint *) routePoint
{
    //rtn = 1 means point added
    //rtn = 2 means point added and route should be saved
    int rtn = 0;
    double dist;
    if (CRAPI.sharedInstance.amBuildingTrackRoute || CRAPI.sharedInstance.waitingToMoveAwayFromVehicle)
    {

        BOOL addIt = TRUE;
        int npt = (int)CRAPI.sharedInstance.currentTrackRoute.count;
        if (npt)
        {
            TrackRoutePoint *lastPoint = CRAPI.sharedInstance.currentTrackRoute[npt-1];
            dist = ArcDistanceLL(routePoint.latlon,lastPoint.latlon);
            if (dist < 1)
                addIt = FALSE;
        }
        else
            _maxDistFromVehicle = 0;
        if (addIt)
        {
            rtn = 1;
            if (CRAPI.sharedInstance.amBuildingTrackRoute)
                [CRAPI.sharedInstance.currentTrackRoute addObject:routePoint];
            if (CRAPI.sharedInstance.currentVehicleLocation.lon != 0)
            {
                dist = ArcDistanceLL(routePoint.latlon,CRAPI.sharedInstance.currentVehicleLocation);
                _maxDistFromVehicle = max (_maxDistFromVehicle,dist);
                if (CRAPI.sharedInstance.waitingToMoveAwayFromVehicle)
                {
                    if (dist > _moveAwayFromVehicleDist)
                    {
                        [self movedAwayFromVehicle];
                    }
                }
                else if (dist < _returnToVehicleDist && CRAPI.sharedInstance.amBuildingTrackRoute && _maxDistFromVehicle > _minTrackRouteDist)
                {
                    int trackTime = getCurrentTime() - CRAPI.sharedInstance.trackRouteStartTime;
                    NSLog (@"Track time:%i",trackTime);
                    if (trackTime > _minTrackTime)
                    {
                        LLPOINT pt = {0,0};
                        CRAPI.sharedInstance.currentVehicleLocation = pt;
                        rtn = 2;
                    }
                }
            }
        }
    }
    return rtn;
}

- (void) movedAwayFromVehicle
{
    CRAPI.sharedInstance.waitingToMoveAwayFromVehicle = NO;
    CRAPI.sharedInstance.locationTrackingEnabled = YES;
    CRAPI.sharedInstance.amBuildingTrackRoute = TRUE;
    [self clearTrackRoute];
    [self playRecording:_startTrackingSoundURL];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didInitiateTracking:)])
    {
        [self.delegate didInitiateTracking:self];
    }
}

- (double) GPSHeadingFromPoints
{
    double A, B, maxDiff=0;
    long locOfMaxDiff;
    if (_numLastPoints < 3)
        return -1;
    double xmin = UINT_MAX, xmax = -UINT_MAX;
    for (int i=0;i<_numLastPoints;i++)
    {
        if (_pLastPoints[i].x < xmin)
            xmin = _pLastPoints[i].x;
        if (_pLastPoints[i].x > xmax)
            xmax = _pLastPoints[i].x;
    }
    if (LINFIT(_pLastPoints, _numLastPoints, &A, &B, &maxDiff, &locOfMaxDiff))
    {
        DPOINT pPoints[2];
        pPoints[0].x = _pLastPoints[0].x;
        pPoints[0].y = A + pPoints[0].x * B;
        pPoints[1].x = _pLastPoints[_numLastPoints-1].x;
        pPoints[1].y = A + pPoints[1].x * B;
        double AZ = getazdp(&pPoints[0], &pPoints[1]);
        return AZMToHeading(AZ);
    }
    return -1;
}

- (float) GPSSpeedFromPoints
{
    if (_numLastPoints < 3)
        return -1;
    double dist = ldistp(_pLastPoints[0],_pLastPoints[_numLastPoints-1]);
    int itime = _pLastPointsTime[_numLastPoints-1] - _pLastPointsTime[0];
    if (itime > 0)
    {
        float speed = dist/itime;
        return speed;
    }
    return -1;
}

-(void) setOffCourseSound:(int) opt
{
    [self setOffCourseSound:opt
                 withVolume:1];
}
-(void) setOffCourseSound:(int) opt
               withVolume:(float)vol
    {

    switch (opt)
    {
        default:
        case 0:
            _currentGPSTickVol = 1;
            if (CRAPI.sharedInstance.inFollowingRouteMode)
            {
                if (CRAPI.sharedInstance.amBuildingTrackRoute)
                    _currentGPSTickURL = _gotGPSInputSoundURL3;
                else
                    _currentGPSTickURL = _gotGPSInputSoundURL1;
            }
            else if (CRAPI.sharedInstance.amBuildingTrackRoute)
                _currentGPSTickURL = _gotGPSInputSoundURL2;
            else
                _currentGPSTickVol = 0;
            break;
        case RIGHT: //go left
            _currentGPSTickURL = _rightSoundURL;
            _currentGPSTickVol = vol;
            _goLeft = TRUE;
            break;
        case LEFT: //go right
            _currentGPSTickURL = _leftSoundURL;
            _currentGPSTickVol = vol;
            break;
    }
    return;

}
-(void) offCourseNotificationPlay:(NSTimer *) timer
{
    return;
    if (_goLeft)
    {
        //AudioServicesPlaySystemSound(_lowSoundID);
        [self performSelector:@selector(vibrate)
                   withObject:nil
                   afterDelay:0.5];
        [self performSelector:@selector(vibrate)
                   withObject:nil
                   afterDelay:2];
        [self performSelector:@selector(vibrate)
                   withObject:nil
                   afterDelay:3];
    }
    else
    {

        //AudioServicesPlaySystemSound(_highSoundID);
        [self performSelector:@selector(vibrate)
                   withObject:nil
                   afterDelay:0.5];
        [self performSelector:@selector(vibrate)
                   withObject:nil
                   afterDelay:1.5];
        [self performSelector:@selector(vibrate)
                   withObject:nil
                   afterDelay:3];
    }
}
-(void) vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (BOOL) pointInMessageList:(INT64)pointID
{
    BOOL rtn = FALSE;
    if (pointID == -1)
        _pointsInMessageList = NSMutableArray.new;
    else
    {
        for (NSNumber *pid in _pointsInMessageList)
        {
            if (pid.longLongValue == pointID)
            {
                rtn = TRUE;
                break;
            }
        }
        if (!rtn)
        {
            NSNumber *nsnum = [NSNumber numberWithLongLong:pointID];
            [_pointsInMessageList addObject:nsnum];
        }
    }
    return rtn;
}
- (void) turnAlert
{
    if (_atEndOfRoute)
    {
        [self playRecording:_endOfRouteSoundURL];
        [self exitRouteMode];
    }
    else if (!_crossedRouteSegment && [self pointInMessageList:CRAPI.sharedInstance.currentSelectedWaypoint])
    {
        return;
    }
    else
    {
        double ch = _currentGPSHeading;
        double nextPt = _headingToNextPoint;
        if (_turnDegrees < -5 && _turnDegrees > -45 * 0.5)
            [self playRecording:_bearRightSoundURL];
        else if (_turnDegrees > -45 * 1.5 && _turnDegrees < -45 * 0.5)
            [self playRecording:_right45SoundURL];
        else if (_turnDegrees > -45 * 2.5 && _turnDegrees < -45 * 1.5)
            [self playRecording:_right90SoundURL];
        else if (_turnDegrees < -45 * 2.5)
            [self playRecording:_right135SoundURL];
        else if (_turnDegrees > 5 && _turnDegrees < 45 * 0.5)
            [self playRecording:_bearLeftSoundURL];
        else if (_turnDegrees < 45 * 1.5 && _turnDegrees > 45 * 0.5)
            [self playRecording:_left45SoundURL];
        else if (_turnDegrees < 45 * 2.5 && _turnDegrees > 45 * 1.5)
            [self playRecording:_left90SoundURL];
        else if (_turnDegrees > 45 * 2.5)
            [self playRecording:_left135SoundURL];
        _crossedRouteSegment = FALSE;
        _lastSide = 0;
        _needTurnAdvice = FALSE;
    }
}
- (void) startRoute
{
    [self pointInMessageList:-1];
    HuntingData *hd = HuntingData.new;
    CRAPI.sharedInstance.currentRoute = [hd getWaypointsOfType:@"RoutePoint"];
    UserWaypoint* waypoint = CRAPI.sharedInstance.currentRoute[0];
    UserWaypoint* nextwaypoint = CRAPI.sharedInstance.currentRoute[1];
    CRAPI.sharedInstance.currentSelectedWaypoint = waypoint.refno;
    _firstRoutePoint = waypoint.latlon;
    if (!CRAPI.sharedInstance.locationTrackingEnabled)
    {
        self.distanceFilter = kCLDistanceFilterNone;
        [_locationManager startUpdatingLocation];
        CRAPI.sharedInstance.locationTrackingEnabled = TRUE;
        _needToInitiateRoute = TRUE;
    }
    else
    {
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _fromPoint = _currentPoint;
        _needToInitiateRoute = TRUE;
    }
}

- (void) exitRouteMode
{
    CRAPI.sharedInstance.inFollowingRouteMode = FALSE;
    CRAPI.sharedInstance.currentSelectedWaypoint = -1;

}

-(void) createTwoPointRoute:(LLPOINT)fromLL
                    toLL:(LLPOINT)toLL
{
    CRAPI.sharedInstance.currentRoute = NSMutableArray.new;
    CGPoint llp = {0};
    llp.y = fromLL.lat;
    llp.x = fromLL.lon;
    DPOINT pt1 = CGPointToDPOINT (llp);
    NSNumber *routePoint = [NSNumber valueWithCGPoint:llp];
    [CRAPI.sharedInstance.currentRoute addObject:routePoint];
    llp.y = toLL.lat;
    llp.x = toLL.lon;
    DPOINT pt2 = CGPointToDPOINT (llp);
    routePoint = [NSNumber valueWithCGPoint:llp];
    [CRAPI.sharedInstance.currentRoute addObject:routePoint];
    double az = getazd (pt1,pt2);
    double azLL = getazLL (fromLL,toLL);
    double bearing = LTWOPI (HALFPI - az)*DEGRAD;
    double bearingLL = LTWOPI (HALFPI - azLL)*DEGRAD;
    CRAPI.sharedInstance.routeBearing = [NSNumber numberWithDouble:bearingLL];

    return;
}
static double HeadingFromAZ (double az)
{
    double heading = az + HALFPI;
    heading = LTWOPI (heading);
    return heading;
}

-(INT64) computeNextRoutePoint
{
    BOOL rtn = FALSE;
    HuntingData *hd = HuntingData.new;
    DPOINT RoutePoint[2];
    DPOINT IntPoint;
    DPOINT routeEndPoint;
    
    if (!CRAPI.sharedInstance.inFollowingRouteMode)
        return -1;
    RoutePoint[0] = _routeStartPoint;

    INT64 destinationRoutePointNumber = 0;
    double minDist = DBL_MAX;
    _atEndOfRoute = FALSE;
    double AZ1=0, AZ2=0, AZ3=0;
    double pctToInt = 0;
    int legNum = 0;
    _turnDegrees = 0;
    NSArray <UserWaypoint*> *routePointArray = CRAPI.sharedInstance.currentRoute;
    if (routePointArray.count)
    {
        UserWaypoint *wp = routePointArray.lastObject;
        routeEndPoint = wp.UTM;
    }
    int index = 0;
    for (UserWaypoint *wp in routePointArray)
    {
        index++;
        INT64 iref = CRAPI.sharedInstance.currentSelectedWaypoint;
        if (iref == wp.refno && index < routePointArray.count)
        {
            double distToDest = ldistp(_atUTM, wp.UTM)/ METERS_PER_YARD;
            if (distToDest < _atDistance/2)
                _atUTM = wp.UTM;
        }
    }
    CRAPI.sharedInstance.currentSelectedWaypoint = -1;
    for (UserWaypoint *wp in routePointArray)
    {
        legNum++;
        _atEndOfRoute = FALSE;
        RoutePoint[1] = wp.UTM;
        AZ2 = getazdp (&RoutePoint[0],&RoutePoint[1]);
        AZ3 = getazdp (&_atUTM,&RoutePoint[1]);
        int leftOrRight=0;
        if (GetPerpendicularIntersect (&_atUTM,RoutePoint,&IntPoint,TRUE,&leftOrRight))
        {
            double offDist = ldistpp (&_atUTM,&IntPoint);
            if (offDist <= minDist)
            {
                _fromUTM = RoutePoint[0];
                _toUTM = wp.UTM;
                AZ1 = getazdp (&_atUTM,&IntPoint);
                _leftOrRight = leftOrRight;
                minDist = offDist;
                _distToRoute = minDist / METERS_PER_YARD;
                CRAPI.sharedInstance.currentSelectedWaypoint = wp.refno;
                destinationRoutePointNumber = wp.refno;
                if (_currentGPSHeading >= 0)
                {
                    double gpsAz = HeadingToAzimuth (_currentGPSHeading);
                    _turnDegrees = DeltaAZD(gpsAz, AZ3);
                    _headingToNextPoint = HeadingFromAZ(AZ3) * RADtoDEG;
                    _turnDegrees *= RADtoDEG;
                }
                if (legNum >= routePointArray.count)
                {
                    double d = ldistpp (&routeEndPoint,&IntPoint);
                    if (d < _atDistance)
                        _atEndOfRoute = TRUE;
                }
                else
                    _atEndOfRoute = FALSE;
                _minDistIntPoint = IntPoint;
                double seglen = ldistpp (&RoutePoint[0],&RoutePoint[1]);
                double dtoint = ldistpp (&RoutePoint[0],&IntPoint);
                pctToInt = dtoint / seglen;
                rtn = TRUE;
            }
        }
        RoutePoint[0] = RoutePoint[1];
    }
    if (rtn)
    {
        float vol;
        _offDist = minDist;
        if (_lastSide && _leftOrRight != _lastSide)
        {
            if (_needTurnAdvice)
            {
                if (pctToInt >= 0.25 && pctToInt <= 0.75)
                    _crossedRouteSegment = TRUE;

            }
        }
        _lastSide = _leftOrRight;
        _offDist /= METERS_PER_YARD;
        if (_offDist > _notifyDist * 6)
        {
            [self playRecording:_offCourseSoundURL];
            [self exitRouteMode];
            return -1;
        }
        if (_offDist > _notifyDist)
        {
            vol = (_offDist - _notifyDist) / _offCourseDist;
            if (_offDist > _notifyDist * 5)
                _timerDelay = _minTimerDelay;
            else if (_offDist > _notifyDist * 2)
                _timerDelay = _minTimerDelay * 2;
            else
                _timerDelay = _maxTimerDelay;
            [self setOffCourseSound:_leftOrRight
                         withVolume:vol];
            if (_offDist > _notifyDist * 2)
                _needTurnAdvice = TRUE;
        }
        else
            [self setOffCourseSound:0
                         withVolume:0];

    }
    else
        [self setOffCourseSound:0
                     withVolume:0];


    return destinationRoutePointNumber;
}
-(Bool) locationManagerShouldDisplayHeadingCalibration:(TrackLocationManager*)manager
{
    return true;
}

-(void) locationManager:(CLLocationManager *) manager
       didFailWithError:(NSError*) error
{
    NSLog(@"Location manager error");
}

-(void) locationManager:(CLLocationManager *)manager
 didChangeAuthorization:(CLAuthorizationStatus)status
{
    NSLog(@"Location manager changed autorization");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _isPlayingAudio = FALSE;
    if (_playNextURL)
        [self playRecording:_playNextURL];
}

- (BOOL)playRecording:(NSURL*)url
               volume:(float)vol
{
    if (vol == 0)
        return FALSE;
    if (!_isPlayingAudio)
    {
        
        NSError *error;
        
        if (url == _gotGPSInputSoundURL2)
            vol *= 0.25;
       
        _ticPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [_ticPlayer prepareToPlay];
        [_ticPlayer setVolume: vol];
        [_ticPlayer setDelegate: self];

        [_ticPlayer play];
        
        return TRUE;
    }
    return FALSE;
}

- (void) playRecording:(NSURL*)url
{
    NSError *error = nil;
    float vol = 1;
    ii = _motionRecordID;
    if (_isPlayingAudio)
        _playNextURL = url;
    else
    {
        _playNextURL = nil;
        _messagePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [_messagePlayer prepareToPlay];
        [_messagePlayer setVolume: vol];
        [_messagePlayer setDelegate: self];
        _isPlayingAudio = TRUE;
        [_messagePlayer play];
    }
    _lastMessageIntPoint = _minDistIntPoint;
}

@end

