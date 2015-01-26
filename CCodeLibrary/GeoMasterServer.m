//  GeoMasterServer.m
//  CCodeLibrary

#define GM_ADDRESS @"74.42.137.128"
#define GM_ADDRESSx @"192.168.254.39"
#define GM_ADDRESSy @"192.168.1.144"
#define GM_PORT 22335

#import "GeoMasterServer.h"
#import "Reachability.h"

@implementation GeoMasterServer
{
    Reachability *_reachability;
}

static GeoMasterServer *_open = nil;

+ (GeoMasterServer *)open
{
    if (!_open)
        _open = [[GeoMasterServer alloc] init];
    
    return _open;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _output = @"";
        _ipAddress = GM_ADDRESS;
    }

    return self;
}

- (void) closeServer
{
    if (_openTimer)
        [_openTimer invalidate];
    
    if (_responseTimer)
        [_responseTimer invalidate];
    
    if (_inputStream)
    {
        [_inputStream close];
        
        [_inputStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                forMode:NSDefaultRunLoopMode];
        
        _inputStream.delegate = nil;
        _inputStream = nil;
    }
    
    if (_outputStream)
    {
        [_outputStream close];
        [_outputStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                 forMode:NSDefaultRunLoopMode];
        
        _outputStream.delegate = nil;
        _outputStream = nil;
    }
}

- (BOOL)initCommunication:(CGFloat)connectionTimeoutInSeconds
{
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = _reachability.currentReachabilityStatus;
    bool rtn = NO;
    
    _responseTimeoutInSeconds = connectionTimeoutInSeconds;
    if(remoteHostStatus == NotReachable)
    {
        [self closeServer];
    
        if (_delegate)
        {
            [_delegate GMServer:self
                didReceiveError:@"Internet Connection Not Available"
                     withStatus:remoteHostStatus];
        }
        
        return rtn;
    }
    
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(_ipAddress),
                                       GM_PORT, &readStream, &writeStream);
	
	_inputStream = (__bridge NSInputStream *)readStream;
	_outputStream = (__bridge NSOutputStream *)writeStream;
	[_inputStream setDelegate:self];
	[_outputStream setDelegate:self];
    
	[_inputStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                            forMode:NSDefaultRunLoopMode];
    
	[_outputStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                             forMode:NSDefaultRunLoopMode];
    
    if (_openTimer)
        [_openTimer invalidate];
    
    _openTimer = [NSTimer scheduledTimerWithTimeInterval:connectionTimeoutInSeconds
                                                  target:self
                                                selector:@selector(serverFailedToOpen)
                                                userInfo:nil
                                                 repeats:NO];
    
	[_outputStream open];
	[_inputStream open];
	return rtn;
}

- (void)doSendMessage
{
    NSLog(@"data.length = %lu", (unsigned long)_data.length);
    
    long rc = [_outputStream write:_data.bytes
                         maxLength:_data.length];
    
    if (_responseTimer)
        [_responseTimer invalidate];
    
    if (_data.length != rc)
    {
        if (_delegate)
        {
            [_delegate GMServer:self
                didReceiveError:@"Failed to send message"
                     withStatus:GMServerStatusSendFailed];
        }
    }
    
    else
    {
    
        _responseTimer = [NSTimer scheduledTimerWithTimeInterval:_responseTimeoutInSeconds
                                                          target:self
                                                        selector:@selector(serverFailedToRespond)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (BOOL)sendMessage:(NSString *)message
{
    _data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (_sendTimer)
        [_sendTimer invalidate];

    _sendTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(doSendMessage)
                                                userInfo:nil
                                                 repeats:NO];
	
    return true;
}

- (void)stream:(NSStream *)theStream
   handleEvent:(NSStreamEvent)streamEvent
{
    NSLog(@"GMServer Stream Event %li", (long)streamEvent);
	
	switch (streamEvent)
    {
		case NSStreamEventOpenCompleted:
			
            if (_openTimer)
                [_openTimer invalidate];
            
            _openTimer = nil;
            
            if (_outputStream && self.delegate && theStream == _outputStream)
                [self.delegate GMServerDidOpen:self];

			break;
            
		case NSStreamEventHasBytesAvailable:
			
            if (_inputStream && theStream == _inputStream)
            {
				uint8_t buffer[1024];
				long len, origlen;
				
				while (_inputStream.hasBytesAvailable)
                {
					origlen = len = [_inputStream read:buffer
                                             maxLength:sizeof(buffer)];
                    
                    while (len > 0 && buffer[len - 1] == 0)
                        len--;
                    
					if (len > 0)
                    {
                        NSString *buff = [[NSString alloc] initWithBytes:buffer
                                                                  length:len
                                                                encoding:NSUTF8StringEncoding];
                        
                        _output  = [_output stringByAppendingString:buff];
                        
                        if (!buffer[origlen - 1])
                        {
                            if (_responseTimer)
                                [_responseTimer invalidate];
                            
                            if (_delegate)
                            {
                                [_delegate GMServer:self
                                  didReceiveMessage:_output
                                         withStatus:GMServerStatusOK];
                            }
                            
							_output = @"";
						}
					}
				}
			}
            
			break;
            
		case NSStreamEventErrorOccurred:
        {
            [self closeServer];
            
            if (_responseTimer)
                [_responseTimer invalidate];
            
            if (_delegate)
            {
                [_delegate GMServer:self
                    didReceiveError:theStream.streamError.localizedDescription
                         withStatus:theStream.streamError.code];
            }
        }
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                 forMode:NSDefaultRunLoopMode];
            theStream = nil;
            
            if (_responseTimer)
                [_responseTimer invalidate];
            
			if (_delegate)
            {
                [_delegate GMServer:self
                    didReceiveError:@"Server closed"
                         withStatus:streamEvent];
            }
			
			break;
            
        case NSStreamEventHasSpaceAvailable:
            break;
            
		default:
            if (_responseTimer)
                [_responseTimer invalidate];
            
			if (_delegate)
            {
                [_delegate GMServer:self
                    didReceiveError:@"Unknown error"
                         withStatus:streamEvent];
            }
	}
}

- (void) serverFailedToRespond
{
    [self closeServer];
    
    if (_delegate)
    {
        [_delegate GMServer:self
            didReceiveError:@"Server failed to respond"
                 withStatus:GMServerStatusNoResponse];
    }
    
}
- (void)serverFailedToOpen
{
    [self closeServer];
   
    if (_delegate)
    {
        [_delegate GMServer:self
            didReceiveError:@"Server failed to open"
                 withStatus:GMServerStatusOpenFailed];
    }
}

- (void)messageReceived:(NSString *)message
{
	[_messages addObject:message];
}

@end