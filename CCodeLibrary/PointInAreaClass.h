//  PointInAreaClass.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"

@interface PointInAreaClass : NSObject

- (BOOL)DPointInArea:(DPOINT *)dPoint;
- (void)setAreaFile:(NSString *)areaFile;

@property int width, height;
@property (nonatomic) CGColorSpaceRef colorSpace;
@property (nonatomic) CGContextRef context;
@property (nonatomic) NSString *areaFile;
@property (nonatomic) dbounds bounds;
@property (nonatomic) LPBYTE bitmapData;
@property BOOL areaLoaded;

@end