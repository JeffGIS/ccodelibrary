//  NVPeerConnect.h
//  CCodeLibrary

@import Foundation;

@class NVPeerConnect;

@protocol NVPeerConnectDelegate <NSObject>

- (void)peerConnectDidReceiveFileAtPath:(NSString *)path;

@end

@interface NVPeerConnect : NSObject

@property (nonatomic, weak) id<NVPeerConnectDelegate> delegate;
@property (nonatomic) NSURL *fileToSend;

- (void)startAdvertising;
- (void)stopAdvertising;
- (void)startBrowsing;
- (void)stopBrowsing;

@end
