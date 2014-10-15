//  FTPDataPush.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "UserDefaults.h"
#import "GSSiPopoverView.h"

#define FTP_OK 0
#define FTP_STOP 1
#define FTP_CANCEL 2
#define FTP_FILE_WRITE_ERROR 101
#define FTP_CONNECTION_FAILED 102

@class FTPDataPush;

@protocol FTPDataPushDelegate  <NSObject>

- (void) FTPdidComplete:(int)status
               filePath:(NSString *)path;

@end

@interface FTPDataPush : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <FTPDataPushDelegate> delegate;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, copy, readwrite) NSString *filePath;
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
@property (nonatomic) int geoid;
@property (nonatomic) CGFloat progress;
@property (strong, nonatomic)GSSiPopoverView *popover;
@property (nonatomic) NSUInteger totalDataSent;

+ (FTPDataPush *)push;

- (BOOL)sendFile:(NSString *)fileName
   fromDirectory:(NSString *)fromDirectory
          toFile:(NSString *)toFileName
     toDirectory:(NSString *)toDirectory
  deleteWhenDone:(BOOL)delete;

- (BOOL)sendFile:(NSString *)fileName
   fromDirectory:(NSString *)fromDirectory
     toDirectory:(NSString *)toDirectory
  deleteWhenDone:(BOOL)delete;

- (BOOL)startSend:(NSString *)fileName;

- (void)stopSendWithStatus:(int)status
              statusString:(NSString *)statusString;

@end