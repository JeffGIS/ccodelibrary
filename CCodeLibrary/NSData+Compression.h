//  NSData+Compression.h
//  CCodeLibrary

@import Foundation;
@import Compression;
#import "minilzo.h"
#import <CommonCrypto/CommonDigest.h>

@interface NSData (Compression)

+ (NSData *)compressFileAtPath:(NSString *)filePath;
+ (NSData *)lzCompressFileAtPath:(NSString *)filePath;
- (NSString *)MD5;
- (NSString *)SHA256;

@end