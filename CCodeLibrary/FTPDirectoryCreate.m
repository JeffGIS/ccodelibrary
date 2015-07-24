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
@property (nonatomic) NSArray *directories;
@property NSInteger directoryCount;

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
    
    ftpDirCreate.directories = directories;
    ftpDirCreate.ftpDomain = ftpDomain;
    ftpDirCreate.directory = directory;
    ftpDirCreate.username = username;
    ftpDirCreate.password = password;
    ftpDirCreate.port = port;
    ftpDirCreate.delegate = delegate;
    ftpDirCreate.directoryCount = 0;
    
    if ([ftpDirCreate reachabilityStatus] == NotReachable)
    {
        if (ftpDirCreate.delegate)
        {
            [ftpDirCreate.delegate FTPDirectoryCreateDidCompleteWithStatus:FTPStatusConnectionFailed
                                                              statusString:@"Cannot Reach Server"
                                                                 directory:directory];
        }
    }
    
    else if (ftpDirCreate.directories.count)
    {
        NSString *currentDir = ftpDirCreate.directories[ftpDirCreate.directoryCount];
        [ftpDirCreate startSendDirectory:currentDir];
    }
    
    return ftpDirCreate;
}

- (NetworkStatus)reachabilityStatus
{
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus reachabilityStatus = _reachability.currentReachabilityStatus;
    
    return reachabilityStatus;
}

- (void)startSendDirectory:(NSString *)currentDir
{
    assert(!_fileStream);
    assert(currentDir);
    
    if (_port && ![_port isEqualToString:@""])
        _urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@/%@/", _username, _password, _ftpDomain, _port, _directory, currentDir];
    
    else
        _urlText = [NSString stringWithFormat:@"%@:%@@%@/%@/%@/", _username, _password, _ftpDomain, _directory, currentDir];
    
    NSURL *url = [NetworkManager.sharedInstance smartURLForString:_urlText];
    
    assert(url);
    
    _fileStream = [NSInputStream inputStreamWithFileAtPath:currentDir];
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
    
    [self sendDidStartDirectory:currentDir];
}

- (void)sendDidStartDirectory:(NSString *)currentDir
{
    NSLog(@"Attempting to CREATE %@ in %@/%@", currentDir, _ftpDomain, _directory);
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

- (void)stream:(NSStream *)aStream
   handleEvent:(NSStreamEvent)eventCode
{
    assert(aStream == _networkStream);
    
    switch (eventCode)
    {
        case NSStreamEventNone:
            break;
        
        case NSStreamEventOpenCompleted:
            break;
            
        case NSStreamEventHasBytesAvailable:
            break;
            
        case NSStreamEventHasSpaceAvailable:
            break;
            
        case NSStreamEventErrorOccurred:
            [self stopSendWithStatus:FTPStatusConnectionFailed
                        statusString:aStream.streamError.localizedDescription];
            break;
        
        case NSStreamEventEndEncountered:
            [self stopSendWithStatus:FTPStatusOK
                        statusString:aStream.streamError.localizedDescription];
            break;
    }
}

- (void)stopSendWithStatus:(int)status
              statusString:(NSString *)statusString
{
    if (_networkStream)
    {
        [_networkStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                  forMode:NSDefaultRunLoopMode];
        
        _networkStream.delegate = nil;
        [_networkStream close];
        _networkStream = nil;
    }
    
    if (_fileStream)
    {
        [_fileStream close];
        _fileStream = nil;
    }
    
    [self sendDidStopWithStatus:status
                   statusString:statusString];
}

- (void)sendDidStopWithStatus:(int)status
                 statusString:(NSString *)statusString
{
    
    if (!statusString)
        status = FTPStatusStop;
    
    [NetworkManager.sharedInstance didStopNetworkOperation];
    
    _directoryCount++;
    
    if (_directoryCount >= _directories.count)
    {
        if (_delegate)
        {
            [_delegate FTPDirectoryCreateDidCompleteWithStatus:status
                                                  statusString:statusString
                                                     directory:_directory];
        }
    }
    
    else
        [self startSendDirectory:_directories[_directoryCount]];
}

@end