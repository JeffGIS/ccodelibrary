//
//  GeoMasterServer.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 8/29/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import "GeoMasterServer.h"

@implementation GeoMasterServer
{
   
}

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
        [_inputStream close];
    if (_outputStream != nil)
        [_outputStream close];
    _inputStream = nil;
    _outputStream = nil;
}

- (bool) initCommunication {
	
    bool rtn=false;
    
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	//FStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 80, &readStream, &writeStream);
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"74.36.96.131", 22335, &readStream, &writeStream);
	
	_inputStream = (__bridge NSInputStream *)readStream;
	_outputStream = (__bridge NSOutputStream *)writeStream;
	[_inputStream setDelegate:self];
	[_outputStream setDelegate:self];
	[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inputStream open];
	[_outputStream open];
	return rtn;
}
- (IBAction) sendMessage:(NSString *)message
{
	
	NSString *response  = [NSString stringWithFormat:@"msg:%@", message];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[_outputStream write:[data bytes] maxLength:[data length]];
	
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	NSLog(@"stream event %lu", streamEvent);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			if (self.delegate)
            {
                [self.delegate GMServerDidOpen:self];
            }
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == _inputStream) {
				
				uint8_t buffer[1024];
				long len;
				
				while ([_inputStream hasBytesAvailable])
                {
					len = [_inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0)
                    {
                        NSString* buff = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        _output  = [_output stringByAppendingString:buff];
                        if (!buffer[len-1])
                        {
                            if (self.delegate)
                            {
                                [self.delegate GMServer:self didReceiveMessage:_output withStatus:GMOK];
                            }
							_output = @"";
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			if (self.delegate)
            {
                [self.delegate GMServer:self didReceiveError:@"Failed to open" withStatus:streamEvent];
            }
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			if (self.delegate)
            {
                [self.delegate GMServer:self didReceiveError:@"Server closed" withStatus:streamEvent];
            }
			
			break;
        case NSStreamEventHasSpaceAvailable:
            break;
		default:
			if (self.delegate)
            {
                [self.delegate GMServer:self didReceiveError:@"Unknown error" withStatus:streamEvent];
            }
	}
    
}

- (void) messageReceived:(NSString *)message {
	
	[self.messages addObject:message];
	//[self.tView reloadData];
	//NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
	//											   inSection:0];
	//[self.tView scrollToRowAtIndexPath:topIndexPath
	//				  atScrollPosition:UITableViewScrollPositionMiddle
	//						  animated:YES];
    
}

@end
