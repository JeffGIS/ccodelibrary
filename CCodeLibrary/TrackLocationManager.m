//
//  TrackLocationManager.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 11/8/23.
//  Copyright © 2023 GSSi. All rights reserved.
//
#import "TrackLocationManager.h"
#import <UIKit/UIKit.h>
#import "CRAPI.h"
#import "GSSiDefs.h"
#import "CVTCoord.h"
#include "PROJ.H"
@interface TrackLocationManager ()

@property CLLocationManager *locationManager;
@property int minTimerDelay,maxTimerDelay;
@property CGFloat timerDelay;
@property double notifyDist;
@property int currentTimerDelay;
@property BOOL goLeft;
@property SystemSoundID lowSoundID, highSoundID;

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

        InitProj4CoordConv (FALSE);

    }
    return self;

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

    return;
}
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    [self.delegate locationManager:self didUpdateHeading:newHeading];
    return;
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
    
    if (CRAPI.sharedInstance.inRouteMode)
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
    CRAPI.sharedInstance.inRouteMode = FALSE;
    if (_offCourseTimer)
        [_offCourseTimer invalidate];

}
@end

