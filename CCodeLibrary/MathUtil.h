#ifndef __MATHUTIL_H
#define __MATHUTIL_H
#include "CCodeTypes.h"
#include "gssitype.h"
#include "TileGraphics.h"

#include <stdlib.h>
#include <string.h>
#include <float.h>
#include <math.h>
#include <stdio.h>
#import <CoreGraphics/CoreGraphics.h>
double LTWOPI (double AZ1);
void setP_TOL (double val);

//1D
float ClockwiseDegFromNorth (float deg);
float DegreesToRadians(float degrees);
float Lerp(float f0, float f1, float t);
int	Clamp(int n, int clampMin, int clampMax);
float ClampF(float n, float clampMin, float clampMax);
float MaxF(float l, float r);
int Max(int l, int r);

//2D
POINT DPointToPoint (DPOINT *dpt);
float DotVec2(vec2* vec0, vec2* vec1);
void LerpVec2(vec2* out_lerpedPos, vec2* p0, vec2* p1, float t);
void NormalizeVec2(vec2* vec);
float MagnitudeVec2(vec2* vec);
void SubVec2(vec2* out_resultVec, vec2* p0, vec2* p1);
void SubVec2_Self(vec2* out_resultVec, vec2* p);
void ScaleVec2_Self(vec2* vec, float scale);
void ScaleVec2(vec2* out_resultVec, vec2* vec, float scale);
void AddVec2_Self(vec2* out_resultVec, vec2* vec);
void AddVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1);
void AddScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void AddScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void SubScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void SubScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void CopyVec2(vec2* out_result, vec2* point);
void CreatePlaneFromPointsVec2(struct PlaneVec2* out_resultPlane, vec2* p0, vec2* p1);
Bool PointInsidePlaneVec2(vec2* point,struct PlaneVec2* plane);
Bool PointInsidePlaneVec2(vec2* point, struct PlaneVec2* plane);
float AngleBetweenVec2(vec2* vec0, vec2* vec1);

//3D
void SetVec3(vec3* out_resultVec,float x, float y, float z);
void CrossVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1);
float DotVec3(const vec3* vec0, const vec3* vec1);
void LerpVec3(vec3* out_lerpedPos, const vec3* p0, const vec3* p1, float t);
void NormalizeVec3(vec3* vec);
float MagnitudeVec3(const vec3* vec);
Bool PosIsBehind(const vec3* frontPos, const vec3* frontAt, const vec3* behindPos);
float DistSqVec3(const vec3* vec0, const vec3* vec1);
float DistVec3_2D(const vec3* vec0, const vec3* vec1);
float DistVec3(const vec3* vec0, const vec3* vec1);
float MagnitudeSqVec3(const vec3* vec);
void AddVec3_Self(vec3* out_resultVec, vec3* vec);
void AddVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1);
void AddScaledVec3_Self(vec3* out_resultVec, const vec3* vec, float scale);
void AddScaledVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1, float scale);
void SubScaledVec3_Self(vec3* out_resultVec, vec3* vec, float scale);
void SubScaledVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1, float scale);
void SubVec3(vec3* out_resultVec, const vec3* p0, const vec3* p1);
void ScaleVec3_Self(vec3* vec, float scale);
void ScaleVec3(vec3* out_resultVec, const vec3* vec, float scale);
void CopyVec3(vec3* out_result, const vec3* point);
float AngleBetweenVec3(vec3* vec0, vec3* vec1);
double Between0And360D (double ival);
double DeltaAngle (double AZ1, double AZ2);
int Between0And360 (int ival);
int iDist(double X1, double Y1, double X2, double Y2);
float distpd(vec2 *Point1, vec2 *Point2);
double ddistp(DPOINT *Point1, DPOINT *Point2);
float getazmd (vec2 *Point1, vec2 *Point2);
vec2  newpt (vec2 *OldPoint, float AZM, float DIS);
dvec2 dnewptp (dvec2 *OldPoint, double AZM, double DIS);
DPOINT dnewpt(DPOINT OldPoint, double AZM, double DIS);
DPOINT dnewpoint (DPOINT *OldPoint, double AZM, double DIS);
float DeltaAZ (float *AZ1, float *AZ2);
double DeltaAZD (double AZ1, double AZ2);
float BTWNTWOPI (float AZ1);
void InitBounds (bounds* bnds);
void AddPointToBounds (bounds* bnds,vec2 *pt);
void AddDPointToBounds(dbounds *pBounds, DPOINT *pt);
void InitDBounds (dbounds* bnds);
void InitIBounds (IBOUNDS* bnds);
void DBoundsInit(LPMNMXCORD bnds);
double BoundsWidth(dbounds* bnds);
double BoundsHeight(dbounds* bnds);
double MNMXCORDWidth(MNMXCORD* bnds);
double MNMXCORDHeight(MNMXCORD* bnds);
void AddMinMaxD (LPMNMXCORD mm1, LPMNMXCORD mm2);
void AddMinMaxL (LPMNMXCORL mm1, LPMNMXCORL mm2);
LPDPOINT PointsFromCorners (CORNERPOINTS* pCornerPoints);
CORNERPOINTS CornerPointsFromLatLonAndDist (LLPOINT llpt,double dist); //dist in meters
CORNERPOINTS CornerPointsFromLLBoundsAndView (LPMNMXCORD pareaBounds,LPMNMXCORD pviewBounds);
MNMXCORD CornerPointBounds (CORNERPOINTS* cornerPoints);
IBOUNDS IBoundsFromPointAndDist (IPOINT pt,int dist);
MNMXCORD BoundsFromPointAndDist(DPOINT pt, double dist);
MNMXCORD BoundsFromLLPointAndDist(LLPOINT pt, double distInMeters);
MNMXCORD LLBoundsToPixelBounds (MNMXCORD * latlonBounds,int levelOfDetail);
IPOINT IBoundsMid (IBOUNDS* bnds);
DPOINT DBoundsMid(MNMXCORD *bnds);
DPOINT MidPointD (DPOINT pt1,DPOINT pt2);
Bool DPointInBounds (LPDPOINT pt,LPMNMXCORD pbounds);
Bool BoundsInBounds (LPMNMXCORD pBounds1,LPMNMXCORD pBounds2,short Opt);
void AddPointToDBounds (dbounds* bnds,dvec2 *pt);
void AddPointToIBounds (IBOUNDS* pBounds,IPOINT *pt);
MNMXCORD PolyBounds (LPDPOINT points,int npoints);
void Rotate256 (int irot,vec2* pt);
double LDIST(double X1,double Y1,double X2,double Y2);
double LGETAZ(double X1, double Y1, double X2, double Y2);
double DTWOPI (double az);
vec3 GetTriangleNormal (vec3 * vertex1,vec3 * vertex2,vec3 * vertex3);
double square (double x);
double ComputeMaxSlope (double frontSlope,double sideSlope);
/*
LPTRANDATA STRAN2 (int ID,double X1[], double Y1[],double X2[],double Y2[],int N, int Type,LPFLOAT RSQMIN);
LPTRANDATA STRANPoints (LPDPOINT FromPt,LPDPOINT ToPt,int nPt,int Type,LPFLOAT pRSQMIN);//,LPMNMXCORD pBounds);
LPTRANDATA  STRANBoundsToBounds (LPMNMXCORD FromRect,LPMNMXCORD ToRect);
LPTRANDATA  STRANCornersToBounds (CORNERPOINTS *corners,LPMNMXCORD ToRect);
LPTRANDATA  STRANBoundsToCorners (CORNERPOINTS *corners,LPMNMXCORD ToRect);
void CloseTRANS2 (LPTRANDATA *phlpTran);
void TRANS2(double XIN, double YIN, LPDOUBLE XOUT, LPDOUBLE YOUT, LPTRANDATA TranPtr);
void CloseTRANS2 (LPTRANDATA *phlpTran);
HANDLE STRANCGRect (CGRect fromCGRect,CGRect toCGRect);
RECT CGRectToRect (CGRect cgRect);
CGRect RECTtoCGRect (RECT rect);
CGRect TranCGRect (CGRect fromCGRect,HANDLE hTran);
LPTRANDATA STRANCopy (LPTRANDATA pTran);
void TranMNMXCORL (MNMXCORL * in,MNMXCORL * out,LPTRANDATA TranPtr);
void TranMNMXCORD (MNMXCORD * in,MNMXCORD * out,LPTRANDATA TranPtr);
DPOINT TranDPOINT (LPDPOINT pPoint,LPTRANDATA  hTran);
POINT TranDPOINTtoPOINT (LPDPOINT pPoint,LPTRANDATA  hTran);
void TranPoints(LPDPOINT FromPt, LPDPOINT ToPt, int nPt, LPTRANDATA hTran);
IPOINT TranIPPOINT (IPOINT InPoint,LPTRANDATA  hTran);
LPTRANDATA  LoadTranFromBPW (char * Name, int dir);
LPTRANDATA  LoadTranFromCPT (const char * Name, int dir);
*/
void MNMXCORLtoMNMXCORD (MNMXCORL *in,MNMXCORD *out);
void MNMXCORDtoMNMXCORL (MNMXCORD *in,MNMXCORL *out);
CGRect MNMXCORDtoCGRect (LPMNMXCORD pBounds);
void InflateMNMXCORL (LPMNMXCORL pBounds, int Value);
int diffInDegrees (int angle1,int angle2);
int CreateMask (LPDPOINT *pPointsIN, int *pnPoints,LPMNMXCORD pbnds,Bool freeExistingPoints);
DPOINT NewLatLong(double Lat,double Long,double Dist,double Direction);
LLPOINT NewLLPoint(LLPOINT pt,double dist,double az);
DPOINT LLPointToDPoint (LLPOINT llpt);
LLCORNERPOINTS LLCornerPointsFromCornerPoints (CORNERPOINTS * cp);
double ArcDistance(DPOINT p1, DPOINT p2);
double ArcDistanceLL(LLPOINT p1, LLPOINT p2);
double LLRectInSQMeters (LLCORNERPOINTS latlonCornerPoints);
Bool findClosestPoint (LPDPOINT pPoint,LPDPOINT pNearPt,double *mind,LPDPOINT p1);
Bool findClosestPointll (LPDPOINT pPoint,LPDPOINT pNearPt,double *mind,LPDPOINT p1);
Bool findClosestLLPoint (LLPOINT *pPoint,LLPOINT *pNearPt,double *mind,LLPOINT *p1LL);
Bool pointInDBounds (DPOINT *pt,dbounds *bounds);
Bool  POINT_IN_AREAD (DPOINT PickPoint, DWORD nPoints, HPDPOINT lpAreaPoints,int nPoly,HANDLE hPolyPartLen,LPDOUBLE pNextXIntersect,LPHANDLE phAccelerator);

Bool PICK_POINT_ON_LINE (DPOINT pickPoint,MNMXCORD pickBounds,LPDPOINT pPickedPoint,long nPnts,HPDPOINT lpPointsIn);
Bool sameDPoint (LPDPOINT p1, LPDPOINT p2,double tol);
Bool samePoint (LPPOINT p1, LPPOINT p2);
double ComputeAreaAreaD (HPDPOINT lpDpoints,long nPnts,LPDOUBLE pPerim,LPMNMXCORD pBounds);
LPSTR Truncate(LPSTR Text);
LPSTR OneSpace(LPSTR Arg1);
LPSTR REPLAC(LPSTR STRING, LPCSTR OLD, LPCSTR NEW, int MAXLEN);
LPSTR ReplaceChar(LPSTR str, char from, char to);
Bool LINFIT(LPDPOINT pPoint, long N, double *A, double *B, double *MAXDIF, long *LOFMDF);
double ldistpp(LPDPOINT Point1, LPDPOINT Point2);
double l2ddistfrom3d (DPOINT3D Point1, DPOINT3D Point2);
double ldistp(DPOINT Point1, DPOINT Point2);
double idist(POINT Point1, POINT Point2);
double GetPolyLength (LPPOINT lpPoints,long nPnts);
double GetPolyLengthD (HPDPOINT lpPoints,long nPnts);
int GetAltitudeAndAzOfSun (DPOINT LatLon,double Height,time_t systime,double *pAltitude,double *pAz);
LPDPOINT PointsFromCGRect (CGRect *pRect);
CGRect largestRect (float aspectRatio,int precision,CGRect bounds,int nRects,CGRect* rects);
short LINSEC_TOL (double X1IN,double Y1IN,double A1,double X2IN,double Y2IN,
                  double A2,double *X3,double *Y3,double INTOL);
double AZMLatLon (LLPOINT pt1,LLPOINT pt2);
double AZMToHeading (double azm);
void BoundsToPoints (LPMNMXCORD pBounds, LPDPOINT Points,LPDOUBLE pAZ);
LPSTR AddCommas (LPSTR InBuff);
CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh, CGColorSpaceRef colorSpace, void **bmData);
Bool WriteBitmapDataToFile (LPSTR file,int pixelsWide, int pixelsHigh, CGColorSpaceRef colorSpace, void *bmData);
CORNERPOINTS * CORNERPOINTS_view (CORNERPOINTS * pcp);
LPMNMXCORD MNMXCORD_view (LPMNMXCORD pmm);


#endif
