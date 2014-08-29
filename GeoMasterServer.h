//
//  GeoMasterServer.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 8/29/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GeoMasterServer;

@protocol GeoMasterServerDelegate  <NSObject>

- (void) FTPdidComplete:(int)status
               filePath:(NSString *)path;

@end



@interface GeoMasterServer : NSObject
@property (nonatomic, weak) id <GeoMasterServerDelegate> delegate;

+ (GeoMasterServer *)pull;

@end
