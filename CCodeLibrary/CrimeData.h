//
//  CrimeData.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/10/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CrimeData : NSObject
@property sqlite3 *database;
@property (nonatomic) int datasetVersion;
@property (nonatomic) BOOL isOpen;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property long long fileSize;

- (BOOL)open;
- (void)close;
- (BOOL)clear;

- (BOOL)executeCmd:(char *)cmd;

- (void)startTransaction;
- (void)commitTransaction;

@end
