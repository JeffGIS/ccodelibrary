//
//  GeoMasterServer.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 8/29/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

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

- (void) initNetworkCommunication {
	
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	//FStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 80, &readStream, &writeStream);
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"74.36.96.131", 22335, &readStream, &writeStream);
	
	inputStream = (__bridge NSInputStream *)readStream;
	outputStream = (__bridge NSOutputStream *)writeStream;
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream open];
	[outputStream open];
	
}
- (IBAction) sendMessage:(NSString *)message
{
	
	NSString *response  = [NSString stringWithFormat:@"msg:%@", message];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
	
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	NSLog(@"stream event %lu", streamEvent);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == inputStream) {
				
				uint8_t buffer[1024];
				long len;
				
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
							[self messageReceived:output];
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
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
