//  NVPeerConnect.m
//  CCodeLibrary

#import "NVPeerConnect.h"
@import MultipeerConnectivity;
#import "CRAPI.h"

@interface NVPeerConnect () <MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate>

@property (nonatomic) MCSession *session;
@property (nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic) MCNearbyServiceBrowser *browser;
@property (nonatomic) NSProgress *progress;

@end

@implementation NVPeerConnect

- (id)init
{
    self = [super init];
    
    if (self)
    {
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:UIDevice.currentDevice.name];
        NSString *serviceType = @"newvision-share";
        
        _session = [[MCSession alloc] initWithPeer:peerID
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
        
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID
                                                        discoveryInfo:nil
                                                          serviceType:serviceType];
        
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID
                                                    serviceType:serviceType];
        
        _session.delegate = self;
        _advertiser.delegate = self;
        _browser.delegate = self;
    }
    
    return self;
}

- (void)startAdvertising
{
    [_advertiser startAdvertisingPeer];
    NSLog(@"Device %@ did start advertising", _advertiser.myPeerID.displayName);
}

- (void)stopAdvertising
{
    [_advertiser stopAdvertisingPeer];
    NSLog(@"Device %@ did stop advertising", _advertiser.myPeerID.displayName);
}

- (void)startBrowsing
{
    [_browser startBrowsingForPeers];
    NSLog(@"Device %@ did start browsing", _browser.myPeerID.displayName);
}

- (void)stopBrowsing
{
    [_browser stopBrowsingForPeers];
    NSLog(@"Device %@ did stop browsing", _browser.myPeerID.displayName);
}

#pragma mark MCSession Delegate Methods

- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state
{
    NSLog(@"MCSession for device %@ with device %@ changed state: %li",
          session.myPeerID.displayName, peerID.displayName, state);
}

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    NSLog(@"MCSession for device %@ received NSData from device %@",
          session.myPeerID.displayName, peerID.displayName);
}

- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    NSLog(@"MCSession for device %@ received NSInputStream from device %@",
          session.myPeerID.displayName, peerID.displayName);
}

- (void)session:(MCSession *)session
didReceiveCertificate:(NSArray *)certificate
       fromPeer:(MCPeerID *)peerID
certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"MCSession for device %@ received certificate from device %@",
          session.myPeerID.displayName, peerID.displayName);
}

- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress
{
    NSLog(@"MCSession for device %@ started receiving resource from device %@",
          session.myPeerID.displayName, peerID.displayName);
    
    _progress = progress;
    
    [_progress addObserver:self
                forKeyPath:@"fractionCompleted"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    if (object == _progress)
    {
        NSLog(@"MCSession for device %@ updated progress on resource: %.2f%%",
              _session.myPeerID.displayName, (_progress.fractionCompleted * 100.0));
    }
    
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error
{
    NSLog(@"MCSession for device %@ finished receiving resource from device %@",
          session.myPeerID.displayName, peerID.displayName);
}

#pragma mark MCNearbyServiceBrowser Delegate Methods

- (void)browser:(MCNearbyServiceBrowser *)browser
      foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"Browser Device %@ found Advertiser Device %@ and will invite.",
          browser.myPeerID.displayName, peerID.displayName);
    
    [browser invitePeer:peerID
              toSession:_session
            withContext:nil
                timeout:30.0];
}

- (void)browser:(MCNearbyServiceBrowser *)browser
didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"ERROR: Device %@ could not browse (%@)",
          browser.myPeerID.displayName, error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser
       lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Browser Device %@ did lose Advertiser Device %@.",
          browser.myPeerID.displayName, peerID.displayName);
}

#pragma mark MCNearbyServiceAdvertiser Delegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"ERROR: Device %@ could not advertise (%@)",
          advertiser.myPeerID.displayName, error.localizedDescription);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler
{
    NSLog(@"Advertiser Device %@ received invite from Browser Device %@.",
          advertiser.myPeerID.displayName, peerID.displayName);
    
    invitationHandler(YES, _session);
}

@end
