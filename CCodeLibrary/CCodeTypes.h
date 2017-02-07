//  CCodeTypes.h
//  CCodeLibrary

#ifndef CCodeLibrary_CCodeTypes_h
#define CCodeLibrary_CCodeTypes_h
#include <stdbool.h>

#define MAX_PATH	260
#define _MAX_PATH   260
#define LF_FACESIZE         32


typedef unsigned int HANDLE;
typedef HANDLE *LPHANDLE;
//typedef bool    BOOL;
typedef int    *LPBOOL;
typedef int * LPINT;
typedef short * LPSHORT;
typedef char *LPSTR;
typedef LPSTR HPSTR;
#define TRUE 1
#define FALSE 0
typedef void *LPVOID;
typedef int HWND;
typedef unsigned int UINT;
typedef unsigned int DWORD;
typedef int LONG;
typedef unsigned short WORD;
typedef unsigned char BYTE;
typedef int *LPLONG;
typedef unsigned int ULONG_PTR, *PULONG_PTR;
typedef ULONG_PTR DWORD_PTR;
typedef unsigned short WORD;
typedef unsigned int DWORD;
typedef unsigned char BYTE;
typedef unsigned char *LPBYTE;
typedef struct {double x,y;}DPOINT;
typedef struct {double x,y,z;}DPOINT3D;
typedef struct {int x,y;}POINT;
typedef POINT *LPPOINT;
typedef struct {DPOINT nearLeft,farLeft,farRight,nearRight;}CORNERPOINTS;
typedef struct {double lon,lat;}LLPOINT;
typedef DPOINT3D *LPDPOINT3D;
typedef DPOINT *LPDPOINT;
typedef DPOINT *HPDPOINT;
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

#define BI_RGB 0

#pragma pack(1)

typedef struct tagBITMAPFILEHEADER {
    WORD bfType;
    DWORD bfSize;
    WORD bfReserved1;
    WORD bfReserved2;
    DWORD bfOffBits;
} BITMAPFILEHEADER;

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
#pragma pack()


#endif
