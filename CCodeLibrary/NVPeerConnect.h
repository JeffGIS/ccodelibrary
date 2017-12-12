//  NVPeerConnect.h
//  CCodeLibrary

@import Foundation;

@interface NVPeerConnect : NSObject

- (void)startAdvertising;
- (void)stopAdvertising;
- (void)startBrowsing;
- (void)stopBrowsing;

@end
