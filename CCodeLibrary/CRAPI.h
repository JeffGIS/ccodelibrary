//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"
#import "MPIntersection.h"
#import "UserDefaults.h"

@interface CRAPI : NSObject

+ (CRAPI *)sharedInstance;

@property (nonatomic) NSString *documentsDirectory;
@property (nonatomic) NSString *outputDirectory;
@property (nonatomic) NSString *imageDirectory;
@property (nonatomic) int currentGeoid;
@property (nonatomic) BOOL currentGeoidStatus;
@property (nonatomic) NSString *currentCityNameAndState;
@property (nonatomic) int currentIntersection;
@property (nonatomic) NSString *googleKey;

- (void)setCurrentGeoid:(int)currentGeoid;
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
                                  andZoom:(int)zoom
                             forceRefresh:(BOOL)refresh;

- (UIImage *)getStreetViewImageAtLatlon:(LLPOINT)atLatLon
                            withHeading:(int)heading;

-(BOOL) getPlaceAreaFile:(id)id
forGeoid:(int)geoid;

-(BOOL) getPlaceIntersectionFile:(id)id
forGeoid:(int)geoid;

- (NSString*)directoryFromPath:(NSString*)path
                       andName:(NSString*)name;

@end