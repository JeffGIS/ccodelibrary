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

-(void)locationFromTrack:(TrackLocationManager *)manager
      didUpdateLocations:(NSArray *)locations;

@optional

@end

@interface TrackLocationManager : NSObject

@end

#endif /* TrackLocationManager_h */
