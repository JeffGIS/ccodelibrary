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

@implementation WeatherRecord
@end

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
        NSString *weatherURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial&appid=%@",  at.lat, at.lon,OPEN_WEATHER_KEY];
    //    NSString *weatherURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=%@", atLatLon.lat, atLatLon.lon, OPEN_WEATHER_KEY];
   // NSString *weatherURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&appid=%@", at.lat, at.lon, OPEN_WEATHER_KEY];
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
            [self->_delegate weatherDataDidReturnError:message];
        }
        else
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (error)
            {
                NSString * message = error.localizedDescription;
                [self->_delegate weatherDataDidReturnError:message];
            }
            else
            {
                WeatherRecord * record = WeatherRecord.new;
                
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSArray * keys = json.allKeys;
                NSArray * vals = json.allValues;
                NSNumber *time = [json objectForKey:@"dt"];
                record.timeStamp = time.integerValue;
                NSDictionary *main = [json objectForKey:@"main"];
                NSString * temp = [main objectForKey:@"temp"];
                record.temp = IDNINT (temp.floatValue);
                id item = [json objectForKey:@"wind"];
                if (!item || [item isKindOfClass:NSNull.class])
                {
                    ii = 1;
                }
                else
                {
                    NSDictionary * wind = item;
                    NSDictionary * sys = [json objectForKey:@"sys"];
                    keys = wind.allKeys;
                    vals = wind.allValues;
                    NSString *sunRise = [sys objectForKey:@"sunrise"];
                    NSString *sunSet = [sys objectForKey:@"sunset"];
                    NSString *windSpeed = [wind objectForKey:@"speed"];
                    NSString *windDir = [wind objectForKey:@"deg"];
                    record.sunRise = sunRise.integerValue;
                    record.sunSet = sunSet.integerValue;
                    record.windSpeed = IDNINT (windSpeed.floatValue);
                    record.windDir = IDNINT (windDir.floatValue);

                    item = [json objectForKey:@"weather"];
                    NSArray * weather = item;
                    NSDictionary *weatherDict = weather[0];
                    NSString * weatherDesc = [weatherDict objectForKey:@"description"];
                    record.desc = weatherDesc;
                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [self->_delegate weatherDataDidReturnData:record];
                }
            }
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
