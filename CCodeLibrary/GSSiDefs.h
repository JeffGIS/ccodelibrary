//  GSSiDefs.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

#define GOOGLE_API_KEY @"AIzaSyB7XIgauC5W-veOVKKdTvkYTO5zQxquw9Q"
#define GOOGLE_SERVER_KEY @"AIzaSyBQvw3ROLNlUtuSlVdnk0zLvnbonh3I3vw"
#define BING_API_KEY @"AhGA_PqXHM1e8opz8VEBHts-yzpUJVjxTIUdyA9m6x7o-TRAwYupMcn6JWEQf9V3"
#define WALKSCORE_API_KEY @"96cbffe516734da405a527bf86a83bb7"
#define OPEN_WEATHER_KEY @"38dde0e75b863c1dad14cb6d2a7f423e"
#define iPAD_HEIGHT 1024.0
#define iPAD_WIDTH 768.0
#define APP_GROUP_ID @"group.com.gssi.appgroup"
#define NUMREADINGS 30
#define DEGREES(radians) ((radians) * (180.0 / M_PI))
#define RADIANS(degrees) ((degrees) / 180.0 * M_PI)
#define RADIANS_SLOPE(degrees) (100.0 * sin(RADIANS(degrees)))
#define METERS_PER_FOOT 0.3048
#define METERS_PER_YARD (3*0.3048)

@interface GSSiDefs : NSObject

@end
