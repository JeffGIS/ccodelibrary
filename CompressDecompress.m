//
//  CompressDecompress.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 3/6/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "CompressDecompress.h"
#import "compress.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <limits.h>
#include <string.h>
#include "compress.h"
#include "minilzo.h"
#include "mathutil.h"
#define BOOL int

@implementation CompressDecompress


-(int) GetFileFromTransferFile:(FILE *)FidTF
                     fileToGet:(LPSTR) FileToGet
                    bufferSize:(long) MaxLength
{
    int lRec, rtn = FALSE;
    int	CompressedLength, LenRead = 0;
    double curLoc;
    FILE *Fid = fopen(FileToGet,"wb");
    
    if (Fid == NULL)
        goto Exit;
    
    BigRead(FidTF, (HPSTR)&CompressedLength, 4);
    rtn = TRUE;
    while (CompressedLength > 0)
    {
        LPBYTE	pCompressedRec = (LPBYTE)malloc(CompressedLength +32);
        LPBYTE	pRec = (LPBYTE)malloc(MaxLength * 2);
        LenRead += CompressedLength + 4;
        BigRead(FidTF,pCompressedRec,CompressedLength);
        lRec = DecompressBinaryRecordUnsafe(pRec, pCompressedRec, CompressedLength);
        if (BigWrite(Fid ,pRec ,lRec, -1) != lRec)
            rtn = FALSE;
        BigRead(FidTF, (HPSTR)&CompressedLength, 4);
        free (pCompressedRec);
        free(pRec);
        curLoc = ftell (FidTF);
        if (_popover)
        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [_popover updateProgress:curLoc/_totLen];
                           });

        }
    }
    
    fclose(Fid);
    
Exit:
    return rtn;
}

-(bool) DecompressGMZipFile:(char *)TransferFileName
                toDirectory:(char *)toDirectory
{
//    return DecompressGMZipFile(TransferFileName,toDirectory,0,0);
    int	len, MaxLength;
    char File[PATH_MAX], OutFile[PATH_MAX];
    short Version, endMarker;
    FILE *FidTF;
    BOOL rtn = TRUE;
    LPSTR pBS;
    FidTF = fopen(TransferFileName,"rb");
    long fileLen;
    long nFilesRead = 0;
    
    if (FidTF == NULL)
        return FALSE;
    
    fileLen = GSSifilelength(FidTF);
    if (fileLen < 14)
    {
        rtn = FALSE;
        goto Exit;
    }
    _totLen = fileLen;
    
    fseek(FidTF, -4, SEEK_END);
    fread(&endMarker, sizeof(short), 1, FidTF);
    
    if (endMarker != 32349)
    {
        rtn = FALSE;
        goto Exit;
    }
    
    fseek(FidTF, 0, SEEK_SET);
    fread(&Version, sizeof(short), 1, FidTF);
    fread(&MaxLength, sizeof(int), 1, FidTF);
    BigRead(FidTF, &len, 4);
    
    while (rtn && len > 0)
    {
        BigRead (FidTF, File, len);
        
        if (!(pBS = strrchr(File,'\\')))
        {
            pBS = File;
        }
        else
        {
            pBS++;
        }
        sprintf(OutFile, "%s/%s", toDirectory, pBS);
        rtn = [self GetFileFromTransferFile:FidTF
                                  fileToGet:OutFile
                                 bufferSize:MaxLength];
        nFilesRead++;
        if (!rtn)
            goto Exit;
        BigRead(FidTF, &len, 4);
    }
    
Exit:
    fclose(FidTF);
    return rtn;
}
@end
