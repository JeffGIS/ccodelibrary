//  NVMesh.m
//  CCodeLibrary

#import "NVMesh.h"

@implementation NVMesh

+ (NVMesh *)meshWithTriangleArray:(NVMeshTriangle *)triangleArray
                            count:(NSUInteger)count
{
    NSUInteger pointCount = (count * 3);
    NSUInteger indexCount = (count * 9);
    
    SCNGeometrySource *meshSource = [SCNGeometrySource geometrySourceWithVertices:(SCNVector3 *)triangleArray
                                                                            count:pointCount];
    
    int *meshIndex = malloc(indexCount * sizeof(int) + 4);
    
    for (int i = 0; i < indexCount; i++)
        meshIndex[i] = i;
    
    NSData *meshIndexData = [NSData dataWithBytes:meshIndex
                                           length:indexCount * sizeof(int)];
    
    free(meshIndex);
    
    SCNGeometryElement *meshElement = [SCNGeometryElement geometryElementWithData:meshIndexData
                                                                    primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                   primitiveCount:count
                                                                    bytesPerIndex:sizeof(int)];
    
    NVMesh *mesh = [super geometryWithSources:@[meshSource]
                                     elements:@[meshElement]];
    
    return mesh;
}

@end