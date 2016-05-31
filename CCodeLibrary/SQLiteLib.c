//
//  SQLiteLib.c
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#include "SQLiteLib.h"
int SQLOK(int sqlReturn, sqlite3 *database)
{
    if (sqlReturn != SQLITE_OK)
    {
        /*NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i = %i:%s",
         sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database)"SQLite Error %i = %i:%s",
         sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database)]);*/
        printf("SQLite Error %i = %i:%s",
                sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database));
        
    }
    
    return sqlReturn;
}
