//  CRAPI.m
//  CCodeLibrary

#import "CRAPI.h"
#import "../../CCodeLibrary/CCodeLibrary/CCodeLibrary.h"
#import <UIKit/UIKit.h>

@implementation CRAPI

- (id)init
{
    self = [super init];
    
    if (self)
    {
/*
        persistencyManager = [[PersistencyManager alloc] init];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(downloadImage:)
                                                   name:@"BLDownloadImageNotification"
                                                 object:nil];
*/
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.outputDirectory = [NSString stringWithFormat:@"%@/ADAFiles", documentsDirectory];
        self.imageDirectory = [NSString stringWithFormat:@"%@/IntersectionImages", documentsDirectory];
        
        [NSFileManager.defaultManager createDirectoryAtPath:self.outputDirectory
                                withIntermediateDirectories:NO
                                                 attributes:nil
                                                      error:nil];
        
        [NSFileManager.defaultManager createDirectoryAtPath:self.imageDirectory
                                withIntermediateDirectories:NO
                                                 attributes:nil
                                                      error:nil];
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

- (void) intersectionInit:(MPIntersection* )currentIntersection
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
   
	//int nramps = (int)currentIntersection.ramps.count;
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

-(void)setIntersectionRotAndQuadDeviders:(NSString *)intAzm
                                  forInt:(MPIntersection*)currentIntersection
{
    currentIntersection.intRotation = [self intRotFromintAZMS:intAzm];
    currentIntersection.quadDev90 = 0;
    currentIntersection.quadDev90 = 90;
    currentIntersection.quadDev180 = 180;
    currentIntersection.quadDev270 = 270;
    
}
-(double) azDiffFrom90s:(double)az
{
    double minDiff = 0 - az;
    double diff;
    
    diff = TWOPI - az;
    
    if (fabs (diff) < fabs (minDiff))
        minDiff = diff;
    
    diff = HALFPI - az;
    
    if (fabs (diff) < fabs (minDiff))
        minDiff = diff;
    
    diff = PY - az;
    
    if (fabs (diff) < fabs (minDiff))
        minDiff = diff;
    
    diff = (HALFPI*3) - az;
    
    if (fabs (diff) < fabs (minDiff))
        minDiff = diff;
    
    return minDiff;
    
}

-(int) intRotFromintAZMS:(NSString *)intAzm
{
    int rtn = 0;
    double minDiff=10, az, diff;
    char * intAZMS = malloc ([intAzm length]+1);
    strcpy (intAZMS,intAzm.UTF8String);
    char * pBeg=intAZMS;
    char * pEnd=strchr (pBeg,'|');
    
    while (pEnd)
    {
        *pEnd++ = 0;
        az = atof (pBeg);
        diff = [self azDiffFrom90s:az];
        if (fabs(diff)<fabs(minDiff))
            minDiff = diff;
        pBeg = pEnd;
        pEnd=strchr (pBeg,'|');
    }
    
    az = atof (pBeg);
    diff = [self azDiffFrom90s:az];
    
    if (fabs(diff)<fabs(minDiff))
        minDiff = diff;
    
    rtn = minDiff * RADtoDEG;
    free (intAZMS);
    return rtn;
}

-(int) getCornerFromAdjustedRot:(int)adjustedRot
                 atIntersection:(MPIntersection*)intersection
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
       atIntersection:(MPIntersection*)intersection
{
    //returns 81,23,45 or 67
    int  corner = -1;
    DPOINT midPt={intersection.lev21x,intersection.lev21y}, pt={x,y};
    
    float az = getazd(&midPt, &pt);
    int adjustedRot = ClockwiseDegFromNorth ((az * RADtoDEG) + intersection.intRotation);
    
    corner = [CRAPI.sharedInstance getCornerFromAdjustedRot:adjustedRot
                                             atIntersection:intersection];
    return corner;
}
-(int) getQuadDeviderFromX:(int)x
                      andY:(int)y
            atIntersection:(MPIntersection*)intersection
{
    //returns quad lines E=1,S=2,W=3,N=4
    int  devider;
    int  dist = 999;
    int  diff;
    
    DPOINT midPt={intersection.lev21x,intersection.lev21y}, pt={x,y};
    
    float az = getazd(&midPt, &pt);
    int adjustedRot = ClockwiseDegFromNorth ((az * RADtoDEG) + intersection.intRotation);
    diff = abs(diffInDegrees (adjustedRot, intersection.quadDev90));
    devider = 1;
    dist = diff;
    diff = abs(diffInDegrees (adjustedRot, intersection.quadDev180));
    
    if (diff < dist)
    {
        devider = 2;
        dist = diff;
    }
    
    diff = abs(diffInDegrees (adjustedRot, intersection.quadDev270));
    
    if (diff < dist)
    {
        devider = 3;
        dist = diff;
    }
    
    diff = abs(diffInDegrees (adjustedRot, intersection.quadDev0));
    
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

- (BOOL) intersectionAlreadyCompleted:(int)intID
{
    NSString *outputFile = [NSString stringWithFormat:@"%@/Intersection_%i.txt", self.outputDirectory,intID];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:outputFile])
        return YES;
    
    outputFile = [NSString stringWithFormat:@"%@/Uploaded_Intersection_%i.txt", self.outputDirectory,intID];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:outputFile])
        return YES;
    
    return NO;
}
-(NSString *)getImageFileforIntersection:(int)intersectionID
                                   atLat:(double)lat
                                  andLon:(double)lon
{
    NSString *imageFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Int_%i.jpg",intersectionID]];
    NSString *cptFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Int_%i.cpt",intersectionID]];
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:imageFile
                                                                                  error:nil].fileSize;
    if (fileSize > 0)
        return imageFile;
    
/*    
    http://maps.googleapis.com/maps/api/staticmap?center=$Y([STREETLL])@,$X([STREETLL])&zoom=[ZOOM]&size=640x640&maptype=[MAPTYPE]&sensor=false&key=AIzaSyBUL-TkaHIxWa8u6Jp9vqs6LzJfsbJoiOY
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&%@&sensor=true",lat, lon,@"zoom=10&size=270x70"];
*/
    
    int zoom = 21;
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%i&size=640x640&maptype=hybrid&sensor=false&key=AIzaSyBUL-TkaHIxWa8u6Jp9vqs6LzJfsbJoiOY",lat, lon, zoom];
    
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
        NSError *err;

        LatLongToPixelXYd(lat, lon, zoom, &pixelX, &pixelY);

        sprintf (txt,"0 0 %f %f\r\n\
                 640 0 %f %f\r\n\
                 640 640 %f %f\r\n\
                 0 640 %f %f\r\n",
                 pixelX - 320, pixelY + 320,
                 pixelX + 320, pixelY + 320,
                 pixelX + 320, pixelY - 320,
                 pixelX - 320, pixelY - 320
                );
        NSString *outcontents = [NSString stringWithCString:txt
                                                   encoding:NSUTF8StringEncoding];
        if (![outcontents writeToFile:cptFile
                           atomically:NO
                             encoding:NSUTF8StringEncoding
                                error:&err])
        {
            //[self displayError:err];
        }
    }
    return imageFile;
}

-(BOOL) getPlaceAreaFile:(id)id forGeoid:(int)geoid;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = id;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/PlaceAreas"
      toDirectory:documentsDirectory
     forceRefresh:NO];
    return TRUE;
}

-(BOOL) getPlaceIntersectionFile:(id)id forGeoid:(int)geoid;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = id;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/PlaceAreas"
      toDirectory:documentsDirectory
     forceRefresh:NO];
    return TRUE;
}

@end