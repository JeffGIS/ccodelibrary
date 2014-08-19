#import "NetworkManager.h"

@interface NetworkManager ()

@property (nonatomic, assign, readwrite) NSUInteger networkOperationCount;

@end

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static NetworkManager *sSharedInstance;

    dispatch_once(&onceToken, ^{
        sSharedInstance = [[NetworkManager alloc] init];
    });
    return sSharedInstance;
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *result;
    NSString *trimmedStr;
    NSRange schemeMarkerRange;
    NSString *scheme;
    
    assert(str != nil);

    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if ( (trimmedStr != nil) && ([trimmedStr length] != 0) )
    {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound)
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        
        else
        {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if (([scheme compare:@"ftp"
                         options:NSCaseInsensitiveSearch] == NSOrderedSame))
            {
                result = [NSURL URLWithString:trimmedStr];
            }
        }
    }
    
    return result;
}

- (BOOL)isBinaryURL:(NSURL *)url
{
    BOOL result;
    NSString *extension;
    
    assert(url != nil);
    
    extension = url.pathExtension;
    result = NO;
    if (extension != nil)
    {
        result = ([extension caseInsensitiveCompare:@"bin"] == NSOrderedSame);
    }
    
    return result;
}


- (BOOL)isImageURL:(NSURL *)url
{
    BOOL result;
    NSString *extension;
    
    assert(url != nil);
    
    extension = url.pathExtension;
    result = NO;
    if (extension != nil)
    {
        result = ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame)
              || ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame)
              || ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame);
    }
    
    return result;
}

- (NSString *)pathForTestImage:(NSUInteger)imageNumber
{
    NSUInteger power;
    NSUInteger expansionFactor;
    NSString *originalFilePath;
    NSString *bigFilePath;
    NSFileManager *fileManager;
    NSDictionary *attrs;
    unsigned long long originalFileSize;
    unsigned long long bigFileSize;
    
    assert( (imageNumber >= 1) && (imageNumber <= 4) );
    
    power = imageNumber - 1;
    #if TARGET_IPHONE_SIMULATOR
        power += 1;
    #endif
    expansionFactor = (NSUInteger) pow(10, power);

    fileManager = NSFileManager.defaultManager;
    assert(fileManager != nil);
    
    originalFilePath = [NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"TestImage%zu", (size_t) imageNumber]
                                                     ofType:@"png"];
    
    assert(originalFilePath != nil);
    
    bigFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"TestImage%zu.png", (size_t) imageNumber]];
    assert(bigFilePath != nil);
    
    attrs = [fileManager attributesOfItemAtPath:originalFilePath
                                          error:NULL];
    
    assert(attrs != nil);
    
    originalFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];

    attrs = [fileManager attributesOfItemAtPath:bigFilePath
                                          error:NULL];
    
    if (attrs == NULL)
        bigFileSize = 0;
    
    else
        bigFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    
    if (bigFileSize != (originalFileSize *expansionFactor))
    {
        NSOutputStream *bigFileStream;
        NSData *data;
        const uint8_t *dataBuffer;
        NSUInteger dataLength;
        NSUInteger dataOffset;
        NSUInteger counter;

        NSLog(@"%5zu - %@", (size_t) expansionFactor, bigFilePath);

        data = [NSData dataWithContentsOfMappedFile:originalFilePath];
        assert(data != nil);
        
        dataBuffer = data.bytes;
        dataLength = data.length;
        
        bigFileStream = [NSOutputStream outputStreamToFileAtPath:bigFilePath
                                                          append:NO];
        
        assert(bigFileStream != NULL);
        
        [bigFileStream open];
        
        for (counter = 0; counter < expansionFactor; counter++)
        {
            dataOffset = 0;
            while (dataOffset != dataLength)
            {
                NSInteger bytesWritten;
                
                bytesWritten = [bigFileStream write:&dataBuffer[dataOffset]
                                          maxLength:dataLength - dataOffset];
                
                assert(bytesWritten > 0);
                
                dataOffset += (NSUInteger) bytesWritten;
            }
        }

        [bigFileStream close];
    }
    
    return bigFilePath;
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)didStartNetworkOperation
{
    assert(NSThread.isMainThread);
    self.networkOperationCount += 1;
}

- (void)didStopNetworkOperation
{
    assert(NSThread.isMainThread);
    assert(self.networkOperationCount > 0);
    
    self.networkOperationCount -= 1;
}

@end