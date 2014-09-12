//  GeoMasterServer.m
//  CCodeLibrary

#import "GeoMasterServer.h"

@implementation GeoMasterServer

static GeoMasterServer *_open;

+ (GeoMasterServer *)open
{
    if (_open == nil)
    {
        _open = [[GeoMasterServer alloc] init];
    }
    
    return _open;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.output = @"";
    }
    return self;
}

- (void) closeServer
{
    if (_inputStream != nil)
    {
        [_inputStream close];
        
        [_inputStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                forMode:NSDefaultRunLoopMode];
        
        _inputStream.delegate = nil;
        _inputStream = nil;
    }
    
    if (_outputStream != nil)
    {
        [_outputStream close];
        [_outputStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                 forMode:NSDefaultRunLoopMode];
        
        _outputStream.delegate = nil;
        _outputStream = nil;
    }
}

- (BOOL)initCommunication:(float)connectionTimeoutInSeconds
{
    bool rtn = NO;
    
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	//FStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 80, &readStream, &writeStream);
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"74.36.99.166", 22335, &readStream, &writeStream);
	
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

- (void) doSendMessage
{
    long rc = [_outputStream write:_data.bytes
                         maxLength:_data.length];
    
    if (_data.length != rc)
    {
        if (self.delegate)
        {
            [self.delegate GMServer:self
                    didReceiveError:@"Failed to send message"
                         withStatus:GM_SEND_FAILED];
        }
    }
}
- (BOOL) sendMessage:(NSString *)message
{
	_data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    
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
    int ii;
	NSLog(@"stream event %lu", (long)streamEvent);
	
	switch (streamEvent)
    {
			
		case NSStreamEventOpenCompleted:
			
            if (_openTimer)
                [_openTimer invalidate];
            
            _openTimer = nil;
            
            if (self.delegate && theStream == _outputStream)
                [self.delegate GMServerDidOpen:self];

			break;
            
		case NSStreamEventHasBytesAvailable:
			
            if (theStream == _inputStream)
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
                            if (self.delegate)
                            {
                                [self.delegate GMServer:self
                                      didReceiveMessage:_output
                                             withStatus:GM_OK];
                            }
                            
							_output = @"";
						}
					}
				}
			}
            
			break;
            
		case NSStreamEventErrorOccurred:
			
        {
            NSError *theError = theStream.streamError;
            NSString *errorMessage = theError.localizedDescription;
            [self closeServer];
            
            if (self.delegate)
            {
                [self.delegate GMServer:self
                        didReceiveError:errorMessage
                             withStatus:theError.code];
            }
        }
            
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:NSRunLoop.currentRunLoop
                                 forMode:NSDefaultRunLoopMode];
            theStream = nil;
            
			if (self.delegate)
            {
                [self.delegate GMServer:self
                        didReceiveError:@"Server closed"
                             withStatus:streamEvent];
            }
			
			break;
            
        case NSStreamEventHasSpaceAvailable:
            ii=1;
            break;
            
		default:
			if (self.delegate)
            {
                [self.delegate GMServer:self
                        didReceiveError:@"Unknown error"
                             withStatus:streamEvent];
            }
	}
}

- (void)serverFailedToOpen
{
    [self closeServer];
   
    if (self.delegate)
    {
        [self.delegate GMServer:self
                didReceiveError:@"Server failed to open"
                     withStatus:GM_OPEN_FAILED];
    }
    
}
- (void) messageReceived:(NSString *)message
{
	[self.messages addObject:message];
/*
	[self.tView reloadData];
 
	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
												   inSection:0];
 
	[self.tView scrollToRowAtIndexPath:topIndexPath
					  atScrollPosition:UITableViewScrollPositionMiddle
							  animated:YES];
*/
}

@end