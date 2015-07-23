//  FTPDirectoryList.m
//  CCodeLibrary

#import "FTPDirectoryList.h"
#import "Reachability.h"

@interface FTPDirectoryList ()

@property (nonatomic) Reachability *reachability;
@property (nonatomic, copy) NSString *directory, *username, *password, *port, *ftpDomain, *urlText;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSOutputStream *fileStream;

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
    
    NSURL *url = [NetworkManager.sharedInstance smartURLForString:_urlText];
    
    assert(url);
    
    _fileStream = NSOutputStream.outputStreamToMemory;
    
    assert(_fileStream);
    
    [_fileStream setProperty:@"YES"
                      forKey:(id)kCFStreamPropertyFTPFetchResourceInfo];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    assert(request);
    
    int itimeout = request.timeoutInterval;
    [request setTimeoutInterval:(itimeout * 1)];
    
    _connection = [NSURLConnection connectionWithRequest:request
                                                delegate:self];
    
    assert(_connection);
    
    [self receiveDidStart];
}

- (void)receiveDidStart
{
    NSLog(@"Attempting to GET DIR LIST from %@", _urlText);
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

- (void)connection:(NSURLConnection *)theConnection
didReceiveResponse:(NSURLResponse *)response
{
    assert(theConnection == _connection);
    assert(response);
    
   [_fileStream open];
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)data
{
    assert(theConnection == _connection);
    
    if (data && _delegate)
    {
        [_delegate FTPDirectoryListDidCompleteWithStatus:FTPStatusOK
                                            statusString:@"Directory List Successful"
                                           directoryList:data];
    }
}

@end