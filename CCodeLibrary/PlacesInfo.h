//  PlacesInfo.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PlacesInfo : NSObject
{
    NSString *_name, *_geoid;
    CGFloat _bounds_w, _bounds_s, _bounds_e, _bounds_n;
    NSNumber *_latitude, *_longitude;
    int _state, _intID, _intX, _intY, _rotation;
    int _ramp1, _ramp2, _ramp3, _ramp4, _ramp5, _ramp6, _ramp7, _ramp8;
    int _ramp81, _ramp23, _ramp45, _ramp67;
    int _xWalkA, _xWalkB, _xWalkC, _xWalkD;
    int _signal81, _signal23, _signal45, _signal67;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *geoid;
@property (nonatomic) int state;
@property (nonatomic) CGFloat bounds_w;
@property (nonatomic) CGFloat bounds_s;
@property (nonatomic) CGFloat bounds_e;
@property (nonatomic) CGFloat bounds_n;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;
@property (nonatomic) int intID;
@property (nonatomic) int intX;
@property (nonatomic) int intY;
@property (nonatomic) int rotation;
@property (nonatomic) int ramp1;
@property (nonatomic) int ramp2;
@property (nonatomic) int ramp3;
@property (nonatomic) int ramp4;
@property (nonatomic) int ramp5;
@property (nonatomic) int ramp6;
@property (nonatomic) int ramp7;
@property (nonatomic) int ramp8;
@property (nonatomic) int ramp81;
@property (nonatomic) int ramp23;
@property (nonatomic) int ramp45;
@property (nonatomic) int ramp67;
@property (nonatomic) int xWalkA;
@property (nonatomic) int xWalkB;
@property (nonatomic) int xWalkC;
@property (nonatomic) int xWalkD;
@property (nonatomic) int signal81;
@property (nonatomic) int signal23;
@property (nonatomic) int signal45;
@property (nonatomic) int signal67;

- (id)initWithBounds_w:(CGFloat)bounds_w
              bounds_s:(CGFloat)bounds_s
              bounds_e:(CGFloat)bounds_e
              bounds_n:(CGFloat)bounds_n;

- (id)initWithName:(NSString *)name
             state:(int)state
          bounds_w:(CGFloat)bounds_w
          bounds_s:(CGFloat)bounds_s
          bounds_e:(CGFloat)bounds_e
          bounds_n:(CGFloat)bounds_n;

- (id)initWithName:(NSString *)name
             geoid:(NSString *)geoid;

- (id)initWithLatitude:(NSNumber *)latitude
             longitude:(NSNumber *)longitude;

- (id)initWithIntID:(int)intID
               intX:(int)intX
               intY:(int)intY
           rotation:(int)rotation
              ramp1:(int)ramp1
              ramp2:(int)ramp2
              ramp3:(int)ramp3
              ramp4:(int)ramp4
              ramp5:(int)ramp5
              ramp6:(int)ramp6
              ramp7:(int)ramp7
              ramp8:(int)ramp8
             ramp81:(int)ramp81
             ramp23:(int)ramp23
             ramp45:(int)ramp45
             ramp67:(int)ramp67
             xWalkA:(int)xWalkA
             xWalkB:(int)xWalkB
             xWalkC:(int)xWalkC
             xWalkD:(int)xWalkD
           signal81:(int)signal81
           signal23:(int)signal23
           signal45:(int)signal45
           signal67:(int)signal67;

@end