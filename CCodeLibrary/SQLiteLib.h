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
typedef sqlite3nv  *LPsqlite3nv;

SQLITE_API int SQLite_Open(
                            const char *filename,   /* Database filename (UTF-8) */
                            LPsqlite3nv *ppDb          /* OUT: SQLite db handle */
);
SQLITE_API int SQLite_Close(LPsqlite3nv *db);

int SQLOK(char * fromFile, int fromLine,int sqlReturn, LPsqlite3nv pdatabase);
bool doesSQLiteTableExist(char* tableName, LPsqlite3nv pdatabase);
bool doesSQLiteFieldExist(char* tableName, char* fieldName,LPsqlite3nv pdatabase);
int SQLitePrepare (LPsqlite3nv pdb,            /* Database handle */
                   const char *zSql,       /* SQL statement, UTF-8 encoded */
                   int nByte,              /* Maximum length of zSql in bytes. */
                   sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                   const char **pzTail     /* OUT: Pointer to unused portion of zSql */);
int SQLiteFinalize(sqlite3_stmt *pStmt);
int SQLiteExec(
               LPsqlite3nv pdb,                                  /* An open database */
               const char *sql,                           /* SQL to be evaluated */
               int (*callback)(void*,int,char**,char**),  /* Callback function */
               void *arg,                                    /* 1st argument to callback */
               char **errmsg                              /* Error msg written here */
);
int query_rtree_bbox(sqlite3 *db_handle, const char *rtree_name, LPMNMXCORD pBounds);

#endif /* defined(__CCodeLibrary__SQLiteLib__) */
