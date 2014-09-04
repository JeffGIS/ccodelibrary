//  CCodeTypes.h
//  CCodeLibrary

#ifndef CCodeLibrary_CCodeTypes_h
#define CCodeLibrary_CCodeTypes_h

#include <stdbool.h>

typedef char * LPSTR;
typedef LPSTR HPSTR;
#ifndef BOOL
#define BOOL int
#endif
#define TRUE 1
#define FALSE 0
typedef void *LPVOID;
typedef int HWND;
typedef unsigned int DWORD;
typedef unsigned char *LPBYTE;

#endif