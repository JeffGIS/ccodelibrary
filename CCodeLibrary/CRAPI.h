//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"
#import "MPIntersection.h"
#import "UserDefaults.h"
#import "GoogleMaps/GoogleMaps.h"

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
@property (nonatomic) BOOL refreshMap;
@property (nonatomic) NSArray *placesArray;
@property (nonatomic) NSArray *currentPlaceArray;
@property (nonatomic) NSString *placeAreaFile;

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
                                heading:(CGFloat)heading
                                  pitch:(CGFloat)pitch
                                    fov:(CGFloat)fov;

-(BOOL) getPlaceIntersectionFile:(id)id
forGeoid:(int)geoid;

- (NSString*)directoryFromPath:(NSString*)path
                       andName:(NSString*)name
                        create:(BOOL)create;

- (IPOINT)PointAtZoom:(int)zoom
        fromViewPoint:(CGPoint)pt
      usingProjection:(GMSProjection *)projection;

- (IBOUNDS)boundsFromRect:(CGRect)rect
                   atZoom:(int)zoom
          usingProjection:(GMSProjection *)projection;

- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)latlon
          usingTransformation:(LPTRANDATA)pTranWToBMP;

- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(LPTRANDATA)pTranWToBMP;

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(LPTRANDATA)pTranBMPToW;

@end