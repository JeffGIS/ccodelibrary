//  NetworkManager.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedInstance;

- (NSURL *)smartURLForString:(NSString *)str;
- (BOOL)isImageURL:(NSURL *)url;
- (BOOL)isBinaryURL:(NSURL *)url;

- (NSString *)pathForTestImage:(NSUInteger)imageNumber;
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix;

@property (nonatomic, assign, readonly ) NSUInteger networkOperationCount;

- (void)didStartNetworkOperation;
- (void)didStopNetworkOperation;

@end