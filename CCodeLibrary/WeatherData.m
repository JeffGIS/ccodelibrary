//
//  WeatherData.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 12/7/22.
//  Copyright © 2022 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherData.h"
#import "GSSiDefs.h"

@interface WeatherData ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSString *url;
@property (nonatomic, weak) id <WeatherDataDelegate> delegate;

@end

@implementation WeatherData

-(bool) getCurrentWeather:(LLPOINT)at
                 delegate:(id)delegate
{
    bool rtn = true;
    _delegate = delegate;
    NSError *error = nil;
    //    NSString *weatherURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&exclude=hourly,daily&appid=%@", atLatLon.lat, atLatLon.lon, OPEN_WEATHER_KEY];
    //    NSString *weatherURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=%@", atLatLon.lat, atLatLon.lon, OPEN_WEATHER_KEY];
    NSString *weatherURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial&appid=%@", at.lat, at.lon, OPEN_WEATHER_KEY];
    // 1
    NSURL *url = [NSURL URLWithString:weatherURL];
    //url = [NSURL URLWithString:[weatherURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    // 2
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
        int ii;
        if (error)
        {
            NSString * message = error.localizedDescription;
            [self->_delegate weatherDataaDidReturnError:message];
        }
        else
        {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self->_delegate weatherDataaDidReturnData:str];
        }
    }];
    
    [downloadTask resume];

    return rtn;
}
-(bool) getWeatherForcast:(LLPOINT)at
                  forTime:(time_t)time
                 delegate:(id)delegate
{
    bool rtn = true;
    
    return rtn;
}


@end
