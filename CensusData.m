//
//  CensusData.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 3/13/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "CensusData.h"
#import "CCodeLibrary.h"

@implementation CensusData

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _documentsDirectory = UserDefaults.defaults.localFilePath;
        _fileName = @"Property.sqlite";
        _path = [NSString stringWithFormat:@"%@/%@", _documentsDirectory, _fileName];
        
    }
    return self;
}
- (BOOL)open
{
    if (!_isOpen)
    {
        self.isOpen = YES;
        self.isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        //NSLog(@"Property Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        return TRUE;
    }
    else
        return FALSE;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(sqlite3_close(_database), _database);
        //NSLog(@"Property Database close");
        _isOpen = NO;
    }
}

-(NSString*) value:(NSString*)valueName
       forAreaType:(NSString*) areaType
           withKey:(NSString*)areaID

{
    sqlite3_stmt *statement = NULL;
    
    NSString * value=@"";
    NSString *query = [NSString stringWithFormat:@"SELECT [%@] FROM CENSUS%@DATA WHERE GEOG_UNIT ='%@'",valueName,areaType,areaID];
    BOOL opened = [self open];
    
    
    SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR cvalue = (LPSTR)sqlite3_column_text(statement,0);
        value = [NSString stringWithUTF8String:cvalue];
    }
    
    
    SQLOK(sqlite3_finalize(statement), _database);
    
    [self close:opened];
    return value;
    
}


@end
