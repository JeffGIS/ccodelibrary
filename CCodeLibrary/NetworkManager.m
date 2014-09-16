//  NetworkManager.m
//  CCodeLibrary

#import "NetworkManager.h"

@interface NetworkManager ()

@property (nonatomic, assign, readwrite) NSUInteger networkOperationCount;

@end

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static NetworkManager *_sharedInstance;

    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NetworkManager alloc] init];
    });
    
    return _sharedInstance;
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *result;
    NSString *trimmedStr;
    NSRange schemeMarkerRange;
    NSString *scheme;
    
    assert(str);
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if ((trimmedStr) && (trimmedStr.length != 0))
    {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound)
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        
        else
        {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme);
            
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
    
    assert(url);
    extension = url.pathExtension;
    result = NO;
    
    if (extension)
    {
        result = ([extension caseInsensitiveCompare:@"bin"] == NSOrderedSame)
        || ([extension caseInsensitiveCompare:@"gcf"] == NSOrderedSame);
    }
    
    return result;
}


- (BOOL)isImageURL:(NSURL *)url
{
    BOOL result;
    NSString *extension;
    
    assert(url);
    extension = url.pathExtension;
    result = NO;
    
    if (extension)
    {
        result = ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame)
              || ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame)
              || ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame);
    }
    
    return result;
}

- (NSString *)pathForTestImage:(NSUInteger)imageNumber
{
    NSUInteger power, expansionFactor;
    NSString *originalFilePath, *bigFilePath;
    NSFileManager *fileManager;
    NSDictionary *attrs;
    unsigned long long originalFileSize, bigFileSize;
    
    assert((imageNumber >= 1) && (imageNumber <= 4));
    power = imageNumber - 1;
    
    #if TARGET_IPHONE_SIMULATOR
        power += 1;
    #endif
    
    expansionFactor = (NSUInteger)pow(10, power);

    fileManager = NSFileManager.defaultManager;
    assert(fileManager);
    
    originalFilePath = [NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"TestImage%zu", (size_t) imageNumber]
                                                     ofType:@"png"];
    
    assert(originalFilePath);
    
    bigFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"TestImage%zu.png", (size_t) imageNumber]];
    assert(bigFilePath);
    
    attrs = [fileManager attributesOfItemAtPath:originalFilePath
                                          error:NULL];
    
    assert(attrs);
    
    originalFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];

    attrs = [fileManager attributesOfItemAtPath:bigFilePath
                                          error:NULL];
    
    if (!attrs)
        bigFileSize = 0;
    
    else
        bigFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    
    if (bigFileSize != (originalFileSize *expansionFactor))
    {
        NSOutputStream *bigFileStream;
        NSData *data;
        const uint8_t *dataBuffer;
        NSUInteger dataLength, dataOffset, counter;

        NSLog(@"%5zu - %@", (size_t) expansionFactor, bigFilePath);

        data = [NSData dataWithContentsOfMappedFile:originalFilePath];
        assert(data);
        
        dataBuffer = data.bytes;
        dataLength = data.length;
        
        bigFileStream = [NSOutputStream outputStreamToFileAtPath:bigFilePath
                                                          append:NO];
        
        assert(bigFileStream);
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
                dataOffset += (NSUInteger)bytesWritten;
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
    assert(uuid);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)didStartNetworkOperation
{
    self.networkOperationCount += 1;
}

- (void)didStopNetworkOperation
{
    self.networkOperationCount -= 1;
}

@end