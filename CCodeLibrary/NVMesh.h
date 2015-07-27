//  NVMesh.h
//  CCodeLibrary

#import <SceneKit/SceneKit.h>

typedef struct NVMeshTriangle {
    SCNVector3 point1;
    SCNVector3 point2;
    SCNVector3 point3;
} NVMeshTriangle;

@interface NVMesh : SCNGeometry

+ (NVMesh *)meshWithTriangleArray:(NVMeshTriangle *)triangleArray
                            count:(NSUInteger)count;

@end