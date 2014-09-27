//  CCodeTypes.h
//  CCodeLibrary

#ifndef CCodeLibrary_CCodeTypes_h
#define CCodeLibrary_CCodeTypes_h
#define MAKELONG(a, b)((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) | ((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
#define LOWORD(l)((WORD)(((DWORD_PTR)(l)) & 0xffff))
#define HIWORD(l)((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))

typedef char *LPSTR;
typedef LPSTR HPSTR;
#define TRUE 1
#define FALSE 0
typedef void *LPVOID;
typedef int HWND;
typedef unsigned int DWORD;
typedef unsigned char *LPBYTE;
typedef struct {double x,y;}DPOINT;
typedef struct {double lon,lat;}LLPOINT;
typedef DPOINT *LPDPOINT;
typedef LLPOINT *LPLLPOINT;
typedef float *LPFLOAT;
typedef double *LPDOUBLE;
typedef struct{int x, y;}IPOINT;
typedef IPOINT *LPIPOINT;
typedef struct
{
    int xmn;
    int ymn;
    int xmx;
    int ymx;
}  IBOUNDS;
typedef IBOUNDS LPIBOUNDS;
typedef struct{short x, y;}SPOINT;
typedef SPOINT *LPSPOINT;
typedef struct{unsigned char x, y;}BPOINT;
typedef struct{char x:4 ,y:4;}CPOINT;
typedef BPOINT *LPBPOINT;
typedef CPOINT *LPCPOINT;
#endif