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

@interface TrackLocationManager ()

@property CLLocationManager *locationManager;
@property int minTimerDelay,maxTimerDelay;
@property int timerDelay;
@property int lastDriveTime;
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
@property NSTimer *drivingTimer, *walkingTimer;
@property int numUpdates;
@property BOOL atEndOfRoute;
@property double turnDegrees;
@property int numLastPoints;
@property int maxLastPoints;
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
@property int minTrackTime;
@property LLPOINT lastVehicleLocation;

@end

@implementation TrackLocationManager

-(id) init
{
    self = [super init];
    
    if (self)
    {
        NSError *error = nil;
        
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
        _nearDistance = 10;
        _atDistance = 5;
        _closeDistance = 100;
        _moveAwayFromVehicleDist = 35;
        _returnToVehicleDist = 25;
        _minTrackTime = 60 * 5;

        _updateNotificationFrequency = 5;
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
- (void)startMotionActivityMonitoring
{
    // create the motion activity handler
    CMMotionActivityHandler motionActivityHandler = ^(CMMotionActivity *activity) {
        NSLog(@"Motion activity detected");
        self.currentMotionActivity = @"Other";
        if (activity.stationary)
            self.currentMotionActivity = @"Stationary";
        else if (activity.walking)
            self.currentMotionActivity = @"Walking";
        else if (activity.running)
            self.currentMotionActivity = @"Running";
        else if (activity.automotive)
            self.currentMotionActivity = @"Vehicle";
        else if (activity.unknown)
            self.currentMotionActivity = @"Unknown";
        
        if (activity.confidence == CMMotionActivityConfidenceLow)
            self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":low"];
        else if (activity.confidence == CMMotionActivityConfidenceMedium)
            self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":medium"];
        else if (activity.confidence == CMMotionActivityConfidenceHigh)
            self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":high"];
        else
            self.currentMotionActivity = [self.currentMotionActivity stringByAppendingString:@":unknown"];
        
        if ([self.currentMotionActivity isEqual:@"Vehicle:high"])
        {
            if (![self.previousMotionActivity isEqual:self.currentMotionActivity])
            {
                [self.drivingTimer invalidate];
                self.lastDriveTime = 0;
                self.drivingTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                     target:self
                                                                   selector:@selector(markLastDriveTime:)
                                                                   userInfo:nil
                                                                    repeats:YES];
            }
        }
        else if ([self.currentMotionActivity isEqual:@"Walking:high"])
        {
            if (![self.previousMotionActivity isEqual:self.currentMotionActivity])
            {
                [self.walkingTimer invalidate];
                self.walkingTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                     target:self
                                                                   selector:@selector(markLastWalkingTime:)
                                                                   userInfo:nil
                                                                    repeats:YES];
            }
        }
        else if ([self.currentMotionActivity isEqual:@"Vehicle:high"])
        {
        }
        else
        {
            if ([self.previousMotionActivity isEqual:@"Vehicle:high"])
                self.lastVehicleLocation = CRAPI.sharedInstance.currentGPSLocation;
;
            
            [self.drivingTimer invalidate];
            [self.walkingTimer invalidate];
        }
        self.previousMotionActivity = self.currentMotionActivity;
    };

    // check to see if the motion activity manager exists
/*    if ([CMMotionActivityManager isActivityAvailable])
    {
        _motionActivityManager = CMMotionActivityManager.new;

//        if ([CMMotionActivityManager authorizationStatus] == CMAuthorizationStatusAuthorized)
        {

            if (_motionActivityManager) {
                // if so, start monitoring activity
                // notice that we add updates to the mainQueue. This will call your handler on the main thread
                [_motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:motionActivityHandler];
            }
        }
    }*/
}

- (void) markLastDriveTime:(NSTimer *)timer
{
    _lastDriveTime = NSDate.now.timeIntervalSince1970;
}
- (void) markLastWalkingTime:(NSTimer *)timer
{
    int now = NSDate.now.timeIntervalSince1970;
    if (now - _lastDriveTime < 600)
    {
        [self markVehicleLocation];
        _lastDriveTime = 0;
    }
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
    _needToSetVehicleLocation = 5;
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
    
    if (_needToSetVehicleLocation)
    {
        if (_needToSetVehicleLocation-- == 1)
        {
            HuntingData *hd = HuntingData.new;
            [self clearTrackRoute];
            CRAPI.sharedInstance.amBuildingTrackRoute = TRUE;
            [hd deleteWaypointsOfType:@"Vehicle"];
            LLPOINT pnt;
            if (_lastVehicleLocation.lat == 0)
                pnt = _currentPoint;
            else
                pnt = _lastVehicleLocation;
            _lastVehicleLocation.lat = 0;
            [hd addWaypoint:@"V" type:@"Vehicle" latlon:pnt description:@"" displayOnCompass:YES];
            CRAPI.sharedInstance.currentVehicleLocation = _currentPoint;
            if (self.delegate && [self.delegate respondsToSelector:@selector(didMarkVehicleLocation:)])
            {
                [self.delegate didMarkVehicleLocation:self];
            }
            [self playRecording:_vehicleLocationSavedSoundURL];
        }
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
            //if (_distToRoute < _atDistance)
                [self turnAlert];
        }
        if (_currentGPSHeading >= 0 && (_turnDegrees >= 150 || _turnDegrees <= -150))
        {
            if (turnArroundCount++ == 3)
            {
                int inow = NSDate.now.timeIntervalSince1970;
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
    if (locations.count > 0 && !_inSimulationMode)
    {
        CLLocation * loc = locations.lastObject;
        LLPOINT pt;
        pt.lat = loc.coordinate.latitude;
        pt.lon = loc.coordinate.longitude;
        _GPSHeading = loc.course;
        _GPSHeadingAccuracy = loc.courseAccuracy;
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
    if (_numLastPoints < _maxLastPoints)
        _pLastPoints[_numLastPoints++] = _atUTM;
    else
    {
        for (int i = 1;i < _numLastPoints; i++)
        {
            _pLastPoints[i-1] = _pLastPoints[i];
        }
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
        if (addIt)
        {
            rtn = 1;
            if (CRAPI.sharedInstance.amBuildingTrackRoute)
                [CRAPI.sharedInstance.currentTrackRoute addObject:routePoint];
            if (CRAPI.sharedInstance.currentVehicleLocation.lon != 0)
            {
                dist = ArcDistanceLL(routePoint.latlon,CRAPI.sharedInstance.currentVehicleLocation);
                if (CRAPI.sharedInstance.waitingToMoveAwayFromVehicle)
                {
                    if (dist > _moveAwayFromVehicleDist)
                    {
                        [self movedAwayFromVehicle];
                    }
                }
                else if (dist < _returnToVehicleDist && CRAPI.sharedInstance.amBuildingTrackRoute)
                {
                    if (NSDate.now.timeIntervalSince1970 - CRAPI.sharedInstance.trackRouteStartTime > _minTrackTime)
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
    else if ([self pointInMessageList:CRAPI.sharedInstance.currentSelectedWaypoint])
        return;
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
    double AZ1=0, AZ2=0;
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
        if (CRAPI.sharedInstance.currentSelectedWaypoint == wp.refno && index < routePointArray.count)
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
                    _turnDegrees = DeltaAZD(gpsAz, AZ2);
                    _headingToNextPoint = HeadingFromAZ(AZ2) * RADtoDEG;
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
                rtn = TRUE;
            }
        }
        RoutePoint[0] = RoutePoint[1];
    }
    if (rtn)
    {
        float vol;
        _offDist = minDist;
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
    }

    [_messagePlayer play];
}

@end

