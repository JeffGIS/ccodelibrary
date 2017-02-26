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
int SQLOK(int from,int sqlReturn, sqlite3 *database);
BOOL doesSQLiteTableExist(char* tableName, sqlite3 *database);
BOOL doesSQLiteFieldExist(char* tableName, char* fieldName,sqlite3 *database);

#endif /* defined(__CCodeLibrary__SQLiteLib__) */
