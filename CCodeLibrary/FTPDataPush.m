//  FTPDataPush.m
//  CCodeLibrary

#import "FTPDataPush.h"
#import "Reachability.h"
#import "NetworkManager.h"
#import <CFNetwork/CFNetwork.h>

enum {
    kSendBufferSize = 32768
};

@interface FTPDataPush ()

@property (nonatomic, readonly) BOOL isSending;
@property (nonatomic, retain) NSOutputStream *networkStream;
@property (nonatomic, retain) NSInputStream *fileStream;
@property (nonatomic, readonly) uint8_t *buffer;
@property (nonatomic, assign) size_t bufferOffset;
@property (nonatomic, assign) size_t bufferLimit;

@end

@implementation FTPDataPush
{
    Reachability *_reachability;
    long _fileSize, _totBytesWritten;
    uint8_t _buffer[kSendBufferSize];
    int ii;
}

+ (FTPDataPush *)push
{
    return [[FTPDataPush alloc] init];
}

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)sendFile:(NSString *)fileName
   fromDirectory:(NSString *)fromDirectory
     toDirectory:(NSString *)toDirectory
  deleteWhenDone:(BOOL)delete
{
    BOOL rtn = [self sendFile:fileName
                fromDirectory:fromDirectory
                       toFile:fileName
                  toDirectory:toDirectory
               deleteWhenDone:delete];
    
    return rtn;
}

- (BOOL)sendFile:(NSString *)fileName
   fromDirectory:(NSString *)fromDirectory
          toFile:(NSString *)toFileName
     toDirectory:(NSString *)toDirectory
  deleteWhenDone:(BOOL)delete
{
    
    self.toDirectory = toDirectory;
    self.directory = fromDirectory;
    self.fileName = fileName;
    self.toFileName = toFileName;
    self.filePath = [NSString stringWithFormat:@"%@/%@", self.directory,self.fileName];
    assert(self.filePath);
    
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = _reachability.currentReachabilityStatus;
    
    if(remoteHostStatus == NotReachable)
    {
        if (self.delegate)
        {
            [self.delegate FTPdidComplete:FTP_CONNECTION_FAILED
                                 filePath:nil];
        }
        
        return NO;
    }
    
    return [self startSend:fileName];
}

- (void)sendDidStart
{
    NSLog(@"Attempting to Push %@ to %@", self.filePath, self.currentFtp);
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

- (void)sendDidStopWithStatus:(int)status
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

- (BOOL)startSend:(NSString *)fileName
{
    if (!self.hasFailed)
    {
        _fileSize = (long)[NSFileManager.defaultManager attributesOfItemAtPath:self.filePath
                                                                         error:nil].fileSize;
        
        if (!_fileSize)
            return NO;
        
        self.fileName = fileName;
        [self setUpFTP];
    }
    
    assert(!self.connection);
    assert(!self.fileStream);
    
    NSURL *url = [NetworkManager.sharedInstance smartURLForString:self.urlText];
    BOOL success = (url != nil);
    
    if (!success || ![NetworkManager.sharedInstance isBinaryURL:url])
    {
        if (!self.hasFailed)
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
            return NO;
        }
        
        else if (![NetworkManager.sharedInstance isBinaryURL:url])
        {
            NSAssert(0, @"ERROR: Invalid file type");
            return NO;
        }
    }
    
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:self.filePath];
    assert(self.fileStream);
    
    [self.fileStream open];
    
    NSLog(@"URL: %@", url);
    
    CFWriteStreamRef ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    if (!ftpStream)
    {
        NSAssert(0, @"Unable to open ftpstream");
        return NO;
    }
    
    self.networkStream = (__bridge NSOutputStream *)ftpStream;
    if (self.username.length != 0)
    {
        success = [self.networkStream setProperty:self.username
                                           forKey:(id)kCFStreamPropertyFTPUserName];
        
        if (!success)
            return NO;
        
        success = [self.networkStream setProperty:self.password
                                           forKey:(id)kCFStreamPropertyFTPPassword];
        
        if (!success)
            return NO;
    }
    
    self.networkStream.delegate = self;
    
    [self.networkStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                                  forMode:NSDefaultRunLoopMode];
    
    [self.networkStream open];
    CFRelease(ftpStream);
    
    self.totalDataSent = 0;
    self.progress = 0.0;
    
    [self sendDidStart];
    return YES;
}

- (void)stopSendWithStatus:(int)status
              statusString:(NSString *)statusString
{
    if (self.networkStream)
    {
        [self.networkStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                      forMode:NSDefaultRunLoopMode];
        
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    
    if (self.fileStream)
    {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    [self sendDidStopWithStatus:status
                   statusString:statusString];
}

- (void)stream:(NSStream *)aStream
   handleEvent:(NSStreamEvent)eventCode
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            break;
            
        case NSStreamEventHasBytesAvailable:
            assert(NO);
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            if (self.bufferOffset == self.bufferLimit)
            {
                NSInteger bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer
                                        maxLength:kSendBufferSize];
                
                if (bytesRead == -1)
                {
                    [self stopSendWithStatus:FTP_CONNECTION_FAILED
                                statusString:@"File read error"];
                }
                
                else if (bytesRead == 0)
                {
                    [self stopSendWithStatus:FTP_OK
                                statusString:@""];
                }
                
                else
                {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            if (self.bufferOffset != self.bufferLimit)
            {
                NSInteger bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset]
                                                         maxLength:self.bufferLimit - self.bufferOffset];
                
                assert(bytesWritten);
                
                if (bytesWritten == -1)
                {
                    [self stopSendWithStatus:FTP_CONNECTION_FAILED
                                statusString:@"Network write error"];
                }
                
                else
                {
                    self.bufferOffset += bytesWritten;
                    _totBytesWritten += bytesWritten;
                    self.progress = (CGFloat)_totBytesWritten / (CGFloat)_fileSize;
                    
                    if (self.popover)
                        [self.popover updateProgress:self.progress];
                }
            }
        }
            break;
            
        case NSStreamEventErrorOccurred:
        {
            [self stopSendWithStatus:FTP_CONNECTION_FAILED
                        statusString:@"Unable to connect"];
        }
            break;
            
        case NSStreamEventEndEncountered:
        {
            ii=1;
        }
            break;
            
        default:
        {
            assert(NO);
        }
            break;
    }
}

- (void)connection:(NSURLConnection *)theConnection
  didFailWithError:(NSError *)error
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.connection);
    
    if (!self.hasFailed)
    {
        NSLog(@"ERROR %i:%@", FTP_CONNECTION_FAILED, error.localizedDescription);
        
        [self stopSendWithStatus:FTP_CONNECTION_FAILED
                    statusString:error.localizedDescription];
        
        if (!self.useOnlyPrimaryFTP)
        {
            if ([self.currentFtp isEqualToString:self.ftpSite])
            {
                [self setToFtpSite2];
                self.currentFtp = self.ftpSite2;
                
                [UserDefaults.defaults saveString:self.currentFtp
                                           forKey:@"CurrentFtp"];
                
                self.hasFailed = YES;
                
                [self stopSendWithStatus:FTP_CONNECTION_FAILED
                            statusString:error.localizedDescription];
                
                [self sendFile:self.fileName
                 fromDirectory:self.directory
                   toDirectory:self.toDirectory
                deleteWhenDone:NO];
            }
            
            else
            {
                [self setToFtpSite1];
                self.currentFtp = self.ftpSite;
                
                [UserDefaults.defaults saveString:self.currentFtp
                                           forKey:@"CurrentFtp"];
                
                self.hasFailed = YES;
                
                [self stopSendWithStatus:FTP_CONNECTION_FAILED
                            statusString:error.localizedDescription];
            
                [self sendFile:self.fileName
                 fromDirectory:self.directory
                   toDirectory:self.toDirectory
                deleteWhenDone:NO];
            }
        }
    }
    
    else
    {
        //remove file to ensure partially transferred files are not used
        [NSFileManager.defaultManager removeItemAtPath:self.filePath
                                                 error:nil];
        
        [self stopSendWithStatus:FTP_CONNECTION_FAILED
                    statusString:error.localizedDescription];
        
        NSLog(@"ERROR %i:%@", FTP_CONNECTION_FAILED, error.localizedDescription);
        
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
    
    [self stopSendWithStatus:FTP_OK
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
    self.urlText = [NSString stringWithFormat:@"@%@:%@/%@/%@",self.ftpSite, self.port, self.toDirectory, self.toFileName];

}

- (void)setToFtpSite2
{
    self.urlText = [NSString stringWithFormat:@"@%@/%@/%@",self.ftpSite2, self.toDirectory, self.toFileName];
}

- (void)dealloc
{
    [self stopSendWithStatus:FTP_STOP
                   statusString:@"Stopped"];
}

@end