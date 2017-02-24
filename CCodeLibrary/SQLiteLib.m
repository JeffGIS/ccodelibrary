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

// This method will return if your table exist a field or not
BOOL doesSQLiteFieldExist(char* tableName, char* fieldName,sqlite3 *database)
{
    BOOL doesExist = FALSE;
    
    
    sqlite3_stmt *stmt = NULL;
    char * query = malloc (1024);
    sprintf (query,"pragma table_info ('%s')",tableName);
    int rc = sqlite3_prepare_v2(database, query, -1, &stmt, NULL);
    
    if (rc==SQLITE_OK)
    {
        //will continue to go down the rows (columns in your table) till there are no more
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            LPSTR colName = (LPSTR)sqlite3_column_text(stmt, 1);
            LPSTR colType = (LPSTR)sqlite3_column_text(stmt, 2);
            if (!strcmp (colName,fieldName))
                doesExist = YES;
        }
    }
    SQLOK(102,sqlite3_finalize(stmt), database);
    free (query);
    return doesExist;
}
