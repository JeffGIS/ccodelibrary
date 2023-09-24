//  compress.h
//  CCodeLibrary

#ifndef CCodeLibrary_compress_h
#define CCodeLibrary_compress_h
#import "CCodeTypes.h"

int InitLZO (void);
int DecompressBinaryRecordUnsafe (LPBYTE pDecompressedRec, LPBYTE pCompressedRec, DWORD CompressedLen);

int GetFileFromTransferFile(HWND hWndStatus, FILE *FidTF, LPSTR FileToGet, long MaxLength,int useGZIP);
int DecompressGMZipFile(char *TransferFileName, char *toDirectory,long offset,int nfilestodecompress,LPSTR outFilePath);
int ZLibUncompress(BYTE* target, long target_size, BYTE* source, long source_size);

#endif
