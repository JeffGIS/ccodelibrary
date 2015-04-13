//  GeoMasterServer.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GSSiEnums.h"

@class GeoMasterServer;

@protocol GeoMasterServerDelegate <NSObject>

- (void) GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
       withStatus:(long)status;

- (void) GMServer:(GeoMasterServer *)server
  didReceiveError:(NSString *)error
       withStatus:(long)status;

- (void) GMServerDidOpen:(GeoMasterServer *)server;

@end

@interface GeoMasterServer : NSObject <NSStreamDelegate>
@property (nonatomic, weak) id <GeoMasterServerDelegate> delegate;

+ (GeoMasterServer *)open;

@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, copy) NSString *ipAddress;
@property (nonatomic) BOOL didOpen;
@property (nonatomic) NSInteger messageID;
@property (nonatomic) NSTimer *openTimer, *sendTimer, *responseTimer;
@property (nonatomic) CGFloat responseTimeoutInSeconds;
@property (nonatomic) NSData *data;

- (BOOL)initCommunication:(CGFloat)connectionTimeoutInSeconds;
- (void)closeServer;
- (BOOL)sendMessage:(NSString *)message;

@end