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
    
    trimmedStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
    assert(url);
    NSString *extension = url.pathExtension;
    BOOL result = NO;
    
    if (extension)
    {
        result = ([extension caseInsensitiveCompare:@"bin"] == NSOrderedSame) ||
        ([extension caseInsensitiveCompare:@"gcf"] == NSOrderedSame) ||
        ([extension caseInsensitiveCompare:@"txt"] == NSOrderedSame) ||
        ([extension caseInsensitiveCompare:@"sqlite3"] == NSOrderedSame)||
        ([extension caseInsensitiveCompare:@"pdf"] == NSOrderedSame);
    }
    
    return result;
}


- (BOOL)isImageURL:(NSURL *)url
{
    assert(url);
    NSString *extension = url.pathExtension;
    BOOL result = NO;
    
    if (extension)
    {
        result = ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame)
              || ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame)
              || ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame);
    }
    
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