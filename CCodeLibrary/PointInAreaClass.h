//  PointInAreaClass.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"

@interface PointInAreaClass : NSObject

- (BOOL)DPointInArea:(DPOINT *)dPoint;

@property CGContextRef context;
@property void *bitmapData;

@end