//  findIntersection.c
//  CCodeLibrary

#define MAXINT  16
#define RECLENx  40
#define RECLENmp  31
#define OFFSETLOCx 30
#define OFFSETLOCmp 23

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <limits.h>
#include <string.h>
#include "TileGraphics.h"
#include "MathUtil.h"

static int OFFSETLOC=30;
static int RECLEN=40;
static int FIRSTRECLEN=0;
static int FILEVERSION;

int Between0And360 (int ival)
{
    if (ival < 0)
        return 360 + ival;
    
    else if (ival > 360)
        return ival % 360;
    
    return ival;
}

double DeltaAngle (double AZ1, double AZ2)
{         
	double daz;
	
    AZ1 = Between0And360((int)AZ1);
    AZ2 = Between0And360((int)AZ2);
    AZ1 *= DEGtoRAD;
    AZ2 *= DEGtoRAD;
	daz =  AZ2 - AZ1;
    
	if (daz < -PY)
		daz += TWOPI;
    
	else if (daz > PY)
		daz -= TWOPI;
    
	return daz*RADtoDEG;
}   

int iDist(double X1, double Y1, double X2, double Y2)
{ 
	double xdf = (X1-X2);
	double ydf = (Y1-Y2);
  	
  	return (int)sqrt(xdf *xdf + ydf *ydf);
}

void GetCoords (char *pLoc, int *px, int *py)
{
    //unsigned int mapSize = MapSize(20);//mpls only
    *py = atoi (pLoc);
    
    //*py = (mapSize - 1) - *py;

    *px = atoi (strchr (pLoc,' '));
    
    return;
}

int GetCornerIDFromHeading (int heading, int IntersectionCorrection)
{
    heading -= IntersectionCorrection;
    
    if (heading >=0 && heading < 90)
        return 45;
    
    if (heading >= 90 && heading < 180)
        return 67;
    
    if (heading >= 180 && heading < 270)
        return 81;
    
    return 23;
}

int DoTestStruct (const char *testFile)
{
    TESTSTRUCT testStruct;
    int l = sizeof(testStruct);
    
    FILE * fid = fopen (testFile,"rb");
    
    fread (&testStruct,l,1,fid);
    fclose (fid);
    return 1;
}

static void ReadHeaderRecord (FILE * fid)
{
    char indxtxt[130];
    
    fread (indxtxt,1,128,fid);
    indxtxt[128] = 0;

    if (!strncasecmp (indxtxt,"VERSION=",8))
    {
        char * loc;
        
        FILEVERSION = atoi (&indxtxt[8]);
        
        if ((loc = strstr (indxtxt,";RECLEN=")))
            RECLEN = atoi (loc+8);
            
            if ((loc = strstr (indxtxt,";OFFSETLOC=")))
                OFFSETLOC = atoi (loc+11);
                
                if ((loc = strstr (indxtxt,";FIRSTRECLEN=")))
                    FIRSTRECLEN = atoi (loc+13);
                    }

    else
    {
        FILEVERSION = 0;
        OFFSETLOC = 30;
        RECLEN = 40;
        FIRSTRECLEN = 0;
    }
    return;
}

int FindIntersectionFromID (const char *indexPath, const char *dataPath, int intID, char *intText,
                            char *intAZMS, int *pnumStreets, int *pnRamps, int *plev21x, int *plev21y)
{
    int rtn = 0;
    int len, fileLen, nrecs, idint, iOffset;
    //int i;
    char indxtxt[256];
    char *pLoc = indxtxt;
    char *pAZ, *pnumRamp;
    FILE *fid = fopen (indexPath,"rb");
    
    if (fid == NULL)
        goto Exit;
    
    ReadHeaderRecord (fid);
    fseek (fid, 0, 2);
    fileLen = (int)ftell (fid) - FIRSTRECLEN;
    nrecs = fileLen / RECLEN; 
    fseek (fid, FIRSTRECLEN, 0);
    
    while (nrecs--)
    {
        len = (int)fread(indxtxt, 1, RECLEN, fid);
        pLoc = strchr (indxtxt,'\t')+1;
        idint = atoi (pLoc);
        
        if (idint == intID)
        {
            int lev21x, lev21y;
            double lat,lon;
            
            pLoc = strchr (pLoc, '\t')+1;
            iOffset = atoi (pLoc) - 1;
            lev21y = atoi (indxtxt);
            pLoc = strchr (indxtxt, ' ');
            lev21x = atoi (pLoc);
            PixelXYToLatLong(lev21x, lev21y, 21, &lat, &lon);
            LatLongToPixelXY(lat, lon, 21, plev21x, plev21y);

            goto HaveInt;
        }
    }
    
    fclose (fid);
    goto Exit;
    
HaveInt:
    pLoc = indxtxt;
    fclose (fid);
    {
        
        FILE *fidData = fopen (dataPath,"rb");
        char *pend;
        
        fseek (fidData,iOffset,0);
        fread (pLoc,1,255,fidData);
        pLoc[255] = 0;
        fclose (fidData);
        
        if ((pend = strchr (pLoc,'\r')))
            *pend = 0;
        
        rtn = atoi (pLoc);
       
/* mpls
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        
        for(i=0;i<strlen(pLoc);i++)
            if (pLoc[i] == '\t')
                pLoc[i] = '\r';
        
        strncpy (intText,(const char *)pLoc,254);
        intText[255] = 0;
*/
        pLoc = strchr (pLoc,'\t')+1;
        *pnumStreets = atoi (pLoc);
        pLoc = strchr (pLoc,'\t')+1;
        pAZ = strchr (pLoc,'\t');
        *pAZ++ = 0;
        pnumRamp = strchr (pAZ,'\t');
        *pnumRamp++ = 0;
        *pnRamps = atoi (pnumRamp);
        strncpy (intText, (const char *)pLoc, 254);
        intText[255] = 0;
        strncpy (intAZMS, (const char *)pAZ, 254);
        intAZMS[255] = 0;

    }
    
Exit:
    return rtn;
}

int FindIntersection (const char *indexPath, const char *dataPath, int x, int y, char *intText,
                      char *intAZMS, int *pnumStreets, int *pnRamps, int iWant, int *plev21x, int *plev21y)
{
    int rtn = 0;
    char indxtxt[256], *pAZ, *pnumRamp;
    char *pLoc = indxtxt;
    long len, fileLen;
    int intAtY, intAtX;
    int minDist[MAXINT] = {INT_MAX};
    long ioffset[MAXINT];
    dvec2 pt[MAXINT];
    long left = 0, right = 0;
    double metersPerPixel = GroundResolution(45.0, 21);
    int yStart = y - (1000 / metersPerPixel);
    int yStop = y + (1000 / metersPerPixel);
    
    long nrecs, iloc, j, k;
    //long i;
    int nFound = 0;
    FILE *fid = fopen (indexPath,"rb");
    
    //find first point with y within 1000 meters of point
    if (iWant <= 0)
        goto Exit;
    
    if (fid == NULL)
        goto Exit;

    ReadHeaderRecord (fid);
    fseek (fid, 0, 2);
    fileLen = (int)ftell (fid) - FIRSTRECLEN;
    nrecs = (fileLen / RECLEN);
    fseek (fid, FIRSTRECLEN, 0);
    len = (int)fread (pLoc, 1, RECLEN, fid);
    GetCoords (pLoc, &intAtX, &intAtY);
    
    if (intAtY > yStop)
        goto Exit;
    
    yStart = max (yStart, intAtY);
    nrecs = (fileLen / RECLEN);
    right = nrecs - 1;
    fseek (fid, (right * RECLEN) + FIRSTRECLEN, 0);
    len = fread(pLoc, 1, RECLEN, fid);
    GetCoords (pLoc, &intAtX, &intAtY);
    
    if (intAtY < yStart)
        goto Exit;
    
    yStop = min (yStop, intAtY);
    iloc = nrecs / 2;
    right = nrecs - 1;
    
    while (right - left > 1)
    {
        fseek (fid, (iloc * RECLEN) + FIRSTRECLEN, 0);
        len = fread(pLoc, 1, RECLEN, fid);
        GetCoords (pLoc, &intAtX, &intAtY);
        
        if (intAtY == yStart)
            left = right = iloc;
        
        else if (intAtY > yStart)
            right = iloc;
        
        else
            left = iloc;
        
        iloc = (left + right) /2;
    }
    
    minDist[0] = iDist (x, y, intAtX, intAtY);
    pt[0].x = intAtX;
    pt[0].y = intAtY;
    ioffset[0] = atoi (pLoc + OFFSETLOC);
    nFound = 1;
    
    while (intAtY < yStop)
    {
        int dist = iDist (x,y,intAtX,intAtY);
        
        for (k = 0; k < MAXINT; k++)
            
            if (dist < minDist[k])
            {
                for (j = MAXINT - 1; j > k; j--)
                {
                    minDist[j] = minDist[j-1];
                    ioffset[j] = ioffset[j-1];
                    pt[j] = pt[j-1];
                }
                
                minDist[k] = dist;
                ioffset[k] = atoi (pLoc+OFFSETLOC)-1;
                pt[k].x = intAtX;
                pt[k].y = intAtY;
                nFound++;
                break;
            }
        
        iloc ++;
        fseek (fid, (iloc * RECLEN) + FIRSTRECLEN, 0);
        len = fread(pLoc, 1, RECLEN, fid);
        GetCoords (pLoc, &intAtX, &intAtY);
    }
    
    nFound = min (nFound, MAXINT);
    
    if (iWant <= nFound)
    {
        //double lat,lon;
        FILE *fidData = fopen (dataPath, "rb");
        char *pend;
        
        fseek (fidData, ioffset[iWant-1], 0);
        //PixelXYToLatLong_old(pt[iWant-1].x, pt[iWant-1].y, 20, &lat,&lon);
        //LatLongToPixelXY(lat, lon, 21, plev21x, plev21y);
        *plev21x = pt[iWant-1].x;
        *plev21y = pt[iWant-1].y;
        pLoc = indxtxt;
        fread (pLoc, 1, 255, fidData);
        pLoc[255] = 0;
        fclose (fidData);
        
        if ((pend = strchr (pLoc,'\r')))
            *pend = 0;
        
        rtn = atoi (pLoc);
/*      
        pLoc = strchr (pLoc,'\t')+1;
        *pnonCity = atoi (pLoc);
        pLoc = strchr (pLoc,'\t')+1;
        *pRot = atoi (pLoc);
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        pLoc = strchr (pLoc,'\t')+1;
        
        for(i=0;i<strlen(pLoc);i++)
            if (pLoc[i] == '\t')
                pLoc[i] = '\r';
        
        strncpy (intText,(const char*)pLoc,254);
        intText[255] = 0;
*/
        pLoc = strchr (pLoc, '\t') +1;
        *pnumStreets = atoi (pLoc);
        pLoc = strchr (pLoc, '\t') +1;
        pAZ = strchr (pLoc, '\t');
        *pAZ++ = 0;
        pnumRamp = strchr (pAZ, '\t');
        *pnumRamp++ = 0;
        *pnRamps = atoi (pnumRamp);
        strncpy (intText,(const char *)pLoc, 254);
        intText[255] = 0;
        strncpy (intAZMS,(const char *)pAZ, 254);
        intAZMS[255] = 0;
        //*pnonCity=1;
    }
    
Exit:
    if (fid)
        fclose(fid);
    
    return rtn;
}