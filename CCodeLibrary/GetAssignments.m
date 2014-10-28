//  GetAssignments.m
//  CCodeLibrary

#import "GetAssignments.h"

@implementation GetAssignments
{
    FTPDataPull * _pull;
}

- (BOOL)getAssignments:(GSSiPopoverView *)popover
              forGeoid:(int)geoid
          underManager:(NSString *)manager
{
    NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    //NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%i.txt", manager,geoid];
    
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
    
    [_pull getFile:fileName
    fromDirectory:@"Bill/Assignments"
      toDirectory:documentsDirectory
     forceRefresh:NO];
    
    return YES;
}

- (void)FTPdidComplete:(int)status
              filePath:(NSString *)path
{
    if (status == FTP_CONNECTION_FAILED_TRYING_SECONDARY)
        return;
    if (status == FTP_OK)
        status = GETASS_OK;
    
    else
    {
        status = GETASS_FAILED;
        path = @"";
    }
    
    [self.delegate getAssignments:self
                       didGetFile:path
                       withStatus:status];
    
    return;
}

@end
