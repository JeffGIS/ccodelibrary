//  GetPlaceAreaFile.m
//  CCodeLibrary

#import "GetPlaceAreaFile.h"

@implementation GetPlaceAreaFile


- (BOOL)getPlaceAreaFile:(GSSiPopoverView*)popover
                forGeoid:(int)geoid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
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
    
    else
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
