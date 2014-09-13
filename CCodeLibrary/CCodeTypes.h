//  CCodeTypes.h
//  CCodeLibrary

#ifndef CCodeLibrary_CCodeTypes_h
#define CCodeLibrary_CCodeTypes_h


typedef char * LPSTR;
typedef LPSTR HPSTR;
#define TRUE    1
#define FALSE   0
typedef void * LPVOID;
typedef int HWND;
typedef unsigned int DWORD;
typedef unsigned char *LPBYTE;
typedef struct{double x,y;} DPOINT;
typedef struct{double lon,lat;} LLPOINT;
typedef DPOINT *LPDPOINT;
typedef LLPOINT *LPLLPOINT;
typedef float *LPFLOAT;
typedef double *LPDOUBLE;


#endif