//  GetPlaceAreaFile.m
//  CCodeLibrary

#import "GetPlaceAreaFile.h"

@implementation GetPlaceAreaFile


- (BOOL)getPlaceAreaFile:(GSSiPopoverView *)popover
                forGeoid:(int)geoid
{
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
    _pull.createDirectory = YES;
    [_pull getFile:fileName
    fromDirectory:@"Bill/PlaceAreas"
           toFile:fileName
      toDirectory:documentsDirectory
    refreshOption:FTPDataPullRefreshOptionUseFileIfExists];
    
    return YES;
}

- (void)FTPdidComplete:(int)option
            withStatus:(int)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    if (status == FTPStatusOK || status == FTPStatusFileExists)
        status = AreaFileStatusOK;
    
    else if (status != FTPStatusConnectionFailedTryingSecondary)
    {
        status = AreaFileStatusFailed;
        path = @"";
    }
    
    [self.delegate getPlaceAreaFile:self
                         didGetFile:path
                         withStatus:status];
}
-(void) dealloc
{
    self.delegate = nil;
}
@end