//  FTPDataPull.h
//  PedRampInv_Prelim

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "UserDefaults.h"
#import "GSSiPopoverView.h"

#define FTP_OK 0
#define FTP_STOP 1
#define FTP_CANCEL 2
#define FTP_FILE_WRITE_ERROR 101
#define FTP_CONNECTION_FAILED 102
#define FTP_CONNECTION_FAILED_TRYING_SECONDARY 103

@class FTPDataPull;

@protocol FTPDataPullDelegate <NSObject>

- (void) FTPdidComplete:(int)status
               filePath:(NSString *)path;

@end

@interface FTPDataPull : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id <FTPDataPullDelegate> delegate;
@property (nonatomic, assign, readonly ) BOOL isReceiving;
@property (nonatomic, assign, readwrite ) BOOL useOnlyPrimaryFTP;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, copy, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *fileStream;
@property (nonatomic, copy, readwrite) NSString *ftpSite;
@property (nonatomic, copy, readwrite) NSString *username;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, copy, readwrite) NSString *port;
@property (nonatomic, copy, readwrite) NSString *directory;
@property (nonatomic, copy, readwrite) NSString *toDirectory;
@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, copy, readwrite) NSString *toFileName;
@property (nonatomic, copy, readwrite) NSString *ftpSite2;
@property (nonatomic, copy, readwrite) NSString *username2;
@property (nonatomic, copy, readwrite) NSString *password2;
@property (nonatomic, copy, readwrite) NSString *currentFtp;
@property (nonatomic, copy, readwrite) NSString *urlText;
@property (nonatomic, assign, readwrite) BOOL hasFailed;
@property BOOL haveCalledDelegate;
@property (nonatomic) int geoid;
@property (nonatomic) NSUInteger totalDataReceived;
@property (nonatomic) NSUInteger fileSize;
@property (nonatomic) CGFloat progress;
@property (strong, nonatomic)GSSiPopoverView *popover;

+ (FTPDataPull *)pull;

- (void)getFile:(NSString *)fileName
  fromDirectory:(NSString *)fromDirectory
         toFile:(NSString *)toFileName
    toDirectory:(NSString *)toDirectory
   forceRefresh:(BOOL)refresh;

- (void)getFile:(NSString *)fileName
  fromDirectory:(NSString *)fromDirectory
    toDirectory:(NSString *)toDirectory
   forceRefresh:(BOOL)refresh;

- (void)startReceive:(NSString *)fileName;

- (void)stopReceiveWithStatus:(int)status
                 statusString:(NSString *)statusString;

@end