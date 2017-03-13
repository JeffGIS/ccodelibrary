//
//  CrimeData.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/10/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteLib.h"
#import "MathUtil.h"

@interface CrimeData : NSObject
@property sqlite3 *database;
@property (nonatomic) int datasetVersion;
@property (nonatomic) BOOL isOpen;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property long long fileSize;
@property NSInteger myLastUpdate;
@property NSInteger serversLastUpdate;
@property BOOL autoUpdate;

- (BOOL)open;
- (void)close;
- (BOOL)clear;

- (BOOL)executeCmd:(char *)cmd;
-(void) getIdForUpdate:(LPSTR)str
                remove:(BOOL)remove;

- (void)startTransaction;
- (void)commitTransaction;
+ (NSString *)reportForControlNumber:(NSInteger)cnumber;
- (BOOL)update:(UIView *)fromView
          auto:(BOOL)autoUpdate;

@end
