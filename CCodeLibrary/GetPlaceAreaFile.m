//
//  GetPlaceAreaFile.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/24/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import "GetPlaceAreaFile.h"

@implementation GetPlaceAreaFile


- (BOOL)getPlaceAreaFile:(id)id
                forGeoid:(int)geoid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    
    FTPDataPull *pull = FTPDataPull.pull;
    pull.delegate = self;
    
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
