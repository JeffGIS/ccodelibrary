//  GeoMasterServer.h
//  CCodeLibrary

#define GM_OK 0
#define GM_OPEN_FAILED 101
#define GM_SEND_FAILED 102
#define GM_NO_RESPONSE 103

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, copy) NSString *ipAddress;
@property (nonatomic) BOOL didOpen;
@property (nonatomic) NSInteger messageID;
@property (nonatomic) NSTimer *openTimer, *sendTimer, *responseTimer;
@property (nonatomic) CGFloat responseTimeoutInSeconds;
@property (nonatomic) NSData *data;

- (BOOL) initCommunication:(float)connectionTimeoutInSeconds;
- (void) closeServer;
- (BOOL) sendMessage:(NSString *)message;

@end