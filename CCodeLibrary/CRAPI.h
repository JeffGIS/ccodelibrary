//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "CCodeTypes.h"
#import "MPIntersection.h"
#import "Facility.h"
#import "UserDefaults.h"
#import "Colors.h"
#import "MapToolbar.h"
#import "NVDocumentManager.h"

#define MANAGEMENT_MODULE   1
#define PRELIM_MODULE       2
#define DETAIL_MODULE       3
#define FACILITIES_MODULE   4
#define GMMOBILE_MODULE     5

#define PROJECT_MPLS        1
#define PROJECT_METROGIS    2

typedef NS_ENUM(NSInteger, CrimeMapMode)
{
    PINMAP,
    HOTSPOT,
    CHOROPLETH,
};

@interface CRAPI : NSObject

@property (nonatomic) int currentModule;
@property (nonatomic) int currentSubModule;
@property int currentApp;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *outputDirectory;
@property (nonatomic, copy) NSString *imageDirectory;
@property (nonatomic, copy) NSString *uploadDirectory;
@property (nonatomic, copy) NSString *sharedOutputDirectory;
@property (nonatomic, copy) NSString *organizationName;
@property (nonatomic, copy) NSString *mailAddress;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *eMail;
@property int rampCredits;
@property int deviceNumber;
@property int maxDevices;

@property (nonatomic) NSMutableDictionary *deviceLists;
@property (nonatomic, copy) NSString *deviceListsKey;
@property (nonatomic) int currentGeoid;
@property (nonatomic) int currentManageriPad; //sequence number for manager iPad - created by GMServer
@property int currentiPadWithinManager;
@property int totiPadWithinManager;
@property (nonatomic) int GSSiPadNumber; //sequence number for this iPad
@property (nonatomic, copy) NSString *currentCityNameAndState;
@property (nonatomic) int currentIntersection;
@property (nonatomic, copy) NSString *googleKey;
@property BOOL refreshMap, doCompassCalibrate, showParcelBoundary;
@property (nonatomic) NSMutableArray *placesArray;
@property (nonatomic, copy) NSArray *currentPlaceArray;
@property (nonatomic, copy) NSString *placeAreaFile;
@property (nonatomic, copy) NSString *calibrateLength;
@property (nonatomic, copy) NSString *calibrateHeight;
@property (nonatomic) NSMutableArray *assignediPadsArray;
@property (nonatomic) Colors *defaultColors;
@property (nonatomic) NSInteger GMMSetting;
@property (nonatomic, copy) NSString *currentPID;
@property (nonatomic, copy) NSString *currentAddress;
@property (nonatomic, copy) NSString *currentPropOwner;
@property (nonatomic, copy) NSString *selectedPID;
@property (nonatomic) NSMutableArray *annotations;
@property (nonatomic) CGFloat currentZoom;
@property BOOL controlledInterface;
@property BOOL controllControlledInterface;
@property int pickApInPixels;
@property int project;
@property (nonatomic, copy) NSString *sharedFilePath;
@property (nonatomic) int showPlats;
@property int parcelShadingOption;
@property int parcelTextOption;
@property int parcelColorOption;
@property int showTileInfo;
@property (nonatomic, copy) NSString *currentOverallBoundaryName;
@property (nonatomic, copy) NSString *currentOverallBoundaryType;
@property (nonatomic) int currentOverallBoundaryRefno;
@property (nonatomic) BOOL showPolylineForBounds, maskBoundsForBounds;
@property int currentBAR;
@property BOOL setToAlleyWalls, isFromGMMobile;
@property (nonatomic, copy) NSString *sourceApp;
@property (nonatomic) UIView *currentView;
@property MNMXCORD lastDisplayBounds;
@property NSString * currentCounty;
@property (nonatomic) NSString * currentCountyName;
@property (nonatomic) NSString * currentCity;
@property (nonatomic, copy) NSString *currentPlatImagePath;
@property (nonatomic, copy) NSString *currentPlatType;
@property (nonatomic, copy) NSString *selectedPDFID;
@property (nonatomic, copy) NSString *extractFile;
@property BOOL resetPropList, resetDestinations;
@property NSInteger fromDate, toDate;
@property NSInteger crimeMode;
@property (nonatomic, copy) NSString *crimeTarget;
@property (nonatomic, copy) NSString *crimeAdjustValue;
@property (nonatomic, copy) NSString *crimeAdjustValueArea;
@property (strong, nonatomic) MapToolbar *mapToolbar;
@property (strong, nonatomic) UIViewController *mapVC;
@property (nonatomic) CGFloat mapToolbarProgress;
@property BOOL becameActive;
@property (nonatomic, copy) NSString *offsetForBounds;
@property (nonatomic) int offsetForBoundsInMeters;
@property (nonatomic, copy) NSString *selectBoundaryFromMapType;
@property int keepProcessing;
@property (nonatomic) NVDocumentManager *docManager;
@property BOOL mapPropList, mapIndividualDest, mapGroupDest;
@property BOOL uploadPix, downloadData, downloadPix;
@property int dataset;
@property BOOL ignoreErrorLog, showDeveloperFunctions;
@property NSString *minManageVersion;
@property NSString *minPrelimVersion;
@property NSString *minDetailVersion;
@property NSString *minAlleyVersion;
@property int currentMessageNum;
@property int serverToUse;
@property CLLocation *lastLocation;
@property BOOL hideConnectButton, appChanged;
@property NSNumberFormatter *dollarFmt;
@property NSNumberFormatter *acreFmt;
@property MNMXCORD lastViewBounds;
@property BOOL resourcesAvailable;

+ (CRAPI *)sharedInstance;

- (void)setCurrentGeoid:(int)currentGeoid;
- (void)facilityInit:(Facility *)currentFacility;
- (NSString *)sharedOutputDirectory:(NSString*)subDir;

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

- (UIImage *)getStreetViewImageAtLatlon:(LLPOINT)atLatLon
                                heading:(CGFloat)heading
                                  pitch:(CGFloat)pitch
                                    fov:(CGFloat)fov;

- (BOOL)getPlaceIntersectionFile:(id)intFile
                        forGeoid:(int)geoid;

- (NSString *)directoryFromPath:(NSString *)path
                       andName:(NSString *)name
                        create:(BOOL)create;

- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(LPTRANDATA)pTranWToBMP;

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(LPTRANDATA)pTranBMPToW;

- (dbounds)getPickApBoundsAtPoint:(LLPOINT *)pt;
- (dbounds)getPixelPickApBoundsAtPoint:(DPOINT *)pt;

- (dbounds)getBoundsAtPoint:(CLLocationCoordinate2D *)pt
                    andDist:(double)meters;

- (void)clearOutputDirectory;

- (BOOL)appendString:(NSString *)str
              toFile:(NSString *)file;

- (NSInteger)adjustNextRefno:(NSInteger)refno;
- (BOOL)savePlacesString:(NSString*)placesString;
- (BOOL)processPlaces;
- (NSMutableArray *) copyPlaces;
- (int) newPlace:(NSArray *)oldPlaces;
- (BOOL)processPlacesArray:(NSInteger) row;
- (void) transferPlacesArrayToManagePlacesList;
- (BOOL) setGeoIDForCurrentApp;
- (NSString*) getPlacesStringFromFile;
- (void)loadiPadParametersForGeoid:(int)geoid;
- (void)setiPadParametersFromGeoid:(int)geoid;
- (void)deleteImagesForAllZooms:(int)intersectionID;

- (void)updateProgress:(NSInteger)tot
               current:(NSInteger)current
                 range:(int)iRange
             numRanges:(int)nRanges;

- (NSURL *)smartURLForString:(NSString *)str;

-(BOOL) haveErrorLog;
-(NSString*) errorLogPath;
-(void) logToErrorFile:(NSString*) error;
-(void) logToErrorFile:(NSString*) error
            withHeader:(NSString*) header;
-(void) clearErrorFile;
-(void) logToErrorFileIgnore:(BOOL)ignore;
- (BOOL) checkVersion:(NSString**)minVersion;

-(void) gotoAppStore;
- (NSString*) getNVCRISServer;
- (void)checkStorageForMinStorage:(nullable NSNumber *)minStorage;
- (nullable NSString *)countyNameFromCountyID:( nullable NSString*)countyID;
- (nullable NSString *)acreFormat:(double)acres;
- (nullable NSString *)dollarsFormat:(double)dollars;


@end
