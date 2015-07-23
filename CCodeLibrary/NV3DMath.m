//  NV3DMath.m
//  CCodeLibrary

#import "NV3DMath.h"

@implementation NV3DMath

+ (SCNVector3)eulerAnglesFromPointA:(SCNVector3)pointA
                             pointB:(SCNVector3)pointB
{
    CGFloat xAngle = 0.0, zAngle = 0.0;
    
    if (pointA.x > pointB.x)
    {
        zAngle = atan2((pointA.y - pointB.y), [NV3DMath distance2DFromPointA:CGPointMake(pointA.z, pointA.x)
                                                                      pointB:CGPointMake(pointB.z, pointB.x)]) + (M_PI * 0.5);
    }
    
    else
    {
        zAngle = -atan2((pointA.y - pointB.y), [NV3DMath distance2DFromPointA:CGPointMake(pointA.z, pointA.x)
                                                                       pointB:CGPointMake(pointB.z, pointB.x)]) + (M_PI * 0.5);
    }
    
    if (pointA.y > pointB.y)
    {
        xAngle = -atan2((pointA.z - pointB.z), [NV3DMath distance2DFromPointA:CGPointMake(pointA.x, pointA.y)
                                                                      pointB:CGPointMake(pointB.x, pointB.y)]);
    }
    
    else
    {
        xAngle = atan2((pointA.z - pointB.z), [NV3DMath distance2DFromPointA:CGPointMake(pointA.x, pointA.y)
                                                                       pointB:CGPointMake(pointB.x, pointB.y)]);
    }
    
    SCNVector3 eulerAngles = SCNVector3Make(xAngle, 0.0, zAngle);
    
    
    return eulerAngles;
}

+ (CGFloat)distance3DFromPointA:(SCNVector3)pointA
                         pointB:(SCNVector3)pointB
{
    CGFloat distance = sqrt(pow((pointA.x - pointB.x), 2) +
                            pow((pointA.y - pointB.y), 2) +
                            pow((pointA.z - pointB.z), 2));
    
    return distance;
}

+ (CGFloat)distance2DFromPointA:(CGPoint)pointA
                         pointB:(CGPoint)pointB
{
    CGFloat distance = sqrt(pow((pointA.x - pointB.x), 2) +
                            pow((pointA.y - pointB.y), 2));
    
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