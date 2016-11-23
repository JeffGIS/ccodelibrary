//  FTPDataPush.m
//  CCodeLibrary

#import "FTPDataPush.h"
#import "Reachability.h"
@import CFNetwork;
#import "CRAPI.h"

enum {
    kSendBufferSize = 32768
};

@interface FTPDataPush ()

@property (nonatomic, readonly) BOOL isSending;
@property (nonatomic) NSOutputStream *networkStream;
@property (nonatomic) NSInputStream *fileStream;
@property (nonatomic, readonly) uint8_t *buffer;
@property (nonatomic, assign) size_t bufferOffset;
@property (nonatomic, assign) size_t bufferLimit;
@property (nonatomic) Reachability *reachability;
@property (nonatomic) long fileSize, totBytesWritten;
@property (nonatomic) int ii;
@property id <GSSiPopoverViewDelegate> savePopoverDelegate;
@property BOOL useOnlyPrimaryFTP;
@property (nonatomic, copy) NSString *tempExtension;

@end

@implementation FTPDataPush
{
    uint8_t _buffer[kSendBufferSize];
}

+ (FTPDataPush *)push
{
    FTPDataPush *dataPush = FTPDataPush.new;
    dataPush.useOnlyPrimaryFTP = YES;
    dataPush.tempExtension = @".upload";
    return dataPush;
}

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)sendFile:(NSString *)fileName
   fromDirectory:(NSString *)fromDirectory
          toFile:(NSString *)toFileName
     toDirectory:(NSString *)toDirectory
  deleteWhenDone:(BOOL)deleteWhenDone
  appendFileName:(BOOL)appendFileName
{
    _toDirectory = toDirectory;
    _directory = fromDirectory;
    _fileName = fileName;
    _toFileName = toFileName;
    
    if (appendFileName)
        _toFileName = [NSString stringWithFormat:@"%@%@", _toFileName, _tempExtension];
    
    _filePath = [NSString stringWithFormat:@"%@/%@", _directory, _fileName];
    
    assert(_filePath);
    
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = _reachability.currentReachabilityStatus;
    
    if(remoteHostStatus == NotReachable)
    {
        if (_delegate)
        {
            [_delegate FTPPushDidComplete:_dataType
                               withStatus:FTPStatusConnectionFailed
                          andStatusString:@"Host not reachable"
                                 filePath:_filePath];
        }
        
        return NO;
    }
    
    if (_popover)
    {
        _savePopoverDelegate = _popover.delegate;
        _popover.delegate = self;
    }
    
    return [self startSend:fileName];
}

- (void)sendDidStart
{
    NSLog(@"Attempting to Push %@ to %@", _filePath, _urlText);
}

- (void)sendDidStopWithStatus:(int)status
                 statusString:(NSString *)statusString
{
    if (!statusString)
    {
        assert(_filePath);
        status = FTPStatusStop;
    }
    
    if (_delegate)
    {
        [_delegate FTPPushDidComplete:_dataType
                           withStatus:status
                      andStatusString:statusString
                             filePath:_filePath];
    }
}

- (BOOL)isReceiving
{
    if (_connection)
        return YES;
    
    else
        return NO;
}

- (BOOL)startSend:(NSString *)fileName
{
    if (!_hasFailed)
    {
        _fileSize = (long)[NSFileManager.defaultManager attributesOfItemAtPath:_filePath
                                                                         error:nil].fileSize;
        
        if (!_fileSize)
            return NO;
        
        [self setUpFTP];
    }
    
    assert(!_connection);
    assert(!_fileStream);
    
    NSURL *url = [CRAPI.sharedInstance smartURLForString:_urlText];
    
    if (!url)
    {
        NSAssert(0, @"ERROR: Invalid URL");
        return NO;
        
    }
    
    _fileStream = [NSInputStream inputStreamWithFileAtPath:_filePath];
    assert(_fileStream);
    
    [_fileStream open];
    
    CFWriteStreamRef ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    
    if (!ftpStream)
    {
        NSAssert(0, @"Unable to open ftpstream");
        return NO;
    }
    
    _networkStream = (__bridge NSOutputStream *)ftpStream;
    
    if (_username.length != 0)
    {
        BOOL success = [_networkStream setProperty:_username
                                            forKey:(id)kCFStreamPropertyFTPUserName];
        
        if (!success)
            return NO;
        
        success = [_networkStream setProperty:_password
                                       forKey:(id)kCFStreamPropertyFTPPassword];
        
        if (!success)
            return NO;
    }
    
    _networkStream.delegate = self;
    
    [_networkStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                              forMode:NSDefaultRunLoopMode];
    
    [_networkStream open];
    CFRelease(ftpStream);
    
    _totalDataSent = 0;
    _progress = 0.0;
    
    [self sendDidStart];
    return YES;
}

- (void)stopSendWithStatus:(int)status
              statusString:(NSString *)statusString
{
    if (_popover)
        _popover.delegate = _savePopoverDelegate;
    
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

- (void)stream:(NSStream *)aStream
   handleEvent:(NSStreamEvent)eventCode
{
#pragma unused(aStream)
    assert(aStream == _networkStream);
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            break;
            
        case NSStreamEventHasBytesAvailable:
            assert(NO);
            break;
            
        case NSStreamEventHasSpaceAvailable:
            if (_bufferOffset == _bufferLimit)
            {
                NSInteger bytesRead;
                
                bytesRead = [_fileStream read:_buffer
                                    maxLength:kSendBufferSize];
                
                if (bytesRead == -1)
                {
                    [self stopSendWithStatus:FTPStatusConnectionFailed
                                statusString:@"File Read Error"];
                }
                
                else if (bytesRead == 0)
                {
                    [self stopSendWithStatus:FTPStatusOK
                                statusString:@"Transfer Complete"];
                }
                
                else
                {
                    _bufferOffset = 0;
                    _bufferLimit = bytesRead;
                }
            }
            
            if (_bufferOffset != _bufferLimit)
            {
                NSInteger bytesWritten = [_networkStream write:&_buffer[_bufferOffset]
                                                     maxLength:(_bufferLimit - _bufferOffset)];
                
                assert(bytesWritten);
                
                if (bytesWritten == -1)
                {
                    [self stopSendWithStatus:FTPStatusConnectionFailed
                                statusString:@"Unable to Connect"];
                }
                
                else
                {
                    _bufferOffset += bytesWritten;
                    _totBytesWritten += bytesWritten;
                    _progress = (_totBytesWritten / (CGFloat)_fileSize);
                    
                    if (_popover)
                        [_popover updateProgress:_progress];
                }
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            if (!_hasFailed)
            {
                NSLog(@"NSStream Error %li:%@", (long)aStream.streamError.code, aStream.streamError.localizedDescription);
                
                [self stopSendWithStatus:FTPStatusConnectionFailed
                            statusString:aStream.streamError.localizedDescription];
                
            }
            
            else
            {
                [self stopSendWithStatus:FTPStatusConnectionFailed
                            statusString:aStream.streamError.localizedDescription];
                
                NSLog(@"ERROR %li:%@", (long)FTPStatusConnectionFailed, aStream.streamError.localizedDescription);
                
                _hasFailed = NO;
            }

            break;
            
        case NSStreamEventEndEncountered:
            _ii = 1;
            break;
            
        default:
            assert(NO);
            break;
    }
}

- (void)setUpFTP
{

    _username = @"GSSiProfessionalServer";
    _password = @"GSSi";
    
    /*_ftpSite = @"192.168.254.39";
    _username = @"GSSiLocal";
    _password = @"GSSi";*/
    
    //_ftpSite2 = @"gssidata.com";
    _username2 = @"GSSiData";
    _password2 = @"GSSi";
    
    _port = @"21";
    

    
    [self setToFtpSite1];
}

- (void)setToFtpSite1
{
    _urlText = [NSString stringWithFormat:@"%@:%@/%@/%@",[CRAPI.sharedInstance getNVCRISServer], self.port, _toDirectory, _toFileName];

}

- (void)dealloc
{
    NSLog(@"FTPDataPush dealloc");
}

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView
{
    [self stopSendWithStatus:FTPStatusUserCancel
                statusString:@"Canceled by User"];
}

@end
