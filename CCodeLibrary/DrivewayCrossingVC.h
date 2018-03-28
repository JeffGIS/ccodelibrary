//  DrivewayCrossingVC.h
//  CCodeLibrary

@import UIKit;
#import "RampStruct.h"

@class DrivewayCrossingVC;

@protocol DrivewayCrossingDelegate<NSObject>

- (void)drivewayCrossingController:(DrivewayCrossingVC *)controller
                     didReturnType:(DrivewayCrossingType)type;

@end

@interface DrivewayCrossingVC : UIViewController

+ (void)presentDrivewayCrossingInController:(UIViewController *)controller
                                   delegate:(id<DrivewayCrossingDelegate>)delegate;

@end
