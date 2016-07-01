//
//  SQLiteLib.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/29/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "SQLiteLib.h"
#import "CRAPI.h"
#import <string.h>

int SQLOK(int from,int sqlReturn, sqlite3 *database)
{
    if (sqlReturn != SQLITE_OK)
    {
        NSString * dbName = @"";
        int shared = 0;
        
        char *name = sqlite3_db_filename(database, "main");
        if (name)
        {
            NSString *fullPath = [NSString stringWithUTF8String:name];
            dbName = [fullPath lastPathComponent];
            fullPath = [fullPath uppercaseString];
            if ([fullPath containsString:@"SHARED"])
                shared = 1;
        }
        NSString *errmess = [NSString stringWithFormat:@"SQLite Error %i = %i from %i:%s db(%i):%@",
                           sqlReturn, sqlite3_errcode(database),from, sqlite3_errmsg(database),shared,dbName];
        [CRAPI.sharedInstance logToErrorFile:errmess];
    }
    
    return sqlReturn;
}
