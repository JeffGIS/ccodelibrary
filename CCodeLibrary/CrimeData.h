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
@class CrimeData;

@protocol CrimeDataDelegate <NSObject>

- (void) CrimeDataUpdateDidComplete:(long)status;

@end

@interface CrimeData : NSObject
@property (nonatomic, weak) id <CrimeDataDelegate> delegate;
@property sqlite3 *database;
@property (nonatomic) int datasetVersion;
@property (nonatomic) Bool isOpen;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *reportsDirectory;
@property long long fileSize;
@property int myLastUpdate, nextUpdate;
@property int serversLastUpdate;
@property Bool autoUpdate;

- (Bool)open;
- (void)close:(Bool)opened;
- (Bool)clear;

- (Bool)executeCmd:(char *)cmd;
-(void) getIdForUpdate:(LPSTR)str
                remove:(Bool)remove;

- (NSString *)databasePath;
- (Bool)startTransaction;
- (void)commitTransaction;
- (NSString *)reportForControlNum:(NSInteger)cnumber;
+ (NSString *)reportForControlNumber:(NSInteger)cnumber;
- (Bool)update:(UIView *)fromView
          auto:(Bool)autoUpdate
      delegate:(id)delegate;

@end
