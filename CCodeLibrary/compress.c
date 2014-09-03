//  compress.c
//  CCodeLibrary

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <limits.h>
#include <string.h>
#include <stdbool.h>
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
long DecompressBinaryRecordUnsafe (LPBYTE pDecompressedRec,LPBYTE pCompressedRec,DWORD CompressedLen)
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
	long	lRec;
    BOOL    rtn=FALSE;
    //HANDLE	hRec = GSSiGlobAlloc (1552,GMEM_MOVEABLE,MaxLength);
    LPBYTE	pRec = malloc (MaxLength);
    //HANDLE	hCompressedRec = GSSiGlobAlloc (1553,GMEM_MOVEABLE,MaxLength*2);
    LPBYTE	pCompressedRec = malloc (MaxLength * 2);
    long	CompressedLength, LenRead=0;
	FILE *	Fid=fopen (FileToGet,"wb");
	
	if (Fid == NULL)
		goto Exit;
   	//PctBox (hWndStatus,LenToRead,LenRead,0);
	while (LenRead < LenToRead)
	{
		BigRead (FidTF,(HPSTR)&CompressedLength,4);
		LenRead += CompressedLength+4;
		BigRead (FidTF,pCompressedRec,CompressedLength);
		lRec = DecompressBinaryRecordUnsafe (pRec,pCompressedRec,CompressedLength);
    	BigWrite (Fid,pRec,lRec,-1);
    	//PctBox (hWndStatus,LenToRead,LenRead,0);
    }
    fclose (Fid);
    rtn = TRUE;
Exit:
    free (pCompressedRec);
    free (pRec);
    return TRUE;
}
BOOL DecompressGMZipFile (char * TransferFileName)
{
    long	NextFileLoc=0, len, FileLength, EndOfFile, MaxLength,LenToRead;
    char File[PATH_MAX];
    short	Version;
    FILE *FidTF;
    BOOL rtn = TRUE;
    FidTF = fopen(TransferFileName,"rb");
    FileLength = GSSifilelength (FidTF);
    NextFileLoc = 10;
    fread(&len, sizeof(long),1,FidTF);
    fread(&Version, sizeof(short),1,FidTF);
    fread(&MaxLength, sizeof(long),1,FidTF);
    while (rtn && NextFileLoc > 0)
    {
        fseek (FidTF,NextFileLoc,0);
        BigRead (FidTF,&len,4);
        BigRead (FidTF,File,len);
        BigRead (FidTF,&NextFileLoc,4);
        if (NextFileLoc > 0)
            EndOfFile = NextFileLoc - 1;
        else
            EndOfFile = FileLength - 4;
        LenToRead = EndOfFile - fseek (FidTF,0,1) +1;
        //SetDlgItemText (hWndDlg,IDC_MESSAGE,File);
        if (!strncasecmp (File,"[XCMD]",6))
            ExpandText (&File[6]);
        else if (!GetFileFromTransferFile (0,FidTF,File,LenToRead,MaxLength))
        {
            rtn = FALSE;
            //sprintf (str,"Unable to open file\r\n%s",File);
            //MessageBox (hWndDlg,str,0,MB_ICONEXCLAMATION);
        }
    }
    fclose (FidTF);
    
    return rtn;
}


