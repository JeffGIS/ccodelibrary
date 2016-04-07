//
//  CensusData.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 3/13/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CensusData : NSObject

@property sqlite3 *database;
@property (atomic) BOOL isOpen;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property NSInteger fileSize;

- (BOOL)open;
- (void)close:(BOOL)opened;

-(NSString*) value:(NSString*)valueName
       forAreaType:(NSString*) areaType
           withKey:(NSString*)areaID;

@end
