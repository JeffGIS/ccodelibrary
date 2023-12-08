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
@property (nonatomic)CLActivityType activityType;
@property (nonatomic)BOOL pausesLocationUpdatesAutomatically;

- (void)startUpdatingLocation;
- (void)startUpdatingHeading;
- (void)stopUpdatingLocation;
- (void)stopUpdatingHeading;

@end

#endif /* TrackLocationManager_h */
