//
//  TrackLocationManager.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 11/8/23.
//  Copyright © 2023 GSSi. All rights reserved.
//
#import "TrackLocationManager.h"
//#import <UIKit/UIKit.h>
#import "CRAPI.h"
#import "GSSiDefs.h"
#import "CVTCoord.h"
#include "PROJ.H"
#import "HuntingData.h"

@interface TrackLocationManager ()

@property CLLocationManager *locationManager;
@property int minTimerDelay,maxTimerDelay;
@property int timerDelay;
@property double notifyDist;
@property int currentTimerDelay;
@property BOOL goLeft;
@property BOOL amSavingLocations;
@property SystemSoundID lowSoundID, highSoundID, gotGPSInputSound;
@property SystemSoundID bearRightSoundID, right45SoundID, right90SoundID, right135SoundID;
@property SystemSoundID bearLeftSoundID, left45SoundID, left90SoundID, left135SoundID, endOfRouteSoundID;
@property NSString * savedLocationsFile;
@property NSString * tempDirectory;
@property int currentSimulationIndex;
@property NSTimer *simulationTimer;
@property int numUpdates;
@property BOOL atEndOfRoute;
@property double turnDegrees;
@property int numLastPoints;
@property int maxLastPoints;
@property LPDPOINT pLastPoints;
@property double distToRoute;
@property double currentGPSHeading;
@property double headingToNextPoint;

@end

@implementation TrackLocationManager

-(id) init
{
    self = [super init];
    
    if (self)
    {
        _locationManager = CLLocationManager.new;
        _locationManager.delegate = self;
        _maxTimerDelay = 60;
        _minTimerDelay = 10;
        _timerDelay = _maxTimerDelay;
        _currentTimerDelay = 0;
        _notifyDist = 10;
        _numLastPoints = 0;
        _maxLastPoints = 8;
        _pLastPoints = malloc (sizeof(DPOINT)*_maxLastPoints+4);
        _nearDistance = 20;
        _atDistance = 10;
        _closeDistance = 100;
        _updateNotificationFrequency = 5;
        _tempDirectory = UserDefaults.defaults.nonBackedUpFilePath;
        _savedLocationsFile = [_tempDirectory stringByAppendingString:@"/savedlocations.bin"];

        InitProj4CoordConv (FALSE);
        NSString *soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/short_double_high.caf"];
        NSURL *url = [NSURL URLWithString:soundFile];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &_highSoundID);
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/short_double_low.caf"];
        url = [NSURL URLWithString:soundFile];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &_lowSoundID);
        soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/Tock.caf"];
        url = [NSURL URLWithString:soundFile];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &_gotGPSInputSound);
        
        NSURL *soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"BearRight" ofType:@"m4a"]];
        OSStatus st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_bearRightSoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Right45Degrees" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_right45SoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Right90Degrees" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_right90SoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Right135Degrees" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_right135SoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"BearLeft" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_bearLeftSoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Left45Degrees" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_left45SoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Left90Degrees" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_left90SoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"Left135Degrees" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_left135SoundID);
        soundURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"EndOfRoute" ofType:@"m4a"]];
        st = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_endOfRouteSoundID);

    }
    return self;

}

- (void) dealloc
{
    AudioServicesDisposeSystemSoundID(_lowSoundID);
    AudioServicesDisposeSystemSoundID(_highSoundID);
}

- (void) setDistanceFilter:(CLLocationDistance) dist
{
    _locationManager.distanceFilter = dist;
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
}
- (void) setPausesLocationUpdatesAutomatically:(BOOL) pausesLocationUpdatesAutomatically
{
    _locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
}

- (void)startUpdatingLocation
{
    [_locationManager startUpdatingLocation];
    _numLastPoints = 0;
}
- (void)startUpdatingHeading
{
    [_locationManager startUpdatingHeading];
}
- (void)stopUpdatingLocation
{
    [_locationManager stopUpdatingLocation];
    [self offCourseNotification:0
                      withDelay:0];
    _numLastPoints = 0;
}
- (void)stopUpdatingHeading
{
    [_locationManager stopUpdatingHeading];
}
- (void) startSimulation
{
    if (CRAPI.sharedInstance.currentTrackRoute.count > 1)
    {
        CRAPI.sharedInstance.locationTrackingEnabled = TRUE;
        _inSimulationMode = YES;
        _currentSimulationIndex = 0;
        _simulationTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(simulateGPS)                                                            userInfo:nil
                                                     repeats:YES];
    }

}
- (void) startSimulationAt:(LLPOINT)startPoint
{
    int nearPoint = 0;
    int index = 0;
    double nearDist = DBL_MAX;
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
        _simulationTimer = [NSTimer scheduledTimerWithTimeInterval:1
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
        [self offCourseNotification:0
                          withDelay:0];

    }
    return;
}

- (void) setDelegate:(id<TrackLocationManagerDelegate>)delegate
{
    _delegate = delegate;
}
- (void) newGPSLocation:(LLPOINT)pt
                heading:(double)GPSHeading
{
    NSLog (@"GPS input recieved");
    if (! (_numUpdates++ % _updateNotificationFrequency))
        AudioServicesPlaySystemSound(_gotGPSInputSound);
    _currentPoint = pt;
    _currentGPSHeading = GPSHeading;
    _atUTM = LLPointToDPoint (pt);
    ConvertCoord(&_atUTM, LATLONPROJECTION, UTM15PROJECTION);
    [self addPointToLastPoints];
    if (_amSavingLocations)
        [self saveLocation];
    if (self.delegate)
        [self.delegate locationManager:self didUpdateLocations:_currentPoint
                            GPSHeading:GPSHeading];
    double distToDest = ldistp(_atUTM, _toUTM)/ METERS_PER_YARD;
    if (distToDest < _atDistance)
    {
        [self offCourseNotification:0
                          withDelay:0];
        //[self turnAlert];
    }
    if (CRAPI.sharedInstance.inFollowingRouteMode)
    {
       INT64 destRoutePoint = [self computeNextRoutePoint];
        if (destRoutePoint && destRoutePoint != _currentRoutePointNumber)
        {
            _currentRoutePointNumber = destRoutePoint;
            if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRefreshScreen:)])
            {
                [self.delegate shouldRefreshScreen:self];
            }
            //if (_distToRoute < _atDistance)
                [self turnAlert];
        }
    }
    return;
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
    FILE *Fid = fopenGSSi(_savedLocationsFile.cString,"a");
    
    if (Fid == NULL)
        return;
    RoutePointStruct routePoint;
    routePoint.time = NSDate.timeIntervalSinceReferenceDate;
    routePoint.pt = _currentPoint;
    routePoint.GPSHeading = _currentGPSHeading;

    BigWriteF(Fid ,(LPSTR)&routePoint ,sizeof(RoutePointStruct), -1);
    fcloseGSSi(Fid);
}

-(void) startSavingLocations
{
    _amSavingLocations = TRUE;
}
-(NSArray *) retrieveSavedLocations
{
    _amSavingLocations = FALSE;
    NSMutableArray * array=NSMutableArray.new;
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
    }

    return array;
}

- (void) addPointToLastPoints
{
    if (_numLastPoints < _maxLastPoints)
        _pLastPoints[_numLastPoints++] = _atUTM;
    else
    {
        for (int i = 0;i < _numLastPoints; i++)
        {
            if (i < _maxLastPoints -1)
            _pLastPoints[i+1] = _pLastPoints[i];
        }
        _pLastPoints[0] = _atUTM;
    }
   
}

- (double) GPSHeadingFromPoints
{
    double A, B, maxDiff=0;
    long locOfMaxDiff;
    if (_numLastPoints < 3)
        return 1000;
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
        pPoints[0].x = xmin;
        pPoints[0].y = A + pPoints[0].x * B;
        pPoints[1].x = xmax;
        pPoints[1].y = A + pPoints[1].x * B;
        double AZ = getazdp(&pPoints[0], &pPoints[1]);
        return AZMToHeading(AZ);
    }
    return 1000;
}

-(void) offCourseNotification:(int) opt
                    withDelay:(int) intDelay
{
    static int currentTimerOpt = 0;
//    int intDelay = max (IDNINT (delay/_minTimerDelay) * _minTimerDelay,_minTimerDelay);
    
    if (opt == currentTimerOpt && intDelay == _currentTimerDelay)
        return;
    _goLeft = FALSE;
    currentTimerOpt = opt;
    _currentTimerDelay = intDelay;
    if (_offCourseTimer)
    {
        [_offCourseTimer invalidate];
        _offCourseTimer = nil;
    }
    switch (opt)
    {
        default:
        case 0:
            _offCourseTimer = nil;
            break;
        case RIGHT: //go left
            _goLeft = TRUE;
        case LEFT: //go right
            if (!_offCourseTimer)
                _offCourseTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(offCourseNotificationPlay:) userInfo:nil repeats:NO];
            _offCourseTimer = [NSTimer scheduledTimerWithTimeInterval:_currentTimerDelay target:self selector:@selector(offCourseNotificationPlay:) userInfo:nil repeats:YES];
            break;
    }
    return;

}
-(void) offCourseNotificationPlay:(NSTimer *) timer
{
    if (_goLeft)
    {
        AudioServicesPlaySystemSound(_lowSoundID);
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

        AudioServicesPlaySystemSound(_highSoundID);
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

- (void) turnAlert
{
    static INT64 currentPointID = 0;
    if (currentPointID == CRAPI.sharedInstance.currentSelectedWaypoint)
        return;
    currentPointID = CRAPI.sharedInstance.currentSelectedWaypoint;
    if (_atEndOfRoute)
    {
        AudioServicesPlaySystemSound(_endOfRouteSoundID);
    }
    else
    {
        double ch = _currentGPSHeading;
        double nextPt = _headingToNextPoint;
        if (_turnDegrees < -5 && _turnDegrees > -45 * 0.5)
            AudioServicesPlaySystemSound(_bearRightSoundID);
        else if (_turnDegrees > -45 * 1.5 && _turnDegrees < -45 * 0.5)
            AudioServicesPlaySystemSound(_right45SoundID);
        else if (_turnDegrees > -45 * 2.5 && _turnDegrees < -45 * 1.5)
            AudioServicesPlaySystemSound(_right90SoundID);
        else if (_turnDegrees < -45 * 2.5)
            AudioServicesPlaySystemSound(_right135SoundID);
        else if (_turnDegrees > 5 && _turnDegrees < 45 * 0.5)
            AudioServicesPlaySystemSound(_bearLeftSoundID);
        else if (_turnDegrees < 45 * 1.5 && _turnDegrees > 45 * 0.5)
            AudioServicesPlaySystemSound(_left45SoundID);
        else if (_turnDegrees < 45 * 2.5 && _turnDegrees > 45 * 1.5)
            AudioServicesPlaySystemSound(_left90SoundID);
        else if (_turnDegrees > 45 * 2.5)
            AudioServicesPlaySystemSound(_left135SoundID);

    }
}

- (void) exitRouteMode
{
    CRAPI.sharedInstance.inFollowingRouteMode = FALSE;
    CRAPI.sharedInstance.currentSelectedWaypoint = -1;
    if (_offCourseTimer)
        [_offCourseTimer invalidate];

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
    RoutePoint[0] = _routeStartPoint;

    CRAPI.sharedInstance.currentSelectedWaypoint = -1;
    INT64 destinationRoutePointNumber = 0;
    double minDist = DBL_MAX;
    _atEndOfRoute = FALSE;
    double AZ1=0, AZ2=0;
    int legNum = 0;
    _turnDegrees = 0;
    NSArray <UserWaypoint*> *routePointArray = [hd getWaypointsOfType:@"RoutePoint"];
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
            if (offDist < minDist)
            {
                _fromUTM = RoutePoint[0];
                _toUTM = wp.UTM;
                AZ1 = getazdp (&_atUTM,&IntPoint);
                _leftOrRight = leftOrRight;
                minDist = offDist;
                _distToRoute = minDist / METERS_PER_YARD;
                CRAPI.sharedInstance.currentSelectedWaypoint = wp.refno;
                destinationRoutePointNumber = wp.refno;
                double gpsAz = HeadingToAzimuth (_currentGPSHeading);
                _turnDegrees = DeltaAZD(gpsAz, AZ2);
                _headingToNextPoint = HeadingFromAZ(AZ2) * RADtoDEG;
                _turnDegrees *= RADtoDEG;
                _atEndOfRoute = FALSE;
                rtn = TRUE;
            }
        }
        RoutePoint[0] = RoutePoint[1];
    }
    if (rtn)
    {
        _offDist = minDist;
        _offDist /= METERS_PER_YARD;
        if (_offDist > _notifyDist)
        {
            if (_offDist > _notifyDist * 5)
                _timerDelay = _minTimerDelay;
            else if (_offDist > _notifyDist * 2)
                _timerDelay = _minTimerDelay * 2;
            else
                _timerDelay = _maxTimerDelay;
            [self offCourseNotification:_leftOrRight
                              withDelay:_timerDelay];
        }
        else
            [self offCourseNotification:0
                              withDelay:0];
    }
    else
        [self offCourseNotification:0
                          withDelay:0];

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

@end

