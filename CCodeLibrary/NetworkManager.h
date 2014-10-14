//  NetworkManager.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedInstance;

- (NSURL *)smartURLForString:(NSString *)str;
- (BOOL)isImageURL:(NSURL *)url;
- (BOOL)isBinaryURL:(NSURL *)url;

@property (nonatomic, assign, readonly ) NSUInteger networkOperationCount;

- (void)didStartNetworkOperation;
- (void)didStopNetworkOperation;

@end