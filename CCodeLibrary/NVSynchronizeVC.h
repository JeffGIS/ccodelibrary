//  NVSynchronizeVC.h
//  CCodeLibrary

#import "CurbRampData.h"
#import "AlleyWallData.h"

#define UPLOAD_DATA_PROCESS 1
#define UPLOAD_PICT_PROCESS 2
#define DOWNLOAD_DATA_PROCESS 3
#define DOWNLOAD_PICT_PROCESS 4

@import UIKit;

@class NVSynchronizeVC;

@protocol NVSynchronizeDelegate <NSObject>

- (void)synchronizeControllerDidReturn:(NVSynchronizeVC *)controller;

@end

@interface NVSynchronizeVC : UIViewController

@property (nonatomic, weak) id <NVSynchronizeDelegate> delegate;
@property (nonatomic) id databaseID;
@property (nonatomic) CurbRampData *crd;
@property (nonatomic) AlleyWallData *awd;
@property (nonatomic) NSString *uploadStatusMsg, *filePath;
@property NSTimer *sendTimer, *doTimer;
@property NSInteger currentServerMsgID;
@property int lastFileNumToUpload;
@property int lastFileNumOnServer;
@property int nextFileNumToUpload;
@property int lastPictNumToUpload;
@property int nextPictNumToUpload;
@property int downloadiPad;
@property int nextFileNumToDownload;
@property int lastFileNumToDownload;
@property int uploadedFiles;
@property int origUpFiles;
@property int currentProcess;
@property int numiPadsInMsg;
@property int myiPad;
@property int process;

@end