#ifndef shr_h
#define shr_h
#include "CCodeTypes.h"
#include "bigmem.h"
#include "gssitype.h"
#include "COMPUTE.H"
#include "DIBAPI.H"
#include "TileGraphics.h"

//include <windowsx.h>
#ifdef	_WIN32_WCE
#include <winuser.h>
#endif
#include <float.h>   
#include <math.h>
#include <stdio.h> 
//#include <io.h>
//#include <dos.h>
//#include <conio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
//#include <shlwapi.h>
#include <limits.h>
#include <memory.h>
#include <stdlib.h>     
#include <fcntl.h>
//#include <direct.h>
#include <stdio.h>
#include <ctype.h>
//#include <winsock2.h>
//#include <dlgs.h>
//#include <print.h>
//#include <sql.h>
//include <sqlext.h>
//#include <mmsystem.h> 
//#include <shellapi.h>
#include <assert.h>
//#include <malloc.h>
//#include <dde.h>
//#include <ddeml.h>
#include <sys/types.h>
#include <sys/stat.h>
//#include <share.h>
#include <fcntl.h>
//#include "FreeImage.h"
//#include <process.h>
//include <compobj.h>
//include <scode.h>
//#include <bios.h>

//#include <tchar.h>
//#include <strsafe.h>
//#include <toolhelp.h>
#include <sqlite3.h>
// For C compatibility --------------------------------------------------------

#ifdef __cplusplus
#define FI_DEFAULT(x)	= x
#define FI_ENUM(x)      enum x
#define FI_STRUCT(x)	struct x
#else
#define FI_DEFAULT(x)
#define FI_ENUM(x)      typedef int x; enum x
#define FI_STRUCT(x)	typedef struct x x; struct x
#endif

#define PASCAL
// Bitmap types -------------------------------------------------------------

FI_STRUCT(FIBITMAP) { void *data; };
FI_STRUCT(FIMULTIBITMAP) { void *data; };



FI_ENUM(FREE_IMAGE_FORMAT) {
    FIF_UNKNOWN = -1,
    FIF_BMP = 0,
    FIF_ICO = 1,
    FIF_JPEG = 2,
    FIF_JNG = 3,
    FIF_KOALA = 4,
    FIF_LBM = 5,
    FIF_IFF = FIF_LBM,
    FIF_MNG = 6,
    FIF_PBM = 7,
    FIF_PBMRAW = 8,
    FIF_PCD = 9,
    FIF_PCX = 10,
    FIF_PGM = 11,
    FIF_PGMRAW = 12,
    FIF_PNG = 13,
    FIF_PPM = 14,
    FIF_PPMRAW = 15,
    FIF_RAS = 16,
    FIF_TARGA = 17,
    FIF_TIFF = 18,
    FIF_WBMP = 19,
    FIF_PSD = 20,
    FIF_CUT = 21,
    FIF_XBM = 22,
    FIF_XPM = 23,
    FIF_DDS = 24,
    FIF_GIF = 25,
    FIF_HDR = 26,
    FIF_FAXG3 = 27,
    FIF_SGI = 28,
    FIF_EXR = 29,
    FIF_J2K = 30,
    FIF_JP2 = 31,
    FIF_PFM = 32,
    FIF_PICT = 33,
    FIF_RAW = 34,
    FIF_WEBP = 35,
    FIF_JXR = 36
};
/** Image type used in FreeImage.
 */
FI_ENUM(FREE_IMAGE_TYPE) {
    FIT_UNKNOWN = 0,	//! unknown type
    FIT_BITMAP = 1,	//! standard image			: 1-, 4-, 8-, 16-, 24-, 32-bit
    FIT_UINT16 = 2,	//! array of unsigned short	: unsigned 16-bit
    FIT_INT16 = 3,	//! array of short			: signed 16-bit
    FIT_UINT32 = 4,	//! array of unsigned long	: unsigned 32-bit
    FIT_INT32 = 5,	//! array of long			: signed 32-bit
    FIT_FLOAT = 6,	//! array of float			: 32-bit IEEE floating point
    FIT_DOUBLE = 7,	//! array of double			: 64-bit IEEE floating point
    FIT_COMPLEX = 8,	//! array of FICOMPLEX		: 2 x 64-bit IEEE floating point
    FIT_RGB16 = 9,	//! 48-bit RGB image			: 3 x 16-bit
    FIT_RGBA16 = 10,	//! 64-bit RGBA image		: 4 x 16-bit
    FIT_RGBF = 11,	//! 96-bit RGB float image	: 3 x 32-bit IEEE floating point
    FIT_RGBAF = 12	//! 128-bit RGBA float image	: 4 x 32-bit IEEE floating point
};


#define ORIGINALPROC(hWnd) (WNDPROC) MAKELONG( \
    GetProp(hWnd, "PrLO"), GetProp(hWnd, "PrHI") )

#define RECTWIDTH(lpRect)     ((lpRect)->right - (lpRect)->left)
#define RECTHEIGHT(lpRect)    ((lpRect)->bottom - (lpRect)->top)

#define	OF_CREATE_NODELETE	0x1111      

#define UP_3D		1
#define DOWN_3D		2
#define	NO_3D		3

#define VARSPACE_LOCAL	1
#define VARSPACE_GLOBAL	2

#define GSSI_REINITDIALOG       0x5110  
#define GSSI_ADDGF 0x5111
#define GSSI_REPOSITION 0x5112

#define GSSI_GPSX	0x5113
#define GSSI_GPSY	0x5114
#define GSSI_GPSZ	0x5115
#define GSSI_GPSwnd	0x5116
#define GSSi_DimMenu 0x5117
#define GSSI_GPS	0x5118

#define GSSI_GMEDITCOMPLETE 0x5119


#define MK_DIGITIZER_BUTTON	    0x0020

#define GetWValue(rgb)  ((BYTE)((rgb)>>24))
#define RGBW(r,g,b,w)   ((COLORREF)(((BYTE)(r)|((WORD)(g)<<8))|(((DWORD)(BYTE)(b))<<16)|(((DWORD)(BYTE)(w))<<24)))

typedef struct {double a,b,c,d,e,f,xc,yc;} TRN; 
typedef TRN FAR *LPTRN;

#define JOURNAL_BLOCK_SIZE	1024	

#define  CFTCM   2.83170164938e-2
#define  CMCFT   3.5314454833912e1
#define  CMCYD   1.3079427716264e0
#define  CYDCM   7.645594553315e-1
#define  FTM     3.04800609601219e-1
#define  HAFSEC    1.388888888888889e-5
#define  HALFPI    1.570796326794896e0
#define  MFT       3.280833333333333e0
#define  PIHALF    4.712388980384689e0
#define  PY        3.141592653589793e0
#define  RADDEG    1.74532925199433e-2
#define  DEGRAD    5.729577951308232e1
#define  SFTSM     9.2903411613274e-2
#define  SMSFT     1.076386736111111e1
#define  TWOPI     6.283185307179586e0
#define  ACRSM     4046.872609874253e0  
#define  INCHES_PER_CM  0.3937e0
#define  MAX_GAP_BTWN_LINKS    0.1e0 
#define  ZERO$  -2146450000 
#define  TMPRF$ -2146483000   
#define	 NULLREF 0
#define RADtoDEG 57.295779513082322
#define DEGtoRAD 0.017453292519943296

#define  GOOD_SOUND 1
#define  BAD_SOUND  2  

#define BA_EXPANDTEXT	1
#define BA_FUNCTION		2
#define BA_BEGINBLOCK	3
#define BA_NEXTPOS		4
#define BA_NEXTLINE		5
#define BA_NEXTBP		6
#define BA_SHOWFUN		7
#define BA_RETURN		8

#define OFS_MAXPATHNAMEGM 256
typedef struct _OFSTRUCTGM {
	BYTE cBytes;
	BYTE fFixedDisk;
	WORD nErrCode;
	WORD Reserved1;
	WORD Reserved2;
	CHAR szPathName[OFS_MAXPATHNAMEGM];
} OFSTRUCTGM, *LPOFSTRUCTGM, *POFSTRUCTGM;

int testVars (int i);

HWND GetFocus (void);
HWND WindowExists(HWND hWnd);
HWND FindWindowByName (LPSTR WindowName);
HWND GetTopParent(HWND	hWnd);
void ShowHideWindows(LPSTR WindowName, UINT fun);
void ShowHideChildren(HWND hWndPar, UINT fun);

void SetWindowText(HWND hWnd,LPSTR txt);
int GetWindowText (HWND hWnd,LPSTR txt,int maxchar);
void SetSQLiteErrFile(LPSTR errFile);

HBITMAP GetToolBitmap (LPSTR BMPath);
Bool WaitForProcessToEnd (DWORD pID,LPINT pMaxWait);
//void UnixTimeToFileTime(time_t t, LPFILETIME pft);
//void UnixTimeToSystemTime(time_t t, LPSYSTEMTIME pst);
long long HighLowToint64(DWORD HighPart,DWORD LowPart);
//long long  FileTimeToint64(FILETIME ft);
long Time64toTime32 (time_t time64);
int	GSSiEnterProg (int progid);
int	GSSiExitProg (int progid);
int SetLastMessage (long mes);
int checkcpl (int i);
int abcd (int i);
Bool ValidateLicense(HWND hWnd);
COLORREF ConvertColor (COLORREF Color,int UseHalfTone);
Bool CopyFileExtended (LPSTR ToFile,LPSTR FromFile);
Bool CopyFileToCache (LPSTR ToFile, LPSTR FromFile);
int DisplayBitmapOnButton (HDC hDCBtn,LPRECT pRectBtn,HBITMAP hBM);
//void HandleFocusState(LPDRAWITEMSTRUCT lpdis);
void Draw3DFrame(HWND hWnd, int iStyle);
int TB_SetupTable(HWND hWndDlg,HWND Tablehwnd,HWND Tableheadhwnd,HWND Tablefoothwnd,LPARAM rows,int cols,
							int * colwidths,int interspace,int usersize);
int   TB_FitToWindow(HWND tblhwnd,int numcols);
int   TB_BestFit(HWND tblhwnd,int extra,LPARAM count,FARPROC fp);
int  TB_RedrawTable(HWND hWnd);
int GetDlgItem (HWND hWndDlg,UINT Control);
LRESULT SendDlgItemMessage(HWND hDlg,int nIDDlgItem, UINT Msg,WPARAM wParam,LPSTR lParam);
POINT POINTStoPOINT(POINTS points);
POINTS POINTtoPOINTS(POINT point);    
Bool FAR PASCAL DATAFILEMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam, UINT cntlSQL,
                                UINT cntlSET_FILE, UINT cntlDATABASE_LIST, UINT cntlTABLE_NAMES,UINT cntlTABLE_NAMES_TITLE,
                                LPUINT pcntlFIELD_NAMES,int NumFieldLists,
                                LPSTR DataFile, short *DataFileType, HANDLE *hThemeDB,
                                Bool *pFieldListIsCB, Bool WantBrackets);
Bool FAR PASCAL FIELDSMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam);
Bool FAR PASCAL CENFIELDSMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam);
void ClientRectToScreenRect (HWND hWnd,LPRECT pRect);
void ScreenRectToClientRect (HWND hWnd,LPRECT pRect);
Bool SetDynDlgData (HWND hWndDlg,LPSTR Name,LPUINT pcntls,short lncntls);
Bool ProcessDlgEdit (HWND hWndDlg,HWND hWndEdit,WPARAM wParam,LPARAM lParam); 
Bool ProcessDynEdit (HWND hWndDlg,HWND hWndEdit,WPARAM wParam,LPARAM lParam); 
Bool ShowDlgUpdateOptions (HWND hWndEdit,HWND hWndInput);
Bool ShowDynDlgUpdateOptions (HWND hWndEdit,HWND hWndInput);
Bool GetDynDlgHandle (HWND hWndDlg,LPHANDLE phDynDlgControls);
Bool WriteDynDlgData (HWND hWndDlg);
//extern	Bool CALLBACK EnumCtrlProc(HWND hCtrl,LONG lParam);
//extern	Bool CALLBACK EnumCtrlProcDynDialog(HWND hCtrl,LONG lParam);
LONG FAR PASCAL Draw3DDownDynDialog(HWND hWnd, unsigned uiMsg,WORD wParam, LONG lParam);
LONG FAR PASCAL Draw3DUpDynDialog (HWND hWnd, unsigned uiMsg,WORD wParam, LONG lParam);
LONG FAR PASCAL Draw3DDown(HWND hWnd, unsigned uiMsg,WORD wParam, LONG lParam);
LONG FAR PASCAL Draw3DUp (HWND hWnd, unsigned uiMsg,WORD wParam, LONG lParam);
LONG FAR PASCAL ComboColor(HWND hWnd, UINT uiMsg,WORD wParam, LONG lParam);
LONG FAR PASCAL ComboColorDynDialog(HWND hWnd, UINT uiMsg,WORD wParam, LONG lParam);
USHORT	AddStringToList (LPSTR str,LPSTR pStrings,LPUSHORT plen);
Bool GetFieldValFromSetList (LPSTR List,LPSTR Name,LPSTR Val);
Bool rread (LPSTR str, LPDOUBLE lpRval, LPINT lpNdp);
double dread (LPSTR str, int nbytes);
long ldread (LPSTR str, int nbytes);
void RWRITE (double RVAL, int NDP, LPSTR OutLoc);
void RWRITEZ (double RVAL, int NDP, int len,LPSTR OutLoc); 
short Strip(LPSTR str, char chr);
LPSTR ReplaceChar (LPSTR str, char from, char to);
LPSTR RemoveDoubleQuotes (LPSTR str);
LPSTR RemoveQuotes(LPSTR str);
LPSTR ConvertCharBtwnDoubleQuotes(LPSTR str, char from, char to);
short FillRectPoly(HDC hDC, LPRECT Rect, COLORREF Color);
short DrawRectPoly(HDC hDC, LPRECT Rect, HPEN hPen);
int FillRectColor (HDC hDC,LPRECT Rect,COLORREF Color);
Bool LoadGlobalInit (LPSTR File,Bool First);
HGLOBAL GSSiGlobAlloc(int From,UINT fuAlloc, long cbAlloc);
HGLOBAL GSSiGlobalReAlloc (USHORT From,HGLOBAL hGlob, long cbAlloc,UINT fuAlloc);
void GSSiGlobFree (LPHANDLE pHandle); 
void GSSiGlobUlFree (LPHANDLE pHandle);    
void SECLIN8(const double *X1,const double *Y1,const double *A1,const double *X2,
             const double *Y2,const double *A2,double *X3,double *Y3,short *K);
double  AZDF(double AZC, double AZP, double RL);
double DSIGN(const double Value, const double Sign);
//void ERROr( long istat, char *message);
LPSTR LastChr (LPSTR str);
short FillList (HWND hWndDlg,UINT Control,LPSTR file,LPSTR DefaultVal,LPRECT pRect);
short FillCBList (HWND hWndDlg,UINT Control,LPSTR file, short InitVal,LPSTR DefaultVal);
UINT ItemInList (int i,UINT nElements,HANDLE hElements);
Bool GetListValue (LPSTR file, long ID, LPSTR Val);
long GetListNum (LPSTR file, LPSTR Val);
void ShowProcessingMessage (LPSTR Mess); 
void ClearProcessingMessage (void);
Bool GetCacheFile (LPSTR UseFile, LPSTR DiskFile, Bool Add, HWND StatusWnd);
short DeleteCacheDir (void);
short GetCacheInfo (LPSTR CacheDir);
Bool RemoveCacheFile (LPSTR File);
short DeleteDirAndContents (LPSTR Name);
short IsValidDir(LPSTR Name); 
void GSSisplitpath (LPSTR InPath,LPSTR Drive,LPSTR Dir,LPSTR Leaf,LPSTR Ext);
LPSTR FilePart(LPSTR File, LPSTR Part);
long SearchFilesInDir (LPSTR CurDir, LPSTR Ext, HFILE OutFile,LPLONG TotFiles,LPSTR WildCard,int Lev,Bool WantSub,Bool fileNameOnly);
long SearchDirectoriesInDir (LPSTR CurDirIN, HFILE OutFile,LPLONG TotFiles,LPSTR WildCard,int Lev);
int DlgDirList32 (HWND hWndDlg, LPSTR cType, int LBCNTL, int CurrentDirCNTL, UINT Flags);
Bool ExistFile(LPSTR Name);
int GetPathType(LPSTR InName);
int GetPathType2(LPSTR InName);
short FileType(LPSTR Name);
short FileType_old(LPSTR Name);
Bool IsLocalFile(LPSTR Name);
HANDLE GetFilesToClose (HANDLE hSQL);
Bool DeleteFilesInList (HANDLE hList);
void Sound (short Type);
void SetTrace (Bool On); 
void TraceInWindow (LPSTR str);
void GSSiTrace (LPSTR str,short From);
void GSSiTraceLev (LPSTR str,short lev,short From);
Bool FileErrMess (HFILE Fid,LPSTR Name,LPOFSTRUCTGM pOFStruct,UINT Mode);
HFILE OpenFileGM(
	LPCSTR lpFileName,
	LPOFSTRUCTGM lpReOpenBuff,
	UINT uStyle
	);
Bool FileOpenForWrite (HFILE Fid);
HFILE OpenFileGSSi (LPSTR Name,LPOFSTRUCTGM pOFStruct,UINT opt,UINT ShareOpt);
HFILE GSSiOpenFile (LPSTR Name,LPOFSTRUCTGM pOFStruct,UINT Mode);
Bool EditLastTextFile (void);
Bool EditLastMenuFile (void);
LPSTR GetLastPathname (void);
LPSTR GetLastAccessedFile (void);
HFILE GSSiClose (HFILE Fid);
HFILE GSSiClose2 (LPHFILE pFid);
int StoreTestToProduction(LPSTR testDir, int option);
HFILE OpenTempNamedFile (void);
//int GSSifstat (int Fid, struct _stati64 * pstat);
//Bool GSSifileinfo (int Fid, LPBY_HANDLE_FILE_INFORMATION pstat);
Bool CloseAndDeleteFile (LPHFILE pFid);
HFILE LogOpenFilesOpen (UINT Mode,HFILE Fid,LPOFSTRUCTGM pOFStruct);
void LogOpenFilesClose (HFILE Fid);
Bool RequestFileClose (HFILE Fid);  
void CloseAllRequestedFiles (Bool FirstOnly); 
void DumpOpenFiles (LPSTR File);
HFILE FileAlreadyOpen (LPSTR Name,UINT Mode,LPOFSTRUCTGM pOFStruct);
Bool GSSiChangeLength (HFILE Fid,INT64 NewLength);
void CreateFidSmall (void);
void CloseFidSmall (void);
Bool GMEdit (HWND hWnd,LPSTR file);
void GMEditReturn(void);
void GMEditSetFile(LPSTR file, LPSTR bpid,int bploc);
void GMEditGetFile(LPSTR file);
Bool EditTextFile(HWND hWnd, LPSTR Name);
void CloseVars (void);
void GMDFieldTypeToSQL (LPSTR gmd,LPSTR sql);
void SQLFieldTypeToGMD (LPSTR sql,LPSTR gmd);
short OpenDataFile (LPSTR InName, LPSTR SQL, short Access, HANDLE *hDB);
HANDLE	OpenSLTDatabase(LPSTR Name, LPSTR SQL, short Access);
HANDLE	OpenSLTDatabaseQuery(LPSTR Name, LPSTR SQL);
INT64 GetSQLITENumRows(sqlite3 *db, LPSTR tableName, LPSTR where);
void CloseSLTDatabase(LPHANDLE pHandle);
void SLTCloseCursor(LPSQLDATABASE pDB);
LPSTR GetSLTFieldData(HANDLE hDB, LPSTR SQL, LPFIELDINFO infield, Bool SingleVal, LPSHORT irc, LPFIELDINFO FirstField);
int FetchSLTRec(LPSQLDATABASE pSQL);
Bool SLTPrepareStatement(LPSQLDATABASE pDB, LPSTR SQL);
void CloseSLTDatabaseQuery(LPHANDLE pHandle);
HANDLE	OpenLISTVARDatabase (LPSTR Name);
Bool SLTSpatialIndexCreate(sqlite3 *db, LPSTR tableName);
Bool SLTSpatialIndexAdd(sqlite3 *db, LPSTR tableName, INT64 id, LPSTR Name, LPMNMXCORD pBounds);
Bool SLTSpatialIndexCreate3D(sqlite3 *db, LPSTR tableName);
Bool SLTSpatialIndexAdd3D(sqlite3 *db, LPSTR tableName, INT64 id, LPSTR Name, LPMNMXCORD3D pBounds);
MNMXCORD SLTSpatialIndexBounds(sqlite3 *db, LPSTR tableName);
MNMXCORD3D SLTSpatialIndexBounds3D(sqlite3 *db, LPSTR tableName);
void DecodeSHPParam(LPSTR str, LPSTR cDesc, LPSTR cIF, LPSTR cColor, LPSTR cWidth, LPSTR cRot);

Bool GetCurrentPNDBName (LPSTR Name);
Bool GetCurrentGraphicsDBName (LPSTR Name,short Type);
int GetNumDBFields (HANDLE hDB);
Bool GetNextPipeDelimitedValue (LPSTR str,LPINT pPos,LPSTR Value);
Bool SetSQLDatabaseFields (LPSTR Name);
HANDLE GetOpenDatabaseFromID (LPSTR id);
Bool CloseDataFile (Bool Final,HANDLE *hDB);
HANDLE GetDBHandleFromSQL (HANDLE hSQL);
Bool GetFieldInfoFromName (HANDLE hDB,LPSTR FldName,LPSTR pFldType,LPSHORT pFldLen);
Bool FetchDBRec (HANDLE hSQLPtr);
int GetDBPos(HANDLE hSQLPtr);
Bool SaveDBRec (HANDLE hSQLPtr);
Bool SetGMDField (HANDLE hSQLPtr,LPSTR Name,LPSTR Value);
HANDLE GetDBByIDName (LPSTR IDName);
short WantGMDRecord (LPOPENFILEDATA FilePtr,LPOPENSQLDATA SQLPtr,LPGWDHEADER lpGWDHead,short cond,Bool HaveOtherFields);
short ProcessDelimTextHeader(LPSTR INstr, LPSTR File, HFILE Fid, LPHANDLE phDLT, char InDelim, LPSTR IDName);
Bool GetDelimTextData(LPSTR str,HANDLE hDLT,int maxline);
Bool GetDLTVarName (int ivar,HANDLE hDLT, LPSTR Name);
HANDLE	GetDLTVarHandle (int ivar,HANDLE hDLT);
Bool UpdateGlobalFile (LPSTR RptFile,LPSTR VarName,LPSTR str);
HANDLE FindVar (LPCSTR Name);
void AddToVarNameTable (LPCSTR Name);
int	GetParmLoc (int MaxParm,char delim,LPSTR str,LPSTR *pLoc);
void CreateInternalGlobals (void);
void ListGlobals (HWND hWndDlg,WORD Control,Bool Expand);
void dumpvars (LPSTR Name);
HANDLE	AllocateVar (LPSTR Name);
HANDLE  AllocateTypeVar (LPCSTR Name,short Type,Bool Save);
void UpdateVarHandle (HANDLE OldHandle,HANDLE NewHandle);
void SetVarSaveStatus (LPSTR Name,Bool Save);
Bool GetVarSaveStatus (LPSTR Name);
void SetUDIValue (LPSTR Name, LPSTR Value);
void SetUDIValueLen (LPSTR Name, LPSTR Value, short len);
void SetGlobalValue (LPCSTR InName, LPSTR InValue);
void SetGlobalValue4(LPCSTR InName, LPSTR InValue, Bool Raw, LPBREAKPOINT pBrkPt, int bpOffset, int bplen);
void SetGlobalValue2 (HANDLE handle, LPSTR Value, short Index);
void SetGlobalValue3 (LPSTR Name, LPSTR Value, short Index, Bool FoundLit);
void SetGlobalValueLen (LPSTR Name, LPSTR Value, short len);
void SetGlobalValueReal (LPCSTR Name, double val);
void SetGlobalValueLong (LPCSTR Name, long val);
void SetGlobalValueHandle (LPCSTR Name, HANDLE val);
void SetGlobalValueDPoint (LPCSTR Name, DPOINT Point);
void SetGlobalValueBounds (LPCSTR Name, LPMNMXCORD pBounds);
void SetGlobalValueBool (LPCSTR Name, Bool val);
void SetGlobalValueRect (LPCSTR Name, RECT Rect);
Bool SetGlobalFromCheckBox (HWND hWndDlg,UINT Control,LPSTR VarName);
int SetGlobalFromTextBox (HWND hWndDlg,UINT Control,LPSTR VarName,Bool ConvertReturns);
void SetVarChangeTimes (short opt);
HANDLE GetOpenHandleFromID (LPSTR ID,int WantType);
void CheckOpenDataFiles (void);
int GetValFromOpenFiles (LPSTR VarName,LPSTR Value,int maxlval);
void SetDLGList (HWND hWndDlg,UINT dlgList);
void SetUseOnlyOneDBHandle (HANDLE handle);
void CloseMacroFiles (long ThisMacro);
Bool GetFieldDefFromOpenFiles (LPSTR VarName,LPFIELDINFO lpField);
Bool AddToOpenFileList (HANDLE hFile);
void ExpandGlobalRaw (LPSTR VarName,Bool AddEscapes,LPSTR Value, short maxlen);
void RemoveFromOpenFileList (HANDLE hFile);
LPOPENFILEDATA InOpenFileList (LPSTR Name,int Type,int Access);
HANDLE SaveValue (void);
void SetValue (LPCSTR value);
void RestoreValue (HANDLE hSaveValue);
LPSTR ExpandText (LPSTR InText);
LPSTR ExpandTextDB(LPSTR InText, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
LPSTR ExpandText2 (LPSTR InText);
void ProcessText (LPCSTR InText);
void ProcessTextDB(LPSTR InText, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
void ProcessGlobal(LPSTR Global);
HANDLE ProcessIF (LPSTR InLoc,LPBool pErr);
int charLevel(LPSTR pchar, LPSTR inStr);
LPSTR MatchLev(LPSTR InStr, char MatchChar);
short NumMatchChar (LPSTR str1,LPSTR str2,int maxchar);  
Bool StringEndsWith (LPSTR str,LPSTR endstr);
Bool ResetFileChangeTime (HANDLE hDB);
Bool GetFileChangeTime (VARPNT VarPtr);
Bool GetVal (LPSTR VarName, LPSTR OutStr);
void RestoreScreenRect (HDC hDC, HBITMAP hSavedBM, RECT Rect, RECT NewRect);
void TRAN (void *source, void *dest, size_t count);
long  NCHK(LPSTR NAME,  long i,  long PART_LN);
void  STRIPR(LPSTR NAME, int *NLEN,LPSTR out_with,  int llen); 
long  IREAD (LPSTR NAME, long NUMDIG,long *IRC);  
Bool IWRITE (long ival,LPSTR str ,short len);  
Bool IWRITEZ (long ival,LPSTR str ,short len);
LPSTR REPLAC (LPSTR STRING, LPCSTR OLD, LPCSTR NEW, int MAXLEN);
void RestoreScreen (HDC hDC, HBITMAP hSavedBM, RECT Rect);
void RestoreScreen2 (HDC hDC, HANDLE hSavedScreen,long ID,Bool Clip);
HBITMAP SaveScreen (HDC hDC, RECT Rect);   
HANDLE SaveScreen2 (HWND hWnd,HDC hDC, RECT Rect, LPVOID pVP,LPLONG pID); 
void DestroySavedScreen (LPHANDLE hSavedScreen,long ID);
void RegisterSavedScreen (HANDLE hSavedScreen);
void UnRegisterSavedScreen (HANDLE hSavedScreen);
Bool ScreenIsRegistered (HANDLE hSavedScreen,long ID);
void ClearSavedScreens(HWND hWnd,LPVOID pVP,LPRECT pRect);
void ResaveSavedScreens(void);
void dumpmemdc(HDC hdc);
void wantnextblt(void);
void SetBit (int ibit, LPSTR lpBytes, Bool setto);
void SetBit2 (int ibit, LPSTR lpBytes, Bool setto);
Bool GetBit (int ibit, LPSTR lpBytes);
Bool GetBitH (long ibit, HPSTR lpBytes);
void SetBitH (long ibit, HPSTR lpBytes, Bool setto);
void GetRunDate (LPSTR RunID, LPSTR Date);
COLORREF SetColor (LPSTR pColor);
long GSSifilelength(HFILE fid);
long GSSifilelengthF(FILE *fid);
long BigReadF(FILE *fid, LPVOID pmem, long len);
long BigWriteF(FILE *fid, LPCSTR pbuf, long len, long loc);
long FileLengthF (FILE *fid);
long FileLength (HFILE fid);
void BlockText (HDC hDC,LPSTR str,int maxlen,float f);
void ConvertSpanishText (LPBYTE pTxt);
int WaitCursor (int iWait);
HCURSOR LoadCursor(HINSTANCE hInstance,LPCSTR lpCursorName);
int LoadStrings (int nstrings ,HANDLE *hstrings,LPSTR *pNextLine,LPINT LineNum);
Bool GWCheckMenuItem(HWND hWnd, int wItem);
LPSTR StrEnd (LPSTR str);
short EndStr (LPSTR str);
LPSTR fgetss (LPSTR lpStr, short len, FILE *Fid);
void fputss (LPSTR lpStr, FILE *Fid);
Bool fputstring(LPSTR lpStr, HFILE Fid);
LPSTR fgetstring (LPSTR lpStr, int len, HFILE Fid);
Bool fputstringF(LPSTR lpStr, FILE *Fid);
int fgetstringF (LPSTR lpStr, int len, FILE *Fid);
float MULREG (double Y[], double X1[], double X2[], int N,
              LPDOUBLE A,LPDOUBLE B, LPDOUBLE C);
double AMEAN (double *X,int N);
short IDNSHRT (double X);

HANDLE STRAN2 (int ID,double X1[], double Y1[],double X2[],double Y2[],int N, LPFLOAT RSQMIN, int Type,LPMNMXCORD pBounds);
LPTRANDATA STRAN2P (int ID,double X1[], double Y1[],double X2[],double Y2[],int N, int Type,LPFLOAT RSQMIN);
void TRANS2 (double XIN,double YIN, LPDOUBLE XOUT,LPDOUBLE YOUT, HANDLE hlpTran);
void TRANS2P (double XIN,double YIN, LPDOUBLE XOUT,LPDOUBLE YOUT, LPTRANDATA pTran);
void TRNPRO (double XIN,double YIN, LPDOUBLE XOUT,LPDOUBLE YOUT, HANDLE hlpTran);
void TRNPROP (double XIN,double YIN, LPDOUBLE XOUT,LPDOUBLE YOUT, LPTRANDATA pTran);
void CloseTRANS2 (LPHANDLE phlpTran);
void CloseTRANS2P (LPTRANDATA *pTran);
Bool WriteTranCHeader (HANDLE hTran,HFILE Fid);
HANDLE STRANRect (LPRECT FromRect,LPRECT ToRect);
void TRANRect (LPRECT Rect,HANDLE hTran);
void TRANRectP (LPRECT Rect,LPTRANDATA pTran);
void TranToParcelPoints(LPDOUBLE XIN, LPDOUBLE YIN, LPDOUBLE  XOUT, LPDOUBLE  YOUT, LPPARCELTRAN pTran);
HANDLE STRANBoundsToRect (LPMNMXCORD FromRect,LPRECT ToRect);
HANDLE STRANRectToBounds (LPRECT FromRect,LPMNMXCORD ToRect);
HANDLE STRANBoundsToBounds (LPMNMXCORD FromRect,LPMNMXCORD ToRect);
HANDLE STRANPoints (int id,LPDPOINT FromPt,LPDPOINT ToPt,int nPt,LPFLOAT pRSQMIN,int Type,LPMNMXCORD pBounds);
POINT TRANDPointToPoint (HPDPOINT pDpoint,HANDLE hTran);
void TranPoints(LPDPOINT FromPt, LPDPOINT ToPt, int nPt, HANDLE hTran);
HANDLE DPolyToPPoly (LPINT pnpnts, HANDLE hDPoly,HANDLE hTran);
HANDLE ReadTranData (HFILE Fid);
Bool DisplayTranTriangles(HANDLE hTran, LPVIEWPORT CurView);
POINT TranPoint16(POINT pPoint, HANDLE hTran);
DPOINT TranPoint (LPDPOINT pPoint,HANDLE hTran);  
void SetVPRotation (double AZ);
XFORM SetXFORMFromTRANS (HANDLE hlpTran);
HANDLE TRFTRI_SET (LPDOUBLE XT,LPDOUBLE YT,LPDOUBLE XT2,LPDOUBLE YT2,int NSETPT,
				   double BASX1, double BASY1,double BASX2, double BASY2, HANDLE hTran,LPMNMXCORD pTriBounds);

//HANDLE STRANPoints (LPDPOINT FromPt,LPDPOINT ToPt,int nPt,int Type,LPFLOAT pRSQMIN);//,LPMNMXCORD pBounds);
LPTRANDATA STRANPointsP (LPDPOINT FromPt,LPDPOINT ToPt,int nPt,int Type,LPFLOAT pRSQMIN);//,LPMNMXCORD pBounds);
HANDLE  STRANBoundsToBounds (LPMNMXCORD FromRect,LPMNMXCORD ToRect);
LPTRANDATA  STRANBoundsToBoundsP (LPMNMXCORD FromRect,LPMNMXCORD ToRect);
HANDLE  STRANCornersToBounds (CORNERPOINTS *corners,LPMNMXCORD ToRect);
LPTRANDATA  STRANCornersToBoundsP (CORNERPOINTS *corners,LPMNMXCORD ToRect);
HANDLE  STRANBoundsToCorners (CORNERPOINTS *corners,LPMNMXCORD ToRect);
LPTRANDATA  STRANBoundsToCornersP (CORNERPOINTS *corners,LPMNMXCORD ToRect);
//void CloseTRANS2 (LPTRANDATA *phlpTran);
LPTRANDATA STRANCopy (LPTRANDATA pTran);
void TranMNMXCORL (MNMXCORL * in,MNMXCORL * out,HANDLE hTranPtr);
void TranMNMXCORD (MNMXCORD * in,MNMXCORD * out,HANDLE hTranPtr);
void TranMNMXCORLP (MNMXCORL * in,MNMXCORL * out,LPTRANDATA TranPtr);
void TranMNMXCORDP (MNMXCORD * in,MNMXCORD * out,LPTRANDATA TranPtr);
DPOINT TranDPOINT (LPDPOINT pPoint,HANDLE hTranPtr);
POINT TranDPOINTtoPOINT (LPDPOINT pPoint,HANDLE hTranPtr);
void TranPoints(LPDPOINT FromPt, LPDPOINT ToPt, int nPt, HANDLE hTranPtr);
IPOINT TranIPPOINT (IPOINT InPoint,HANDLE hTranPtr);
DPOINT TranDPOINTP (LPDPOINT pPoint,LPTRANDATA  hTran);
POINT TranDPOINTtoPOINTP (LPDPOINT pPoint,LPTRANDATA  hTran);
void TranPointsP(LPDPOINT FromPt, LPDPOINT ToPt, int nPt, LPTRANDATA hTran);
IPOINT TranIPPOINTP (IPOINT InPoint,LPTRANDATA  hTran);
LPTRANDATA  LoadTranFromBPWP (char * Name, int dir);
LPTRANDATA  LoadTranFromCPTP (const char * Name, int dir);



Bool makedirectories (LPSTR Name,Bool IsDir,Bool Verify);   
short GSSiMakeDir (LPSTR Name,LPDWORD pErrCode);
short GSSiRemove32 (LPSTR Name); 
int GSSiRemoveDir (LPSTR Name); 
int ConvertToNewLocation (LPSTR Path, Bool DoCopy);
Bool ConvertFileNameToCacheFileName (LPSTR FileName);
DWORD GM32GetSpecialDirectory (LPSTR Path);
Bool GSSirenamefile (LPSTR OldName,LPSTR NewName);
Bool GSSiCopyFile (LPSTR OldName,LPSTR NewName,Bool Replace);
Bool CopyDirectory(LPSTR toDir, LPSTR fromDir, Bool replace, LPSTR statusTitle);
Bool NameContainsDL (LPSTR Name);
void WriteTranData (HFILE Fid,HANDLE hTran);
double GetTranAZ (HANDLE hTrans);
HANDLE LoadTranFile (LPSTR Name, int dir,int Type,LPSHORT pNumPoints,LPDOUBLE pRSQ);
HANDLE LoadTranFromBPW (LPSTR Name);
MNMXCORD GetTranFileBounds (LPSTR Name,LPSTR Direction);
HANDLE LoadTranFileWithDandT (LPSTR Name);
long ConvertPoint (LPSTR CvtFile,LPDPOINT Point,int Direction);
DWORD ConvertGeodeticToMGRS (LPDOUBLE pLat,LPDOUBLE pLon,DWORD Precision,LPSTR MGRS);
DWORD ConvertMGRSToGeodetic (LPDOUBLE pLat,LPDOUBLE pLon,LPSTR MGRS);

short LINSEC (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
            double A2,double *X3,double *Y3);
short LINSEC_TOL (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
            double A2,double *X3,double *Y3,double INTOL);
short LIN_SEC (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
             double A2,double *X3,double *Y3);
Bool  POINT_IN_AREAS (POINT PickPoint, DWORD nPoints, HPPOINTS lpAreaPoints);
Bool  POINT_IN_AREA (POINT PickPoint, DWORD nPoints, HPPOINT lpAreaPoints);
HANDLE  PointInAreaAcceleratorSetup (DWORD nPoints, HPDPOINT pAreaPoints,int nPoly,HANDLE hPolyPartLen,HANDLE hMaskAccelerator); 
HANDLE  PointInAreaAcceleratorSetupMono (DWORD nPoints, HPDPOINT pAreaPoints, int nPoly,HANDLE hPolyPartLen,double Offset,LPMNMXCORD pBounds);
HANDLE  PointInAreaAcceleratorSetupWindow (DWORD nPoints, HPDPOINT pAreaPoints,HANDLE hMaskAccelerator); 
HANDLE  PCTInAreasInit (LPMNMXCORD pBounds,int Precision);
void PCTInAreasDestroy (HANDLE hPIA);
double  PCTInAreasLoad (HANDLE hPIA,int opt,int type,DWORD nPoints, HPDPOINT pAreaPoints, int nPoly,HANDLE hPolyPartLen,double Offset,LPMNMXCORD pBounds);
double PCTInAreas (HANDLE hPIA);
int	PointInAreaAccelerator (LPDPOINT Point,HANDLE hAccelerator);    
POINT PIAACenter (LPPIAAStruct pPIAA,LPLONG piCPDist,LPLONG pMaxn,Bool UsePCTBox,LPBool pHaveCP);
POINT	DPointToPIAAPoint (HPDPOINT pDPoint,LPMNMXCORD pBounds,LPDOUBLE pFactor,short Offset,short Type);
DPOINT	PIAAPointToDPoint (POINT Point,LPMNMXCORD pBounds,LPDOUBLE pFactor,short Offset,short Type);
LPHANDLE GetPolygonPickAccelerator (int Opt);
void ThinPoly (LPLONG pnPnts, HPDPOINT pPoints, double maxdist);
int	ReducePolyPoints (int nPnts,LPHANDLE phPoly,int MaxPoints);
Bool NextLine (LPSTR *lpText,LPSTR lpLine,short nAutoLines); 
LPSTR PadString (LPSTR str,char padchr,int padlen);
LPSTR Truncate(LPSTR str); 
LPSTR Truncate2(LPSTR Text, char c);
LPSTR TruncateAt (LPSTR str,LPSTR EndChars);           
LPSTR FirstNonInt (LPSTR Text);  
LPSTR FirstAlpha (LPSTR Text);
void GSSiERROR (HWND hWnd, short ErrorNum, LPSTR ErrorMessage);
LPSTR IADDR (LPSTR InAdd, long Offset);
long HADDR (HPSTR InAddress, long Offset);
//LPSTR NextFld (LPSTR pInRec);
//LPSTR NextRec (short Fid);
Bool CheckForContinue (Bool QuitOnEscapeOnly,LPBool pQuitProcessing);
void Wait (long MicroSeconds);
void Wait2 (long MicroSeconds);
Bool WaitForKeystroke (Bool UseGetMessage);
Bool PctBox(HWND hWnd, LONGLONG MaxLen, LONGLONG Done, short Freq);
Bool IsInteger(LPSTR str);       
Bool IsReal(LPSTR str);
HANDLE GetPrinterDC(void);
long BigWrite (HFILE Fid,LPVOID pBuf,DWORD isize,long seekloc);
long BigRead (HFILE Fid,LPVOID pBuf,long isize);
void farfree(void *block);
Bool CDInit (HWND hWnd, HINSTANCE Inst);
void CDClose (void);
Bool GetColor (HWND hWnd,COLORREF *Color);  
int GetColorFromPalette (HWND hWnd,LPRGBTRIPLE pColors,int nColors);
COLORREF GetNextUniqueColor (LPLONG pColor);
void cwCenter(HWND hWnd, int top);
int nCwRegisterClasses(LPSTR Menu);
void CwUnRegisterClasses(void);
/*Bool GSSIPeekMessage(
    LPMSG lpMsg,
    HWND hWnd,
    _wMsgFilterMin,
    wMsgFilterMax,
    UINT wRemoveMsg);
Bool GSSiGetMessage(
    __out LPMSG lpMsg,
    __in_opt HWND hWnd,
    __in UINT wMsgFilterMin,
    __in UINT wMsgFilterMax);*/
void SetFilterString (UINT Filter); 
void PrintMessage (short    ViewID, LPSTR File, short record);
void PrintMessage2 (LPSTR line1, LPSTR line2, LPSTR line3);
HRESULT BasicFileOpen2(LPSTR pFile, int lfile, LPSTR initialDir, LPSTR filter, LPSTR Title,Bool save);
Bool GetOpenFileCD (HWND hWnd, LPSTR Name, int lname, LPSTR lpInitDir);
Bool GetSaveFileCD (HWND hWnd, LPSTR Name, LPSTR lpInitDir);
Bool GetFolderName (HWND hWnd,LPSTR startDir,LPSTR outDir,LPSTR title);
Bool GetFont (HWND ghWnd, LPLOGFONT lpLogFont, COLORREF *dwFontColor, COLORREF *dwShadowColor,HFONT *phSelectedFont);
double square(double val);
double idist(POINT Point1, POINT Point2);
double ldistp(DPOINT Point1, DPOINT Point2);
double l2ddistfrom3d (DPOINT3D Point1, DPOINT3D Point2);
double ldistpp(LPDPOINT Point1, LPDPOINT Point2);
FPOINT MidPointF(FPOINT Point1, FPOINT Point2);
POINT MidPoint(POINT Point1, POINT Point2);
DPOINT MidPointD(DPOINT Point1, DPOINT Point2);
DPOINT3D MidPoint3D (DPOINT3D Point1, DPOINT3D Point2);
double getaz(POINT Point1, POINT Point2);
double getazF(FPOINT Point1, FPOINT Point2);
double fgetaz(FLTPOINT Point1, FLTPOINT Point2);
double getazl (LPOINT Point1, LPOINT Point2);
double getazd (DPOINT Point1, DPOINT Point2);
double getazdp(LPDPOINT Point1, LPDPOINT Point2);
double get2dazfrom3d (HPDPOINT3D Point1, HPDPOINT3D Point2);
double LTWOPI (double AZ1);
double LGETAZ(double X1, double Y1, double X2, double Y2);
void AZToBear (double CurAZ,LPSTR PreDir,LPSTR DegC,LPSTR MinC,LPSTR SecC,LPSTR PostDir);
void AZToAZIM (double AZ,LPSTR DegC,LPSTR MinC,LPSTR SecC);
FPOINT newptF(FPOINT OldPoint, double AZM, double DIS);
POINT newptscreen(POINT OldPoint, double AZM, double DIS);
DPOINT dnewptproj (DPOINT OldPoint, double AZM, double DIS);
void LNEWPT (double X,double Y,LPDOUBLE NewX,LPDOUBLE NewY, double AZM, double DIS);  
Bool MemError (void);

//Bool copyfile (LPSTR ToFile, LPSTR FromFile,short AppendOrReplace,long StartPos,long EndPos,HWND hWndDlg,UINT StatusCntl,long TotLen,LPLONG pCurLoc);
LPSTR FirstNonBlank(LPSTR Text);
LPSTR LastNonBlank(LPSTR Text);
LPSTR NextBlank(LPSTR Text);
short RemoveTrailingBlanks (LPSTR str);
UINT GetOPENERR00(void);    
double Round (double Value,double RoundTo);
LPSTR AddCommas (LPSTR VCBuff);
double DecDegFromDMS (LPSTR DMS,LPBool pErr);
Bool GetDMS (double DecDegrees,LPSHORT Deg,LPSHORT Min,LPDOUBLE Sec);
LPSTR ValueConv (double Value, short ValConv,double RoundTo,Bool Commas); 
HANDLE  BMPFromPCX (LPSTR ImageFile);  
HANDLE  BMPFromEXT (LPSTR ImageFile); 
Bool SetDIBMonoColors(HDIB32 hDib,LPLONG Colors); 
Bool  BMPToEXT (HANDLE hBMP,LPSTR ImageFile,DWORD Flag); 
Bool  BMPToEXT32 (HDIB32 hDib,LPSTR ImageFile,DWORD Flag); 
DWORD  BMPFileFromEXT (LPSTR ImageFile,LPSTR BMPFile,double factor); 
int  DisplayBMFileInRect (HDC hDC,LPSTR ImageFile, RECT Rect, short MaintainAspect);
int  DisplayBMInRect (HDC hDC,LPBITMAPINFOHEADER pDibInfo,LPSTR pImage, RECT Rect, short MaintainAspect,LPRECT pOutRect);
short  DisplayPCXFileInRect (HDC hDC,LPSTR ImageFile, RECT Rect, Bool MaintainAspect);
Bool  DisplayBMInRect2 (HDC hDC, HANDLE hBM, RECT Rect, double Factor,double VPct, double HPct,LPRECT pOutRect);
int  DisplayBMInRect32 (HDC hDC,HDIB32 hDib, RECT Rect, short MaintainAspect);
int  DisplayBMInRect32_2 (HDC hDC,HDIB32 hDib, RECT Rect, short MaintainAspect,DWORD RasterOpt);
Bool DisplayBMFileInVP32(HDC hDC, LPSTR BMFile, double RotationAZ, Bool fitToVP);
Bool DisplaySIDInVP32 (LPVIEWPORT pVP,LPSTR BMFile);
//Bool CheckBoardBMInRect (HDC hDC,LPSTR ImageFile1, LPSTR ImageFile2,RECT Rect, Bool MaintainAspect);
void CenterRectOnPoint(LPRECT pRect,POINT center);
POINT RectMid (LPRECT rect);
DPOINT RectMidD (LPRECT rect);
void ComputeBMLoc (RECT Rect,LPBITMAPINFO pDibInfo,short MaintainAspect);
Bool GetDIBDimensionsFromHandle(HDIB32	hDib32,LPINT height,LPINT width);
Bool GetDIBDimensions(LPSTR File,LPINT height,LPINT width);
LPBITMAPINFO GetDibHeader (HDIB32 hDib);
Bool hDibIs32Bit (HDIB32 hDib);
void hDibFree (LPHDIB32 phDib);
Bool LoadBitMap (LPSTR ImageFile,long frame, LPHDIB32 phDib, LPSHORT pDeleteBM,
                 LPSHORT BitCount, LPSHORT width, LPSHORT height);
Bool ReadBitMapHeader (HFILE Fid, LPHANDLE phDibInfo, LPLONG ImageOffset);
Bool SetupTIFHeader (HFILE Fid, LPHANDLE phDibInfo,LPSHORT pNumStrips, LPHANDLE phImageOffset,LPHANDLE phByteCounts,
					 LPSHORT pRowsPerStrip,LPSHORT pPhotoInterp,
					 LPSHORT pSamplesPerPixel,LPSHORT pPlanarConfig,LPSHORT TIFFCompression,
					 LPSHORT pBitsPerSample,LPSHORT pSkipBits);  
Bool DecompressTIFF (HPSTR Data,long length,long explen,short type);
HANDLE  BMPFromTIF (LPSTR TiffFile,Bool Check);
short DisplayTIFFileInRect (HDC hDC,LPSTR ImageFile, RECT Rect, Bool MaintainAspect);
Bool Report (LPSTR Name, LPSTR ViewportName, LPSTR Prefix, LPSTR UDI, long ref,Bool LoadOnly, Bool FitToVP);
Bool DisplayReport (HDC hDC, HANDLE hReport, RECT Rect, RECT ClipRect, double Factor, long Refno,LPRECT SizeRect);
Bool ReportToFile (LPSTR Name, LPSTR Prefix, LPSTR UDI, long ref,LPSTR File);
Bool DisplayReport2 (HDC hDC, HANDLE hReport, RECT Rect, double Factor,Bool CloseFiles,LPRECT SizeRect);
//RECT SizeReport (HDC hDC,HANDLE hReport,RECT CurRect,Bool FitToVP);
HANDLE LoadReport (LPSTR Name); 
void UnloadReport (LPHANDLE hReport);
Bool OpenReportFiles (HANDLE hReport);
void CloseReportFiles (HANDLE hReport);
Bool AddReportToPrintList (LPSTR ReportFile,long Refno,LPSTR Prefix, LPSTR UDI,LPSTR InitCmd);  
Bool GetNextPrintReport (Bool First,LPSTR ReportName,LPLONG pRefno,LPSTR Prefix,LPSTR UDI,LPSTR InitCmd);
Bool PrintReport2 (HDC hPr,HDC PrinterDC,Bool IsVirtPrinter,HDC mfDC,LPSTR ReportFile,long Refno,LPSTR Prefix,LPSTR UDI,LPSTR InitCmd);
short   Signof (double val);
short   lSignof (long val);
int NumCharInString (LPSTR str,char chr);
double   dSignof (double val);
WORD ECRCMem(WORD *icrc, BYTE *icp, WORD icnt);
DWORD CRC16 (LPSTR Array, short nc);
Bool GetSaveName (HWND hWnd,LPSTR Name, UINT StringID, LPSTR Ext);  
Bool    GetSaveName2 (HWND hWnd,LPSTR Name, UINT StringID, LPSTR Ext,UINT FileNameID);
Bool    GetSaveName3 (HWND hWnd,LPSTR Name, UINT StringID, LPSTR Ext,LPSTR Title,LPSTR VarName);
Bool    GetFileName (HWND hWnd,LPSTR Name, int lname, UINT StringID);
Bool    GetFileName2 (HWND hWnd,LPSTR Name, LPSTR Ext,UINT FileNameID);
Bool    GetFileName3 (HWND hWnd,LPSTR Name,UINT StringID,UINT FileNameID);
Bool    GetFileName4 (HWND hWnd,LPSTR Name,UINT StringID,LPSTR Ext,LPSTR Title,LPSTR VarName);
Bool    GetMultFiles (HWND hWnd,LPSTR Name,int lname,UINT StringID,UINT FileNameID);
void SetOpenFlags (short Flags);
void SetCreateFile (void);
DWORD GetDlgItemPrompt (HWND hWnd); 
void flip (LPSTR In, short n);
void SetDlgPrompt (HWND hWnd,UINT Prompt,UINT More);
void InitDlgPrompts (HWND hWnd);
void ClearDlgPrompts (void);
//void FillFontNameList (HWND hWndDlg,UINT ListBox);
unsigned int MessageBox(
            HWND hWnd,
            LPCSTR lpText,
            LPCSTR lpCaption,
            UINT uType);


void GMMessageBox (UINT Message, UINT Title, UINT Style);
long LoadProjection(long nj, LPSTR NAME); 
long TranProjection(long I, long O, double *x, double *y); 
int ConvertPRJtoProj4(char *in, char * out);

//extern long FAR PASCAL CloseLibrary(void);
//extern Bool FAR PASCAL OpenGCTPLibrary(void);
//extern Bool FAR PASCAL OpenGCTP(long far *d);   
Bool ConvertCoordClose (void);
Bool NeedToConvertCoord (int from, int to);
long ConvertCoord (LPDPOINT DPoint,int from, int to);
double ClipCoordToProjection (double val,int xory,int idFrom,int idTo);
long ConvertCoordInit (void);
long ConvertAndTranCoord (LPDPOINT pPoint,HANDLE hTranFile);
void ConvertCoordError(long ErrNum);
Bool GetCurVal (LPCSTR Val,short maxval, UINT StringID);
void SetCurVal (LPCSTR Val,UINT StringID);
void SaveGlobalVals (HFILE Fid);
int	GetUpdateFieldType (LPSTR SetFieldName);
Bool GetUpdateFieldValue (HWND hWndDlg,LPSTR SetFieldName,LPSTR NewValue);
Bool AVIFrameToDIB (LPSTR File, long frame,LPHANDLE NewDIB,LPSHORT ShouldDeleteBM,
                    short Bitcount, short width, short height);
long NumDIBColors (HANDLE hDib);
void CloseOrthoAVI (void);
short AVIOut (LPSTR Name,LPBITMAPINFOHEADER alpbi,LPHANDLE hFile,LPLONG pFrame,Bool UseExCmp);
void AVIOutClose (LPHANDLE phFile);
HANDLE ConvertBitmap16To24 (LPBITMAPINFOHEADER  lpbi);
HANDLE ConvertBitmap8To24 (LPBITMAPINFOHEADER  lpbi);
Bool SplitBitmap (LPSTR Infile,int numRows,int numCols,LPSTR OutDir,LPSTR OutExt,int OutOpt);
Bool FixBitMapHeader (LPSTR FileName);
int GetOpenFileChecksum2 (HFILE Fid,int frombyte,int tobyte);
int GetOpenFileChecksum (HFILE Fid,int frombyte,int tobyte);
int GetFileChecksum (LPSTR File,int frombyte,int tobyte);
BYTE ComputeCheckSum (LPBYTE rec,DWORD l);
int	GSSiRemove (LPSTR Name);
int GSSiRemoveAndClear (LPSTR Name);
int GSSiRemove2 (LPSTR Name);
long GSSiLength (LPSTR Name);
Bool GSSiRename (LPSTR NameFrom, LPSTR NameTo);
HCURSOR GSSiSetCursor (HCURSOR hCursor);
POINT TAGPtToWinPt (DPOINT TagPoint);
DPOINT WinPtToTAGPt (POINT WinPoint);
float PixelsToTAGFontHt (LPLOGFONT lpFont,short CoordStyle);
double TAGFontHtToPixels (double TAGFontHeight,short CoordStyle);
DPOINT AverageDPoint (DPOINT Point1, DPOINT Point2);   
POINT AveragePoint (POINT Point1, POINT Point2);   
LPOINT AveragePointL (LPOINT Point1, LPOINT Point2);
DPOINT AverageDPoints (HPDPOINT Point,long nPnts);
Bool RemoveLine (LPSTR Name,LPSTR line);
Bool DisplayTextFileInRect (HDC hDC,LPRECT Rect,LPSTR Name);
LPSTR UpcaseFirst (LPSTR s);
LPSTR OneSpace (LPSTR Arg1); 
LPSTR strncpy0(LPSTR Buff,LPSTR str, size_t n);
void SetFocusAndCursor (HWND hWnd);
Bool GetTextString (HWND hWnd,LPSTR String,int lenstring, LPSTR Title,LPSTR ListFile,LPSTR InitVal,long AutoInc,Bool DrowDown,Bool Sorted); 
Bool GetTextStringML (HWND hWnd,LPSTR String,int lenstring, LPSTR Title,LPSTR InitVal);
long GetGlobalLVal (LPSTR Global);
long GetGlobalLVal2 (LPSTR Global,long Default);
long GetGlobalLVal3 (LPSTR Global,long Default);
Bool GetGlobalBVal (LPSTR Global);
Bool GetGlobalBVal2 (LPSTR Global,Bool Default);
Bool GetGlobalPVal (LPSTR Global,LPDPOINT Default,LPDPOINT pPoint);
short GetGlobalVal (HANDLE hGlobal,LPSTR OutStr,long Index);
double GetGlobalDVal (LPSTR Global);
double GetGlobalDVal2 (LPSTR Global,double Default);
Bool GetGlobalCVal (LPSTR Global,LPSTR Val,LPSTR Default);
RECT GetGlobalRectVal (LPSTR Global,LPRECT pDefault);
MNMXCORD GetGlobalBoundsVal(LPSTR Global, LPMNMXCORD pDefault);
MNMXCORD3D GetGlobalBounds3DVal(LPSTR Global, LPMNMXCORD3D pDefault);
Bool GetGlobalValRaw(LPSTR Global, LPSTR Val);
Bool ExecuteCommandString (LPSTR pCommand);
//HBITMAP PCXtoBMP (HDC hDC,LPSTR Name);   
long Factorial (long value);    
Bool LoadTAGDef (void);
double ArcDistance(DPOINT p1, DPOINT p2);
DPOINT NewLatLong(double Lat,double Long,double Dist,double Direction);
short DrawCircle (HDC hDC,POINT Point,double Radius,short Width,COLORREF Color); 
void AddPointToRect (POINT pPoint,LPRECT pBounds);
void AddFPointToRect(FPOINT Point, LPRECT pBounds);
void AddDPointToRect(DPOINT Point, LPRECT pBounds);
void AddPointToRect16 (POINT Point,LPRECT16 pBounds);
void AddPointToMinMax (POINT pPoint,LPMINMAX pMinMax);
void AddDPointToMinMax (HPDPOINT Point,LPMNMXCORD pBounds);
double BoundsWidth (LPMNMXCORD pBounds);
double BoundsHeight (LPMNMXCORD pBounds);
void MinMaxInit (LPMINMAX pMinMax);
void AddPointToMinMaxL (POINT Point,LPMNMXCORL pBounds);
void RectInit (LPRECT pMinMax);
void RectInit16 (LPRECT16 pMinMax);
void MinMaxInitL (LPMNMXCORL pMinMax);
void BoundsToPoints (LPMNMXCORD pBounds, LPDPOINT Points,LPDOUBLE pAZ);
void BoundsLToPoints (LPMNMXCORL pBounds, LPDPOINT Points,LPDOUBLE pAZ);
Bool DPointInBounds (LPDPOINT Point,LPMNMXCORD pBounds);
DPOINT FPointToDPoint (FPOINT point);
POINT FPointToPoint (FPOINT point);
DPOINT SPointToDPoint (POINTS Point);
DPOINT PointToDPoint (POINT Point);
LPOINT PointToLPoint (POINT Point);
HANDLE DPointsToHFPoints(LPDPOINT DPoints, int np);
HANDLE HDPointsToHFPoints(HANDLE hDPoints, int np);
HANDLE DPointsToFPoints(HANDLE hDPoints, int np);
LPOINT DPointToLPoint(LPDPOINT pPoint);
DPOINT LPointToDPoint (LPOINT Point);
FPOINT DPointToFPoint (DPOINT DPoint);
FPOINT PointToFPoint (POINT DPoint);
DPOINT DPoint3DToDPoint (DPOINT3D DPoint);
DPOINT3D DPointToDPoint3D (DPOINT DPoint);
LPOINT DPointToFilePointL (LPDPOINT pDPoint,HANDLE hTran);
void RoundToPTOL (LPDPOINT Point);
void InflateBounds (LPMNMXCORD pBounds, double Value);
void InflateMinMax (LPMINMAX pBounds, int Value);
void InflateMinMaxL (LPMNMXCORL pBounds, int Value);
Bool DPointInRect(LPDPOINT pt, LPRECT rect);
Bool FPointInRect(LPFPOINT pt, LPRECT rect);
Bool RectInRect(LPRECT pRectIn,LPRECT pRectTest);
Bool RectCompletelyInRect(LPRECT pRectIn,LPRECT pRectTest);
Bool IntersectBounds (LPMNMXCORD pBounds1,LPMNMXCORD pBounds2,LPMNMXCORD pBoundsInt);
void BlowOut (LPSTR Message, LPSTR Title);
void SubstituteDL (LPSTR Name,Bool WantAt); 
void SetReplacePath (LPSTR Name,short opt);
LPSTR ldelim (LPSTR str,char delim);
Bool ProcessMacroReport (LPSTR Name, LPSTR Prefix, LPSTR UDI, long ref);
Bool DisplayScrollReport (LPSTR Name, LPSTR Prefix, LPSTR UDI, long ref);
Bool DisplayReportScroll (HWND hWndDlg, int ScrollCntl);
int GetLBSelectedItems (HWND hWndDlg,UINT controlid,LPHANDLE phItems);
LPSTR TabFromEnd (LPSTR str, int n);
Bool EditDynamicDialog (HWND hWndDlg,LPSTR Name, LPSTR SQL, LPSTR InsertString);
int AppendFile (LPSTR File,LPSTR Line);
int AppendFile2 (LPSTR InFile,LPSTR Line);
void AddToMinMaxD (LPMNMXCORD mm1, LPDPOINT pPoint); 
Bool BoundsInBounds (LPMNMXCORD pBounds1,LPMNMXCORD pBounds2,short Opt);
Bool Bounds4InBounds4 (LPMNMXCORL pBounds1,LPMNMXCORL pBounds2,short Opt);
Bool PointInBounds (DPOINT Point,LPMNMXCORD pBounds);
Bool PointInBoundsL (DPOINT Point,LPMNMXCORL pBounds);
void DBoundsInit(LPMNMXCORD lpRect);
void DBoundsInit3D(LPMNMXCORD3D lpRect);
void AdjustBounds(LPMNMXCORD Bounds, double AdjustX, double AdjustY);
void ExpandBounds (LPMNMXCORD Bounds, double Adjust);
void ExpandMinMax (LPMINMAX Bounds, int Adjust);
void ExpandMinMaxL (LPMNMXCORL Bounds, long Adjust);
void TranBounds(HANDLE TranID, LPMNMXCORD pBounds);
void ConvertBounds(LPMNMXCORD pBounds, int from, int to);
void AdjustRectToRect(LPRECT pRectToAdjust, LPRECT pRect);
void DebugShowLine (LPDPOINT p1,LPDPOINT p2);
double MinAngleToTheRight (double AZ1,double AZ2);
short GetValListFieldLen (LPFIELDINFO pField);
Bool CreateStatusWind (HWND hWnd,int nStatusBars,LPSTR Title);
Bool StatusWindowUpdate (LPSTR Title, LPSTR Mess, LONGLONG Tot, LONGLONG Done);
void StatusExtraInfoUpdate(LPSTR mess);
Bool StatusWindowUpdate2(LPSTR Mess, LONGLONG Tot, LONGLONG Done);
Bool DestroyStatusWindow (long Macro);
void TranBoundsToRect (HANDLE TranID,LPMNMXCORD pBounds,LPRECT pRect);
double TranAngle (HANDLE TranID,LPMNMXCORD pBounds);
double TranScale (HANDLE TranID,LPMNMXCORD pBounds);
void AddMinMax (LPMINMAX mm1, LPMINMAX mm2);
void AddMinMaxD(LPMNMXCORD mm1, LPMNMXCORD mm2);
void AddMinMax3D(LPMNMXCORD3D mm1, LPMNMXCORD3D mm2);
void AddMinMaxL(LPMNMXCORL mm1, LPMNMXCORL mm2);
Bool ValidBounds (LPMNMXCORD Bounds);
Bool ValidBounds2 (LPMNMXCORD Bounds);
void DdeBye(void);
Bool InitDdeStuff(HWND  In_handle, Bool Highways);
void SetIntRefno (long Ref); 
void SetSymNum (int SymNum);
void BufWrite (HPSTR *pBuf,LPLONG plBuf,HPSTR data,long ldata);
Bool BackupFiles (LPSTR FileList,LPSTR BUDir);
void DeleteObject (HGDIOBJ handle);
void GSSiDeleteObject (HGDIOBJ *handle);  
short loadtabs (LPINT Tabs);
short GetDriveNum (char DriveLetter);
//Bool CreatePickData (void);
double RectArea (LPRECT pRect);
double RectArea16 (LPRECT16 pRect);
double BoundsArea (LPMNMXCORD pRect);
double ComputeAreaAreaD (HPDPOINT lpDPoints,long nPnts,LPDOUBLE pPerim,LPMNMXCORD pBounds);
double ComputeAreaAreaDH (HANDLE hPoints,long nPnts,LPDOUBLE pPerim);
DPOINT ComputeAreaMidpoint2 (HPDPOINT pPoints,long nPnts);
DPOINT ComputeAreaMidpoint (HANDLE hPoints,long nPnts);
Bool GetItemMidpoint (LPSTR TagOrRef,LPDPOINT pMidPoint);
DPOINT ComputePolylineMidpoint2 (HPDPOINT pPoints,long nPnts);
DPOINT ComputePolylineMidpoint (HANDLE hPoints,long nPnts);
Bool GetVolumeLabel(LPSTR wDrive, LPSTR lpBuff);
double	GetDriveFreeSpace (LPSTR Drive);
//Bool LoadLibraries(HINSTANCE hInst);
//void FreeLibraries(void);
USHORT GetSQLType(LPSTR pstr,LPSTR lpBrack,int NumFields,LPFIELDINFO lpFldInfo,LPDWORD pPrecision,LPUSHORT pScale);
Bool AddPWtoODBCFile (LPSTR lpcstring);
//void CloseGCTPLibrary32(void);
HANDLE CopyDib (HANDLE hdib);
Bool ReverseBool (Bool In);
void hmemset (HPSTR out,char in,DWORD len);
Bool SamePointS (POINTS p1, POINTS p2);
Bool SamePoint (POINT p1, POINT p2);
Bool SameLPoint (LPOINT p1, LPOINT p2);
Bool SameDPoint (LPDPOINT p1, LPDPOINT p2);
Bool SameFPoint(FPOINT p1, FPOINT p2);
Bool PolylineF(HDC hDC, LPFPOINT pt, int np);
Bool PolygonF(HDC hDC, LPFPOINT pt, int np);
int	GetFunctionID(LPSTR str, LPSTR ParenLoc);
int	GetFunctionValue(int FunID, LPSTR Args, LPSTR OutLoc, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
int	GetFunctionValue1(int FunID, LPSTR Args, LPSTR OutLoc, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
int	GetFunctionValue2(int FunID, LPSTR Args, LPSTR OutLoc, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
int	GetFunctionValue3(int FunID, LPSTR Args, LPSTR OutLoc, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
short GetFunArgs(LPSTR	Args, LPSTR *Arg, short MaxArgs, LPHANDLE phMem, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
COLORREF ColorWOWidth(COLORREF InColor);
COLORREF ColorWithWidth (COLORREF Color,int Width);
double FltAP (LPSTR INEXPR,LPBool IRC);
Bool LogicP (LPCSTR INEXPR,LPBool IRC);
Bool LogicPBP(LPCSTR INEXPR, LPBool IRC, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen);
Bool LogicPFile(LPOPENSQLDATA	FilePtr, LPSTR SQL, LPBool pErr);
void ConvertSQLToLogicP (LPSTR pLogicP,LPSTR pSQL);
double fltread (LPSTR Instr, LPBool IRC);
double ComputeFLTValue (double val1, double val2, char OpCode,LPBool IRC);
Bool ComputeLogValue (LPSTR val1, LPSTR val2, UINT OpCode,LPBool IRC);
UINT GetBoolOpCode (LPSTR Input,LPSHORT pInc,LPBool pNeedArg1,LPBool pError);
short OpRankBool (UINT OpCode);
//short DupDLLs (void);                            
HWND SendDDEInitiate(LPSTR szApplication, LPSTR szTopic);
void SendExecute(HWND hwndClientDDE, HWND hwndServerDDE,LPSTR szExecuteString);
void ClientTerminate(HWND hwndClientDDE,HWND hwndServerDDE);
void TerminateConversations(HWND hWndClient);
void MovePromptMessage (HWND hWnd,LPARAM lParam);
void SetPromptDlg (UINT PromptID);
POINT MinMaxMidPoint (LPMINMAX pBounds);
POINT MinMaxMidPointL (LPMNMXCORL pBounds);
DPOINT MinMaxMidPointD (LPMNMXCORD pBounds);
MNMXCORD FactorBounds (LPMNMXCORD pRect,double Factor);
DPOINT SubtractPoint (LPDPOINT pPoint1,LPDPOINT pPoint2);
int	SaveCurView (int opt);
short GSSiMessageBox (int from,LPSTR Mess,LPSTR Title,UINT icon,LPSTR Position);
void GSSiMessageBoxEnable(void);
DPOINT EnlargedPoint (POINT Point);
Bool EnlargeScreen (short factor,short width); 
Bool atob (LPSTR Value); 
void btoa (Bool Val,LPSTR str);
DPOINT atopt (LPSTR Value,LPBool pErr);
POINT atopt16 (LPSTR Value,LPBool pErr);
MNMXCORD atobounds(LPSTR Value, LPBool pErr);
MNMXCORD3D atobounds3D(LPSTR Value, LPBool pErr);
MNMXCORD lboundstobounds(LPMNMXCORL plbounds);
RECT atorect (LPSTR Value,LPBool pErr); 
void boundstoa (LPSTR Value,LPMNMXCORD Bounds);
void lboundstoa (LPSTR Value,LPMNMXCORL Bounds);
void recttoa (LPSTR Value,RECT Rect);
void pttoa (LPSTR Value,POINT Point);
void dpointtoa (LPSTR Value,LPDPOINT pPoint);
void dpointtoatrunc (LPSTR Value,LPDPOINT pPoint);
void pointstoa (LPSTR Value,int nPoints,HANDLE hPoints,HANDLE hTran);
LPSTR ftoa (LPSTR Value,double DVal);
void NextPage (HDC hDC);  
short Expandicmp (LPSTR String1, LPSTR String2);
Bool MakeMap (LPSTR Args);
Bool WhereAt (LPSTR Args);  
Bool NeedSQLValueQuote (HANDLE hSQL,LPSTR FieldName);
void SetLinkedVarTime (VARPNT VP); 
void LinkIncludedVars (HANDLE hVar,LPSTR Value);
void GetPatternOpt (HWND hDlg,LPPATBYTE pPatByte);
void SetPatternOpt (HWND hDlg,LPPATBYTE pPatByte);
HBRUSH CreatePatBrush (HDC hDC, COLORREF color, LPPATBYTE pPatByte);
void SetDlgItemTextGlobal (HWND hWndDlg,UINT icntl,LPSTR Global,LPSTR Init);
void GetDlgItemTextGlobal (HWND hWndDlg,UINT icntl,LPSTR Global);
void SetDlgItemTextFromField (HWND hWndDlg,UINT icntl,LPSTR FieldName,LPSTR Init);
Bool SetDlgCheckboxFromField (HWND hWndDlg,UINT icntl,LPSTR FieldName,LPSTR Init);
Bool SetDlgComboboxFromField (HWND hWndDlg,UINT icntl,LPSTR FieldName,LPSTR Init);
Bool LININT (double L1X1, double L1Y1, double L1X2, double L1Y2,
			 double L2X1, double L2Y1, double L2X2, double L2Y2);
//void DumpDCB (int Stream);
void SIOOpenError (LPSTR Port,int Error);
HANDLE ReadSavedScreen (LPSTR File,LPLONG pUpdateTime,LPMNMXCORD pBounds);
Bool WriteSavedScreen (LPSTR File,HANDLE hSavedScreen,LPMNMXCORD pBounds); 
void Draw3DBorder(HDC hDC, LPRECT pRect,int iStyle, Bool DoubleWidth);
Bool FAR PASCAL EDITDYNDIALOGMsgProc(HWND hWndDlg, WORD Message, WORD wParam, LONG lParam);
Bool GetCDDriveForVol (LPSTR VolID,LPSTR Drive);
Bool ConvertNameToCDName (LPSTR Name);     
Bool CDIsInstalled (LPSTR CDName);
void OpenCDLookUpTable (void);
void CloseCDLookUpTable (void);
void ShowCheck (HDC hDC,LPRECT pRect,Bool Checked,LPRECT pOutRect);
HANDLE	EnterBlockingWindow (HWND hWndDlg);
void LeaveBlockingWindow(HANDLE hSavedScreen);
void GSSiEndDialog(HWND hWndDlg,Bool rtn,HANDLE hSaveBM);  
void ClearFullWindowBitmap (HWND hWnd);
short GetNumOpenFiles (void);
short GetOpenFileID (HFILE Fid);
short GenList (HWND hWndDlg,UINT CntlID,Bool ComboBox,long Loc,LPSTR str,LPSTR CurrentValue,LPBool pUseBAR,LPINT MaxLen,LPINT NumItems);
Bool GetGenListVal (LPSTR GenListString,int Inc,LPSTR OutString);
void ClearCurrentCD (void);
Bool CDInCancelledList (LPSTR CD);
void AddCDToCancelledList (LPSTR CD);
short OkToContinue (Bool ForceCheck);
Bool WindowIsCovered (HWND hWnd,short opt);
double GetDriveSize (char Drive);
long GetProcessorID (void);
Bool NormalRect (LPRECT Rect); 
RECT FactorRect (LPRECT Rect,double Factor); 
Bool GetOpenFilePathname (HFILE Fid,LPSTR Name); 
Bool MinimizeWindowIfOverMain (HWND hWnd);
Bool WriteErrorHandler (HFILE Fid,long ln,long loc);  
//grp4decomp(HPBYTE indata,long inbytes,long width,long height,HPBYTE outdata,LPLONG outbytes,short SkipBits);
//int SetLastMessage (long mes);
//void ShowTextTrace (LPSTR str);
double ColorDist (COLORREF C1, COLORREF C2);
double RGBDist (RGBTRIPLE C1, RGBTRIPLE C2);
double RGBQUADDist (RGBQUAD C1, RGBQUAD C2);
COLORREF NearestColor (COLORREF Color, COLORREF C1, COLORREF C2);
int NumBytesDifferent (LPSTR File1,LPSTR File2);
Bool RectanglesAreEqual (LPRECT pRect1,LPRECT pRect2);
Bool TABToComma (LPSTR InFile,LPSTR OutFile);  
INT64 llFileSeek (HANDLE hf, INT64 distance, DWORD MoveMethod);
LONG GSSillseek (HFILE Fid, LONG loc, int opt); 
LONGLONG GSSillseek2 (HFILE Fid, LONGLONG loc, int opt);
long  GSSilread(HFILE Fid, void * ptr, long len);
UINT  GSSilwrite(HFILE Fid, const void * ptr, UINT len);
Bool ConvertToMemFile (HFILE Fid,int MaxMem);
HFILE GSSiOpenFileMem (LPSTR InName,UINT mode,UINT maxlen); 
HFILE SetMemFile (HFILE Fid,HANDLE handle,long len);
Bool IsMemFile (HFILE Fid);
double LDIST(double X1,double Y1,double X2,double Y2);
HANDLE GetBMPFromCache (LPSTR Name);
void AddBMPToCache (LPSTR Name,HANDLE hBMP);
Bool hDIBInCache (HANDLE hBMP);
HDIB32 GetBMPFromCache32 (LPSTR Name);
Bool hDIBInCache32 (HDIB32 hBMP);
void AddBMPToCache32 (LPSTR Name,HDIB32 hBMP);
Bool RemoveBMPFromCache32 (LPSTR Name);
short CacheAlreadyChecked (LPSTR Name,int lCacheDir,UINT Mode);
void ResetOriginalDrive (void);
long ConvertRectToArea (LPHANDLE phPoints);
HANDLE TransformBitmap (HANDLE hBMP,HANDLE hTran,HANDLE hTranBack,LPMNMXCORD pBounds, LPDOUBLE pRes,LPSTR Namelong, long nAreaPts,HANDLE hAreaPts,Bool DisplayStatus);
void RectToPoints (LPRECT Rect,LPPOINT Points);
void RectToDPoints (LPRECT Rect,LPDPOINT Points);
void RectToBounds (LPRECT Rect,LPMNMXCORD pBounds);
MNMXCORD RotateBounds (LPMNMXCORD pBounds,double Rotation);
int GSSiGetTempFileName (BYTE Drive,LPSTR Pre,UINT Unique,LPSTR Name);
Bool GetTempDir (LPSTR Dir);
Bool GetCacheDir (LPSTR Dir);
short CompressCensusString (LPSTR pStr);
short ExpandCensusString (LPSTR pStr);
int CompressByteArray (LPBYTE pMem,LPBYTE pMemCmp,int lMem);
int DeCompressByteArray (LPBYTE pMemCmp,LPBYTE pMem,int lMem);
int OpenJournal (LPSTR Name,HFILE Fid,UINT Mode);
Bool CloseJournal (HFILE Fid);
Bool ApplyJournal (LPSTR JournalFileName);
void FileWillBeCreated (LPSTR Name);
void FileOpenForUpdate (LPSTR Name,HFILE Fid,UINT Mode);
void SaveDataToUndoFile (short Type,short UndoFileID, long len, HPSTR pData,long SeekLoc);
void CheckPointBegin (void);
void CheckPointEnd (void);
Bool CreateUndoPoint (LPSTR Name);
void RemoveUndoPoint (void);
long GetSizeAtLastUndoPoint (short UndoFileID);
Bool UndoAction (HFILE FidUndo);
Bool UndoChanges (HWND hWnd);
HFILE GetUndoFid (short UndoFileID);
Bool GetUndoData (HFILE Fid,HPSTR pData,long length,long FirstPiece,Bool Remove);
Bool GetUndoFileNameFromUndoFileID (short UndoFileID,LPSTR Name);
short GetUndoFileIDFromName (LPSTR Name,Bool Add);
short GetUndoFileIDFromFid (HFILE Fid);
void AddToChangedGlobalList (HANDLE handle);
void AddToUndoFreeSpace (HFILE Fid,long loc,long len);
DWORD NextVarTime(void);   
long WriteToUndoFile (HFILE Fid,HPSTR pData,long len);
Bool OpenHighlightList(LPSTR Name1, LPSTR Name2);
void CloseHighlightList(void);
void AddFileToUndoFile (LPSTR Name,long BeginLoc,HFILE Fid);
void DisableUndo (Bool Disable);
void UndoAddWindow (HWND hWnd);
void UndoRemoveWindow (HWND hWnd);
void AdjustDIBColors (HANDLE hDib);   
HDIB32 AdjustDIB32Colors (HDIB32 hDib32);   
COLORREF ConvertToGray (COLORREF);
RGBTRIPLE ConvertToGrayTriple (RGBTRIPLE color3);
double DistToGray (short R, short G, short B, short Gray);
//Bool CopyDib2 (HANDLE hdib,LPHANDLE phDibInfo, LPHANDLE phImage);
void BiasPoly (HANDLE hDPoints,long np,double xbias,double ybias);
RECT GetPolyBounds (HANDLE hPoly,long np);
RECT GetPolyBounds2 (LPPOINT Poly,long np);
void GetPolyBoundsD (HANDLE hPoly,long np,LPMNMXCORD pBounds,int Type);
void GetPolyBoundsD2 (LPDPOINT Poly,long np,LPMNMXCORD pBounds,int Type);
HANDLE	GetOffsetPoly (LPDPOINT pPoints,int nPoints,LPINT pnOffPoints,double Offset);
//Bool GetFile32 (short Opt,LPOPENFILENAME pof,DWORD lFilters);
Bool GetShortPathName2 (LPSTR Name,short MaxLen);
int GetLongPathName2 (LPSTR Name,short MaxLen);
int GetLongPathName3 (LPSTR Name,short MaxLen);
int GetLongPathFromBuffer (LPSTR Name,short MaxLen);
int FlushFile (HFILE Fid);
Bool LoadGM32Lib (Bool Close);
Bool GSSiGetFileName (short opt,HWND hWnd,HINSTANCE hInstance,LPSTR PathName,LPCSTR Filters,DWORD lFilters,LPCSTR InitialDir,LPCSTR Title,DWORD Flags);
DWORD CreateLongNameFile (LPSTR Name);
void CheckOpenFiles (void);   
//Bool GSSiPrintDlg (LPPRINTDLG p,LPBool IsVirtualPrinter,LPHANDLE phVirtPrinter,HDC *PrinterDC);
HDC GM32LargeMemDC (HDC hDC16,LPDWORD pMemMapWidth,LPDWORD pMemMapHeight,LPDWORD phOldBitmap);
WORD GM32SaveDCBitMap (HDC hDC16,LPSTR OutFile,long Format,DWORD Flag,DWORD BackgroundColor,
					   HANDLE hOverViewBitmap16,
					   DWORD OverViewTileCol, DWORD OverViewTileRow,
					   DWORD OverViewTileWidth, DWORD OverViewTileHeight,
					   DWORD OverViewBitmapHeight);
DWORD GM32DeleteLargeMemDC (HDC hDC16,DWORD hOldBitmap);
DWORD GM32GetDIBPalette (HDIB32 hDIB,LPLONG pPalletSize,LPRGBQUAD pPalletIn);
DWORD GM32SetDIBPalette(HDIB32 hDIB,DWORD PalletSize,LPRGBQUAD pPalletIn);
DWORD GM32QuantizeDIB (HDIB32 hDIB,DWORD Flag);
DWORD GM32BitmapToDIB(DWORD hBitmap16);
WORD GM32SaveBitmap(HANDLE hBitmap16, LPSTR OutFile, long Format, DWORD Flag);
WORD GM32SaveDIB (HDIB32 hDIB,LPSTR OutFile,long Format,DWORD Flag);
HDIB32 GM32AllocateDIB (DWORD Width,DWORD Height,DWORD BitsPerPixel);
DWORD GM32PasteDIB (HDIB32 ToDIB,HDIB32 FromDIB,DWORD Left,DWORD Top,DWORD Alpha);
int ConvertBitmapColorsInRect (LPSTR BitmapPath,LPMNMXCORD pBounds,COLORREF FromColor,COLORREF ToColor,Bool CountOnly);
int ConvertBitmapColorsInRange(LPSTR BitmapPath, LPSTR ToPath, COLORREF FromColor, COLORREF ToColor, double colordist, LPMNMXCORD pBounds);
DWORD GM32CompressFrame (LPBITMAPINFOHEADER	lpbiIn, LPBITMAPINFOHEADER lpbiOut);
Bool GSSiGetGMCName (HWND hWnd,LPSTR PathName,LPSTR InitialDir,LPSTR Title,LPBool pStartInNewSession,LPBool pRetainZoom,LPBool pLinkZoom,LPSTR NetworkDir,LPSTR PersonalDir);
long GSSiGetDeviceCaps(HDC hPr, int opt); 
DWORD DrawLineWithFlatEnd (HDC hDC,DWORD npt,HPPOINT pPoints16,DWORD Width,COLORREF Color);
DWORD GM32DrawDibOpen (void);
DWORD GM32DrawDibClose (DWORD hdd);
HDC LargeMemDC (HDC hDC16,DWORD * MemMapWidth,DWORD * MemMapHeight,DWORD *pOldBitmap); 
Bool DeleteLargeDC (HDC hDC16,DWORD hOldBitmap);  
Bool SaveDCBitMap (HDC hDC16,LPSTR OutFile,long Format,DWORD Flag,COLORREF BackgroundColor,
						   	 HBITMAP hOverviewBitmap,
						   	 long VirtualPageRow,long VirtualPageCol,
							 long OverViewTileWidth, long OverViewTileHeight, long OverViewBitmapHeight);  
long StretchDIBits32 (HDC hDC,long destX,long destY,long destW,long destH,long xoff,long yoff,long bmwidth,long bmheight,
					  LPBYTE pImage, LPBITMAPINFOHEADER pDibInfo,long ColorType,long RastOpts,LPDOUBLE pFactor,Bool Fast);
long StretchDIBitsFromHandle (HDC hDC,long destX,long destY,long destW,long destH,long source_xoff,long source_yoff,long sourcew,long sourceh,
					 		  HDIB32 hDib, DWORD ColorType,DWORD RasterOpt,double Factor);
int SetCurImage (LPSTR Name);
Bool SaveBitmap (HBITMAP hBitmap,LPSTR OutFile,long Format,DWORD Flag);  
HDIB32 BitmapToDIB_32(HBITMAP hBitmap, HPALETTE hPal);
Bool SaveDIB32(HDIB32 hBitmap, LPSTR OutFile, long Format, DWORD Flag);
HDIB32 AllocateDIB (DWORD Width,DWORD Height,DWORD BitsPerPixel);
Bool PasteDIB (HDIB32 ToDIB,HDIB32 FromDIB,DWORD Left,DWORD Top,DWORD Alpha);
HDIB32 BitmapToDIB32 (HBITMAP hBitmap); 
HDIB32 QuantizeDib (HDIB32 hDib,DWORD Opt); 
HDIB32 QuantizeDibEx (HDIB32 hDib,DWORD Opt,DWORD PalSize,DWORD ResPalSize,RGBQUAD *Pallet);
Bool GetDibPalette (HDIB32 hDib,LPLONG pNumColors,LPRGBQUAD pPalette);
Bool SetDibPalette (HDIB32 hDib,DWORD NumColors,LPRGBQUAD pPalette);   
RGBQUAD RGBTripleToRGBQuad (RGBTRIPLE Trip);
COLORREF RGBTRIPLEToCOLORREF (RGBTRIPLE Trip);
COLORREF RGBQUADToCOLORREF (RGBQUAD Quad);
RGBTRIPLE RGBQuadToRGBTriple (RGBQUAD qcolor);
RGBTRIPLE RGBTRIPLEFromCOLORREF (COLORREF Color);
RGBQUAD RGBQUADFromCOLORREF (COLORREF Color);  
COLORREF COLORREFFromRGBQUAD (RGBQUAD rgbq);
COLORREF COLORREFFromRGBTRIPLE (RGBTRIPLE rgbt);
HDIB32 LoadDIB32(LPSTR lpFileName,Bool AdjustColorsToVP);
HDIB32 GMDestroyDIB32 (HDIB32 hDib);
Bool DestroyDIB32 (HDIB32 hDib,Bool Force);
Bool GetFreeImageVersionAndCopyright (LPSTR Version, LPSTR Copyright) ;
Bool GMFIBMPFromEXT (LPSTR lpszPathName,LPSTR ToMem,DWORD * pSize);
DWORD GMFIGetVersionAndCopyright (LPSTR Version,LPSTR Copyright);
HDIB32  CopyBMP32 (HDIB32 hBitmap,DWORD left,DWORD right, DWORD top, DWORD bottom); 
Bool GetBitmapInfoFromHandle (LPBITMAPINFOHEADER pDibInfo,HDIB32 hDib);
DWORD GM32QuantizeDIBEx (HDIB32 hDIB,DWORD Flag,DWORD PalSize, DWORD ResPalSize, LPRGBQUAD Pallet);
Bool GetGeoTiffData (HDIB32 hBMP,LPDOUBLE pScaleX,LPDOUBLE pScaleY,LPDPOINT pBitmapPoint, LPDPOINT pWorldPoint); 
Bool SetGeoTiffData (HDIB32 hBMP,LPDOUBLE pScaleX,LPDOUBLE pScaleY,LPDPOINT pBitmapPoint, LPDPOINT pWorldPoint); 
Bool GetImageCoord (HANDLE hBMP, LPDPOINT pWorldPoint,LPSTR DateTaken);
HDIB32 Create8BitBMP (HDIB32 dibin,RGBQUAD	*rgbpal, LPLONG plPalette);
HDIB32 Create8BitBMPSixteenth (HDIB32 dibin,RGBQUAD	*rgbpal, LPLONG plPalette,int iSixteenth,LPBool pErr);
HDIB32 LoadImageFromMem (FREE_IMAGE_FORMAT fif, void *pMem, int MemLen,int flags);
Bool SaveImageToMem (FREE_IMAGE_FORMAT fif, FIBITMAP *dib,void *pMem, int *MemLen,int flags);
HANDLE WriteDIBToMem (HDIB32 hDib,int Format, int flags,LPINT pSize);
DWORD GM32Remove (LPSTR Name);
DWORD GM32GetNodeInfo (LPSTR NodeName,LPSTR UserName,LPSTR Winver);
HDIB32 GMFIBMPHandleFromEXT (LPSTR lpszPathName);
Bool GMFIBMPGetBitmapInfo (LPBITMAPINFOHEADER pDibInfoD, HANDLE hDib);
DWORD GM32StretchDIBitsFromHandle (HDC hDC16,long destX,long destY,long destW,long destH,long xoff,
						 long yoff,long sourcew, long sourceh, HANDLE Handle,DWORD ColorType,DWORD RasterOpt,LPDOUBLE pFactorD);
Bool GMFIGetGeoTiffData (HANDLE hBMP,DWORD ShowTag,DWORD pScaleX, DWORD pScaleY, DWORD pBitmapPoint, DWORD pWorldPoint);
DWORD GM32DrawLineWithFlatEnd (HDC hDC16,DWORD npt,LPPOINT pPoints32,DWORD Width,DWORD Color);
HDIB32 LoadDIBFromMem (LPBYTE pMem,int MemLen,int Format,int flags);
HDIB32  BMPHandleFromEXT (LPSTR ImageFile); 
Bool GMFISetGeoTiffData (DWORD hBMP,DWORD pScaleX, DWORD pScaleY, DWORD pBitmapPoint, DWORD pWorldPoint);
HDIB32 GMRotateImageClassic (HDIB32 hDib,double DegreesRotation);
HANDLE GMFreeImageRotateClassic (HANDLE hDIBIn,LPDOUBLE pRotate);
DWORD GMFICopy (DWORD hDIBIn,DWORD left,DWORD right, DWORD top, DWORD bottom);
Bool GMFIBMPFileFromEXT (LPSTR lpszPathName,LPSTR ToFile,double factor);
Bool GMFIBMPToEXT (LPSTR lpszPathName,LPSTR FromMem,DWORD * pSize,DWORD Flag);
Bool GMFIBMPHandleToEXT (LPSTR lpszPathName,HANDLE hBMP,DWORD Flag);
Bool GMSetDIBMonoColors (HANDLE hBMP,LPLONG Colors);
Bool GM32GetGMCName(HWND hWnd16,LPSTR PathName,
								 LPSTR InitialDirIn,LPSTR Title,LPBool pStartInNewSession,LPBool pRetainZoom,LPBool pLinkZoom,LPSTR NetDir,LPSTR PersonalDir);
Bool PickNearestCPTFile (DPOINT Point,LPSTR Filelist,LPSTR IgnoreName,double MaxDist,LPSTR OutLoc);
//DWORD SearchDirectory32 (LPSTR Name,DWORD UseHandle,LPDWORD pType,WIN32_FIND_DATA	*pFindFileData);
DWORD GetSpecialDirectory (LPSTR Name);
Bool GSSiGetNodeInfo (LPSTR CDriveSerno,LPSTR NodeName,LPSTR UserName,LPSTR Winver);
DWORD	GetDriveSerialNumber (LPSTR Drive);
Bool GetDriveLetterFromLocalDriveName (LPSTR Name,LPSTR Drive);
Bool	GetSDChipSerialNumber (LPSTR Drive);
Bool DisplayHTMLHelp (LPSTR HelpFile,LPSTR Topic);
Bool SizeDlgToRect (HWND hWndDlg,LPRECT pRect);
RECT Rect16ToRect32 (RECT16 rect16);
RECT16 Rect32ToRect16 (RECT rect16);
Bool GM32NADCONINIT (LPSTR InitFile);
Bool GMNADCON (LPDPOINT Point,DWORD Dir);
long NumRowsInTxtFile (HFILE Fid);
Bool CompressFrame (LPBITMAPINFOHEADER	lpbiIn, LPBITMAPINFOHEADER lpbiOut);
Bool CompressFrameEX (LPBITMAPINFOHEADER	lpbiIn, LPBITMAPINFOHEADER lpbiOut, long Quality);
Bool SetupVirtualPrinter (HWND hWnd,LPSTR VPName);
int GSSiMsgBox (HWND hWnd, LPSTR Mess, LPSTR Title, UINT Flag,LPSTR Position);
int MessageBoxAtPosition (HWND hWnd, LPSTR Mess, LPSTR Title, UINT Flag,LPSTR Position);
Bool GetPerpendicularIntersect (LPDPOINT Point,LPDPOINT Line,LPDPOINT IntPoint,Bool IncludeDistToEPs);
Bool GetPerpendicularIntersect2 (LPDPOINT Point,LPDPOINT LinePt,LPDOUBLE pLineAZ,LPDPOINT IntPoint);
Bool GetPerpendicularOffsetToPoly (LPDPOINT Point,long nPolyPoints,HPDPOINT PolyPoints,LPDPOINT IntPoint,LPDOUBLE OffDist,LPDOUBLE PolyDist,double LastPolyDist);
void AreaFromLineAndOffset (LPPOINT Line,double Offset,LPPOINT AreaPoints);  
Bool OpenGarminUSB (LPSTR ProductID);
Bool CloseGarminUSB (LPSTR NullArg);
int	Insert (LPSTR Opt,LPSTR File,LPSTR Text);
//HPSTR malloc32 (DWORD Bytes);
//DWORD malloc32free (HPSTR pMem);
time_t GetLastFileWriteTime (LPSTR File,LPLONG pDiffTime);
time_t GetFileCreateTime (LPSTR File,LPLONG pTimeDiff);
Bool GetDirectoryCreateTime (LPSTR File,LPDWORD pLowTime,LPDWORD pHighTime,LPDWORD pTimeDiff);
DWORD MrSidVersion (LPSTR Version);
HDIB32 MrSidOpen (LPSTR File);
DWORD MrSidClose (HDIB32 ImageHandle);
DWORD MrSidGetInfo (HDIB32 ImageHandle,
					LPDWORD pWidth,
					LPDWORD pHeight,
					LPDWORD	pColorSpace,
					LPDWORD	pNumBands,
					LPDWORD	pDataType,
					LPDOUBLE pMinMag,
					LPDOUBLE pMaxMag,
					LPDWORD	pIsLocked,
					LPDOUBLE pULX,
					LPDOUBLE pULY,
					LPDOUBLE pXres,
					LPDOUBLE pYres,
					LPDOUBLE pXRot,
					LPDOUBLE pYRot,
					LPDWORD pNumMetaRecords);
DWORD MrSidGetMetadataRecord(HDIB32 ImageHandle,
                               DWORD recordNum,
                               LPSTR ptag,
                               LPSHORT pdatatype,
                               LPSHORT pnumDims,
                               LPDWORD *ppdims,
                               LPVOID *ppdata);
HDIB32 GMMrSidGetImage (HDIB32 ImageHandle,
					   LPDOUBLE pxUpperLeft,
					   LPDOUBLE pyUpperLeft,
					   LPDWORD pWidth,
					   LPDWORD pHeight,
					   LPDOUBLE pMagnification,
					   DWORD	ConvertToGray,
					   DWORD	Intensity,
					   DWORD DisplayErrorMessage);
HDIB32 MrSidGetImage (HDIB32 ImageHandle,
					LPDOUBLE pULX,
					LPDOUBLE pULY,
					LPDWORD pWidth,
					LPDWORD pHeight,
					LPDOUBLE	pMag,
					DWORD	ConvertToGray,
					DWORD		Intensity);
HDIB32 GMMrSidOpen (LPSTR MrSidFile);
DWORD GMMrSidClose (HDIB32 ImageHandle);
DWORD GMMrSidVersion (LPSTR Version);
DWORD GMMrSidGetImageInfo (HDIB32 ImageHandle,
						   DWORD pWidth,
						   DWORD pHeight,
						   DWORD pColorSpace,
						   DWORD pNumBands,
						   DWORD pDataType,
						   DWORD pMinMag,
						   DWORD pMaxMag,
						   DWORD pIsLocked,
						   DWORD pULX,
						   DWORD pULY,
						   DWORD pXres,
						   DWORD pYres,
						   DWORD pXRot,
						   DWORD pYRot,
						   DWORD pNumMetaRecords
						   );
long Convert_MGRS_To_Geodetic (char* MGRS, 
                               double *Latitude, 
                               double *Longitude);
long GMConvert_Geodetic_To_MGRS (double *Latitude,
                               double *Longitude,
                               long Precision,
                               char* MGRS);
DWORD GMURLDownloadToFile(LPSTR URL,LPSTR File);
Bool GetTXTUniqueFieldValues (HANDLE hDB, LPSTR SQL,LPSTR FldName,short FieldLength, HANDLE hDBList);
Bool GetDBUniqueFieldValues (HANDLE hDB, LPSTR SQL,LPSTR FldName, LPHANDLE phDBList);
DWORD SendEMail (LPSTR cmd);
Bool URLToFile (LPSTR URL,LPSTR File);
LPSTR requestFromURL(LPSTR url);

  void CNGRNT(const double *BX1,const double *BY1,const double *EX1,const double *EY1,
                    const double *BX2,const double *BY2,const double *EX2,const double *EY2,
                    short *N1,short *N2, short *IRC);
                    

 void SECLIN8(const double *X1,const double *Y1,const double *A1,const double *X2,
                    const double *Y2,const double *A2,double *X3,double *Y3,short *K);
                    
 double DSPTLN(const double *X1,const double *Y1,const double *X2,const double *Y2,
                     const double *XP,const double *YP, short *N, short m1);
                      
  double DSTMIN(const double *X1,const double *Y1,const double *X2,const double *Y2,
                      const double *X3,const double *Y3,const double *XP,const double *YP,
                      short *N);
                      
 short INLNCK(const double *BX,const double *BY,const double *EX,const double *EY,
                  const double *PX8,const double *PY8); 
                    
  double DMNMX(const double *X1,const double *Y1,const double *X2,const double *Y2,
                     const double *X3,const double *Y3,const double *X4,const double *Y4,
                     short *N1,short *N2,short *IRC);
                                                                                  
 double DMNMX_TOL(const double *X1,const double *Y1,const double *X2,const double *Y2,
                        const double *X3,const double *Y3,const double *X4,const double *Y4,
                        short *N1,short *N2, const double TOL,short *IRC);
                        
 void XLL(const double *BX1, const double *BY1, const double *EX1, const double *EY1,
                const double *BX2, const double *BY2, const double *EX2, const double *EY2,
                double *X1, double *Y1, double *X2, double *Y2, double *X3, double *Y3, 
                short *N1, short *N2, double *DMN, short *ICD);
         
 void XLC(const double *ldax1,  const double *lday1,
                const double *ldax2,  const double *lday2, const double *ldalngth,
                const double *ldax21, const double *lday21, 
                const double *ldax22, const double *lday22,
                double  *x1, double  *y1, double  *x2,double  *y2,
                double  *x3, double  *y3, short *n1, short *n2,
                double *gap, short *i2);  

 void XCC(const double *c1x,const double *c1y,const double *r1x,const double *r1y,
                const double *cl1,const double *c2x,const double *c2y,const double *r2x,
                const double *r2y,const double *cl2,double *x1, double *y1, 
                double *x2, double *y2, double *x3, double *y3,
                short *n1, short *n2, double *dmn, short *icd);                        
                
 short     INCRVE(const double *CX,
                const double *CY,
                const double *RX,
                const double *RY,
                const double *CL,
                const double *PtX,
                const double *PtY);

HANDLE OpenComm (LPSTR CommID,int buf1,int buf2);
Bool CloseComm (HANDLE Stream);
Bool FoundModem (HANDLE Stream);
int ReadComm (HANDLE Stream,LPBYTE Buffer,int MaxRead);
int WriteComm (HANDLE Stream,LPBYTE Buffer,int MaxRead);
int LogCommIO (int From,LPBYTE Buffer,int BytesRead);
int GetCommEventMask(HANDLE Stream,int EvtToClear);
Bool GetSystemErrMessage (DWORD errorcode,LPSTR Mess);
HWND CreateToolbarWnd (HWND hWnd); 
void AbendWriter (LPSTR Message,LPSTR Title,long at,int type);
int SysMonthFromSymTime (time_t systime);
//Bool CALLBACK CACHEFILEMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam);
//void __cdecl BackgroundCache (LPHANDLE phArgs);
Bool StartBackgroundCache (void);
void StopBackgroundCache (void);
void RenameCachedFiles (LPSTR CacheDir);
HANDLE GetNextXMLElement (HANDLE FileHandle,LPINT pFileLoc,LPSTR TagID);
HANDLE LoadXMLFile (LPSTR File);
Bool GetXMLElementAttribute (HANDLE hElem,LPSTR AttrName,LPSTR AttrValue);
HANDLE GetXMLElementValue (HANDLE hElement);

double ComputeMaxSlope (double frontSlope,double sideSlope);

//2D
float DotVec2(vec2* vec0, vec2* vec1);
void  LerpVec2(vec2* out_lerpedPos, vec2* p0, vec2* p1, float t);
void  NormalizeVec2(vec2* vec);
float MagnitudeVec2(vec2* vec);
void  SubVec2(vec2* out_resultVec, vec2* p0, vec2* p1);
void  SubVec2_Self(vec2* out_resultVec, vec2* p);
void  ScaleVec2_Self(vec2* vec, float scale);
void  ScaleVec2(vec2* out_resultVec, vec2* vec, float scale);
void  AddVec2_Self(vec2* out_resultVec, vec2* vec);
void  AddVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1);
void  AddScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void  AddScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void  SubScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void  SubScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void  CopyVec2(vec2* out_result, vec2* point);
void  CreatePlaneFromPointsVec2(struct PlaneVec2* out_resultPlane, vec2* p0, vec2* p1);
Bool  PointInsidePlaneVec2(vec2* point,struct PlaneVec2* plane);
Bool  PointInsidePlaneVec2(vec2* point, struct PlaneVec2* plane);
float AngleBetweenVec2(vec2* vec0, vec2* vec1);

//3D
void  SetVec3(vec3* out_resultVec,float x, float y, float z);
void  CrossVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1);
float DotVec3(const vec3* vec0, const vec3* vec1);
void  LerpVec3(vec3* out_lerpedPos, const vec3* p0, const vec3* p1, float t);
void  NormalizeVec3(vec3* vec);
float MagnitudeVec3(const vec3* vec);
Bool  PosIsBehind(const vec3* frontPos, const vec3* frontAt, const vec3* behindPos);
float DistSqVec3(const vec3* vec0, const vec3* vec1);
float DistVec3_2D(const vec3* vec0, const vec3* vec1);
float DistVec3(const vec3* vec0, const vec3* vec1);
float MagnitudeSqVec3(const vec3* vec);
void  AddVec3_Self(vec3* out_resultVec, vec3* vec);
void  AddVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1);
void  AddScaledVec3_Self(vec3* out_resultVec, const vec3* vec, float scale);
void  AddScaledVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1, float scale);
void  SubScaledVec3_Self(vec3* out_resultVec, vec3* vec, float scale);
void  SubScaledVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1, float scale);
void  SubVec3(vec3* out_resultVec, const vec3* p0, const vec3* p1);
void  ScaleVec3_Self(vec3* vec, float scale);
void  ScaleVec3(vec3* out_resultVec, const vec3* vec, float scale);
void  CopyVec3(vec3* out_result, const vec3* point);
float AngleBetweenVec3(vec3* vec0, vec3* vec1);
vec3 VectorFromPoints (vec3 * p1, vec3 * p2);
vec3 sVectorFromPoints (svec3 * p1, svec3 * p2);
vec3 GetTriangleNormal (vec3 * vertex1,vec3 * vertex2,vec3 * vertex3);
vec3 sGetTriangleNormal (svec3 * vertex1,svec3 * vertex2,svec3 * vertex3,double metersperpixel);

HANDLE FTPOpen (LPCSTR lpszServerName,LPCSTR lpszUsername,LPCSTR lpszPassword,LPCSTR directory,LPSTR errorVarName,WORD port,Bool passive);
Bool FTPClose (HANDLE h);
HANDLE ListFtpDir(HANDLE hConnection,HANDLE hFind,
				  LPSTR pWildCard,DWORD dwFindFlags,
				  LPSTR fileName,LPDWORD pFileSize,LPDWORD pLastUpdateTime,LPBool pisDirecotry,LPSTR errorVarName);
Bool FTPGetFile(HANDLE hConnect,LPCTSTR lpszRemoteFile,LPCTSTR lpszNewFile,Bool fFailIfExists,Bool showStatus,LPSTR errorVarName);
Bool FTPPutFile(HANDLE hConnect,LPCTSTR lpszRemoteFile,LPCTSTR lpszLocalfile,Bool replace,Bool showStatus,LPSTR errorVarName);
Bool FTPDeleteFile(HANDLE hConnect,LPCTSTR lpszRemoteFile,LPSTR errorVarName);
Bool FTPCreateDirectory(HANDLE hConnect,LPCTSTR lpszRemoteDir,LPSTR errorVarName);
Bool FTPGetDirectory(HANDLE hConnect,LPSTR lpszRemoteDir,LPSTR errorVarName);
Bool FTPSetDirectory(HANDLE hConnect,LPCTSTR lpszRemoteDir,LPSTR errorVarName);
INT64 FTPGetFileSize (HANDLE hConnect);


void  InFunction (int funid,LPSTR inString);
void OutFunction (int funid,LPSTR outString);
void SetFunctionDBIn(LPSTR InLoc);
void SetFunctionDBOut(LPSTR OutLoc);
void DebugReturn(LPSTR rtnValue);
HANDLE CreateVarSpace(int type);
void DestroyVarSpace(HANDLE hVarSpace);
void SetVarSpace(int type, HANDLE hVarSpace);
int AddToMacroStack(int from, int iCurrentMacro, LPSTR File, LPHANDLE phArgs, int NumArgs);
void RemoveFromMacroStack (int macroID);
Bool AddBreakpoint(LPSTR macroFile, int insertLoc);
void setMacroBrkPtHandle(int macroID, HANDLE hBreakPoints, int lnBP);
void breakAtPos(int pos, LPBREAKPOINT pBrkPt, int bpOffset, int bpLen, int from);
void AtBreakPoint(LPSTR Args,int bploc);
void SetDebug (Bool state);
Bool GetDebug (void);
Bool getDebugMacro(int macroID);
void debugFile(LPSTR id, LPSTR text);
void GetWindowsVersion(LPSTR Ver);
int ChassisType(void); // returns -1 if error, 1 for desktop, 2 for laptop, 3 for handheld and 4 for other
int MonitorType(int which,LPSTR monName);
int GetMouseType(void);
int GetNumMonitors(void);
//HMONITOR GetOtherMonitor(POINT pt);
Bool IsPointOnTouchScreen(HWND hWnd,POINT pt);

//int wlanGetCurrentSSID(char * pSSID, int maxSSID, GUID *pInterfaceGuid);
//int getipAddressForAdapter(LPSTR ipAddress, GUID *pInterfaceGuid);

int GetWifiName(LPSTR Name);
int GetWifiAddress(LPSTR address);

/*int mainlaszip(int argc, char *argv[]);
Bool getLAZMinMax(char * file, double * xmin, double * xmax, double * ymin, double * ymax, double * zmin, double * zmax);
int getLAZPointsInBounds(LPLAZFILESTRUCT pFiles, int fileNum, char * file, int wantType, LPMNMXCORD pBounds, int maxPoints, LPDPOINT3D points);
int writeLAZFileToText(char * file, int wantType, char * outFile);
int classifyLAZFile(char * file, char * outFile);*/

LPSTR _fullpath (LPSTR fullpath,LPSTR path,int maxpath);
void _splitpath (LPSTR PathName,LPSTR drive,LPSTR dir,LPSTR fname,LPSTR ext);
LPSTR _itoa (int i,LPSTR str, int radix);
LPSTR _ltoa (long i,LPSTR str, int radix);
LPSTR _ultoa (unsigned long i,LPSTR str, int radix);

DWORD GetTempPath (int len,LPSTR OutStr);

SQLRETURN   SQLCancel(SQLHSTMT StatementHandle);
SQLRETURN   SQLCancelHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle);
SQLRETURN   SQLCloseCursor(SQLHSTMT StatementHandle);
SQLRETURN   SQLFreeConnect(SQLHDBC ConnectionHandle);
SQLRETURN   SQLFreeEnv(SQLHENV EnvironmentHandle);
SQLRETURN   SQLFreeHandle(SQLSMALLINT HandleType, SQLHANDLE Handle);
SQLRETURN   SQLFreeStmt(SQLHSTMT StatementHandle,
                               SQLUSMALLINT Option);
/*
 * Listbox Return Values
 */
#define LB_OKAY             0
#define LB_ERR              (-1)
#define LB_ERRSPACE         (-2)

/*
 * Listbox Notification Codes
 */
#define LBN_ERRSPACE        (-2)
#define LBN_SELCHANGE       1
#define LBN_DBLCLK          2
#define LBN_SELCANCEL       3
#define LBN_SETFOCUS        4
#define LBN_KILLFOCUS       5


/*
 * Listbox messages
 */
#define LB_ADDSTRING            0x0180
#define LB_INSERTSTRING         0x0181
#define LB_DELETESTRING         0x0182
#define LB_SELITEMRANGEEX       0x0183
#define LB_RESETCONTENT         0x0184
#define LB_SETSEL               0x0185
#define LB_SETCURSEL            0x0186
#define LB_GETSEL               0x0187
#define LB_GETCURSEL            0x0188
#define LB_GETTEXT              0x0189
#define LB_GETTEXTLEN           0x018A
#define LB_GETCOUNT             0x018B
#define LB_SELECTSTRING         0x018C
#define LB_DIR                  0x018D
#define LB_GETTOPINDEX          0x018E
#define LB_FINDSTRING           0x018F
#define LB_GETSELCOUNT          0x0190
#define LB_GETSELITEMS          0x0191
#define LB_SETTABSTOPS          0x0192
#define LB_GETHORIZONTALEXTENT  0x0193
#define LB_SETHORIZONTALEXTENT  0x0194
#define LB_SETCOLUMNWIDTH       0x0195
#define LB_ADDFILE              0x0196
#define LB_SETTOPINDEX          0x0197
#define LB_GETITEMRECT          0x0198
#define LB_GETITEMDATA          0x0199
#define LB_SETITEMDATA          0x019A
#define LB_SELITEMRANGE         0x019B
#define LB_SETANCHORINDEX       0x019C
#define LB_GETANCHORINDEX       0x019D
#define LB_SETCARETINDEX        0x019E
#define LB_GETCARETINDEX        0x019F
#define LB_SETITEMHEIGHT        0x01A0
#define LB_GETITEMHEIGHT        0x01A1
#define LB_FINDSTRINGEXACT      0x01A2
#define LB_SETLOCALE            0x01A5
#define LB_GETLOCALE            0x01A6
#define LB_SETCOUNT             0x01A7


HMENU CreateMenu(void);
HMENU CreatePopupMenu (void);
Bool  AppendMenu(HMENU hMenu,UINT uFlags,UINT_PTR uIDNewItem,LPCSTR lpNewItem);


#endif
