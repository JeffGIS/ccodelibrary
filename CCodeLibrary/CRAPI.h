//  CRAPI.h
//  ADAFieldCollector2
//
//  Created by JEFFREY E SMITH on 5/27/14.
//  Copyright (c) 2014 GSSi. All rights reserved.

#import <Foundation/Foundation.h>
#import "MPIntersection.h"

@interface CRAPI : NSObject

+ (CRAPI *)sharedInstance;

@property NSString *outputDirectory;
@property NSString *imageDirectory;

- (void)intersectionInit:(MPIntersection*)currentIntersection;

- (void)setIntersectionRotAndQuadDeviders:(NSString *)intAzm
                                   forInt:(MPIntersection*)currentIntersection;

- (int)getCornerFromAdjustedRot:(int)adjustedRot
                 atIntersection:(MPIntersection*)intersection;

- (int)getCornerFromX:(int)x
                 andY:(int)y
       atIntersection:(MPIntersection*)intersection;

- (int)getQuadDeviderFromX:(int)x
                      andY:(int)y
            atIntersection:(MPIntersection*)intersection;

- (BOOL)intersectionAlreadyCompleted:(int)intID;
- (NSString *)getOutputDirectory;

- (NSString *)getImageFileforIntersection:(int)intersectionID
                                    atLat:(double)lat
                                   andLon:(double)lon;
@end