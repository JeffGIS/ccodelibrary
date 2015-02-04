//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"
#import "MPIntersection.h"
#import "Facility.h"
#import "UserDefaults.h"
#import "Colors.h"

#define MANAGEMENT_MODULE 1
#define PRELIM_MODULE 2
#define DETAIL_MODULE 3
#define FACILITIES_MODULE 4

@interface CRAPI : NSObject

@property (nonatomic) int currentModule;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *outputDirectory;
@property (nonatomic, copy) NSString *imageDirectory;
@property (nonatomic, copy) NSString *uploadDirectory;
@property (nonatomic) int currentGeoid;
@property (nonatomic) int currentManageriPad; //sequence number for manager iPad - created by GMServer
@property (nonatomic) int currentUserID; //sequence number for this iPad
@property (nonatomic, copy) NSString *currentCityNameAndState;
@property (nonatomic) int currentIntersection;
@property (nonatomic, copy) NSString *googleKey;
@property (nonatomic) BOOL refreshMap;
@property (nonatomic) NSArray *placesArray;
@property (nonatomic) NSArray *currentPlaceArray;
@property (nonatomic, copy) NSString *placeAreaFile;
@property (nonatomic) BOOL doCompassCalibrate;
@property (nonatomic, copy) NSString *calibrateLength;
@property (nonatomic, copy) NSString *calibrateHeight;
@property (nonatomic) NSMutableArray *assignediPadsArray;
@property (nonatomic) Colors *defaultColors;
@property (nonatomic) NSInteger GMMSetting;
@property (nonatomic) NSString *currentPID;
@property (nonatomic) NSString *currentAddress;
@property (nonatomic) NSMutableArray *annotations;

//temporary visibility stuff
@property BOOL GMTilesVisible;
@property int parcelsVisibleAtZoom;
@property int sewerVisibleAtZoom;
@property int parcelShadingOption;
@property int showTileInfo;


+ (CRAPI *)sharedInstance;

- (void)setCurrentGeoid:(int)currentGeoid;
- (void)intersectionInit:(MPIntersection *)currentIntersection;
- (void)facilityInit:(Facility *)currentFacility;

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

- (BOOL)getPlaceIntersectionFile:(id)id
forGeoid:(int)geoid;

- (NSString*)directoryFromPath:(NSString*)path
                       andName:(NSString*)name
                        create:(BOOL)create;

- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)latlon
          usingTransformation:(LPTRANDATA)pTranWToBMP;

- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(LPTRANDATA)pTranWToBMP;

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(LPTRANDATA)pTranBMPToW;

@end