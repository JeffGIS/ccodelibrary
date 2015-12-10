//
//  CurbRampData.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface CurbRampData : NSObject
@property sqlite3 *database;
@property NSString *sendToServerFile;
@property (atomic) BOOL isOpen;
@property int geoid;
@property (atomic) int processingID;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property NSInteger fileSize;
@property (nonatomic) int datasetVersion;

+ (CurbRampData *)databaseForGeoid:(int)geoid
                            create:(BOOL)create;
- (BOOL)open;
- (void)close:(BOOL)opened;
- (void)clear;
- (BOOL)createIntersectionsTable:(BOOL)dropExistingTables;
- (NSString *)databasePath:(int)geoid;

- (BOOL)executeCmd:(char *)cmd
      sendToServer:(BOOL)sendToServer
     useUniqueFile:(BOOL)uniqueFile;

- (void)startTransaction;
- (void)commitTransaction;


@end
