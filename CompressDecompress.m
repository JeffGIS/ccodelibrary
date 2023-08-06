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
#include "shr.h"
#define BOOL int

@implementation CompressDecompress


-(int) GetFileFromTransferFile:(FILE *)FidTF
                     fileToGet:(LPSTR) FileToGet
                    bufferSize:(long) MaxLength
{
    int lRec, rtn = FALSE;
    int	CompressedLength, LenRead = 0;
    double curLoc;
    FILE *Fid = fopenGSSi(FileToGet,"wb");
    
    if (Fid == NULL)
        goto Exit;
    
    BigReadF(FidTF, (HPSTR)&CompressedLength, 4);
    rtn = TRUE;
    while (CompressedLength > 0)
    {
        LPBYTE	pCompressedRec = (LPBYTE)malloc(CompressedLength +32);
        LPBYTE	pRec = (LPBYTE)malloc(MaxLength * 2);
        LenRead += CompressedLength + 4;
        BigReadF(FidTF,pCompressedRec,CompressedLength);
       // NSData * data = [NSData dataWithBytes:pCompressedRec length:CompressedLength];
       // NSError *error = nil;
       // NSData * dcdata = [data decompressedDataUsingAlgorithm:NSDataCompressionAlgorithmZlib error:&error];
       // NSString * er = [error localizedDescription];
        lRec = DecompressBinaryRecordUnsafe(pRec, pCompressedRec, CompressedLength);
        if (BigWriteF(Fid ,(LPCSTR)pRec ,lRec, -1) != lRec)
            rtn = FALSE;
        BigReadF(FidTF, (HPSTR)&CompressedLength, 4);
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
    
    fcloseGSSi(Fid);
    
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
    FidTF = fopenGSSi(TransferFileName,"rb");
    long fileLen;
    long nFilesRead = 0;
    
    if (FidTF == NULL)
        return FALSE;
    
    fileLen = GSSifilelengthF(FidTF);
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
    BigReadF(FidTF, &len, 4);
    
    while (rtn && len > 0)
    {
        BigReadF (FidTF, File, len);
        
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
        BigReadF(FidTF, &len, 4);
    }
    
Exit:
    fcloseGSSi(FidTF);
    return rtn;
}
@end
