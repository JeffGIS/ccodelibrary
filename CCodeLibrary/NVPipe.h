//  NVPipe.h
//  CCodeLibrary

typedef NS_ENUM(NSInteger, NVTexture)
{
    NVTextureNone,
    NVTexturePipe,
    NVTextureManhole,
};

#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>

@interface NVPipe : SCNTube

@property (nonatomic) SCNVector3 eulerAngles;
@property (nonatomic) SCNVector3 position;

+ (NVPipe *)pipeWithPointA:(SCNVector3)pointA
                    pointB:(SCNVector3)pointB
                  diameter:(CGFloat)diameter
                   texture:(NVTexture)texture
                      name:(NSString *)name;

@end