//  compress.h
//  CCodeLibrary

#ifndef CCodeLibrary_compress_h
#define CCodeLibrary_compress_h
#import "CCodeTypes.h"

int InitLZO (void);
int DecompressBinaryRecordUnsafe (LPBYTE pDecompressedRec, LPBYTE pCompressedRec, DWORD CompressedLen);

int GetFileFromTransferFile(HWND hWndStatus, FILE *FidTF, LPSTR FileToGet, long MaxLength);
int DecompressGMZipFile(char *TransferFileName, char *toDirectory,long offset,int nfilestodecompress,LPSTR outFilePath);

#endif
