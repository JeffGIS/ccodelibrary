//  CCodeTypes.h
//  CCodeLibrary
#ifndef CCodeLibrary_CCodeTypes_h
#define CCodeLibrary_CCodeTypes_h
#include <stdbool.h>

#define FAR
#define NEAR

#define _fstrncpy strncpy
#define _fstrncmp strncmp
#define _fstrnicmp strnicmp
#define _fstrlen strlen
#define _fstrcmp strcmp
#define _fstrcpy strcpy
#define _fstrstr strstr
#define _fstrlwr strlwr
#define _strlwr  strlwr
#define _fstrcat strcat
#define _fstrupr strupr
#define _strupr   strupr
#define _fstrchr strchr
#define _fstrrchr strrchr
#define _fstricmp stricmp
#define _fstrcspn strcspn
#define _fstrncat strncat
#define _fstrspn strspn
#define _fstrpbrk strpbrk
#define _fmemccpy memccpy
#define _fmemmove memmove
#define hmemmove memmove
#define _fmemcpy memcpy
#define _fstrset strset
#define _fmemicmp memicmp
#define _fmemcmp memcmp
#define hmemcpy memcpy
#define _fmemset memset
#define stricmp strcasecmp
#define _stricmp strcasecmp
#define strnicmp strncasecmp
#define _strnicmp strncasecmp

#define MAX_PATH	260
#define _MAX_PATH   260
#define LF_FACESIZE         32

#define CONST   const
typedef unsigned int WPARAM;
typedef unsigned int LPARAM;
typedef int DLGPROC;
typedef int Bool;
typedef Bool *LPBool;
typedef short BOOL16;
typedef int SOCKET;
typedef int RETCODE;
typedef long long HANDLE;
typedef	HANDLE	HGLOBAL;
typedef HANDLE  HINSTANCE;
typedef HANDLE	HFONT;
typedef HANDLE	HDC;
typedef HANDLE  HCURSOR;
typedef HANDLE	HRGN;
typedef HANDLE  HBITMAP;
typedef HANDLE *LPHANDLE;
typedef HANDLE  HACCEL;
typedef HANDLE	HGDIOBJ;
typedef unsigned int DWORD ;
typedef DWORD   *LPDWORD;
typedef int     COLORREF;
typedef COLORREF *LPCOLORREF;
typedef int     HRESULT;
typedef int     LRESULT;
typedef int HFILE;
typedef HANDLE HMENU;
typedef struct {
    int left,top,right,bottom;
} RECT;
typedef RECT *LPRECT;
typedef struct {
    short left,top,right,bottom;
} RECT16;
typedef RECT16 *LPRECT16;
typedef char CHAR;
typedef HANDLE *LPHANDLE;
typedef int    *LPBOOL;
typedef int * LPINT;
typedef unsigned int UINT;
typedef UINT * LPUINT;
typedef short * LPSHORT;
#define CONST	const
typedef int HFILE;
typedef float FLOAT;
typedef char *LPSTR;
typedef char const *LPCSTR;
typedef LPCSTR  LPCTSTR;
typedef short SHORT;
typedef short *LPSHORT;
typedef	unsigned char BYTE;
typedef void *LPVOID;
typedef int	COLORREF;

typedef LPSTR HPSTR;
#define TRUE 1
#define FALSE 0
typedef void *LPVOID;
typedef int HWND;
typedef unsigned int UINT;
typedef long LONG;
typedef unsigned short WORD;
typedef WORD    SWORD;
typedef unsigned char BYTE;
typedef long *LPLONG;
typedef unsigned long ULONG_PTR, *PULONG_PTR;
typedef ULONG_PTR DWORD_PTR;
typedef unsigned short WORD;
typedef WORD *LPWORD;
typedef unsigned char BYTE;
typedef unsigned char *LPBYTE;
typedef struct {double x,y;}DPOINT;
typedef struct {double x,y,z;}DPOINT3D;
typedef struct {int x,y;}POINT;
typedef POINT *LPPOINT;
typedef struct {double lon,lat;}LLPOINT;
typedef struct{float x,y;}  FLTPOINT;
typedef struct{short x,y;}  POINTS;
typedef POINTS  *LPPOINTS;
typedef struct{long x,y;} LPOINT;
typedef LPOINT  			*LPLPOINT;
typedef LPOINT  			*HPLPOINT;

typedef struct {DPOINT nearLeft,farLeft,farRight,nearRight;}CORNERPOINTS;
typedef struct {LLPOINT nearLeft,farLeft,farRight,nearRight;}LLCORNERPOINTS;
typedef DPOINT3D *LPDPOINT3D;
typedef DPOINT *LPDPOINT;
typedef DPOINT *HPDPOINT;
typedef LLPOINT *LPLLPOINT;
typedef float   FLOAT;
typedef float *LPFLOAT;
typedef double *LPDOUBLE;
typedef struct{int x, y;}IPOINT;
typedef IPOINT *LPIPOINT;
typedef struct{short x, y;}SPOINT;
typedef SPOINT *LPSPOINT;
typedef struct{unsigned char x, y;}BPOINT;
typedef struct{char x:4 ,y:4;}CPOINT;
typedef BPOINT *LPBPOINT;
typedef CPOINT *LPCPOINT;
typedef struct
{    double  xmn;
    double  ymn;
    double  xmx;
    double  ymx;
} MNMXCORD;
typedef MNMXCORD    FAR *LPMNMXCORD;
typedef MNMXCORD	*HPMNMXCORD;
typedef struct
{    double  xmn;
    double  ymn;
    double  zmn;
    double  xmx;
    double  ymx;
    double  zmx;
} MNMXCORD3D;
typedef MNMXCORD3D    FAR *LPMNMXCORD3D;
typedef struct
{	short	xmn;
    short	ymn;
    short	xmx;
    short	ymx;
} mnmxCor;
typedef mnmxCor FAR	*LPMINMAX;
typedef struct
{	int	xmn;
    int	ymn;
    int	xmx;
    int	ymx;
} MNMXCORL;
typedef MNMXCORL FAR  *LPMNMXCORL;

#include "MathTypes.h"

#define MAKELONG(a, b)((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) | ((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
#define LOWORD(l)((WORD)(((DWORD_PTR)(l)) & 0xffff))
#define HIWORD(l)((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))

#define BI_RGB 0

#pragma pack(1)
typedef struct
{
    unsigned char cRed;
    unsigned char cGreen;
    unsigned char cBlue;
}COLORREF_RGB;
typedef struct
{
    unsigned char cRed;
    unsigned char cGreen;
    unsigned char cBlue;
    unsigned char cIntensity;
}COLORREF_RGB4;
typedef COLORREF_RGB4   RGBQUAD;
typedef RGBQUAD *LPRGBQUAD;

typedef struct tagBITMAPFILEHEADER {
    WORD bfType;
    DWORD bfSize;
    WORD bfReserved1;
    WORD bfReserved2;
    DWORD bfOffBits;
} BITMAPFILEHEADER;
typedef BITMAPFILEHEADER *LPBITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER {
    DWORD biSize;
    LONG biWidth;
    LONG biHeight;
    WORD biPlanes;
    WORD biBitCount;
    DWORD biCompression;
    DWORD biSizeImage;
    LONG biXPelsPerMeter;
    LONG biYPelsPerMeter;
    DWORD biClrUsed;
    DWORD biClrImportant;
} BITMAPINFOHEADER;
typedef BITMAPINFOHEADER *LPBITMAPINFOHEADER;
typedef struct {
    BITMAPINFOHEADER bmiHeader;
    RGBQUAD bmiColors[1];
} BITMAPINFO;
typedef BITMAPINFO *LPBITMAPINFO;

#pragma pack()
/* Global Memory Flags */
#define GMEM_FIXED          0x0000
#define GMEM_MOVEABLE       0x0002
#define GMEM_NOCOMPACT      0x0010
#define GMEM_NODISCARD      0x0020
#define GMEM_ZEROINIT       0x0040
#define GMEM_MODIFY         0x0080
#define GMEM_DISCARDABLE    0x0100
#define GMEM_NOT_BANKED     0x1000
#define GMEM_SHARE          0x2000
#define GMEM_DDESHARE       0x2000
#define GMEM_NOTIFY         0x4000
#define GMEM_LOWER          GMEM_NOT_BANKED
#define GMEM_VALID_FLAGS    0x7F72
#define GMEM_INVALID_HANDLE 0x8000

#define GHND                (GMEM_MOVEABLE | GMEM_ZEROINIT)
#define GPTR                (GMEM_FIXED | GMEM_ZEROINIT)

#define OF_READ             0x00000000
#define OF_WRITE            0x00000001
#define OF_READWRITE        0x00000002
#define OF_SHARE_COMPAT     0x00000000
#define OF_SHARE_EXCLUSIVE  0x00000010
#define OF_SHARE_DENY_WRITE 0x00000020
#define OF_SHARE_DENY_READ  0x00000030
#define OF_SHARE_DENY_NONE  0x00000040
#define OF_PARSE            0x00000100
#define OF_DELETE           0x00000200
#define OF_VERIFY           0x00000400
#define OF_CANCEL           0x00000800
#define OF_CREATE           0x00001000
#define OF_PROMPT           0x00002000
#define OF_EXIST            0x00004000
#define OF_REOPEN           0x00008000

#define HFILE_ERROR -1

/*
 * MessageBox() Flags
 */
#define MB_OK                       0x00000000L
#define MB_OKCANCEL                 0x00000001L
#define MB_ABORTRETRYIGNORE         0x00000002L
#define MB_YESNOCANCEL              0x00000003L
#define MB_YESNO                    0x00000004L
#define MB_RETRYCANCEL              0x00000005L
#define MB_CANCELTRYCONTINUE        0x00000006L


#define MB_ICONHAND                 0x00000010L
#define MB_ICONQUESTION             0x00000020L
#define MB_ICONEXCLAMATION          0x00000030L
#define MB_ICONASTERISK             0x00000040L

#define MB_USERICON                 0x00000080L
#define MB_ICONWARNING              MB_ICONEXCLAMATION
#define MB_ICONERROR                MB_ICONHAND
#define MB_ICONINFORMATION          MB_ICONASTERISK
#define MB_ICONSTOP                 MB_ICONHAND

#define MB_DEFBUTTON1               0x00000000L
#define MB_DEFBUTTON2               0x00000100L
#define MB_DEFBUTTON3               0x00000200L
#define MB_DEFBUTTON4               0x00000300L

#define MB_APPLMODAL                0x00000000L
#define MB_SYSTEMMODAL              0x00001000L
#define MB_TASKMODAL                0x00002000L
#define MB_HELP                     0x00004000L // Help Button
#define MB_NOFOCUS                  0x00008000L
#define MB_SETFOREGROUND            0x00010000L
#define MB_DEFAULT_DESKTOP_ONLY     0x00020000L

#define MB_TOPMOST                  0x00040000L
#define MB_RIGHT                    0x00080000L
#define MB_RTLREADING               0x00100000L

#define IDOK                1
#define IDCANCEL            2
#define IDABORT             3
#define IDRETRY             4
#define IDIGNORE            5
#define IDYES               6
#define IDNO                7
#define IDCLOSE         8
#define IDHELP          9

typedef long            SQLINTEGER;
typedef unsigned long   SQLUINTEGER;
typedef unsigned char   SQLNUMERIC;
typedef void *          SQLPOINTER;

typedef float           SQLREAL;

typedef short           SQLSMALLINT;
typedef unsigned short  SQLUSMALLINT;

typedef unsigned char   SQLTIME;
typedef unsigned char   SQLTIMESTAMP;
typedef unsigned char   SQLVARCHAR;


/* function return type */
typedef SQLSMALLINT     SQLRETURN;

#define SQL_CLOSE           0
#define SQL_DROP            1
#define SQL_UNBIND          2
#define SQL_RESET_PARAMS    3
/* special length/indicator values */
#define SQL_NULL_DATA               (-1)
#define SQL_DATA_AT_EXEC            (-2)


/* return values from functions */
#define SQL_SUCCESS                 0
#define SQL_SUCCESS_WITH_INFO       1
#define SQL_NO_DATA                 100

#define SQL_PARAM_DATA_AVAILABLE    101
#define SQL_ERROR                   (-1)
#define SQL_INVALID_HANDLE          (-2)

#define SQL_STILL_EXECUTING         2
#define SQL_NEED_DATA               99

/* test for SQL_SUCCESS or SQL_SUCCESS_WITH_INFO */
#define SQL_SUCCEEDED(rc)  (((rc)&(~1))==0)

/* flags for null-terminated string */
#define SQL_NTS                     (-3)
#define SQL_NTSL                    (-3L)

/* maximum message length */
#define SQL_MAX_MESSAGE_LENGTH      512
typedef SQLINTEGER              SQLHANDLE;
typedef SQLHANDLE               SQLHENV;
typedef SQLHANDLE               SQLHDBC;
typedef SQLHANDLE               SQLHSTMT;
typedef SQLHANDLE               SQLHDESC;

/*
 * Menu flags for Add/Check/EnableMenuItem()
 */
#define MF_INSERT           0x00000000L
#define MF_CHANGE           0x00000080L
#define MF_APPEND           0x00000100L
#define MF_DELETE           0x00000200L
#define MF_REMOVE           0x00001000L

#define MF_BYCOMMAND        0x00000000L
#define MF_BYPOSITION       0x00000400L

#define MF_SEPARATOR        0x00000800L

#define MF_ENABLED          0x00000000L
#define MF_GRAYED           0x00000001L
#define MF_DISABLED         0x00000002L

#define MF_UNCHECKED        0x00000000L
#define MF_CHECKED          0x00000008L
#define MF_USECHECKBITMAPS  0x00000200L

#define MF_STRING           0x00000000L
#define MF_BITMAP           0x00000004L
#define MF_OWNERDRAW        0x00000100L

#define MF_POPUP            0x00000010L
#define MF_MENUBARBREAK     0x00000020L
#define MF_MENUBREAK        0x00000040L

#define MF_UNHILITE         0x00000000L
#define MF_HILITE           0x00000080L


#define MF_DEFAULT          0x00001000L

#define MF_SYSMENU          0x00002000L
#define MF_HELP             0x00004000L

#define MF_RIGHTJUSTIFY     0x00004000L

#define MF_MOUSESELECT      0x00008000L

#define MF_END              0x00000080L  /* Obsolete -- only used by old RES files */


typedef int INT_PTR, *PINT_PTR;
typedef unsigned int UINT_PTR, *PUINT_PTR;

typedef long LONG_PTR, *PLONG_PTR;
typedef unsigned long ULONG_PTR, *PULONG_PTR;

#define IDC_WAIT    1

LPSTR strlwr (LPSTR str);
LPSTR strupr (LPSTR str);

typedef signed long 		SLONG;
typedef signed short		SSHORT;
typedef unsigned long		ULONG;
typedef HFILE				FAR *LPHFILE;
typedef ULONG				FAR *LPULONG;
typedef ULONG				*HPULONG;
typedef unsigned short		USHORT;
typedef USHORT				FAR	*LPUSHORT;
typedef USHORT				*HPUSHORT;
typedef char				*HPSTR;
typedef short				*HPSHORT;
typedef long				*HPLONG;
typedef WORD				*HPWORD;
typedef unsigned char		*HPBYTE;
typedef int					HBRUSH;
typedef int					HPEN;
typedef HBRUSH				FAR	*LPHBRUSH;
typedef HPEN				FAR	*LPHPEN;
typedef short				FAR *LPSHORT;
typedef float			 	FAR *LPFLOAT;
typedef float   			*HPFLOAT;
typedef double  			FAR *LPDOUBLE;
typedef double  			*HPDOUBLE;
//typedef struct{double x,y;} DPOINT;
typedef DPOINT  			FAR *LPDPOINT;
typedef DPOINT  			*HPDPOINT;
typedef POINTS				*HPPOINTS;
//typedef struct{double x,y,z;} DPOINT3D;
typedef DPOINT3D  			FAR *LPDPOINT3D;
typedef DPOINT3D  			*HPDPOINT3D;
typedef DPOINT				FPOINT;
typedef FPOINT  			FAR *LPFPOINT;
typedef FPOINT  			*HPFPOINT;
//typedef struct{float x,y;}  FLTPOINT;
typedef FLTPOINT			*LPFLTPOINT;
typedef POINT				*HPPOINT;
typedef void				* LPHUGE;
//typedef struct{long x,y;} LPOINT;
//typedef LPOINT  			FAR *LPLPOINT;
//typedef LPOINT  			*HPLPOINT;
typedef HANDLE				HDIB32;
typedef HDIB32				FAR *LPHDIB32;
typedef RECT				*HPRECT;


#define MAKEWORD(a, b)      ((WORD)(((BYTE)(((DWORD_PTR)(a)) & 0xff)) | ((WORD)((BYTE)(((DWORD_PTR)(b)) & 0xff))) << 8))
#define MAKELONG(a, b)      ((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) | ((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
#define LOWORD(l)           ((WORD)(((DWORD_PTR)(l)) & 0xffff))
#define HIWORD(l)           ((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))
#define LOBYTE(w)           ((BYTE)(((DWORD_PTR)(w)) & 0xff))
#define HIBYTE(w)           ((BYTE)((((DWORD_PTR)(w)) >> 8) & 0xff))
#define RGB(r,g,b)          ((COLORREF)(((BYTE)(r)|((WORD)((BYTE)(g))<<8))|(((DWORD)(BYTE)(b))<<16)))

#define GetRValue(rgb)      (LOBYTE(rgb))
#define GetGValue(rgb)      (LOBYTE(((WORD)(rgb)) >> 8))
#define GetBValue(rgb)      (LOBYTE((rgb)>>16))

#endif
