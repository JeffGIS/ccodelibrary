//  GetAssignments.m
//  CCodeLibrary

#import "GetAssignments.h"

@implementation GetAssignments
{
    FTPDataPull * _pull;
}

- (BOOL)getAssignments:(GSSiPopoverView *)popover
              forGeoid:(int)geoid
          underManager:(int)manager
{
    NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    //NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%i_%i.txt", manager, geoid];
    
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
    _pull.useOnlyPrimaryFTP = YES;
    
    [_pull getFile:fileName
     fromDirectory:@"Bill/Assignments"
            toFile:fileName
       toDirectory:documentsDirectory
     refreshOption:FTPDataPullRefreshOptionCheckFileSize];
    
    return YES;
}

- (void)FTPdidComplete:(int)option
            withStatus:(int)status
              filePath:(NSString *)path
{
    if (status == FTPStatusConnectionFailedTryingSecondary)
        return;
    
    if (status == FTPStatusOK)
        status = GetAssStatusOK;
    
    else
    {
        status = GetAssStatusFailed;
        path = @"";
    }
    
    [self.delegate getAssignments:self
                       didGetFile:path
                       withStatus:status];
    
    return;
}

@end
