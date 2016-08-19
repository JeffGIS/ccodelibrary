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
    geoid = geoid % 100000000;
    NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
    //NSString *documentsDirectory = UserDefaults.defaults.sharedFilePath;
    
    NSString *fileName = [NSString stringWithFormat:@"%i_%i.txt", manager, geoid];
    
    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = popover;
    
    [_pull getFile:fileName
     fromDirectory:@"NVCRIS/Assignments"
            toFile:fileName
       toDirectory:documentsDirectory
     refreshOption:FTPDataPullRefreshOptionCheckFileSize];
    
    return YES;
}

- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    GetAssStatus gaStatus = GetAssStatusDefault;
    
    if (status == FTPStatusConnectionFailedTryingSecondary)
        return;
    
    if (status == FTPStatusOK || status == FTPStatusFileExists)
        gaStatus = GetAssStatusOK;
    
    else
    {
        gaStatus = GetAssStatusFailed;
        path = @"";
    }
    
    [self.delegate getAssignments:self
                       didGetFile:path
                       withStatus:gaStatus];
    
    return;
}

@end