//  FTPDataPush.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "FTPDataPull.h"
#import "UserDefaults.h"
#import "GSSiPopoverView.h"
#import "GSSiEnums.h"

@class FTPDataPush;

@protocol FTPDataPushDelegate <NSObject>

- (void)FTPPushDidComplete:(FTPDataType)dataType
                withStatus:(int)status
           andStatusString:(NSString *)statusString
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
@property (nonatomic, assign, readwrite ) BOOL useOnlyPrimaryFTP;
@property (nonatomic) int geoid;
@property (nonatomic) CGFloat progress;
@property (nonatomic) GSSiPopoverView *popover;
@property (nonatomic) NSUInteger totalDataSent;
@property FTPDataType dataType;

+ (FTPDataPush *)push;

- (BOOL)sendFile:(NSString *)fileName
   fromDirectory:(NSString *)fromDirectory
          toFile:(NSString *)toFileName
     toDirectory:(NSString *)toDirectory
  deleteWhenDone:(BOOL)deleteWhenDone;

- (BOOL)startSend:(NSString *)fileName;

- (void)stopSendWithStatus:(int)status
              statusString:(NSString *)statusString;

@end