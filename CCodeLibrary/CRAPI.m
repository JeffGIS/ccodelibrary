//  CRAPI.m
//  CCodeLibrary

#import "../../CCodeLibrary/CCodeLibrary/CCodeLibrary.h"
#import <UIKit/UIKit.h>

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
        _numAllowedZooms = 3;
        _allowedZooms[0] = 21;
        _allowedZooms[1] = 20;
        _allowedZooms[2] = 19;
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
    }
    
    return self;
}

+ (CRAPI *)sharedInstance
{
    static CRAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,
                  ^{
                      _sharedInstance = [[CRAPI alloc] init];
                  });
    
    return _sharedInstance;
}

-(int)currentGeoid
{
    return _currentGeoidValue;
}

-(void)setCurrentGeoid:(int)geoid
{
    BOOL rtn = TRUE;
    if (geoid != _currentGeoidValue)
    {
        _currentGeoidValue = geoid;
        self.outputDirectory = [NSString stringWithFormat:@"%@/%i/ADAFiles", self.documentsDirectory,_currentGeoidValue];
        self.imageDirectory = [NSString stringWithFormat:@"%@/%i/IntersectionImages", self.documentsDirectory,_currentGeoidValue];
        
        rtn = [NSFileManager.defaultManager createDirectoryAtPath:self.outputDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
        
        rtn = [NSFileManager.defaultManager createDirectoryAtPath:self.imageDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
    }
}
- (void)intersectionInit:(MPIntersection *)currentIntersection
{
    currentIntersection.intID = -1;
    currentIntersection.dataUpdated = NO;
    currentIntersection.pairedMode = 0;
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
    currentIntersection.quadDev90 = 0;
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
        ramp.SteepTopOfCurve = 0;
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

- (int) adjustQuadDev:(int)normalRot
             fromAZMs:(NSArray *)azms
           withIntRot:(int)intRot
{
    int rtn = normalRot;
    int minDiff = 999;
    int minRot = 0;
    
    for (NSString * cazm in azms)
    {
        float az = cazm.floatValue;
        int adjustedRot = ClockwiseDegFromNorth((az * RADtoDEG) + intRot);
        int diff = abs (normalRot - adjustedRot);
        
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
    currentIntersection.intRotation = [self intRotFromintAZMS:intAzm];
    NSArray *azm = [intAzm componentsSeparatedByString:@"|"];
    
    currentIntersection.quadDev0 = 0;
    currentIntersection.quadDev90 = [self adjustQuadDev:90 fromAZMs:azm withIntRot:currentIntersection.intRotation];
    currentIntersection.quadDev180 = [self adjustQuadDev:180 fromAZMs:azm withIntRot:currentIntersection.intRotation];
    currentIntersection.quadDev270 = [self adjustQuadDev:270 fromAZMs:azm withIntRot:currentIntersection.intRotation];
    
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
    
    az = atof (pBeg);
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

-(int) getCornerFromX:(int)x
                 andY:(int)y
       atIntersection:(MPIntersection *)intersection
{
    //returns 81,23,45 or 67
    int  corner = -1;
    DPOINT midPt = {intersection.lev21x,intersection.lev21y}, pt = {x,y};
    
    float az = getazd(&midPt, &pt);
    int adjustedRot = ClockwiseDegFromNorth((az * RADtoDEG) + intersection.intRotation);
    
    corner = [CRAPI.sharedInstance getCornerFromAdjustedRot:adjustedRot
                                             atIntersection:intersection];
    return corner;
}

-(int) getQuadDeviderFromX:(int)x
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
        dist = diff;
    }
    
    return devider;
}

-(NSString *)getOutputDirectory
{
    return self.outputDirectory;
}

- (BOOL)intersectionAlreadyCompleted:(int)intID
{
    NSString *outputFile = [NSString stringWithFormat:@"%@/Intersection_%i.txt", self.outputDirectory, intID];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:outputFile])
        return YES;
    
    outputFile = [NSString stringWithFormat:@"%@/Uploaded_Intersection_%i.txt", self.outputDirectory, intID];
    
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

-(NSString *)getImageFileforIntersection:(int)intersectionID
                                   atLat:(double)lat
                                  andLon:(double)lon
                                 andZoom:(int)zoom
                            forceRefresh:(BOOL)refresh
{
    if (refresh)
    {
        [self deleteImagesForAllZooms:intersectionID];
    }
    
    NSString *imageFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Int_%i_%i.jpg", intersectionID, zoom]];
    NSString *cptFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Int_%i_%i.cpt", intersectionID, zoom]];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:imageFile
                                                                                 error:nil].fileSize;
    if (fileSize > 0 && refresh == NO)
        return imageFile;
    
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%i&size=640x640&maptype=hybrid&sensor=false&key=%@", lat, lon, zoom, GOOGLE_API_KEY];
    
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    
    int rtn = [UIImageJPEGRepresentation(image, 0.8) writeToFile:imageFile
                                                      atomically:YES];
    
    if (!rtn)
    {
        UIAlertView *getError = [[UIAlertView alloc]initWithTitle:@"Error getting intersection image."
                                                          message:@"Unable to access server."
                                                         delegate:self
                                                cancelButtonTitle:@"Continue"
                                                otherButtonTitles:nil];
        [getError show];
    }
    
    else
    {
        char txt[1024];
        double pixelX, pixelY;
        int factor = pow(2,21-zoom);
        NSError *err;

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
                                error:&err])
        {

        }
    }
    return imageFile;
}

- (UIImage *)getStreetViewImageAtLatlon:(LLPOINT)atLatLon
                                heading:(CGFloat)heading
                                  pitch:(CGFloat)pitch
                                    fov:(CGFloat)fov
{
    UIImage *image = nil;
    
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/streetview?size=640x640&location=%f,%f&fov=%f&heading=%f&pitch=%f&sensor=false&key=%@",
                              atLatLon.lat, atLatLon.lon, fov, heading, pitch, GOOGLE_API_KEY];
    
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    return image;
}


- (BOOL)getPlaceIntersectionFile:(id)id
forGeoid:(int)geoid
{
    return YES;
}

- (NSString*)directoryFromPath:(NSString *)path
                       andName:(NSString *)name
                        create:(BOOL)create
{
    LPSTR str = malloc(path.length + 2);
    LPSTR pBS;
    NSString *outDir = @"";
    
    strcpy(str,path.UTF8String);
    
    if ((pBS = strrchr(str,'/')))
    {
        *pBS = 0;
        strcat (str, name.UTF8String);
        outDir = [NSString stringWithUTF8String:str];
    }
    
    free(str);
    if (create)
    {
        int rtn = [NSFileManager.defaultManager createDirectoryAtPath:outDir
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];

    }
    return outDir;
}
-(IPOINT) PointAtZoom:(int)zoom
        fromViewPoint:(CGPoint)pt
      usingProjection:(GMSProjection *)projection
{
    IPOINT zoomPt;
    CLLocationCoordinate2D latlon = [projection coordinateForPoint:pt];
    LatLongToPixelXY(latlon.latitude, latlon.longitude, zoom, &zoomPt.x, &zoomPt.y);
    return zoomPt;
}

- (IBOUNDS)boundsFromRect:(CGRect)rect
                   atZoom:(int)zoom
          usingProjection:(GMSProjection *)projection
{
    IBOUNDS iBounds;
    CGPoint pt;
    IPOINT pt21;
    
    InitIBounds(&iBounds);
    pt.x = rect.origin.x;
    pt.y = rect.origin.y;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt
             usingProjection:projection];
    
    AddPointToIBounds(&iBounds, &pt21);
    pt.x += rect.size.width;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt
             usingProjection:projection];
    
    AddPointToIBounds(&iBounds, &pt21);
    pt.y += rect.size.height;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt
             usingProjection:projection];
    
    AddPointToIBounds(&iBounds, &pt21);
    pt.x = rect.origin.x;
    
    pt21 = [self PointAtZoom:21
               fromViewPoint:pt
             usingProjection:projection];
    
    AddPointToIBounds(&iBounds, &pt21);
    return iBounds;
}

- (IBOUNDS) CGRectToIBounds:(CGRect)rect
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
    CGPoint pt;
    
    return pt;
}
- (CGPoint)pointForLev21Coordinate:(IPOINT)lev21pt
               usingTransformation:(LPTRANDATA)pTranWToBMP
{
    CGPoint pt;
    
    TRANS2(lev21pt.x, lev21pt.y, &pt.x, &pt.y, pTranWToBMP);
    return pt;
}
- (IBOUNDS)boundsFromRect:(CGRect)rect
          usingTransformation:(LPTRANDATA)pTranBMPToW
{
    IBOUNDS iBounds,outBounds;
    
    iBounds = [self CGRectToIBounds:rect];
    TranMNMXCORL(&iBounds,&outBounds,pTranBMPToW);
    return outBounds;
}


@end