//  NSData+Compression.m
//  CCodeLibrary

#import "NSData+Compression.h"

@implementation NSData (Compression)

+ (NSData *)compressFileAtPath:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    const void *sourceBuffer = data.bytes;
    NSUInteger sourceBufferSize = data.length;
    
    void *destinationBuffer = malloc(sourceBufferSize);
    
    size_t status = compression_encode_buffer(destinationBuffer, sourceBufferSize,
                                              sourceBuffer, sourceBufferSize, nil, COMPRESSION_LZFSE);
    
    if (!status)
    {
        NSLog(@"Compression ERROR");
        return nil;
    }
    
    else
        
    {
        NSLog(@"Original size:%lu, Compressed size:%zu", (unsigned long)sourceBufferSize, status);
        
        return [NSData dataWithBytesNoCopy:destinationBuffer
                                    length:status
                              freeWhenDone:YES];
    }
}

@end