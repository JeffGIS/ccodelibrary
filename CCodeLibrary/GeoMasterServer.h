//  GeoMasterServer.h
//  CCodeLibrary

#define GMOK 0

#import <Foundation/Foundation.h>

@class GeoMasterServer;

@protocol GeoMasterServerDelegate  <NSObject>

- (void) GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
       withStatus:(int)status;

- (void) GMServer:(GeoMasterServer *)server
  didReceiveError:(NSString *)error
       withStatus:(int)status;

- (void) GMServerDidOpen:(GeoMasterServer*)server;

@end

@interface GeoMasterServer : NSObject<NSStreamDelegate>
@property (nonatomic, weak) id <GeoMasterServerDelegate> delegate;

+ (GeoMasterServer *)open;

@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain)NSInputStream *inputStream;
@property (nonatomic, retain)NSOutputStream *outputStream;
@property (nonatomic, retain)NSString *output;

- (BOOL) initCommunication;
- (void) closeServer;
- (IBAction) sendMessage:(NSString *)message;

@end