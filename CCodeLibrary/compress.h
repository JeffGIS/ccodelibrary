//  compress.h
//  CCodeLibrary

#ifndef CCodeLibrary_compress_h
#define CCodeLibrary_compress_h

#include "CCodeTypes.h"

int GetFileFromTransferFile (HWND hWndStatus,FILE * FidTF,LPSTR FileToGet,long LenToRead,long MaxLength);
int DecompressGMZipFile (char * TransferFileName,char * toDirectory);

#endif