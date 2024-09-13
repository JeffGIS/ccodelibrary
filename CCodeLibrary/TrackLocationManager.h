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
#import <AVFoundation/AVFoundation.h>
@import CoreLocation;

typedef struct {LLPOINT pt;
    int time;
    double GPSHeading;} RoutePointStruct ;
typedef NS_ENUM(NSInteger, Activities)
{
    Vehicle,
    Walking,
};

@class TrackLocationManager;

@protocol TrackLocationManagerDelegate <NSObject>

- (void)locationManager:(TrackLocationManager *)manager
     didUpdateLocations:(LLPOINT)point
             GPSHeading:(double)gpsHeading;
- (void)locationManager:(TrackLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading;

@optional
- (void)shouldRefreshScreen:(TrackLocationManager *)manager;
- (void)didMarkVehicleLocation:(TrackLocationManager *)manager;

@end

@interface TrackLocationManager : NSObject<CLLocationManagerDelegate,AVAudioPlayerDelegate>
@property (nonatomic, weak) id <TrackLocationManagerDelegate> delegate;

@property (nonatomic)CLLocationDegrees headingFilter;
@property (nonatomic)CLDeviceOrientation headingOrientation;
@property (nonatomic)CLLocationAccuracy desiredAccuracy;
@property (nonatomic)CLLocationDistance distanceFilter;
@property (nonatomic)CLActivityType activityType;
@property (nonatomic) BOOL allowsBackgroundLocationUpdates;
@property (nonatomic)BOOL pausesLocationUpdatesAutomatically;
@property (nonatomic) double GPSHeading;
@property (nonatomic) double GPSHeadingAccuracy;
@property (nonatomic) double GPSHeadingFromPoints;
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
@property DPOINT routeStartPoint;
@property LLPOINT fromPoint;
@property INT64 currentRoutePointNumber;
@property int updateNotificationFrequency;
@property BOOL inSimulationMode;
@property BOOL routeWasSaved;
@property NSString *currentMotionActivity;
@property Activities currentActivity;
@property Activities previousActivity;
@property int currentActivityStartTime;


@property NSTimer * offCourseTimer;

- (void)startUpdatingLocation;
- (void)startUpdatingHeading;
- (void)stopUpdatingLocation;
- (void)stopUpdatingHeading;
- (void)requestLocation;
- (void) requestWhenInUseAuthorization;

-(void) offCourseNotification:(int) opt
                    withDelay:(int) delay;
-(void) exitRouteMode;
-(void) createTwoPointRoute:(LLPOINT)fromLL
                       toLL:(LLPOINT)toLL;
-(void) startSavingLocations;
-(NSArray *) retrieveSavedLocations;
- (void) startSimulation;
- (void) startSimulationAt:(LLPOINT)startPoint;
- (void) stopSimulation;
- (BOOL) pointInMessageList:(INT64)pointID;
- (void) endLocationTrackingMessage;
- (void) markVehicleLocation;

@end

#endif /* TrackLocationManager_h */
