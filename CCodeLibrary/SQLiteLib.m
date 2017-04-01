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
        
        char *name = (char *)sqlite3_db_filename(database, "main");
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

BOOL doesSQLiteTableExist(char* tableNameIN, sqlite3 *database)
{
    BOOL doesExist = FALSE;
    char tableName[256];
    strncpy (tableName,tableNameIN,254);
    
    sqlite3_stmt *stmt = NULL;
    char * query = malloc (1024);
    LPSTR pDot = strrchr (tableName,'.');
    if (pDot)
    {
        *pDot = 0;
        sprintf (query,"SELECT name FROM %s.sqlite_master WHERE type='table';",tableName);
        *pDot++ = '.';
    }
    else
    {
        pDot = tableName;
        sprintf (query,"SELECT name FROM sqlite_master WHERE type='table' AND name='table_name';",tableName);
    }
    BOOL rc = !SQLOK(0,sqlite3_prepare_v2(database, query, -1, &stmt, NULL),database);
    
    if (rc)
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            LPSTR tName = (LPSTR)sqlite3_column_text(stmt, 0);
            if (!strcmp (tName,pDot))
                doesExist = YES;
        }
    }
    SQLOK(102,sqlite3_finalize(stmt), database);
    free (query);
    return doesExist;
}
