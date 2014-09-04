//  compress.c
//  CCodeLibrary

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <limits.h>
#include <string.h>
#include "compress.h"
#include "minilzo.h"

long GSSifilelength (FILE *fid)
{
    long fileLen;
    long curloc = ftell (fid);
    fseek (fid, 0, SEEK_END);
    fileLen = ftell (fid);
    fseek (fid,curloc,SEEK_SET);
    return fileLen;
}
long BigRead (FILE *fid,LPVOID pmem,long len)
{
    long didRead = fread (pmem,len,1,fid);
    return didRead;
}
long BigWrite (FILE *fid,LPBYTE pbuf,long len, long loc)
{
    long bytesWritten = fwrite (pbuf,len,1,fid);
    
    return bytesWritten;
}
void ExpandText (LPSTR txt)
{
    return;
}
BOOL InitLZO (void)
{
	static BOOL	HaveLZOInit=FALSE;
	if (HaveLZOInit)
		return TRUE;
	if (lzo_init() != 0)
    	return FALSE;
    HaveLZOInit = TRUE;
    return TRUE;
}
int DecompressBinaryRecordUnsafe (LPBYTE pDecompressedRec,LPBYTE pCompressedRec,DWORD CompressedLen)
{
	int		DCLen;
	int		rtn;
    
	if (InitLZO())
	{
		rtn = lzo1x_decompress(pCompressedRec,(lzo_uint) CompressedLen,pDecompressedRec,(lzo_uint *) &DCLen,NULL);
		if (rtn == 0)
        	return DCLen;
	}
	return 0;
}
BOOL GetFileFromTransferFile (HWND hWndStatus,FILE * FidTF,LPSTR FileToGet,long LenToRead,long MaxLength)
{
	int	lRec;
    BOOL    rtn=FALSE;
    //HANDLE	hRec = GSSiGlobAlloc (1552,GMEM_MOVEABLE,MaxLength);
    LPBYTE	pRec = malloc (MaxLength);
    //HANDLE	hCompressedRec = GSSiGlobAlloc (1553,GMEM_MOVEABLE,MaxLength*2);
    LPBYTE	pCompressedRec = malloc (MaxLength * 2);
    int	CompressedLength, LenRead=0;
	FILE *	Fid=fopen (FileToGet,"wb");
	
	if (Fid == NULL)
		goto Exit;
   	//PctBox (hWndStatus,LenToRead,LenRead,0);
    BigRead (FidTF,(HPSTR)&CompressedLength,4);
	while (CompressedLength > 0)
	{
		LenRead += CompressedLength+4;
		BigRead (FidTF,pCompressedRec,CompressedLength);
		lRec = DecompressBinaryRecordUnsafe (pRec,pCompressedRec,CompressedLength);
    	BigWrite (Fid,pRec,lRec,-1);
    	//PctBox (hWndStatus,LenToRead,LenRead,0);
        BigRead (FidTF,(HPSTR)&CompressedLength,4);
    }
    fclose (Fid);
    rtn = TRUE;
Exit:
    free (pCompressedRec);
    free (pRec);
    return TRUE;
}
BOOL DecompressGMZipFile (char * TransferFileName,char * toDirectory)
{
    int	 len, MaxLength,LenToRead;
    char File[PATH_MAX];
    char OutFile[PATH_MAX];
    short	Version, endMarker;
    FILE *FidTF;
    BOOL rtn = TRUE;
    LPSTR pBS;
    
    FidTF = fopen(TransferFileName,"rb");
    if (FidTF == NULL)
        return FALSE;
    if (GSSifilelength (FidTF) < 14)
    {
        rtn = FALSE;
        goto Exit;
    }
    fseek (FidTF,-4,SEEK_END);
    fread(&endMarker, sizeof(short),1,FidTF);
    if (endMarker != 32349)
    {
        rtn = FALSE;
        goto Exit;
    }
    fseek (FidTF,0,SEEK_SET);
    fread(&Version, sizeof(short),1,FidTF);
    fread(&MaxLength, sizeof(int),1,FidTF);
    BigRead (FidTF,&len,4);
    while (rtn && len > 0)
    {
        BigRead (FidTF,File,len);
        if (!(pBS = strrchr (File,'\\')))
            pBS = File;
        sprintf (OutFile,"%s/%s",toDirectory,pBS);
        rtn = GetFileFromTransferFile (0,FidTF,OutFile,LenToRead,MaxLength);
        BigRead (FidTF,&len,4);
    }
Exit:
    fclose (FidTF);
    return rtn;
}