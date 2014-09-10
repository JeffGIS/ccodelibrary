//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "MPIntersection.h"

@interface CRAPI : NSObject

+ (CRAPI *)sharedInstance;

@property NSString *outputDirectory;
@property NSString *imageDirectory;
@property int currentGeoid;
@property NSString *currentCityNameAndState;
@property NSMutableArray *intersectionPointsArray;
@property BOOL shouldDismissTwice;

- (void)intersectionInit:(MPIntersection *)currentIntersection;

- (void)setIntersectionRotAndQuadDeviders:(NSString *)intAzm
                                   forInt:(MPIntersection *)currentIntersection;

- (int)getCornerFromAdjustedRot:(int)adjustedRot
                 atIntersection:(MPIntersection *)intersection;

- (int)getCornerFromX:(int)x
                 andY:(int)y
       atIntersection:(MPIntersection *)intersection;

- (int)getQuadDeviderFromX:(int)x
                      andY:(int)y
            atIntersection:(MPIntersection *)intersection;

- (BOOL)intersectionAlreadyCompleted:(int)intID;
- (NSString *)getOutputDirectory;

- (NSString *)getImageFileforIntersection:(int)intersectionID
                                    atLat:(double)lat
                                   andLon:(double)lon
                                  andZoom:(int)zoom;

-(BOOL) getPlaceAreaFile:(id)id
forGeoid:(int)geoid;

-(BOOL) getPlaceIntersectionFile:(id)id
forGeoid:(int)geoid;

- (NSString*)directoryFromPath:(NSString*)path
                       andName:(NSString*)name;

@end