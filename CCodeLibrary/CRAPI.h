//  CRAPI.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "shr.h"
#import "MathUtil.h"
#import "TileGraphics.h"
#import "MPIntersection.h"
#import "Facility.h"
#import "UserDefaults.h"
#import "Colors.h"
#import "MapToolbar.h"
#import "NVDocumentManager.h"
#import "NVSendEmail.h"
#import "HotSpotVideo.h"

#define MANAGEMENT_MODULE       1
#define PRELIM_MODULE           2
#define DETAIL_MODULE           3
#define GMMOBILE_MODULE         4
#define FAC_MANAGEMENT_MODULE   5
#define FAC_PRELIM_MODULE       6
#define FAC_DETAIL_MODULE       7

#define PROJECT_MPLS            1
#define PROJECT_METROGIS        2

typedef NS_ENUM(NSInteger, CrimeMapMode)
{
    PINMAP,
    HOTSPOT,
    CHOROPLETH,
    LINEGRAPH,
    HOTSPOTVIDEO,
};

typedef NS_ENUM(NSInteger, FieldDisplayOption)
{
    FDOAll,
    FDOInComplete,
    FDONonConforming,
};

@interface TimeRange : NSObject

@property int beginTime, endTime;

@end

@interface AreaText : NSObject

@property int refno;
@property (nonatomic, copy, nonnull) NSString *areaID, *text;

@end

@interface CRAPI : NSObject

@property (nonatomic) int currentModule, currentSubModule, currentApp;
@property (nonatomic, copy, nullable) NSString *documentsDirectory;
@property (nonatomic, copy, nullable) NSString *outputDirectory;
@property (nonatomic, copy, nullable) NSString *imageDirectory;
@property (nonatomic, copy, nullable) NSString *uploadDirectory;
@property (nonatomic, copy, nullable) NSString *sharedOutputDirectory;
@property (nonatomic, copy, nullable) NSString *organizationName;
@property (nonatomic, copy, nullable) NSString *mailAddress;
@property (nonatomic, copy, nullable) NSString *userName;
@property (nonatomic, copy, nullable) NSString *eMail;
@property (nonatomic, copy, nullable) NSString *pdfImageFile;
@property (nonatomic) int rampCredits, deviceNumber, maxDevices;
@property (nonatomic, nullable) NSMutableDictionary *deviceLists;
@property (nonatomic, copy, nullable) NSString *deviceListsKey;
@property (nonatomic) int currentGeoid, currentManageriPad, GSSiPadNumber;
@property (nonatomic) int currentiPadWithinManager, totiPadWithinManager;
@property (nonatomic, copy, nullable) NSString *currentCityNameAndState;
@property (nonatomic) int currentIntersection;
@property (nonatomic, copy, nullable) NSString *googleKey;
@property (nonatomic) BOOL refreshMap, doCompassCalibrate, showParcelBoundary;
@property (nonatomic, nullable) NSMutableArray *placesArray;
@property (nonatomic, copy, nullable) NSArray *currentPlaceArray;
@property (nonatomic, copy, nullable) NSString *placeAreaFile;
@property (nonatomic, copy, nullable) NSString *calibrateLength;
@property (nonatomic, copy, nullable) NSString *calibrateHeight;
@property (nonatomic, nullable) NSMutableArray *assignediPadsArray;
@property (nonatomic, nullable) Colors *defaultColors;
@property (nonatomic) NSInteger GMMSetting;
@property (nonatomic, copy, nullable) NSString *currentPID;
@property (nonatomic, copy, nullable) NSString *currentAddress;
@property (nonatomic, copy, nullable) NSString *currentPropOwner;
@property (nonatomic, copy, nullable) NSString *selectedPID;
@property (nonatomic, nullable) NSMutableArray *annotations;
@property (nonatomic) CGFloat currentZoom;
@property (nonatomic) BOOL controlledInterface, controllControlledInterface;
@property (nonatomic) int pickApInPixels, project;
@property (nonatomic, copy, nullable) NSString *sharedFilePath;
@property (nonatomic) int showPlats, parcelShadingOption, parcelTextOption;
@property (nonatomic) int parcelColorOption, showTileInfo;
@property (nonatomic, copy, nullable) NSString *currentOverallBoundaryName;
@property (nonatomic, copy, nullable) NSString *currentOverallBoundaryType;
@property (nonatomic) int currentOverallBoundaryRefno, currentBAR;
@property (nonatomic) BOOL showPolylineForBounds, maskBoundsForBounds, setToAlleyWalls, isFromGMMobile;
@property (nonatomic, copy, nullable) NSString *sourceApp;
@property (nonatomic, nullable) UIView *currentView;
@property (nonatomic) MNMXCORD lastDisplayBounds, lastViewBounds;
@property (nonatomic, copy, nullable) NSString *currentCounty;
@property (nonatomic, copy, nullable) NSString *currentCountyName;
@property (nonatomic, copy, nullable) NSString *currentCity;
@property (nonatomic, copy, nullable) NSString *currentPlatImagePath;
@property (nonatomic, copy, nullable) NSString *currentPlatType;
@property (nonatomic, copy, nullable) NSString *selectedPDFID;
@property (nonatomic, copy, nullable) NSString *extractFile;
@property (nonatomic) BOOL resetPropList, resetDestinations, resetCrimeList, forAllYears;
@property (nonatomic) NSInteger fromDate, toDate, crimeMode;
@property (nonatomic, copy, nullable) NSString *crimeTarget;
@property (nonatomic, copy, nullable) NSString *crimeCompare;
@property (nonatomic, copy, nullable) NSString *crimeAdjustValue;
@property (nonatomic, copy, nullable) NSString *crimeAdjustValueArea;
@property (nonatomic, nullable) MapToolbar *mapToolbar;
@property (nonatomic, nullable) UIViewController *mapVC;
@property (nonatomic) CGFloat mapToolbarProgress;
@property (nonatomic) BOOL becameActive, ignoreErrorLog;
@property (nonatomic, copy, nullable) NSString *offsetForBounds;
@property (nonatomic) int offsetForBoundsInMeters, keepProcessing;
@property (nonatomic, copy, nullable) NSString *selectBoundaryFromMapType;
@property (nonatomic, nullable) NVDocumentManager *docManager;
@property (nonatomic) BOOL mapIndividualDest, mapGroupDest, mapPropList;
@property (nonatomic, copy, nullable) NSString *mapCrimeList;
@property (nonatomic) BOOL uploadPix, downloadData, downloadPix;
@property (nonatomic) DataSetTypes newDataset;
@property (nonatomic, copy, nullable) NSString *minManageVersion;
@property (nonatomic, copy, nullable) NSString *minPrelimVersion;
@property (nonatomic, copy, nullable) NSString *minDetailVersion;
@property (nonatomic, copy, nullable) NSString *minAlleyVersion;
@property (nonatomic) int currentMessageNum, serverToUse, showDeveloperFunctions;
@property (nonatomic , nullable) CLLocation *lastLocation;
@property (nonatomic) BOOL hideConnectButton, appChanged, inDataUpdate;
@property (nonatomic, nullable) NSNumberFormatter *dollarFmt;
@property (nonatomic, nullable) NSNumberFormatter *acreFmt;
@property (nonatomic, nullable) NVSendEmail *currentEmail;
@property (nonatomic, nullable) NSMutableArray *lastAreaText;
@property (nonatomic) BOOL isRentaliPad, canUseSdwk, inSdwkMode, GMTilesVisible, justZoom;
@property (nonnull)Facility * currentFacility;
@property (nonatomic) int facilityFieldDisplayOpt;
@property (nonatomic, nullable) NSMutableArray <ChartsBitmap *> *chartBitmaps;
@property (nonatomic, nullable) HotSpotVideo *hsv;
@property (nonatomic, nullable) dispatch_queue_t vectorQueue;
@property BOOL showCompassCalibrationScreen;

+ (nullable CRAPI *)sharedInstance;

- (void)setCurrentGeoid:(int)currentGeoid;
- (nullable Facility *)facilityInit;
- (nullable NSString *)sharedOutputDirectory:(nullable NSString *)subDir;

- (void)setIntersectionRotAndQuadDeviders:(nullable NSString *)intAzm
                                   forInt:(nullable MPIntersection *)currentIntersection;

- (int)getCornerFromAdjustedRot:(int)adjustedRot
                 atIntersection:(nullable MPIntersection *)intersection;

- (int)getCornerFromX:(int)x
                 andY:(int)y
       atIntersection:(nullable MPIntersection *)intersection;

- (int)getQuadDeviderFromX:(int)x
                      andY:(int)y
            atIntersection:(nullable MPIntersection *)intersection;

- (BOOL)intersectionAlreadyCompleted:(int)intID;
- (nullable NSString *)getOutputDirectory;

- (nullable UIImage *)getStreetViewImageAtLatlon:(LLPOINT)atLatLon
                                heading:(CGFloat)heading
                                  pitch:(CGFloat)pitch
                                    fov:(CGFloat)fov;

- (BOOL)getPlaceIntersectionFile:(nullable id)intFile
                        forGeoid:(int)geoid;

- (nullable NSString *)directoryFromPath:(nullable NSString *)path
                       andName:(nullable NSString *)name
                        create:(BOOL)create;

- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(nullable LPTRANDATA)pTranWToBMP;

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(nullable LPTRANDATA)pTranBMPToW;

- (dbounds)getPickApBoundsAtPoint:(nullable LLPOINT *)pt;
- (dbounds)getPixelPickApBoundsAtPoint:(nullable DPOINT *)pt;

- (dbounds)getBoundsAtPoint:(nullable CLLocationCoordinate2D *)pt
                    andDist:(double)meters;

- (void)clearOutputDirectory;

- (BOOL)appendString:(nullable NSString *)str
              toFile:(nullable NSString *)file;

- (NSInteger)adjustNextRefno:(NSInteger)refno;
- (BOOL)savePlacesString:(nullable NSString *)placesString;
- (BOOL)processPlaces;
- (nullable NSMutableArray *) copyPlaces;
- (int) newPlace:(nullable NSArray *)oldPlaces;
- (BOOL)processPlacesArray:(NSInteger) row;
- (void) transferPlacesArrayToManagePlacesList;
- (BOOL) setGeoIDForCurrentApp;
- (nullable NSString *)getPlacesStringFromFile;
- (void)loadiPadParametersForGeoid:(int)geoid;
- (void)setiPadParametersFromGeoid:(int)geoid;
- (void)deleteImagesForAllZooms:(int)intersectionID;

- (void)updateProgress:(NSInteger)tot
               current:(NSInteger)current
                 range:(int)iRange
             numRanges:(int)nRanges;

- (nullable NSURL *)smartURLForString:(nullable NSString *)str;

-(BOOL) haveErrorLog;
-(nullable NSString *)errorLogPath;
-(void) logToErrorFile:(nullable NSString *)error;

-(void) logToErrorFile:(nullable NSString *)error
            withHeader:(nullable NSString *)header;

-(void) clearErrorFile;
-(void) logToErrorFileIgnore:(BOOL)ignore;

-(nullable NSString *)appAndVersion;
-(BOOL)isValidVersion:(nullable NSString *)message;

- (void)gotoAppStore;
- (nullable NSString *) getNVCRISServer;
- (void)checkStorageForMinStorage:(nullable NSNumber *)minStorage;
- (nullable NSString *)countyNameFromCountyID:(nullable NSString *)countyID;
- (nullable NSString *)acreFormat:(double)acres;
- (nullable NSString *)dollarsFormat:(double)dollars;
- (nonnull NSArray<TimeRange *> *)getTimeRanges;
- (BOOL) refnoInAreaText:(int) refno;
- (nullable AreaText *) areaTextForRefno:(int) refno;
- (void) showMapToolbarIndicator:(BOOL)show;
- (void)showAlert:(nonnull NSString *)text;
- (void)uploadToCloud;
- (void)displayChartBitmaps:(nonnull NSTimer *)timer;
- (void)displayHotSpotVideo:(nonnull NSTimer *)timer;

@end
