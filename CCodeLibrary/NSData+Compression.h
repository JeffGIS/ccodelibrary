//  NSData+Compression.h
//  CCodeLibrary

@import Foundation;
@import Compression;

@interface NSData (Compression)

+ (NSData *)compressFileAtPath:(NSString *)filePath;

@end