//  NVPipe.h
//  CCodeLibrary

typedef NS_ENUM(NSInteger, NVTexture)
{
    NVTextureNone,
};

#import <SceneKit/SceneKit.h>

@interface NVPipe : SCNTube

@property SCNVector3 eulerAngles;
@property SCNVector3 position;

+ (NVPipe *)pipeWithPointA:(SCNVector3)pointA
                    pointB:(SCNVector3)pointB
                  diameter:(CGFloat)diameter
                   texture:(NVTexture)texture;

@end