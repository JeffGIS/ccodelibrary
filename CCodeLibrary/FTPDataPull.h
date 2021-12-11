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
    GetDatabaseSettingHunting,
    GetDatabaseSettingNVMetro,
    GetDatabaseSettingNWI,
    FTPDataPhoto,
    FTPData,
    FTPDatabase,
    GOOGLESearch,
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
@property (nonatomic, assign, readonly ) BOOL isReceiving;
@property (nonatomic) BOOL useTestServer;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property NSString *filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *fileStream;
@property (nonatomic, copy, readwrite) NSString *ftpSiteOveride;
@property (nonatomic, copy, readwrite) NSString *usernameOveride;
@property (nonatomic, copy, readwrite) NSString *passwordOveride;
@property (nonatomic, copy, readwrite) NSString *portOveride;
@property (nonatomic, copy, readwrite) NSString *username;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, copy, readwrite) NSString *port;
@property (nonatomic, copy, readwrite) NSString *directory;
@property (nonatomic, copy, readwrite) NSString *toDirectory;
@property BOOL createDirectory;
@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, copy, readwrite) NSString *toFileName;
@property (nonatomic, copy, readwrite) NSString *username2;
@property (nonatomic, copy, readwrite) NSString *password2;
@property (nonatomic, copy, readwrite) NSString *urlText;
@property (nonatomic, assign, readwrite) BOOL hasFailed;
//@property (nonatomic) BOOL haveCalledDelegate;
@property (nonatomic) int geoid;
@property (nonatomic) NSUInteger totalDataReceived;
@property (nonatomic) unsigned long long fileSize;
@property (nonatomic) CGFloat progress;
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
