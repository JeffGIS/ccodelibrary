//  FTPDataPull.m
//  PedRampInv_Prelim

#import "FTPDataPull.h"
#import "Reachability.h"

@interface FTPDataPull ()

@property (nonatomic) Reachability *reachability;
@property (nonatomic) unsigned long long existingFileSize;
@property (nonatomic) NSInteger refreshOption;

@end

@implementation FTPDataPull

+ (FTPDataPull *)pull
{
    FTPDataPull *pull = [[FTPDataPull alloc] init];
    pull.haveCalledDelegate = NO;
    return pull;
}

- (int)getFile:(NSString *)fileName
 fromDirectory:(NSString *)fromDirectory
        toFile:(NSString *)toFileName
   toDirectory:(NSString *)toDirectory
 refreshOption:(NSInteger)refreshOption

{
    int rtn = FTPStatusOK;
    
    _toDirectory = toDirectory;
    _refreshOption = refreshOption;
    
    _createDirectory = NO;
    
    if (_createDirectory)
    {
        [NSFileManager.defaultManager createDirectoryAtPath:_toDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
    }
    
    _directory = fromDirectory;
    _fileName = fileName;
    _toFileName = toFileName;
    _filePath = [NSString stringWithFormat:@"%@/%@", _toDirectory, _toFileName];
    assert(_filePath);
    
    _existingFileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_filePath
                                                                       error:nil].fileSize;
    
    if (_refreshOption == FTPDataPullRefreshOptionOverwriteFile ||
        _refreshOption == FTPDataPullRefreshOptionCheckFileSize)
    {
        _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus remoteHostStatus = _reachability.currentReachabilityStatus;
        
        if(remoteHostStatus == NotReachable)
        {
            if (_delegate && !_haveCalledDelegate)
            {
                [_delegate FTPdidComplete:_option
                               withStatus:FTPStatusConnectionFailed
                                 filePath:nil];
                
                _haveCalledDelegate = YES;
            }
            
            return FTPStatusConnectionFailed;
        }
        
        [self startReceive:fileName];
    }
    
    else if (_refreshOption == FTPDataPullRefreshOptionUseFileIfExists)
        rtn = FTPStatusFileExists;
    
    /*else if (_delegate && !_haveCalledDelegate)
    {
        [_delegate FTPdidComplete:_option
                       withStatus:FTPStatusOK
                         filePath:_filePath];
        
        _haveCalledDelegate = YES;
    }*/
    
    return rtn;
}

- (void)receiveDidStart
{
    NSLog(@"Attempting to PULL %@ from %@/%@", _fileName, _currentFtp, _directory);
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

- (void)receiveDidStopWithStatus:(int)status
                    statusString:(NSString *)statusString
{
    
    if (!statusString)
    {
        assert(_filePath);
        status = 1;
    }

    [NetworkManager.sharedInstance didStopNetworkOperation];
    
    if (_delegate && !_haveCalledDelegate)
    {
        [_delegate FTPdidComplete:_option
                       withStatus:status
                         filePath:_filePath];
        
        _haveCalledDelegate = YES;
    }
}

- (BOOL)isReceiving
{
    if (_connection)
        return YES;
    
    else
        return NO;
}

- (void)startReceive:(NSString *)fileName
{
    if (!_hasFailed)
    {
        _fileName = fileName;
        [self setUpFTP];
    }
    
    assert(!_connection);
    assert(!_fileStream);
    
    NSURL *url = [NetworkManager.sharedInstance smartURLForString:_urlText];
    
    if (!url)
    {
        if (!_hasFailed)
        {
            if (_currentFtp == _ftpSite)
            {
                [self setToFtpSite2];
                _currentFtp = _ftpSite2;
            }
            
            else
            {
                [self setToFtpSite1];
                _currentFtp = _ftpSite;
            }
            
            url = [NetworkManager.sharedInstance smartURLForString:_urlText];
        }
        
        if (!url)
            return;
    }
    
    _fileStream = [NSOutputStream outputStreamToFileAtPath:_filePath
                                                    append:NO];
    
    assert(_fileStream);
    
    [_fileStream setProperty:@"YES"
                      forKey:(id)kCFStreamPropertyFTPFetchResourceInfo];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    assert(request);
    
    int itimeout = request.timeoutInterval;
    [request setTimeoutInterval:(itimeout / 2)];
    
    _connection = [NSURLConnection connectionWithRequest:request
                                                delegate:self];
    
    assert(_connection);
    _totalDataReceived = 0;
    _progress = 0.0;
    
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(int)status
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
    
    _filePath = nil;
}

- (void)connection:(NSURLConnection *)theConnection
didReceiveResponse:(NSURLResponse *)response
{
#pragma unused(theConnection)
#pragma unused(response)
    
    assert(theConnection == _connection);
    assert(response);
    
    _fileSize = (int)response.expectedContentLength;
    
    if (_fileSize == _existingFileSize &&
        _refreshOption == FTPDataPullRefreshOptionCheckFileSize)
    {
        [self stopReceiveWithStatus:FTPStatusFileExists
                       statusString:@"File Already Exists"];
    }
    
    else
        [_fileStream open];
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)data
{
#pragma unused(theConnection)
    NSUInteger dataLength;
    const uint8_t *dataBytes;
    NSInteger bytesWritten;
    NSUInteger bytesWrittenSoFar;
    
    assert(theConnection == _connection);
    
    dataLength = data.length;
    dataBytes = data.bytes;
    bytesWrittenSoFar = 0;
    
    _totalDataReceived += dataLength;
    _progress = ((CGFloat)_totalDataReceived / (CGFloat)_fileSize);
    
    if (_popover)
        [_popover updateProgress:_progress];
    
    do
    {
        bytesWritten = [_fileStream write:&dataBytes[bytesWrittenSoFar]
                                    maxLength:(dataLength - bytesWrittenSoFar)];
        
        assert(bytesWritten != 0);
        
        if (bytesWritten <= 0)
        {
            [self stopReceiveWithStatus:FTPStatusFileWriteError
                           statusString:@"File write error"];
            break;
        }
        
        else
            bytesWrittenSoFar += (NSUInteger)bytesWritten;
    }
    
    while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection
  didFailWithError:(NSError *)error
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == _connection);
    
    NSLog(@"NSURLConnection Error %li:%@", (long)error.code, error.localizedDescription);
    
    if (!_hasFailed && !_useOnlyPrimaryFTP)
    {
        if ([_currentFtp isEqualToString:_ftpSite])
        {
            [self setToFtpSite2];
            _currentFtp = _ftpSite2;
            
            [UserDefaults.defaults saveString:_currentFtp
                                       forKey:@"CurrentFtp"];
            
            _hasFailed = YES;
            
            [self stopReceiveWithStatus:FTPStatusConnectionFailedTryingSecondary
                           statusString:error.localizedDescription];
            
            _haveCalledDelegate = NO;
            
            [self getFile:_fileName
            fromDirectory:_directory
                   toFile:_fileName
              toDirectory:_toDirectory
            refreshOption:FTPDataPullRefreshOptionCheckFileSize];
        }
        
        else
        {
            [self setToFtpSite1];
            _currentFtp = _ftpSite;
            
            [UserDefaults.defaults saveString:_currentFtp
                                       forKey:@"CurrentFtp"];
            
            _hasFailed = YES;
            
            [self stopReceiveWithStatus:FTPStatusConnectionFailed
                           statusString:error.localizedDescription];
            
            [self getFile:_fileName
            fromDirectory:_directory
                   toFile:_fileName
              toDirectory:_toDirectory
            refreshOption:FTPDataPullRefreshOptionCheckFileSize];
        }
    }
    
    else
    {
        //remove file to ensure partially transferred files are not used
        [NSFileManager.defaultManager removeItemAtPath:_filePath
                                                 error:nil];

        [self stopReceiveWithStatus:FTPStatusConnectionFailed
                       statusString:error.localizedDescription];
        
        _currentFtp = [UserDefaults.defaults stringForKey:@"DefaultFtp"];
        
        [UserDefaults.defaults saveString:_currentFtp
                                   forKey:@"CurrentFtp"];
        
        _hasFailed = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
#pragma unused(theConnection)
    assert(theConnection == _connection);
    
    [self stopReceiveWithStatus:FTPStatusOK
                   statusString:@""];
}

- (void)setUpFTP
{
    if (_ftpSiteOveride)
    {
        _ftpSite = _ftpSiteOveride;
        _username = _usernameOveride;
        _password = _passwordOveride;
        _port = _portOveride;
    }
    
    else
    {
        _ftpSite = @"gssidata.com";
        _username = @"GSSiData";
        _password = @"GSSi";
        _port = @"14147";
    }
    
    _ftpSite2 = @"thmgis.com";
    _username2 = @"waypoint";
    _password2 = @"pointway4*";
    
    _currentFtp = [UserDefaults.defaults stringForKey:@"CurrentFtp"];
    
    if (_currentFtp == _ftpSite2)
        [self setToFtpSite2];
    
    else
        [self setToFtpSite1];
}

- (void)setToFtpSite1
{
    _urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@/%@",
                _username, _password, _ftpSite, _port, _directory, _fileName];
}

- (void)setToFtpSite2
{
    _urlText = [NSString stringWithFormat:@"%@:%@@%@/%@/%@",
                _username2, _password2, _ftpSite2, _directory, _fileName];
}

- (void)dealloc
{
    NSLog(@"FTPDataPull dealloc");
    
    [self stopReceiveWithStatus:FTPStatusStop
                   statusString:@"Stopped"];
}

@end