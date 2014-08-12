//
//  CRAPI.m
//  ADAFieldCollector2
//
//  Created by JEFFREY E SMITH on 5/27/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import "CRAPI.h"
#import "../../CCodeLibrary/CCodeLibrary/CCodeLibrary.h"
#import <UIKit/UIKit.h>

@implementation CRAPI

- (id)init
{
    self = [super init];
    if (self)
    {
        //persistencyManager = [[PersistencyManager alloc] init];
        
        //      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"BLDownloadImageNotification" object:nil];
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.outputDirectory = [NSString stringWithFormat:@"%@/ADAFiles", documentsDirectory];
        self.imageDirectory = [NSString stringWithFormat:@"%@/IntersectionImages", documentsDirectory];
        
        [[NSFileManager defaultManager]createDirectoryAtPath:self.outputDirectory
                                 withIntermediateDirectories:NO
                                                  attributes:nil
                                                       error:nil];
        [[NSFileManager defaultManager]createDirectoryAtPath:self.imageDirectory
                                 withIntermediateDirectories:NO
                                                  attributes:nil
                                                       error:nil];
        
    }
    
    return self;
}

+ (CRAPI*)sharedInstance
{
    // 1
    static CRAPI *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate,
                  ^{
                      _sharedInstance = [[CRAPI alloc] init];
                  });
    
    return _sharedInstance;
}
-(int) getCornerFromAdjustedRot:(int)adjustedRot atIntersection:(MPIntersection*)intersection
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
-(int) getCornerFromX:(int)x andY:(int)y atIntersection:(MPIntersection*)intersection
{
    //returns 81,23,45 or 67
    int  corner = -1;
    DPOINT midPt={intersection.lev21x,intersection.lev21y}, pt={x,y};
    
    float az = getazd(&midPt,&pt);
    int adjustedRot = ClockwiseDegFromNorth ((az * RADtoDEG) + intersection.intRotation);
    corner = [[CRAPI sharedInstance]getCornerFromAdjustedRot:adjustedRot atIntersection:intersection];
    return corner;
}
-(int) getQuadDeviderFromX:(int)x andY:(int)y atIntersection:(MPIntersection*)intersection
{
    //returns quad lines E=1,S=2,W=3,N=4
    int  devider;
    int  dist = 999;
    int  diff;
    
    DPOINT midPt={intersection.lev21x,intersection.lev21y}, pt={x,y};
    
    float az = getazd(&midPt,&pt);
    int adjustedRot = ClockwiseDegFromNorth ((az * RADtoDEG) + intersection.intRotation);
    diff = abs(diffInDegrees (adjustedRot,intersection.quadDev90));
    devider = 1;
    dist = diff;
    diff = abs(diffInDegrees (adjustedRot,intersection.quadDev180));
    if (diff < dist)
    {
        devider = 2;
        dist = diff;
    }
    diff = abs(diffInDegrees (adjustedRot,intersection.quadDev270));
    if (diff < dist)
    {
        devider = 3;
        dist = diff;
    }
    diff = abs(diffInDegrees (adjustedRot,intersection.quadDev0));
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
    NSString *outputFile = [NSString stringWithFormat:@"%@/Intersection_%i.txt",
                  self.outputDirectory,intID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFile])
        return YES;
    outputFile = [NSString stringWithFormat:@"%@/Uploaded_Intersection_%i.txt",
                  self.outputDirectory,intID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFile])
        return YES;
    return NO;
}
-(NSString *)getImageFileforIntersection:(int)intersectionID
                                   atLat:(double) lat
                                  andLon:(double)lon
{
    NSString *imageFile = [_imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Intersection_%i.jpg",intersectionID]];
    
    unsigned long long fileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:imageFile
                                                                                  error:nil] fileSize];
    if (fileSize > 0)
        return imageFile;
/*    http://maps.googleapis.com/maps/api/staticmap?center=$Y([STREETLL])@,$X([STREETLL])&zoom=[ZOOM]&size=640x640&maptype=[MAPTYPE]&sensor=false&key=AIzaSyBUL-TkaHIxWa8u6Jp9vqs6LzJfsbJoiOY
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&%@&sensor=true",lat, lon,@"zoom=10&size=270x70"];*/
    int zoom=21;
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%i&size=640x640&maptype=hybrid&sensor=false&key=AIzaSyBUL-TkaHIxWa8u6Jp9vqs6LzJfsbJoiOY",lat, lon,zoom];
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    
    int rtn = [UIImageJPEGRepresentation(image, 0.8) writeToFile:imageFile
                                                      atomically:YES];
/*    if (!rtn)
    {
        UIAlertView *saveError = [[UIAlertView alloc] initWithTitle:@"Save Image Error"
                                                            message:@"Unable to save image. Check available storage space."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                   otherButtonTitle:nil];
        saveError.delegate = self;
        [saveError showInView:self.view];
    }*/
    return imageFile;
}

@end
