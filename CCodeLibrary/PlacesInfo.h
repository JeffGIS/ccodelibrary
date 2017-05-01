//  PlacesInfo.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PlacesInfo : NSObject

@property (nonatomic, copy) NSString *name, *geoid, *stateCode;
@property int statefp;
@property CLLocationDegrees bounds_w, bounds_s, bounds_e, bounds_n;
@property (nonatomic) NSNumber *latitude, *longitude;

- (id)initWithBounds_w:(CLLocationDegrees)bounds_w
              bounds_s:(CLLocationDegrees)bounds_s
              bounds_e:(CLLocationDegrees)bounds_e
              bounds_n:(CLLocationDegrees)bounds_n;

- (id)initWithName:(NSString *)name
         stateCode:(NSString *)stateCode
          bounds_w:(CLLocationDegrees)bounds_w
          bounds_s:(CLLocationDegrees)bounds_s
          bounds_e:(CLLocationDegrees)bounds_e
          bounds_n:(CLLocationDegrees)bounds_n;

- (id)initWithName:(NSString *)name
             geoid:(NSString *)geoid;

- (id)initWithLatitude:(NSNumber *)latitude
             longitude:(NSNumber *)longitude;

@end
