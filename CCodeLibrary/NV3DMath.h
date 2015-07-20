//  NV3DMath.h
//  CCodeLibrary

#import <SceneKit/SceneKit.h>

@interface NV3DMath : NSObject

+ (SCNVector3)eulerAnglesFromPointA:(SCNVector3)pointA
                             pointB:(SCNVector3)pointB;

+ (CGFloat)distanceFromPointA:(SCNVector3)pointA
                       pointB:(SCNVector3)pointB;

+ (SCNVector3)centerPointFromPointA:(SCNVector3)pointA
                             pointB:(SCNVector3)pointB;

@end