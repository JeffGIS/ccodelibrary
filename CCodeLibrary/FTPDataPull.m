//  FTPDataPull.m
//  PedRampInv_Prelim

#import "FTPDataPull.h"

@implementation FTPDataPull

+ (FTPDataPull *)pull
{
    return [[FTPDataPull alloc] init];
}

- (void)getFile:(NSString *)fileName
        fromDirectory:(NSString *)fromDirectory
        toDirectory:(NSString *)toDirectory
        forceRefresh:(BOOL)refresh
{
    self.toDirectory = toDirectory;
    self.directory = fromDirectory;
    self.fileName = fileName;
    self.filePath = [NSString stringWithFormat:@"%@/%@", self.toDirectory,self.fileName];
    assert(self.filePath);
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:self.filePath
                                                                                  error:nil].fileSize;
    
    if (refresh || fileSize == 0)
        [self startReceive:fileName];
    
    else if (self.delegate)
    {
        [self.delegate FTPdidComplete:FTP_OK
                             filePath:self.filePath];
    }
}

- (void)receiveDidStart
{
    NSLog (@"Attempting to PULL %@ from %@", self.fileName, self.currentFtp);
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

- (void)receiveDidStopWithStatus:(int)status
                    statusString:(NSString *)statusString
{
    
    if (!statusString)
    {
        assert(self.filePath);
        status = 1;
    }

    [NetworkManager.sharedInstance didStopNetworkOperation];
    
    if (self.delegate)
    {
        [self.delegate FTPdidComplete:status
                             filePath:self.filePath];
    }
}

- (BOOL)isReceiving
{
    return (self.connection != nil);
}

- (void)startReceive:(NSString *)fileName
{
    if (self.hasFailed == NO)
    {
        self.fileName = fileName;
        [self setUpFTP];
    }
    
    BOOL success;
    NSURL *url;
    NSURLRequest *request;
    
    assert(!self.connection);
    assert(!self.fileStream);
    
    url = [NetworkManager.sharedInstance smartURLForString:self.urlText];
    success = (url != nil);
    
    if (!success || ![NetworkManager.sharedInstance isBinaryURL:url])
    {
        if (self.hasFailed == NO)
        {
            if (self.currentFtp == self.ftpSite)
            {
                [self setToFtpSite2];
                self.currentFtp = self.ftpSite2;
            }
            
            else
            {
                [self setToFtpSite1];
                self.currentFtp = self.ftpSite;
            }
            
            url = [NetworkManager.sharedInstance smartURLForString:self.urlText];
            success = (url != nil);
        }
        
        if (!success)
        {
            NSAssert(0, @"ERROR: Invalid URL");
            return;
        }
        
        else if (![NetworkManager.sharedInstance isBinaryURL:url])
        {
            NSAssert(0, @"ERROR: NOT a binary file");
            return;
        }
    }
    
    self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath
                                                        append:NO];
    
    assert(self.fileStream);
    
    [self.fileStream open];
    
    request = [NSURLRequest requestWithURL:url];
    assert(request);
    
    self.connection = [NSURLConnection connectionWithRequest:request
                                                    delegate:self];
    
    assert(self.connection);
    
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(int)status
                 statusString:(NSString *)statusString
{
    if (self.connection != nil)
    {
        [self.connection cancel];
        self.connection = nil;
    }
    
    if (self.fileStream != nil)
    {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    [self receiveDidStopWithStatus:status
                      statusString:statusString];
    
    self.filePath = nil;
}

- (void)connection:(NSURLConnection *)theConnection
didReceiveResponse:(NSURLResponse *)response
{
#pragma unused(theConnection)
#pragma unused(response)
    
    assert(theConnection == self.connection);
    assert(response);
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)data
{
#pragma unused(theConnection)
    NSUInteger dataLength;
    const uint8_t *dataBytes;
    NSInteger bytesWritten;
    NSUInteger bytesWrittenSoFar;
    
    assert(theConnection == self.connection);
    
    dataLength = data.length;
    dataBytes  = data.bytes;
    
    bytesWrittenSoFar = 0;
    
    do
    {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar]
                                    maxLength:dataLength - bytesWrittenSoFar];
        
        assert(bytesWritten != 0);
        
        if (bytesWritten <= 0)
        {
            [self stopReceiveWithStatus:FTP_FILE_WRITE_ERROR
                           statusString:@"File write error"];
            break;
        }
        
        else
            bytesWrittenSoFar += (NSUInteger) bytesWritten;
    }
    
    while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection
  didFailWithError:(NSError *)error
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.connection);
    
    if (self.hasFailed == NO)
    {
        [self stopReceiveWithStatus:FTP_CONNECTION_FAILED
                       statusString:error.localizedDescription];
        
        NSLog (@"ERROR %i:%@", FTP_CONNECTION_FAILED, error.localizedDescription);
        
        if (self.currentFtp == self.ftpSite)
        {
            [self setToFtpSite2];
            self.currentFtp = self.ftpSite2;
            
            [UserDefaults.defaults saveString:self.currentFtp
                                       forKey:@"CurrentFtp"];
            
            self.hasFailed = YES;
            
            [self getFile:self.fileName
            fromDirectory:self.directory
              toDirectory:self.toDirectory
             forceRefresh:NO];
        }
        
        else
        {
            [self setToFtpSite1];
            self.currentFtp = self.ftpSite;
            
            [UserDefaults.defaults saveString:self.currentFtp
                                       forKey:@"CurrentFtp"];
            
            self.hasFailed = YES;
            
            [self getFile:self.fileName
            fromDirectory:self.directory
              toDirectory:self.toDirectory
             forceRefresh:NO];
        }
    }
    
    else
    {
        [self stopReceiveWithStatus:FTP_CONNECTION_FAILED
                       statusString:error.localizedDescription];
        
        NSLog (@"ERROR %i:%@", FTP_CONNECTION_FAILED, error.localizedDescription);
        
        self.currentFtp = [UserDefaults.defaults stringForKey:@"DefaultFtp"];
        
        [UserDefaults.defaults saveString:self.currentFtp
                                   forKey:@"CurrentFtp"];
        
        self.hasFailed = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
#pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self stopReceiveWithStatus:FTP_OK
                   statusString:@""];
}

- (void)setUpFTP
{
    self.ftpSite = @"gssidata.com";
    self.username = @"GSSiData";
    self.password = @"GSSi";
    self.port = @"14147";
    
    self.ftpSite2 = @"thmgis.com";
    self.username2 = @"waypoint";
    self.password2 = @"pointway4*";
    
    self.currentFtp = [UserDefaults.defaults stringForKey:@"CurrentFtp"];
    
    if (self.currentFtp == self.ftpSite2)
        [self setToFtpSite2];
    
    else
        [self setToFtpSite1];
}

- (void)setToFtpSite1
{
    self.urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@/%@", self.username,
                    self.password, self.ftpSite, self.port, self.directory, self.fileName];
}

- (void)setToFtpSite2
{
    self.urlText = [NSString stringWithFormat:@"%@:%@@%@/%@/%@", self.username2,
                    self.password2, self.ftpSite2, self.directory, self.fileName];
}

- (void)dealloc
{
    [self stopReceiveWithStatus:FTP_STOP
                   statusString:@"Stopped"];
}

@end