//  CRAPI.m
//  CCodeLibrary

#import "CRAPI.h"
#import "GSSiDefs.h"
#import "MathUtil.h"
#import "TileGraphics.h"

@implementation CRAPI
{
    int _currentGeoidValue, _numAllowedZooms, _allowedZooms[3];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _currentGeoidValue = 0;
        _pickApInPixels = 50;
        _numAllowedZooms = 3;
        _allowedZooms[0] = 21;
        _allowedZooms[1] = 20;
        _allowedZooms[2] = 19;
        _maxDevices = 32;
        _controlledInterface = TRUE;
        _documentsDirectory = UserDefaults.defaults.localFilePath;
        _extractFile = [NSString stringWithFormat:@"%@/extract.png", _documentsDirectory];
        //_documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _crimeMode = PINMAP;
        _crimeTarget = @"Minneapolis Neighborhoods";
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

- (NSString*)sharedOutputDirectory
{
    NSString* outdir = [NSString stringWithFormat:@"%@/OutputFiles",self.sharedFilePath];
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

-(void)setCurrentZoom:(CGFloat)zoom
{
    _currentZoom = zoom;
}
-(void)setShowPlats:(int)showPlats
{
    _showPlats = showPlats;
}
- (NSString *)uploadDirectory
{
    NSString *uploadDirectory = [NSString stringWithFormat:@"PedRampSurvey/%i/%i", _currentManageriPad, _currentGeoidValue];
    return uploadDirectory;
}

- (void)intersectionInit:(MPIntersection *)currentIntersection
{
    currentIntersection.intID = -1;
    currentIntersection.dataUpdated = NO;
    currentIntersection.intRotation = 0;
    currentIntersection.doLater = NO;
    currentIntersection.timeComplete = 0;
    currentIntersection.name1 = @"NOTYETSET";
    currentIntersection.signal23Exists = NO;
    currentIntersection.signal45Exists = NO;
    currentIntersection.signal67Exists = NO;
    currentIntersection.signal81Exists = NO;
    currentIntersection.xWalkAExists = NO;
    currentIntersection.xWalkBExists = NO;
    currentIntersection.xWalkCExists = NO;
    currentIntersection.xWalkDExists = NO;
    currentIntersection.corner23isComplete = NO;
    currentIntersection.corner45isComplete = NO;
    currentIntersection.corner67isComplete = NO;
    currentIntersection.corner81isComplete = NO;
    currentIntersection.quadDev0 = 0;
    currentIntersection.quadDev90 = 90;
    currentIntersection.quadDev180 = 180;
    currentIntersection.quadDev270 = 270;
   
    for (int i = 1; i < 13; i++)
    {
        MPRamp *ramp = [currentIntersection.ramps objectAtIndex:i];
        ramp.rampNum = i;
        ramp.rampExists = NO;
        ramp.timeComplete = 0;
        ramp.isComplete = YES;
        ramp.xWalkisComplete = YES;
        ramp.signalisComplete = YES;
        ramp.hasPEDButton = NO;
        ramp.hasPEDSignal = NO;
        ramp.SteepTopOfCurb = 0;
        ramp.PedRampLip = 0;
        
        switch (i)
        {
            default:
                if (i % 2)
                    ramp.rampID = [NSString stringWithFormat:@"%i(Left)",i];
                
                else
                    ramp.rampID = [NSString stringWithFormat:@"%i(Right)",i];
                break;
                
            case 9:
                ramp.rampID = @"23 (Middle)";
                break;
                
            case 10:
                ramp.rampID = @"45 (Middle)";
                break;
                
            case 11:
                ramp.rampID = @"67 (Middle)";
                break;
                
            case 12:
                ramp.rampID = @"81 (Middle)";
                break;
        }
    }
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

/*
- (UIImage *)getMPLSImage:(int)size
                    atLat:(double)lat
                   andLon:(double)lon
                  andZoom:(int)zoom
{
    UIImage *compositeImage = nil;
    int worldx = 0, worldy = 0;
    int worldxEnd = 0, worldyEnd = 0;
    int tilex = 0, tiley = 0, tilexLeft = 0;
    int xinc = 0, yinc = 0;
    int xintile = 0, yintile = 0, xintileLeft = 0;
    int xincomposite = 0, yincomposite=0;
    int nxpixels = 0, nypixels = 0;
    int x = 0, y = 0;
    
    //get world pixel coordinates of center of composite image at current zoom
    LatLongToPixelXY_old(lat,lon, zoom, &worldx, &worldy);
    
    //adjust to upper left corner of composite image
    worldx -= (size / 2);
    worldy -= (size / 2);
    worldxEnd = (worldx + size);
    worldyEnd = (worldy + size);
    
    //get tile x and y index
    PixelXYToTileXY(worldx, worldy, &tilex, &tiley);
    tilexLeft = tilex;
    
    //get pixel within tile coordinates
    //xintile = xintileLeft = (worldx % 256);
    yintile = (worldy % 256);
    //xinc = (256 - xintile);
    yinc = (256 - yintile);
    y = worldy;
    
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    
    while (y < worldyEnd)
    {
        xincomposite = 0;
        x = worldx;
        tilex = tilexLeft;
        xintile = xintileLeft;
        xinc = (256 - xintile);
        
        while (x < worldxEnd)
        {
            
            UIImage *image = [self getTileImageForZoom:zoom
                                                 tilex:tilex
                                                 tiley:tiley];
            
            nxpixels = min(xinc, (size - xincomposite));
            nypixels = min(yinc, (size - yincomposite));
            
            CGImageRef subimage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(xintile, yintile, nxpixels, nypixels));
            image = [UIImage imageWithCGImage:subimage];
            CGImageRelease(subimage);
            
            [image drawInRect:CGRectMake(xincomposite, yincomposite, nxpixels, nypixels)];
            
            tilex++;
            x += xinc;
            xinc = 256;
            xincomposite += nxpixels;
            xintile = 0;
        }
        
        tiley++;
        y += yinc;
        yinc = 256;
        yincomposite += nypixels;
        yintile = 0;
    }
    
    compositeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compositeImage;
}

- (UIImage *)getTileImageForZoom:(int)zoom
                           tilex:(int)tilex
                           tiley:(int)tiley
{
    UIImage *tileImage = nil;
    
    NSString *sharedDir = UserDefaults.defaults.sharedFilePath;
    
    NSString *filepath = [NSString stringWithFormat:@"%@/%i_%lu_%lu_%lu.jp2",
                          sharedDir, self.currentGeoid,
                          (unsigned long)zoom, (unsigned long)tiley, (unsigned long)tilex];
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    if ([fileManager fileExistsAtPath:filepath])
        tileImage = [UIImage imageWithContentsOfFile:filepath];
    
    else
    {
        NSString *MPLSurls = [NSString stringWithFormat:@"http://gssidata.com/MPLSADA/%lu/%lu/%lu.jp2",
                                  (unsigned long)zoom, (unsigned long)tiley, (unsigned long)tilex];
            
        NSURL *mapUrl = [NSURL URLWithString:[MPLSurls stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        tileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:mapUrl]];
        
        if (![UIImageJPEGRepresentation(tileImage, 0.8) writeToFile:filepath
                                                         atomically:YES])
        {
            NSLog(@"Tile Image Write ERROR at filepath:%@",
                  filepath);
        }
    }
    
    return tileImage;
}

- (NSString *)getImageFileforIntersection:(int)intersectionID
                                    atLat:(double)lat
                                   andLon:(double)lon
                                  andZoom:(int)zoom
                             forceRefresh:(BOOL)refresh
{
    BOOL MPLS = NO;
    refresh = YES;
    if (CRAPI.sharedInstance.currentGeoid == 2743000)
        MPLS = YES;

    
    if (refresh)
        [self deleteImagesForAllZooms:intersectionID];
    
    NSString *imageFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Int_%i_%i.jpg",
                                                                           intersectionID, zoom]];
    
    NSString *cptFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Int_%i_%i.cpt",
                                                                         intersectionID, zoom]];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:imageFile
                                                                                 error:nil].fileSize;
    if (fileSize > 0 && !refresh)
        return imageFile;
    
    UIImage *image = nil;
    
    if (MPLS)
    {
        image = [self getMPLSImage:640
                             atLat:lat
                            andLon:lon
                           andZoom:zoom];
    }
    
    else
    {
        NSString *staticMapUrl =
        [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%i&size=640x640&maptype=hybrid&key=%@",
         lat, lon, zoom, GOOGLE_API_KEY];
        
        NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    }
    
    int rtn = [UIImageJPEGRepresentation(image, 0.8) writeToFile:imageFile
                                                      atomically:YES];
    {
        char txt[1024] = {0};
        double pixelX = 0.0, pixelY = 0.0;
        int factor = pow(2, (21 - zoom));
        NSError *error = nil;
        
        LatLongToPixelXYd(lat, lon, 21, &pixelX, &pixelY);
        
        sprintf(txt, "0 0 %f %f\r\n\
                640 0 %f %f\r\n\
                640 640 %f %f\r\n\
                0 640 %f %f\r\n",
                pixelX - 320 * factor, pixelY + 320 * factor,
                pixelX + 320 * factor, pixelY + 320 * factor,
                pixelX + 320 * factor, pixelY - 320 * factor,
                pixelX - 320 * factor, pixelY - 320 * factor);
        
        NSString *outcontents = [NSString stringWithCString:txt
                                                   encoding:NSUTF8StringEncoding];
        
        if (![outcontents writeToFile:cptFile
                           atomically:NO
                             encoding:NSUTF8StringEncoding
                                error:&error])
        {
            NSLog(@"ERROR (getImageFileforIntersection): %@", error.localizedDescription);
        }
    }
    
    if (!rtn && _currentView)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:_currentView
                                                          delegate:self
                                                             title:@"Error getting intersection image. Unable to access server."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
#pragma unused(alert)
    }
    
   
    return imageFile;
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:YES];
}*/

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

- (dbounds) getBoundsAtPoint:(CLLocationCoordinate2D*)pt andDist:(CGFloat)meters
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

- (dbounds) getPickApBoundsAtPoint:(LLPOINT*)pt
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

- (NSString *)sharedFilePath
{
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    NSURL *groupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:
                                @"group.com.GSSi.SurveyApps"];
    
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
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
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

- (NSInteger) adjustNextRefno:(NSInteger)refno
{
    NSInteger nextRef = refno % _maxDevices;
    
    if (nextRef < _deviceNumber)
        nextRef = refno - nextRef + _deviceNumber;
    else
        nextRef = refno - nextRef + _maxDevices +_deviceNumber;
    return nextRef;
}

- (void)processPlacesArray:(NSUInteger) row
{
    if (row >= CRAPI.sharedInstance.placesArray.count)
    {
        row = (CRAPI.sharedInstance.placesArray.count - 1);
        
        [UserDefaults.defaults saveInteger:(int)row
                                    forKey:@"SelectedRow"];
    }
    
    if (_placesArray.count == 1 || row >= _placesArray.count ||
        self.currentGeoid == 0)
    {
        row = 0;
    }
    
    NSString *locationLabelText = textInsideParentheses(_placesArray[row]);
    _currentCityNameAndState = addSpaceAfterComma(locationLabelText);
    NSString *geoid = textBeforeParentheses(_placesArray[row]);
    NSString *manager = textAfterClosingParentheses(_placesArray[row]);
    NSString *managerNumber = textBeforeHyphen(manager);
    NSString *withinManager = textAfterHyphen(manager);
    NSString *numWithinManager = textBefore(withinManager, @"of");
    NSString *totWithinManager = textAfter(withinManager, @"of");
    
    self.currentGeoid = geoid.intValue;
    
    [UserDefaults.defaults saveInteger:self.currentGeoid
                                forKey:@"CurrentGeoid"];
    
    _currentManageriPad = managerNumber.intValue;
    _currentiPadWithinManager = numWithinManager.intValue;
    _totiPadWithinManager = totWithinManager.intValue;
    NSString *key = [NSString stringWithFormat:@"ManagerForGeoid:%i",geoid.intValue];
    [UserDefaults.defaults saveInteger:_currentManageriPad
                                forKey:key];
    key = [NSString stringWithFormat:@"iPadWithinManagerForGeoid:%i",geoid.intValue];
    [UserDefaults.defaults saveInteger:_currentiPadWithinManager
                                forKey:key];
    key = [NSString stringWithFormat:@"totiPadWithinManagerForGeoid:%i",geoid.intValue];
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

- (void)setMapToolbarProgress:(CGFloat)mapToolbarProgress
{
    _mapToolbarProgress = mapToolbarProgress;
    
    [CRAPI.sharedInstance.mapToolbar.progressView setProgress:_mapToolbarProgress
                                                     animated:NO];
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
                           CRAPI.sharedInstance.mapToolbarProgress = (float)currentProgress/100.0;
                       });
    }
}
@end