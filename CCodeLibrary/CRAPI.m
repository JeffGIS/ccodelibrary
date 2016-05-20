//  CRAPI.m
//  CCodeLibrary

#import "CRAPI.h"
#import "GSSiDefs.h"
#import "MathUtil.h"
#import "TileGraphics.h"
#import "CityOrOrganizationData.h"

@implementation CRAPI
{
    int _currentGeoidValue, _numAllowedZooms, _allowedZooms[3];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _keepProcessing = 0;
        _currentGeoidValue = 0;
        _pickApInPixels = 50;
        _numAllowedZooms = 3;
        _allowedZooms[0] = 21;
        _allowedZooms[1] = 20;
        _allowedZooms[2] = 19;
        _maxDevices = 100;
        _controlledInterface = NO;
        _documentsDirectory = UserDefaults.defaults.localFilePath;
        _extractFile = [NSString stringWithFormat:@"%@/extract.png", _documentsDirectory];
        _crimeMode = PINMAP;
        _crimeTarget = @"Minneapolis Neighborhoods";
        _docManager = NVDocumentManager.new;
        _deviceLists = NSMutableDictionary.dictionary;
        _assignediPadsArray = NSMutableArray.array;
        
        _uploadPix = [UserDefaults.defaults boolForKey:@"UploadPix"];
        _downloadData = [UserDefaults.defaults boolForKey:@"DownloadData"];
        _downloadPix = [UserDefaults.defaults boolForKey:@"DownloadPix"];
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
    NSString* outdir = [NSString stringWithFormat:@"%@/OutputFiles/%@",self.sharedFilePath,subDir];
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

- (void)setCurrentGeoid:(int)geoid
{
    if (geoid != _currentGeoidValue)
    {
        _currentGeoidValue = geoid;
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
    
    if (geoid == 2743000)//MPLS
        self.controlledInterface = NO;
}

-(void)setCurrentOverallBoundaryName:(NSString *)currentOverallBoundaryName
{
    _currentOverallBoundaryName = currentOverallBoundaryName;
}

-(void)setCurrentZoom:(CGFloat)zoom
{
    _currentZoom = zoom;
}

-(void)setKeepProcessing:(int)kp
{
    _keepProcessing = kp;
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

- (void)facilityInit:(Facility *)currentFacility
{
    currentFacility.facID = -1;
    currentFacility.dataUpdated = NO;
    currentFacility.intRotation = 0;
    currentFacility.doLater = NO;
    currentFacility.timeComplete = 0;
    currentFacility.name1 = @"NOTYETSET";
    currentFacility.quadDev90 = 0;
    currentFacility.quadDev90 = 90;
    currentFacility.quadDev180 = 180;
    currentFacility.quadDev270 = 270;
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
    
    float az = getazd(&midPt, &pt);
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
    
    float az = getazd(&midPt, &pt);
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
    TRANS2(lev21pt.x, lev21pt.y, (LPDOUBLE)&pt.x, (LPDOUBLE)&pt.y, pTranWToBMP);
    return pt;
}

- (IBOUNDS)boundsFromRect:(CGRect)rect
      usingTransformation:(LPTRANDATA)pTranBMPToW
{
    IBOUNDS iBounds, outBounds;
    iBounds = [self CGRectToIBounds:rect];
    TranMNMXCORL(&iBounds, &outBounds, pTranBMPToW);
    return outBounds;
}

- (dbounds)getBoundsAtPoint:(CLLocationCoordinate2D *)pt
                    andDist:(CGFloat)meters
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
    
    CGFloat pickApMeters = (_pickApInPixels * GroundResolution(pt->lat, (int)_currentZoom));
    
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
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    NSURL *groupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    
    [groupContainerURL setResourceValue:[NSNumber numberWithBool:YES]
                                 forKey:NSURLIsExcludedFromBackupKey
                                  error:nil];
    
    return groupContainerURL.relativePath;
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

- (NSMutableArray*) getPlacesArray
{
    NSMutableArray * array;
    
    return array;
}

- (NSInteger)adjustNextRefno:(NSInteger)refno
{
    NSInteger nextRef = refno % _maxDevices;
    
    if (nextRef < _deviceNumber)
        nextRef = refno - nextRef + _deviceNumber;
    else
        nextRef = refno - nextRef + _maxDevices +_deviceNumber;
    return nextRef;
}
- (BOOL)processPlaces
{
    NSString *message = [UserDefaults.defaults stringForKey:@"PlacesString"];
    
    if (strncmp(message.UTF8String,"PlacesFor", 9))
        return FALSE;
    
    _GSSiPadNumber = atoi(&message.UTF8String[9]);
    
    NSMutableArray *placearray = [[NSMutableArray alloc] initWithArray:[message componentsSeparatedByString:@":"]];
    [placearray removeObjectAtIndex:0];
    _placesArray = NSMutableArray.new;
    for (NSString *str in placearray)
    {
        CityOrOrganizationData *c = [[CityOrOrganizationData alloc]init];
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


    return TRUE;
}

- (void)savePlacesString:(NSString*)placesString
{
    [UserDefaults.defaults saveString:placesString
                               forKey:@"PlacesString"];
}

- (BOOL)processPlacesArray:(NSUInteger)row
{
    if (_placesArray.count < 1)
        return FALSE;
    if (row >= CRAPI.sharedInstance.placesArray.count)
    {
        row = (CRAPI.sharedInstance.placesArray.count - 1);
        
        [UserDefaults.defaults saveInteger:(int)row
                                    forKey:@"SelectedRow"];
    }
    
    if (_placesArray.count == 1 || row >= _placesArray.count)
        row = 0;
    
    CityOrOrganizationData *c = _placesArray[row];
    _GSSiPadNumber = c.GSSiPadNumber;
    _currentCityNameAndState = addSpaceAfterComma(c.name);
    
    self.currentGeoid = c.number;
    
    [UserDefaults.defaults saveInteger:self.currentGeoid
                                forKey:@"CurrentGeoid"];
    
    _currentManageriPad = c.managerNumber;
    _currentiPadWithinManager = c.withinManager;
    _deviceNumber = _currentiPadWithinManager;
    _totiPadWithinManager = c.totWithinManager;
    
    NSString *key = [NSString stringWithFormat:@"ManagerForGeoid:%i",self.currentGeoid ];
    [UserDefaults.defaults saveInteger:_currentManageriPad
                                forKey:key];
    
    key = [NSString stringWithFormat:@"iPadWithinManagerForGeoid:%i",self.currentGeoid ];
    
    [UserDefaults.defaults saveInteger:_currentiPadWithinManager
                                forKey:key];
    
    key = [NSString stringWithFormat:@"totiPadWithinManagerForGeoid:%i",self.currentGeoid ];
    
    [UserDefaults.defaults saveInteger:_totiPadWithinManager
                                forKey:key];
    return TRUE;
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
        return;
    }
    if (!tot)
        return;
    CGFloat baseProgress = (CGFloat)iRange / nRanges;
    CGFloat thisProgress = baseProgress + current / (CGFloat)(tot * nRanges);
    progress = thisProgress * 100;
    if (progress > currentProgress)
    {
        currentProgress = progress;
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           CRAPI.sharedInstance.mapToolbar.progress = (float)currentProgress/100.0;
                       });
    }
}

@end