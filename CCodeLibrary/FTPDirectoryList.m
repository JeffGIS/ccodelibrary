//  FTPDirectoryList.m
//  CCodeLibrary

#import "FTPDirectoryList.h"
#import "Reachability.h"
#import "CRAPI.h"

@interface FTPDirectoryList ()

@property (nonatomic) Reachability *reachability;
@property (nonatomic, copy) NSString *directory, *username, *password, *port, *ftpDomain, *urlText;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSOutputStream *fileStream;
@property (nonatomic) NSMutableData *mutableData;

@end

@implementation FTPDirectoryList

+ (FTPDirectoryList *)getListingFromFTPDomain:(NSString *)ftpDomain
                                    directory:(NSString *)directory
                                     username:(NSString *)username
                                     password:(NSString *)password
                                         port:(NSString *)port
                                     delegate:(id)delegate;
{
    FTPDirectoryList *ftpDirList = [[FTPDirectoryList alloc] init];
    
    ftpDirList.ftpDomain = ftpDomain;
    ftpDirList.directory = directory;
    ftpDirList.username = username;
    ftpDirList.password = password;
    ftpDirList.port = port;
    ftpDirList.delegate = delegate;
    
    if ([ftpDirList reachabilityStatus] == NotReachable)
    {
        if (ftpDirList.delegate)
        {
            [ftpDirList.delegate FTPDirectoryListDidCompleteWithStatus:FTPStatusConnectionFailed
                                                          statusString:@"Cannot Reach Server"
                                                         directoryList:nil];
        }
    }
    
    else
        [ftpDirList startReceive];
    
    return ftpDirList;
}

- (NetworkStatus)reachabilityStatus
{
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus reachabilityStatus = _reachability.currentReachabilityStatus;
    
    return reachabilityStatus;
}

- (void)startReceive
{
    assert(!_connection);
    assert(!_fileStream);
    
    if (_port && ![_port isEqualToString:@""])
        _urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@", _username, _password, _ftpDomain, _port, _directory];
    
    else
        _urlText = [NSString stringWithFormat:@"%@:%@@%@/%@", _username, _password, _ftpDomain, _directory];
    
    NSURL *url = [CRAPI.sharedInstance smartURLForString:_urlText];
    
    assert(url);
    
    _fileStream = NSOutputStream.outputStreamToMemory;
    
    assert(_fileStream);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    assert(request);
    
    _connection = [NSURLConnection connectionWithRequest:request
                                                delegate:self];
    
    assert(_connection);
    
    [self receiveDidStart];
}

- (void)receiveDidStart
{
    NSLog(@"Attempting to GET DIR LIST from %@", _urlText);
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    assert(connection == _connection);
    
    NSLog(@"NSURLConnection Error %li:%@", (long)error.code, error.localizedDescription);
    
    [self stopReceiveWithStatus:FTPStatusConnectionFailed
                   statusString:error.localizedDescription];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    assert(connection == _connection);
    
    if (_mutableData && _delegate)
    {
        [_delegate FTPDirectoryListDidCompleteWithStatus:FTPStatusOK
                                            statusString:@"Directory List Successful"
                                           directoryList:_mutableData];
    }
    
    [self stopReceiveWithStatus:FTPStatusOK
                   statusString:@"NSURL Did Finish Loading"];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    assert(connection == _connection);
    assert(response);
    
    _mutableData = [[NSMutableData alloc] init];
    
    [_fileStream open];
    
    if (_fileStream.streamStatus == NSStreamStatusError)
    {
        NSLog(@"StreamStatus:%lu", (unsigned long)_fileStream.streamStatus);
        
        [self stopReceiveWithStatus:FTPStatusFileWriteError
                       statusString:_fileStream.streamError.localizedDescription];
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    assert(connection == _connection);
    
    [_mutableData appendData:data];
}

- (void)stopReceiveWithStatus:(FTPStatus)status
                 statusString:(NSString *)statusString
{
    if (_connection)
    {
        [_connection cancel];
        _connection = nil;
    }
    
    if (_fileStream)
    {
        [_fileStream close];
        _fileStream = nil;
    }
    
    [self receiveDidStopWithStatus:status
                      statusString:statusString];
}

- (void)receiveDidStopWithStatus:(FTPStatus)status
                    statusString:(NSString *)statusString
{
    
    if (!statusString)
        status = 1;
    
    if (_delegate)
    {
        [_delegate FTPDirectoryListDidCompleteWithStatus:status
                                            statusString:statusString
                                           directoryList:nil];
        
    }
}

- (BOOL)isReceiving
{
    if (_connection)
        return YES;
    
    else
        return NO;
}

@end