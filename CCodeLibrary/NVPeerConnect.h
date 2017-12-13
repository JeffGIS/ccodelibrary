//  NVPeerConnect.h
//  CCodeLibrary

@import Foundation;

@interface NVPeerConnect : NSObject

@property (nonatomic) NSURL *fileToSend;

- (void)startAdvertising;
- (void)stopAdvertising;
- (void)startBrowsing;
- (void)stopBrowsing;

@end
