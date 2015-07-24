//  FTPDirectoryCreate.m
//  CCodeLibrary

#import "FTPDirectoryCreate.h"
#import "NetworkManager.h"
#import "Reachability.h"

@interface FTPDirectoryCreate ()

@property (nonatomic) Reachability *reachability;
@property (nonatomic, copy) NSString *directory, *username, *password, *port, *ftpDomain, *urlText;
@property (nonatomic) NSOutputStream *networkStream;
@property (nonatomic) NSInputStream *fileStream;

@end

@implementation FTPDirectoryCreate

+ (FTPDirectoryCreate *)createDirectories:(NSArray *)directories
                              inFTPDomain:(NSString *)ftpDomain
                                directory:(NSString *)directory
                                 username:(NSString *)username
                                 password:(NSString *)password
                                     port:(NSString *)port
                                 delegate:(id)delegate
{
    FTPDirectoryCreate *ftpDirCreate = [[FTPDirectoryCreate alloc] init];
    
    ftpDirCreate.ftpDomain = ftpDomain;
    ftpDirCreate.directory = directory;
    ftpDirCreate.username = username;
    ftpDirCreate.password = password;
    ftpDirCreate.port = port;
    ftpDirCreate.delegate = delegate;
    
    if ([ftpDirCreate reachabilityStatus] == NotReachable)
    {
        if (ftpDirCreate.delegate)
        {
            [ftpDirCreate.delegate FTPDirectoryCreateDidCompleteWithStatus:FTPStatusConnectionFailed
                                                              statusString:@"Cannot Reach Server"
                                                                 directory:directory];
        }
    }
    
    else
        [ftpDirCreate startSend];
    
    return ftpDirCreate;
}

- (NetworkStatus)reachabilityStatus
{
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus reachabilityStatus = _reachability.currentReachabilityStatus;
    
    return reachabilityStatus;
}

- (void)startSend
{
    assert(!_fileStream);
    
    NSURL *url = [NetworkManager.sharedInstance smartURLForString:_urlText];
    
    assert(url);
    
    _fileStream = [NSInputStream inputStreamWithFileAtPath:_directory];
    assert(_fileStream);
    
    [_fileStream open];
    
    CFWriteStreamRef ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    
    assert(ftpStream);
    
    _networkStream = (__bridge NSOutputStream *)ftpStream;
    
    if (_username.length)
    {
        BOOL success = [_networkStream setProperty:_username
                                            forKey:(id)kCFStreamPropertyFTPUserName];
        
        if (!success)
            return;
        
        success = [_networkStream setProperty:_password
                                       forKey:(id)kCFStreamPropertyFTPPassword];
        
        if (!success)
            return;
    }
    
    else
        return;
    
    _networkStream.delegate = self;
    
    [_networkStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                              forMode:NSDefaultRunLoopMode];
    
    [_networkStream open];
    CFRelease(ftpStream);
    
    [self sendDidStart];
}

- (void)sendDidStart
{
    NSLog(@"Attempting to CREATE DIR LIST in %@", _urlText);
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

@end