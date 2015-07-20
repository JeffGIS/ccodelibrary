//  NV3DMath.m
//  CCodeLibrary

#import "NV3DMath.h"

@implementation NV3DMath

+ (SCNVector3)eulerAnglesFromPointA:(SCNVector3)pointA
                             pointB:(SCNVector3)pointB
{
    CGFloat zAngle = atan2((pointA.y - pointB.y), (pointA.x - pointB.x)) - (M_PI * 0.5);
    CGFloat xAngle = atan2((pointA.z - pointB.z), (pointA.y - pointB.y));
    CGFloat yAngle = 0.0;
    
    if (pointA.y > 0 || pointB.y > 0)
        yAngle += M_PI;
    
    SCNVector3 eulerAngles = SCNVector3Make(xAngle, yAngle, zAngle);
    
    return eulerAngles;
}

+ (CGFloat)distanceFromPointA:(SCNVector3)pointA
                       pointB:(SCNVector3)pointB
{
    CGFloat distance = sqrt(pow((pointA.x - pointB.x), 2) +
                            pow((pointA.y - pointB.y), 2) +
                            pow((pointA.z - pointB.z), 2));
    
    return distance;
}

+ (SCNVector3)centerPointFromPointA:(SCNVector3)pointA
                             pointB:(SCNVector3)pointB
{
    SCNVector3 centerPoint = SCNVector3Make(((pointA.x + pointB.x) / 2.0),
                                            ((pointA.y + pointB.y) / 2.0),
                                            ((pointA.z + pointB.z) / 2.0));
    
    return centerPoint;
}

@end