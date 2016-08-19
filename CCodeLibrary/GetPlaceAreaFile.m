//  GetPlaceAreaFile.m
//  CCodeLibrary

#import "GetPlaceAreaFile.h"

@implementation GetPlaceAreaFile


- (BOOL)getPlaceAreaFile:(GSSiPopoverView *)popover
                forGeoid:(int)geoid
{
    geoid = geoid % 100000000;
    //NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
    _pull.createDirectory = YES;
    [_pull getFile:fileName
    fromDirectory:@"NVCRIS/PlaceAreas"
           toFile:fileName
      toDirectory:documentsDirectory
    refreshOption:FTPDataPullRefreshOptionUseFileIfExists];
    
    return YES;
}

- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    AreaFileStatus afStatus = AreaFileStatusDefault;
    
    if (status == FTPStatusOK || status == FTPStatusFileExists)
        afStatus = AreaFileStatusOK;
    
    else if (status != FTPStatusConnectionFailedTryingSecondary)
    {
        afStatus = AreaFileStatusFailed;
        path = @"";
    }
    
    [self.delegate getPlaceAreaFile:self
                         didGetFile:path
                         withStatus:afStatus
                    andStatusString:statusString];
}
-(void) dealloc
{
    self.delegate = nil;
}
@end