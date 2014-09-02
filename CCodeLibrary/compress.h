//
//  compress.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/2/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#ifndef CCodeLibrary_compress_h
#define CCodeLibrary_compress_h

#include "CCodeTypes.h"

BOOL GetFileFromTransferFile (HWND hWndStatus,FILE * FidTF,LPSTR FileToGet,long LenToRead,long MaxLength);
BOOL DecompressGMZipFile (char * TransferFileName);


#endif
