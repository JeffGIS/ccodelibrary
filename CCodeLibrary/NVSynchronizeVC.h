//  NVSynchronizeVC.h
//  CCodeLibrary
#import "CurbRampData.h"

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
@property id databaseID;
@property CurbRampData * crd;
@property NSTimer * sendTimer;
@property NSTimer * doTimer;
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
@property NSString* uploadStatusMsg;
@property int numiPadsInMsg;
@property int myiPad;
@property NSString* filePath;
@property int process;
@end