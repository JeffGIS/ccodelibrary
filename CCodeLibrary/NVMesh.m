//  NVMesh.m
//  CCodeLibrary

#import "NVMesh.h"
#import "CCodeLibrary/MathUtil.h"

@implementation NVMesh

+ (NVMesh *)meshWithTriangleArray:(NVMeshTriangle *)triangleArray
                            count:(NSUInteger)count
{
    NSUInteger pointCount = (count * 3);
    NSUInteger indexCount = (count * 9);
    
    SCNGeometrySource *meshSource = [SCNGeometrySource geometrySourceWithVertices:(SCNVector3 *)triangleArray
                                                                            count:pointCount];
    
    SCNVector3 *meshNormals = malloc(pointCount * sizeof(SCNVector3) + 4);
    vec3 *trianglePoints = malloc(3 * sizeof(vec3) + 4);
    
    for (int i = 0; i < count; i++)
    {
        int j = (i * 3);
        
        NVMeshTriangle triangle = triangleArray[i];
        trianglePoints[0].x = triangle.point1.x;
        trianglePoints[0].y = triangle.point1.y;
        trianglePoints[0].z = triangle.point1.z;
        trianglePoints[1].x = triangle.point2.x;
        trianglePoints[1].y = triangle.point2.y;
        trianglePoints[1].z = triangle.point2.z;
        trianglePoints[2].x = triangle.point3.x;
        trianglePoints[2].y = triangle.point3.y;
        trianglePoints[2].z = triangle.point3.z;
        
        vec3 normal = GetTriangleNormal(&trianglePoints[0], &trianglePoints[1], &trianglePoints[2]);
        
        meshNormals[j + 2] = meshNormals[j + 1] = meshNormals[j] =
        SCNVector3Make(normal.x, normal.y, normal.z);
    }
    
    SCNGeometrySource *normalsSource = [SCNGeometrySource geometrySourceWithNormals:meshNormals
                                                                              count:pointCount];
    
    free(meshNormals);
    
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
    
    NVMesh *mesh = [super geometryWithSources:@[meshSource, normalsSource]
                                     elements:@[meshElement]];
    
    return mesh;
}

@end