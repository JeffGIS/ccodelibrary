//  CRAPI.h
//  CCodeLibrary

@import Foundation;
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
#import "SSDelegate.h"
#import "NVPeerConnect.h"
#import "ChartsBitmap.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NVCRIS_PeripheralManager.h"
#import "SlopeClient.h"
#import "NVSlopeData.h"
#import "WIT_MotionInput.h"
#import "SOLAR-2Input.h"

@import AVKit;
@import CoreMotion;

#ifndef LE_Transfer_TransferService_h
#define LE_Transfer_TransferService_h

#define TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"

#endif
#define NOTIFY_MTU      20
#define DOWNLOAD_DATABASE_FUNCTION 3

typedef NS_ENUM(NSInteger, ModuleNames)
{
    MANAGEMENT_MODULE  =     1,
    PRELIM_MODULE      =     2,
    DETAIL_MODULE      =     3,
    GMMOBILE_MODULE    =     4,
    FAC_MANAGEMENT_MODULE =  5,
    FAC_PRELIM_MODULE     =  6,
    FAC_DETAIL_MODULE  =     7,
    ALLEYWALL_DETAIL_MODULE = 8,
    SIDEWALK_ASSISTANT_MODULE = 9,
    PHOTO_TAKER_MODULE = 10,
};

#define PROJECT_MPLS            1
#define PROJECT_METROGIS        2
#define PROJECT_HUNTING         3


#define RH_QUERY_INTERVAL 3
#define RH_ERROR_INTERVAL 432

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

@interface TrackRoutePoint : NSObject
@property (nonatomic) INT64 refno;
@property (nonatomic) LLPOINT latlon;
@property int time;
@end

@interface CRAPI : NSObject

@property (nonatomic, nullable) id currentMeasurementView;
@property (nonatomic, nullable) id currentUploadView;
@property (nonatomic, nullable) NSMutableArray *savedNotesArray;//temp till store in DB

@property (nonatomic, nullable) WIT_MotionInput *witMotionInput;
@property (nonatomic, nullable) SOLAR2Input *solar2Input;

@property (nonatomic) ModuleNames currentModule;
@property (nonatomic) int currentSubModule;
@property (nonatomic) HardCodedConfigs currentApp;
@property (nonatomic, copy, nullable) NSString *bundleID;
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
@property (nonatomic) BOOL controlledInterface, controllControlledInterface, presentUpsideDown;
@property BOOL allowSidewalk;
@property (nonatomic) int pickApInPixels, project;
@property (nonatomic, copy, nullable) NSString *sharedFilePath;
@property (nonatomic) int showPlats, parcelShadingOption, parcelTextOption;
@property (nonatomic) int parcelColorOption, showTileInfo;
@property (nonatomic, copy, nullable) NSString *currentOverallBoundaryName;
@property (nonatomic, copy, nullable) NSString *currentOverallBoundaryType;
@property (nonatomic) int currentOverallBoundaryRefno, currentBAR;
@property (nonatomic) BOOL showPolylineForBounds, maskBoundsForBounds, setToAlleyWalls, isFromGMMobile;
@property (nonatomic,copy, nonnull) NSString *currentOverallBoundaryTable;
@property (nonatomic) CGFloat maskTransparency;
@property (nonatomic) CGFloat boundaryBorderWidth;
@property (nonatomic, copy, nullable) NSString *sourceApp, *stateID;
@property (nonatomic, nullable) UIView *currentView;
@property (nonatomic) MNMXCORD lastDisplayBounds, lastViewBounds;
@property (nonatomic, copy, nullable) NSString *currentCounty;
@property (nonatomic, copy, nullable) NSString *currentCountyName;
@property (nonatomic, copy, nullable) NSString *currentCity;
@property (nonatomic, copy, nullable) NSString *currentPlatImagePath;
@property (nonatomic, copy, nullable) NSString *currentPlatType;
@property (nonatomic, copy, nullable) NSString *selectedPDFID;
@property (nonatomic, copy, nullable) NSString *extractFile;
@property (nonatomic) BOOL resetPropList, resetFieldList, resetDestinations, resetCrimeList, forAllYears;
@property (nonatomic) NSInteger fromDate, toDate, crimeMode;
@property (nonatomic, copy, nullable) NSString *crimeTarget;
@property (nonatomic, copy, nullable) NSString *crimeCompare;
@property (nonatomic, copy, nullable) NSString *crimeAdjustValue;
@property (nonatomic, copy, nullable) NSString *crimeAdjustValueArea;
@property (nonatomic, copy, nullable) NSString *hotspotVideoMode;
@property (nonatomic, nullable) MapToolbar *mapToolbar;
@property (nonatomic, nullable) UIViewController *mapVC;
@property (nonatomic) CGFloat mapToolbarProgress;
@property (nonatomic) BOOL becameActive, ignoreErrorLog;
@property (nonatomic, copy, nullable) NSString *offsetForBounds;
@property (nonatomic) int offsetForBoundsInMeters, keepProcessing;
@property (nonatomic, copy, nullable) NSString *selectBoundaryFromMapType;
@property (nonatomic, nullable) NVDocumentManager *docManager;
@property (nonatomic) BOOL mapIndividualDest, mapGroupDest;
@property (nonatomic) NSString*  mapPropList;
@property (nonatomic, copy, nullable) NSString *mapCrimeList;
@property (nonatomic) BOOL uploadPix, downloadData, downloadPix;
@property (nonatomic) DataSetTypes newDataset;
@property (nonatomic, copy, nullable) NSString *minManageVersion;
@property (nonatomic, copy, nullable) NSString *minPrelimVersion;
@property (nonatomic, copy, nullable) NSString *minDetailVersion;
@property (nonatomic, copy, nullable) NSString *minAlleyVersion;
@property (nonatomic) int currentMessageNum, serverToUse, showDeveloperFunctions;
@property int databaseToDownload;
@property (nonatomic , nullable) CLLocation *lastLocation;
@property (nonatomic) BOOL hideConnectButton, appChanged, inDataUpdate, inAutoLoopMode;
@property (nonatomic, nullable) NSNumberFormatter *dollarFmt;
@property (nonatomic, nullable) NSNumberFormatter *acreFmt;
@property (nonatomic, nullable) NVSendEmail *currentEmail;
@property (nonatomic, nullable) NSMutableArray *lastAreaText;
@property (nonatomic) BOOL isRentaliPad, canUseSdwk, inSdwkMode, GMTilesVisible, justZoom;
@property long currentSidewalkPointID;
@property (nonnull)Facility *currentFacility;
@property (nonatomic) int facilityFieldDisplayOpt;
@property (nonatomic, nullable) NSMutableArray<ChartsBitmap *> *chartBitmaps;
@property (nonatomic, nullable) HotSpotVideo *hsv;
@property (nonatomic, nullable) dispatch_queue_t vectorQueue;
@property BOOL showCompassCalibrationScreen, barChartOnly, allowLegendMinimize, allowPortraitPhotos;
@property LLPOINT lastPickPoint;
@property (nonatomic, nullable) SSDelegate *spreadsheetDelegate;
@property (nonatomic, nullable) NVPeerConnect *peerConnect;
@property int rhUpdateTime, rhCurrentZip;
@property (nonatomic, copy, nullable) NSURL *rhVideoURL;
@property (nonatomic, nullable) NSMutableString *rhSearchSqlCommands;
@property (nonatomic, copy, nullable) NSString *rhSearchFilePath;
@property BOOL inDevMode;
@property double feetPerStep;
@property (nonatomic, copy, nullable) NSString *currentStepValueID;
@property id showLocationTarget;
@property int cellPadding;
@property (nonatomic) int rebuildYear;
@property BOOL requirePhotoLandscape;
@property SideOfStreet currentSideOfStreet;
@property int firstSidewalkPointIDOnSegment;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *WITMotionPeripheral;
@property (strong, nonatomic) CBPeripheral          *SOLAR2Peripheral;
@property (strong, nonatomic) CBPeripheral          *NVCRIS_Peripheral;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) NVCRIS_PeripheralManager * nvcpm;
@property int NVCRIS_GroupNum;
@property (nonatomic, nullable) NSString *group_NVCRIS_SERVICE_UUID;
@property (nonatomic, nullable) NSString *group_NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID;
@property (nonatomic, nullable) NSString *group_NVCRIS_TAKEPHOTO_CHARACTERISTIC_UUID;
@property (nonatomic, nullable) NSString *group_NVCRIS_PHOTOTAKEN_CHARACTERISTIC_UUID;
@property (nonatomic, nullable) NSString *group_NVCRIS_HOLDFORMEASUREMENT_CHARACTERISTIC_UUID;
@property (nonatomic, nullable) NSString *group_NVCRIS_DOORTIMER_CHARACTERISTIC_UUID;
@property BOOL NVCRIS_Central_Server;
@property BOOL NVCRIS_Slope_Client;
@property (strong, nonatomic) SlopeClient *slopeClient;
@property (nonatomic) int useExternalAccelerometer;
@property NSFileHandle *debugFileHandle;
@property NSString * debugFilePath;
@property dispatch_queue_t peripheralmanque;
@property dispatch_queue_t centralmanque;
@property int holdForMeasurement;
@property (nonatomic, nullable) NVAlertView *connectionAlert;
@property BOOL boschIsAvailable;
@property int currentFocusWaypoint;
@property int currentSelectedWaypoint;
@property (nonatomic, nullable) NSMutableArray *currentRoute;
@property int currentRouteSegment;
@property (nonatomic, nullable) NSMutableArray *currentTrackRoute;
@property int currentRoutePoint;
@property bool evaluateEdges;
@property int maxEvaluaterScore;
@property int currentEvaluaterScore;
@property LLPOINT currentLocation;
@property BOOL locationTrackingEnabled;
@property (nonatomic, nullable) NSNumber *routeBearing;
@property BOOL firstTimeZoomToCentract;
@property BOOL amTrackingRoute;
@property (nonatomic) LLPOINT currentVehicleLocation;


+ (nullable CRAPI *)sharedInstance;

- (void)setCurrentGeoid:(int)currentGeoid;
- (nullable Facility *)facilityInit;
- (nullable NSString *)sharedOutputDirectory:(nullable NSString *)subDir;
- (NSString *)localOutputDirectory:(NSString*)subDir;

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
- (nullable NSString *)getWeatherDataAtLatlon:(LLPOINT)atLatLon;

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
- (void)showReference:(nonnull NSString *)reference;
- (void)uploadToCloud;
- (void)displayChartBitmaps:(nonnull NSTimer *)timer;
- (void)displayHotSpotVideo:(nonnull NSTimer *)timer;
- (nonnull NSArray<NSArray *> *)arrayOutput;
- (void)playBeep;
- (void)playFinalBeep;
- (void)playErrorBeep;
- (void)startBeepTimer:(NSTimeInterval)timeInterval;
- (void)cancelBeepTimer;
- (void)setBeepVolume:(float)volume;
- (nullable CBCentralManager *)getCentralManager:(id)delegate;
- (nullable CBPeripheralManager *) getPeripheralManager:(id)delegate;
- (NVCRIS_PeripheralManager *) getNVCRIS_PeripheralManager:(id)delegate;
- (nullable SlopeClient *) getSlopeClient:(id)delegate;
- (void)sendDebugFile;
- (void) clearDebugFile;
- (void) addToDebugFile:(NSString *)line;
- (void) openDebugFile:(NSString *)name;
- (void) closeDebugFile;
- (void) writeToDebugFile:(NSString *)line;
- (NSString *_Nonnull) getRouteServer;
- (CMMotionManager *) getMotionManager;
- (CLLocationManager *) getLocationManager;
- (void) updateConnectionAlertTitle:(NSString *)text;
- (void) hideConnectionAlert;
-(BOOL) getLastBounds:(LPMNMXCORD)pBounds;
-(BOOL) getLastBounds:(LPMNMXCORD)pBounds
              andZoom:(float *)pZoom;
-(int) addPointToTrackRoute:(CLLocationCoordinate2D) location;

void GSSiViewDidLoad (void);
@end
