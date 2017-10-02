//  FTPDataPull.h
//  PedRampInv_Prelim

#import <Foundation/Foundation.h>
#import "UserDefaults.h"
#import "GSSiPopoverView.h"
#import "GSSiEnums.h"

typedef NS_ENUM(NSInteger, FTPDataPullRefreshOption)
{
    FTPDataPullRefreshOptionDefault,
    FTPDataPullRefreshOptionUseFileIfExists,
    FTPDataPullRefreshOptionOverwriteFile,
    FTPDataPullRefreshOptionCheckFileSize,
};

typedef NS_ENUM(NSInteger, FTPDataType)
{
    FTPDataPlat,
    FTPDataPDF,
    FTPDataJPG,
    FTPDataCrimes,
    FTPDataOther,
    GetDatabaseSettingProperty,
    GetDatabaseSettingTiles,
    GetDatabaseSettingParcels,
    GetDatabaseSettingAreas,
    GetDatabaseSettingSewer,
    GetDatabaseSettingPlan,
    GetDatabaseSettingCensus,
    GetDatabaseSettingAlleyWall,
    GetDatabaseSettingAlleyWallNew,
    GetDatabaseSettingCurbRamp,
    GetDatabaseSettingCrimes,
    GetDatabaseSettingMapleGrove,
    GetDatabaseSettingNVMetro,
    FTPDataPhoto,
    FTPData,
    FTPDatabase,
    FTPErrorFile,
};

@class FTPDataPull;

@protocol FTPDataPullDelegate <NSObject>

@optional
- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path;

@end

@interface FTPDataPull : NSObject <NSURLConnectionDataDelegate,GSSiPopoverViewDelegate>

@property (nonatomic, strong) id <FTPDataPullDelegate> delegate; //nonstandard strong pointer needed for intersection database init
@property (nonatomic, readonly) BOOL isReceiving;
@property BOOL useTestServer;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSOutputStream *fileStream;
@property (nonatomic, copy) NSString *ftpSiteOveride;
@property (nonatomic, copy) NSString *usernameOveride;
@property (nonatomic, copy) NSString *passwordOveride;
@property (nonatomic, copy) NSString *portOveride;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, copy) NSString *toDirectory;
@property BOOL createDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *toFileName;
@property (nonatomic, copy) NSString *username2;
@property (nonatomic, copy) NSString *password2;
@property (nonatomic, copy) NSString *urlText;
@property BOOL hasFailed;
//@property (nonatomic) BOOL haveCalledDelegate;
@property int geoid;
@property NSUInteger totalDataReceived;
@property unsigned long long fileSize;
@property CGFloat progress;
@property (nonatomic) GSSiPopoverView *popover;
@property FTPDataType dataType;

+ (FTPDataPull *)pull;

- (int)getFile:(NSString *)fileName
 fromDirectory:(NSString *)fromDirectory
        toFile:(NSString *)toFileName
   toDirectory:(NSString *)toDirectory
 refreshOption:(FTPDataPullRefreshOption)refreshOption;

- (void)startReceive:(NSString *)fileName;

- (void)stopReceiveWithStatus:(int)status
                 statusString:(NSString *)statusString;

@end
