
//
//  PointInAreaClass.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeLibrary.h"

@interface PointInAreaClass : NSObject

- (BOOL)DPointInArea:(DPOINT *)dPoint;

@property CGContextRef context;
@property (nonatomic) NSString * areaFile;
@property dbounds bounds;
@property void * bitmapData;
@end
