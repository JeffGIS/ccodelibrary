//  GetPlaceAreaFile.m
//  CCodeLibrary

#import "GetPlaceAreaFile.h"

@implementation GetPlaceAreaFile


- (BOOL)getPlaceAreaFile:(GSSiPopoverView*)popover
                forGeoid:(int)geoid
{
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = self;
    pull.popover = popover;
    
    [pull getFile:fileName
    fromDirectory:@"Bill/PlaceAreas"
      toDirectory:documentsDirectory
     forceRefresh:NO];
    
    return YES;
}

- (void)FTPdidComplete:(int)status
              filePath:(NSString *)path
{
    if (status == FTP_OK)
        status = AF_OK;
    
    else if (status != FTP_CONNECTION_FAILED_TRYING_SECONDARY)
    {
        status = AF_FAILED;
        path = @"";
    }
    
    [self.delegate getPlaceAreaFile:self
                         didGetFile:path
                         withStatus:status];
    
    return;
}

@end