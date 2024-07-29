//
//  TrackLocationManager.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 11/8/23.
//  Copyright © 2023 GSSi. All rights reserved.
//

#ifndef TrackLocationManager_h
#define TrackLocationManager_h

#import <Foundation/Foundation.h>
@class TrackLocationManager;

@protocol TrackLocationManagerDelegate <NSObject>

- (void)locationManager:(TrackLocationManager *)manager
      didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(TrackLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading;

@optional

@end

@interface TrackLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic, weak) id <TrackLocationManagerDelegate> delegate;

@property (nonatomic)CLLocationDegrees headingFilter;
@property (nonatomic)CLDeviceOrientation headingOrientation;
@property (nonatomic)CLLocationAccuracy desiredAccuracy;
@property (nonatomic)CLLocationDistance distanceFilter;
@property (nonatomic)CLActivityType activityType;
@property (nonatomic) BOOL allowsBackgroundLocationUpdates;
@property (nonatomic)BOOL pausesLocationUpdatesAutomatically;
@property DPOINT fromUTM, toUTM, atUTM, nextUTM;
@property int atDistance;
@property int nearDistance;
@property int closeDistance;
@property BOOL checkOff;
@property double offDist;
@property int leftOrRight;
@property int nearDist;
@property BOOL checkOffset;
@property LLPOINT currentPoint;
@property LLPOINT routeStartPoint;
@property LLPOINT fromPoint;
@property int currentRoutePointNumber;

@property NSTimer * offCourseTimer;

- (void)startUpdatingLocation;
- (void)startUpdatingHeading;
- (void)stopUpdatingLocation;
- (void)stopUpdatingHeading;

-(void) offCourseNotification:(int) opt
                    withDelay:(CGFloat) delay;
-(void) exitRouteMode;
-(void) createTwoPointRoute:(LLPOINT)fromLL
                       toLL:(LLPOINT)toLL;

@end

#endif /* TrackLocationManager_h */
