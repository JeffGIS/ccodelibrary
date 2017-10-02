//  FTPDataPull.m
//  PedRampInv_Prelim

#import "FTPDataPull.h"
#import "Reachability.h"
#import "CRAPI.h"

@interface FTPDataPull ()

@property (nonatomic) Reachability *reachability;
@property (nonatomic) unsigned long long existingFileSize;
@property (nonatomic) FTPDataPullRefreshOption refreshOption;
@property id <GSSiPopoverViewDelegate> savePopoverDelegate;
@property (nonatomic, copy) NSString *tempExtension;
//@property BOOL useOnlyPrimaryFTP;

@end

static FTPDataPull * _statpull = nil;

@implementation FTPDataPull

+ (FTPDataPull *)pull
{
    if (!_statpull)
        _statpull = [[FTPDataPull alloc] init];

    return _statpull;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        //_haveCalledDelegate = NO;
        //_useTestServer = NO;
        _tempExtension = @".download";
        //_useOnlyPrimaryFTP = YES;
    }
    
    return self;
}

- (int)getFile:(NSString *)fileName
 fromDirectory:(NSString *)fromDirectory
        toFile:(NSString *)toFileName
   toDirectory:(NSString *)toDirectory
 refreshOption:(FTPDataPullRefreshOption)refreshOption

{
    int rtn = FTPStatusOK;
    
    if (_connection)
        return FTPStatusBusy;
    
    if ([toDirectory characterAtIndex:toDirectory.length-1] == '/')
        _toDirectory = [toDirectory substringToIndex:toDirectory.length-1];
    
    else
        _toDirectory = toDirectory;
    
    _refreshOption = refreshOption;
    
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
    //_haveCalledDelegate = NO;
    assert(_filePath);
    
    _existingFileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_filePath
                                                                       error:nil].fileSize;
    
    if (!_existingFileSize || _refreshOption == FTPDataPullRefreshOptionOverwriteFile ||
        _refreshOption == FTPDataPullRefreshOptionCheckFileSize)
    {
        _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
        NetworkStatus remoteHostStatus = _reachability.currentReachabilityStatus;
        
        if (remoteHostStatus == NotReachable)
        {
            if (_delegate /*&& !_haveCalledDelegate*/)
            {
                [_delegate FTPdidComplete:_dataType
                               withStatus:FTPStatusConnectionFailed
                          andStatusString:@"Cannot reach server"
                                 filePath:_filePath];
                
                //_haveCalledDelegate = YES;
            }
            
            return FTPStatusConnectionFailed;
        }
        
        [self startReceive:fileName];
        
        if (_popover)
        {
            _savePopoverDelegate = _popover.delegate;
            _popover.delegate = self;
        }
    }
    
    else if (_refreshOption == FTPDataPullRefreshOptionUseFileIfExists)
    {
        rtn = FTPStatusFileExists;
        [_popover hide];
        
        if (_delegate /*&& !_haveCalledDelegate*/)
        {
            [_delegate FTPdidComplete:_dataType
                           withStatus:FTPStatusOK
                      andStatusString:@"File exists"
                             filePath:_filePath];
            
            //_haveCalledDelegate = YES;
        }
    }
    
    return rtn;
}

- (void)receiveDidStart
{
    NSLog(@"Attempting to PULL %@ from %@/%@", _fileName, [CRAPI.sharedInstance getNVCRISServer], _directory);
}

- (void)receiveDidStopWithStatus:(FTPStatus)status
                    statusString:(NSString *)statusString
{
    
    if (!statusString)
    {
        assert(_filePath);
        status = 1;
    }
    
    if (_delegate /*&& !_haveCalledDelegate*/)
    {
        [_delegate FTPdidComplete:_dataType
                       withStatus:status
                  andStatusString:statusString
                         filePath:_filePath];
        
        //_haveCalledDelegate = YES;
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
        _filePath = [NSString stringWithFormat:@"%@%@", _filePath, _tempExtension];
        _fileName = fileName;
        [self setUpFTP];
    }
    
    assert(!_connection);
    assert(!_fileStream);
    
    NSURL *url = [CRAPI.sharedInstance smartURLForString:_urlText];
    
    if (!url)
    {
            [self stopReceiveWithStatus:FTPStatusCancel
                           statusString:[NSString stringWithFormat:@"%@ is not a valid URL", url]];
            
            return;
     }
    
    _fileStream = [NSOutputStream outputStreamToFileAtPath:_filePath
                                                    append:NO];
    
    assert(_fileStream);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    assert(request);
    
    _connection = [NSURLConnection connectionWithRequest:request
                                                delegate:self];
    assert(_connection);

    _totalDataReceived = 0;
    _progress = 0.0;
    
    if (_popover)
        [_popover updateProgress:_progress];
    
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(int)status
                 statusString:(NSString *)statusString
{
    if (_popover)
        _popover.delegate = _savePopoverDelegate;
    
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
    
    NSLog(@"FileSizeOnDevice:%llu,FileSizeOnFTP:%llu", _existingFileSize, _fileSize);
    
    if (_fileSize == _existingFileSize &&
        _refreshOption == FTPDataPullRefreshOptionCheckFileSize)
    {
        if ([_filePath containsString:_tempExtension])
        {
            _filePath = _filePath.stringByDeletingPathExtension;
        }

        [self stopReceiveWithStatus:FTPStatusFileExists
                       statusString:@"File Already Exists"];
    }
    
    else
    {
        [_fileStream open];
        
        if (_fileStream.streamStatus == NSStreamStatusError)
        {
            NSLog(@"StreamStatus:%lu", (unsigned long)_fileStream.streamStatus);
            
            [self stopReceiveWithStatus:FTPStatusFileWriteError
                           statusString:_fileStream.streamError.localizedDescription];
        }
    }
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
    
        //remove file to ensure partially transferred files are not used
        [NSFileManager.defaultManager removeItemAtPath:_filePath
                                                 error:nil];

        [self stopReceiveWithStatus:FTPStatusConnectionFailed
                       statusString:error.localizedDescription];
        
    
        _hasFailed = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
#pragma unused(theConnection)
    assert(theConnection == _connection);
    
    if ([_filePath containsString:_tempExtension])
    {
        NSString *newFilePath = _filePath.stringByDeletingPathExtension;
        NSError *error = nil;
        
        BOOL st = [NSFileManager.defaultManager removeItemAtPath:newFilePath
                                                           error:nil];
       
        [NSFileManager.defaultManager moveItemAtPath:_filePath
                                              toPath:newFilePath
                                               error:&error];
        
        if (error)
            NSLog(@"ERROR renaming file:%@", _fileName);
        
        else
            _filePath = newFilePath;
    }
    
    else
        NSLog (@"No Extension");
    
    [self stopReceiveWithStatus:FTPStatusOK
                   statusString:@""];
}

- (void)setUpFTP
{
    if (_ftpSiteOveride)
    {
        //_useOnlyPrimaryFTP = YES;
        //_ftpSite = _currentFtp = _ftpSiteOveride;
        _username = _usernameOveride;
        _password = _passwordOveride;
        _port = _portOveride;
    }
    
    else
    {
        /*if (_useTestServer)
        {
        }
        
        else*/
        {
            _username = @"GSSiProfessionalServer";
            _password = @"GSSi";
            
            /*_ftpSite = @"192.168.254.39";
             _username = @"GSSiLocal";
             _password = @"GSSi";*/
         }
        
        _port = @"21";
        [self setToFtpSite1];
    }
}

- (void)setToFtpSite1
{
    _urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@/%@",
                _username, _password, [CRAPI.sharedInstance getNVCRISServer], _port, _directory, _fileName];
}

- (void)setToFtpSite2
{
    _urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@/%@",
                _username2, _password2, [CRAPI.sharedInstance getNVCRISServer], _port, _directory, _fileName];
}

- (void)dealloc
{
    NSLog(@"FTPDataPull dealloc");
    
    [self stopReceiveWithStatus:FTPStatusStop
                   statusString:@"Stopped"];
    _statpull = nil;
}

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView
{
    [self stopReceiveWithStatus:FTPStatusUserCancel
                   statusString:@"Canceled by User"];

}

@end
