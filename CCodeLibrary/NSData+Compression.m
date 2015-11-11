//  NSData+Compression.m
//  CCodeLibrary

#import "NSData+Compression.h"

@implementation NSData (Compression)

/*+ (NSData *)compressFileAtPath:(NSString *)filePath
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
        free(destinationBuffer);
        return nil;
    }
    
    else
        
    {
        NSLog(@"Original size:%lu, lzfse size:%zu", (unsigned long)sourceBufferSize, status);
        
        return [NSData dataWithBytesNoCopy:destinationBuffer
                                    length:status
                              freeWhenDone:YES];
    }
}*/

+ (NSData *)lzCompressFileAtPath:(NSString *)filePath
{
    if (lzo_init() != LZO_E_OK)
    {
        NSLog(@"LZO INIT ERROR");
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    lzo_bytep sourceBuffer = (lzo_bytep)data.bytes;
    lzo_uint sourceBufferSize = (lzo_uint)data.length;
    lzo_uint destinationBufferSize = 0;
    
    lzo_bytep destinationBuffer = (lzo_bytep)malloc(sourceBufferSize);
    lzo_bytep wrkmem = (lzo_bytep)malloc(LZO1X_1_MEM_COMPRESS);
    
    if (destinationBuffer == NULL || wrkmem == NULL)
    {
        NSLog(@"LZO MEMORY ERROR");
        free(destinationBuffer);
        free(wrkmem);
        return nil;
    }
    
    int status = lzo1x_1_compress(sourceBuffer, sourceBufferSize, destinationBuffer, &destinationBufferSize, wrkmem);
    
    free(wrkmem);
    
    if (status != LZO_E_OK)
    {
        NSLog(@"LZO COMPRESSION ERROR");
        free(destinationBuffer);
        return nil;
    }
    
    else
        
    {
        NSLog(@"Original size:%zu, minilz size:%lu", sourceBufferSize, (unsigned long)destinationBufferSize);
        
        return [NSData dataWithBytesNoCopy:destinationBuffer
                                    length:(NSUInteger)destinationBufferSize
                              freeWhenDone:YES];
    }
}

- (NSString *)MD5
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    if (CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer))
    {
        NSMutableString *output = [NSMutableString stringWithCapacity:(CC_MD5_DIGEST_LENGTH * 2)];
        
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", (int)md5Buffer[i]];
        
        return output.copy;
    }
    
    else
        return nil;
}

- (NSString *)SHA256
{
    unsigned char sha256Buffer[CC_SHA256_DIGEST_LENGTH];
    
    if (CC_SHA256(self.bytes, (CC_LONG)self.length, sha256Buffer))
    {
        NSMutableString *output = [NSMutableString stringWithCapacity:(CC_SHA256_DIGEST_LENGTH * 2)];
        
        for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", (int)sha256Buffer[i]];
        
        return output.copy;
    }
    
    else
        return nil;
}

@end