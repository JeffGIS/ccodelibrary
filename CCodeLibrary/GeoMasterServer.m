//  GeoMasterServer.m
//  CCodeLibrary

#define PRODUCTION_PORT 443

#import "GeoMasterServer.h"
#import "Reachability.h"
#import "CRAPI.h"

@interface GeoMasterServer ()

@property (nonatomic) Reachability *reachability;

@end

@implementation GeoMasterServer

static GeoMasterServer *statServer = nil;

+ (GeoMasterServer *)open
{
    if (!statServer)
        statServer = [[GeoMasterServer alloc] init];
    statServer.output = @"";
    statServer.useTestServer = NO;
    return statServer;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _output = @"";
    }

    return self;
}

- (void)dealloc
{
    statServer = nil;
    NSLog(@"GMServer dealloc");
}

- (void)closeServer
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
    BOOL rtn = NO;
    int port = _port;
    if (!_port)
        port = PRODUCTION_PORT;
    NSString * ipAddress = [CRAPI.sharedInstance getNVCRISServer];
    if (_ipAddress)
        ipAddress = _ipAddress;
    
    _reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = _reachability.currentReachabilityStatus;
    
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
    _reachability = nil;
    _responseTimeoutInSeconds = connectionTimeoutInSeconds;
	CFReadStreamRef readStream = NULL;
	CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(ipAddress),
                                       port, &readStream, &writeStream);
	
	_inputStream = (__bridge NSInputStream *)readStream;
	_outputStream = (__bridge NSOutputStream *)writeStream;
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
	[_inputStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                            forMode:NSDefaultRunLoopMode];
    
	[_outputStream scheduleInRunLoop:NSRunLoop.currentRunLoop
                             forMode:NSDefaultRunLoopMode];
    
    if (_openTimer)
        [_openTimer invalidate];
    
    _openTimer = [NSTimer scheduledTimerWithTimeInterval:connectionTimeoutInSeconds
                                                  target:self
                                                selector:@selector(serverFailedToOpen:)
                                                userInfo:nil
                                                 repeats:NO];
    
	[_outputStream open];
	[_inputStream open];
	return rtn;
}

- (void)doSendMessage:(NSTimer *)timer
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
                                                        selector:@selector(serverFailedToRespond:)
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
                                                selector:@selector(doSendMessage:)
                                                userInfo:nil
                                                 repeats:NO];
	
    return YES;
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
            
            if (_outputStream && _delegate && theStream == _outputStream)
                [_delegate GMServerDidOpen:self];

			break;
            
		case NSStreamEventHasBytesAvailable:
			
            if (_inputStream && theStream == _inputStream)
            {
				uint8_t buffer[1024];
                long len = 0;
                long origlen = 0;
				
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
                        
                        _output = [_output stringByAppendingString:buff];
                        
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
                            
							//_output = @"";
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

- (void)serverFailedToRespond:(NSTimer *)timer
{
    [self closeServer];
    
    if (_delegate)
    {
        [_delegate GMServer:self
            didReceiveError:@"Server failed to respond"
                 withStatus:GMServerStatusNoResponse];
    }
    
}
- (void)serverFailedToOpen:(NSTimer *)timer
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
