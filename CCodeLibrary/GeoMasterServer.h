//  GeoMasterServer.h
//  CCodeLibrary

#define GM_OK 0
#define GM_OPEN_FAILED 101
#define GM_SEND_FAILED 102

#import <Foundation/Foundation.h>

@class GeoMasterServer;

@protocol GeoMasterServerDelegate<NSObject>

- (void) GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
       withStatus:(long)status;

- (void) GMServer:(GeoMasterServer *)server
  didReceiveError:(NSString *)error
       withStatus:(long)status;

- (void) GMServerDidOpen:(GeoMasterServer*)server;

@end

@interface GeoMasterServer : NSObject<NSStreamDelegate>
@property (nonatomic, weak) id <GeoMasterServerDelegate> delegate;

+ (GeoMasterServer *)open;

@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain)NSInputStream *inputStream;
@property (nonatomic, retain)NSOutputStream *outputStream;
@property (nonatomic, retain)NSString *output;
@property NSTimer *openTimer;
@property NSTimer *sendTimer;
@property NSData *data;

- (BOOL) initCommunication:(float)connectionTimeoutInSeconds;
- (void) closeServer;
- (BOOL) sendMessage:(NSString *)message;

@end