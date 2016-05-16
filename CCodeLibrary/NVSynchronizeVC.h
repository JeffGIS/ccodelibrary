//  NVSynchronizeVC.h
//  CCodeLibrary

@import UIKit;

@class NVSynchronizeVC;

@protocol NVSynchronizeDelegate <NSObject>

- (void)synchronizeControllerDidReturn:(NVSynchronizeVC *)controller;

@end

@interface NVSynchronizeVC : UIViewController

@property (nonatomic, weak) id <NVSynchronizeDelegate> delegate;

@end