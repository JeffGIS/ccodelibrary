#define _CRTDBG_MAP_ALLOC  
#include <stdlib.h>  
//#include <crtdbg.h>
#include "graphint.h"
#include "proj_api.h"
#include "shapefil.h"
#include "gmextern.h"
#include "PROJ.H"

HANDLE STRANRect (LPRECT FromRect,LPRECT ToRect)
{
    HANDLE hTran;
    double    XFROM[4],YFROM[4],XTO[4],YTO[4];
    float    RSQMIN;
    
    XFROM[0] = FromRect->left;
    XFROM[1] = FromRect->left;
    XFROM[2] = FromRect->right;
    XFROM[3] = FromRect->right;
    YFROM[0] = FromRect->bottom;
    YFROM[1] = FromRect->top;
    YFROM[2] = FromRect->top;
    YFROM[3] = FromRect->bottom;
    XTO[0] = ToRect->left;
    XTO[1] = ToRect->left;
    XTO[2] = ToRect->right;
    XTO[3] = ToRect->right;
    YTO[0] = ToRect->bottom;
    YTO[1] = ToRect->top;
    YTO[2] = ToRect->top;
    YTO[3] = ToRect->bottom;
    
    hTran = STRAN2 (1662,XFROM,YFROM,XTO,YTO,4,(LPFLOAT)&RSQMIN,1,NULL);
    return hTran;
}
void TRANRect (LPRECT Rect,HANDLE hTran)
{
    double    Xfrom,Yfrom,Xto,Yto;
    RECT    OutRect;
    POINT    Point,OutPoint;
    
    RectInit (&OutRect);
    Point.x = Rect->left;
    Point.y = Rect->bottom;
    OutPoint = TranPoint16 (Point,hTran);
    AddPointToRect (OutPoint,&OutRect);
    Point.y = Rect->top;
    OutPoint = TranPoint16 (Point,hTran);
    AddPointToRect (OutPoint,&OutRect);
    Point.x = Rect->right;
    OutPoint = TranPoint16 (Point,hTran);
    AddPointToRect (OutPoint,&OutRect);
    Point.y = Rect->bottom;
    OutPoint = TranPoint16 (Point,hTran);
    AddPointToRect (OutPoint,&OutRect);
    *Rect = OutRect;
    return;
}

LPSTR strupr (LPSTR txt)
{
    LPSTR c = txt;
    
    while (*c)
    {
        *c = toupper(*c);
    }
    return txt;
}
LPSTR strlwr (LPSTR txt)
{
    LPSTR c = txt;
    
    while (*c)
    {
        *c = tolower(*c);
    }
    return txt;
}
LPSTR _itoa (int i,LPSTR str, int radix)
{
    switch (radix)
    {
        case 10:
            sprintf(str,"%d",i); // converts to decimal base.
            break;
        case 16:
            sprintf(str,"%x",i); // converts to hexadecimal base.
            break;
        case 8:
            sprintf(str,"%o",i); // converts to octal base.
            break;
    }
    
    return str;
}
LPSTR _ltoa (long i,LPSTR str, int radix)
{
    switch (radix)
    {
        case 10:
            sprintf(str,"%ld",i); // converts to decimal base.
            break;
        case 16:
            sprintf(str,"%lx",i); // converts to hexadecimal base.
            break;
        case 8:
            sprintf(str,"%lo",i); // converts to octal base.
            break;
    }
    
    return str;
}

LPSTR _ultoa (unsigned long i,LPSTR str, int radix)
{
    switch (radix)
    {
        case 10:
            sprintf(str,"%ld",i); // converts to decimal base.
            break;
        case 16:
            sprintf(str,"%lx",i); // converts to hexadecimal base.
            break;
        case 8:
            sprintf(str,"%lo",i); // converts to octal base.
            break;
    }
    
    return str;
}

SQLRETURN   SQLCancel(SQLHSTMT StatementHandle)
{
    return 0;
}
SQLRETURN   SQLCancelHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle)
{
    return 0;
}
SQLRETURN   SQLCloseCursor(SQLHSTMT StatementHandle)
{
    return 0;
}
SQLRETURN   SQLFreeConnect(SQLHDBC ConnectionHandle)
{
    return 0;
}
SQLRETURN   SQLFreeEnv(SQLHENV EnvironmentHandle)
{
    return 0;
}
SQLRETURN   SQLFreeHandle(SQLSMALLINT HandleType, SQLHANDLE Handle)
{
    return 0;
}

SQLRETURN   SQLFreeStmt(SQLHSTMT StatementHandle,
                        SQLUSMALLINT Option)
{
    return 0;
}


int GetDlgItem (HWND hWndDlg,UINT Control)
{
    return 0;
}
LRESULT SendDlgItemMessage(HWND hDlg,int nIDDlgItem, UINT Msg,WPARAM wParam,LPSTR lParam)
{
    return 0;
}
void DeleteObject (HGDIOBJ handle)
{
    return;
}
unsigned int MessageBox(
                        HWND hWnd,
                        LPCSTR lpText,
                        LPCSTR lpCaption,
                        UINT uType)
{
    return 0;
}

HMENU CreateMenu(void)
{
    return 0;
}
HMENU CreatePopupMenu (void)
{
    return 0;
}
Bool  AppendMenu(HMENU hMenu,UINT uFlags,UINT_PTR uIDNewItem,LPCSTR lpNewItem)
{
    return FALSE;
}

HWND GetFocus (void)
{
    return 0;
}


Bool ConvertCoordClose (void)
{
    return FALSE;
}
Bool NeedToConvertCoord (int from, int to)
{
    return FALSE;
}
long ConvertCoord (LPDPOINT DPoint,int from, int to)
{
    return 0;
}
long ConvertCoordInit (void)
{
    return 0;
}
long ConvertAndTranCoord (LPDPOINT pPoint,HANDLE hTranFile)
{
    return 0;
}
void ConvertCoordError(long ErrNum)
{
    return;
}

void SetWindowText(HWND hWnd,LPSTR txt)
{
    return;
}
int GetWindowText (HWND hWnd,LPSTR txt,int maxchar)
{
    *txt = 0;
    return 0;
}

long LoadProjection(long nj, LPSTR NAME)
{
	return 0;
}
long TranProjection(long I, long O, double *x, double *y)
{
	return 0;
}
HANDLE STRAN2(int ID, double X1[], double Y1[], double X2[], double Y2[], int N, LPFLOAT RSQMIN, int Type, LPMNMXCORD pBounds)
{
	HANDLE rtn = 0;
	return rtn;
}

void TRANS2(double XIN, double YIN, LPDOUBLE XOUT, LPDOUBLE YOUT, HANDLE hlpTran)
{
	return;
}
void TRNPRO(double XIN, double YIN, LPDOUBLE XOUT, LPDOUBLE YOUT, HANDLE hlpTran)
{
	return;
}
void CloseTRANS2(LPHANDLE phlpTran)
{
	return;
}

HANDLE STRANBoundsToRect(LPMNMXCORD FromRect, LPRECT ToRect)
{
	HANDLE rtn = 0;
	return rtn;
}
HANDLE STRANRectToBounds(LPRECT FromRect, LPMNMXCORD ToRect)
{
	HANDLE rtn = 0;
	return rtn;
}
HANDLE STRANBoundsToBounds(LPMNMXCORD FromRect, LPMNMXCORD ToRect)
{
	HANDLE rtn = 0;
	return rtn;
}
POINT TRANDPointToPoint(HPDPOINT pDpoint, HANDLE hTran)
{
	POINT pt = { 0 };
	return pt;
}
void TranPoints(LPDPOINT FromPt, LPDPOINT ToPt, int nPt, HANDLE hTran)
{
	return;
}
HANDLE DPolyToPPoly(LPINT pnpnts, HANDLE hDPoly, HANDLE hTran)
{
	HANDLE rtn = 0;
	return rtn;
}

HANDLE ReadTranData(HFILE Fid)
{
	HANDLE rtn = 0;
	return rtn;
}

short TestFieldVal(LPGWDHEADER lpGWDHead, int FieldNum, LPSTR lpVal, short OpCode)
{
	return 0;
}
LPSTR strncpy0(LPSTR Buff, LPSTR str, size_t n)
#if ENABLETRACE
{
	GSSiEnterProg(202);
#endif
	{
		if (n)
			_fstrncpy(Buff, str, n);
		Buff[n] = 0;
		{
#if ENABLETRACE
			GSSiExitProg(202);
#endif
			return Buff;
		}
#if ENABLETRACE
	}
#endif
}
short Strip(LPSTR str, char chr)
{
	return 0;
}
int SysMonthFromSymTime(time_t systime)
{
	return 0;
}
void SubstituteDBQ(LPSTR str, LPSTR pDBQ)
{
	return;
}
Bool SLTPrepareStatement(LPSQLDATABASE pDB, LPSTR SQL)
{
	return FALSE;
}
HANDLE	OpenSLTDatabase(LPSTR Name, LPSTR SQL, short Access)
{
	HANDLE rtn = 0;
	return rtn;
}

HANDLE	OpenSLTDatabaseQuery(LPSTR Name, LPSTR SQL)
{
	HANDLE rtn = 0;
	return rtn;
}

LONGLONG GetSQLITENumRows(sqlite3nv *db, LPSTR tableName, LPSTR where)
{
	return 0;
}
void CloseSLTDatabase(LPHANDLE pHandle)
{
	return;
}
void SLTCloseCursor(LPSQLDATABASE pDB)
{
	return;
}
LPSTR GetSLTFieldData(HANDLE hDB, LPSTR SQL, LPFIELDINFO infield, Bool SingleVal, LPSHORT irc, LPFIELDINFO FirstField)
{
	LPSTR rtn = 0;
	return rtn;
}
int FetchSLTRec(LPSQLDATABASE pSQL)
{
	return 0;
}
void CloseSLTDatabaseQuery(LPHANDLE pHandle)
{
	return;
}

Bool SLTSpatialIndexCreate(sqlite3nv *db, LPSTR tableName)
{
	return FALSE;
}

Bool SLTSpatialIndexAdd(sqlite3nv *db, LPSTR tableName, LONGLONG id, LPSTR Name, LPMNMXCORD pBounds)
{
	return FALSE;
}

Bool SLTSpatialIndexCreate3D(sqlite3nv *db, LPSTR tableName)
{
	return FALSE;
}

Bool SLTSpatialIndexAdd3D(sqlite3nv *db, LPSTR tableName, LONGLONG id, LPSTR Name, LPMNMXCORD3D pBounds)
{
	return FALSE;
}

MNMXCORD SLTSpatialIndexBounds(sqlite3nv *db, LPSTR tableName)
{
	MNMXCORD rtn = { 0 };
	return rtn;
}
MNMXCORD3D SLTSpatialIndexBounds3D(sqlite3nv *db, LPSTR tableName)
{
	MNMXCORD3D rtn = { 0 };
	return rtn;
}
LPVIEWPORT SetVPFromName(LPSTR Arg2, LPBool pErr)
{
	LPVIEWPORT pvp = 0;
	return pvp;
}
Bool SetViewport(int iview)
{
	return FALSE;
}
Bool SetupViewports(HWND hWnd, HDC hDC, short CurParent, RECT rect, int Band)
{
	return FALSE;
}
short SetupViewport(RECT rect, Bool ShrinkToFit, int band)
{
	return 0;
}
void SetTrace(Bool On)
{
	return;
}
void SetShowValDB(LPSTR DBName)
{
	return;
}
void SetReadSecIndex(HGLOBAL IBTID, Bool val)
{
	return;
}
void SetPrompt(UINT PromptID, Bool SetVP)
{
	return;
}
void setMacroBrkPtHandle(int macroID, HANDLE hBreakPoints, int lnBP)
{
	return;
}
void SetLogSocketIO(Bool set)
{
	return;
}
void SetFunctionDBIn(LPSTR InLoc)
{
	return;
}
void SetFunctionDBOut(LPSTR OutLoc)
{
	return;
}

void DebugReturn(LPSTR rtnValue)
{
	return;
}
double GetNumericFieldData(HANDLE hDB, LPFIELDINFO lpField, int FunctionID, int MultiValOption, LPSTR CmdString, long iref, int Type, LPSHORT irc, LPSTR DataFileID)
{
	return 0;
}
int GetCharFieldData(HANDLE hSQL, LPFIELDINFO lpField, long iref, short FunctionID, LPSTR CmdString, LPSTR Value, int maxLen, LPSTR DataFileID, int combineOption)
{
	return 0;
}
Bool SetFieldValFromDlgItem(LPGWDHEADER lpGWDHead, HWND hWndDlg, UINT icntl, LPSTR FieldName)
{
	return FALSE;
}
Bool SetFieldValFromChar(LPGWDHEADER lpGWDHead, LPGWFLDINFO lpField, LPSTR CharVal, Bool BinMode, Bool IncrementValue, Bool ExpandValue)
{
	return FALSE;
}

Bool SetFieldValFromCharAndName(LPGWDHEADER lpGWDHead, LPSTR FieldName, LPSTR CharVal, Bool BinMode, Bool ExpandValue)
{
	return FALSE;
}

Bool SetFieldValFromLong(LPGWDHEADER lpGWDHead, LPGWFLDINFO lpGWFldInfo, long LVal)
{
	return FALSE;
}

Bool SetFieldValFromReal(LPGWDHEADER lpGWDHead, LPGWFLDINFO lpGWFldInfo, double LVal)
{
	return FALSE;
}
Bool GetFieldMinValue(LPGWFLDINFO lpGWFldInfo, LPVOID lpVal)
{
	return FALSE;
}
Bool SetFieldToMinVal(LPGWDHEADER lpGWDHead, int FieldNum)
{
	return FALSE;
}

Bool setDoPaint(Bool DoPaint)
{
	return FALSE;
}
void SetCurView(LPVIEWPORT pVP)
{
	return;
}
void SetBounds(HWND hWnd, HDC hDC)
{
	return;
}

DPOINT BasePtToScreenPtD(LPDPOINT WPoint)
{
	DPOINT pt = { 0 };
	return pt;
}
DPOINT ScreenPtDToBasePt(DPOINT WinPointD)
{
	DPOINT pt = { 0 };
	return pt;
}

HDC ScreenBufferDC(HWND hWnd, HDC hDC)
{
	return 0;
}

void ScanItemForDBVals(void)
{
	return;
}
void SaveDataToUndoFile(short Type, short UndoFileID, long len, HPSTR pData, long SeekLoc)
{
	return;
}
void CheckPointBegin(void)
{
	return;
}
void CheckPointEnd(void)
{
	return;
}
Bool CreateUndoPoint(LPSTR Name)
{
	return FALSE;
}
void RemoveUndoPoint(void)
{
	return;
}
Bool RunUserFunction(LPSTR FunctionName, LPSTR ReturnValue, short NumArgs, LPSTR *Args)
{
	return FALSE;
}
LPSTR RemoveQuotes(LPSTR str)
{
	return str;
}
void RemoveFromMacroStack(int macroID)
{
	return;
}

Bool ProcessPickedItem(int Item, short Display)
{
	return FALSE;
}

Bool ProcessErrorString(void)
{
	return FALSE;
}
RECT atorect(LPSTR Value, LPBool pErr)
{
	RECT r = { 0 };
	return r;
}
void boundstoa(LPSTR Value, LPMNMXCORD Bounds)
{
	return;
}
void lboundstoa(LPSTR Value, LPMNMXCORL Bounds)
{
	return;
}
void recttoa(LPSTR Value, RECT Rect)
{
	return;
}
void pttoa(LPSTR Value, POINT Point)
{
	return;
}
void dpointtoa(LPSTR Value, LPDPOINT pPoint)
{
	return;
}
void dpointtoatrunc(LPSTR Value, LPDPOINT pPoint)
{
	return;
}
void pointstoa(LPSTR Value, int nPoints, HANDLE hPoints, HANDLE hTran)
{
	return;
}
LPSTR ftoa(LPSTR Value, double DVal)
{
	return Value;
}
short RCURVE(double *PCX, double *PCY, double *POCX, double *POCY,
	double *PTX, double *PTY, double *RPX, double *RPY, double *CLEN)
{
	return 0;
}
POINT POINTStoPOINT(POINTS points)
{
	POINT pt = { 0 };
	return pt;
}
POINTS POINTtoPOINTS(POINT point)
{
	POINTS pt = { 0 };
	return pt;
}
DPOINT PointAtDistOnPoly(HPDPOINT pPoly, long nPoly, double Dist, LPDOUBLE pAZ, LPLONG pEndPointNum)
{
	DPOINT pt = { 0 };
	return pt;
}
/*
int pj_transform(projPJ src, projPJ dst, long point_count, int point_offset,
	double *x, double *y, double *z)
{
	return 0;
}
int pj_is_latlong(projPJ p)
{
	return 0;
}
projPJ pj_init_plus(const char * str)
{
	projPJ p = { 0 };
	return p;
}
void pj_free(projPJ p)
{
	return;
}*/
void OutFunction(int funid, LPSTR outString)
{
	return;
}
Bool OpenThemeHighlightFile(short mode)
{
	return FALSE;
}
Bool OpenHighlightList(LPSTR Name1, LPSTR Name2)
{
	return FALSE;
}
int  OpenFGDB2(LPSTR DBName, LPSTR Table, LPSTR SQL)
{
	return 0;
}
void OpenDisplayedRefs(void)
{
	return;
}
LPSTR MatchLev(LPSTR InStr, char MatchChar)
#if ENABLETRACE
{
	GSSiEnterProg(200);
#endif
	{
		short lev = 0;
		Bool    Literal = FALSE;
		char	BegLev=0, EndLev=0;

		while (*InStr)
		{
			if (Literal)
				Literal = FALSE;
			else
			{
				if (*InStr == literalChar)
					Literal = TRUE;
				else if (*InStr == MatchChar && !lev)
				{
#if ENABLETRACE
					GSSiExitProg(200);
#endif
					return (InStr);
				}
				else if (lev)
				{
					if (*InStr == BegLev)
						lev++;
					else if (*InStr == EndLev)
						lev--;
				}
				else
					switch (*InStr)
				{
					case '(':
						EndLev = ')';
						BegLev = *InStr;
						lev++;
						break;
					case '[':
						EndLev = ']';
						BegLev = *InStr;
						lev++;
						break;
					case '{':
						EndLev = '}';
						BegLev = *InStr;
						lev++;
						break;
					default:
						break;
				}

			}
			InStr++;
		}
		{
#if ENABLETRACE
			GSSiExitProg(200);
#endif
			return (0);
		}
#if ENABLETRACE
	}
#endif
}
Bool makedirectories(LPSTR Name, Bool IsDir, Bool Verify)
{
	return FALSE;
}

Bool LoadUserLib(Bool Close)
{
	return FALSE;
}

HDIB32 LoadDIB32(LPSTR lpFileName, Bool AdjustColorsToVP)
{
	HDIB32 h = 0;
	return h;
}
LPSTR LastChr(LPSTR str)
{
    LPSTR lastC = strchr (str,0);
    if (lastC != str)
        lastC--;
	return lastC;
}
void  InFunction(int funid, LPSTR inString)
{
	return;
}

void GSSiTraceLev(LPSTR str, short lev, short From)
{
	return;
}

void GSSiTrace(LPSTR str, short From)
{
	return;
}

HCURSOR GSSiSetCursor(HCURSOR hCursor)
{
	return 0;
}
Bool GSSirenamefile(LPSTR OldName, LPSTR NewName)
{
	return FALSE;
}

Bool GSSiRename(LPSTR NameFrom, LPSTR NameTo)
{
	return FALSE;
}

short GSSiRemove32(LPSTR Name)
{
	return 0;
}

int GSSiRemoveDir(LPSTR Name)
{
	return 0;
}
int	GSSiRemove(LPSTR Name)
{
	return 0;
}
int GSSiRemoveAndClear(LPSTR Name)
{
	return 0;
}
int GSSiRemove2(LPSTR Name)
{
	return 0;
}
HFILE GSSiOpenFileMem(LPSTR InName, UINT mode, UINT maxlen)
{
	return 0;
}
int GSSiMsgBox(HWND hWnd, LPSTR Mess, LPSTR Title, UINT Flag, LPSTR Position)
{
	return 0;
}
short GSSiMessageBox(int from, LPSTR Mess, LPSTR Title, UINT icon, LPSTR Position)
{
	return 0;
}
void GSSiMessageBoxEnable(void)
{
	return;
}

LONG GSSillseek(HFILE Fid, LONG loc, int opt)
{
	return 0;
}
LONGLONG GSSillseek2(HFILE Fid, LONGLONG loc, int opt)
{
	return 0;
}
/*Bool GSSiGetMessage(
	__out LPMSG lpMsg,
	__in_opt HWND hWnd,
	__in UINT wMsgFilterMin,
	__in UINT wMsgFilterMax)
{
	return FALSE;
}*/
void GSSiEndDialog(HWND hWndDlg, Bool rtn, HANDLE hSaveBM)
{
	return;
}

HFILE GSSiClose2(LPHFILE pFid)
{
	return 0;
}
void GetWindowsVersion(LPSTR Ver)
{
	return;
}

Bool GetTextString(HWND hWnd, LPSTR String, int lenstring, LPSTR Title, LPSTR ListFile, LPSTR InitVal, long AutoInc, Bool DrowDown, Bool Sorted)
{
	return FALSE;
}

Bool GetTextStringML(HWND hWnd, LPSTR String, int lenstring, LPSTR Title, LPSTR InitVal)
{
	return FALSE;
}

Bool GetTempDir(LPSTR Dir)
{
	return FALSE;
}

Bool GetSymbolName(int Desc, LPSTR Name, LPSHORT pParent, int From, LPBool pIsPar)
{
	return FALSE;
}

int GetSymbolNames(int Desc, LPHANDLE phNames, int From)
{
	return 0;
}
Bool GetPolyPoints(LPPICKDATAHEADER PickData, Bool Reverse, LPINT pnPnts, LPHANDLE pHandle)
{
	return FALSE;
}

Bool GetPolyPoints3D(LPPICKDATAHEADER PickData, Bool Reverse, LPLONG pnPnts, LPHANDLE pHandle)
{
	return FALSE;
}

short GetPolyPoints2(LPPICKDATAHEADER PickData, LPINT pnPnts, LPHANDLE pHandle, short MaxLoops)
{
	return 0;
}
int GetPolyPointsWithParts(LPPICKDATAHEADER PickData, LPLONG pnPnts, LPHANDLE phPoints, LPHANDLE phPolyPartLen)
{
	return 0;
}
LPHANDLE GetPolygonPickAccelerator(int Opt)
{
	return 0;
}
void GetPolyBoundsD2(LPDPOINT Poly, long np, LPMNMXCORD pBounds, int Type)
{
	return;
}

Bool GetOpenFileSymName(int desc, LPSTR Name)
{
	return FALSE;
}

void GetItemMinMax(LPMINMAX pMinMax, LPMNMXCORD Rect)
{
	return;
}
Bool GetImageCoord(HANDLE hBMP, LPDPOINT pWorldPoint, LPSTR DateTaken)
{
	return FALSE;
}

Bool GetFieldInfoFromName(HANDLE hDB, LPSTR FldName, LPSTR pFldType, LPSHORT pFldLen)
{
	return FALSE;
}

Bool FGDBGetFieldInfo(int iDB, int icount, LPSTR FieldName, LPINT pFieldWidth, LPINT pFieldType)
{
	return FALSE;
}

short GetFieldIDFromName(LPSTR IDName, LPOPENFILEDATA FilePtr, LPSTR Name)
{
	return 0;
}
LPVOID GetFGDBFieldData(LPOPENFILEDATA FilePtr, LPCSTR indexIN, LPHANDLE phstmt,
	LPFIELDINFO infield, Bool SingleVal, short FunctionID, short *irc,
	int NumFields, LPFIELDINFO FirstField, int singleValID)
{
	return 0;
}
Bool GetDebug(void)
{
	return FALSE;
}
Bool getDebugMacro(int macroID)
{
	return FALSE;
}

Bool GetCurrentPNDBName(LPSTR Name)
{
	return FALSE;
}

Bool GetCurrentGraphicsDBName(LPSTR Name, short Type)
{
	return FALSE;
}

Bool GetCacheDir(LPSTR Dir)
{
	return FALSE;
}

Bool GetBitmapInfoFromHandle(LPBITMAPINFOHEADER pDibInfo, HDIB32 hDib)
{
	return FALSE;
}


double getazF(FPOINT Point1, FPOINT Point2)
{
	return 0;
}
double fgetaz(FLTPOINT Point1, FLTPOINT Point2)
{
	return 0;
}
double getazl(LPOINT Point1, LPOINT Point2)
{
	return 0;
}
Bool fputstring(LPSTR lpStr, HFILE Fid)
{
	return FALSE;
}

Bool fputstring2(LPSTR lpStr, HFILE Fid)
{
	return FALSE;
}

LPSTR FirstNonBlank(LPSTR Text)
#if ENABLETRACE
{
	GSSiEnterProg(309);
#endif
	{   LPSTR rtn;

	rtn = Text;
	while (*rtn == ' ' || *rtn == '\t') rtn++;
	{
#if ENABLETRACE
		GSSiExitProg(309);
#endif
		return (rtn);
	}
#if ENABLETRACE
	}
#endif
}

DPOINT FilePtToBasePt(POINT Point)
{
	DPOINT pt = { 0 };
	return pt;
}

DPOINT FilePtToBasePtD(DPOINT Point)
{
	DPOINT pt = { 0 };
	return pt;
}

DPOINT FilePtToBasePtNP(POINT Point)
{
	DPOINT pt = { 0 };
	return pt;
}

DPOINT FilePtToBasePtNPD(DPOINT Point)
{
	DPOINT pt = { 0 };
	return pt;
}

DPOINT CopyFilePtToBasePt(POINT Point)
{
	DPOINT pt = { 0 };
	return pt;
}

LPSTR fgetstring2(LPSTR lpStr, int len, HFILE Fid)
{
	return lpStr;
}
Bool FGDBFreeStmt(int iSt)
{
	return FALSE;
}

Bool FGDBCloseCursor(HANDLE iSt)
{
	return FALSE;
}

int FetchFGDBRecord(LPOPENFILEDATA	FilePtr, int singleValID)
{
	return 0;
}
Bool ExistFile(LPSTR Name)
{
	return FALSE;
}

void EscapeFunction(Bool DoHalt)
{
	return;
}

HANDLE	EnterBlockingWindow(HWND hWndDlg)
{
	return 0;
}

DPOINT dnewptproj(DPOINT OldPoint, double AZM, double DIS)
{
	DPOINT pt = { 0 };
	return pt;
}

HDIB32 GMDestroyDIB32(HDIB32 hDib)
{
	return 0;
}
Bool DestroyDIB32(HDIB32 hDib, Bool Force)
{
	return FALSE;
}
void DeleteAllVPRegions(void)
{
	return;
}

void cwCenter(HWND hWnd, int top)
{
	return;
}

void cwCenterBelowCursor(HWND hWnd, short top)
{
	return;
}

void cwCenterInVP(HWND hWnd, short VPID)
{
	return;
}

Bool CreateInfoBoxGMD(LPSTR Name)
{
	return FALSE;
}

void CreateDigCursor(HDC hDC)
{
	return;
}
int ConvertToNewLocation(LPSTR Path, Bool DoCopy)
{
	return 0;
}
double ConvertDist (double Dist,int outUnits)
{
//char    DistUnitOpts[5][12]={"FEET","METERS","YARDS","MILES","KILOMETERS"};
    extern  long  PRJ_UNITS[MAX_PROJ];
    switch (PRJ_UNITS[1])
    {
    case PRJ_UNITS_FEET:
        switch (outUnits)
            {
            case IU_FEET:
                    return (Dist);
            case IU_METERS:
                    return Dist * FTM;
            case IU_MILES:
                    return (Dist) / 5280.0;
            case IU_YARDS:
                    return (Dist) / 3.0;
            case IU_KILOMETERS:
                    return Dist/1000 * FTM;
            }
            break;
        case PRJ_UNITS_METERS:
        case PRJ_UNITS_LATLON:
            switch (outUnits)
            {
                case IU_FEET:
                    return (Dist * MFT);
                case IU_METERS:
                    return Dist;
                case IU_MILES:
                    return (Dist * MFT) / 5280.0;
                case IU_YARDS:
                    return (Dist * MFT) / 3.0;
                case IU_KILOMETERS:
                    return Dist / 1000;
            }
            break;
    }
    return Dist;
}

double ConvertInDist (double Dist,int opt)
{
//char    DistUnitOpts[5][12]={"FEET","METERS","YARDS","MILES","KILOMETERS"};
    extern  long  PRJ_UNITS[MAX_PROJ];
    if (PRJ_UNITS[1] == PRJ_UNITS_METERS) //meters
    switch (opt)
    {
        case 1:
            return (Dist * FTM);
        case 2:
            return Dist;
        case 4:
            return (Dist * FTM) * 5280.0;
        case 3:
            return (Dist * FTM) * 3.0;
        case 5:
            return Dist*1000;
    }
    if (PRJ_UNITS[1] == PRJ_UNITS_FEET)//feet
    switch (opt)
    {
        case 1:
            return Dist;
        case 2:
            return Dist * MFT;
        case 4:
            return Dist * 5280.0;
        case 3:
            return Dist * 3.0;
        case 5:
            return Dist * MFT * 1000;
    }
    if (PRJ_UNITS[1] == PRJ_UNITS_LATLON)//latlon
    {
        DPOINT newPt;
        DPOINT zpt={0,0};

        switch (opt)
            {
            case 1:
                Dist = Dist * FTM;
                break;
            case 2:
                break;
            case 4:
                Dist = (Dist * FTM) * 5280.0;
                break;
            case 3:
                Dist = (Dist * FTM) * 3.0;
                break;
            case 5:
                Dist*=1000;
                break;
            }
        newPt = NewLatLong(0,0,Dist,0);
        Dist = ldistp (zpt,newPt);
        Dist = ArcDistance(zpt,newPt);
    }
    return Dist;
}

double ConvertAltDist(double Dist, int opt)
{
    //char    DistUnitOpts[5][12]={"FEET","METERS","YARDS","MILES","KILOMETERS"};
    extern  long  PRJ_UNITS[MAX_PROJ];
    if (PRJ_UNITS[3] == PRJ_UNITS_METERS) //meters
        switch (opt)
        {
        case 1:
            return (Dist * FTM);
        case 2:
            return Dist;
        case 4:
            return (Dist * FTM) * 5280.0;
        case 3:
            return (Dist * FTM) * 3.0;
        case 5:
            return Dist * 1000;
        }
    if (PRJ_UNITS[3] == PRJ_UNITS_FEET)//feet
        switch (opt)
        {
        case 1:
            return Dist;
        case 2:
            return Dist * MFT;
        case 4:
            return Dist * 5280.0;
        case 3:
            return Dist * 3.0;
        case 5:
            return Dist * MFT * 1000;
        }
    if (PRJ_UNITS[3] == PRJ_UNITS_LATLON)//latlon
    {
        DPOINT newPt;
        DPOINT zpt = { 0,0 };

        switch (opt)
        {
        case 1:
            Dist = Dist * FTM;
            break;
        case 2:
            break;
        case 4:
            Dist = (Dist * FTM) * 5280.0;
            break;
        case 3:
            Dist = (Dist * FTM) * 3.0;
            break;
        case 5:
            Dist *= 1000;
            break;
        }
        newPt = NewLatLong(0, 0, Dist, 0);
        Dist = ldistp(zpt, newPt);
        Dist = ArcDistance(zpt, newPt);
    }
    return Dist;
}

double ConvertDist2 (double Dist,int from, int to)
{
//char    DistUnitOpts[5][12]={"FEET","METERS","YARDS","MILES","KILOMETERS"};
    if (from == 4)
    {
        from = 1;
        Dist *= 5280;
    }
    switch (from)
    {
        case 3:
            Dist *= 3;
        case 1:
            switch (to)
            {
                case 1:
                    return (Dist);
                case 2:
                    return Dist * FTM;
                case 4:
                    return (Dist) / 5280.0;
                case 3:
                    return (Dist) / 3.0;
                case 5:
                    return Dist/1000 * FTM;
            }
        break;
        
        case 5:
            Dist *= 1000;
        case 2:
            switch (to)
            {
                case 1:
                    return (Dist * MFT);
                case 2:
                    return Dist;
                case 4:
                    return (Dist * MFT) / 5280.0;
                case 3:
                    return (Dist * MFT) / 3.0;
                case 5:
                    return Dist / 1000;
            }
        break;
    }
    return Dist;
}


double ConvertArea (double area,int opt)
{
    extern  long  PRJ_UNITS[MAX_PROJ];
//char    AreaUnitOpts[6][10]={"SQRFEET","SQRMETERS","SQRYARDS","SQRMILES","SQRKILOS","ACRES"};
    if (PRJ_UNITS[1] == 1)
    switch (opt)
    {
        case 1:
            return area;
        case 2:
            return (area * SFTSM);
        case 4:
            return (area / ((double)5280 * (double)5280));
        case 3:
            return (area/9);
        case 5:
            return ((area * SFTSM) /(double) 1000000);
        case 6:
            return ((area * SFTSM) / ACRSM);
    }
    if (PRJ_UNITS[1] == 2)
    switch (opt)
    {
        case 1:
            return (area * SMSFT);
        case 2:
            return area;
        case 4:
            return (area * (SMSFT / ((double)5280 * (double)5280)));
        case 3:
            return (area/9 * SMSFT);
        case 5:
            return (area /(double) 1000000);
        case 6:
            return (area / ACRSM);
    }
    return area;
}
SLONG ConvertCMDToNum(LPSTR CMD)
{
	return 0;
}
double ComputeProjectedAreaAreaD(HPDPOINT lpPoints, long nPnts, LPDOUBLE pPerim)
{
	return 0;
}
double ComputeProjectedAreaArea(HPPOINTS lpPoints, long nPnts, LPDOUBLE pPerim)
{
	return 0;
}
DPOINT ComputeAreaMidpoint2(HPDPOINT pPoints, long nPnts)
{
	DPOINT pt = { 0 };
	return pt;
}
DPOINT ComputeAreaMidpoint(HANDLE hPoints, long nPnts)
{
	DPOINT pt = { 0 };
	return pt;
}

double ComputeAreaAreaDH(HANDLE hPoints, long nPnts, LPDOUBLE pPerim)
{
	return 0;
}
Bool CloseFGDB(int iDB)
{
	return FALSE;
}

void CloseDisplayedRefs(void)
{
	return;
}

void CloseAllRequestedFiles(Bool FirstOnly)
{
	return;
}

Bool CheckForContinue(Bool QuitOnEscapeOnly, LPBool pQuitProcessing)
{
	return FALSE;
}

int charLevel(LPSTR pchar, LPSTR inStr)
{
	return 0;
}

short CacheAlreadyChecked(LPSTR Name, int lCacheDir, UINT Mode)
{
	return 0;
}
void btoa(Bool Val, LPSTR str)
{
	return;
}

void breakAtPos(int pos, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen, int from)
{
	return;
}

void BlowOut(LPSTR Message, LPSTR Title)
{
	return;
}

long BigWrite(HFILE Fid, LPVOID pBuf, DWORD isize, long seekloc)
{
	return 0;
}
long BigRead(HFILE Fid, LPVOID pBuf, long isize)
{
	return 0;
}
DPOINT BasePtToWinPtD(LPDPOINT WPoint)
{
	DPOINT pt = { 0 };
	return pt;
}
MNMXCORD3D atobounds3D(LPSTR Value, LPBool pErr)
{
	MNMXCORD3D rtn = { 0 };
	return rtn;
}

Bool atob(LPCSTR Value)
{
    Bool rtn = FALSE;
    if (strlen (Value) > 1)
        rtn = TRUE;
    else if (*Value == 'Y')
        rtn = TRUE;
    else if (*Value == 'T')
        rtn = TRUE;
    else if (*Value == '1')
        rtn = TRUE;
	return rtn;
}
double atobasedist(LPSTR Dist, LPBool perr)
{
	return 0;
}
int AddToMacroStack(int from, int iCurrentMacro, LPSTR File, LPHANDLE phArgs, int NumArgs)
{
	return 0;
}
void AddGraphicsFunction(HWND hWnd, int FunType, UINT StartPrompt)
{
	return;
}
void AddGraphicsCmd(HWND hWnd, LPSTR Cmd, Bool Keydef, UINT StartPrompt)
{
	return;
}

void AddBMPToCache32(LPSTR Name, HDIB32 hBMP)
{
	return;
}
HANDLE OpenGWDatabase(LPSTR Name, short Mode)
{
	return 0;
}
void CloseGWDatabase(HANDLE DBHandle)
{
	return;
}
int OpenDatabaseTable(int DBHandle, LPSTR TableName)
{
	return 0;
}
int  GWDReplaceRecord(LPGWDHEADER lpGWDHead, long length, LPSHORT IndexArray, long Offset)
{
	return 0;
}
Bool GWDFormKey(LPGWDHEADER lpGWDHead, int Index, Bool Search, long length, int Month)
{
	return FALSE;
}
HANDLE OpenComboDatabase(LPSTR Name, LPSTR SQL)
{
	return 0;
}
Bool CloseComboDatabase(HANDLE hDB)
{
	return FALSE;
}
HANDLE OpenExternalDatabase(LPSTR Name)
{
	return 0;
}
void ODBCTerminate(Bool Quit)
{
	return;
}
UINT_PTR GSSiSetTimer(HWND hWnd, UINT_PTR nIDEvent, UINT uElapse,LPVOID lpTimerFunc)
{
	return 0;
}
Bool GSSiKillTimer(HWND hWnd,UINT_PTR uIDEvent)
{
	return FALSE;
}
Bool GSSiDELETEOBJCT(HGDIOBJ hobj)
{
	return FALSE;
}
Bool GetGMDUniqueFieldValues(HANDLE DBhandle, LPCSTR SQL, int fieldindex, HANDLE hDBList)
{
	return FALSE;
}
Bool GetODBCUniqueFieldValues(int DBhandle, LPCSTR SQL, LPSTR name, int length,
	HANDLE hDBList)
{
	return FALSE;
}
Bool GetPNData(HANDLE hDB, long Refno)
{
	return FALSE;
}
LPVOID GetExternalFieldData(LPOPENFILEDATA FilePtr, LPCSTR index, LPVOID *hstmt,
	LPFIELDINFO Field, Bool SingleVal, short FunctionID, LPSHORT irc,
	int NumFields, LPFIELDINFO FirstField)
{
	return 0;
}
LPFIELDINFO GetFieldInfo(HANDLE TBLHandle, Bool First, short FileType, LPBool pHaveNonStandardFields)
{
	return 0;
}
int GetDictSymbolNumber(LPSTR SymName)
{
	return 0;
}
Bool GetDictSymName(int idesc, LPSTR Name)
{
	return FALSE;
}
long FillGWDData(LPGWDHEADER lpGWDHead, long Offset)
{
	return 0;
}
RETCODE	FetchODBCRecord(LPOPENSQLDATA	SQLPtr)
{
	return 0;
}
Bool DoPaint(void)
{
	return FALSE;
}
HANDLE CreateUniqueList(int length, LPSTR Name)
{
	return 0;
}
void CloseSymDict(void)
{
	return;
}
void CloseExternalDatabase(int DBHandle)
{
	return;
}
void ClearCurVals(LPOPENFILEDATA FilePtr)
{
	return;
}
Bool ConvertFieldValFromChar(LPGWDHEADER lpGWDHead, int FieldNum, LPSTR CharVal, LPSTR lpVal)
{
	return FALSE;
}
HGLOBAL BT_OPEN(LPSTR FNAME, time_t TIME, int ACCESS, int DATE)
{
	return 0;
}
int BT_CLOSE(HGLOBAL IBTID)
{
	return 0;
}
int BT_FIND(HGLOBAL IBTID, LPSTR KEY, int POSITION, int COND, LPSTR DATA)
{
	return 0;
}
int BT_PUT(HGLOBAL hBTree, LPSTR KEY, LPSTR DATA)
{
	return 0;
}
Bool AddToODBCParms(LPSTR Begin, LPSTR End)
{
	return FALSE;
}
void CloseUserDefinedAddress(Bool Opened)
{
	return;
}
Bool CreateStnameFilesUpdate(void)
{
	return FALSE;
}
int AppendFile(LPSTR File, LPSTR Line)
{
	return 0;
}
LPSTR AddCommas(LPSTR VCBuff)
{
	return VCBuff;
}
long GSSiLength(LPSTR Name)
{
	return 0;
}
Bool IsInteger(LPSTR str)
{
	return FALSE;
}
Bool IsReal(LPSTR str)
{
	return FALSE;
}
Bool OpenConfig(HWND hWnd, HDC hDC)
{
	return FALSE;
}
void UnallocateConfig(void)
{
	return;
}
Bool CreateStatusWind (HWND hWnd,int nStatusBars,LPSTR Title)
{
    return TRUE;
}
Bool StatusWindowUpdate (LPSTR Title, LPSTR Mess, LONGLONG Tot, LONGLONG Done)
{
    return TRUE;
}
void StatusExtraInfoUpdate(LPSTR mess)
{
    return;
}
Bool StatusWindowUpdate2(LPSTR Mess, LONGLONG Tot, LONGLONG Done)
{
    return TRUE;
}
Bool DestroyStatusWindow(long Macro)
{
    return TRUE;
}

Bool rread(LPSTR str, LPDOUBLE lpRval, LPINT lpNdp)
#if ENABLETRACE
{
	GSSiEnterProg(230);
#endif
	{
		LPSTR lpEnd, lpDp;

		*lpRval = strtod(str, &lpEnd);
		if (*lpEnd)
		{
#if ENABLETRACE
			GSSiExitProg(230);
#endif
			return FALSE;
		}
		lpDp = _fstrchr(str, '.');
		if (lpDp)
			*lpNdp = (int)(lpEnd - lpDp);
		else
			*lpNdp = 0;
		{
#if ENABLETRACE
			GSSiExitProg(230);
#endif
			return TRUE;
		}
#if ENABLETRACE
	}
#endif
}
void TranToParcelPoints(LPDOUBLE XIN, LPDOUBLE YIN, LPDOUBLE  XOUT, LPDOUBLE  YOUT, LPPARCELTRAN pTran)
{
    return;
}
void DebugShowLine (LPDPOINT p1,LPDPOINT p2)
{
    return;
}
DPOINT BasePtToFilePtD (DPOINT WPoint)
{
    return WPoint;
}
HCURSOR LoadCursor(HINSTANCE hInstance,LPCSTR lpCursorName)
{
    HCURSOR cur = 0;
    return cur;
}
void hmemset (HPSTR out,char in,DWORD len)
{
    memset (out,in,len);
    return;
}
long Factorial (long value)
{
    long    n=0;
    
    while (value--)
        n+=value;
    return  n;
}
double MinAngleToTheRight (double AZ1,double AZ2)
{
    double AZDiff;
    
    if (AZ1 < AZ2)
        AZDiff = AZ2 - AZ1;
    else
        AZDiff = AZ2 + (TWOPI - AZ1);
    return AZDiff;
}

void RectInit (LPRECT pMinMax)
{
    pMinMax->left=INT_MAX;
    pMinMax->top=INT_MAX;
    pMinMax->bottom=INT_MIN;
    pMinMax->right=INT_MIN;
    return;
}
void AddPointToRect(POINT Point, LPRECT pBounds)
{
    pBounds->left = min(pBounds->left, Point.x);
    pBounds->right = max(pBounds->right, Point.x);
    pBounds->top = min(pBounds->top, Point.y);
    pBounds->bottom = max(pBounds->bottom, Point.y);
    return;
}

void AddDPointToRect(DPOINT Point, LPRECT pBounds)
{
    int x = IDNINT(Point.x);
    int y = IDNINT(Point.y);
    pBounds->left = min(pBounds->left, x);
    pBounds->right = max(pBounds->right, x);
    pBounds->top = min (pBounds->top,y);
    pBounds->bottom = max (pBounds->bottom,y);
    return;
}
/*int test(int in)
{
	char str[256] = "[VAR]=1;";
	// TODO: Place code here.

	CreateVarSpace(VARSPACE_GLOBAL);

	ExpandText(str);
	strcpy(str, "IF([VAR]>2){[VALUE]=5;}ELSE{[VALUE]=$FLT([VAR]+10);};");
	ExpandText(str);
	strcpy(str, "[VALUE]");
	ExpandText(str);
	DestroyVarSpace((HANDLE)-1);
	//_CrtDumpMemoryLeaks();
	return 0;

}*/
