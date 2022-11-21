//  CRAPI.m
//  CCodeLibrary

#import "CRAPI.h"
#import "GSSiDefs.h"
#import "CityOrOrganizationData.h"
#import "NVAlertView.h"
#import "UIApplication+VersionBuild.h"
#import "ManagePlacesDatabase.h"
#import "SharedDefaults.h"
#include "shr.h"
#import "NVDocumentManager.h"
#import "ChartsBitmapVC.h"
#import "HotSpotVideoVC.h"
#import "NVReferenceView.h"
#import "NVCRIS_UUIDs.h"
#import "NVSendEmail.h"

NVSlopeData CurrentSlopeData;

@implementation TimeRange

@end

@implementation AreaText

@end

@interface CRAPI () <NVAlertViewDelegate, NVDocumentManagerDelegate>

@property (nonatomic, nullable) NVAlertView *alert;
@property int kp, currentGeoidValue, numAllowedZooms;
@property (nonatomic, nullable) AVAudioPlayer *beep, *finalBeep;
@property (nonatomic, nullable) NSTimer *beepTimer;
@property (nonatomic, nullable) NSString * routeServer;
@property (nonatomic, nullable) CMMotionManager *motionManager;
@property (nonatomic, nullable) CLLocationManager *locationManager;

@end

@implementation CRAPI
{
    int _allowedZooms[3];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _bundleID = NSBundle.mainBundle.bundleIdentifier;

#ifdef DEBUG
        if ([UIDevice.currentDevice.name isEqualToString:@"WildBill iPhone"] ||
            [UIDevice.currentDevice.name isEqualToString:@"GSSiRental015"])
        {
            //_bundleID = @"com.gssi.newvisioncrime";
            //_bundleID = @"com.gssi.newvisionmetro";
        }
        
        else
        {
            //_bundleID = @"com.gssi.newvisioncrime";
            _bundleID = @"com.gssi.newvisionmngame";
            _bundleID = @"com.gssi.newvisionaccess";
            _bundleID = @"com.gssi.newvisionmetro";
        }
#endif
        
        _vectorQueue = dispatch_queue_create("vectorQueue", NULL);
        _newDataset = CURBRAMPS;
        //_newDataset = ALLEYWALLS;
        _kp = 0;
        _boschIsAvailable = NO;
        _currentGeoidValue = 0;
        _pickApInPixels = 50;
        _numAllowedZooms = 3;
        _allowedZooms[0] = 21;
        _allowedZooms[1] = 20;
        _allowedZooms[2] = 19;
        _maxDevices = 100;
        _documentsDirectory = UserDefaults.defaults.localFilePath;
        _extractFile = [NSString stringWithFormat:@"%@/extract.bmp", _documentsDirectory];
        _crimeMode = (CrimeMapMode)[UserDefaults.defaults integerForKey:@"CrimeMode"];
        _mapPropList = [UserDefaults.defaults stringForKey:@"MapPropList"];
        _mapCrimeList = [UserDefaults.defaults stringForKey:@"MapCrimeList"];
        NSString *defaultCrimeTarget = [UserDefaults.defaults stringForKey:@"CrimeTarget"];
        _peerConnect = NVPeerConnect.new;
        _stateID = @"Default";
        
        if (defaultCrimeTarget && defaultCrimeTarget.length)
            _crimeTarget = defaultCrimeTarget;
        
        else
        {
            _crimeTarget = @"Minneapolis Neighborhoods";
            [UserDefaults.defaults saveString:_crimeTarget forKey:@"CrimeTarget"];
        }
        
        NSString *defaultCrimeAdjustValue = [UserDefaults.defaults stringForKey:@"CrimeAdjustValue"];
        
        if (defaultCrimeAdjustValue && defaultCrimeAdjustValue.length)
            _crimeAdjustValue = defaultCrimeAdjustValue;
        
        NSString *defaultCrimeAdjustValueArea = [UserDefaults.defaults stringForKey:@"CrimeAdjustValueArea"];
        
        if (defaultCrimeAdjustValueArea && defaultCrimeAdjustValueArea.length)
            _crimeAdjustValueArea = defaultCrimeAdjustValueArea;
        
        NSString *defaultCrimeCompare = [UserDefaults.defaults stringForKey:@"CrimeCompareValue"];
        
        if (defaultCrimeCompare && defaultCrimeCompare.length)
            _crimeCompare = defaultCrimeCompare;
        
        NSString *defaultHotspotVideoMode = [UserDefaults.defaults stringForKey:@"Hotspot Video Mode"];
        
        if (defaultHotspotVideoMode && defaultHotspotVideoMode.length)
            _hotspotVideoMode = defaultHotspotVideoMode;

        _docManager = NVDocumentManager.new;
        _deviceLists = NSMutableDictionary.new;
        _assignediPadsArray = NSMutableArray.new;
        _controlledInterface = ![SharedDefaults.defaults boolForKey:@"UncontrolledInterface"];
        _uploadPix = [SharedDefaults.defaults boolForKey:@"UploadPix"];
        _downloadData = [SharedDefaults.defaults boolForKey:@"DownloadData"];
        _downloadPix = [SharedDefaults.defaults boolForKey:@"DownloadPix"];
        _forAllYears = [UserDefaults.defaults boolForKey:@"ForAllYears"];
        _minManageVersion  = @"";
        _minPrelimVersion = @"";
        _minDetailVersion = @"";
        _minAlleyVersion  = @"";
        _serverToUse = 3;
        _doCompassCalibrate = YES;
        _showDeveloperFunctions = isGSSiDevice();
        _appChanged = NO;
        _currentBAR = 0;
        _currentCounty = @"053";
        _dollarFmt = [[NSNumberFormatter alloc] init];
        _dollarFmt.numberStyle = NSNumberFormatterCurrencyStyle;
        _dollarFmt.groupingSeparator = @"'";
        _dollarFmt.groupingSize = 3;
        _dollarFmt.alwaysShowsDecimalSeparator = NO;
        _dollarFmt.usesGroupingSeparator = YES;
        _dollarFmt.maximumFractionDigits = 0;
        _acreFmt = [[NSNumberFormatter alloc] init];
        _acreFmt.numberStyle = NSNumberFormatterNoStyle;
        _acreFmt.roundingMode = NSNumberFormatterRoundHalfUp;
        _acreFmt.groupingSeparator = @",";
        _acreFmt.groupingSize = 3;
        _acreFmt.alwaysShowsDecimalSeparator = NO;
        _acreFmt.usesGroupingSeparator = YES;
        _acreFmt.maximumFractionDigits = 2;
        _showCompassCalibrationScreen = YES;
        _boundaryBorderWidth = 4;
        _allowLegendMinimize = YES;
        _allowPortraitPhotos = NO;
        _feetPerStep = 2.5;
        [self setRouteServer:@"Both"];
        [self getUseExternalAccelerometer];
        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@",
                                UserDefaults.defaults.localFilePath,
                                [UserDefaults.defaults stringForKey:@"RHVideoPath"]];
        
        if (outputPath && outputPath.length)
        {
            NSURL *outputURL = [NSURL fileURLWithPath:outputPath isDirectory:NO];
            _rhVideoURL = outputURL;
        }
        _rebuildYear = max (2012,(int)[UserDefaults.defaults integerForKey:@"RebuildYear"]);
        _requirePhotoLandscape = YES;
        _currentSideOfStreet = SideOfStreetNotSet;
        {
            NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
            _NVCRIS_GroupNum = (int)[defaults integerForKey:@"NVCRIS_group_number"];
            if (!_NVCRIS_GroupNum)
            {
                NSString *deviceName = UIDevice.currentDevice.name;
                NSString *deviceNumber = textAfterLastChar(deviceName, @" ");
                _NVCRIS_GroupNum = deviceNumber.intValue;
            }
            NSString * tst = [defaults stringForKey:@"NVCRIS_group_number"];
            NSString * tst2 = [defaults stringForKey:@"NVCRIS group number"];
            _NVCRIS_GroupNum = max (_NVCRIS_GroupNum,1);
            char groupc = '1' + _NVCRIS_GroupNum - 1;
            _group_NVCRIS_SERVICE_UUID = replaceLastChar(NVCRIS_SERVICE_UUID,groupc);
            _group_NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID = replaceLastChar(NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID,groupc);
            _group_NVCRIS_TAKEPHOTO_CHARACTERISTIC_UUID = replaceLastChar(NVCRIS_TAKEPHOTO_CHARACTERISTIC_UUID,groupc);
            _group_NVCRIS_PHOTOTAKEN_CHARACTERISTIC_UUID = replaceLastChar(NVCRIS_PHOTOTAKEN_CHARACTERISTIC_UUID,groupc);
            _group_NVCRIS_HOLDFORMEASUREMENT_CHARACTERISTIC_UUID = replaceLastChar(NVCRIS_HOLDFORMEASUREMENT_CHARACTERISTIC_UUID,groupc);
            _group_NVCRIS_DOORTIMER_CHARACTERISTIC_UUID = replaceLastChar(NVCRIS_DOORTIMER_CHARACTERISTIC_UUID,groupc);
            _NVCRIS_Central_Server = (int)[defaults integerForKey:@"NVCRIS_central_server"];
            _NVCRIS_Slope_Client = (int)[defaults integerForKey:@"NVCRIS_slope_client"];

        }
        _savedNotesArray = NSMutableArray.new;
    }
    
    return self;
}

+ (CRAPI *)sharedInstance
{
    static CRAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,
                  ^{
                      sharedInstance = [[CRAPI alloc] init];
                      sharedInstance.GSSiPadNumber = -1;
                  });
    
    return sharedInstance;
}
- (CMMotionManager *) getMotionManager
{
    if (!_motionManager)
        _motionManager = CMMotionManager.new;
    return _motionManager;
}
- (CLLocationManager *) getLocationManager
{
    if (!_locationManager)
        _locationManager = CLLocationManager.new;
    return _locationManager;
}
- (nullable CBCentralManager *)getCentralManager:(id)delegate
{
    if (!self.centralManager)
    {
        _centralmanque = nil;//dispatch_queue_create("com.gssi.centralManQue", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:delegate queue:_centralmanque];
    }
    self.centralManager.delegate = delegate;
    return self.centralManager;
}
- (void) updateConnectionAlertTitle:(NSString *)text
{
    if (!_connectionAlert)
    {
        _connectionAlert = [NVAlertView showLargeAlertViewinView:UIApplication.sharedApplication.keyWindow
                                                        delegate:CRAPI.sharedInstance
                                                           title:text
                                                 buttonTextArray:@[@"Go to Upload Screen",@"Exit Application"]
                                                destructiveIndex:0];
        
        _connectionAlert.identifier = @"BlueToothConnections";
    }
    [_connectionAlert updateTitle:text];
}
- (void) hideConnectionAlert
{
    if (_connectionAlert)
    {
        [_connectionAlert hideLargeAlertView:YES];
        _connectionAlert = nil;
    }
}
- (nullable CBPeripheralManager *) getPeripheralManager:(id)delegate
{
    if (!self.peripheralManager)
    {
        [self updateConnectionAlertTitle:@"Assistant Disconnected\niPhone Disconnected"];
        _peripheralmanque = nil;//dispatch_queue_create("com.gssi.peripheralManQue", DISPATCH_QUEUE_SERIAL);
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:delegate queue:_peripheralmanque];
    }
    self.peripheralManager.delegate = delegate;
    return self.peripheralManager;
}

- (nullable SlopeClient *) getSlopeClient:(id)delegate
{
    if (!self.slopeClient)
        self.slopeClient = [[SlopeClient alloc] init];
    self.slopeClient.delegate = delegate;
    return self.slopeClient;
}
- (void) setRouteServer:(NSString *)routeServer
{
    _routeServer = routeServer;
    [UserDefaults.defaults saveString:_routeServer forKey:@"RouteServer"];
}
- (NSString *_Nonnull) getRouteServer
{
    if (_routeServer.length)
        return _routeServer;
    
    _routeServer = [UserDefaults.defaults stringForKey:@"RouteServer"];

    if (_routeServer.length)
    {
        _routeServer = @"GOOGLE";
        [UserDefaults.defaults saveString:_routeServer forKey:@"RouteServer"];
    }
    return _routeServer;
}

- (NVCRIS_PeripheralManager *) getNVCRIS_PeripheralManager:(id)delegate
{
    if (!_nvcpm)
        _nvcpm = NVCRIS_PeripheralManager.new;
    _nvcpm.delegate = delegate;
    return _nvcpm;
}
- (void)setNewDataset:(DataSetTypes)newDataset
{
    _newDataset = newDataset;
}

- (NSString *)sharedOutputDirectory
{
    NSString* outdir = [NSString stringWithFormat:@"%@/OutputFiles",self.sharedFilePath];
    [NSFileManager.defaultManager createDirectoryAtPath:outdir
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
    return outdir;
}

- (NSString *)sharedOutputDirectory:(NSString*)subDir
{
    NSString* outdir = [NSString stringWithFormat:@"%@/OutputFiles/%@/%i/%i",
                        self.sharedFilePath,subDir,self.currentManageriPad,self.currentGeoid];
    
    [NSFileManager.defaultManager createDirectoryAtPath:outdir
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
    return outdir;
}

- (NSString *)localOutputDirectory:(NSString*)subDir
{
    NSString* outdir = [NSString stringWithFormat:@"%@/%@",
                        self.documentsDirectory,subDir];
    
    [NSFileManager.defaultManager createDirectoryAtPath:outdir
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
    return outdir;
}

- (int)currentGeoid
{
    return _currentGeoidValue;
}

- (void)setCurrentManageriPad:(int)currentManageriPad
{
    _currentManageriPad = currentManageriPad;
    _uploadDirectory = [NSString stringWithFormat:@"PedRampSurvey/%i/%i", _currentManageriPad, _currentGeoidValue];
}

- (void)setCurrentIntersection:(int)currentIntersection
{
    _currentIntersection = currentIntersection;
}

- (void)setCurrentApp:(HardCodedConfigs)currentApp
{
    _currentApp = currentApp;
}

- (void) setCurrentModule:(ModuleNames)currentModule
{
    _currentModule = currentModule;
    switch (currentModule)
    {
        case FAC_DETAIL_MODULE:
            _currentFacility = [self facilityInit];
            _currentApp = HCConfigFacilities;
            break;
        case FAC_PRELIM_MODULE:
        case FAC_MANAGEMENT_MODULE:
            _currentApp = HCConfigFacilities;
            break;
        case ALLEYWALL_DETAIL_MODULE:
            _currentApp = HCConfigAlleyWalls;
            break;
        case MANAGEMENT_MODULE:
        case DETAIL_MODULE:
        case PRELIM_MODULE:
            _currentApp = HCConfigCurbRamps;
            break;
    }
}

- (void)setCurrentGeoid:(int)geoid
{
    if (geoid != _currentGeoidValue)
    {
        _currentGeoidValue = geoid;
        [self loadiPadParametersForGeoid:geoid];
        if (_currentManageriPad == 0)
        {
            _currentManageriPad = _GSSiPadNumber;
            _currentiPadWithinManager = 1;
            _totiPadWithinManager = 1;
            [self saveiPadIDs];
        }
        _outputDirectory = [NSString stringWithFormat:@"%@/%i/ADAFiles", _documentsDirectory, _currentGeoidValue];
        _imageDirectory = [NSString stringWithFormat:@"%@/%i/IntersectionImages", UserDefaults.defaults.sharedFilePath, _currentGeoidValue];
        _deviceListsKey = [NSString stringWithFormat:@"iPads:%i", CRAPI.sharedInstance.currentGeoid];
        
        [NSFileManager.defaultManager createDirectoryAtPath:_outputDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
        
        [NSFileManager.defaultManager createDirectoryAtPath:_imageDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
        
        _uploadDirectory = [NSString stringWithFormat:@"PedRampSurvey/%i/%i", _currentManageriPad, geoid];
    }
}

- (void)setInAutoLoopMode:(BOOL)inAutoLoopMode
{
    static BOOL saveIdleTimer = NO;
    
    _inAutoLoopMode = inAutoLoopMode;
    
    if (inAutoLoopMode)
    {
        saveIdleTimer = UIApplication.sharedApplication.idleTimerDisabled;
        UIApplication.sharedApplication.idleTimerDisabled = YES;
    }
    
    else
        UIApplication.sharedApplication.idleTimerDisabled = saveIdleTimer;
}

-(void) setCurrentOverallBoundaryRefno:(int)i
{
    _currentBAR = i;
}

-(int) currentOverallBoundaryRefno
{
    return _currentBAR;
}

-(void) setLastDisplayBounds:(MNMXCORD)lastDisplayBounds
{
    _lastDisplayBounds = lastDisplayBounds;
    NSString *sBounds = [NSString stringWithFormat:@"%f,%f,%f,%f,%f",lastDisplayBounds.xmn,lastDisplayBounds.xmx,lastDisplayBounds.ymn,lastDisplayBounds.ymx,_currentZoom];
    [UserDefaults.defaults saveString:sBounds forKey:@"LastBounds"];
}
-(BOOL) getLastBounds:(LPMNMXCORD)pBounds
{
    NSString *lastBounds = [UserDefaults.defaults stringForKey:@"LastBounds"];
    NSArray <NSString*>*array = [lastBounds componentsSeparatedByString:@","];
    if (array.count >= 4)
    {
        pBounds->xmn = array[0].doubleValue;
        pBounds->xmx = array[1].doubleValue;
        pBounds->ymn = array[2].doubleValue;
        pBounds->ymx = array[3].doubleValue;
        return TRUE;
    }
    else
        return FALSE;
}
-(BOOL) getLastBounds:(LPMNMXCORD)pBounds
              andZoom:(float *)pZoom;
{
    BOOL rtn = FALSE;
    *pZoom = 12.0;
    NSString *lastBounds = [UserDefaults.defaults stringForKey:@"LastBounds"];
    NSArray <NSString*>*array = [lastBounds componentsSeparatedByString:@","];
    if (array.count >= 4)
    {
        pBounds->xmn = array[0].doubleValue;
        pBounds->xmx = array[1].doubleValue;
        pBounds->ymn = array[2].doubleValue;
        pBounds->ymx = array[3].doubleValue;
        if (array.count == 5)
            *pZoom = array[4].doubleValue;
        rtn = TRUE;
    }
    else
        rtn = FALSE;
    return rtn;
}
-(BOOL)showPolylineForBounds
{
    return _showPolylineForBounds;
}

-(BOOL)maskBoundsForBounds
{
    return _maskBoundsForBounds;
}

-(void)setCurrentOverallBoundaryName:(NSString *)currentOverallBoundaryName
{
    _currentOverallBoundaryName = currentOverallBoundaryName;
}

-(void)setSelectBoundaryFromMapType:(NSString *)selectBoundaryFromMapType
{
    _selectBoundaryFromMapType = selectBoundaryFromMapType;
}

 -(void)setCurrentPID:(NSString *)currentPID
{
    _currentPID = currentPID;
}

-(void)setCurrentZoom:(CGFloat)zoom
{
    _currentZoom = zoom;
}

- (int) keepProcessing
{
    return _kp;
}

-(void)setKeepProcessing:(int)kp
{
    _kp = kp;
}

-(void)setShowPlats:(int)showPlats
{
    _showPlats = showPlats;
}

-(void) setCrimeAdjustValue:(NSString *)crimeAdjustValue
{
    _crimeAdjustValue = crimeAdjustValue;
}

- (NSString *)uploadDirectory
{
    NSString *uploadDirectory = [NSString stringWithFormat:@"PedRampSurvey/%i/%i", _currentManageriPad, _currentGeoidValue];
    return uploadDirectory;
}
- (NSString *) boundsForFacilityImage:(NSString *)image
{
    NSString *path = [NSBundle.mainBundle pathForResource:@"imageBounds" ofType:@"txt"];
    NSString * bounds = @"";
    NSString * file = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray * lines = [file componentsSeparatedByString:@"\n"];
    for (NSString * line in lines)
    {
        NSString *line2 = [line stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSArray * fields = [line2 componentsSeparatedByString:@"\t"];
        NSString * imageName = fields[0];
        if ([imageName isEqualToString:image])
        {
            bounds = fields[1];
            break;
        }
    }
    return bounds;
}
- (Facility *)facilityInit
{
    self.currentGeoid = 608100;//22;
    Facility *currentFacility = Facility.new;
    currentFacility.facID = 1;
    NSArray * names = [NSArray arrayWithObjects:@"City Hall Site",@"Parking Lot 1",@"Parking Lot 2",@"Parking Lot 3",@"Parking Lot 4",@"City Hall",@"Police", nil];
    currentFacility.name = @"Eagan City Hall";
    currentFacility.imagePaths = NSMutableArray.array;
    currentFacility.imageTypes = NSMutableArray.array;
    currentFacility.imageDescriptions = NSMutableArray.array;
    currentFacility.cbounds = NSMutableArray.array;
    
    for (NSString *name in names)
    {
        NSString *path = [NSBundle.mainBundle pathForResource:name ofType:@"png"];
        path = [path stringByDeletingPathExtension];
        [currentFacility.imagePaths addObject:path];
        [currentFacility.imageTypes addObject:@"png"];
        [currentFacility.imageDescriptions addObject:name];
        NSString * bounds = [self boundsForFacilityImage:name];
        [currentFacility.cbounds addObject:bounds];
    }
    NSString * path = [NSBundle.mainBundle pathForResource:@"1995 City Hall Plans A03" ofType:@"jpg"];
    path = [path stringByDeletingPathExtension];
    [currentFacility.imagePaths addObject:path];
    [currentFacility.imageTypes addObject:@"jpg"];
    [currentFacility.imageDescriptions addObject:@"Lower Level"];
    NSString * bounds = [self boundsForFacilityImage:@"Lower Level"];
    [currentFacility.cbounds addObject:bounds];

    path = [NSBundle.mainBundle pathForResource:@"1995 City Hall Plans A04" ofType:@"jpg"];
    path = [path stringByDeletingPathExtension];
    [currentFacility.imagePaths addObject:path];
    [currentFacility.imageTypes addObject:@"jpg"];
    [currentFacility.imageDescriptions addObject:@"Entry Level"];
    bounds = [self boundsForFacilityImage:@"Entry Level"];
    [currentFacility.cbounds addObject:bounds];

    path = [NSBundle.mainBundle pathForResource:@"1995 City Hall Plans A05" ofType:@"jpg"];
    path = [path stringByDeletingPathExtension];
    [currentFacility.imagePaths addObject:path];
    [currentFacility.imageTypes addObject:@"jpg"];
    [currentFacility.imageDescriptions addObject:@"Upper Level"];
    bounds = [self boundsForFacilityImage:@"Upper Level"];
    [currentFacility.cbounds addObject:bounds];

/*    path = [NSBundle.mainBundle pathForResource:@"1995 City Hall Plans A06" ofType:@"jpg"];
    path = [path stringByDeletingPathExtension];
    [currentFacility.imagePaths addObject:path];
    [currentFacility.imageTypes addObject:@"jpg"];
    [currentFacility.imageDescriptions addObject:@"Council Chambers"];*/
    return currentFacility;
}

- (int)adjustQuadDev:(int)normalRot
            fromAZMs:(NSArray *)azms
          withIntRot:(int)intRot
{
    int rtn = normalRot+intRot;
    int minDiff = 999;
    int minRot = 0;
    
    for (NSString *cazm in azms)
    {
        float az = cazm.floatValue;
        int adjustedRot = ClockwiseDegFromNorth((az * RADtoDEG) + intRot);
        int diff = abs(normalRot - adjustedRot);
        
        if (diff < minDiff)
        {
            minDiff = diff;
            minRot = adjustedRot;
        }
     
    }
    
    if (minDiff < 45)
        rtn = minRot;
    
    return rtn;
}

- (void)setIntersectionRotAndQuadDeviders:(NSString *)intAzm
                                   forInt:(MPIntersection *)currentIntersection
{
    if (!currentIntersection.intRotation)
        currentIntersection.intRotation = [self intRotFromintAZMS:intAzm];
    NSArray *azm = [intAzm componentsSeparatedByString:@"|"];
    
    currentIntersection.quadDev0 = currentIntersection.intRotation;
    
    currentIntersection.quadDev90 = [self adjustQuadDev:90
                                               fromAZMs:azm
                                             withIntRot:currentIntersection.intRotation];
    
    currentIntersection.quadDev180 = [self adjustQuadDev:180
                                                fromAZMs:azm
                                              withIntRot:currentIntersection.intRotation];
    
    currentIntersection.quadDev270 = [self adjustQuadDev:270
                                                fromAZMs:azm
                                              withIntRot:currentIntersection.intRotation];
}

- (double)azDiffFrom90s:(double)az
{
    double minDiff = (0.0 - az);
    double diff;
    
    diff = (TWOPI - az);
    
    if (fabs(diff) < fabs(minDiff))
        minDiff = diff;
    
    diff = HALFPI - az;
    
    if (fabs(diff) < fabs(minDiff))
        minDiff = diff;
    
    diff = PY - az;
    
    if (fabs(diff) < fabs(minDiff))
        minDiff = diff;
    
    diff = (HALFPI * 3.0) - az;
    
    if (fabs(diff) < fabs(minDiff))
        minDiff = diff;
    
    return minDiff;
    
}

- (int)intRotFromintAZMS:(NSString *)intAzm
{
    int rtn = 0;
    double minDiff = 10, az, diff;
    char *intAZMS = malloc(intAzm.length + 1);
    strcpy(intAZMS,intAzm.UTF8String);
    char *pBeg = intAZMS;
    char *pEnd = strchr(pBeg,'|');
    
    while (pEnd)
    {
        *pEnd++ = 0;
        az = atof(pBeg);
        diff = [self azDiffFrom90s:az];
        
        if (fabs(diff) < fabs(minDiff))
            minDiff = diff;
        
        pBeg = pEnd;
        pEnd = strchr(pBeg,'|');
    }
    
    az = atof(pBeg);
    diff = [self azDiffFrom90s:az];
    
    if (fabs(diff) < fabs(minDiff))
        minDiff = diff;
    
    rtn = minDiff * RADtoDEG;
    free(intAZMS);
    return rtn;
}

- (int)getCornerFromAdjustedRot:(int)adjustedRot
                 atIntersection:(MPIntersection *)intersection
{
    //returns 81,23,45 or 67
    int  corner = -1;
    
    if (adjustedRot < intersection.quadDev90)
        corner = 81;
    
    else if (adjustedRot < intersection.quadDev180)
        corner = 23;
    
    else if (adjustedRot < intersection.quadDev270)
        corner = 45;
    
    else
        corner = 67;
    
    return corner;
}

- (int)getCornerFromX:(int)x
                 andY:(int)y
       atIntersection:(MPIntersection *)intersection
{
    //returns 81,23,45 or 67
    int corner = -1;
    int lev21x, lev21y;
    LatLongToPixelXY(intersection.lat, intersection.lon, 21, &lev21x, &lev21y);
//    DPOINT midPt = {intersection.lev21x,intersection.lev21y};
    DPOINT midPt = {lev21x,lev21y};
    DPOINT pt = {x,y};
    
    float az = getazdp(&midPt, &pt);
    int adjustedRot = ClockwiseDegFromNorth((az * RADtoDEG) + intersection.intRotation);
    
    corner = [CRAPI.sharedInstance getCornerFromAdjustedRot:adjustedRot
                                             atIntersection:intersection];
    return corner;
}

- (int)getQuadDeviderFromX:(int)x
                      andY:(int)y
            atIntersection:(MPIntersection*)intersection
{
    //returns quad lines E=1, S=2, W=3, N=4
    int  devider;
    int  dist = 999;
    int  diff;
    
    DPOINT midPt = {intersection.lev21x, intersection.lev21y}, pt = {x, y};
    
    float az = getazdp(&midPt, &pt);
    int adjustedRot = ClockwiseDegFromNorth((az * RADtoDEG) + intersection.intRotation);
    diff = abs(diffInDegrees(adjustedRot, intersection.quadDev90));
    devider = 1;
    dist = diff;
    diff = abs(diffInDegrees(adjustedRot, intersection.quadDev180));
    
    if (diff < dist)
    {
        devider = 2;
        dist = diff;
    }
    
    diff = abs(diffInDegrees(adjustedRot, intersection.quadDev270));
    
    if (diff < dist)
    {
        devider = 3;
        dist = diff;
    }
    
    diff = abs(diffInDegrees(adjustedRot, intersection.quadDev0));
    
    if (diff < dist)
    {
        devider = 4;
        //dist = diff;
    }
    
    return devider;
}

- (NSString *)getOutputDirectory
{
    return _outputDirectory;
}

- (BOOL)intersectionAlreadyCompleted:(int)intID
{
    NSString *outputFile = [NSString stringWithFormat:@"%@/Intersection_%i.txt", _outputDirectory, intID];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:outputFile])
        return YES;
    
    outputFile = [NSString stringWithFormat:@"%@/Uploaded_Intersection_%i.txt", _outputDirectory, intID];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:outputFile])
        return YES;
    
    return NO;
}

- (void)deleteImagesForAllZooms:(int)intersectionID
{
    NSFileManager *manager = NSFileManager.defaultManager;
    
    for (int i = 0; i< _numAllowedZooms; i++)
    {
        NSString *imageFile = [_imageDirectory stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"/Int_%i_%i.jpg", intersectionID, _allowedZooms[i]]];
        
        NSString *cptFile = [_imageDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"/Int_%i_%i.cpt", intersectionID, _allowedZooms[i]]];
        
        [manager removeItemAtPath:imageFile
                            error:nil];
        
        [manager removeItemAtPath:cptFile
                            error:nil];
    }
}

- (UIImage *)getStreetViewImageAtLatlon:(LLPOINT)atLatLon
                                heading:(CGFloat)heading
                                  pitch:(CGFloat)pitch
                                    fov:(CGFloat)fov
{
    NSString *staticMapUrl =
    [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/streetview?size=640x640&location=%f,%f&fov=%f&heading=%f&pitch=%f&key=%@",
     atLatLon.lat, atLatLon.lon, fov, heading, pitch, GOOGLE_API_KEY];
    
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:mapUrl]];
    return image;
}


- (BOOL)getPlaceIntersectionFile:(id)intFile
                        forGeoid:(int)geoid
{
    return YES;
}

- (NSString *)directoryFromPath:(NSString *)path
                        andName:(NSString *)name
                         create:(BOOL)create
{
    LPSTR str = malloc(path.length + 2);
    LPSTR pBS;
    NSString *outDir = @"";
    BOOL isDir;
    
    strcpy(str, path.UTF8String);
    
    if ((pBS = strrchr(str,'/')))
    {
        BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:path
                                                         isDirectory:&isDir];
        
        if (!*(pBS + 1) || (exists && !isDir))
            *pBS = 0;
        
        strcat(str, name.UTF8String);
        outDir = [NSString stringWithUTF8String:str];
    }
    
    free(str);
    return outDir;
}

- (IBOUNDS)CGRectToIBounds:(CGRect)rect
{
    IBOUNDS iBounds;
    iBounds.xmn = rect.origin.x;
    iBounds.ymn = rect.origin.y;
    iBounds.xmx = rect.origin.x + rect.size.width;
    iBounds.ymx = rect.origin.y + rect.size.height;
    return iBounds;
}


- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)latlon
          usingTransformation:(LPTRANDATA)pTranWToBMP
{
    CGPoint pt = CGPointZero;
    return pt;
}


- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(LPTRANDATA)pTranWToBMP
{
    CGPoint pt = CGPointZero;
    TRANS2P(lev21pt.x, lev21pt.y, (LPDOUBLE)&pt.x, (LPDOUBLE)&pt.y, pTranWToBMP);
    return pt;
}

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(LPTRANDATA)pTranBMPToW
{
    IBOUNDS iBounds, outBounds;
    iBounds = [self CGRectToIBounds:rect];
    TranMNMXCORLP(&iBounds, &outBounds, pTranBMPToW);
    return outBounds;
}

- (dbounds)getBoundsAtPoint:(CLLocationCoordinate2D *)pt
                    andDist:(double)meters
{
    dbounds bnds;
    
    DPOINT pt1 = NewLatLong(pt->latitude, pt->longitude, meters, 0);
    double pickapY = pt1.y - pt->latitude;
    DPOINT pt2 = NewLatLong(pt->latitude, pt->longitude, meters, HALFPI);
    double pickapX = pt2.x - pt->longitude;
    bnds.xmn = (pt->longitude - pickapX);
    bnds.xmx = (pt->longitude + pickapX);
    bnds.ymn = (pt->latitude - pickapY);
    bnds.ymx = (pt->latitude + pickapY);
    return bnds;
}

- (dbounds)getPickApBoundsAtPoint:(LLPOINT *)pt
{
    dbounds bnds;
    
    CGFloat pickApMeters;
    if (_pickApInPixels < 0)
        pickApMeters = -_pickApInPixels;
    else
        pickApMeters = (_pickApInPixels * GroundResolution(pt->lat, (int)_currentZoom));

        
    
    DPOINT pt1 = NewLatLong(pt->lat, pt->lon, pickApMeters, 0);
    double pickapY = pt1.y - pt->lat;
    DPOINT pt2 = NewLatLong(pt->lat, pt->lon, pickApMeters, HALFPI);
    double pickapX = pt2.x - pt->lon;
    bnds.xmn = (pt->lon - pickapX);
    bnds.xmx = (pt->lon + pickapX);
    bnds.ymn = (pt->lat - pickapY);
    bnds.ymx = (pt->lat + pickapY);
    return bnds;
}

- (dbounds) getPixelPickApBoundsAtPoint:(DPOINT*)pt
{
    dbounds bnds;
    
    double pickapY = _pickApInPixels;
    double pickapX = _pickApInPixels;
    bnds.xmn = (pt->x - pickapX);
    bnds.xmx = (pt->x + pickapX);
    bnds.ymn = (pt->y - pickapY);
    bnds.ymx = (pt->y + pickapY);
    return bnds;
}

- (NSString *)sharedFilePath
{
    return UserDefaults.defaults.sharedFilePath;
}

-(void)clearOutputDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_sharedOutputDirectory error:nil];
}

-(BOOL)appendString:(NSString*)str
             toFile:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath])
    {
        [str writeToFile:filePath
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:nil];
    }
    
    else
    {
        NSString *newLine = [NSString stringWithFormat:@"\r\n%@", str];
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[newLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return YES;
}

-(NSString*) timeStamp
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *rtn = [dateFormatter stringFromDate:[NSDate date]];
    return rtn;
}
-(BOOL) haveErrorLog
{
    BOOL rtn = FALSE;
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:[self errorLogPath]
                                                                       error:nil].fileSize;
    if (fileSize > 0)
        rtn = TRUE;
    return rtn;

}
-(NSString*) errorLogPath
{
    NSString * path = [self sharedFilePath];
    NSString * file = [NSString stringWithFormat:@"%@/%@", path, @"NVErrorLog.txt"];
    return file;
}
- (void) logToErrorFileIgnore:(BOOL)ignore
{
    _ignoreErrorLog = ignore;
}

-(void) logToErrorFile:(NSString*) error
            withHeader:(NSString*) header
{
    NSString *mess = [NSString stringWithFormat:@"%@:%@",header,error];
    [self logToErrorFile:mess];
}
-(void) logToErrorFile:(NSString*) error
{
    if (_ignoreErrorLog)
        return;
    NSString *errorFile = [self errorLogPath];
    NSString *idString = [NSString stringWithFormat:@"%@ %li %i %@ %i %i %i %i",[self timeStamp],(long)_currentModule,_currentSubModule,[self appAndVersion],_GSSiPadNumber,_currentManageriPad,_currentiPadWithinManager,self.currentGeoid];
    //#ifdef DEBUG
    NSLog(@"%@", error);
    //showAlert (error);
//#else
    [self appendString:idString
                toFile:errorFile];
    [self appendString:error
                toFile:errorFile];
//#endif
}

-(void) clearErrorFile
{
    NSString *errorFile = [self errorLogPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:errorFile error:nil];
  
}

- (NSString *)appAndVersion
{
    //NSString *vb = UIApplication.appVersionBuild;
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString *appVersionBuild = [NSString stringWithFormat:@"%@ (%@)",version,build];
    NSString *rtn = [NSString stringWithFormat:@"%i.%i-%@",
                     (int)_currentModule, (int)_currentSubModule,
                     appVersionBuild];
    return rtn;
}

- (BOOL)isValidVersion:(NSString *)message
{
    NVAlertView *alert = nil;
    BOOL rtn = YES;
    
    if ([message isEqualToString:@"InvalidVersion1"])
    {
        alert = [NVAlertView showLargeAlertViewinView:UIApplication.sharedApplication.keyWindow
                                             delegate:CRAPI.sharedInstance
                                                title:@"This app must be updated to the current version to function correctly. Tap on 'OK' to go to TestFlight and update this app."
                                      buttonTextArray:@[@"OK"]
                                     destructiveIndex:0];
        
        alert.identifier = @"LaunchTestFlight";
        rtn = NO;
    }
    
    if ([message isEqualToString:@"InvalidVersion2"])
    {
        alert = [NVAlertView showLargeAlertViewinView:UIApplication.sharedApplication.keyWindow
                                             delegate:CRAPI.sharedInstance
                                                title:@"This app must be updated to the current version to function correctly. Tap on 'OK' to go to the App Store and update this app."
                                      buttonTextArray:@[@"OK"]
                                     destructiveIndex:0];
        
        alert.identifier = @"LaunchAppStore";
        rtn = NO;
    }
    
    return rtn;
}

- (void)setGSSiPadNumber:(int)num
{
    NSString *key = [NSString stringWithFormat:@"GSSiPadNumber"];
    _GSSiPadNumber = num;
    
    if (num > 0)
        [UserDefaults.defaults saveInteger:num forKey:key];
}

- (void) setRebuildYear:(int)rebuildYear
{
    _rebuildYear = rebuildYear;
    [UserDefaults.defaults saveInteger:rebuildYear forKey:@"RebuildYear"];
}
- (void) setUseExternalAccelerometer:(int)useExternalAccelerometer
{
    _useExternalAccelerometer = useExternalAccelerometer;
    [UserDefaults.defaults saveInteger:useExternalAccelerometer forKey:@"UseExternalAccelerometer"];
}
- (int) getUseExternalAccelerometer
{
    _useExternalAccelerometer = (int)[UserDefaults.defaults integerForKey:@"UseExternalAccelerometer"];
    return _useExternalAccelerometer;
}
- (NSInteger)adjustNextRefno:(NSInteger)refno
{
    NSInteger nextRef = refno % _maxDevices;
    
    if (!_deviceNumber)
        [self logToErrorFile:@"Device number 0 in adjustNextRefno"];
    if (nextRef < _deviceNumber)
        nextRef = refno - nextRef + _deviceNumber;
    else
        nextRef = refno - nextRef + _maxDevices +_deviceNumber;
    return nextRef;
}

- (BOOL) setGeoIDForCurrentApp
{
    BOOL rtn = YES;
    NSInteger selectedRow = [UserDefaults.defaults integerForKey:@"SelectedRow"];
    if (_currentModule == MANAGEMENT_MODULE)
        selectedRow = -2; //current geoid
    else if (_currentModule == GMMOBILE_MODULE && (_currentApp == HCConfigAlleyWalls || _currentApp == HCConfigAlleyWallStatus))
        selectedRow = -1;
    rtn = [CRAPI.sharedInstance processPlacesArray:selectedRow];
    if (!rtn && selectedRow < 0)
    {
        [CRAPI.sharedInstance logToErrorFile:@"NVMobile-Alleywalls does not set place and manager"];
    }
    else if (!rtn)
    {
        [CRAPI.sharedInstance logToErrorFile:@"NVMobile-CurbRamps does not set place and manager"];
    }
    return rtn;
}

-(NSMutableArray *) copyPlaces
{
    NSMutableArray * oldPlaces = _placesArray;
    
    [self processPlaces];
    
    return oldPlaces;
}

- (int) newPlace:(NSArray *)oldPlaces
{
    if (!oldPlaces)
        return -1;
    if (oldPlaces.count == _placesArray.count)
        return -1;
    int row = 0;
    for (CityOrOrganizationData *c in _placesArray)
    {
        if (![c inArray:oldPlaces])
            return row;
        row++;
            
    }
    return -1;
}

int ControlChar (NSString * controlStr,int whichChar)
{
    int rtn = 0;
    char chr[2];
    if (controlStr.length < whichChar)
        return 0;
    chr[0] = [controlStr characterAtIndex:whichChar-1];
    chr[1] = 0;
    rtn = atoi (chr);
    return rtn;
}
- (BOOL)processPlaces
{
    NSString *message = [UserDefaults.defaults stringForKey:@"PlacesString"];
    
    _placesArray = NSMutableArray.new;
    if (!message)
        return NO;
    
    if (strncmp(message.UTF8String,"PlacesFor", 9))
        return NO;
    
    self.GSSiPadNumber = atoi(&message.UTF8String[9]);
    
    NSMutableArray *placearray = [[NSMutableArray alloc] initWithArray:[message componentsSeparatedByString:@":"]];
    [placearray removeObjectAtIndex:0];
    
    for (NSString *instr in placearray)
    {
        NSString *str = textBeforeLastChar(instr,@"*");
        NSString *controlStr = textAfterLastChar(instr,@"*");
        CityOrOrganizationData *c = [[CityOrOrganizationData alloc]init];
        c.controlledInterface = ControlChar (controlStr,1);
        c.allowSidewalk = ControlChar(controlStr, 2);
        c.fullDescription = str;
        c.name = textInsideParentheses(str);
        c.number = [textBeforeParentheses(str) integerValue];
        NSString *manager = textAfterClosingParentheses(str);
        c.managerNumber = [textBeforeHyphen(manager) integerValue];
        c.withinManager = [textAfterHyphen(manager) integerValue];
        c.totWithinManager = [textAfter(manager,@"of") integerValue];
        c.GSSiPadNumber = _GSSiPadNumber;
        [_placesArray addObject:c];
    }

    [_placesArray sortUsingSelector:@selector(compareName:)];

    return YES;
}

- (void) transferPlacesArrayToManagePlacesList
{
    [UserDefaults.defaults resetPlacesLists];
    
    for (CityOrOrganizationData *c in _placesArray)
        [ManagePlacesDatabase.database addLocationToList:(int)c.number];
}

-(BOOL)processServerString:(NSString*)instr
{
    BOOL rtn = TRUE;
    NSArray *arr = [instr componentsSeparatedByString:@" "];
    NSString * str = arr[0];
    int server = (int)str.integerValue;
    if (server != _serverToUse)
        rtn = FALSE;
    _serverToUse = server;
    if (arr.count > 1)
    {
        str = arr[1];
        _hideConnectButton = str.integerValue;
    }
    if (arr.count > 2)
    {
        str = arr[2];
        _showDeveloperFunctions = (int)str.integerValue;
        if (_showDeveloperFunctions >= 100)
        {
            NSString * process = [str substringToIndex:1];
            if (process.integerValue == 2)
                _showDeveloperFunctions = DOWNLOAD_DATABASE_FUNCTION;
            NSString * database = [str substringWithRange:NSMakeRange(1,2)];
            _databaseToDownload = (int)database.integerValue;
        }
        if (isGSSiDevice())
            _showDeveloperFunctions = max (1,_showDeveloperFunctions);
    }
    if (arr.count > 3)
    {
        str = arr[3];
            _isRentaliPad = str.integerValue;
    }
    
    return rtn;
}
- (BOOL)savePlacesString:(NSString*)placesStringIN //returns FALSE if need to switch server
{
    BOOL rtn = TRUE;
    NSArray *arr = [placesStringIN componentsSeparatedByString:@"|"];
    if (arr.count > 3)
    {
        NSString* messNum = arr[0];
        _currentMessageNum = (int)messNum.integerValue;
        messNum = arr[1];
        rtn = [self processServerString:messNum];
        NSString* version = arr[2];
        NSArray *versions = [version componentsSeparatedByString:@":"];
        _minManageVersion  = versions[0];
        if (versions.count > 1)
            _minPrelimVersion = versions[1];
        if (versions.count > 2)
            _minDetailVersion = versions[2];
        if (versions.count > 3)
            _minAlleyVersion  = versions[3];
    }
    NSRange placesStart = [placesStringIN rangeOfString:@"PlacesFor"];
    NSString *placesString = [placesStringIN substringFromIndex:placesStart.location];
    [UserDefaults.defaults saveString:placesString
                               forKey:@"PlacesString"];
    if (_currentModule == GMMOBILE_MODULE)
    {
        NSString * path = [NSString stringWithFormat:@"%@/%@", UserDefaults.defaults.sharedFilePath, @"PlacesString.txt"];
        [placesString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    return rtn;
}

- (NSString*) getPlacesStringFromFile
{
    NSString * path = [NSString stringWithFormat:@"%@/%@", UserDefaults.defaults.sharedFilePath, @"PlacesString.txt"];
    NSString *places = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return places;
}

- (BOOL)processPlacesArray:(NSInteger)row
{
    if (_placesArray.count < 1)
        return FALSE;
    
    if (row >= (int)_placesArray.count)
    {
        row = (CRAPI.sharedInstance.placesArray.count - 1);
        
        [UserDefaults.defaults saveInteger:(int)row
                                    forKey:@"SelectedRow"];
    }
    
    if (row == -1) // AlleyWalls
    {
        BOOL haveCity = FALSE;
        row = 0;
        
        for (CityOrOrganizationData *c in _placesArray)
        {
            if (c.number >= 100000001)
            {
                haveCity = TRUE;
                break;
            }
            
            row++;
        }
        if (!haveCity)
            return FALSE;
    }
    
    else if (row == -2) // CurrentGeoid
    {
        BOOL haveCity = FALSE;
        row = 0;
        
        for (CityOrOrganizationData *c in _placesArray)
        {
            if (c.number == _currentGeoidValue)
            {
                haveCity = TRUE;
                break;
            }
            
            row++;
        }
        if (!haveCity)
        {
            if (_placesArray.count == 1)
                row = 0;
            else
                return FALSE;
        }
    }
    
    else if (_placesArray.count == 1 || row >= _placesArray.count)
        row = 0;

    CityOrOrganizationData *c = _placesArray[row];
    _GSSiPadNumber = (int)c.GSSiPadNumber;
    _currentCityNameAndState = addSpaceAfterComma(c.name);
    self.currentGeoid = (int)c.number;
    
    [UserDefaults.defaults saveInteger:self.currentGeoid
                                forKey:@"CurrentGeoid"];
    
    _currentManageriPad = (int)c.managerNumber;
    _currentiPadWithinManager = (int)c.withinManager;
    _deviceNumber = _currentiPadWithinManager;
    _totiPadWithinManager = (int)c.totWithinManager;
    _controlledInterface = c.controlledInterface;
    _controllControlledInterface = !c.controlledInterface;
    _allowSidewalk = c.allowSidewalk;
    _allowSidewalk = YES;
    [self saveiPadIDs];
    return TRUE;
}

- (void) saveiPadIDs
{
    NSString *key = [NSString stringWithFormat:@"ManagerForGeoid:%i",self.currentGeoid ];
    [UserDefaults.defaults saveInteger:_currentManageriPad
                                forKey:key];
    
    key = [NSString stringWithFormat:@"iPadWithinManagerForGeoid:%i",self.currentGeoid ];
    
    [UserDefaults.defaults saveInteger:_currentiPadWithinManager
                                forKey:key];
    
    key = [NSString stringWithFormat:@"totiPadWithinManagerForGeoid:%i",self.currentGeoid ];
    
    [UserDefaults.defaults saveInteger:_totiPadWithinManager
                                forKey:key];

}

- (void)loadiPadParametersForGeoid:(int)geoid
{
    _GSSiPadNumber = (int)[UserDefaults.defaults integerForKey:@"GSSiPadNumber"];
    
    NSString *key = [NSString stringWithFormat:@"ManagerForGeoid:%i",geoid];
    _currentManageriPad = (int)[UserDefaults.defaults integerForKey:key];
    
    key = [NSString stringWithFormat:@"iPadWithinManagerForGeoid:%i",geoid];
    _currentiPadWithinManager = (int)[UserDefaults.defaults integerForKey:key];
    
    key = [NSString stringWithFormat:@"totiPadWithinManagerForGeoid:%i",geoid];
    _totiPadWithinManager = (int)[UserDefaults.defaults integerForKey:key];
}

- (void)setiPadParametersFromGeoid:(int)geoid
{
    int row = 0;
    
    while (row < _placesArray.count)
    {
        NSString *place = _placesArray[row];
        int goid = (int)place.integerValue;
        
        if (goid == geoid)
            [self processPlacesArray:row];
        
        row++;
    }
}

- (void) showMapToolbarIndicator:(BOOL)show
{
dispatch_async(dispatch_get_main_queue(),
               ^{
                   self.mapToolbar.showIndicator = show;
               });
}

-(void) updateProgress:(NSInteger)tot
               current:(NSInteger)current
                 range:(int)iRange
             numRanges:(int)nRanges
{
    static NSInteger currentProgress = -1;
    NSInteger progress = 0;
    if (tot < 0)
    {
        currentProgress = -1;
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           CRAPI.sharedInstance.mapToolbar.progress = 0;
                       });
        return;
    }
    if (!tot)
        return;
    nRanges = max (1,nRanges);
    CGFloat baseProgress = (CGFloat)iRange / nRanges;
    CGFloat thisProgress = baseProgress + current / (CGFloat)(tot * nRanges);
    progress = thisProgress * 100;
    if (currentProgress > 140)
        currentProgress = currentProgress + 0;
    if (progress > currentProgress)
    {
        currentProgress = progress;
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           CRAPI.sharedInstance.mapToolbar.progress = (float)currentProgress/100.0;
                       });
    }
}

-(void) setMapToolbar:(MapToolbar *)mapToolbar
{
    _mapToolbar = mapToolbar;
}
- (NSString*) getNVCRISServer
{
    NSString *server = [NSString stringWithFormat:@"gssiserver%i.com", _serverToUse];
    return server;
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *result = nil;
    NSString *trimmedStr = nil, *scheme = nil;
    NSRange schemeMarkerRange = {0};
    
    assert(str);
    
    trimmedStr = [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    
    if ((trimmedStr) && (trimmedStr.length != 0))
    {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound)
        {
            result = [NSURL URLWithString:[[NSString stringWithFormat:@"ftp://%@", trimmedStr]
                                           stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        else
        {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme);
            
            if (([scheme compare:@"ftp"
                         options:NSCaseInsensitiveSearch] == NSOrderedSame))
            {
                result = [NSURL URLWithString:trimmedStr];
            }
        }
    }
    
    return result;
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.identifier isEqualToString:@"LaunchTestFlight"])
        [self gotoTestFlight];
    
    else if ([alertView.identifier isEqualToString:@"LaunchAppStore"])
        [self gotoAppStore];
    
    else if ([alertView.identifier isEqualToString:@"BlueToothConnections"])
        [self bluetoothConnectionOps:buttonIndex];
   
    else
        [alertView hideLargeAlertView:YES];
}

- (void) bluetoothConnectionOps:(NSInteger)opt
{
    switch (opt)
    {
        case 0:
            [self hideConnectionAlert];
            if ([CRAPI.sharedInstance.currentUploadView respondsToSelector:@selector(upload:)])
                [CRAPI.sharedInstance.currentUploadView performSelector:@selector(upload:) withObject:nil afterDelay:0.1];
            break;
        case 1:
            exit (-1);
            break;

    }
}
- (void)gotoAppStore
{
    NSString *urlString = @"";
    
    switch (CRAPI.sharedInstance.currentModule)
    {
        case MANAGEMENT_MODULE:
            urlString = @"https://itunes.apple.com/us/app/gssi/id1104782524";
            break;
        case PRELIM_MODULE:
            urlString = @"https://itunes.apple.com/us/app/gssi/id1104781807";
            break;
        case DETAIL_MODULE:
            urlString = @"https://itunes.apple.com/us/app/gssi/id1104782168";
            break;
        default:
            urlString = @"https://itunes.apple.com/us/developer/geographic-software-specialists/id1104523427";
            break;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if ([UIApplication.sharedApplication canOpenURL:url])
        [UIApplication.sharedApplication openURL:url];
}

- (void)gotoTestFlight
{
    NSURL *url = [NSURL URLWithString:@"https://beta.itunes.apple.com"];
    
    if ([UIApplication.sharedApplication canOpenURL:url])
        [UIApplication.sharedApplication openURL:url];
}

- (void)checkStorageForMinStorage:(NSNumber *)minStorage
{
    int minValue = 0;
    
    if (minStorage)
        minValue = minStorage.intValue;
    
    else
        minValue = 10000000;
    long long avail = UIDevice.availableStorageSpace;
    if (avail < minValue)
    {
        if (![UIApplication.sharedApplication.keyWindow.subviews containsObject:_alert])
        {
            _alert = [NVAlertView showLargeAlertViewinView:UIApplication.sharedApplication.keyWindow
                                                  delegate:self
                                                     title:@"Warning: Storage Space is very low."
                                           buttonTextArray:@[@"OK"]
                                          destructiveIndex:0];
        }
    }
}

-(NSString*)countyNameFromCountyID:(NSString*)countyID
{
    if ([countyID isEqualToString:@"003"])
        return @"Anoka";
    if ([countyID isEqualToString:@"019"])
        return @"Carver";
    if ([countyID isEqualToString:@"037"])
        return @"Dakota";
    if ([countyID isEqualToString:@"053"])
        return @"Hennepin";
    if ([countyID isEqualToString:@"123"])
        return @"Ramsey";
    if ([countyID isEqualToString:@"139"])
        return @"Scott";
    if ([countyID isEqualToString:@"163"])
        return @"Washington";
    return @"";
}

- (NSString *)currentCountyName
{
    return [self countyNameFromCountyID:_currentCounty];
}
- (void) setCurrentCountyName:(NSString *)inName
{
    NSString *name = [inName uppercaseString];
    
    if ([name isEqualToString:@"ANOKA"])
        _currentCounty = @"003";
    if ([name isEqualToString:@"CARVER"])
        _currentCounty = @"019";
    if ([name isEqualToString:@"DAKOTA"])
        _currentCounty = @"037";
    if ([name isEqualToString:@"HENNEPIN"])
        _currentCounty = @"053";
    if ([name isEqualToString:@"RAMSEY"])
        _currentCounty = @"123";
    if ([name isEqualToString:@"SCOTT"])
        _currentCounty = @"139";
    if ([name isEqualToString:@"WASHINGTON"])
        _currentCounty = @"163";
}

- (NSString *)acreFormat:(double)acres
{
    NSNumber *num = [[NSNumber alloc] initWithDouble:acres];
    NSString *value = [self.acreFmt stringFromNumber:num];
    return value;
}

- (NSString *)dollarsFormat:(double)dollars
{
    NSNumber *num = [[NSNumber alloc] initWithDouble:dollars];
    NSString *value = [self.dollarFmt stringFromNumber:num];
    return value;
}

- (void)setForAllYears:(BOOL)forAllYears
{
    _forAllYears = forAllYears;
    [UserDefaults.defaults saveBool:forAllYears forKey:@"ForAllYears"];
}

- (NSArray<TimeRange *> *)getTimeRanges
{
    NSMutableArray<TimeRange *> *array = NSMutableArray.array;
    
    if (_forAllYears)
    {
        NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:_fromDate];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:_toDate];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.locale = NSLocale.currentLocale;
        calendar.timeZone = NSTimeZone.localTimeZone;
        
        NSDateComponents *beginComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|
                                        NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                   fromDate:beginDate];
        
        NSDateComponents *endComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|
                                      NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                 fromDate:endDate];
        
        NSInteger endYear = endComps.year;
        endComps.year = beginComps.year;
        
        if ((beginComps.month > endComps.month) ||
            ((beginComps.month == endComps.month) && (beginComps.day > endComps.day)))
        {
            endComps.year++;
            endYear--;
        }
        
        while (beginComps.year <= endYear)
        {
            TimeRange *tr = TimeRange.new;
            tr.beginTime = (int)[calendar dateFromComponents:beginComps].timeIntervalSince1970;
            tr.endTime = (int)[calendar dateFromComponents:endComps].timeIntervalSince1970;
            [array addObject:tr];
            beginComps.year++;
            endComps.year++;
        }
    }
    
    else
    {
        TimeRange *tr = TimeRange.new;
        tr.beginTime = (int)_fromDate;
        tr.endTime = (int)_toDate;
        [array addObject:tr];
    }
    
    return array.copy;
}

- (void)setMapCrimeList:(NSString *)mapCrimeList
{
    _mapCrimeList = mapCrimeList;
    [UserDefaults.defaults saveString:mapCrimeList forKey:@"MapCrimeList"];
}

- (void)setMapPropList:(NSString *)mapPropList
{
    _mapPropList = mapPropList;
    [UserDefaults.defaults saveString:mapPropList forKey:@"MapPropList"];
}

- (BOOL) refnoInAreaText:(int) refno
{
    BOOL rtn = FALSE;
    
    for (AreaText *at in _lastAreaText)
    {
        if (at.refno == refno)
            rtn = TRUE;
    }
    return rtn;
}
- (AreaText*) areaTextForRefno:(int) refno
{
    AreaText * rtn = nil;
    
    for (AreaText *at in _lastAreaText)
    {
        if (at.refno == refno)
            rtn = at;
    }
    return rtn;
}

- (void)showAlert:(NSString *)text
{
    [self performSelectorOnMainThread:@selector(presentAlert:)
                           withObject:text
                        waitUntilDone:YES];
}

- (void)presentAlert:(NSString *)text
{
    if (![UIApplication.sharedApplication.keyWindow.subviews containsObject:_alert])
    {
        _alert = [NVAlertView showLargeAlertViewinView:UIApplication.sharedApplication.keyWindow
                                              delegate:self
                                                 title:text
                                       buttonTextArray:@[@"OK"]
                                      destructiveIndex:0];
    }
}

- (void)showReference:(NSString *)reference
{
    [self performSelectorOnMainThread:@selector(presentReference:)
                           withObject:reference
                        waitUntilDone:YES];
}

- (void)presentReference:(NSString *)reference
{
    if (![UIApplication.sharedApplication.keyWindow.subviews containsObject:_alert])
        [NVReferenceView showReference:reference inView:UIApplication.sharedApplication.keyWindow];
}

- (void)documentManagerDidCompleteWithMessage:(NSString *)message
                                     filepath:(NSString *)filepath
{
    [self showAlert:message];
}

- (void)uploadToCloud
{
    [self performSelector:@selector(performUploadToCloud)
               withObject:nil
               afterDelay:0.5];
}

- (void)performUploadToCloud
{
    [_docManager exportDocumentFromFilePath:_docManager.filePath
                                   delegate:self
                             deleteWhenDone:_docManager.deleteWhenDone];
}

- (void)displayChartBitmaps:(NSTimer *)timer
{
    [timer invalidate];
    
    ChartsBitmapVC *chartsVC = ChartsBitmapVC.new;
    chartsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController *parentVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    
    [parentVC presentViewController:chartsVC
                           animated:YES
                         completion:nil];
}

- (void)displayHotSpotVideo:(NSTimer *)timer
{
    [timer invalidate];
    
    HotSpotVideoVC *hsvVC = HotSpotVideoVC.new;
    hsvVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController *parentVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    
    [parentVC presentViewController:hsvVC
                           animated:YES
                         completion:nil];
}

- (NSArray <NSArray *> *)arrayOutput
{
    BOOL opened = [_spreadsheetDelegate openList:nil];
    int rows = (int)(_spreadsheetDelegate.numRowsInSpreadsheet + 1);
    int columns = (int)(_spreadsheetDelegate.numColumnsInSpreadsheet + 1);
    NSMutableArray <NSArray *> *outerArray = NSMutableArray.array;
    NSMutableArray *innerArray = NSMutableArray.array;
    [innerArray addObject:@""];
    
    for (int i = 1; i < columns; i++)
    {
        [innerArray addObject:[[_spreadsheetDelegate headerTextForColumn:i] stringByReplacingOccurrencesOfString:@"\n"
                                                                                                      withString:@" "]];
    }
    
    [outerArray addObject:innerArray.copy];
    
    for (int i = 1; i < rows; i++)
    {
        innerArray = NSMutableArray.array;
        
        [innerArray addObject:[[_spreadsheetDelegate headerTextForRow:i] stringByReplacingOccurrencesOfString:@"\n"
                                                                                                   withString:@" "]];
        
        for (int j = 1; j < columns; j++)
        {
            [innerArray addObject:[[_spreadsheetDelegate textForColumn:j row:i] stringByReplacingOccurrencesOfString:@"\n"
                                                                                                          withString:@" "]];
        }
        
        [outerArray addObject:innerArray.copy];
    }
    
    if (opened)
        [_spreadsheetDelegate closeList];
    
    return outerArray.copy;
}

- (void)setRhVideoURL:(NSURL *)rhVideoURL
{
    _rhVideoURL = rhVideoURL;
    [UserDefaults.defaults saveString:rhVideoURL.lastPathComponent forKey:@"RHVideoPath"];
}

- (void)initBeep
{
_beep = [[AVAudioPlayer alloc] initWithContentsOfURL:
         [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.mp3",
                                 NSBundle.mainBundle.resourcePath]] error:nil];

_finalBeep = [[AVAudioPlayer alloc] initWithContentsOfURL:
              [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/finalBeep.mp3",
                                      NSBundle.mainBundle.resourcePath]] error:nil];
}

- (void)playBeep
{
    [_beep play];
}

- (void)playFinalBeep
{
    [_finalBeep play];
}

- (void)playErrorBeep
{
    [_finalBeep play];
    [_finalBeep play];
    [_finalBeep play];
}

- (void)startBeepTimer:(NSTimeInterval)timeInterval
{
    if (timeInterval > 0.0)
    {
        [_beep prepareToPlay];
        [self cancelBeepTimer];
        
        _beepTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                      target:_beep
                                                    selector:@selector(play)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)cancelBeepTimer
{
    [_beep stop];
    
    if (_beepTimer)
    {
        if (_beepTimer.isValid)
            [_beepTimer invalidate];
        
        _beepTimer = nil;
    }
}

- (void)setBeepVolume:(float)volume
{
    _beep.volume = volume;
}
- (void)sendDebugFile
{
    NSInteger totSize = 0;
    
   totSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:_debugFilePath
                                                                       error:nil].fileSize;

    NSString *message = [NSString stringWithFormat:@"Debug file (%li) from %@(%i)",totSize,
                         UIDevice.currentDevice.name, CRAPI.sharedInstance.GSSiPadNumber];
    dispatch_async(dispatch_get_main_queue(),
                   ^{


    [NVSendEmail sendEmailWithSubject:@"Debug file from GMMobile"
                              message:message
                       attachmentData:[NSData dataWithContentsOfFile:_debugFilePath]
                             mimeType:@"application/csvm+json"
                             fileName:[_debugFilePath lastPathComponent]
                           controller:_mapVC];
                   });
}
- (void) clearDebugFile
{
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _debugFilePath = [NSString stringWithFormat:@"%@/debug.txt", documentsDir];
    [NSFileManager.defaultManager removeItemAtPath:_debugFilePath
                        error:nil];
}
- (void) addToDebugFile:(NSString *)line
{
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _debugFilePath = [NSString stringWithFormat:@"%@/debug.txt", documentsDir];
    [self appendString:line toFile:_debugFilePath];
}
- (void) openDebugFile:(NSString *)name
{
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _debugFilePath = [NSString stringWithFormat:@"%@/%@.txt", documentsDir,name];
    [NSFileManager.defaultManager removeItemAtPath:_debugFilePath
                                             error:nil];
    [NSFileManager.defaultManager createFileAtPath:_debugFilePath contents:nil attributes:nil];
    _debugFileHandle = [NSFileHandle fileHandleForWritingAtPath:_debugFilePath];
}
- (void) closeDebugFile
{
    [_debugFileHandle closeFile];
    _debugFileHandle = nil;
}
- (void) writeToDebugFile:(NSString *)line
{
    NSString *newLine = [NSString stringWithFormat:@"%@\r\n", line];
    [_debugFileHandle writeData:[newLine dataUsingEncoding:NSUTF8StringEncoding]];
}

void GSSiViewDidLoad (void)
{
    NSLog (@"view did load");
}
@end
