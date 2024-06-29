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
static int numOpenDB = 0;
static int ii=0;

SQLITE_API int SQLite_Open(
                           const char *filename,   /* Database filename (UTF-8) */
                           LPsqlite3nv *ppDb          /* OUT: SQLite db handle */
)
{
    *ppDb = malloc (sizeof(sqlite3nv));
    (*ppDb)->lastQuery = 0;
    sqlite3 * db;
    int rtn = sqlite3_open(filename, &db);
    (*ppDb)->db = db;
    if (rtn == SQLITE_OK)
        numOpenDB++;
    if (numOpenDB > 10)
        ii = 1;
    return rtn;
}
SQLITE_API int SQLite_Close(LPsqlite3nv *pdb)
{
    int rtn = 0;
    if (*pdb)
    {
        rtn = sqlite3_close((*pdb)->db);
        if ((*pdb)->lastQuery)
        {
            free ((*pdb)->lastQuery);
            (*pdb)->lastQuery = 0;
        }
        free (*pdb);
        *pdb = 0;
        if (rtn == SQLITE_OK)
            numOpenDB--;
    }
    return rtn;
}


int SQLOK(char * fromFile, int fromLine,int sqlReturn, LPsqlite3nv pdatabase)
{
    if (sqlReturn != SQLITE_OK)
    {
        NSString * dbName = @"";
        NSString * query = @"";
        if (pdatabase->lastQuery)
            query = [NSString stringWithUTF8String:pdatabase->lastQuery];
        int shared = 0;
        
        char *name = (char *)sqlite3_db_filename(pdatabase->db, "main");
        if (name)
        {
            NSString *fullPath = [NSString stringWithUTF8String:name];
            dbName = [fullPath lastPathComponent];
            fullPath = [fullPath uppercaseString];
            if ([fullPath containsString:@"SHARED"])
                shared = 1;
        }
        LPSTR ffile = strrchr (fromFile,'/');
        if (ffile)
            ffile++;
        else
            ffile = fromFile;
        NSString *errmess = [NSString stringWithFormat:@"SQLite Error %i = %i:%s db(%i):%@\r\nFrom:%s line%i\r\n%@",
                           sqlReturn, sqlite3_errcode(pdatabase->db),sqlite3_errmsg(pdatabase->db),shared,dbName,ffile,fromLine,query];
        [CRAPI.sharedInstance logToErrorFile:errmess];
    }
    
    return sqlReturn;
}
int SQLOKpd(int sqlReturn, sqlite3nv *database, int method)
{
    return SQLOK (__FILE__,__LINE__,sqlReturn,database);
}

bool doesSQLiteFieldExist(char* tableName, char* fieldName,LPsqlite3nv pdatabase)
{
    BOOL doesExist = FALSE;
    
    sqlite3_stmt *stmt = NULL;
    char * query = malloc (1024);
    sprintf (query,"pragma table_info ('%s')",tableName);
    int rc = SQLitePrepare(pdatabase, query, -1, &stmt, NULL);
    
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
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(stmt), pdatabase);
    free (query);
    return doesExist;
}

int SQLitePrepare (LPsqlite3nv pdb,            /* Database handle */
                   const char *zSql,       /* SQL statement, UTF-8 encoded */
                   int nByte,              /* Maximum length of zSql in bytes. */
                   sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                   const char **pzTail     /* OUT: Pointer to unused portion of zSql */)

{
    int rtn = sqlite3_prepare_v2(pdb->db, zSql,nByte,ppStmt,pzTail);
    int qlen =  (int)strlen (zSql);
    if (pdb->lastQuery)
        free (pdb->lastQuery);
    pdb->lastQuery = malloc (qlen+4);
    strcpy (pdb->lastQuery,zSql);
    return rtn;
}
int SQLiteFinalize(sqlite3_stmt *pStmt)
{
    int rtn = sqlite3_finalize(pStmt);
//    if (lastQuery)
//        free (lastQuery);
//    lastQuery = 0;
    return rtn;
}
int SQLiteExec(
                            LPsqlite3nv pdb,                                  /* An open database */
                            const char *sql,                           /* SQL to be evaluated */
                            int (*callback)(void*,int,char**,char**),  /* Callback function */
                            void * arg,                                    /* 1st argument to callback */
                            char **errmsg                              /* Error msg written here */)
{
    int qlen =  (int)strlen (sql);
    if (pdb->lastQuery)
        free (pdb->lastQuery);
    pdb->lastQuery = malloc (qlen+4);
    strcpy (pdb->lastQuery,sql);
    return sqlite3_exec(pdb->db, sql, callback, arg, errmsg);
}

bool doesSQLiteTableExist(char* tableNameIN, LPsqlite3nv pdatabase)
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
        sprintf (query,"SELECT name FROM sqlite_master WHERE type='table' AND name='%s';",tableName);
    }
    BOOL rc = !SQLOK(__FILE__,__LINE__,SQLitePrepare(pdatabase, query, -1, &stmt, NULL),pdatabase);
    
    if (rc)
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            LPSTR tName = (LPSTR)sqlite3_column_text(stmt, 0);
            if (!strcmp (tName,pDot))
                doesExist = YES;
        }
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(stmt), pdatabase);//,query);
    free (query);
    return doesExist;
}
