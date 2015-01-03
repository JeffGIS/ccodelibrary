
//
//  PointInAreaClass.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 1/1/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeLibrary.h"

@interface PointInAreaClass : NSObject

- (bool) DPointInArea:(DPOINT *)dPoint;

@property CGContextRef context;
@property (nonatomic) NSString * areaFile;
@property dbounds bounds;
@property void * bitmapData;
@end
