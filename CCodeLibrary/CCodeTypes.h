//  CCodeTypes.h
//  CCodeLibrary

#ifndef CCodeLibrary_CCodeTypes_h
#define CCodeLibrary_CCodeTypes_h

typedef int * LPINT;
typedef char *LPSTR;
typedef LPSTR HPSTR;
#define TRUE 1
#define FALSE 0
typedef void *LPVOID;
typedef int HWND;
typedef unsigned long LONG;
typedef unsigned long ULONG_PTR, *PULONG_PTR;
typedef ULONG_PTR DWORD_PTR;
typedef unsigned short WORD;
typedef unsigned long DWORD;
typedef unsigned char BYTE;
typedef unsigned char *LPBYTE;
typedef struct {double x,y;}DPOINT;
typedef struct {double lon,lat;}LLPOINT;
typedef DPOINT *LPDPOINT;
typedef LLPOINT *LPLLPOINT;
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
#include "MathTypes.h"

#define MAKELONG(a, b)((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) | ((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
#define LOWORD(l)((WORD)(((DWORD_PTR)(l)) & 0xffff))
#define HIWORD(l)((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))

#endif