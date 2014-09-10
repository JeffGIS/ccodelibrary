//  PlacesInfo.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PlacesInfo : NSObject
{
    NSString *_name, *_geoid, *_statecode;
    CGFloat _bounds_w, _bounds_s, _bounds_e, _bounds_n;
    NSNumber *_latitude, *_longitude;
    int _statefp;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *geoid;
@property (nonatomic, copy) NSString *stateCode;
@property (nonatomic) int statefp;
@property (nonatomic) CGFloat bounds_w;
@property (nonatomic) CGFloat bounds_s;
@property (nonatomic) CGFloat bounds_e;
@property (nonatomic) CGFloat bounds_n;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;

- (id)initWithBounds_w:(CGFloat)bounds_w
              bounds_s:(CGFloat)bounds_s
              bounds_e:(CGFloat)bounds_e
              bounds_n:(CGFloat)bounds_n;

- (id)initWithName:(NSString *)name
         stateCode:(NSString *)stateCode
          bounds_w:(CGFloat)bounds_w
          bounds_s:(CGFloat)bounds_s
          bounds_e:(CGFloat)bounds_e
          bounds_n:(CGFloat)bounds_n;

- (id)initWithName:(NSString *)name
             geoid:(NSString *)geoid;

- (id)initWithLatitude:(NSNumber *)latitude
             longitude:(NSNumber *)longitude;

@end