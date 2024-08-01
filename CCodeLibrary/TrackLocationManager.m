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
@property CGFloat timerDelay;
@property double notifyDist;
@property int currentTimerDelay;
@property BOOL goLeft;
@property BOOL amSavingLocations;
@property SystemSoundID lowSoundID, highSoundID, gotGPSInputSound;
@property NSString * savedLocationsFile;
@property NSString * tempDirectory;

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
        _nearDistance = 20;
        _atDistance = 10;
        _closeDistance = 100;
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
}
- (void)startUpdatingHeading
{
    [_locationManager startUpdatingHeading];
}
- (void)stopUpdatingLocation
{
    [_locationManager stopUpdatingLocation];
}
- (void)stopUpdatingHeading
{
    [_locationManager stopUpdatingHeading];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog (@"GPS input recieved");
    AudioServicesPlaySystemSound(_gotGPSInputSound);
    if (locations.count > 0)
    {
        CLLocation * loc = locations.lastObject;
        
        _currentPoint.lat = loc.coordinate.latitude;
        _currentPoint.lon = loc.coordinate.longitude;
        if (_amSavingLocations)
            [self saveLocation];
        if (self.delegate)
            [self.delegate locationManager:self didUpdateLocations:locations];
        double distToDest = ldistp(_atUTM, _toUTM)/ METERS_PER_YARD;
        if (distToDest < _atDistance)
        {
            [self offCourseNotification:0
                              withDelay:0];
        }
        else if (_checkOff && [self checkIfOffRoute:_atUTM])
        {
            
        }
        if (CRAPI.sharedInstance.inFollowingRouteMode)
            [self computeNextRoutePoint];

    }

    return;
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
    BigWriteF(Fid ,(LPSTR)&_currentPoint ,sizeof(LLPOINT), -1);
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
        LLPOINT point;
        while (BigReadF(Fid, (HPSTR)&point ,sizeof(LLPOINT)) == sizeof(LLPOINT))
        {
            TrackRoutePoint * pt = TrackRoutePoint.new;
            pt.latlon = point;
            [array addObject:pt];
        }
        fcloseGSSi(Fid);
        NSError *err = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:_savedLocationsFile error:&err];
    }

    return array;
}


-(void) offCourseNotification:(int) opt
                    withDelay:(CGFloat) delay
{
    static int currentTimerOpt = 0;
    int intDelay = max (IDNINT (delay/_minTimerDelay) * _minTimerDelay,_minTimerDelay);
    
    if (opt == currentTimerOpt && intDelay == _currentTimerDelay)
        return;
    _goLeft = FALSE;
    currentTimerOpt = opt;
    _currentTimerDelay = intDelay;
    if (_offCourseTimer)
        [_offCourseTimer invalidate];
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

/*-(BOOL) checkIfOffRouteTest:(LLPOINT) atLL
{
    DPOINT atUTM;
    _fromUTM = saveFromUTM;
    _toUTM = saveToUTM;
    atUTM.x = atLL.lon;
    atUTM.y = atLL.lat;
    ConvertCoord(&atUTM, LATLONPROJECTION, UTM15PROJECTION);
    [self checkIfOffRoute:atUTM];
}*/
-(BOOL) checkIfOffRoute:(DPOINT) currentPoint
{
    BOOL offRoute = FALSE;
    DPOINT Line[2];
    DPOINT IntPoint;
    double offDistNext = -1;
    //saveFromUTM = _fromUTM;
    //saveToUTM = _toUTM;
    
    if (CRAPI.sharedInstance.inFollowingRouteMode)
    {
        if (_nextUTM.x)
        {
            Line[0] = _toUTM;
            Line[1] = _nextUTM;
            if (GetPerpendicularIntersect (&currentPoint,Line,&IntPoint,FALSE,&_leftOrRight))
            {
                offDistNext = ldistpp (&currentPoint,&IntPoint);
            }
        }
        Line[0] = _fromUTM;
        Line[1] = _toUTM;
        if (GetPerpendicularIntersect (&currentPoint,Line,&IntPoint,TRUE,&_leftOrRight))
        {
            _offDist = ldistpp (&currentPoint,&IntPoint);
            if (_offDist > offDistNext) //switch to next point in route
            {
                
            }
            _offDist /= METERS_PER_YARD;
            if (_offDist > _notifyDist)
            {
                _timerDelay = max (_minTimerDelay,(_notifyDist/_offDist) * _maxTimerDelay);
                [self offCourseNotification:_leftOrRight
                                  withDelay:_timerDelay];
            }
            else
                [self offCourseNotification:0
                                  withDelay:0];
        }
        else
        {
            _offDist = 0;
            [self offCourseNotification:0
                              withDelay:0];
        }
    }
    return offRoute;
}

- (void) exitRouteMode
{
    CRAPI.sharedInstance.inFollowingRouteMode = FALSE;
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
-(BOOL) computeNextRoutePoint
{
    BOOL rtn = FALSE;
    HuntingData *hd = HuntingData.new;
    DPOINT Line[2];
    DPOINT IntPoint;
    DPOINT CurrentPoint;
    CurrentPoint.x = _currentPoint.lon;
    CurrentPoint.y = _currentPoint.lat;
    ConvertCoord(&CurrentPoint, LATLONPROJECTION, UTM15PROJECTION);
    Line[0] = LLPointToDPoint (_routeStartPoint);
    ConvertCoord(&Line[0], LATLONPROJECTION, UTM15PROJECTION);

    CRAPI.sharedInstance.currentSelectedWaypoint = -1;
    _currentRoutePointNumber = 0;
    double minDist = DBL_MAX;
    
    NSArray <UserWaypoint*> *routePointArray = [hd getWaypointsOfType:@"RoutePoint"];
    for (UserWaypoint *wp in routePointArray)
    {
        Line[1] = LLPointToDPoint (wp.latlon);
        ConvertCoord(&Line[1], LATLONPROJECTION, UTM15PROJECTION);
        int leftOrRight=0;
        if (GetPerpendicularIntersect (&CurrentPoint,Line,&IntPoint,TRUE,&leftOrRight))
        {
            double offDist = ldistpp (&CurrentPoint,&IntPoint);
            _leftOrRight = leftOrRight;
            if (offDist < minDist)
            {
                minDist = offDist;
                CRAPI.sharedInstance.currentSelectedWaypoint = wp.refno;
                _currentRoutePointNumber = wp.refno;
                rtn = TRUE;
            }
        }
        Line[0] = Line[1];
    }

    return rtn;
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

