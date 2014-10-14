//
//  FTPDataPush.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/14/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
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

@interface FTPDataPush : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, weak) id <FTPDataPushDelegate> delegate;
@property (nonatomic, assign, readonly ) BOOL isSending;
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
@property (nonatomic, copy, readwrite) NSString *ftpSite2;
@property (nonatomic, copy, readwrite) NSString *username2;
@property (nonatomic, copy, readwrite) NSString *password2;
@property (nonatomic, copy, readwrite) NSString *currentFtp;
@property (nonatomic, copy, readwrite) NSString *urlText;
@property (nonatomic, assign, readwrite) BOOL hasFailed;
@property (nonatomic) int geoid;
@property (nonatomic) NSUInteger totalDataSent;
@property (nonatomic) NSUInteger fileSize;
@property (nonatomic) CGFloat progress;
@property (strong, nonatomic)GSSiPopoverView *popover;

+ (FTPDataPush *)push;

- (void)sendFile:(NSString *)fileName
  fromDirectory:(NSString *)fromDirectory
    toDirectory:(NSString *)toDirectory
   deleteWhenDone:(BOOL)delete;

- (void)startSend:(NSString *)fileName;

- (void)stopSendWithStatus:(int)status
                 statusString:(NSString *)statusString;

@end