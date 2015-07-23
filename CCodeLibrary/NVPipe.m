//  NVPipe.m
//  CCodeLibrary

#import "NVPipe.h"
#import "NV3DMath.h"

@implementation NVPipe

+ (NVPipe *)pipeWithPointA:(SCNVector3)pointA
                    pointB:(SCNVector3)pointB
                  diameter:(CGFloat)diameter
                   texture:(NVTexture)texture
                      name:(NSString *)name;
{
    CGFloat height = [NV3DMath distance3DFromPointA:pointA
                                             pointB:pointB];
    
    NVPipe *pipe = [super tubeWithInnerRadius:(diameter * 0.35)
                                  outerRadius:(diameter * 0.50)
                                       height:height];
    
    pipe.eulerAngles = [NV3DMath eulerAnglesFromPointA:pointA
                                                pointB:pointB];
    
    pipe.position = [NV3DMath centerPointFromPointA:pointA
                                             pointB:pointB];
    
    pipe.name = name;
    pipe.radialSegmentCount = 64.0;
    
    switch (texture)
    {
        case NVTextureManhole:
        {
            UIImage *textureImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"manholeTexture"
                                                                                                   ofType:@"png"]];
            
            SKTexture *skTexture = [SKTexture textureWithImage:textureImage];
            pipe.firstMaterial.diffuse.contents = skTexture;
        }
            
            break;
            
        case NVTexturePipe:
        {
            UIImage *textureImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"pipeTexture"
                                                                                                   ofType:@"png"]];
            
            SKTexture *skTexture = [SKTexture textureWithImage:textureImage];
            pipe.firstMaterial.diffuse.contents = skTexture;
        }
            
            break;
            
        default:
            break;
    }
    
    return pipe;
}

@end