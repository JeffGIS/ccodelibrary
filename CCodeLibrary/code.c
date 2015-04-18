#include <float.h>
#include <math.h>

#define MAX_PATH	260
#define _MAX_PATH   260
#define LF_FACESIZE         32

#undef HUGE
#define HUGE
#define FAR
#define NEAR
#define CONST	const
typedef int HFILE;
typedef float FLOAT;
typedef char *LPSTR;
typedef char const *LPCSTR;
typedef long LONG;
typedef short SHORT;
typedef short *LPSHORT;
typedef long *LPLONG;
typedef	unsigned char BYTE;
typedef char CHAR;
typedef void *LPVOID;
typedef int	COLORREF;

typedef int BOOL;
typedef short BOOL16;
typedef unsigned int HANDLE;
typedef HANDLE HWND;
typedef HANDLE	HFONT;
typedef HANDLE	HDC;
typedef HANDLE	HRGN;
typedef HANDLE  HBITMAP;
typedef HANDLE *LPHANDLE;
typedef HANDLE	HGDIOBJ;
typedef unsigned long DWORD ;

#define WINAPI      __stdcall
typedef int (FAR WINAPI *FARPROC)();

typedef struct tagSIZE
{
    LONG        cx;
    LONG        cy;
} SIZE, *PSIZE, *LPSIZE;

typedef struct
{
    short   y;
    short   x;
} POINTS, *PPOINTS, *LPPOINTS;
typedef struct
{
    int   y;
    int   x;
} POINT, *PPOINT, *LPPOINT;
typedef struct
{
    LONG    left;
    LONG    top;
    LONG    right;
    LONG    bottom;
} RECT, *PRECT, NEAR *NPRECT, FAR *LPRECT;

typedef HANDLE				HCURSOR;
typedef short				FAR *LPSHORT;
typedef float			 	FAR *LPFLOAT;
typedef float   			HUGE *HPFLOAT;
typedef double  			FAR *LPDOUBLE;
typedef double  			HUGE *HPDOUBLE;
typedef struct{double x,y;} DPOINT;
typedef DPOINT  			FAR *LPDPOINT;
typedef DPOINT  			HUGE *HPDPOINT;
typedef POINTS				*HPPOINTS;
typedef struct{double x,y,z;} DPOINT3D;
typedef DPOINT3D  			FAR *LPDPOINT3D;
typedef DPOINT3D  			HUGE *HPDPOINT3D;
typedef DPOINT				FPOINT;
typedef FPOINT  			FAR *LPFPOINT;
typedef FPOINT  			HUGE *HPFPOINT;
typedef struct{float x,y;}  FLTPOINT;
typedef FLTPOINT			*LPFLTPOINT;
typedef POINT				HUGE *HPPOINT;
typedef void				HUGE* LPHUGE;
typedef struct{long x,y;} LPOINT;
typedef LPOINT  			FAR *LPLPOINT;         
typedef LPOINT  			HUGE *HPLPOINT;         
typedef HANDLE				HDIB32; 
typedef HDIB32				FAR *LPHDIB32; 
typedef RECT				HUGE *HPRECT;
typedef unsigned short		WORD;
typedef unsigned short		USHORT;
typedef unsigned int		UINT;
typedef unsigned long		ULONG;

typedef unsigned long ULONG_PTR, *PULONG_PTR;

typedef struct tagLOGBRUSH
  {
    UINT        lbStyle;
    COLORREF    lbColor;
    ULONG_PTR   lbHatch;
  } LOGBRUSH, *PLOGBRUSH, NEAR *NPLOGBRUSH, FAR *LPLOGBRUSH;

typedef struct  tagXFORM
  {
    FLOAT   eM11;
    FLOAT   eM12;
    FLOAT   eM21;
    FLOAT   eM22;
    FLOAT   eDx;
    FLOAT   eDy;
  } XFORM, *PXFORM, FAR *LPXFORM;

typedef struct tagRGBTRIPLE {
        BYTE    rgbtBlue;
        BYTE    rgbtGreen;
        BYTE    rgbtRed;
} RGBTRIPLE, *PRGBTRIPLE, NEAR *NPRGBTRIPLE, FAR *LPRGBTRIPLE;
typedef struct tagLOGFONTA
{
    LONG      lfHeight;
    LONG      lfWidth;
    LONG      lfEscapement;
    LONG      lfOrientation;
    LONG      lfWeight;
    BYTE      lfItalic;
    BYTE      lfUnderline;
    BYTE      lfStrikeOut;
    BYTE      lfCharSet;
    BYTE      lfOutPrecision;
    BYTE      lfClipPrecision;
    BYTE      lfQuality;
    BYTE      lfPitchAndFamily;
    CHAR      lfFaceName[LF_FACESIZE];
} LOGFONT, *PLOGFONT, NEAR *NPLOGFONT, FAR *LPLOGFONT;

#include "gssitype.h"
#define TRUE	1
#define FALSE	0
#define  CFTCM   2.83170164938e-2
#define  CMCFT   3.5314454833912e1
#define  CMCYD   1.3079427716264e0
#define  CYDCM   7.645594553315e-1
#define  FTM     3.04800609601219e-1
#define  HAFSEC    1.388888888888889e-5
#define  HALFPI    1.570796326794896e0
#define  MFT       3.280833333333333e0
#define  PIHALF    4.712388980384689e0
#define  PY        3.141592653589793e0
#define  RADDEG    1.74532925199433e-2
#define  DEGRAD    5.729577951308232e1
#define  SFTSM     9.2903411613274e-2
#define  SMSFT     1.076386736111111e1
#define  TWOPI     6.283185307179586e0
#define  ACRSM     4046.872609874253e0  
#define  INCHES_PER_CM  0.3937e0
#define  MAX_GAP_BTWN_LINKS    0.1e0 
#define  ZERO$  -2146450000 
#define  TMPRF$ -2146483000   
#define	 NULLREF 0
#define RADtoDEG 57.295779513082322
#define DEGtoRAD 0.017453292519943296
#define max(a,b)    (((a) > (b)) ? (a) : (b))
#define min(a,b)    (((a) < (b)) ? (a) : (b))
#define		MAXPICKITEMS		32


/*typedef	struct
	{	LONG	Segment;
		WORD	Offset, Element;
		LONG	Refno;   
		short	ViewID,
				ConfigID;
		short	FileNum;
		USHORT	FileInIndex;
		short	SubFile;
		unsigned	short	Type:8, 
						HasText:1,
						HasTextPointer:1, 
						HiPrecis:1, 
						Blocked:1,
						IsDispersed:1,
						IsDeleted:1,
						filler2:2;
		short	Desc,
		 		PolyID;
		UINT	NearPoint;
		short	NearSeg,
		 		UDILen;
		UINT	NumPoints;
		double	Length,
		 		PCT,
		 		OffDist,
		 		BPAZ,PPAZ,EPAZ,
		 		Area;
		DPOINT	BeginPoint, EndPoint, PickedPoint, NodePoint, FromPoint, ToPoint; //for curves NodePoint = POC 
		POINT	BeginPointFile, EndPointFile, PickedPointFile;
		MNMXCORD Rect;
		float	Elev; 
		char	Prefix[33], UDI[65];
		ULONG	MSLink;
	} PICKDATA;   
typedef	PICKDATA	FAR	*LPPICKDATA;
*/


static BOOL PickNET=FALSE;
static HANDLE hProfileSymbols = 0;
static int CurrentRefno=0;
static HANDLE hHighlightArea=0;
static BOOL PickOnlyEndPoints=FALSE;
static DPOINT PickPointBase;
static BOOL PickingByRefno=FALSE;
static double PickApW;
static BOOL IgnoreBounds=FALSE;
static BOOL PickDeletes=FALSE;
static BOOL WantOnlyShapePoints=FALSE;
static BOOL InSnapNode=FALSE;
static int NumPicked;
static PICKDATA	PickList[MAXPICKITEMS+3];
//static long counts[3] = {0,0,0};

static short LINSEC (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
            double A2,double *X3,double *Y3);
short LINSEC_TOL (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
      double A2,double *X3,double *Y3,double INTOL);
static short LIN_SEC (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
             double A2,double *X3,double *Y3);
static double LTWOPI (double AZ1);
//static double ComputeAreaAreaD (HPDPOINT lpDpoints,long nPnts,LPDOUBLE pPerim);
BOOL  POINT_IN_AREAD (DPOINT PickPoint, DWORD nPoints, HPDPOINT lpAreaPoints,int nPoly,HANDLE hPolyPartLen,LPDOUBLE pNextXIntersect,LPHANDLE pAccelerator);

static double	P_TOL = 1e-4;

LPVOID GlobalLock (HANDLE hmem)
{
	return (LPVOID)hmem;
}

void GlobalUnlock (HANDLE hmem)
{
	return;
}

/*static void GSSiEnterProg (int id)
{
	return;
}
*/

static BOOL RefInNet (int ref)
{
	return FALSE;
}

static BOOL GetGlobalBVal2 (LPSTR Global,BOOL Default)
{
	return FALSE;
}

static int PickListDelete (int i)
{
	return i;
}

static void DBoundsInit (LPMNMXCORD lpRect)
#if ENABLETRACE
{GSSiEnterProg (257);
#endif
{
    lpRect->xmn = DBL_MAX;
    lpRect->ymn = DBL_MAX;
    lpRect->xmx = -DBL_MAX;
    lpRect->ymx = -DBL_MAX;
{
#if ENABLETRACE
GSSiExitProg (257);
#endif
	return;
}
#if ENABLETRACE
}
#endif
} 
static void ExpandBounds (LPMNMXCORD Bounds, double Adjust)
#if ENABLETRACE
{GSSiEnterProg (261);
#endif
{ 
    Bounds->xmn -= Adjust;
    Bounds->xmx += Adjust;
    Bounds->ymn -= Adjust;
    Bounds->ymx += Adjust;
{
#if ENABLETRACE
GSSiExitProg (261);
#endif
    return;
}
#if ENABLETRACE
}
#endif
}

static double DeflectionAngle (double CurAZ, double AZ)
#if ENABLETRACE
{GSSiEnterProg (665);
#endif
{   double rtn;
	CurAZ = LTWOPI (CurAZ); 
	AZ	  = LTWOPI (AZ);
	if (CurAZ > AZ)
	{
		if (CurAZ - AZ > PY)
			rtn = TWOPI - (CurAZ-AZ);
		else
			rtn = AZ-CurAZ;
	}
	else
	{ 
		if (AZ - CurAZ > PY)
			rtn = (AZ-CurAZ)-TWOPI;
		else
			rtn = AZ-CurAZ;
	}
{
#if ENABLETRACE
GSSiExitProg (665);
#endif
	return (rtn);
}
#if ENABLETRACE
}
#endif
}

static double LTWOPI (double AZ1)
#if ENABLETRACE
{GSSiEnterProg (375);
#endif
{
      if (AZ1<0)
{
#if ENABLETRACE
GSSiExitProg (375);
#endif
      	return (TWOPI + fmod(AZ1,TWOPI));
}
      if (AZ1 == 0)
{
#if ENABLETRACE
GSSiExitProg (375);
#endif
      	return (AZ1);
}
{
#if ENABLETRACE
GSSiExitProg (375);
#endif
      return (fmod(AZ1,TWOPI));
}
#if ENABLETRACE
}
#endif
}
static double LGETAZ(double X1, double Y1, double X2, double Y2)
#if ENABLETRACE
{GSSiEnterProg (374);
#endif
{   
	double	rtn=LTWOPI(atan2(Y2 - Y1,X2 - X1));
{
#if ENABLETRACE
GSSiExitProg (374);
#endif
	return rtn;
}
#if ENABLETRACE
}
#endif
}



static double getazd (HPDPOINT Point1, HPDPOINT Point2)
#if ENABLETRACE
{GSSiEnterProg (373);
#endif
{   
	double 	rtn=LTWOPI(atan2((Point2->y-Point1->y),(Point2->x-Point1->x)));
{
#if ENABLETRACE
GSSiExitProg (373);
#endif
	return rtn;
}
#if ENABLETRACE
}
#endif
}

static double ldistp(DPOINT Point1, DPOINT Point2)
#if ENABLETRACE
{GSSiEnterProg (379);
#endif
{
{
#if ENABLETRACE
GSSiExitProg (379);
#endif
    return (sqrt (pow(Point1.x - Point2.x, 2) +
                  pow(Point1.y - Point2.y, 2)));
}
#if ENABLETRACE
}
#endif
}

double l2ddistfrom3d (DPOINT3D Point1, DPOINT3D Point2)
#if ENABLETRACE
{GSSiEnterProg (379);
#endif
{
{
#if ENABLETRACE
GSSiExitProg (379);
#endif
    return (sqrt (pow(Point1.x - Point2.x, 2) +
                  pow(Point1.y - Point2.y, 2)));
}
#if ENABLETRACE
}
#endif
}

static double LDIST(double X1,double Y1,double X2,double Y2)
{ 
	double xdf = (X1-X2);
	double ydf = (Y1-Y2);
  	
  	return sqrt(xdf * xdf + ydf * ydf);
}
static void AddDPointToMinMax (HPDPOINT Point,LPMNMXCORD pBounds)
#if ENABLETRACE
{GSSiEnterProg (253);
#endif
{   
    pBounds->xmn = min (pBounds->xmn,Point->x);
    pBounds->ymn = min (pBounds->ymn,Point->y);
    pBounds->xmx = max (pBounds->xmx,Point->x);
    pBounds->ymx = max (pBounds->ymx,Point->y);
{
#if ENABLETRACE
GSSiExitProg (253);
#endif
    return;
}
#if ENABLETRACE
}
#endif
}
static void ComputePickPointD (HPDPOINT BPOINT, HPDPOINT EPOINT,double Dist,
					   double TotDist,LPDOUBLE PCT, LPDOUBLE OffDist,LPDOUBLE AZ,
				  	   LPMNMXCORD BOUNDS,LPDPOINT PickedPoint)
#if ENABLETRACE
{GSSiEnterProg (664);
#endif
{	double	PickY, PickX, AZ1, AZ2, INTX, INTY, LineLen,dist1,dist2;

	PickX = PickPointBase.x;//(double)BOUNDS->xmn + ((double)BOUNDS->xmx-(double)BOUNDS->xmn)/2;
	PickY = PickPointBase.y;//(double)BOUNDS->ymn + ((double)BOUNDS->ymx-(double)BOUNDS->ymn)/2;
    if (!(LineLen = ldistp (*BPOINT,*EPOINT)))
    {
    	*AZ = 0;
		*PickedPoint = *BPOINT;
		*OffDist = LDIST (BPOINT->x,BPOINT->y,PickX,PickY);
		if (TotDist == 0)
			*PCT = 0;
		else
			*PCT = Dist/TotDist;
{
#if ENABLETRACE
GSSiExitProg (664);
#endif
		return;
}
	}
    	
	AZ1 = getazd (BPOINT,EPOINT); 
	*AZ = AZ1;
	AZ2 = LTWOPI (AZ1 + HALFPI);
	LINSEC ((double)BPOINT->x,(double)BPOINT->y,AZ1, PickX,PickY,AZ2,&INTX,&INTY);
	if (LDIST (INTX,INTY,(double)BPOINT->x,(double)BPOINT->y) > LineLen ||
		LDIST (INTX,INTY,(double)EPOINT->x,(double)EPOINT->y)> LineLen)
	{ 
		dist1 = LDIST (PickX,PickY,(double)BPOINT->x,(double)BPOINT->y);
		dist2 = LDIST (PickX,PickY,(double)EPOINT->x,(double)EPOINT->y);
		if (dist1 < dist2)
		{  
			INTX = BPOINT->x;
			INTY = BPOINT->y;
		}
		else 
		{
			INTX = EPOINT->x;
			INTY = EPOINT->y;
		}
	}
	PickedPoint->x = INTX;
	PickedPoint->y = INTY; 
	*OffDist = LDIST (INTX,INTY,PickX,PickY);
	AZ2 = LGETAZ(INTX,INTY,PickX,PickY);
	if (DeflectionAngle (AZ1,AZ2) >0) *OffDist = -*OffDist; 
	if (TotDist == 0)
		*PCT = 0;
	else
		*PCT = (Dist + LDIST ((double)BPOINT->x,(double)BPOINT->y,INTX,INTY))/TotDist;
{
#if ENABLETRACE
GSSiExitProg (664);
#endif
	return;
}
#if ENABLETRACE
}
#endif
}
static short LINSEC (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
            double A2,double *X3,double *Y3)
#if ENABLETRACE
{GSSiEnterProg (362);
#endif
 {

      double  TOL ;
      TOL = P_TOL;
{
#if ENABLETRACE
GSSiExitProg (362);
#endif
      return (LINSEC_TOL (X1IN, Y1IN, A1, X2IN, Y2IN, A2, X3, Y3, TOL));
}

#if ENABLETRACE
}
#endif
}

short LINSEC_TOL (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
      double A2,double *X3,double *Y3,double INTOL)
#if ENABLETRACE
{GSSiEnterProg (363);
#endif
{

    double X2, Y2, Z1, Z2, DM1, DM2, TOL, ADIFF,  TAZ;
    short       RC;

      if (INTOL == 0.0) { TOL = 1e-4;}
      else { TOL = INTOL;}

      X2 = X2IN - X1IN; /* delta_x*/
      Y2 = Y2IN - Y1IN; /*  delta_y */
      RC = 1;
      Z1 = fabs(cos(A1)); /*   cosine of line in radians  */
      Z2 = fabs(cos(A2));
      ADIFF = fabs (A1-A2);
      if (ADIFF < (TOL * 1e-3)) {goto S10;}/*  parallel  check for coincident */
      if (fabs (PY-ADIFF) < (TOL * 1e-3)) {goto S10;} /*parallel  check for coincident*/
      if (min(Z1, Z2) < (TOL * 1e-3)) {goto S30;} /*going straight up */
      DM1 = tan(A1);  /*tangent of line in radians */
      DM2 = tan(A2);
      if (fabs(DM1-DM2) < (TOL * 1e-3))
       {goto S10;} /*parallel  check for coincident */

    /*gets here if lines aren't parallel or going straight up */
      *X3 = -(-Y2+DM2*X2)/(DM1-DM2);
      *Y3 = DM1* *X3;
      goto S1000;

/*c*    gets here if the lines are virtually parallel*/
S10:   *X3 = 0;
       *Y3 = 0;
       RC = 2; /*lines parallel and NOT coincident */
       if (fabs(Z1+Z2) < (TOL * 1e-3)) 
       	{goto S50;} /*going straight up */
       RC = 0; /*lines parallel and coincident*/
       TAZ = LDIST(X1IN, Y1IN, X2IN, Y2IN);
       if (TAZ <= TOL)
       	{goto S1000;} /*lines start the same place*/
       TAZ= LGETAZ(X1IN, Y1IN, X2IN, Y2IN);
       if(fabs(TAZ-A1) <= (TOL * 1e-3)){
             *X3 = X2IN;
             *Y3 = Y2IN;}
       else
         {if(fabs(TAZ-LTWOPI(A1+PY)) <= (TOL * 1e-3))
            { *X3 = X1IN;
              *Y3 = Y1IN;}
          else 
          	{ RC = 2;}
         }
      goto Exit;

/*c*    here it handles lines going straight up*/
S30:  if (Z2 < (TOL * 1e-3)) {goto S40;}
      *X3 = 0;
      *Y3 = tan(A2)*(*X3-X2)+Y2;
      goto S1000;
S40:  if (Z1 < (TOL * 1e-3)){ goto S50;}
      *X3 = X2;
      *Y3 = tan(A1)* *X3;
      goto S1000;
S50:  if (fabs(X2) <= (TOL * 1e-3))
		 {RC = 0;}
S1000:*X3 = *X3 + X1IN ;
      *Y3 = *Y3 + Y1IN ;
Exit:
{
#if ENABLETRACE
GSSiExitProg (363);
#endif
      return(RC);
}
#if ENABLETRACE
}
#endif
 } 
 
static BOOL LineInBoundsD (long NPNTS, HPDPOINT POINTS,double TotDist,LPDOUBLE PCT,
                   LPDOUBLE OffDist,LPDOUBLE AZ,LPMNMXCORD BOUNDS, LPDPOINT PickedPoint,LPLONG	pFromPtID)
#if ENABLETRACE
{GSSiEnterProg (1017);
#endif
{    HPDPOINT    BPOINT, EPOINT;
     double     Dist, MinOffDist, MinPCT = 0.0, MinAZ = 0.0;
     DPOINT     MinPickedPoint;
     double     YMN, YMX, XMN, XMX, XDIFF;
     double     SLOPE, YINT, X, Y;
     long       i, MinFromPt = 0;
     short		nfound;
     
     if (IgnoreBounds || PickDeletes)
{
#if ENABLETRACE
GSSiExitProg (1017);
#endif
        return TRUE;
}
     nfound = 0;
     BPOINT = EPOINT = POINTS; 
     if (NPNTS > 1)
        EPOINT++; 
     else
        NPNTS = 2;
     Dist = 0;
     MinOffDist=999999;
     for (i=0;i<NPNTS-1;i++,BPOINT++,EPOINT++)
     {
         XMN = min (BPOINT->x, EPOINT->x);
         XMX = max (BPOINT->x, EPOINT->x);
         YMN = min (BPOINT->y, EPOINT->y);
         YMX = max (BPOINT->y, EPOINT->y);
         if (XMN >= BOUNDS->xmn && XMX <=BOUNDS->xmx &&
             YMN >= BOUNDS->ymn && YMX <=BOUNDS->ymx)
              goto Found;
         XDIFF = EPOINT->x - BPOINT->x;
         if (XDIFF == 0)
         {    if (BPOINT->x >= BOUNDS->xmn &&
                 BPOINT->x <= BOUNDS->xmx)
                if (!(YMN > BOUNDS->ymx ||
                      YMX < BOUNDS->ymn))
                       goto Found;
         }
         else
         {
             SLOPE = ((double)EPOINT->y - (double)BPOINT->y)/(double)XDIFF;
             YINT  = (double)BPOINT->y - SLOPE * (double)BPOINT->x;
             if (BOUNDS->xmn >= XMN && BOUNDS->xmn <= XMX)
             {
                 Y = SLOPE * (double)BOUNDS->xmn + YINT;
                 if (Y >= BOUNDS->ymn && Y <=BOUNDS->ymx)
                  goto Found;
             }
             if (BOUNDS->xmx >= XMN && BOUNDS->xmx <= XMX)
             {
                 Y = SLOPE * (double)BOUNDS->xmx + YINT;
                 if (Y >= BOUNDS->ymn && Y <=BOUNDS->ymx)
                  goto Found;
             }
             if (SLOPE != 0)
             {
                 if (BOUNDS->ymn >= YMN && BOUNDS->ymn <= YMX)
                 {
                     X = ((double)BOUNDS->ymn - YINT) / SLOPE;
                     if (X >= BOUNDS->xmn && X <=BOUNDS->xmx)
                      goto Found;
                 }
                 if (BOUNDS->ymx >= YMN && BOUNDS->ymx <= YMX)
                 {
                     X = ((double)BOUNDS->ymx - YINT) / SLOPE;
                     if (X >= BOUNDS->xmn && X <=BOUNDS->xmx)
                      goto Found;
                 }
             }
         }
         goto Next;
Found:   if (TotDist < 0)
{
#if ENABLETRACE
GSSiExitProg (1017);
#endif
			return (TRUE);
}
         nfound++; 
       	 ComputePickPointD (BPOINT, EPOINT, Dist, TotDist,PCT,OffDist,AZ, BOUNDS,PickedPoint);
         if (fabs(*OffDist)<MinOffDist)
         {
            MinOffDist = fabs(*OffDist);
            MinPCT = *PCT;  
            MinAZ = *AZ;
            MinPickedPoint = *PickedPoint;   
            MinFromPt = i;
         } 
Next:;
         Dist += ldistp (*BPOINT,*EPOINT);
     }
     if (!nfound)
{
#if ENABLETRACE
GSSiExitProg (1017);
#endif
        return (FALSE);
}
     else
     {
        *PCT = MinPCT;
        *OffDist = MinOffDist;
        *AZ = MinAZ;
        *PickedPoint = MinPickedPoint; 
        *pFromPtID = MinFromPt;
{
#if ENABLETRACE
GSSiExitProg (1017);
#endif
        return (TRUE);
}
     }
#if ENABLETRACE
}
#endif
}

BOOL PICK_POINT_ON_LINE(DPOINT pickPoint, MNMXCORD pickBounds, LPDPOINT pPickedPoint, long nPnts, HPDPOINT lpPointsIn)
{
    BOOL rtn = FALSE;
    double offDist, totDist=0;
    double az, pct;
    long fromPt;
    //MNMXCORD bounds;
    
    PickPointBase = pickPoint;
    rtn = LineInBoundsD (nPnts, lpPointsIn,totDist,&pct,
                         &offDist,&az,&pickBounds,pPickedPoint,&fromPt);
    
    return rtn;
}

BOOL PickPolylineD (HPDPOINT lpPointsIn,long nPnts, int PolyID,short Type,LPDOUBLE pAZ,LPDOUBLE pSize, long PinA)
#if ENABLETRACE
{GSSiEnterProg (707);
#endif
{
	DPOINT PickedPoint, WPoint, LastWPoint, NearPoint;
    //DPOINT BeginPoint, EndPoint, FromPoint, ToPoint;
	HPDPOINT lpPoints = lpPointsIn;//lpPointsIn[1]
	//POINT	BeginPointFile, EndPointFile, PickedPointFile;
	int	i, mini = 0;
    double	PCT, OffDist, TotDistW, AZ[3], MinDist, Dist;
    //double Area = 0;
	BOOL	First=TRUE, rtn=FALSE;   
	MNMXCORD	Rect;       
	long	FromPtID=-1;
   	double	PickDist;   
MNMXCORD WBounds;

	if (PickNET)
	{
		if (!RefInNet (CurrentRefno))
{
#if ENABLETRACE
GSSiExitProg (707);
#endif
			return FALSE;
}
	}
	if (hProfileSymbols)
{
#if ENABLETRACE
GSSiExitProg (707);
#endif
    	return 0;//(AddPolySymbolToProfile(CurrentDesc,1,lpPoints,nPnts,0,hProfileSymbols,&NumProfileSymbols));
}
    if (hHighlightArea)
{
#if ENABLETRACE
GSSiExitProg (707);
#endif
	return 0;//(PickPolyInAreaD(1, lpPoints, nPnts, 0, pAZ, pSize, 0, 0, 0, 0));
}
	
	TotDistW=0;  
	//BeginPoint = *lpPoints;
	MinDist = DBL_MAX;
	DBoundsInit (&Rect); 
	if (nPnts > 1)
	{
		AZ[0] = getazd (&lpPoints[0],&lpPoints[1]);
		AZ[2] = getazd (&lpPoints[nPnts-2],&lpPoints[nPnts-1]);
	} 
	else if (pAZ)
		AZ[0]=AZ[1]=AZ[2]=*pAZ; 
	else
		AZ[0]=AZ[1]=AZ[2]=0;
	for (i=0;i<nPnts;i++,lpPoints++)
	{   
		AddDPointToMinMax (lpPoints,&Rect);
		WPoint = *lpPoints;
		if (!First) 
			TotDistW += ldistp(LastWPoint,WPoint);
		else
			First = FALSE;
		LastWPoint = WPoint;
		if (!PickOnlyEndPoints || !i || i==nPnts-1)
		{  
			Dist = ldistp (PickPointBase,WPoint);
			if (Dist < MinDist)
			{
				MinDist = Dist;
				NearPoint = WPoint;
				mini = i;
			}
		}
	}
    
	//EndPoint = LastWPoint;
    
    if (PickingByRefno)
    {
    	PCT = 0.5;
    	OffDist = 0;
		PickedPoint = LastWPoint;
		//PickedPointFile = EndPointFile = BasePtToFilePt (PickedPoint);
		//BeginPointFile = BasePtToFilePt (BeginPoint);
    	goto Add;
    }
    
    if (PickOnlyEndPoints)
    {   
    	OffDist = MinDist;
	    if (OffDist > PickApW) 
			goto Exit;
        
		if (mini)
		{
			PCT = 1;  
			AZ[1] = AZ[2];
		}
        
		else
		{
			PCT = 0; 
			AZ[1] = AZ[0];
		}
		PickedPoint = NearPoint;
	}
    
	else
	{
		if (!LineInBoundsD (nPnts,lpPointsIn,TotDistW,&PCT,&OffDist,&AZ[1],
						    &WBounds,&PickedPoint,&FromPtID))
						     goto Exit;   
	    if (WantOnlyShapePoints)
	    {
		   	PickedPoint = NearPoint;  
	    	OffDist = ldistp (PickPointBase,PickedPoint);
	    }
		if (pSize)
			PickDist = max (0,OffDist - *pSize);  
		else
			PickDist = OffDist;
		if (PickDist > PickApW)
			goto Exit;
	}
//	if (nPnts == 1 && AddToPickAp > 0)
//		OffDist = max (0,fabs(OffDist)-AddToPickAp);
	for (i=0; i<NumPicked; i++)
	{
		if (CurrentRefno == PickList[i].Refno)
		{
			if (fabs(OffDist)<fabs(PickList[i].OffDist))
				PickListDelete((int)i);
			else
				goto Exit;
		}
	} 
Add: 
	rtn = TRUE;
	if (PinA)
//		OffDist = PinA; 
		OffDist = fabs(OffDist) + PinA;
    
	if (InSnapNode)
		OffDist = ldistp (PickPointBase,NearPoint);
    
	if (!PickingByRefno)
	{
		//PickedPointFile = BasePtToFilePt (PickedPoint);
		//BeginPointFile = BasePtToFilePt (BeginPoint);
		//EndPointFile = BasePtToFilePt (EndPoint);
	}
    
	/*if (Type == 3)
		Area = ComputeAreaAreaD(lpPointsIn, nPnts, &TotDistW);
    
	if (pSize)
		TotDistW = *pSize;*/
    
	if (GetGlobalBVal2("[%PICKPOINTFIRST]",FALSE))
	{
		if (Type == 1)
			OffDist = 0;
        
		else if (OffDist >= 0)
			OffDist += P_TOL;
        
		else
			OffDist -= P_TOL;
	}
    
	if (nPnts == 1 && pSize)
		ExpandBounds(&Rect, *pSize);
    
	/*if (FromPtID > -1 && nPnts > 1)
	{
		FromPoint = lpPointsIn[FromPtID];
		ToPoint = lpPointsIn[FromPtID+1];
	}
    
	else
		FromPoint = ToPoint = *lpPointsIn;*/
    
	/*PickListAdd (FileNum,SubFile,FileInIndex,ItemSeg,CurrentRefno,CurrentDesc,PolyID,
				   Type,PCT,OffDist,AZ,TotDistW,CurrentItem,CurElement,
				   BeginPoint,EndPoint,PickedPoint,NearPoint,mini,fabs(Area),&Rect,
				   BeginPointFile, EndPointFile,PickedPointFile,nPnts,NULL_ELEV,&FromPoint,&ToPoint);*/
Exit:
{
#if ENABLETRACE
GSSiExitProg (707);
#endif
	return (rtn);
}
#if ENABLETRACE
}
#endif
}

/*
static double ComputeAreaAreaD (HPDPOINT lpDpoints,long nPnts,LPDOUBLE pPerim)
#if ENABLETRACE
{GSSiEnterProg (404);
#endif
{    
	int	i; 
	DPOINT	BeginPoint, LastPoint;
	double	Area=0,Perim=0;    

	for (i=0;i<nPnts;i++,lpDpoints++)
	{   
		if (!i)
			BeginPoint = *lpDpoints;
		else  
		{
			Perim += ldistp(LastPoint,*lpDpoints);
			Area += ( LastPoint.y - lpDpoints->y) * (lpDpoints->x + LastPoint.x) / 2;
		}
		LastPoint = *lpDpoints;
	} 
	Perim += ldistp(LastPoint,BeginPoint);
	Area += (LastPoint.y - BeginPoint.y) * (BeginPoint.x + LastPoint.x) / 2;  
	if (pPerim)
		*pPerim = Perim;
{
#if ENABLETRACE
GSSiExitProg (404);
#endif
	return (Area);
}
#if ENABLETRACE
}
#endif
}
*/

BOOL  POINT_IN_AREAD (DPOINT PickPoint, DWORD nPoints, HPDPOINT lpAreaPoints,int nPoly,HANDLE hPolyPartLen,LPDOUBLE pNextXIntersect,LPHANDLE pAccelerator)
#if ENABLETRACE
{GSSiEnterProg (359);
#endif
{
/*C******* SPECIFICATIONS ***********************************************
C*                                                                    *
C*       PROGRAM SUMMARY                                              *
C*       ------- -------                                              *
C*       THIS ROUTINE DETERMINES if THE POINT SEGPOS IS IN THE        *
C*       AREA DEFINED IN THE PICKED AREA COMMON.                      *
C*                                                                    *
C*       ARGUMENT DESCRIPTION                                         *
C*       -------- -----------                                         *
C*       SEGPOS   R*4[1] THE SEGMENT COORDINATES OF THE POINT         *
C*                                                                    *
C*       AUTHOR: JEFF SMITH                                           *
C*                                                                    *
C**********************************************************************
C*/
#if WIN32
    DPOINT  *lpPoint;
#else
    HPDPOINT lpPoint;
#endif

    double   A1, A2, INTX, INTY, XP, YP, XMID1 = 0.0, XMID2, YMID1 = 0.0, YMID2, AMID,
             PAX1, PAY1, PAX2, PAY2, MXX, MNY, MXY,
             XMIDMN, XMIDMX, YMIDMN, YMIDMX, XMID2_NEED = 0.0, YMID2_NEED = 0.0;

    BOOL HAVE_MID1, NEED_MID1, p_in_a;

    long  IRC ;
    DWORD	ip;
    short NIN;
    //short ii;
	//LPPIAAStruct pPIAA;
      
      /*if (pAccelerator)
      { 
      	int	iaccel;
      	
      	//if (!*pAccelerator)
      	//	*pAccelerator = PointInAreaAcceleratorSetup (nPoints,lpAreaPoints,nPoly,hPolyPartLen,0);
      	if (*pAccelerator) 
      	{
	      	iaccel = PointInAreaAccelerator (&PickPoint,*pAccelerator);
	      	if (iaccel == 0)         
	      	{
	      		counts[0]++;
	      		goto RtnFalse;  
	      	}
	      	else if (iaccel == 1)   
	      	{
	      		counts[1]++;
	      		goto RtnTrue;
	      	}
	     }
	     else
	     	ii=1;
      } */
//      counts[2]++;
      if (pNextXIntersect)
      	*pNextXIntersect = DBL_MAX;
      A2 =  (double) 0;
      p_in_a = FALSE;

      XP = PickPoint.x;
      YP = PickPoint.y;

      HAVE_MID1 = FALSE;
      NEED_MID1 = FALSE;
      NIN = 0;
      
      if (pAccelerator && *pAccelerator)
      {
		//pPIAA = (LPPIAAStruct)GlobalLock (*pAccelerator);
		GlobalUnlock (*pAccelerator);
      }
    
      lpPoint = lpAreaPoints + (nPoints-1);
      PAX1 = lpPoint->x;
      PAY1 = lpPoint->y;
      lpPoint = lpAreaPoints;
      for (ip = 0; ip <nPoints; ip++,lpPoint++)
      {
/*C******* LOOK ONLY FOR INTERSECTIONS WITH X GE XP  */
          PAX2 = lpPoint->x;
          PAY2 = lpPoint->y;
          MXX = max (PAX1,PAX2);
          if (XP > MXX) goto S100;
          MNY = min (PAY1,PAY2);
          if (YP < MNY) goto S100;
          MXY = max (PAY1,PAY2);
          if (YP > MXY) goto S100;
          A1 = LGETAZ (PAX1,PAY1,PAX2,PAY2);
          IRC = LIN_SEC (PAX1,PAY1,A1, XP, YP, A2, &INTX, &INTY);
/*C******* IGNORE PARALLEL LINES */
          if (IRC != 0)  goto S100;
/*C******* if POINT ON AREA SIDE IT IS IN THE AREA */
          if (LDIST(INTX,INTY,XP,YP) <= P_TOL)  
          {
          if (pNextXIntersect)
          	*pNextXIntersect = INTX;
			goto RtnTrue;
		  }
          if (INTX < XP)  goto S100;
          if (pNextXIntersect)
          	*pNextXIntersect = min (*pNextXIntersect,INTX);
          NIN++;
/*             if intersection within p_tol of the begin point of this line
C              find the midpoint of the last non-parallel line and intersect
C              the horizontal line with the line between the found midpoint
C              and the midpoint of this line. if the intersection
C              is not between the midpoints keep this intersection. */
          if (LDIST(INTX,INTY,PAX1,PAY1) <= P_TOL)
          {
               if (HAVE_MID1)
	           {  XMID2  = (PAX1 + PAX2) / (double) 2;
	              YMID2  = (PAY1 + PAY2) / (double) 2;
	              XMIDMN = min (XMID1, XMID2);
	              XMIDMX = max (XMID1, XMID2);
	              YMIDMN = min (YMID1, YMID2);
	              YMIDMX = max (YMID1, YMID2);
	              AMID   = LGETAZ (XMID1,YMID1,XMID2,YMID2);
	              IRC = LIN_SEC (XMID1,YMID1,AMID,XP,YP,A2,&INTX,&INTY);
	              if (IRC == 0 && (INTX >= XMIDMN &&
	                  INTX <= XMIDMX)&& (INTY >= YMIDMN &&
	                  INTY <= YMIDMX))
	              { NIN--; }  
	           }
	           else
               {   
               	  NEED_MID1 = TRUE;
                  XMID2_NEED = (PAX1 + PAX2) / (double) 2 ;
                  YMID2_NEED = (PAY1 + PAY2) / (double) 2 ;
               }
          }
          if (fabs (PAY1 - PAY2) > P_TOL)
          {
	          HAVE_MID1 = TRUE;
	          XMID1 = (PAX1 + PAX2) / (double) 2 ;
	          YMID1 = (PAY1 + PAY2) / (double) 2 ; 
	      }
S100:     PAX1 = PAX2;
          PAY1 = PAY2;
      } /* end of the for loop */



      if (NEED_MID1)
      {   XMID2  = XMID2_NEED;
          YMID2  = YMID2_NEED;
          XMIDMN = min (XMID1, XMID2);
          XMIDMX = max (XMID1, XMID2);
          YMIDMN = min (YMID1, YMID2);
          YMIDMX = max (YMID1, YMID2) ;
          AMID  = LGETAZ (XMID1,YMID1,XMID2,YMID2);
          IRC = LIN_SEC (XMID1,YMID1,AMID,XP,YP,A2,&INTX,&INTY);

          if (IRC == 0 &&
             (INTX >= XMIDMN && INTX <= XMIDMX)&&
             (INTY >= YMIDMN && INTY <= YMIDMX))
             { NIN--;}
      }
      if (NIN % 2  == 1){ p_in_a = TRUE;}
{
#if ENABLETRACE
GSSiExitProg (359);
#endif
      return(p_in_a);
}
RtnTrue:
{
#if ENABLETRACE
GSSiExitProg (359);
#endif
      return(TRUE);
}
RtnFalse:
{
#if ENABLETRACE
GSSiExitProg (359);
#endif
      return(FALSE);
}
#if ENABLETRACE
}
#endif
}

/*
static BOOL LININT (double L1X1, double L1Y1, double L1X2, double L1Y2,
			 double L2X1, double L2Y1, double L2X2, double L2Y2)
#if ENABLETRACE
{GSSiEnterProg (360);
#endif
{
      double SLOPE1 = 0.0, SLOPE2 = 0.0, YINT1, YINT2, X, Y, XDIFF, YDIFF;
      BOOL INF1, INF2;
      
      if ( (L1X1 ==L2X1 && L1Y1 ==L2Y1) ||
           (L1X1 ==L2X2 && L1Y1 ==L2Y2) ||
           (L1X2 ==L2X1 && L1Y2 ==L2Y1) ||
           (L1X2 ==L2X2 && L1Y2 ==L2Y2) ) goto S550;
      XDIFF  = L1X1 - L1X2;
      YDIFF  = L1Y1 - L1Y2;
      if (fabs (XDIFF) <1e-20) goto S10;
      SLOPE1 = YDIFF / XDIFF;
      YINT1  = L1Y1 - SLOPE1 * L1X1;
      INF1   = FALSE;
      goto S20;
 S10: INF1   = TRUE;
      YINT1  = L1Y1;
 S20: XDIFF  = L2X1 - L2X2;
      YDIFF  = L2Y1 - L2Y2;
      if (fabs (XDIFF) <1e-20) goto S30;
      SLOPE2 = YDIFF / XDIFF;
      YINT2  = L2Y1 - SLOPE2 * L2X1;
      INF2   = FALSE;
      goto S50;
 S30: INF2   = TRUE;
      YINT2  = L2Y1;
 S50: if (!INF1) goto S60;
      if (!INF2) goto S100;
      goto S250;
 S60: if (!INF2) goto S300;
      goto S200;
//SLOPE1 IS INFINITE - SLOPE2 IS NOT
S100: X      = L1X1;
      Y      = SLOPE2 * X + YINT2;
      goto S500;
//SLOPE2 IS INFINITE - SLOPE1 IS NOT
S200: X      = L2X1;
      Y      = SLOPE1 * X + YINT1;
      goto S500;
//BOTH SLOPES ARE INFINITE
S250: if (L1X1 ==L2X1) goto S510;
      goto S550;
//NIETHER SLOPE IS INFINITE
S300: if (SLOPE1 !=SLOPE2) goto S310;
      if (YINT1  !=YINT2)  goto S550;
      goto S510;
S310: X      = (YINT2 - YINT1) / (SLOPE1 - SLOPE2);
      Y      = SLOPE1 * X + YINT1;
//DETERMINE IF THE POINT X,Y IS ON BOTH LINES
S500: if (X <min (L1X1,L1X2) || X > max (L1X1,L1X2) ||
          X <min (L2X1,L2X2) || X > max (L2X1,L2X2) ||
          Y <min (L1Y1,L1Y2) || Y > max (L1Y1,L1Y2) ||
          Y <min (L2Y1,L2Y2) || Y > max (L2Y1,L2Y2))
          goto S550;
S510:
{
#if ENABLETRACE
GSSiExitProg (360);
#endif
	return TRUE;
}
S550:
{
#if ENABLETRACE
GSSiExitProg (360);
#endif
	return FALSE;
}
#if ENABLETRACE
}
#endif
}
*/

static short LIN_SEC (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
             double A2,double *X3,double *Y3)
#if ENABLETRACE
{GSSiEnterProg (361);
#endif
 {  short   irc;
    // retrns 0 if successful, 1 if lines parallel or 2 if cooincident
    irc = LINSEC_TOL (X1IN, Y1IN, A1, X2IN, Y2IN, A2, X3, Y3, P_TOL);
    if (irc == 1)
{
#if ENABLETRACE
GSSiExitProg (361);
#endif
    	return(0);
}
    if (!irc)
{
#if ENABLETRACE
GSSiExitProg (361);
#endif
    	return(2);
}
{
#if ENABLETRACE
GSSiExitProg (361);
#endif
    return(1);
}
#if ENABLETRACE
}
#endif
 }

