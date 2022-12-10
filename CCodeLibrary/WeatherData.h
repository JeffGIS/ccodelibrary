//
//  WeatherData.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 12/7/22.
//  Copyright © 2022 GSSi. All rights reserved.
//

#ifndef WeatherData_h
#define WeatherData_h

@interface WeatherRecord : NSObject

@property int timeStamp;
@property NSString *desc;
@property int temp;
@property int windSpeed;
@property int windDir;
@property int sunRise, sunSet;
@end

@class WeatherData;

@protocol WeatherDataDelegate <NSObject>

- (void)weatherDataDidReturnData:(WeatherRecord *)data;
- (void)weatherDataDidReturnError:(NSString *) message;

@end


@interface WeatherData : NSObject <NSURLConnectionDataDelegate>

-(bool) getCurrentWeather:(LLPOINT)at
                 delegate:(id)delegate;
-(bool) getWeatherForcast:(LLPOINT)at
                  forTime:(time_t)time
                 delegate:(id)delegate;

@end
#endif /* WeatherData_h */
