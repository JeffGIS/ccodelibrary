//  compress.h
//  CCodeLibrary

#ifndef CCodeLibrary_compress_h
#define CCodeLibrary_compress_h

#include "CCodeTypes.h"

BOOL GetFileFromTransferFile (HWND hWndStatus,FILE * FidTF,LPSTR FileToGet,long LenToRead,long MaxLength);
BOOL DecompressGMZipFile (char * TransferFileName);

#endif