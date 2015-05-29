//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"
#import "MPIntersection.h"
#import "Facility.h"
#import "UserDefaults.h"
#import "Colors.h"

#define MANAGEMENT_MODULE   1
#define PRELIM_MODULE       2
#define DETAIL_MODULE       3
#define FACILITIES_MODULE   4

#define PROJECT_MPLS        1
#define PROJECT_METROGIS    2

@interface CRAPI : NSObject

@property (nonatomic) int currentModule;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *outputDirectory;
@property (nonatomic, copy) NSString *imageDirectory;
@property (nonatomic, copy) NSString *uploadDirectory;
@property (nonatomic, copy) NSString *sharedOutputDirectory;
@property (nonatomic, copy) NSString *organizationName;

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
@property (nonatomic) NSString *currentPropOwner;
@property (nonatomic) NSMutableArray *annotations;
@property (nonatomic) CGFloat currentZoom;
@property int pickApInPixels;
@property int project;
@property (nonatomic, copy) NSString *sharedFilePath;
@property (nonatomic) int showPlats;
@property int parcelShadingOption;
@property int parcelTextOption;
@property int showTileInfo;
@property BOOL showParcelBoundary;
@property NSString *currentOverallBoundaryName;
@property NSString *currentOverallBoundaryType;
@property int currentOverallBoundaryRefno;
@property BOOL setToAlleyWalls;
@property NSString *sourceApp;

@property NSString *currentPlatImagePath;
@property NSString *currentPlatType;
@property NSString *extractFile;

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

- (BOOL)getPlaceIntersectionFile:(id)intFile
                        forGeoid:(int)geoid;

- (NSString *)directoryFromPath:(NSString*)path
                       andName:(NSString*)name
                        create:(BOOL)create;

- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(LPTRANDATA)pTranWToBMP;

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(LPTRANDATA)pTranBMPToW;

- (dbounds) getPickApBoundsAtPoint:(LLPOINT *)pt;

- (dbounds) getBoundsAtPoint:(CLLocationCoordinate2D*)pt
                     andDist:(CGFloat)meters;
- (void) clearOutputDirectory;
- (BOOL) appendString:(NSString*)str toFile:(NSString*)file;


@end