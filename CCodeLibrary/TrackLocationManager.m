//
//  TrackLocationManager.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 11/8/23.
//  Copyright © 2023 GSSi. All rights reserved.
//

#import "TrackLocationManager.h"

@interface TrackLocationManager ()

@property CLLocationManager *locationManager;
@end

@implementation TrackLocationManager

-(id) init
{
    self = [super init];
    
    if (self)
    {
        _locationManager = CLLocationManager.new;
        _locationManager.delegate = self;
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
    return;
}
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    [self.delegate locationManager:self didUpdateHeading:newHeading];
    return;
}

@end

