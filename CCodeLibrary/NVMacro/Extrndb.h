
#ifndef extrndb_h
#define extrndb_h


#define WM_BOOL     1
#define WM_BYTE     2
#define WM_INT      3
#define WM_LONG     4
#define WM_CURRENCY 5
#define WM_FLOAT    6
#define WM_DOUBLE   7
#define WM_DATE     8
#define WM_CHARS    10
#define WM_OLE      11
#define WM_MEMO     12
#define WM_PICTURE  13
#define WM_GENERAL  14

void SubstituteDBQ (LPSTR str,LPSTR pDBQ);
HANDLE OpenExternalDatabase ( LPSTR Name);
HANDLE OpenDDEExternalDatabase ( LPSTR Name);
/*	Opens a FoxPro, MS Access or Pardox database	*/
/*	Returns handle if successful or NULL if not		*/

long FindFieldName (LPSTR DBName,LPSTR FldPartialName,LPSTR OutFile);
long FindTableName (LPSTR DBName,LPSTR TablePartialName,LPSTR OutFile);
int	NumDatabaseTables ( char *type, HANDLE DBhandle,int itype);
int	NumDDEDatabaseTables ( char *type, HANDLE DBhandle);
/*	Returns the number of tables in the database	*/

LPSTR GetTableName (HANDLE DBhandle, Bool First,int dataFileType);
LPSTR GetDDETableName (HANDLE DBhandle, Bool First);
/*	Returns the name of a table in the database		*/
/*	If First is TRUE returns the first table.		*/
/*	Otherwise returns the next or NULL if at end	*/

int OpenDatabaseTable (int DBHandle, LPSTR TableName);
HANDLE OpenDDEDatabaseTable (HANDLE DBHandle, LPSTR TableName);
/*	Opens the specified table						*/

LPFIELDINFO GetFieldInfo (HANDLE TBLHandle, Bool First, short FileType,LPBool pHaveNonStandardFields);
LPFIELDINFO GetDDEFieldInfo (HANDLE TBLHandle, Bool First, short FileType);
/*	Returns a pointer to a FIELDINFO struct.		*/
/*	If First is TRUE returns the first table.		*/
/*	Otherwise returns the next or NULL if at end	*/  

LPFIELDINFO GetExternalFieldInfo (HANDLE TBLHandle, Bool First, LPBool pHaveNonStandardFields);
LPFIELDINFO GetDDEExternalFieldInfo (HANDLE TBLHandle, Bool First);
/*	Returns a pointer to a FIELDINFO struct.		*/
/*	If First is TRUE returns the first table.		*/
/*	Otherwise returns the next or NULL if at end	*/  
Bool AddToODBCParms (LPSTR Begin,LPSTR End);

LPVOID GetExternalFieldData (LPOPENFILEDATA FilePtr, LPCSTR index,LPHANDLE hstmt,
	LPFIELDINFO Field, Bool SingleVal, short FunctionID, LPSHORT irc,
                              int NumFields,LPFIELDINFO FirstField);
LPVOID GetDDEExternalFieldData ( HANDLE DBhandle, LPCSTR index, LPVOID keydata,
                              LPFIELDINFO field, Bool First, LPSHORT irc);
int UpdateExternalFieldData ( LPOPENFILEDATA FilePtr, LPSTR index,LPSTR UpdateString);
                              /*	Returns data for the specified field for the	*/
/*	row with the specified key.	Returns NULL if		*/
/*	the record does not exist.						*/

Bool InsertExternalFieldData (LPOPENFILEDATA FilePtr, LPSTR InsertString);
Bool ExternalSQLDirect (int hDB, LPSTR SQL);
Bool ExternalSQLDirectBatch (int hDB, LPSTR SQL);
void GetExternalReport ( HANDLE DBhandle, LPCSTR index, LPVOID keydata,
                              LPFIELDINFO field,LPCSTR R_or_F_Name);
void GetDDEExternalReport ( HANDLE DBhandle, LPCSTR index, LPVOID keydata,
                              LPFIELDINFO field,LPCSTR R_or_F_Name,
                              int PrintOrReport);
LPSTR GetDDEReportName (HANDLE DBhandle, Bool first);
void ClearCurVals (LPOPENFILEDATA FilePtr);

void CloseExternalTable (HANDLE TBLHandle);
void CloseDDEExternalTable (HANDLE TBLHandle);

void CloseExternalDatabase (int DBHandle);   
void CloseDDEExternalDatabase (HANDLE DBHandle);
RETCODE GetDataSource(HANDLE CThemeDB, Bool first, LPSTR names,
           short maxnamelen, short *namelen, LPSTR desc, short maxdesclen,
           short *desclen);
Bool GetODBCUniqueFieldValues (int DBhandle, LPCSTR SQL,LPSTR name,int length,
                               HANDLE hDBList);
RETCODE	FetchODBCRecord (LPOPENSQLDATA	SQLPtr);
SWORD NumSQLCols (LPOPENSQLDATA	SQLPtr);
DWORD NumSQLRows (HANDLE hSQL);
void SetODBCPassword (LPSTR UserID,LPSTR Password);
void CloseODBCPasswordFile (void);
void ODBCTerminate (Bool Quit);
Bool GetSQLWhereClause (HWND hWnd, HANDLE hDB, LPSTR Where);
Bool FAR PASCAL SQLWHEREMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam);
Bool FAR PASCAL SQL_BETWEENMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam);
HANDLE CreateUniqueList (int length, LPSTR Name);

#endif
