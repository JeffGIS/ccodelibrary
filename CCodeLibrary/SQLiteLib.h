//
//  SQLiteLib.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 6/12/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import <sqlite3.h>
#ifndef __CCodeLibrary__SQLiteLib__
#define __CCodeLibrary__SQLiteLib__

#include <stdio.h>
int SQLOK(char * fromFile, int fromLine,int sqlReturn, sqlite3 *database);
BOOL doesSQLiteTableExist(char* tableName, sqlite3 *database);
BOOL doesSQLiteFieldExist(char* tableName, char* fieldName,sqlite3 *database);
int SQLitePrepare (sqlite3 *db,            /* Database handle */
                   const char *zSql,       /* SQL statement, UTF-8 encoded */
                   int nByte,              /* Maximum length of zSql in bytes. */
                   sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                   const char **pzTail     /* OUT: Pointer to unused portion of zSql */);
int SQLiteFinalize(sqlite3_stmt *pStmt);

#endif /* defined(__CCodeLibrary__SQLiteLib__) */
