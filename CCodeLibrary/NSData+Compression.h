//  NSData+Compression.h
//  CCodeLibrary

@import Foundation;
@import Compression;
#import "minilzo.h"

@interface NSData (Compression)

+ (NSData *)compressFileAtPath:(NSString *)filePath;
+ (NSData *)lzCompressFileAtPath:(NSString *)filePath;

@end