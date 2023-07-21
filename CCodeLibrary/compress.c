//  compress.c
//  CCodeLibrary

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <limits.h>
#include <string.h>
#include "compress.h"
#include "minilzo.h"
#include "shr.h"
#include "MathUtil.h"
#define BOOL int

int InitLZO (void)
{
	static int HaveLZOInit = FALSE;
    
	if (HaveLZOInit)
		return TRUE;
    
	if (lzo_init() != 0)
    	return FALSE;
    
    HaveLZOInit = TRUE;
    return TRUE;
}

int DecompressBinaryRecordUnsafe (LPBYTE pDecompressedRec, LPBYTE pCompressedRec, DWORD CompressedLen)
{
    lzo_uint DCLen;
    int rtn;
    
	if (InitLZO())
	{
		rtn = lzo1x_decompress_safe (pCompressedRec, (lzo_uint)CompressedLen, pDecompressedRec, (lzo_uint *)&DCLen, NULL);
        
		if (rtn == 0)
        {
            rtn = (int)DCLen;
        	return rtn;
        }
	}
    
	return 0;
}
int GetFileFromTransferFile (HWND hWndStatus, FILE *FidTF, LPSTR FileToGet, long MaxLength)
{
	int lRec, rtn = FALSE;
    int	CompressedLength, LenRead = 0;
	FILE *Fid = fopenGSSi(FileToGet,"wb");
	
	if (Fid == NULL)
		goto Exit;
    
    BigReadF(FidTF, (HPSTR)&CompressedLength, 4);
    
	while (CompressedLength > 0)
	{
        LPBYTE	pCompressedRec = (LPBYTE)malloc(CompressedLength +32);
        LPBYTE	pRec = (LPBYTE)malloc(MaxLength * 2);
		LenRead += CompressedLength + 4;
		BigReadF(FidTF,pCompressedRec,CompressedLength);
		lRec = DecompressBinaryRecordUnsafe(pRec, pCompressedRec, CompressedLength);
    	BigWriteF(Fid ,(LPCSTR)pRec ,lRec, -1);
        BigReadF(FidTF, (HPSTR)&CompressedLength, 4);
        free (pCompressedRec);
        free(pRec);
    }
    
    fcloseGSSi(Fid);
    rtn = TRUE;
    
Exit:
    return rtn;
}

BOOL DecompressGMZipFile(char *TransferFileName, char *toDirectory,long offset,int nfilestodecompress,LPSTR outFilePath)
{
    int	len, MaxLength;
    char File[PATH_MAX], OutFile[PATH_MAX];
    short Version, endMarker;
    FILE *FidTF;
    BOOL rtn = FALSE;
    LPSTR pBS;
    FidTF = fopenGSSi(TransferFileName,"rb");
    long fileLen;
    long nFilesRead = 0;
    
    if (FidTF == NULL)
        return FALSE;
    
    fileLen = GSSifilelengthF(FidTF);
    if (fileLen < 14 || fileLen < offset)
    {
        rtn = FALSE;
        goto Exit;
    }
    
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
    if (offset < fileLen)
    {
        if (offset > 0)
            fseek(FidTF, offset, SEEK_SET);
        BigReadF(FidTF, &len, 4);
        rtn = TRUE;
        while (rtn && len > 0 && len + offset < fileLen)
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
            if (outFilePath)
                strcpy (outFilePath,OutFile);
            rtn = GetFileFromTransferFile(0, FidTF, OutFile,  MaxLength);
            nFilesRead++;
            if (!rtn || (nfilestodecompress && nFilesRead >= nfilestodecompress))
                goto Exit;
            offset = ftell(FidTF);
            BigReadF(FidTF, &len, 4);
        }
    }
    
Exit:
    fcloseGSSi(FidTF);
    return rtn;
}
