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

typedef struct {sqlite3 * db; LPSTR lastQuery;} sqlite3nv;

SQLITE_API int SQLite_Open(
                            const char *filename,   /* Database filename (UTF-8) */
                            sqlite3nv **ppDb          /* OUT: SQLite db handle */
);
SQLITE_API int SQLite_Close(sqlite3nv* db);

int SQLOK(char * fromFile, int fromLine,int sqlReturn, sqlite3nv *database);
bool doesSQLiteTableExist(char* tableName, sqlite3nv *database);
bool doesSQLiteFieldExist(char* tableName, char* fieldName,sqlite3nv *database);
int SQLitePrepare (sqlite3nv *db,            /* Database handle */
                   const char *zSql,       /* SQL statement, UTF-8 encoded */
                   int nByte,              /* Maximum length of zSql in bytes. */
                   sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                   const char **pzTail     /* OUT: Pointer to unused portion of zSql */);
int SQLiteFinalize(sqlite3_stmt *pStmt);
int SQLiteExec(
               sqlite3nv* db,                                  /* An open database */
               const char *sql,                           /* SQL to be evaluated */
               int (*callback)(void*,int,char**,char**),  /* Callback function */
               void *arg,                                    /* 1st argument to callback */
               char **errmsg                              /* Error msg written here */
);

#endif /* defined(__CCodeLibrary__SQLiteLib__) */
